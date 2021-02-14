# Those weeks: much progress!
    
*Originally published on [2015-09-30](https://6guts.wordpress.com/2015/09/30/those-weeks-much-progress/) by Jonathan Worthington.*

This post is an attempt to summarize the things I worked on since the last weekly report up until the end of last week (so, through to Friday 25th). Then I’ll get back to weekly. :-)

### GLR

The Great List Refactor accounted for a large amount of the time I spent. Last time I wrote here, I was still working on my prototype. That included exploring the `hyper` / `race` design space for providing for data parallel operations. I gave an example of this in my recent concurrency talk. I got the prototype far enough along to be comfortable with the API and to have a basic example working and showing a wallclock time win when scaling over multiple cores – and that was as far as I went. Getting the GLR from prototype mode to something others could help with was far more pressing.

Next came the long, hard, slog of getting the new `List` and `Array` types integrated into Rakudo proper. It was pleasant to start out by tossing a bunch of VM-specific things that were there “for performance” that were no longer going to be needed under the new design – reducing the amount of VM-specific code in Rakudo (we already don’t have much of it anyway, but further reductions are always nice). Next, I cleared the previous list implementation from CORE.setting and put the new stuff in place, including all of the new iterator API. And then it was “just” a case of getting the setting to compile again. You may wonder why getting it to even compile is challenging. The answer is that the setting runs parts of itself while it compiles (such is the nature of bootstrapping).

Once I got things to a point where Rakudo actually could build and run its tests again, others felt confident to jump in. And jump in they did – especially *nine*++. That many people were able to dive in and make improvements was a great relief – not only because it meant we could get the job done sooner, but because it told me that the new list and iterator APIs were easy for people to understand and work with. Seeing other people pick up my design, get stuff done with it, and make the right decisions without needing much guidance, is a key indicator for me as an architect that I got things sufficiently right.

Being the person who initially created the GLR branch, it was nice to be the person who merged it too. Other folks seemed to fear that task a bit; thankfully, it was in the end straightforward. On the other hand, I’ve probably taught 50 Git courses over the last several years, so one’d hope I’d be comfortable with such things.

After the merge, of course, came dealing with various bits of fallout that were discovered. Some showed up holes in the test suite, which were nice to fill. I also did some of the work on getting the JVM backend back up and running; again, once I got it over a certain hump, others eagerly jumped in to take on the rest.

### GLR performance work

After landing the GLR came getting some of the potential optimizations in place. I wanted a real world codebase to profile to see how it handled things under the GLR, rather than just looking at synthetic benchmarks. I turned to Text::CSV, and managed a whole bunch of improvements from what I found. The improvements came from many areas: speeding up iterating lines read from a file, fixing performance issues with flattening, improving our code-gen in a number of places… There’s plenty more to be had when I decide it’s time for some more performance work; in the meantime, things are already faster and more memory efficient.

### S07

