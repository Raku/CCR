# Better usage information in the MoarVM specializer
    
*Originally published on [2018-07-20](https://6guts.wordpress.com/2018/07/20/better-usage-information-in-the-moarvm-specializer/) by Jonathan Worthington.*

I’ve been doing lots of work on the MoarVM specializer of late, and will be writing a few posts here to explain it. This work has been covered by my grant from [The Perl Foundation](http://news.perlfoundation.org/2018/01/grant-extension-request-perl-6-1.html).

This post covers the recent addition of DU (Define-Use) chains. I’ll explain what they are, what kind of optimizations they have helped with so far, and how they can help us ensure the specializer is free of certain kinds of bug.

### A little background

The MoarVM specializer helps programs run faster by ripping out as much unrequired generality as it knows how. This involves a bunch of different analyses, and those are aided by the program being turned into SSA (Static Single Assignment) form. This happens not at the Raku program level, but rather at the bytecode level. MoarVM’s interpreter is a register machine, so something like:

```` raku
($a + $b) * $c
````

Could, assuming these are all native integer variables, compile into something like:

```` raku
getlex r0, '$a'
getlex r1, '$b'
add_i r0, r0, r1
getlex r1, '$c'
mul_i r0, r0, r1
````

Notice how registers `r0` and `r1` are re-used for multiple things. Now imagine that these registers hold objects and we are trying to track types and other such information. Since a register may be used for completely different things over its lifetime, we can’t just associate information with the register.

Transforming the bytecode into SSA form helps. We give each use of the register a version number:

```` raku
getlex r0(1), '$a'
getlex r1(1), '$b'
add_i r0(2), r0(1), r1(1)
getlex r1(2), '$c'
mul_i r0(3), r0(2), r1(2)
````

Now we can associate information with each version of the register, greatly easing analysis of the program.

### Defines

When a program is in SSA form, every versioned register has one definition: the instruction that writes it. Since it can never be written again anywhere in the SSA form of the bytecode, the writer is a single instruction. There are no MoarVM instructions that write more than one register, and so an instruction defines at most one value, and every versioned register has precisely one instruction that defines it.

So, defines are easy. For as long back as I can remember, we’ve stored a reference to the writing instruction of each versioned register, so whenever we see a read of it then we can always quickly find the defining instruction.

### Uses

Until recently, we stored a counter of how many times each versioned register was used. We made an initial pass through the graph representing the bytecode to be optimized, bumping the usage count each time we saw a versioned register being used. Then, as we optimized, we could update those counts.

Usage information is especially useful taken together with knowledge of which instructions are *pure* – that is to say, they produce a result, but don’t have any effects besides that. If the usage count of such an instruction drops to zero, then we can delete it.

For example, if we have an attribute `has str $!value` in a class, it would be compiled into something like this:

```` raku
  wval              r4(2), liti16(1), liti16(36) (P6opaque: Str)
  getattr_s         r5(1),   r0(2),   r4(2), lits($!value)
````

The `wval` instruction grabs the type object of the class that declares the attribute. This is used together with the attribute name to do a lookup (since parent and child classes may have attributes of the same name, but they are different attributes since they are in different classes). Provided we know the type of `r0(2)` – which is holding `self` – then we might optimize it into:

```` raku
  wval              r4(2), liti16(1), liti16(36) (P6opaque: Str)
  sp_p6oget_s       r5(1),   r8(3), liti16(8)
````

Where the `8` is an offset in bytes indicating where the attribute lives in the memory of the object. We’ve turned a lookup by name into pointer chasing, which will later JIT into some pretty simple machine code (not quite as simple as we want yet, but still vastly faster than the normal lookup path).

But wait! What about that `wval` there? We don’t need it now. And so, after the various optimizations have taken place, we do Dead Instruction Elimination. So long as the usage count has dropped to zero – that is, nothing else is using the value – we can delete the instruction, meaning the end result is just:

```` raku
  sp_p6oget_s       r5(1),   r8(3), liti16(8)
````

### Deoptimization complication

So far, so relatively simple. Alas, there’s complications. Some values might become unused after we optimize the code, but we still can’t delete them. We use statistics to drive optimization, and do a great deal of speculation. For example, if we see 99% of the time a particular type shows up in the program, we optimize it assuming that type. But what if the 1% case shows up? Or what if we saw a certain type 100% of the time *so far*, but there’s a different one in the future? In that case, we drop back to the normal interpreter to handle it. For that to work out, however, we must make sure that the values the interpreter needs are still available after this *deoptimization* has taken place.

Up until recently, whenever we detected that a value *might* be needed if deoptimization happens, we simply gave its usage count an extra bump. This meant that even if we deleted all of its uses in the graph, we’d still not delete it. (This was a very coarse-grained analysis. I’ll discuss that more in a future post.)

### You can’t count on this

The usage count was a fine enough approach to start out with, but it gradually came to be insufficient.

One bug that it’s quite possible to make is to forget to increment or decrement the usage count. The cases where it ended up too high could prevent us from deleting an instruction we didn’t need, leading to worse code. This wasn’t very serious, though a bit sub-optimal. The other way round – failing to increment the count – is of course more dangerous, since it may lead to an instruction being deleted that we really need. This didn’t happen often – we’re relatively careful – but it’d be nice if we had a way to verify it wasn’t happening at all. However, the +1 for the sake of deoptimization would have frustrated doing such an analysis.

A further issue is that while finding the place that a given versioned register was defined was easy, there was no cheap way to find its usages. Having such information would make some optimizations we already did easier and more effective, as well as make it easier to do some that we’re keen to add in the near future.

Beyond that, a single number was uninformative for those of us working on the optimizer. We could see the number, but what was it telling us? Why was the register still in use?

### Adding use chains

So, instead of storing a count, we’ve started storing a linked list that points to each instruction that uses the versioned register. Often we only care about used, used precisely once, or unused; in fact, the only place we need the exact count is for debug output. Therefore, we can answer all the common questions we could with the usage count without having to traverse the chain. Building the chain is easy: everywhere we used to bump the counter, we now add an entry into the chain.

This chain works well for instructions that use the value, but what about the deoptimization usage? This was handled by storing that piece of information as a separate flag. It could then be displayed alongside the real usage count in the debug output, so we could quickly understand which registers were in use *only* for the purpose of deoptimization.

### Checking the chains

Along with this, I implemented a chain checker. It goes through the instruction graph and the use chains, and makes sure:

- Every versioned register that is used in the instructions has an entry in the chain
- There are no entries in the chain that don’t appear in the graph
- Every used value has its writing instruction set correctly

This isn’t done by default – it costs something – but is available as a flag MoarVM developers can turn on when implementing new optimizations to aid with verifying they are, at least in this regard, correct.

### Improving elimination of set instructions

Often in Raku, code has to deal with both values and values held in `Scalar` containers – that is to say, it’s polymorphic over the two cases. In the case that we have a `Scalar` container, we have to remove the value from it. This is an incredibly common operation in Raku, and there is a single op – `decont` – that checks if we have a container and takes the value out of it if so. Code generation conservatively inserts quite a lot of these.

Often, we simply have a value, and so there’s nothing to do. And often, the specializer can tell there will be nothing to do. Thus, something like this:

```` raku
  decont            r5(2),   r0(2)
  findmeth          r4(2),   r5(2), lits(chars)
````

Is turned into this:

```` raku
  set               r5(2),   r0(2)
  findmeth          r4(2),   r5(2), lits(chars)
````

Where `set` simply sets the value of one register into another. For this and various other reasons, it’s quite common that – after optimizations – we end up with code chock full of `set` instructions. They’re cheap, but they certainly aren’t free – on two counts. Firstly, there’s the execution cost of them. Secondly, they make the optimized code larger than it needs to be. This both makes less efficient use of the CPU’s code cache once we JIT the optimized result, but also can push the code over the inlining size limit, and thus it might miss out on further powerful optimizations.

We did have some code to try and get rid of `set` instructions. It was less than awesome on multiple counts. Firstly, it still left quite a few behind that we could see by inspection of the code could go away. Secondly, it could make a mess of the SSA form. Since it was one of the very last optimizations we did, that wasn’t a big deal, but it did make the debug output confusing, plus we will be adding more optimizations to this second pass in the future. Thirdly, it was somewhat adhoc, mostly written to handle peephole patterns that commonly showed up.

The usage chains provide a way to do better. The new `set` elimination algorithm covers the previous cases *and* new ones, and yet only does two fairly straightforward things.

Firstly, it looks if the writer of the `set`‘s second operand has only one usage, which is that set instruction, and no deopt usages. If so, and if there are no interfering uses of different versions of the register that the `set` writes, then it can have the writing instruction changed to write to the register that the `set` would, and the `set` instruction can then be deleted.

Failing that, it uses the use chain to check if there is a single user of the versioned register that the `set` instruction writes to. Again, given no conflicts, it can eliminate the set instruction by arranging for the user of the `set` instruction to instead use the value that the `set` would read. So in our case:

```` raku
  set               r5(2),   r0(2)
  findmeth          r4(2),   r5(2), lits(chars)
````

We’d end up with:

```` raku
  findmeth          r4(2),   r0(2), lits(chars)
````

To give a practical example of this, here is how the optimized code of the `chars` method called on a `Scalar` holding a `Str` looks without the `set` elimination:

```` raku
  sp_getarg_o       r1(2), liti16(0)
  set               r8(2),   r1(2)
  set               r1(3),   r8(2)
  [Annotation: Logged (bytecode offset 24)]
  sp_p6oget_o       r8(3),   r1(3), liti16(16)
  [Annotation: INS Deopt One (idx 0 -> pc 30; line 2838)]
  sp_guardconc      r8(3), sslot(1), litui32(30)
  set              r11(2),   r8(3)
  set               r0(2),  r11(2)
  [Annotation: Line Number: SETTING::src/core/Str.pm6:2838]
  takedispatcher    r3(2)
  sp_p6oget_s       r5(1),   r0(2), liti16(8)
  chars             r6(1),   r5(1)
  hllboxtype_i      r4(3)
  [Annotation: INS Deopt One (idx 1 -> pc 134; line 2839)]
  box_i             r4(4),   r6(1),   r4(3)
  return_o          r4(4)
````

Notice the four `set` instructions in there. With the new `set` elimination algorithm, we end up with:

```` raku
  sp_getarg_o       r1(3), liti16(0)
  [Annotation: Logged (bytecode offset 24)]
  sp_p6oget_o       r8(3),   r1(3), liti16(16)
  [Annotation: INS Deopt One (idx 0 -> pc 30; line 2838)]
  sp_guardconc      r8(3), sslot(1), litui32(30)
  [Annotation: Line Number: SETTING::src/core/Str.pm6:2838]
  takedispatcher    r3(2)
  sp_p6oget_s       r5(1),   r8(3), liti16(8)
  chars             r6(1),   r5(1)
  hllboxtype_i      r4(3)
  [Annotation: INS Deopt One (idx 1 -> pc 134; line 2839)]
  box_i             r4(4),   r6(1),   r4(3)
  return_o          r4(4)
````

### Elimination of box/unbox pairs

Another interesting use of DU chains is to eliminate boxing of native values into objects only to unbox them again a short time later. This can happen due to the compiler not being smart enough, but if it happens across two subs or methods, and especially when we have multiple dispatch and polymorphic method dispatch happening, there’s not so much we could do better at that phase.

However, MoarVM does inlining, including speculative inlining. We can therefore see between boundaries that we cannot at compile time. Recall how `chars` produced this boxing code, as it is declared to return an `Int`:

```` raku
  chars             r6(1),   r5(1)
  hllboxtype_i      r4(3)
  box_i             r4(4),   r6(1),   r4(3)
````

What if we were to write:

```` raku
my int $chars = $str.chars;
````

Then the boxing happens just over the boundary. It turns out that there’s quite a lot to do in order to get rid of the boxing instruction, but with use chains we can already make a start. When we encounter a `box`, we look if any of its users are an `unbox`. After inlining, we’d see that there are such cases. Therefore, that `unbox` instruction can be rewritten to use `r6(1)` – the unboxed value.

That much works now. For reasons I’ll dig into in my next post, that’s not yet quite enough to eliminate the `box_i` instruction. So in this case, the saving is minor. Once we can get rid of the boxing operation, however, it will be a notable saving in such cases.

### Coming in the future: native ref/deref pairs

One current performance challenge we have is that if we call a method and pass it a variable declared with a native type:

```` raku
my int $foo = $a + $b;
$obj.meth($foo);
````

Then we don’t know if that method is declared as taking an `rw` parameter or not. Therefore, we must not pass a native integer value, but instead form a reference that points to where `$foo` lives, so we can update it. Of course, in most cases `is rw` is not used.

After inlining, we’ll be able to see this, and so will be able to use the use chain to discover when a formed reference is used for nothing more than to do a dereference. Then we can eliminate that reference taking process entirely.

### In summary

Adding use chains has allowed us to detect and fix a small number of usage handling bugs, given us a way to prevent such bugs happening in the future, allowed us to improve an existing optimization, provided for efficiently implementing a new one, and will be an important part of improving the performance of code using native types in the future. Furthermore, it means those of us working on MoarVM have more detailed information about why an operation has to take place in the optimized code, so we can better understand if we have missed opportunities.

However, that’s not the end of the usage story. It turned out that a single flag for deopt usage would not suffice. Next time, I’ll look at why, and what I’ve done to address that.
