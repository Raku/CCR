# This week: concurrency stuff, multi-dimensional stuff, stuff stuff…
    
*Originally published on [2015-07-22](https://6guts.wordpress.com/2015/07/23/this-week-concurrency-stuff-multi-dimensional-stuff-stuff-stuff/) by Jonathan Worthington.*

Finally, I got a week of peaceful hacking time at home and not-too-bad health, and so Stuff Got Done. Here’s what.

### Progress on multi-dimensional arrays

Last time, I’d gotten decent support into MoarVM for multi-dimensional arrays (including packing natively typed values into a single piece of memory), and had started on porting this functionality to the JVM. This week, I finished that JVM porting work. Doing something for the second time is often pretty good at showing up things you didn’t think through well enough the first time. In doing the port, I thought up a couple of tests I’d not written on MoarVM that would be explodey, or faily, or otherwise unhappy – and found one that I’d written that really didn’t make a lot of sense. So I wrote some extra tests, fixed things, and we now have MoarVM and JVM equipped with the guts needed to dig into implementing multi-dimensional arrays at the Raku level.

### Concurrency thinking and tooling

I did two interesting things relating to Raku’s concurrency support, both of which are interesting to discuss a little.

For a while, I’ve known that our syntactic relief for concurrent programming needed some attention. For one, our `await` keyword – so far implemented as the simplest possible thing – does not offer the semantics that would make it genuinely powerful. If you await a `Promise` today, you block the waiting thread until it’s ready. Sure, it’s a kernel-supported, OS-scheduler-efficient blocking, not busy waiting, but it still swallows one of the thread pool’s threads – which are real OS threads. And that makes it impossible to have many thousands of start blocks “active” and awaiting something to happen in order to make progress. What we want is for an `await` in a `start` block scheduled on the thread pool to return control to the thread pool, so the OS thread can be used for something else. Then, once the `Promise` being waited on reaches some conclusion, the rest of the `start` block is scheduled for resumption. That was always my vision for it, but until now I never got around to defining the API through which that happens, let alone implementing it. This week I tackled the API design part of the job. I’ll work on the implementation in the coming weeks.

Next in line were supplies. I like where we’ve gone with them so far, but working with them is very much an exercise in functional programming. It’s a bit like not having for loops and if statements, and having to write everything with map and grep. You can certainly do it, but plenty of normal people find code written that way harder to follow. Heck, some of the less-normal folks like me recognize that some solutions just read better when they’re more imperatively specified. I’ve been pondering this for a while. I really want the asynchronous aspects of Raku to be accessible, and I really want people to be able to write operations that combine many asynchronous data sources – including time – without epic functional contortions. Having done my share of teaching Rx.Net, I’ve had plenty of chance to see people grapple with asynchronous data using an API a lot like we have for supplies. When there’s a nice built-in that does Just What You Want, it works out great. But sometimes there’s not, and you have to get creative, and then the result tends to feel clever rather than clear.

So, I also proposed some syntactic relief for working with supplies. It comes in two parts: `supply { … }` blocks for constructing supplies, and an asynchronous looping construct called `whenever` that works with it. So far, feedback has been positive; *Larry* said it looked sane, and other responses ranged from approving up to excited. So, it’s looking promising.

I didn’t update S17 yet, but rather [wrote my proposals in a gist](https://gist.github.com/jnthn/a56fd4a22e7c43080078), which has all of the details.

The second big thing I did this week was work on a MoarVM bytecode instrumentation that can identify when one thread writes to an object that was created by another thread while not holding a lock. While there are of course patterns where you can legitimately do such a thing, they are the exception rather than the norm – and so having a tool that tells you when such things happen can help identify bugs. I wrote it to help me get a better insight into some of the threading bugs we have in the RT queue. It’s turned on by setting an environment variable, and it instruments bytecode (using the same approach the profiler does) to detect and record such cross-thread writes. It was also [not a lot of code to implement](https://github.com/MoarVM/MoarVM/blob/master/src/instrument/crossthreadwrite.c), which I guess is good news on MoarVM’s architecture. And yes, there are sophisticated data race detection algorithms out there, but they’d all take a good bit more work to get in place (maybe some day in the future, I’ll take this one). For now, this first, simplistic, approach should help us hunt down a bunch of issues.

### Meanwhile, in regex land…

I was active in the regex engine again.

- Fix RT #125608 (Longest Token Matching did not factor in the first branch of a sequential alternation)
- Verify RT #125391 (order of zero-width delimiters in .caps) already fixed and write a test for it
- Fix RT #117955 (quantified captures only captured last items when used in a conjunction)
- Investigate ways to deal with RT #67128 (calling another grammar); discussion, prototype a fix, find it needs lang design input

### Better errors

This week had its share of improved failure modes and better feedback, to enhance Raku user experience.

- Fix RT #125595 (improve error reporting on bad loop specification, in line with STD)
- Fix RT #125600 (good error message for running a directory, plus make sure we report such issues on STDERR)
- Fix RT #115398 and RT #115400 (give good error with location info on trying to parameterize a non-parametric type)
- Fix RT #125591 (failed to detect various mis-uses of `$.x` and `$!x` in signatures at compile time)
- Fix RT #125625 (misleading/malformed error for useless accessor method generation with `my $.a` and `our $.a`)
- Fix RT #125620 (gist method on custom exceptions with no message method would crash)

### Other assorted bits

As usual, there are a few other small things I did that are worth a quick mention:

- Fixing MSVC MoarVM build after an otherwise-good patch busted it
- Fix a `Proc::Async` test file for Windows and add it to those we run
- Fix RT #124121 (using `but` for role mixins with `Array` literal did the wrong thing, plus bad behavior with `List`)
- Implement `does` trait on variables (resolves RT #124747)
