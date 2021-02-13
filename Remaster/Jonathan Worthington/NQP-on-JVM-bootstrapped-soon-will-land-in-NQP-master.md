# NQP on JVM bootstrapped, soon will land in NQP master
    
*Originally published on [2013-04-18](https://6guts.wordpress.com/2013/04/18/nqp-on-jvm-bootstrapped-soon-will-land-in-nqp-master/) by Jonathan Worthington.*

The work to get NQP running and bootstrapped on the JVM has reached an interesting milestone, and I thought I’d take a few moments from working on it to talk about what has taken place since my last post here, as well as taking a look at what will be coming next.

### Getting NQP on JVM Bootstrapped

When I last posted here, I had reached the point of having an NQP cross-compiler to the JVM that covered quite a lot of NQP’s language features. Cross-compilation meant using NQP on Parrot to parse NQP source, build an AST, and then turn the AST into a kind of JVM assembly language. This in turn was then transformed into a JVM bytecode file by a small tool written in Java, which could then be executed on the JVM.

Since the last post, the cross-compiler became capable of cross-compiling NQP itself. This meant taking the NQP source files and using the cross-compiler to produce an NQP that would run on the JVM – without depending on Parrot. This also enabled support for eval-like scenarios. I reached this stage last month; the work involved tracking down a range of bugs, implementing some missing features, and doing a little more work to improve NQP’s portability. So, we had an NQP that ran on the JVM. Port done? Well, not quite.

A little vacation later, I dug into the next stage: making NQP on the JVM able to compile (and thus reproduce) itself. While I’d already implemented the deserialization used to persist meta-objects (representing classes, grammars and so forth), for this next step I had to implement the serialization side of things. Thankfully, there are a bunch of tests for this, so this was largely “just” a matter of working through making them pass. Finally, it was time to work through the last few problems, and get NQP on JVM able to build the NQP sources – and therefore able to compile new versions of itself. I decided to do this work as part of moving the JVM support into the main NQP repository.

Since we’ve only had NQP running on one backend (Parrot) up until now, certain aspects of the repository structure were not ideal. Before starting to bring in the JVM support, I first did a little bit of reorganization to segregate the VM specific components from the VM independent ones. Happily, much of NQP’s implementation falls into the latter category. Next came gradually building up the bootstrapping build process, working a file at a time, tracking down any issues that came up. This was a little tedious, especially given a couple of the problems were separate compilation leakages (where things from the running compiler would get confused with the version of the compiler that it was compiling). It was pretty clear that this was the problem from the errors I was seeing, but such problems show up long after things actually go wrong, requiring some careful analysis to hunt down. With those leaks plugged, and a few other relatively small bugs fixed, I had a working NQP on JVM…compiled by NQP on JVM.

The work from there has been to fill out the rest of the build process, adding in the second bootstrap stage and the test targets. The good news: the NQP produced by NQP on JVM passes all the tests that the original cross-compiled version did, so we’ve got no regressions there as a result of the bootstrap.

This work is currently sat in the jvm-support branch of the NQP repository. After the upcoming NQP release, it will be merged.

### Supporting invokedynamic

Amongst all of this progress, we’ve also gained infrastructure to support using the invokedynamic instruction. This is a mechanism that enables those implementing non-Java languages on the JVM to teach its JIT about how their dispatch works. Most of the hard work here was done by *donaldh*++. I’d initially built things using BCEL in order to do code generation. While it served well up to a point, it turns out that [ASM](http://asm.ow2.org/) has much better support for invokedynamic, as well as being a little faster. So, donaldh got things switched over, and I soon was able to emit invokedynamic.

So far, we are not using it a great deal (just for making `QAST::WVal` compile to something a bit – or potentially a lot – cheaper), but in the future it will be used for things you’d typically think of as invocations (sub and method calls). I’ll write in more detail about it as things evolve.

### What next?

With NQP now ported, the focus will fall on Rakudo itself. Quite a lot of preparations have already been made; for example, many pir:: ops have been replaced with nqp:: ones, multiple dispatch has been ported to NQP from C (fixing some bugs along the way), the way HLL boundaries work has been updated to cope with a fully-6model world (this also let me fix a long-standing introspection bug).

The path through getting Rakudo ported will largely follow the build order. This means starting with the module loader, then the compiler, followed by the MOP and its bootstrapping. After that comes the setting – the place where the built-ins live. There’s around 13,650 lines worth of that, so of course I expect to take it a little at a time. :-) I’ll try to remember to get a progress update here in a couple of weeks time.
