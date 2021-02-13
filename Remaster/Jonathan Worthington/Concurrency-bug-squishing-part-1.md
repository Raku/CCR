# Concurrency bug squishing: part 1
    
*Originally published on [2016-08-22](https://6guts.wordpress.com/2016/08/22/concurrency-bug-squishing-part-1/) by Jonathan Worthington.*

Most of my recent Raku development time has been spent hunting down and fixing various concurrency bugs. We’ve got some nice language features in this area, and they’ve been pretty well received so far. However, compared with many areas of Raku, they have been implemented relatively recently. Therefore, they have had less time to mature – which, of course, means more bugs and other rough edges.

Concurrency bugs tend to be rather tedious to hunt down. This is in no small part because reproducing them reliably can be challenging. Even once a fairly reliable reproduction is available, working out what’s going on can be tricky. Like all debugging, being methodical and patient is the key. I tend to keep notes of things I’ve tried and observed, and output produced by instrumenting programs with logging (fancy words for “adding prints and exception throws when sanity checks fail”). I will use interactive debuggers when needed, but even then the data from them tends to end up in my editor on any extended bug hunt. Debugging is in some ways the experimental science of programming. Even with a good approach, being sufficiently patient – or perhaps just downright stubborn – matters plenty too.

In the next 2-3 posts here, I’ll discuss a few of the bugs I recently hunted down. It will not be anything close to an exhaustive list of them, which would surely be as boring for you to read as it would be for me to write. This is just the “greatest hits”, if you like.

### A tale of silly suspicions and dodgy data

This hunt started out looking in to various hangs that had been reported. Deadlocks are a broad category of bug (there’s another completely unrelated one I’ll cover in this little series, even). However, a number of ones that had shown up looked very similar. All of them showed a number of threads trying to enter GC, stuck in the consensus loop (which, yes, really is just a loop that we go around asking, “did every thread agree we’re going to do GC yet?”)

I’ll admit I went into this one with a bit of a bias. The GC sync-up code in question is a tad clever-looking. That doesn’t mean it’s wrong, but it makes it harder to be comfortable it’s correct. I also worried a bit that the cost of the consensus loop might well be enormous. So I let myself become a bit distracted for some minutes doing a profiling run to find out. I mean, who doesn’t want to be the person who fixed concurrency bug in the GC *and* made it faster at the same time?!

I’ve found a lot of useful speedups over the years using callgrind. I’ve sung its praises on this blog at least once before. By counting CPU cycles, it can give very precise and repeatable measurements on things that – measured using execution time – I’d consider within noise. With such accuracy, it must be the only profiler I need in my toolbox, right?

Well, no, of course not. Any time somebody says that X tool is The Best and doesn’t explain the context *when* it’s The Best, be very suspicious. Running Callgrind on a multi-threaded benchmark gave me all the ammunition I could ever want for replacing the GC sync-up code. It seemed that a whopping 30% of CPU cycles were spent in the GC consensus loop! This was going to be huuuuge…

Or was it? I mean, 35% seems just a little too huge. Profiling is vulnerable to the [observer effect](https://en.wikipedia.org/wiki/Observer_effect_(physics)): the very act of measuring a program’s performance inevitably changes the program’s performance. And, while on the dubious physics analogies (I shouldn’t; I was a pretty awful physicist once I reached the relativity/QM stuff), there’s a bit of an uncertainty principle thing going on. The most invasive profilers can tell you very precisely where in your program time is spent, but you’re miles off knowing how fast you’re normally going in those parts of the program. They do this by instrumenting the program (like the current Raku on MoarVM profiler does) or running it on a [synthetic CPU](http://valgrind.org/docs/manual/manual-core.html#manual-core.whatdoes), as Callgrind does. By contrast, a sampling profiler lets your program run pretty much as normal, and just takes regular samples of the call stack. The data is much less precise about where the program is spending its time, but it is a much better reflection of how fast the program is normally going.

So what would, say, the [perf sampling profiler](https://perf.wiki.kernel.org/index.php/Tutorial#Sampling_with_perf_record) make of the benchmark? Turns out, well less than 1% of time was spent in the GC consensus loop in question. (Interestingly, around 5% was spent in a second GC termination consensus loop, which wasn’t the one under consideration here. That will be worth looking into in the future.) The Visual Studio sampling profiler on Windows – which uses a similar methodology – also gave a similar figure, which was somewhat reassuring also.

Also working against Callgrind is the way the valgrind suite of tools [deal with multi-threaded applications](http://valgrind.org/docs/manual/manual-core.html#manual-core.pthreads) – in short by serializing all operations onto a single thread. For a consensus loop, which expects to be dealing with syncing up a number of running threads, this could make a radical difference.

Finally, I decided to check in on what The GC Handbook had to say on the matter. It turns out that it suggests pretty much the kind of consensus loop we already have in MoarVM, albeit rather simpler because it’s juggling a bit less (a simplification I’m all for us having in the future too). So, we’re not doing anything so unusual, and with suitable measurements it’s performing as expected.

So, that was an interesting but eventually fairly pointless detour. What makes this all the more embarassing, however, is what came next. Running an example I knew to hang under GDB, I waited for it to do so, hit Ctrl + C, and started looking at all of the threads. Here’s a summary of their states:

- 17: blocking on concurrent queue read (cond var wait)
- 16: in mark thread unblocked; yielded
- 15: in AO_load_read at MVM_gc_enter_from_interrupt (tc=0x33ee010) at src/gc/orchestrate.c:481
- 14: blocking on concurrent queue read (cond var wait)
- 13: blocking on concurrent queue read (cond var wait)
- 12: in AO_load_read at MVM_gc_enter_from_interrupt (tc=0x33ee010) at src/gc/orchestrate.c:481
- 11: in AO_load_read at MVM_gc_enter_from_interrupt (tc=0x33ee010) at src/gc/orchestrate.c:481
- 10: blocking on concurrent queue read (cond var wait)
- 09: blocking on concurrent queue read (cond var wait)
- 08: trying to acquire lock on concurrent queue read (at src/6model/reprs/ConcBlockingQueue.c:160)
- 07: blocking on concurrent queue read (cond var wait)
- 06: in mark thread unblocked; yielded
- 05: in AO_load_read at MVM_gc_enter_from_interrupt (tc=0x33ee010) at src/gc/orchestrate.c:481
- 04: in AO_load_read at MVM_gc_enter_from_interrupt (tc=0x33ee010) at src/gc/orchestrate.c:481
- 03: blocking on concurrent queue read (cond var wait)
- 02: in mark thread unblocked; yielded
- 01: triggered GC; MVM_gc_enter_from_allocator (tc=tc@entry=0x6037c0) at src/gc/orchestrate.c:384

And yes, for the sake of this being a nice example for the blog I perhaps should not have picked one with 17 threads. Anyway, we’ll cope. First up, the easy to explain stuff. All the threads that are “blocking on concurrent queue read (cond var wait)” are fairly uninteresting. They are Raku thread pool threads waiting for their next task (that is, wanting to pull an item from the scheduler’s queue, and waiting for it to be non-empty).

Thread 01 is the thread that has triggered GC. It is trying to get consensus from other threads to begin GC. A number of other threads have already been interrupted and are also in the consensus loop (those marked “in AO_load_read at MVM_gc_enter_from_interrupt”). This is where I had initially suspected the problem would be. That leaves 4 other threads.

You might wonder how we cope with threads that are simply not in a position to participate in the consensus process, because they’re stuck in OS land, blocked waiting on I/O, a lock, a condition variable, a semaphore, a thread join, and so forth. The answer is that before they hand over control, they mark themselves as blocked. Another thread will steal their work if a GC happens while the thread is blocked. When the thread becomes unblocked, it marks itself as such. However, if a GC is already happening at that point, it’s not safe for the thread to proceed. Thus, it yields until GC is done. This accounts for the 3 threads described as “in mark thread unblocked; yielded”.

Which left one thread, which was trying to acquire a lock in order to peek a queue. The code looked like this:

````
    if (kind != MVM_reg_obj)
        MVM_exception_throw_adhoc(tc, "Can only shift objects from a ConcBlockingQueue");

    uv_mutex_lock(&cbq->locks->head_lock);

    while (MVM_load(&cbq->elems) == 0) {
        MVMROOT(tc, root, {
````

Spot anything missing?

Here’s the corrected version of the code:

````
    if (kind != MVM_reg_obj)
        MVM_exception_throw_adhoc(tc, "Can only shift objects from a ConcBlockingQueue");

    MVM_gc_mark_thread_blocked(tc);
    uv_mutex_lock(&cbq->locks->head_lock);
    MVM_gc_mark_thread_unblocked(tc);

    while (MVM_load(&cbq->elems) == 0) {
        MVMROOT(tc, root, {
````

Yup, it was failing to mark itself as blocked while contending for a lock, meaning the GC could not steal its work. So, the GC’s consensus algorithm wasn’t to blame after all. D’oh.

### To be continued…

I actually planned to cover a second issue in this post. But, it’s already gone midnight, and perhaps that’s enough fun for one post anyway. :-) Tune in next time, for more GC trouble and another cute deadlock!
