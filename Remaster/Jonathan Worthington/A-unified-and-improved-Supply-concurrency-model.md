# A unified and improved Supply concurrency model
    
*Originally published on [2017-11-24](https://6guts.wordpress.com/2017/11/24/a-unified-and-improved-supply-concurrency-model/) by Jonathan Worthington.*

Raku encourages the use of high-level constructs when writing concurrent programs, rather than dealing with threads and locks directly. These not only aid the programmer in producing more correct and understandable programs, but they also afford those of us working on Raku implementation the opportunity to improve the mechanisms beneath the constructs over time. Recently, I wrote about [the new thread pool scheduler](https://github.com/rakudo/rakudo/commit/142c1d657c), and how improving it could bring existing programs lower memory usage, better performance, and the chance to scale better on machines with higher core counts.

In this post, I’ll be discussing the concurrency model beneath `Supply`, which is the Raku mechanism for representing an asynchronous stream of values. The values may be packets arriving over a socket, output from a spawned process or SSH command, GUI events, file change notifications, ticks of a timer, signals, and plenty more besides. Giving all of these a common interface makes it easier to write programs that compose multiple asynchronous data sources, for example, a GUI application that needs to update itself when files change on disk, or a web server that should shut down cleanly upon a signal.

Until recently, there were actually two different concurrency models, one for `supply` blocks and one for all of the methods available on a `Supply`. Few people knew that, and fewer still had a grasp of what that meant. Unfortunately, neither model worked well with the 6.d non-blocking `await`. Additionally, some developers using `supply`/`react`/`whenever` in their programs ran into a few things that they had expected would Just Work, which in reality did not.

Before digging in to the details, I’d like to take a moment to thank [Vienna.pm](https://vienna.pm.org/perl_6_jonathan_grant.html) for providing the funding that allowed me to dedicate a good bit of time to this task. It’s one of the trickiest things I’ve worked on in a while, and having a good chunk of uninterrupted time to focus on it was really helpful. So, thanks!

### Supplies and concurrency

The first thing to understand about `Supply`, and `supply` blocks, is that they are a tool for concurrency *control*. The power of `supply` blocks (`react` also) is that, no matter how many sources of asynchronous data you tap using `whenever` blocks, you can be sure that only one incoming message will be processed at a time. The same principle operates with the various methods: if I `Supply.merge($s1, $s2).tap(&some-code)`, then I know that even if `$s1` or `$s2` were to emit values concurrently, they will be pushed onward one at a time, and thus I can be confident that `&some-code` will be called with a value at a time.

These one-message-at-a-time semantics exist to enable safe manipulation of state. Any lexical variables declared within a `supply` block will exist per time the `supply` block is tapped, and can be used safely inside of it. Furthermore, it’s far easier to write code that processes asynchronous messages when one can be sure the processing code for a given message will run to completion before the next message is processed.

### Backpressure

Another interesting problem for any system processing asynchronous messages is that of backpressure. In short, how do we make a source of messages emit them at a rate no greater than that of the processing logic? The general principle with `Supply` is that the sender of a message pays the cost of its processing. So, if I have `$source.map(&foo).tap(&bar)`, then whatever emits at the source pays the cost of the `map` of that message along with the processing done by the `tap` callback.

The principle is easy to state, but harder to deliver on. One of the trickiest questions resolves around recursion: what happens when a `Supply` ends up taking an action that results in it sending a message to itself? That may sound contrived, but it can happen very easily. When the body of a `supply` block runs, the `whenever` blocks trigger tapping of a `supply`. If the tapped `Supply` was to synchronously emit a message, we immediately have a problem: we can’t process it now, because that would violate the one-at-a-time rule. A real world example where this happens? A HTTP/2 client, where the frame serializer immediately emits the connection preface when tapped, to make sure it gets sent before anything else can be sent. (Notice how this in itself also relies on the non-interruption principle.) This example comes straight out of Cro’s HTTP/2 implementation.

A further issue is how we apply the backpressure. Do we block a real thread? Or can we do better? If we go doing real blocking of thread pool threads, we’ll risk exhausting the pool at worst, or in the better case force the program to create more threads (and so use more memory) than it really needs.

### Where things stood

So, how did we do on these areas before my recent work? Not especially great, it turned out.

First, let’s consider the mechanism that was used for everything except the case of `supply` blocks. Supply processing methods generally check that their input `Supply` is serial – that is, delivered one message at a time – by calling its `serial` method. If not, they `serialize` it. (In fact, they all call the `serialize` method, which just returns identity if `serial` is `True`, thus factoring out the check). The upshot of this is that we only have to enforce the concurrency control once in a chain of operations that can’t introduce concurrency themselves. That’s good, and has been retained during my changes.

So, the interesting part is how `serialize` enforces one-at-a-time semantics. Prior to my recent work, it did this using a `Lock`. This has a few decent properties: locks are pretty well optimized, and they block a thread in an OS-aware way, meaning that the OS scheduler knows not to bother scheduling the waiting thread until the lock is released. They also have some less good properties. One is that using `Lock` blocks the use of 6.d non-blocking `await` in any downstream code (a held `Lock` can’t migrate between threads), which was a major motivator to look for an alternative solution. Even if that were not an issue, the use of `Lock` really blocks up a thread, meaning that it will not be available for the thread pool to use for anything else. Last, but certainly not least, `Lock` is a reentrant mutex – meaning that we could end up violating the principle that a message is completely processed before the next message is considered in some cases!

For `supply` blocks, a different approach had been taken. The `supply` block (or `react` block) instance had a queue of messages to process. Adding to, or taking from, this queue was protected by a `Lock`, but that was only held in order to update the queue. Messages were not removed from the queue until they had been processed, which in turn provided a way of knowing if the block instance is “busy”. If a message was pushed to the block instance when it was busy, then it was put onto the queue…and that is all. So who paid for the message processing?

It turns out, it was handled by the thread that was busy in the `supply` block at the time that message arrived! This is pretty sensible if the message was a result of recursion. However, it could lead to violation of the principle that the sender of a message should pay for its processing costs. An unlucky sender could end up paying the cost of an unbounded number of messages of other senders! Interestingly enough, there haven’t been any bug reports about this, perhaps because most workloads simply don’t hit this unfairness, and those that do aren’t impacted by it anyway. Many asynchronous messages arrive on the thread pool, and it’s probably not going to cause much trouble if one thread ends up working away at a particular `supply` block instance that is being very actively used. It’s a thread pool, and some thread there will have to do the work anyway. The unfairness could even be argued to be good for memory caches!

Those arguments don’t justify the problems of the previous design, however. Queues are pretty OK at smoothing out peaks in workloads, but the stable states of a queue are being full and being empty, and this was an unbounded queue, so “full” would mean “out of memory”. Furthermore, there was no way to signal back towards a producer that it was producing too fast.

### Towards a unified model: Lock::Async

So, how to do better? I knew I wanted a unified concurrency control mechanism to use for both `serialize` and `supply`/`react` blocks. It had to work well with non-blocking `await` in 6.d. In fact, it needed to – in the case a message could not be processed now, and when the sender was on the thread pool – do exactly what non-blocking `await` does: suspend the sender by taking a continuation, and schedule that to be run when the message it was trying to send could be sent. Only in the case that the sender is not a pool thread should it really block. Furthermore, it should be fair: message senders should queue up in order to have their message processed. On top of that, it needed to be efficient in the common case, which is when there is no contention.

In response to these needs, I built `Lock::Async`: an asynchronous locking mechanism. But what is an asynchronous lock? It has a `lock` method which returns a `Promise`. If nothing else is holding the lock, then the lock is marked as taken (this check-and-acquire operation is implemented efficiently using an atomic operation) and the `Promise` that is returned will already be `Kept`. Otherwise, the `Promise` that is returned will be `Kept` when the lock becomes available. This means it can be used in conjunction with `await`. And – here’s the bit that makes this particularly useful – it means that it can use the same infrastructure built for non-blocking `await` in 6.d. Thus, an attempt to acquire an asynchronous lock that is busy on the thread pool will result in that piece of work being suspended, and the thread can be used for something else. As usual, in a non-pool thread, real blocking (involving a condition variable) will take place, meaning those who need to be totally in control of what thread they’re running on, and so use `Thread` directly, will maintain that ability. (Examples of when that might be needed include writing bindings using NativeCall.)

When the `unlock` method is called, then there are two cases. The first is if nobody contended for the lock in the meantime: in this case, then another atomic operation can be used to mark it as free again. Otherwise, the `Promise` of the first waiter in line is kept. This mechanism provides fairness: the lock is handed out to senders in the order that they requested it.

Thus, using `Lock::Async` for concurrency control of supplies gives us:

- A mechanism that, under no contention, is relatively cheap: a single atomic operation to acquire and another one to release.
- Fairness: senders get the lock in the order they asked for it.
- Non-blocking suspension of a sender that can not currently obtain the lock, enabling better utilization of the thread pool.
- Working non-blocking `await` in `supply`/`react` blocks, or even `Supply` methods like `do` or `map`.
- No accidental reentrancy (but we’ll need to care for recursion – more on that next).

As an aside: as part of this I spent some time thinking about the semantics of `await` inside of a `supply` or `react` block. Should it block processing of other messages delivered to the block? I concluded that yes, it should: it provides a way to apply backpressure (for example, `await` of a write to a socket), and also means that `await` isn’t an exception to the “one message processed at a time, and processed fully” design principle. It’s not like getting the other behavior is hard: just use a nested `whenever`.

### Taps that send messages

So, I put use of `Lock::Async` in place and all was…sort of well, but only sort of. Something like this:

```` raku
my $s = supply {
    for ^10 -> $i {
        emit $i
    }
}
react {
    whenever $s {
        .say 
    }
}
````

Would hang. Why? Because the lock protecting the `react` block was obtained to run its mainline, setting up the subscription to `$s`. The setup is treated just like processing a message: it should run to completion before any other message is processed. Being able to rely on that is important for both correctness and fairness. The supply `$s`, however, wants to synchronously `emit` values as soon as it is tapped, so it tries to acquire the async lock. But the lock is held, so it waits on the `Promise`, but in doing so blocks progress of the calling `react` block, so the lock is never released. It’s a deadlock.

An example like this did work under the previous model, though for not entirely great reasons. The 10 messages would be queued up, along with the done message of `$s`. Then, its work complete, the calling `react` block would get back control, and then the messages would be processed. This was OK if there was just a handful of messages. But something like this:

```` raku
my $s = supply {
    loop {
        emit ++$;
    }
}
react {
    whenever $s {
        .say;
    }
    whenever Promise.in(0.1) {
        done;
    }
}
````

Would hang, eating memory rapidly, until it ran out of memory, since it would just queue messages forever and never give back control.

The new semantics are as follows: if the `tap` method call resulting from a `whenever` block being encountered causes an `await` that can not immediately be satisfied, then a continuation is taken, rooted at the `whenever`. It is put into a queue. Once the message (or initial setup) that triggered the `whenever` completes, and the lock is released, then those continuations are run. This process repeats until the queue is empty.

What does this mean for the last two examples? The first one suspends at the first `emit` in the `for ^10 { ... }` loop, and is resumed once the setup work of the `react` block is completed. The loop then delivers the messages into the `react` block, producing them and having them handled one at a time, rather than queuing them all up in memory. The second example, which just hung and ate memory previously, now works as one would hope: it displays values for a tenth of a second, and then tears down the `supply` when the `react` block exits due to the `done`.

This opens up `supply` blocks to some interesting new use cases. For example, this works now:

```` raku
my $s = supply {
    loop {
        await Promise.in(1);
        emit ++$;
    }
}
react {
    whenever $s {
        .say
    }
}
````

Which isn’t itself useful (just use `Supply.interval`), but the general pattern here – of doing an asynchronous operation in a loop and emitting the result it gives each time – is. A supply emitting the results of periodic polling of a service, for example, is pretty handy, and now there’s a nice way to write it using the `supply` block syntax.

### Other recursion

Not all recursive message delivery results from synchronous `emit`s from a `Supply` tapped by a `whenever`. While the solution above gives nice semantics for those cases – carefully not introducing extra concurrency – it’s possible to get into situations where processing a message results in another message that loops back to the very same `supply` block. This typically involves a `Supplier` being emitted into. This isn’t *common*, but it happens.

Recursive mutexes – which are used to implement `Lock` – keep track of which thread is currently holding the lock, using thread ID. This is the reason one cannot migrate code that is holding such a lock between threads, and thus why one being held prevents non-blocking `await` from being, well, non-blocking. Thus, a recursion detection mechanism based around thread IDs was not likely to end well.

Instead, `Lock::Async` uses dynamic variables to keep track of which async locks are currently held. These are part of an invocation record, and so can safely be transported across thread pool threads, meaning they interact just fine with the 6.d non-blocking `await`, and the new model of non-blocking handling of supply contention.

But what does it *do* when it detects recursion? Clearly, it can’t just decide to forge ahead and process the message anyway, since that violates the “messages are processed one at a time and completely” principle.

I mentioned earlier that `Lock::Async` has `lock` and `unlock` methods, but those are not particularly ideal for direct use: one must be terribly careful to make sure the `unlock` is never missed. Therefore, it has a `protect` method taking a closure. This is then run under the lock, thus factoring out the `lock` and `unlock`, meaning it only has to be got right in one place.

There is also a `protect-or-queue-on-recursion` method. This is where the recursion detection comes in. If recursion is detected, then instead of the code being run now, a `then` is chained on to the `Promise` returned by `lock`, and the passed closure is run in the `then`. Effectively, messages that can’t be delivered right now because of recursion are queued for later, and will be sent from the thread pool.

This mechanism’s drawback is that it becomes a place where concurrency is introduced. On the other hand, given we know that we’re introducing it for something that’s going to run under a lock anyway, that’s a pretty safe thing to be doing. A good property of the design is that recursive messages queue up fairly with external messages.

### Future work

The current state is much better than what came before it. However, as usual, there’s more that can be done.

One thing that bothers me slightly is that there are now two different mechanisms both dealing with different cases of message recursion: one for the case where it happens during the tapping of a supply caused by a `whenever` block, and one for other (and decidedly less common) cases. Could these somehow be unified? It’s not immediately clear to me either way. My gut feeling is that they probably can be, but doing so will involve some different trade-offs.

This work has also improved the backpressure situation in various ways, but we’ve still some more to do in this area. One nice property of async locks is that you can check if you were able to acquire the lock or not before actually awaiting it. That can be used as feedback about how busy the processing path ahead is, and thus it can be used to detect and make decisions about overload. We also need to do some work to communicate down to the I/O library (libuv on MoarVM) when we need it to stop reading from things like sockets or process handles, because the data is arriving faster than the application is able to process it. Again, it’s nice that we’ll be able to do this improvement and improve the memory behavior of existing programs without those programs having to change.

### In summary…

This work has replaced the two concurrency models that previously backed `Supply` with a single unified model. The new model makes better use of the thread pool, deals with back-pressure shortcomings with `supply` blocks, and enables some new use cases of `supply` and `react`. Furthermore, the new approach interacts well with 6.d non-blocking `await`, removing a blocker for that.

These are welcome improvements, although further unification may be possible, and further work on back-pressure is certainly needed. Thanks once again to [Vienna.pm](https://vienna.pm.org/perl_6_jonathan_grant.html) for helping me dedicate the time to think about and implement the changes. If your organization would like to help me continue the journey, and/or my Raku work in general, I’m still [looking for funding](https://6guts.wordpress.com/2017/05/12/looking-for-perl-6-rakudo-and-moarvm-development-funding/).
