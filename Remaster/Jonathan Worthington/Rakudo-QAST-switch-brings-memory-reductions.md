# Rakudo QAST switch brings memory reductions
    
*Originally published on [2012-07-29](https://6guts.wordpress.com/2012/07/29/rakudo-qast-switch-brings-memory-reductions/) by Jonathan Worthington.*

In my [previous post](https://6guts.wordpress.com/2012/07/20/the-rakudo-move-to-qast-progressing-nicely/) I mentioned that the work to get Rakudo using QAST was going nicely. QAST is a refreshed abstract syntax tree design and implementation, written in NQP (the Raku subset we write much of Rakudo in) instead of PIR. I’m happy to say that this work has now been merged into the mainline Rakudo and NQP branches, and thus will be included in the next release. There were no spectest regressions, and just one module needed updating (and that’s because it was using a Parrot-specific construct that has got a bit stricter; all of the other pure Raku modules were fine) As part of this work, POST – a much simpler and more low level tree that gets transformed into Parrot Intermediate Code – has also been replaced.

One of the goals of this work was to reduce memory consumption during compilation, especially of CORE.setting. The results on this front look pretty good. Exact numbers vary depending on 32-bit vs 64-bit and other details. I’ve seen various numbers flying around on channel that all suggest a notable improvement; better still, *nwc10*++ took a moment to take some decent measurements before and after and from them it seems we’re looking at something around a 37% reduction in memory consumption during compilation of CORE.setting compared to the previous release. Since we use the standard Raku compiler to compile the setting, this means the improvement applies to compilation of scripts and modules in general.

While I was fairly comfortable I could get memory usage down some amount, I was a bit concerned that we may take a speed hit. I mean, this work has involved re-writing a bunch of code written in low-level PIR into rather higher level NQP. That carries obvious risks of a slow down – especially since NQP currently lacks an optimizer. Happily, though, we’ve actually got a little bit faster at compilation. This is thanks to more efficient data structures (of note, using natively typed attributes), the AST being a little better angled towards the needs of Raku compilation, and through an implementation that learned from PAST compilation profiles. The most dramatic speedup was to the optimization phase, which now completes in a third of the time it used to! The gains in other phases are much, much more modest, but it’s still movement in the right direction in a project that carried a real risk of a regression speed wise.

While this work has been merged, this isn’t the end of the road for QAST-related tasks. Here’s what I will be looking at from here, both in time for the August release and probably a bit beyond that:

- Getting inlining of routines back in place; this is a re-implementation rather than an update. Happily, the re-implementation will be much, much cleaner and should allow for better inlining support. This is currently top of my todo list, so should be in place in the next couple of days.
- Some more optimizations here and there, which should get us some more (albeit probably relatively smaller) wins in memory usage and speed.
- Getting NQP switched over to using QAST.
- Giving NQP natively typed variables, which should let us write a bunch of code more efficiently in the compiler.
- Giving NQP an optimizer, which should hopefully get us some more speed wins.

In other exciting news, the arrival on QAST means *masak*++ is digging into taking macros some steps further. Maybe there’ll be something nice there for the next release too. :-)
