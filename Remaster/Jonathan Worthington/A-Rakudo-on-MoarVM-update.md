# A Rakudo on MoarVM update
    
*Originally published on [2014-01-08](https://6guts.wordpress.com/2014/01/08/a-rakudo-on-moarvm-update/) by Jonathan Worthington.*

Almost exactly a month ago, I reported that [Rakudo on MoarVM could do “Hello, world”](https://6guts.wordpress.com/2013/12/07/a-few-quick-updates/). Despite the general slow-down as folks took Christmas and New Year breaks (myself very much included), progress has been very good. Here are the key things to know:

- All of the Rakudo sanity tests pass on Rakudo on MoarVM
- At present, Rakudo on MoarVM passes over **92%** of the specification tests that the current leader (Rakudo on the JVM) does
- We’re on course to have the January compiler release be the first Rakudo release with some level of MoarVM support; I’m hopeful we’ll be passing over 95% of the specification tests Rakudo on the JVM does by that point

The work has been taking place in the moar-support branch. We didn’t merge it yet, but that should happen within the next week or so.

MoarVM itself has been improving steadily, also. Here are a few of the features that have landed in the last weeks:

- Block exit handlers, used to implement LEAVE and friends
- Continuations, used to make gather/take properly lazy
- Updated the Unicode database to Unicode 6.3
- Sized native arrays
- State variables

However, another extremely important bit of work has been taking place that is focused on stability. *Nicholas Clark* has been conducting garbage collection torture tests, by now down to forcing a GC run every single object allocation and using memory protection to catch illegal accesses to moved objects. Most of the things we call GC bugs are not actually inside the garbage collector implementation, but rather are other places in the codebase where mistakes have been made that break invariants that must be upheld for the GC to do its job correctly. I’ve not been counting, but I’d estimate that a bit over a dozen bugs have been turned up by this work so far – bugs that would have been a real pain to find if they had just happened to crop up some weeks, months or years down the line in some user’s code. At this point, NQP can be built and tested under the toughest torture test that exists so far without showing any issues. The Rakudo build is the current torture subject. I’m incredibly happy this work is taking place; it means that by the time Rakudo on MoarVM starts getting used more widely, we can be reasonably confident that users are unlikely to run into GC-related issues.

So, what’s the path from here? Here’s what I’m hoping for in the coming month:

- We reach the point of passing more than 99% of the spectests that Rakudo on the JVM does
- Progress towards Panda being able to run and install some modules (not sure we’ll get all the way there, but I hope we’ll get reasonably close)
- Dealing the with very-slow-path signature binding. If you try anything on Rakudo on MoarVM, you’ll discover it’s slow. This is thanks to a hot path being implemented in a slow way, in the name of getting stuff correct before optimizing. As soon as we’re beyond the 99% point with the spectests, I’ll dig into this. It should make a dramatic difference. I’m aiming to do some work in this area to make things better for Rakudo on JVM also.
- Whatever fixes are needed to get the Rakudo build and sanity tests surviving the GC torture

I’ll be back with some updates in a couple of weeks, to let you know how we’re getting on. :-)
