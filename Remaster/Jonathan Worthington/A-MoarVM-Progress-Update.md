# A MoarVM Progress Update
    
*Originally published on [2013-09-08](https://6guts.wordpress.com/2013/09/08/a-moarvm-progress-update/) by Jonathan Worthington.*

A while back, I wrote here to [introduce the MoarVM project](https://6guts.wordpress.com/2013/05/31/moarvm-a-virtual-machine-for-nqp-and-rakudo/), which aims to build a Virtual Machine specially tailored for the needs of NQP and Rakudo. Since then, a lot of progress has been made and the project has attracted a number of new contributors. So, it’s time for a round-up of the latest MoarVM news.

### MoarVM Hosts NQP

Back when I first introduced MoarVM, we had a partly complete cross-compiler that used NQP on Parrot to parse NQP source code and build its AST, then turned it into MoarVM bytecode. This enabled us to cross-compile some of the NQP test suite to MoarVM. Since then, we’ve been improving the cross-compiler so it is able to translate NQP itself into MoarVM bytecode, as well as making the VM capable of doing the things that NQP requires to run.

In the last week, we’ve reached the point of having a self-hosted NQP on MoarVM that passes most of the NQP test suite. What does this really mean? That MoarVM is capable enough not only to run programs written in NQP, but also to run the NQP compiler (meaning it has pretty complete Raku grammar support), its own backend code-generator and to be able to evaluate the result of this compilation.

We’re down to 5 files from t/nqp that either fail outright or fail some tests. I expect we’ll be able to get these fixed within the next week, and also make progress on the serialization tests. Beyond this, it will be time to start working on getting this self-hosted NQP able to build itself. At this point, the cross-compiler will no longer be needed, and the MoarVM backend code will migrate to the main NQP repository, joining the Parrot and JVM backends.

### How slow is it?

I’ve been pushing pretty hard for us to focus on getting things working before getting things fast; for now keeping the code easy to work on and implementing features on the path to having a Rakudo on MoarVM is far, far more important. That said, there is already an encouraging result. While it’s not quite a fair test given the five of the 77 test files that do not run to completion, currently MoarVM can run the NQP test suite in 16s on my main development machine, This compares to 21s on Parrot (which means we come out ahead at startup time, execution time, or a mixture). While it’s not incredibly faster (though of course running lots of small test files is startup-dominated), it isn’t a bad starting point given we’ve barely scratched the surface of what we’ll be able to do in terms of optimization (for example, no JIT yet, known algorithmic issues in handling of GC inter-generational pointers, and comparatively little time invested in optimization all over the VM). By the way, thanks to its much greater start-up time, NQP on the JVM takes a huge 139s. However, much like in the story of the tortoise and the hare, leave things to run for long enough and the JVM backend still typically comes out ahead, sometimes very significantly so.

On memory usage, to compile and run a simple “hello, world” in NQP, MoarVM’s memory usage clocks in at just over half that which Parrot uses, which in turn clocks in at about half that of the hungry JVM. :-)

While the JVM backend doesn’t come out looking too awesome here resource usage wise unless you’re doing something long-running, it’s worth remembering that the JVM port of Rakudo is just a couple of months old, and the whole porting effort less than a year old. In that sense, we’ve a lot of room for improvement yet.

### Goodbye APR, welcome libuv

Originally, MoarVM was using the Apache Portable Runtime for IO, multi-platform thread support and a handful of other things. By now, we’ve moved over to using libuv. This isn’t because there was anything inherently wrong with the APR, and while we’ve ended up not using it, I’ve come out with a positive impression of it. So, thanks to the APR developers! The primary reason we moved to using libuv instead was to ensure we can provide support for asynchronous I/O on a relatively wide variety of platforms. We were also using a mix of the atomic primitives from the APR and from libatomic_ops; we’ve now standardized completely on libatomic_ops for this.

### Build and Dependencies

There’s a bunch of stuff I’m decent at doing, but build systems is not one of them. My first pass was a case of, “make something work, and hope somebody replaces it.” Happily, that has now happened, so the build system is in much better shape. We’ve also got things in place for building MoarVM as a shared library, and for pulling in varius dependencies while keeping them at enough of a distnace that we should be able to depend on system versions of them (trying to balance easy source builds with keeping future packagers happier).

### Contributors

Since becoming a public project, MoarVM has grown its contributor base. In total, 16 authors now show up in the commit log and I’d say we’re at around 5 core developers who commit notable things relatively often. I’m happy that people have felt inspired to contribute, and that things are progressing fairly swiftly now (I hoped we’d be a little further by this point, but my tuit supply over the summer was not what I’d hoped). Currently, it looks like the October NQP release will be the first to include MoarVM support, and from there we’ll focus on getting Rakudo onto MoarVM.