I also did some work on [S07](http://design.raku.org/S07.html), the Raku design document for lists and iteration. I ended up starting over, now I knew how the GLR had worked out. So far I’ve got most of the user-facing bits documented in there; in the coming weeks I’ll get the sections on the iterator API and the parallel iteration design fleshed out.

### Syntactic support for supplies

At YAPC::Asia I had the pleasure of [introducing the new `supply` / `react` / `whenever` syntax](http://jnthn.net/papers/2015-yapcasia-concurrency.pdf) in my presentation. It’s something of a game-changer, making working with streams of asynchronous data a lot more accessible and pleasant. Once I’d had the idea of how it should all work, getting to an initial working implementation wasn’t actually much effort. Anyway, that’s the biggest item ticked off my [S17 changes list](https://gist.github.com/jnthn/a56fd4a22e7c43080078).

### Other concurrency improvements

A few other concurrency bits got fixed. RT #125977 complained that if you sat in a tight loop starting and joining threads that themselves did nothing, you could eat rather a lot of memory up. It wasn’t a memory leak – the memory was recovered – just a result of allocating GC semispaces for each of the threads, and not deallocating them until a GC run occurred. The easy fix was to make joining a thread trigger a GC run – a “free” fix for typical Raku programs which never touch threads directly, but just have a pool of them that are cleaned up by the OS at process end.

The second issue I hunted down was a subtle data race involving closure semantics and invocation. The symptoms were a “frame got wrong outer” on a good day, but usually a segfault. Anyway, it’s gone now.

Last but not least, I finally tracked down an issue that’s been occasionally reported over the last couple of months, but had proved hard to recreate reliably. Once I found it, I understood why: it would only show up in programs that both used threads and dynamically created types and left them to be GC’d. (For the curious: our GC is parallel during its stop the world phase, but lets threads do the finalization step concurrently so they can go their own way as soon as they get done finalizing. Unfortunately, the finalization of type tables could happen too soon, leaving another thread finalizing objects of that type with a dangling pointer. These things always sound like dumb bugs in hindsight…)

### Fixed size/shaped arrays

Work on fixed size arrays and shaped arrays continued, helped along by the GLR. By now, you can say things like:

```` raku
my @a := Array.new(:shape(3,3));
@a[1;1] = 42;
````

Next up will be turning that into just:

```` raku
my @a[3;3];
@a[1;1] = 42;
````

### Preparing for Christmas

With the 6.christmas release of the Raku language getting closer, I decided to put on a project manager hat for a couple of hours and get a few things into, and out of, focus. First of all, I wrote up a list of [things that will explicitly not be included in 6.christmas](https://gist.github.com/jnthn/040f4502899d39b2cbb4), and so deferred to a future Raku language release.

And on the implementation side, I collected together [tickets that I really want to have addressed in the Rakudo we ship as the Christmas release](https://rt.perl.org/Ticket/Display.html?id=123766). Most of them relate to small bits of semantic indecision that we should really get cleaned up, so we don’t end up having to maintain (so many…) semantics we didn’t quite want for years and years to come. Having compiler crashes and fixing them up in the next release is far more forgivable than breaking people’s working code when they upgrade to the next release, so I’m worrying about loose semantic ends much more than “I can trigger a weird internal compiler error”.

### The `is rw` cleanup

One of the issues on my Christmas list was getting the `is rw` semantics tightened up. We’ve not been properly treating it as a constraint, as the design docs wish, meaning that you could pass in a value rather than an assignable container and not get an error until you tried to assign to it. Now the error comes at signature binding time, so this program now gives an error:

```` raku
sub foo($x is rw) { }
 foo(42); # the 42 fails to bind to $x
````

### Error reporting improvements

I improved a couple of poor failure modes:

- Fix RT #125812 (error reporting of with/without syntax issues didn’t match if/unless)
- Finish fixing RT #125745 (add hint to implement `ACCEPTS` in error about ~~ being a special form)
- Remove leftover debugging info in an error produced by MoarVM

### Other bits

Finally, the usual collection of bits and pieces I did that don’t fit anywhere else.

- Test and look over a MoarVM patch to fix VS 2015 build
- Reject RT #125963 with an explanation
- Write response to RT #126000 and reject it (operator lexicality semantics)
- Start looking into RT #125985, note findings on ticket
- Fix RT #126018 (crash in optimizer when analysing attribute with subset type as an argument)
- Fix RT #126033 (hang when result of a match assigned to variable holding target)
- Reviewing the gmr (“Great Map Refactor”) branch
- Fix crash that sometimes happened when assembing programs containing labeled exception handlers
- Review RT #125705, check it’s fixed, add a test to cover it. Same for RT #125161.
- Cut September MoarVM release
- Hunt JIT devirtualization bug on platforms using x64 POSIX ABI and fix it
- Tests for RT #126089
- Fix RT #126104 (the `is default` type check was inverted)
- Investigate RT #126029, which someone fixed concurrently; added a test to cover it
- Fix RT #125876 (redeclaring $_ inside of various constructs, such as a loop, caused a compiler crash)
- Fix RT #126110 and RT #126115.
- Fixed a POST regression
- Fix passing allomorphs to native parameters and add tests; also clear up accidental `int` / `num` argument coercion and add tests
- Fix RT #124887 and RT #124888 (implement missing `<.print>` and `<.graph>` subrules in regexes)
- Fix RT #118467 (multi-dispatch sorting bug when required named came after positional slurpy)
- Looking into RT #75638 (auto-export of multis), decided we’d rather not have that feature; updated design docs and closed ticket
- Investigate weird return compilation bug with JIT/inline enabled; get it narrowed down to resolution of dynamics in JIT inlines
- Fix RT #113884 (constant scalars interpolated in regexes should participate in LTM)
- Investigate RT #76278, determine already fixed, ensure there is test coverage
