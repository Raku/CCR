# Lexicals have arrived
    
*Originally published on [25 November 2008](https://use-perl.github.io/user/pmichaud/journal/37943/) by Patrick Michaud.*

Earlier today I *finally* got lexicals to work properly in Parrot (and Rakudo).  This means that recursion now works properly, as do a whole host of other things.  It resulted in closing at least eight tickets in the Rakudo and Parrot RT trackers, and we're still looking to see how many spectests it enables.

We're still missing list interpolation, list assignment, and a few other basic things, but lexicals support was a big blocker for many things we've wanted to do.  I'm glad it's finally done.

Many thanks to (irc nicks)  jonathan, infinoid, masak, moritz, particle, bacek, chromatic, rgrjr, Tene, tewk, allison, and many others who helped with debugging and testing.
