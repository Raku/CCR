# November 2, 2008 — one step forward, two steps back
    
*Originally published on [3 November 2008](http://strangelyconsistent.org/blog/november-2-2008-one-step-forward-two-steps-back) by Carl Mäsak.*

Twenty years ago today, the [Morris worm](http://en.wikipedia.org/wiki/Morris_worm), was launched from MIT. Never meant to cause any serious harm, it nevertheless had a massive effect on the Internet at that time, got a lot of media attention, and resulted in the convicion of its inventor. The Wikipedia article explains:

> The critical error that transformed the worm from a potentially harmless intellectual exercise into a virulent denial of service attack was in the spreading mechanism. The worm could have determined whether or not to invade a new computer by asking if there was already a copy running. But just doing this would have made it trivially easy to kill; everyone could just run a process that would answer "yes" when asked if there was already a copy, and the worm would stay away. The defense against this was inspired by Michael Rabin's mantra, "Randomization." To compensate for this possibility, Morris directed the worm to copy itself even if the response is "yes", 1 out of 7 times. This level of replication proved excessive and the worm spread rapidly, infecting some computers multiple times. Rabin remarked when he heard of the mistake, that he "should have tried it on a simulator first."

Those were more innocent times indeed. Nowadays, worms and botnets are a global phenomenon, and a lucrative business for those not encumbered by a conscience.

&#x2766;

Today I've been submitting bug reports and making the occasional patch to Rakudo, but it didn't feel big enough for a good deed. Thus I turned to November, and brought the `mediawiki-markup` branch up to speed. I was going to start actually implementing stuff when I ran `./test_wiki.sh` and got the error "Unrecognized directive: TMPL_VAR".

The offending statement was [this one](http://github.com/viklund/november/tree/43ac68be3d1dc1959aebf78018694ea052cb092b/p6w/HTML__Template.pm#L40), which of course should never die with that error message, by the rules of basic logic.

This is something that worked before. A regression in Rakudo. And dang, it affects the `master` branch as well. (Of course.)

So, I worked around that, adding another '# RAKUDO' comment. But the time spent for actual coding was used for tracking down this error, so actual improvements will have to wait till another day. Report from the front: everything takes at least twice as long as you'd expect, [even when you're prepared for exactly that](http://en.wikipedia.org/wiki/Hofstadter's_law).
