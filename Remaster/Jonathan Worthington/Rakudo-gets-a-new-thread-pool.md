# Rakudo gets a new thread pool
    
*Originally published on [2017-09-23](https://6guts.wordpress.com/2017/09/23/rakudo-gets-a-new-thread-pool/) by Jonathan Worthington.*

Vienna.pm have [funded me to work 50 hours](http://vienna.pm.org/perl_6_jonathan_grant.html) on Raku. After some discussion, we decided I would first work on improving the thread pool scheduler, and then move on to continuing the work around non-blocking `await`, a feature of the upcoming Raku.d. In this post I’ll discuss the work on the thread pool scheduler, which was merged shortly after the latest Rakudo release to maximize testing time, and thus will appear in the next release (2017.10).

### What was wrong with the ThreadPoolScheduler before?

My (by now slightly hazy) memory is that I wrote the initial Raku thread pool implementation in the space of an hour or two on a train, probably heading to some Perl event or other. It was one of those “simplest thing that could possibly work” implementations that turned out to work well enough that it survived with only isolated tweaks and fixes until January this year. At that point, I added the initial bits of support for non-blocking `await`. Even that change was [entirely additive](https://github.com/rakudo/rakudo/commit/94bfd71f32f1925693d5b5877f4485b41989f3a2), leaving the existing scheduling mechanism completely intact.

When I first implemented the thread pool, there were approximately no people writing concurrent Raku programs. Happily, that’s changed, but with it came a few bug reports that could be traced back to the thread pool. Along with those, there were things that, while not being outright bugs, were far from ideal.

Before I dug into a re-design, I first summarized all of the problems I was aware of with the thread pool, so as I considered new designs I could “crash test” them against the problems that afflicted the previous design. Here’s my list of problems with the previous design.

1. It was wasteful, spawning far too many threads in quite a lot of cases. A single use of `Proc::Async` would cause some threads to be created. A second use after that would add some more. A third use would add more. Even if these uses were not concurrent, threads would still be added, up until the maximum pool size. It was a very conservative way to make sure a thread would be available for each piece of work, provided the pool didn’t reach exhaustion point. But really, the pool doesn’t need more than a thread or two for many programs. [RT #131915](https://rt.perl.org/Ticket/Display.html?id=131915) was a ticket resulting from this behavior: each thread added to the memory consumption of the program, making memory use a good bit higher than it should have been for programs that really didn’t need more than a thread or two.
1. Very active async I/O could swamp the thread pool with events. Since there was a single queue, then timer events – which might be being used to kill off a process after a timeout – may not have fired in a very timely manner at all, since the timer event would be stuck behind all of the I/O events. [RT #130370](https://rt.perl.org/Ticket/Display.html?id=130370)
1. Sometimes, despite the conservative mechanism described in #1, not enough threads got started and this led to occasional deadlocks. [RT #122709](https://rt.perl.org/Ticket/Display.html?id=122709)
1. It didn’t try to scale the number of threads to match the available CPU cores in any way. Just because there is a lot of work in the queue does not mean that we need more threads; if we are making progress and the CPU load is pretty high then adding more threads is unlikely to lead to more progress.
1. In high-core-count systems, the default limit of 16 was too low. 32-core CPUs at tolerable prices very much exist by now!
1. For programs that manage to really block a lot of threads with non-CPU bound work, we could deadlock. Most of that will go away with non-blocking `await`, but there will still be ways to write code that really blocks a bunch of OS threads and can’t make progress without yet more threads being made available to run something. At some point, people just have to write their programs differently, but the default limit of 16 threads was not very generous.
1. Despite wishing to raise the maximum default pool size a good bit, we couldn’t do it because issues #1 and #4 meant we’d likely end up hitting the maximum in most programs, and memory use would become totally unreasonable.
1. We suffered from poor thread affinity for events that would inevitably queue up due to serial supplies. For example, if two packets arrived from a socket then they might be picked up by different threads in the pool. If the first packet was still being processed, then the second would contend for the lock used to enforce serial processing of messages by supplies, and block until it was available.

### 3 kinds of queue

Problems 2 (active I/O swamping the queue and delaying timers) and 8 (poor thread affinity) are resolved in the new thread pool by recognizing that not all work given to the pool is equal. Timers really want to be dealt with in a timely manner, so in programs that have timers it makes sense to have a queue, and one or more worker threads, exclusively for time-based events. Work items that will need processing sequentially anyway should be assigned to a single thread, implying that each such “affinity worker” gets a queue of its own. Finally, there is a general queue for everything else, and one or more threads eat from it.

### Adding a supervisor

The other problems were addressed by the addition of a Sufficiently Smart Supervisor. The supervisor is a thread created by the thread pool upon its first use, and living from then until the end of the program. It spends most of its time sleeping, waking up around 100 times a second to check how things are going. It is the supervisor that makes most of the decisions about how many threads to add to the pool. It factors in:

- **Demand** – that is, how much work is there that needs doing. It determines this by looking at the lengths of the timer queue and general queue. If they are empty, then there’s clearly no demand for extra workers. If they have something in them, that’s a sign that we might want more workers.
- **Available workers** – if there’s a worker thread that’s currently not doing anything, then there’s little motivation to add another worker.
- **CPU core count** – for CPU-bound work there’s not much point in having more threads than there are CPU cores, because otherwise the OS will have to juggle them and it won’t do CPU cache hit rates any good. Modern OS schedulers are good at dealing with lots of threads, and these days the MoarVM GC copes alright with having a load of threads to sync up also. Still, each extra thread brings memory overhead. Making the CPU core count a “soft limit” for the number of threads to spawn is usually a reasonable choice.
- **Resource usage** – there’s work in the queue, but the scheduler already spawned as many threads as there are CPU cores. At this point, a couple of situations may apply. Perhaps there’s a queue because all the threads are hard at work on CPU-bound tasks, in which case adding more beyond the core count will not help matters. Alternatively, the thread pool may be full of threads that are somehow blocked, and so there isn’t much, or any, progress at all. In the worst case, there may be a deadlock due to the thread pool being full of blocked threads, and adding an extra thread would break it. To determine this, the supervisor looks at the program’s CPU usage. If it’s really low, then the deadlock situation is relatively likely, so threads may be added beyond the CPU core count.

Having the pool soft-limited to the number of threads, and reluctantly able to go beyond that, means that we can raise the maximum default pool size quite a lot; it now stands at 64 threads. In reality, many programs don’t even reach the CPU core count, as there’s never enough work to trigger the addition of more threads.

### Affinity workers

Affinity worker threads aren’t added by the supervisor. Instead, when an affinity queue is requested, any existing affinity worker threads will have their queue lengths inspected. The one with the shortest queue will be picked, provided that the queue length is below a threshold. If it’s over the threshold (which increases per affinity worker thread added), then another affinity worker thread will be spawned and the work allocated to it.

### Outcomes

For all the cases I’ve tried so far, the new scheduler seems to do either at least as well or better than the one it replaced – and sometimes much better. The deadlock due to insufficient threads bug is gone, thanks to the supervisor. Programs that do the occasional bit of work needing pool threads end up with just a thread or two, greatly reducing their memory consumption. A Cro web application that is processing just a handful of requests a second will now spawn just a few threads (and so use much less memory and get better locality), while one faced with some hundreds of requests per second will spawn more. And a program doing a lot of CPU-bound work now spawns as many threads as there are cores, which gives a small speedup compared to oversubscribing the CPU under the previous scheduler. Finally, timer events are delivered and handled in a timely way, even when there is a lot of output from a process.

### And next?

Well, most immediately I should write some extra regression tests, so I can get the RT tickets mentioned earlier in the article closed up. Feel free to beat me to doing that, though! :-)

That aside, I’d like to mention that while the new scheduler is a decided improvement, it’s also improvable. The heuristics it uses to decide when to add further threads can surely be tuned some more. The code doing that decision making is [written in Raku](https://github.com/rakudo/rakudo/blob/nom/src/core/ThreadPoolScheduler.pm#L405), which I hope makes it accessible to those who would like to experiment and tweak.

Once again, thanks to Vienna.pm for making this work possible. And, finally, a mention that I’m [still looking for funding](https://6guts.wordpress.com/2017/05/12/looking-for-perl-6-rakudo-and-moarvm-development-funding/) to help me keep on doing Raku things for a sizable chunk of my work time; a handful of companies each sponsoring 10 hours a month would soon add up!
