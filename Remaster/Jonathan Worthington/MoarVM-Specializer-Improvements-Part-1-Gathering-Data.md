# MoarVM Specializer Improvements Part 1: Gathering Data
    
*Originally published on [2017-08-06](https://6guts.wordpress.com/2017/08/06/moarvm-specializer-improvements-part-1-gathering-data/) by Jonathan Worthington.*

Over the last weeks I’ve had the chance to work full time on Raku, and have dedicated this time to improving the MoarVM specializer. Since “specializer” is such a lot to type, but shortening it to “spec” would result in it being confused with specification (or perhaps bacon), we refer to it as “spesh”. But what is it?

### Specialization

Specialization is the process of taking code with lots of late-binding in it, and producing one or more versions of the code with as much of that stripped out as we can. We take late binding in a very broad sense, really using it to mean any place where we defer a decision until the code is executed (that is, runtime) because we don’t know the context it will be executed in. So, if we write a module with this in it:

```` raku
sub shorten($text, $limit) is export {
    $text.chars > $limit
        ?? $text.substr(0, $limit) ~ '...'
        !! $text
}
````

Then this code isn’t committed to the types of `$text` and `$limit`. Thus, we must:

- Resolve the `chars` and `substr` method at runtime
- Decide which multi dispatch candidate of `>` and `~` to call
- Since `substr` is also a multi, decide what multi dispatch candidate to call

Even if we put `Str` and `Int` type constraints on the sub, that still isn’t really enough: these could be subclassed (for example, by mixing in to them) and thus override the methods that we call. (Granted in this particular case that’d be a tad odd, but in the general case, it’s not.)

Even with nice things like method caches and multi-dispatch caches, which do provide a huge speedup, we still must do the cache lookups, call the methods, and so forth. The job of the specializer is to notice what types we actually call `shorten` with, and the types methods like `chars` return, and thus strip out the need to even do cache lookups. It can then go further, for example inlining the body of the small `chars` method (and maybe `substr` too) into the caller so that there will be no invocation overhead for them at all!

### Before we go any further, a quick thank you

This work is funded by my [current TPF grant](http://news.perlfoundation.org/2017/07/grant-extension-approved-perl-.html), which was approved some weeks back (so I’ve already been working away at it), though only recently publicly announced due to an internal TPF procedure that had to be completed first. So, thanks go to TPF for administering the funding, and to those who have donated to TPF and the Raku Core Development Fund for providing the funding.

### A little series

I could just write up a list of the improvements I’ve done, but I figure that many readers here don’t know a great deal about spesh. So instead, I will write a series of posts working through the way spesh works today, after my changes, together with some notes on how it used to work and why that changed. Hopefully that will be a more interesting and useful read.

### What to optimize?

When I’ve talked people through how spesh works in the past, I’ve tended to start by discussing how the bytecode is turned into a control flow graph in single static assignment form, and then we go on and do the various bits of analysis and transformation. We’ll get to that, but in fact there has always been a step before it.

Constructing a CFG and putting it in SSA form takes time; transforming it by doing a load of optimizations takes more. How much depends on the size and structure of the code. So we need to decide what code to spend time on. This was done in two ways.

The first was just incrementing a counter every time the sub, block, method, or regex was called. If the count passed a threshold (which was chosen based upon the size of the bytecode) then an optimized version of it would be produced. Easy enough.

Trouble is that this doesn’t catch an important case: that where we have a program that spends most of its lifetime in a loop. In that case, we only enter the block holding the loop once, which is never going to trigger optimization. Thus we also count the number of iterations of loops. If that counter hits a high enough value, then we produce the optimized code and replace the running code with it, potentially moving from the interpreter into machine code. This replacement of code with an optimized version is known as “on stack replacement”, because it’s replacing code already running on the call stack).

### Gathering data

Just throwing bytecode representing a highly dynamic program into an optimizer won’t achieve much, however. The cost is in the late binding, and to remove that we need an idea of what kinds of things are showing up when the code is run. This data came from two sources.

The first source was the incoming parameter types. When code was determined as hot, then the shape of the callsite (how many arguments, which named arguments) and the types of the arguments were taken and turned into a “key” for the specialization. These could then be assumed inside of the optimizer.

This was not enough on its own to produce good optimizations, however, because a lot of data comes from attribute accesses, lexical accesses, and the return values of things the code calls. Therefore, before doing any significant work, spesh would go through the code and insert logging instructions. These would record the values that were observed. After 8 runs, the specialization process would continue, using this data.

### Bad decisions and missing information

This worked relatively well, but had notable shortcomings. The main one concerns code that is highly polymorphic in nature – that is, it is called with many different types. In this case, whichever type it was called with on, say, its 100th call, would have a specialization produced for it. If the next call used a different type, another specialization would be produced for that. And so forth, up until we had four specializations, which was the number picked as the limit.

This meant that things like `defined` or `sink`, which are called very often but on a lot of different types, would often go unoptimized and un-JITted. Worse, the way inlining works is to inline any existing specialization. Inlining all the `defined` and `sink` calls would be ideal. But in reality, for any non-trivial program, that would not happen in most cases. Clearly, if only the specializer were able to take a step back, it could see this situation and do something smarter. But the data just wasn’t there to do it.

The 8 samples taken when logging could also get lucky or unlucky about what values they saw. If a value returned from a method is a certain type over 99% of the time, and less than 1% of the time it is something else, then it makes sense to stick a guard in, optimize for the 99% case, and let the guard fail and trigger deoptimization for the less than 1% of the cases. (A deoptimization is like the opposite of OSR: we swap the optimized version of the code for the slower one that can handle all of the cases, and let it take care of the rare cases).

With only 8 values, however, 1 of them being different suggests we might have to deoptimize over 10% of the time. Deoptimization takes a bit of time to do, but leaves us interpreting the code with a bunch of late binding. The stakes are too high if all the data can tell us is that there’s a 1 in 8 chance.

Another problem in the data was a lack of knowing about the stability of the types on the callee side of a callsite. We relied on being able to infer them based on things we did know, or had inserted checks to guard against. However, what if we were just one more guard clause away from being able to inline something? Previously we could never determine that, so had to miss out on the opportunity. With better data, it would be possible to do better.

### Interruptions and stampedes

Spesh needed to interrupt the execution of the program twice for each frame it wished to optimize: once to parse the bytecode into the SSA CFG, insert the logging and produce a logged version of the code, and again after the logging to produce an optimized version of the code. This introduced pauses into the execution. So, every time spesh makes a program run faster, it has to do so sufficiently to overcome the time it stole to do its optimization work. And if it speeds something up that doesn’t get run much in the future, it can make the program slower overall.

This is pretty poor use of the parallel hardware available in pretty much all computers nowadays. Better would be to spend time doing the optimization work on a thread separate from the execution of the user’s program. This not only gets rid of the pauses; it also means that if the work is completed by the interpreter before the optimized version is ready then we didn’t slow the program down by stopping it to do optimization work that was never going to pay off anyway.

Having a thread taking care of specialization work can also resolve another problem. Imagine that a bunch of threads are set off executing the same code on a range of different data items (so, data parallelism). In this case, more than one thread could see that the code is hot, notice there’s not yet any specialization, and get to work on producing it. There was detection of any duplicate ones at installation time, but that still meant there was wasted work producing specializations. If 3 different threads wasted their time this way, then the amount of time before the specializer had paid for itself was also increased.

### A new approach to data collection

Clearly, there was plenty of room for improvement. It was fairly clear that having a better data model representing the execution of the program, which the specialier would use to make smarter decisions, was a key part of this. At the same time, it was important that threads executing user code didn’t spend much of their time building this. Ideally, they would just throw data into a sequential buffer, and toss it over to another thread – a specializer thread – when it was full.

So, that’s the direction I headed it. Each thread would log interesting events into a thread local buffer. The append-only and thread local (for writes) nature of it should make it fairly cache friendly. It was desirable that the entries were fairly small; the main place this had an impact was parameter type logging, where we both wish to log the container type and the type held inside of the container. This was taken care of by just writing two entries, rather than all the rest being padded out (fixed size entries weren’t all that important, I guess, but it did make things easier).

I converged on [this set of events in the log](https://github.com/MoarVM/MoarVM/blob/ece9788ee0a443d9a9572cface9fd18ca7d82fb8/src/6model/reprs/MVMSpeshLog.h#L4). It’s 24 bytes per entry, which isn’t too bad. One early mistake I made was logging invokes. I was keen that we start being able to inline calls to closures in the future, when it’s always the same code we call but with a different environment. So I logged the invoked code object, figuring the specializer thread could then pick the interesting parts out. This turned out to quite notably extend the lifetime of the closed over data, however. As the things we cared about were what code was invoked and whether the calling frame was also the outer frame, it was quite cheap to just extract those at the point of writing the log anyway.

The end result only logs references to static frames, types objects, and code objects where we’re told the result of the lookup can be cached because it will always be the same. It never logs values. This fixes an issue in the previous logging mechanism: during its 8 runs it would keep values alive for longer, and – much worse – if the 8 runs were never completed, it could keep them alive indefinitely. It was a bounded leak, but certainly one I’m glad to no longer have.

A hugely important part of the log is the correlation ID. This is a per-thread incrementing counter. It is bumped each time a frame is entered with logging turned on. It is then included in all events occurring within the execution of that frame. This allows the specializer thread to work out what events go with what code.

### The spesh worker thread

The spesh worker thread sits in a loop, reading a log from a blocking queue (meaning it waits in an efficient way, and – once the program has been fully specialized – just never gets woken up again). Once a thread running code fills up a log buffer, it sticks it into the blocking queue, the spesh worker receives it, and it gets to work. I’ll go through the various steps it takes later in this series; for today I’ll focus only on the first one (updating the statistics model, below) and what it does before going to wait for another data buffer.

To prevent runaway memory use if the threads running code are producing logs way faster than the specializer can make use of them, threads are given a quota of log buffers they are allowed to send. On sending, they decrement the quota. If it’s still greater than zero, then they allocate another log buffer and continue logging. Otherwise, logging is disabled for that thread. Once the specialization worker thread is done processing a buffer and acting upon its content, it increments the quotas. If it incremented it from zero, then it also installs a spesh log buffer for the thread, so it will continue logging.

### Nailing the main loop

This scheme almost worked out fine, but there was an awkward problem. If we weren’t logging at the point that the outermost frame of the program started running (perhaps because we were specializing bits of the compiler still), then the outermost body of the program wouldn’t get a correlation ID, and so wouldn’t log any events. This would be especially unfortunate, since the first thing people measuring performance tend to do is write a hot loop in the mainline of a program! (More usefully, any `raku -ne ...` invocation has the same kind of program structure.)

Thankfully, there was an easy way to deal with this: when we enter a new compilation unit for the first time, if there is no spesh log, then grant a temporary quota boost. Alternatively, if the log is almost full, then we send it off and then make a new one (with a quota boost if needed). This boost is temporary.

Every heuristic written with good intentions can go rogue, and this one is no exception: imagine a program doing a load of `EVAL`s. So, there is a fixed limit on how many times this quota boosting can happen, to ensure it handles the cases it is aimed at but doesn’t do harm.

### Building a model

Over on the specialization thread, the events are fed into a simulation that recreates something much like the call stack of the logged program, so it can understand the relationships between callers and callees. This produces a set of statistics, hung off each invoked piece of code (know as a “static frame” in MoarVM); doing it this way has the advantage that the statistics will be garbage collected should the code also be garbage collected (this can matter in `EVAL`-heavy programs).

One of the things I like most about this new approach is that, with the `MVM_SPESH_LOG` environment variable set to the name of a file to log to, the assembled statistical data will be dumped. This makes it possible to see the data being used to make decisions. Enough with me describing stuff, though: let’s see the stats! Here’s an example program:

```` raku
sub shorten($text, $limit) is export {
    $text.chars > $limit
        ?? $text.substr(0, $limit) ~ '...'
        !! $text
}
for ^10000 {
    shorten 'foo' x 100, (20..500).pick;
}
````

Here’s the statistics output after a while for the `shorten` sub:

````
Latest statistics for 'shorten' (cuid: 1, file: xxx.p6:1)

Total hits: 156

Callsite 0x7fdb8a1249e0 (2 args, 2 pos)
Positional flags: obj, obj

    Callsite hits: 156

    Maximum stack depth: 13

    Type tuple 0
        Type 0: Str (Conc)
        Type 1: Int (Conc)
        Hits: 156
        Maximum stack depth: 13
        Logged at offset:
            226:
                156 x type Int (Conc)
                156 x static frame 'chars' (4197) (caller is outer: 0)
                156 x type tuple:
                    Type 0: Scalar (Conc) of Str (Conc)
            260:
                156 x type Bool (Conc)
                1 x static frame 'infix:«>»' (2924) (caller is outer: 0)
                155 x static frame 'infix:«>»' (3143) (caller is outer: 0)
                156 x type tuple:
                    Type 0: Int (Conc)
                    Type 1: Scalar (Conc) of Int (Conc)
            340:
                91 x type Str (Conc)
                91 x static frame 'substr' (2541) (caller is outer: 0)
                91 x type tuple:
                    Type 0: Scalar (Conc) of Str (Conc)
                    Type 1: Int (Conc)
                    Type 2: Scalar (Conc) of Int (Conc)
            382:
                91 x type Str (Conc)
                        91 x static frame 'infix:<~>' (4223) (caller is outer: 0)
                        91 x type tuple:
                    Type 0: Str (Conc)
                    Type 1: Str (Conc)

Static values:
    - Sub+{<anon|77645888>} (0x2a70d48) @ 194
    - Sub+{<anon|77645888>}+{Precedence} (0x23a90c0) @ 288
````

From this we can see:

- It’s always called with two arguments
- Those are always a `Str` and an `Int` respectively
- We always pass a `Scalar` variable holding a `Str` to `chars`, and it always returns an `Int`
- We always pass an `Int` and a `Scalar` variable holding an `Int` to `>`, and it always returns a `Bool`
- When we call `substr` and `~` the type tuples and return values are also consistent

At compile time it was also worked out that some lexical lookups will always resolve to the very same object; the results of those have been logged also (the static values section), so the optimization process can elide the lookups and do further optimizations by knowing exactly what will be called. (The lookups in question are for the `>` and `~` operations, which are lexical, but in this case not overridden in a nested scope and so will come from the CORE setting.)

Here’s another example, this time for `chars`:

````
Latest statistics for 'chars' (cuid: 4197, file: SETTING::src/core/Str.pm:2728)

Total hits: 157

Callsite 0x7fdb8a124a00 (1 args, 1 pos)
Positional flags: obj

    Callsite hits: 157

    Maximum stack depth: 33

    Type tuple 0
        Type 0: Str (Conc)
        Hits: 1
        Maximum stack depth: 33

    Type tuple 1
        Type 0: Scalar (Conc) of Str (Conc)
        Hits: 156
        Maximum stack depth: 14
````

Here we can see that it was called once with a `Str` value, but a bunch of times with a `Scalar` holding a `Str`. Therefore, it’s worth producing optimized code for the latter case, but not worth bothering about the former.

### Clearing up

But what about all of the statistics we record on one-off cold paths, such as at startup? We’ll never do optimizations based on them, and so they’d just sit around using memory. Or what about after we’ve optimized a frame in all the needed ways, and it’s no longer logging new data? We don’t really need the statistics any more.

To alleviate this, each time a log buffer is received a statistics version number is incremented. The statistics are marked with the current version when updated. Any statistics that are not updated in a while will be presumed to be no longer interesting, and so thrown out.

### Debuggability

When I first mentioned moving specialization work off to its own thread on `#moarvm`, *brrt* (who leads development of the JIT) was immediately concerned about the unpredictability this would introduce. Threads are scheduled a bit differently between runs, which would make it a nightmare to reproduce and hunt down specializer and JIT compiler bugs, including using the bisection approach to work out exactly which specialization made things go wrong. It was an excellent point.

Therefore, I introduced the `MVM_SPESH_BLOCKING` environment variable. When set, a thread executing code will send off its log, and then block until the spesh worker thread has finished processing it and installing specializations. This means that, for a single threaded program, the behavior will again be fully deterministic.

### You won’t believe what happens next!

Alas, that’s all I’m covering this time. Next time, I’ll talk about how the statistics are used.
