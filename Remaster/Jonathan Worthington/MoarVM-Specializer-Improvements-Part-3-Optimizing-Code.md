# MoarVM Specializer Improvements Part 3: Optimizing Code
    
*Originally published on [2017-11-05](https://6guts.wordpress.com/2017/11/05/moarvm-specializer-improvements-part-3-optimizing-code/) by Jonathan Worthington.*

Finally, after considering [gathering data](https://6guts.wordpress.com/2017/08/06/moarvm-specializer-improvements-part-1-gathering-data/) and [planning what to optimize](https://6guts.wordpress.com/2017/09/17/moarvm-specializer-improvements-part-2-planning/), it’s time to look at how MoarVM’s dynamic optimizer, “spesh”, transforms code into something that should run faster.

### Specialization

The name “spesh” is short for “specializer”, and this nicely captures the overall approach taken. The input bytecode the optimizer considers is full of genericity, and an interpreter of that bytecode needs to handle all of the cases. For example, a method call depends on the type of the invocant, and in the general case that may vary from call to call. Worse, while most of the time the method resolution might just involve looking in a cache, in other cases we might have to call into `find_method` to do a more dynamic dispatch. That in turn means method lookup is potentially an invocation point, which makes it harder to reason about the state of things after the method lookup.

Of course, in the common case, it’s a boring method lookup that will be found in the cache, and in many cases there’s only one invocant type that shows up at a given callsite at runtime. Therefore, we can *specialize* the code for this case. This means we can cache the result of the method lookup, and since that is now a constant, we may be able to optimize the call itself using that knowledge.

This specialization of method resolution is just one of many kinds of specialization that we can perform. I’ll go through a bunch more of them in this post – but before that, let’s take a look at how the code to optimize is represented, so that these optimizations can be performed conveniently.

### Instruction Nodes, Basic Blocks, and CFGs

The input to the optimization process is bytecode, which is just a bunch of bytes with instruction codes, register indexes, and so forth. It goes without saying that doing optimizations by manipulating that directly would be pretty horrible. So, the first thing we do is make a pass through the bytecode and turn every instruction in the bytecode into an instruction node: a C structure that points to information about the instruction, to the previous and next instructions, and contains information about the operands.

This is an improvement from the point of view of being able to transform the code, but it doesn’t help the optimizer to “understand” the code. The step that transforms the bytecode instructions into instruction nodes also performs a second task: it marks the start and end of each basic block. A basic block is a sequence of instructions that will run one after the other, without any flow control. Actually, this definition is something we’ve gradually tightened up over time, and was particularly refined during my work on spesh over the summer. By now, anything that *might* invoke terminates a basic block. This means that things like `findmethod` (which may sometimes invoke `find_method` on the meta-object) and `decont` (which normally takes a value out of a `Scalar` container, but may have to invoke a `FETCH` routine on a `Proxy`) terminate basic blocks too. In short, we end up with a *lot* of basic blocks, which makes life a bit harder for those of us who need to read the spesh debug output, but experience tells that the more honest we are about just how many things might cause an invocation, the more useful it is in terms of reasoning about the program and optimizing it.

The basic blocks themselves are only so useful. The next step is to arrange them into a Control Flow Graph (CFG). Each basic block is represented by a C structure, and has a list of its successors and predecessors. The successors of a basic block are those basic blocks that we might end up in after this one. So, if it’s a condition that may be taken or not, then there will be two successors. If it’s a jump table, there may be a lot more than two.

Once we have a control flow graph, it’s easy to pick out basic blocks that are not reachable from the root of the graph. These could never be reached in any way, and are therefore dead code.

One thing that we need to take special care of is exception handlers. Since they work using dynamic scope, then they may be reached only through a callee, but we are only assembling the CFG for a single routine or block. We need to make sure they are considered reachable, so they aren’t deleted as dead code. One safe and conservative way to do this is to add a dummy entry node and link them all from it. This is what spesh did for all exception handlers, until this summer. Now, it only does this for catch handlers. Control exception handlers are instead made reachable by linking them into the graph as a successor to all of the basic blocks that are in the region covered by the handler. Since these are used for `redo`, `next`, and `last` handling in loops, it means we get much more precise flow control information for code with loops in. It also means that control exception handlers can now be eliminated as dead code too, if all the code they cover goes away. Making this work out meant doing some work to remove assumptions in various areas of spesh that exception handlers were never eliminated as dead code.

### Dominance and SSA form

The control flow graph is a step forward, but it still falls short of letting us do the kind of analysis we’d really like. We’d also like to be able to propagate type information through the graph. So, if we know a register holds an `Int`, and then it is assigned into a second register, we’d like to mark that register as also containing an `Int`. The challenge here is that register allocation during code generation wants to minimize the number of registers that are needed – a good thing for memory use – and so a given register will have many different – and unrelated – usages over time.

To resolve this, the instructions are transformed into Static Single Assignment form. Each time a register is assigned to in the bytecode (this is where the “static” comes from), it is given a new version number. Thus, the first assignment to `r2` would be named `r2(1)`, the second `r2(2)`, and so forth. This helps enormously, because now information can be stored about these renamed variables, and it’s easy to access the correct information upon each usage. Register re-use is something we no longer have to worry about in this model.

So far so straightforward, but of course there’s a catch: what happens when we have conditionals and loops?

````
  if_i r1(1) goto LABEL1
  set r2(1), r3(1)
  goto LABEL2
LABEL1:
  set r2(2), r4(1)
LABEL2:      
  # Which version of r2 reaches here???
````

This problem is resolved by the use of phi nodes, which “merge” the various versions at “join points”:

````
  if_i r1(1) goto LABEL1
  set r2(1), r3(1)
  goto LABEL2
LABEL1:
  set r2(2), r4(1)
LABEL2:      
  PHI r2(3), r2(1), r2(2)
````

The placement of these phi nodes is an interesting problem, and that’s where dominance comes in. Basic block B1 dominates basic block B2 if every possible path to B2 in the flow control graph must pass through B1. There’s also a notion of immediate dominance, which you can think of as the “closest” dominator of a node. The immediate dominators form a tree, not a graph, and this tree turns out to be a pretty good order to explore the basic blocks in during analysis and optimization. Last but not least, there’s also the concept of dominance frontiers – that is, where a node’s dominance ends – and this in turn tells us where the phi nodes should be placed.

Thankfully, there’s a good amount of literature on how to implement all of this efficiently and, somewhat interestingly, the dominance algorithm MoarVM picked is a great example of how a cubic algorithm with a really low constant factor can beat a `n*log(n)` algorithm on all relevant problem sizes (20,000 basic blocks or so – which is a lot).

### Facts

Every SSA register has a set of facts associated with it. These include known type, known value, known to be concrete, known to be a type object, and so forth. These provide information that is used to know what optimizations we can do. For example, knowing the type of something can allow an `istype` operation to be turned into a constant. This means that the facts of the result of that `istype` now include a known value, and that might mean a conditional can be eliminated entirely.

Facts are, in fact, something of a relative concept in spesh. In the previous parts of this series, I discussed how statistics about the types that show up in the program are collected and aggregated. Of course, these are just statistics, not proofs. So can these statistics be used to introduce facts? It turns out they can, provided we are willing to add a guard. A guard is an instruction that cheaply checks that reality really does match up with expectations. If it does not, then *deoptimization* is triggered, meaning that we fall back to the slow-path code that can handle all of the cases. Beyond the guard, the facts can be assumed to be true. Guards are another area that I simplified and made more efficient during my work in the summer.

Phi nodes and facts have an interesting relationship. At a phi node, we need to merge the facts from all of the joined values. We can only merge those things that all of the joined values agree on. For example, if we have a phi with two inputs, and they both have a fact indicating a known type `Int`, then the result of the phi can have that fact set on it. By contrast, if one input thinks it’s an `Int` and the other a `Rat`, then we don’t know what it is.

During my work over the summer, I also introduced the notion of a “dead writer”. This is a fact that is set when the writer of a SSA register is eliminated as dead code. This means that the merge can completely ignore what that input thinks, as it will never be run. A practical example where this shows up is with optional parameters:

```` raku
sub process($data, :$normalize-first) {
    if $normalize-first {
        normalize($data);
    }
    do-stuff-with($data);
}
````

Specializations are produced for a particular callsite, meaning that we know if the `normalize-first` argument is passed or not. Inside of the generated code, there is a branch that sticks an `Any` into `$normalize-first` if no argument is received. Before my change, the phi node would not have any facts set on it, as the two sides disagreed. Now, it can see that one side of the branch is gone, and the merge can keep whichever facts survive. In the case that type named argument was *not* passed, then the `if` can also be eliminated entirely, as a type object is falsey.

### Specialization by arguments

So, time to look at some of the specializations! The first transformations that are applied relate to the instructions that bind the incoming arguments into the parameter variables that are to receive them. Specializations are keyed on callsite, and a callsite object indicates the number of arguments, whether any of them are natively typed, and – for named arguments – what names the arguments have. The argument processing code can be specialized for the callsite, by:

- Throwing out the `checkarity` instruction, if we know that the number of arguments being passed are in range.
- Directly reading arguments from the args buffer when no boxing/unboxing is required, instead of calling an op that checks if a box/unbox is needed. Alternatively, if a box/unbox operation is needed (passing native arg to object parameter and vice versa), then this can be inserted directly, and may be subject to further optimization and/or JIT compilation later.
- Directly reading named arguments by index into the arguments buffer, rather than having to do any kind of hash lookup or string comparisons (this makes named arguments as cheap to receive as positionals).
- Eliminating the “check all named arguments are used” instruction, if present and it can be proven to be unrequired.
- Eliminating branches related to optional arguments.
- Generating code to build a hash directly from the args buffer contents for slurpy named arguments.

### Attribute access specialization

Attribute access instructions pass the name of the attribute together with the type the attribute was declared in. This is used to resolve the location of the attribute in the object. There is a static optimization that adds a hint, which has to be verified to be in range at runtime and that does not apply when multiple inheritance is used.

When the spesh facts contain the type of the object that the attribute is being looked up in, then – after some sanity checks – this can be turned into something much cheaper: a read of the memory location at an offset from the pointer to the object. Both reads and writes of object attributes can receive this treatment.

### Decontainerization specialization

Many values in Raku live inside of a `Scalar` container. The `decont` instruction is used to take a value out of a container (which may be a `Scalar` or a `Proxy`). Often, `decont` is emitted when there actually is no container (because it’s either impossible or too expensive to reason about that at compile time). When we have the facts to show it’s not being used on a container type, the `decont` can be rewritten into a `set` instruction. And when the facts show that it’s a `Scalar`, then it can optimized into a cheap memory offset read.

### Method resolution specialization

When both the name of a method and the type it’s being resolved on are known from the facts, then spesh looks into the method cache, which is a hash. If it finds the method, it turns the method lookup into a constant, setting the known value fact along the way. This, in the common case, saves a hash lookup per method call, which is already something, but knowing the exact method that will be run opens the door to some very powerful optimizations on the invocation of the resolved method.

### Invocation specialization

Specialization of invocations – that is, calling of subs, methods, blocks, and so forth – is one of the most valuable things spesh does. There are quite a few combinations of things that can happen here, and my work over the summer made this area of spesh a good deal more powerful (and, as a result, took some time off various benchmarks).

The most important thing for spesh to know is what, exactly, is the target of the invocation. In the best case, it will be a known value already. This is the case with subs resolved from the setting or from `UNIT`, as well as in the case that a `findmethod` was optimized into a constant. These used to be the only cases, until I also added recording statistics on the static frame that was the target of an invocation. These are analyzed and, if pretty stable, then a guard can be inserted. This greatly increases the range of invocations that can be optimized. For example, a library that can be configured with a callback may, if the program uses a consistent callback, and the callback is small, have the callback’s code inlined into the place that calls it in the library code.

The next step involves seeing if the target of the invocation is a `multi` sub or method. If so, then the argument types are used to do a lookup into the multi dispatch cache. This means that spesh can potentially resolve a multi-dispatch once at optimization time, and just save the result.

Argument types are worth dwelling on a little longer. Up until the summer, the facts were consulted to see if the types were known. In the case there was no known type from the facts, then the invocation would not be optimized. Now, using the far richer set of statistics, when a fact is missing but the statistics suggest there is a very consistent argument type, then a guard can be inserted. This again increases the range of invocations that can be optimized.

So, by this point a multi dispatch may have been resolved, and we have something to invoke. The argument types are now used to see if there is a specialization of the target of the invocation for those arguments. Typically, if it’s on a hot path, there will be. In that case, then the invocation can be rewritten to use an instruction that pre-selects the specialization. This saves a lot of time re-checking argument types, and is a powerful optimization that can reduce the cost of parameter type checks to zero.

Last, but very much not least, it may turn out that the target specialization being invoked is very small. In this case, a few more checks are performed to see if the call really does need its own invocation record (for example, it may do so if it has lexicals that will be closed over, or if it might be the root of a continuation, or it has an exit handler). Provided the conditions are met, the target may be inlined – that is, have its code copied – into the caller. This saves the cost of creating and tearing down an invocation record (also known as call frame), and also allows some further optimizations that consider the caller and callee together.

Prior to my work in the summer, it wasn’t possible to inline anything that looked up lexical variables in an outer scope (that is to say, anything that was a closure). Now that restriction has been lifted, and closures can be inlined too.

Finally, it’s worth noting that MoarVM also supports inlining specializations that *themselves* contain code that was inlined. This isn’t too bad, except that in order to support deoptimization it has to also be able to do multiple levels of uninlining too. That was a slight headache to implement.

### Conditional specialization

This was mentioned in passing earlier, but worth calling out again: when the value that is being evaluated in a conditional jump is known, then the branch can be eliminated. This in turn makes dead code of one side of the branch or the other. This had been in place for a while, but in my work during the summer I made it handle some further cases, and also made it more immediately remove the dead code path. That led to many SSA registers being marked with the dead writer fact, and thus led to more optimization possibilities in code that followed the branch.

### Control exception specialization

Control exceptions are used for things like `next` and `last`. In the general case, their target may be some stack frames away, and so they are handled by the exception system. This walks down the stack frames to find a handler. In some cases, however – and perhaps thanks to an inlining – the handler and the throw may be in the same frame. In this case, the throw can be replaced with a simple – and far cheaper – `goto` instruction. We had this optimization for a while, but it was only during the summer that I made it work when the throwing part was in code that had been inlined, making it far more useful for Raku code.

### In summary

Here we’ve seen how spesh takes pieces of a program, which may be full of generalities, and specializes them for the actual situations that are encountered when the program is run. Since it operates at runtime, it is able to do this across compilation units, meaning that a module’s code may be optimized in quite different ways according to the way a particular consumer uses it. We’ve also discussed the importance of guards and deoptimization in making good use of the gathered statistics.

You’ll have noticed I mentioned many changes that took place “in the summer”, and this work was done under a grant from The Perl Foundation. So, thanks go to them for that! Also, I’m still [looking for sponsors](https://6guts.wordpress.com/2017/05/12/looking-for-perl-6-rakudo-and-moarvm-development-funding/).

In the next, and final, part of this series, we’ll take a look at argument guards, which are used to efficiently pick which specialization to use when crossing from unspecialized to specialized code.
