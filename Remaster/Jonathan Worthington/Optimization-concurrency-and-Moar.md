# Optimization, concurrency, and Moar
    
*Originally published on [2014-04-12](https://6guts.wordpress.com/2014/04/12/optimization-concurrency-and-moar/) by Jonathan Worthington.*

It’s been a while since I wrote an update here. Happily, *timotimo* has taken up the role of being our [weekly Raku reporter](http://p6weekly.wordpress.com/), so there’s a good place to follow for regular updates. However, I wanted to take a moment to provide the bigger picture of what’s been happening in the last couple of months, share my perspectives on it, and talk a bit about where things are headed from here.

### Optimization, optimization, optimization!

A lot of recent effort has gone on optimization. NQP, the subset of Raku that we use to implement much of the Rakudo Raku compiler, has performance on MoarVM that starts to approach that of Perl, and on JVM sometimes exceeds that of Perl for longer running things (it typically runs the forest fire benchmark from our benchmark suite faster once the JIT has had time to get going, for example). By contrast, Rakudo’s performance itself has been comparatively awful. Thankfully, things have been getting better, as we’ve worked to improve optimization, reduce costs of common things, and gradually begun to close the gap. This has involved work on both Rakudo and NQP’s optimization phases, along with work on improving the built-ins and some performance-oriented factoring changes. There’s still plenty of work to go, but anybody using Rakudo on MoarVM will likely feel the results in the next release. To give an idea of the improvement in HEAD Rakudo on MoarVM, which will appear in the April monthly:

- Array and hash access is more than 3 times faster
- Most multi-dispatches are now enormously cheaper
- Many, many unrequired scalar allocations are optimized away
- The forest fire benchmark on Rakudo can render twice as many frames per second
- Compiler performance is around 15% better (estimate going on CORE.setting compile time)

Compared to Rakudo on Parrot the difference is more marked. On compiler performance alone, the difference is enormous: you can build the entire of Rakudo on MoarVM on my box in around 80s (which I’m not happy with yet, though you rarely change so much that you have to do the whole thing). That is less time than it takes for Rakudo on Parrot to complete the parse/AST phases of compiling CORE.setting (the built-ins). Running the spectest suite happens in half the time. Both of these times are important because they influence how quickly those of us working on Raku implementation can try out our changes. Unsurprisingly, most of us do the majority of our development on MoarVM first these days.

One consequence of this work is that Rakudo on MoarVM is often sneaking ahead of Rakudo on JVM on some benchmarks now, even once the mighty JVM JIT kicks in. This won’t last long, though; a couple of the optimizations done will not be a great deal of work to port to the JVM, and then it can re-claim its crown. For now! :-)

### Introducing “spesh”

A whole other level of performance related work has been taking place in MoarVM itself. The first goal for the project was “just run NQP and Raku”, and the VM simply got on with interpreting the bytecode we threw at it. That doesn’t mean it wasn’t carefully designed along the way – just that the focus in terms of execution was to be simple, correct and sufficiently complete to serve as a solid Rakudo backend. With that goal achieved, the next phase of the project is underway: implementing dynamic optimization based on program information available at runtime, speculative optimizations that can be undone if things they rely on are broken, and so forth.

The first steps in that direction will be included in this month’s MoarVM release, and are to thank for much of the improved compiler performance (since the compiler is a program running on the VM too). The easiest way to get an overview is for me to walk you through the pieces in [src/spesh](https://github.com/MoarVM/MoarVM/tree/master/src/spesh) in MoarVM.

- **graph** is about building a representation of the bytecode (at a frame level) suitable for analysis and transformation (the two steps involved in optimization). It starts out by building a Control Flow Graph. It then computes the dominance tree, which it uses to rename variables so as to produce a Static Single Assignment form of the bytecode. This is a form whereby a given name is only written to once, which eases many, many aspects of analysis.
- **args** takes a tuple of incoming arguments, considers their types, arity, and so forth. It produces a set of guard clauses that indicate when a given specialization of the code applies (that is, a version of the code improved by making assumptions about what was passed), and then re-writes various argument access instructions to “unsafe” but fast ones that it can prove will always work out.
- **facts** takes the graph, looks through it for sources of type information (including the incoming arguments) and does an initial propagation of that information through the graph. It creates usage counts to be later used in dead code elimination.
- **optimize** takes this annotated graph, and makes a pass through it, applying a number of optimizations. Granted, there are not so many yet; so far we’ve mostly worked on getting to the point of having a framework to prove safety of transformations, and adding more of them comes next. However, those there so far can do things like:

- Resolve methods to avoid hash lookups
- Install monomorphic method caching if that doesn’t work out
- Resolve type checks, possibly eliminating entire branches of code
- Re-write attribute binds into “unsafe” pointer operations
- Eliminate dead code

- **codegen** takes the optimized graph and produces bytecode from it again. However, in the future (if we’re lucky, then hopefully through a GSoC project), this is where we would produce machine code instead.
- **deopt **deals with the situation where some invariant specialized code may be relying on gets broken, and yet that specialized code is still on the call stack. It walks the call stack, looking for specialized code on it and tweaking return addresses and other data structures so that when we return into the code, we’re back in the safe (though of course slower) unspecialized code that checks things as needed.

By and large, this is essentially giving MoarVM a JIT. Of course, it’s not producing machine code yet, but rather JITing back to improved bytecode. While we tend to think of JITs primarily as “turn the program into machine code”, that’s really just one small part of any modern JIT. Analysis and specialization of the program before the machine code is produced is just as important; with this approach, we get to focus in on that part first and get some of the benefits now.

### Concurrency

Progress on Raku concurrency continues. The JVM implementation of the concurrency features has had various performance improvements since the March release, and MoarVM now has support for most of the Raku concurrency features also. However, the MoarVM support for these features is early and most certainly not yet production ready. We’ll include it in the April release, but stick with Rakudo on the JVM for concurrency things if you’re doing anything that matters. If you just want to play with the basics, either will do.

### Rakudo on MoarVM takes the spectest crown

Rakudo on its various backends hold the top spots on the Raku specification test suite pass rate. However, nowadays Rakudo on MoarVM has worked its way into the lead. How so? Because it has the best Unicode database introspection support, opening up a range of tests that no other backend handles yet. Additionally, because it gets some of the Unicode stuff right that that Parrot does, but JVM doesn’t. And, finally, because on top of that it can now pass a bunch of the concurrency tests.

### A multi-backend Rakudo Star

I’d hoped we would get a Rakudo Star release with support for all three backends out in March. It didn’t happen; the module tests showed up some holes. We’ve by now largely fixed those for Rakudo on MoarVM, and we’re looking quite good for the April Rakudo Star coming with support for both Parrot and MoarVM. With some effort, I’m optimistic we’ll have a JVM Star release in good shape for April too. This will provide users who want the “batteries included” release a choice of backends, and of note give those using Parrot a chance to switch over to using MoarVM, getting some substantial performance improvements on most programs and lower startup time and memory use.

### Where next?

In the coming months, I’m going to be focusing on the following areas:

- More improvements to the Rakudo and NQP optimizers, so we generate better (faster, smaller) code.
- More improvements to the Rakudo built-ins, so they operate more efficiently.
- Making the MoarVM concurrency support more robust, and improving the parallel GC.
- Advancing the state of asynchronous I/O, so we’ll have good support for it on both the JVM and MoarVM.
- Teaching spesh to specialize better. There are a bunch of data access things that can be made cheaper, as well as being able to better optimize multiple dispatch. Beyond that, both inlining and escape analysis are on the menu.
- Improving native type support, including providing native arrays.

I’ve been hidden away coding for much of the year so far, apart from putting in an appearance at FOSDEM. But I’m getting on the road soon! I’ll be at the Dutch, Polish and Czech Perl Workshops, and look forward to seeing folks and sharing what I’ve been working on. Hope to see some of you out there!
