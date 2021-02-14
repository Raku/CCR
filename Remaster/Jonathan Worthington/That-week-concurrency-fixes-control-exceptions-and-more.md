# That week: concurrency fixes, control exceptions, and more
    
*Originally published on [2015-06-05](https://6guts.wordpress.com/2015/06/05/that-week-concurrency-fixes-control-exceptions-and-more/) by Jonathan Worthington.*

I’m back! I was able to rest fairly well in the days leading up to my wedding, and had a wonderful day. Of course, after the organization leading up to it, I was pretty tired again afterwards. I’ve also had a few errands to run with getting our new apartment equipped with various essentials – including a beefy internet connection. And, in the last couple of days, I’ve been steadily digging back into work on my Raku grant. :-) So, there will be stuff to tell of about that soon; in the meantime, here’s the May progress report I never got around to writing.

### Before fixing something, be sure you need it

I continued working on improving stability of our concurrent, async, and parallel programming features. One of the key things I found to be problematic was the frame cache. The frame cache was introduced to MoarVM very early on, to avoid memory allocations for call frames by keeping them cached. Back then, we allocated them using malloc. The frames were cached per thread, so in theory no thread safety issues, right? Well, wrong, unfortunately. The MoarVM garbage collector works in parallel, and while it does have to pause all threads for some of the work, it frees them to go on their way when it can. Also, it steals work from threads that are blocked on doing I/O, acquiring a lock, waiting on a condition variable, and so forth. One of the things that we don’t need to block all threads for is clearing out the per-thread nursery, and running any cleanup functions. And some of those cleanups are for closures, and those hold references to frames, which when freed go into the frame pool. This is enough for a nasty bug: thread A is unable to participate in GC, thread B steals its GC work, the GC gets mostly done and things resume, thread A comes back from its slumber and begins executing frames, touching the frame pool…which thread B is also now touching because it is freeing closures that got collected. Oops. I started pondering how best to deal with this…and then had a thought. Back when we introduced the frame cache, we used malloc to allocate frames. However, now we use MoarVM’s own fixed size allocator – which is a good bit faster (and of course makes some trade-offs to achieve that – there’s no free lunch in allocation land). Was the frame cache worth it? I did some benchmarking and discovered that it wasn’t worth it in terms of runtime (and *timotimo*++ did some measurements that suggested we might even be better off without it, though it was in the “noise” region). So, we could get less code, and be without a nasty threading bug. Good, right? But it gets better: the frame cache kept hold of memory for frames that we only ever executed during startup, or only ran during the compile phase and not at runtime. So eliminating it would also shave a bit off Rakudo’s memory consumption too. With that data in hand, it was a no-brainer: the frame cache went away, and with it an icky concurrency bug. However, the frame cache had one last “gift” for us: its holding on to memory had hidden a reference counting mistake for deserialized closures. Thankfully, I was able to identify it fairly swiftly and fix it.

### More concurrency fixes

I landed a few more concurrency related fixes also. Two of them related to parametric role handling and role specialization, which needed some concurrency control. To ease this I added an `Lock` class to NQP, with pretty much the same API as the Raku one. (You could use locks from NQP before, but there was some boilerplate. Now it’s easy.) One other long-standing issue we’ve had is that using certain features (such as timers) could drive a single CPU core up to 100% usage. This came from using an idle handler on the async event loop thread to look for new work and check if we needed to join in with a garbage collection run. It did yield to the OS if it had nothing to do – but on an unloaded system, a yield to the OS scheduler will simply get you scheduled again in pretty short order. Anyway, I spent some time looking into a better way and implemented it. Now we use libuv async handlers to wake up the event loop when there’s new work it needs to be aware of. And with that, we stopped swallowing up a core. Unfortunately, while this was a good fix, our CPU hunger had been making another nasty race involving lazy deserialization only show up occasionally. Without all of that resource waste, this race started showing up all over the place. This is now fixed – but it happened just in these last couple of days, so I’ll save talking about it until the next report.

### Startup time improvements

Our startup time has continued to see improvements. One of the blockers was a pre-compilation bug that showed up when various lazily initialized symbols were used (of note, `$*KERNEL`, `$*VM`, and `$*DISTRO`). It turns out the setup work of these poked things into the special `PROCESS` package. While it makes no sense to serialize an updated version of this per-process symbol table…we did. And there was no good mechanism to prevent that from happening. Now there is one, resolving RT #125090. This also unblocked some startup time optimizations. I also got a few more percent off startup by deferring constructing a rarely used `DateTime` object for the compiler build date.

### Control exception improvements

Operations like `next`, `last`, `take`, and `warn` throw “control exceptions”. These are not caught by a normal `CATCH` handler, and you don’t normally need to think of them as exceptions. In fact, MoarVM goes to some effort to allow their implementation without ever actually creating an exception object (something we take advantage of in NQP, though not yet in Rakudo). If you do want to catch them and process them, you can use a `CONTROL` block. Trouble is, there was no way to talk about what sort of control exceptions were interesting. Also, we had some weird issues when a control exception went unhandled (RT #124255), manifesting in a segfault a while back, though by the time I looked at it we were merely at giving a poor error. Anyway, I fixed that, and introduced types for the different kinds of control exception, so you can now do things like:

```` raku
CONTROL {
    when CX::Warn {
        log(.message);
    }
}
````

To do custom logging of warnings. I also wrote various [tests](https://github.com/raku/roast/blob/master/S04-exception-handlers/control.t) for these things.

### Collaboration

I helped out others, and they helped me. :-)

- *FROGGS*++ was working on using the built-in serialization support we have for the module database, but was running into a few problems. I helped resolve them…and now we have faster module loading. Yay.
- *TimToady*++ realized that auto-generated proto subs were being seen by `CALLER`, auto-generated method ones were not, and hand-written protos that only delegated to the correct multi also were not. He found a way to fix it; I reviewed it and tweaked it to use a more appropriate and far cheaper mechanism.
- I noticed that calling `fail` was costly partly because we constructed a full backtrace. It turns out that we don’t need to fully construct it, but rather can defer most of the work (for the common case where the failure is handled). I mentioned this on channel, and *lizmat*++ implemented it

### Other bits

I also did a bunch of smaller, but useful things.

- Fixed two tests in S02-literals/quoting.t to work on Win32
- Did a Panda Wndows fix
- Fixed a very occasional SEGV during CORE.setting compilation due to a GC marking bug (RT #124196)
- Fixed a JVM build breakage
- Fixed RT #125155 (.assuming should be supported on blocks)
- Fixed a crash in the debugger, which made it explode on entry for certain script

More next time!
