# This month’s Rakudo Star release – and what’s coming next
    
*Originally published on [2012-01-29](https://6guts.wordpress.com/2012/01/29/this-months-rakudo-star-release-and-whats-coming-next/) by Jonathan Worthington.*

So, we made it – a [Rakudo Star release](http://rakudo.org/2012/01/28/rakudo-star-2012-01-released/) based on the “nom” development branch has landed. It’s based on the compiler release *moritz*++ cut earlier this week, and *pmichaud*++, *masak*++ and myself have been involved in getting the Star-specific build and installation scripts in shape.

Getting to this release has been a lot of work; in many sense this is a revolution in Rakudo’s development rather than a small evolutionary step over what we had before. It’s taken a while (indeed, longer than I’d first hoped) and has been a lot of work – but it was worth it. Not just because of the many improvements that are in this release, but because of the enormous future potential that we now have.

Here’s some of the things I’m happiest about in the release.

- The performance improvements in many areas. Yes, we’ve plenty of work to do here – but this is a solid step forward for a wide range of scripts, and in some cases an order of magnitude improvement.
- That 6model – something I started designing a year and a half ago – has not only cleanly supported all of the things we needed to do in Rakudo, but also opened up so many other doors. For example, the new NativeCall module uses its representation polymorphism support to great effect.
- Protoregexes doing real NFA-driven Longest Token Matching rather than the cheating version we had before that only operated on literals.
- The optimizer, along with the various extra compile time error reporting it gives. This will be an important future area for Rakudo.
- Initial native type support, and bigint semantics for the Int type.
- The POD6 support, thanks to *tadzik*++’s Google Summer of Code grant in summer.

So, what’s next? Currently I’m working hard on getting true bounded serialization support in place. This should further improve `BEGIN` time support (including constructs that depend on `BEGIN` time), greatly cut down resource consumption during CORE.setting compilation (both time and memory) and give us faster startup. It’s hard to guess at figures for the improvement, but I’m expecting it to be a noticeable improvement in all of these areas. I’m aiming at getting this landed for the next Rakudo compiler release (which I expect us to do a Star release based on too), though largely it depends on whether I can get it working and stable enough in time; while some parts are a simple matter or programming, other parts are tricky.

That aside, we’ve already got various other new features in the pipeline; even since last weekend’s compiler release, there are multiple new regex-related things in place, *moritz*++ has continued with his typed exceptions work, we’re catching a couple more errors at compile time rather than letting them slip through until runtime, and there’s various other miscellaneous bug fixes. Also, *masak*++ is working on macros in a branch, and I’m optimistic that we’ll have some initial macro support in place by the next release also. Busy times! :-)
