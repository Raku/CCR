# Complex cocktail causes cunning crash
    
*Originally published on [2016-12-09](https://6guts.wordpress.com/2016/12/09/complex-cocktail-causes-cunning-crash/) by Jonathan Worthington.*

I did a number of things for Raku yesterday. It was not, however, hard to decide which of them to write up for the blog. So, let’s dig in.

### Horrible hiding heisenbugs

It all started when I was looking into [this RT](https://rt.perl.org/Ticket/Display.html?id=128985), reporting a segfault. It was filed a while ago, and I could not reproduce it. So, add a test and case closed? Well, not so fast. As I discussed [last week](https://6guts.wordpress.com/2016/12/01/taking-a-couple-of-steps-backwards-to-fix-a-gc-bug/), garbage collection happens when a thread fills up its nursery. Plenty of bugs only show up when the timing is just right (or is that just wrong?) What can influence when GC runs? How many allocations we’ve done. And what can influence that? Pretty much any change to the program being run, the compiler, or the environment. The two that most often have people tearing their hair out are:

- How many things the compiler allocates compiling the code. This is why even adding or removing comments can reveal and hide bugs. And, of course, changes to the compiler over time will make all kinds of differences, so the bug can appear or disappear from Rakudo commit to commit. Argh!
- How many things are in the environment, because each one of them results in an allocation of a string at startup. So, yes, adding an environment variable to turn on a debugging feature can hide or show a problem. Running under a test harness that sticks something into the environment can do the very same. Eek!

While GC-related issues are not the only cause of SEGVs, in such a simple piece of code using common features it’s far and away the most likely cause. So, to give myself more confidence that the bug truly was gone, I [adjusted the nursery size](https://github.com/MoarVM/MoarVM/blob/8e24145dafe3551563bb5ef1997c437dd08afd6e/src/gc/collect.h#L4) to be just 32KB instead of 4MB, which causes GC to run much more often. This, of course, is a huge slowdown, but it’s good for squeezing out bugs.

And…no bug! So, in goes the test. Simples!

In even better news, it was lunch time. Well, actually, that was only sort of good news. A few days ago I cooked a rather nice chicken and berry pulao. It came out pretty good, but cooking 6 portions worth of it when I’m home alone for the week wasn’t so smart. I don’t want to see chicken pulao for a couple of months now. Anyway, while I was devouring some of my pulao mountain, I set off a spectest run on the 32KB nursery stress build of MoarVM, just to see if it showed up anything.

### Putrid pointers

A couple of failures did, in fact, show up, one of them in `constant.t`. This rang a bell. I was sure somebody had a in the last couple of weeks reported a crash in that test file, which had then vanished. I checked in with the person who I vaguely recalled mentioning it and…sure enough, it was that very test file. In their normal test runs, the bug had long since vanished. I figured, having now got a reproduction of it, I should probably hunt it down right away. Otherwise, we’d probably end up playing “where’s Wally” with it for another month or ten.

So, how did the failure look?

````
$ ./raku -Ilib t/spec/S04-declarations/constant.rakudo.moar 
Segmentation fault (core dumped)
````

It actually segfaulted while *compiling* the test file. Sad! So, where?

````
$ ./rakudb-m -Ilib t/spec/S04-declarations/constant.rakudo.moar 
[boring output omitted]
Program received signal SIGSEGV, Segmentation fault.
0x0000000000000000 in ?? ()
````

That looks…ungood. That final line is meant to be a code location, which means something decided to tell the CPU to go execute code living at the NULL address. At this point, things could go two ways: the JIT spat out something terrible, or a function pointer somewhere was NULL. But which?

````
(gdb) where
#0  0x0000000000000000 in ?? ()
#1  0x00007ffff78cacbc in MVM_coerce_smart_stringify (tc=0x6037c0, obj=0x605c10, res_reg=0x56624d8)
    at src/core/coerce.c:214
#2  0x00007ffff789dff4 in MVM_interp_run (tc=tc@entry=0x6037c0, initial_invoke=0x60ea80, 
    invoke_data=0x56624d8) at src/core/interp.c:827
#3  0x00007ffff7978b21 in MVM_vm_run_file (instance=0x603010, 
    filename=0x7fffffffe09f "/home/jnthn/dev/rakudo/raku.moarvm") at src/moar.c:309
#4  0x000000000040108b in main (argc=9, argv=0x7fffffffdbc8) at src/main.c:192
````

Phew, it looks like the second case, given there’s no JIT entry stub on the stack. So, we followed a `NULL` function pointer. Really?

````
(gdb) frame 1
#1  0x00007ffff78cacbc in MVM_coerce_smart_stringify (tc=0x6037c0, obj=0x605c10, res_reg=0x56624d8)
at src/core/coerce.c:214
214     ss = REPR(obj)->get_storage_spec(tc, STABLE(obj));
````

Yes, really. Presumably, that `get_storage_spec` is bogus. (I did a `p` to confirm it.) So, how is `obj` looking?

````
(gdb) p *obj
$1 = {header = {sc_forward_u = {forwarder = 0x48000000000001, sc = {sc_idx = 1, idx = 4718592}, 
  st = 0x48000000000001}, owner = 6349760, flags = 0, size = 0}, st = 0x6d06c0}
````

Criminally corrupt; let me count the ways. For one, `6349760` looks like a very high thread ID for a program that’s only running a single thread (they are handed out sequentially). For two, `0` is not a valid object size. And for three, `idx` is just a nuts value too (even Rakudo’s CORE.setting isn’t made up of 4 million objects). So, where does this object live? Well, let’s try out last week’s handy object locator to figure out:

````
(gdb) p MVM_gc_debug_find_region(tc, obj)
In tospace of thread 1
````

Well. Hmpfh. That’s actually an OK place for an object to be. Of course, the GC spaces swap often enough at this nursery size that a pointer could fail to be updated, point into `fromspace` after one GC run, not be used until a later GC run, and then come to point into some random bit of `tospace` again. How to test this hypothesis? Well, instead of 32768 bytes of nursery, what if I make it…well, 40000 maybe?

Here we go again:

````
$ ./rakudb-m -Ilib t/spec/S04-declarations/constant.rakudo.moar 
[trust me, this omitted stuff is boring]
Program received signal SIGSEGV, Segmentation fault.
0x00007ffff78b00db in MVM_interp_run (tc=tc@entry=0x6037c0, initial_invoke=0x0, invoke_data=0x563a450)
    at src/core/interp.c:2855
2855                    if (obj && IS_CONCRETE(obj) && STABLE(obj)->container_spec)
````

Aha! A crash…somewhere else. But where is `obj` this time?

````
(gdb) p MVM_gc_debug_find_region(tc, obj)
In fromspace of thread 1
````

Hypothesis confirmed.

### Dump diving

So…what now? Well, just turn on that wonder `MVM_GC_DEBUG` flag and the bug will make itself clear, of course. Alas, no. It didn’t trip a single one of the sanity checks added by enabling thee flag. So, what next?

The `where` in gdb tells us where in the C code we are. But what high level language code was MoarVM actually running at the time? Let’s dump the VM frame stack and find out:

````
(gdb) p MVM_dump_backtrace(tc)
   at <unknown>:1  (./blib/Perl6/Grammar.moarvm:initializer:sym<=>)
 from gen/moar/stage2/QRegex.nqp:1378  (/home/jnthn/dev/MoarVM/install/share/nqp/lib/QRegex.moarvm:!protoregex)
 from <unknown>:1  (./blib/Perl6/Grammar.moarvm:initializer)
 from src/Perl6/Grammar.nqp:3140  (./blib/Perl6/Grammar.moarvm:type_declarator:sym<constant>)
 from gen/moar/stage2/QRegex.nqp:1378  (/home/jnthn/dev/MoarVM/install/share/nqp/lib/QRegex.moarvm:!protoregex)
 from <unknown>:1  (./blib/Perl6/Grammar.moarvm:type_declarator)
 from <unknown>:1  (./blib/Perl6/Grammar.moarvm:term:sym<type_declarator>)
 from gen/moar/stage2/QRegex.nqp:1378  (/home/jnthn/dev/MoarVM/install/share/nqp/lib/QRegex.moarvm:!protoregex)
 from src/Perl6/Grammar.nqp:3825  (./blib/Perl6/Grammar.moarvm:termish)
 from gen/moar/stage2/NQPHLL.nqp:886  (/home/jnthn/dev/MoarVM/install/share/nqp/lib/NQPHLL.moarvm:EXPR)
from src/Perl6/Grammar.nqp:3871  (./blib/Perl6/Grammar.moarvm:EXPR)
...
````

I’ve snipped out a good chunk of a fairly long stack trace. But look! We were parsing and compiling a constant at the time of the crash. That’s somewhat interesting, and explains why `constant.t` was a likely test file to show this bug up. But MoarVM has little idea about parsing or Raku’s idea of constants. Rather, something on that codepath of the compiler must run into a bug of sorts.

Looking at the location in `interp.c` the op being interpreted at the time was `decont`, which takes a value out of a `Scalar `container, if it happens to be in one. Combined with knowing what code we were in, I can invoke `moar --dump blib/Perl6/Grammar.moarvm`, and then locate the disassembly of `initializer:sym<=>`.

There were a few uses of the `decont` op in that function. All of them seemed to be on things looked up lexically or dynamically. So, I instrumented those ops with a [fromspace check](https://github.com/MoarVM/MoarVM/commit/4d939e89808b61c817badb757504f1281efec322). Re-compiled, and…

````
(gdb) break MVM_panic
Breakpoint 1 at 0x7ffff78a19a0: file src/core/exceptions.c, line 779.
(gdb) r
Starting program: /home/jnthn/dev/MoarVM/install/bin/moar --execname=./rakudb-m --libpath=/home/jnthn/dev/MoarVM/install/share/nqp/lib --libpath=/home/jnthn/dev/MoarVM/install/share/nqp/lib --libpath=. /home/jnthn/dev/rakudo/raku.moarvm --nqp-lib=blib -Ilib t/spec/S04-declarations/constant.rakudo.moar
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib/x86_64-linux-gnu/libthread_db.so.1".

Breakpoint 1, MVM_panic (exitCode=1, 
    messageFormat=0x7ffff799bc58 "Collectable %p in fromspace accessed") at src/core/exceptions.c:779
779 void MVM_panic(MVMint32 exitCode, const char *messageFormat, ...) {
(gdb) where
#0  MVM_panic (exitCode=1, messageFormat=0x7ffff799bc58 "Collectable %p in fromspace accessed")
    at src/core/exceptions.c:779
#1  0x00007ffff78ba657 in MVM_interp_run (tc=0x1, tc@entry=0x6037c0, initial_invoke=0x0, 
    invoke_data=0x604b80) at src/core/interp.c:374
#2  0x00007ffff7979071 in MVM_vm_run_file (instance=0x603010, 
    filename=0x7fffffffe09f "/home/jnthn/dev/rakudo/raku.moarvm") at src/moar.c:309
#3  0x000000000040108b in main (argc=9, argv=0x7fffffffdbc8) at src/main.c:192
````

And what’s in `interp.c` around that line? The `getdynlex` op. That’s the one that is used to lookup things like `$*FOO` in Raku. So, a dynamic lexical lookup seemed to be handing back an outdated object. How could that happen?

### Interesting idea is insufficient

My next idea was to see if I could catch the moment that something bad was put into the lexical. I’d already instrumented the obvious places with no luck. But…what if I could intercept every single VM register access and see if an object from `fromspace `was read? Hmmm… It turned out that [I could make that happen](https://github.com/MoarVM/MoarVM/commit/8dd2f63e1921134d8d7a2174cc910d6e2e62f411) with a sufficiently cunning patch. I made it opt-in rather than the default for `MVM_GC_DEBUG` because it’s quite a slow-down. I’m sure that this will come in really useful for finding some GC bug some day. But for this bug? It was no direct help.

It was of some indirect help, however. It suggested strongly that at the time the lexical was set (actually, it turned out to be `$*LEFTSIGIL`), everything was valid. Somewhere between then and the lookup of it using the `getdynlex` op, things went bad.

### Cache corruption

So what does `getdynlex` actually do? It checks if the current frame declares a lexical of the specified name. If so, it returns the value. If not, it looks in the caller for the value. If that fails, it goes on to the caller’s caller, until it runs out of stack to search and then gives up.

If that’s what it really did, then this bug would never have happened. But no, people actually want Raku to run fast and stuff, so we can’t just implement the simplest possible thing and go chill. Instead, there’s a caching mechanism. And, as well all know, the two hardest problems in computer science are cache invalidation and cache invalidation.

The caching is relatively simple: each frame has slots for sticking a name, register pointer, and type in it.

````
MVMString   *dynlex_cache_name;
MVMRegister *dynlex_cache_reg;
MVMuint16    dynlex_cache_type;
````

When `getdynlex` finds something the slow way, it then looks down the stack again and finds a frame with an empty `dynlex_cache_name`. It then sticks the name of dynamic lexical into the `name` slot, a pointer to the MoarVM lexical into the `reg` slot, and what type of lexical it was (native int, native num, object, etc.) into the `type` slot. The most interesting of these is the `reg` slot. The `MVMRegister` type is actually a union of different types that we may store in a register or lexical. We re-use the union for registers that live while the frame is on the callstack and lexicals that may need to live longer thanks to closures. So, each frame as two arrays of these:

````
MVMRegister *env;   /* The lexical environment */
MVMRegister *work;  /* Working space that dies with the frame */
````

And so the `dynlex_cache_reg` ends up pointing to `env` somewhere in the frame that we found the lexical in.

So, the big question: was the caching to blame? I [shoved in a way to disable it](https://github.com/MoarVM/MoarVM/commit/22281b63f9ca915911a2bde09b0c298f04be0cc3) and…the bug vanished.

Note by this point we’re up to two pieces that contribute to the bug: the GC and the dynamic lexical cache. The thing is, the dynamic lexical cache is used very heavily. My gut feeling told me there must be at least one more factor at play here.

### Suspicious specialization

So, what could the other factor be? I re-enabled the cache, verified the crash came back, and then stuck `MVM_SPESH_DISABLE=1 `into the environment. And…no bug. So, it appeared that dynamic optimization was somehow involved too. That’s the magic that looks at what types actually show up at runtime, and compiles specialized versions of the code that fast-paths a bunch of operations based on that (this *specialization* being where the name “spesh” comes from). Unfortunately, `MVM_SPESH_DISABLE` is a rather blunt instrument. It disables a huge range of things, leaving a massive surface area to consider for the bug. Thankfully, there are some alternative environment variables that just turn off parts of spesh.

First, I tried `MVM_JIT_DISABLE=1`, which results in spesh interpreting the specialized version of the code rather than turning it into machine code to remove the interpreter overhead. The bug remained.

Next, I tried `MVM_SPESH_OSR_DISABLE`, which disables On Stack Replacement. This is a somewhat fiddly optimization that detects hot loops as they are being interpreted, pauses execution, produces an optimized version of the code, and then recalculates the program counter so it points to the appropriate point in the optimize code and continues execution. Basically, the interpreter gets the code it’s executing replaced under it – perhaps with machine code, which the interpreter is instructed to jump into immediately. Since this also fiddles with frames “in flight”, it seemed like a good candidate. But…nope. Bug remained.

Finally, I tried `MVM_SPESH_INLINE_DISABLE`, which disables inlining. That’s where we spot a call to a relatively small subroutine or method, and just replace the call with the code of the sub or method itself, saving the cost of setting up callframes. And…bug vanished!

So, inlining was apparently a factor too. The trouble is, that also didn’t seem to add up to an obvious bug. Consider:

```` raku
sub foo($a) {
    bar($a);
}
sub bar($b) {
    my $c = $b + 6;
    $c * 6
}
````

Imagine that `bar` was to be inlined into `foo`. Normally they’d have lexical slots in `->env` as follows:

````
A:  | $_ | $! | $/ | $a |
B:  | $_ | $! | $/ | $b | $c |
````

The environment for the frame `inline(A, B)` would look like:

````
inline(A, B):  | $_ | $! | $/ | $a | $_ | $! | $/ | $b | $c |
                \---- from A ----/  \------- from B -------/
````

Now, it’s easy to imagine various bugs that could arise in the *initial* lookup of a dynamic lexical in such a frame. Indeed, the dynamic lexical lookup code actually has two bunches of code that deal with such frames, one in the case the specialized code is being interpreted and one in the case where it has been JIT compiled. But by the time we are hitting the cache, there’s nothing smart going on at all: it’s just a cheap pointer deference.

### Dastardly deoptimization

So, it seems we need a *fourth* ingredient to explain the bug. By now, I had a pretty good idea what it was. MoarVM doesn’t just to optimizations based on properties it can prove will always hold. It can also do speculative optimization based on properties that it expects will probably hold up. For example, suppose we have:

```` raku
sub foo($a, $b) {
    $b.some-huge-complex-call($a);
    return $a.Str;
}
````

Imagine we’re generating a specialization of this routine for the case `$a` is an object of type `Product`. The `Str` method is tiny, so we go ahead and inline it. However, `some-huge-complex-call` takes all kinds of code paths. We can’t be sure, from our analysis, that at some point it won’t mix in to the object in `$a`. What if it mixes in a role that has an alternate `Str` method? Our inlining would break stuff! We’d end up calling the `Product.Str` method, not the one from the mixin.

One reaction is to say “well, we’ll just not ever optimize stuff unless we can be REALLY sure”, which is either hugely limiting or relies on much more costly analyses. The other path, which MoarVM does, is to say “eh, let’s just assume mixins won’t happen, and if they do, we’ll fix things *then*!” The process of fixing things up is called deoptimization. We walk the call stack, rewriting return addresses to point to the original interpreted code instead of the optimized version of the code.

But what, you might wonder, do we do if there’s a frame on the stack that is actually the result of an inlining operation? What if we’re in the code that resulted from `inline(A,B)`, in the bit that corresponds to the code of `B`? Well, we have to perform – you guessed it – uninlining! The composite call frame has to be dissected, and the call stack rewritten to look like it would have if we’d been running the original interpreted code. To do this, we’d create a call frame for `B`, complete with space for its lexicals, and copy the lexicals from `inline(A,B)` that belong to `B` into that new buffer.

The code that does this is one of the very few parts of MoarVM that frightens me.

For good reason, it turns out. This deoptimization, together with uninlining, was the final ingredient needed for the bug. Here’s what happened:
<ol>
- The method `EXPR` in `Perl6::Grammar` was inlined into one of its callers. This `EXPR` method declares a `$*LEFTSIGIL `variable.
- While parsing the constant, the `$*LEFTSIGIL` is assigned to the sigil of the constant being declared, if it has one (so, in `constant $a = 42` it would be set to `$`).
- Something does a lookup of `$*LEFTSIGIL`. It is located and cached. The cache entry points into a region of the `->env` of the frame that inlined, and thus incorporated, the lexical environment of `EXPR`.
- At some point, a mixin happens, causing a deoptimization of the call stack. The frame that inlined `EXPR` gets pulled apart. A new `EXPR` frame comes to exist, with the lexicals that used to live in the composite frame copied into them. Execution continues.
- A GC happens. The object containing the `$` substring moves. The new `EXPR` frame’s lexical environment is updated.
- Another lookup of `$*LEFTSIGIL` happens. It hits the cache. The cache, however, still points to the place the lexical used to live in the composite frame. This memory has not been freed, because the first part of it is still being used. However, the GC no longer cares about its contents because that content is unreachable. Therefore, it contains an outdated pointer, thus leading to accessing memory that’s being used for something else entirely by that point, leading to the eventual segmentation fault.
</ol>

The most natural fix was to [invalidate the cache](https://github.com/MoarVM/MoarVM/commit/e674686fe9c21b907e68abdd8d78c6308726e0f3) during deoptimization.

### <a id="user-content-lessons-learned" class="anchor" href="https://gist.github.com/jnthn/c10d8f30b23a8bc74418d10388cc22e0#lessons-learned"></a>Lessons learned

The bug I wrote up last week was thanks to a comparatively simple oversight made within the scope of a few lines of a single C function. While this one could be fixed with a small amount of code added in a single file, the segfault arose from the interaction of four distinct features existing in MoarVM:

- Garbage collection
- Dynamic lexical lookup caching
- Inlining
- Deoptimization

Even when a segfault was not produced, thanks to “lucky” GC timing, the bug would lead to reading of stale data. It just so turned out that the data wasn’t ever stale enough in reality to break things on this particular code path.

All of garbage collection, inlining, and deoptimization are fairly complicated. By contrast, the dynamic lexical lookup cache is fairly easy. Interestingly, it was the addition of this easy feature that introduced the bug – not because the code that was added was wrong, but rather because it did something that some other far flung piece of code – the deoptimizer – had quietly relied on not happening.

So, what might be learned for the future?

The most immediate practical learning is that taking interior pointers into mutable data structures is risky. In this case, that data structure was a composite lexical environment, that later got taken apart. Conceptually, the environment was resized and the interior pointer was off the end of the new size. This suggests either providing a safe way to acquire such a reference, or an alternative design for the dynamic lexical cache to avoid needing to do so.

Looking at the bigger picture, this is all about managing complexity. Folks who work with me tend to observe I worry a good bit about loose coupling, to the degree that I’m much more hesitant than the typical developer when it comes to code re-use. Acutely aware that re-use means use, and use means dependency, and dependency means coupling, I tend to want things to prove they really are the same thing rather than just looking like they might be the same thing. MoarVM reflects this in various ways: to the degree I can, I try to organize it as a collection of parts that either keep themselves very much to themselves, or that collaborate over a small number of very stable data structures. One of the reasons Git works architecturally is because while all the components of it are messing with the same data structure, it’s a very stable and well-understood data structure.

In this bug, `MVMFrame` is the data structure in question. A whole load of components know about it and work with it because – so the theory went – it’s one of the key stable data structures of the VM. Contrast it with the design of things like the Unicode normalizer or the fixed size allocator, which nothing ever pokes into directly. These are likely to want to evolve over time to choose smarter data structures, or to get extra bits of state to cope with Unicode’s latest and greatest emoji boundary specification. Therefore, all work with them is hidden nicely behind an API.

In reality, `MVMFrame` has grown to contain quite a fair few things as MoarVM has evolved. At the same time, its treated as a known quantity by lots of parts of the codebase. This is only sustainable if every addition to `MVMFrame` is followed by considering how every other part of the VM that interacts with it will be affected by the change, and making compensating changes to those components. In this case, the addition of the dynamic lexical cache into the frame data structure was not accompanied by sufficient analysis of which other parts of the VM may need compensating changes.

The bug I wrote up last week isn’t really the kind that causes an architect a headache. It was a localized coding slip-up that could happen to anyone on a bad day. It’s a pity we didn’t catch it in code review, but code reviewers are also human. This bug, by contrast, arose as a result of the complexity of the VM – or, more to the point, insufficient management of that complexity. And no, I’m not beating myself up over this. But, as MoarVM architect, this is exactly the type of bug that catches my eye, and causes me to question assumptions. In the immediate, it tells me what kinds of patches I should be reviewing really carefully. In the longer run, the nature of the `MVMFrame` data structure and its level of isolation from the rest of the codebase deserves some questioning.
