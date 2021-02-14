# Rakudo switched over to QRegex
    
*Originally published on [2012-05-27](https://6guts.wordpress.com/2012/05/28/rakudo-switched-over-to-qregex/) by Jonathan Worthington.*

In my last post – just two days ago – I talked about how the work to [switch Rakudo over to using QRegex for parsing Raku source](https://6guts.wordpress.com/2012/05/26/switching-to-qregex-for-parsing-perl-6-source/) was going well. I guessed there was a 90% chance we’d land it well in time for the next release, hoping it would happen sometime in the next week.

Well, after a flurry of fixes and testing, with contributions from *moritz*++, *diakopter*++ and *tadzik*++, it landed today. We got to the point where the spectests showed up zero regressions, which was a very encouraging sign. Then, *tadzik*++ did a run of [Ementaler](https://github.com/tadzik/emmentaler) (automatic building and testing of all the modules) to see how module ecosystem had fared the transition. That caught one issue, which was easily fixed. After that…no regressions there either. And not only did we not regress on any spectests, but the improved LTM meant some previously failing spectests are now passing also.

So, it’s merged. NQP is now bootstrapped using a regex implementation written in itself, Rakudo now uses QRegex for parsing, and the next release will ship with it. And there’s still a good three weeks to go until the next release to tune it – and, of course, for plenty more general Rakudo development.
