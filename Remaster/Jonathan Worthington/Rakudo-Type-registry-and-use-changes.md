# Rakudo: Type registry and 'use' changes
    
*Originally published on [13 January 2009](https://use-perl.github.io/user/JonathanWorthington/journal/38273/) by Jonathan Worthington.*

Since *pmichaud*++'s excellent branch of Rakudo refactors has been merged into trunk, I've been digging back in to my Hague Grant tasks. Me being, well, me, I'm behind schedule. Happily, this week I've got few other jobs on my plate to distract me and I'm hoping to get somewhat caught up. So, this should be the first in a bunch of posts this week about stuff that I'm working on. :-)

I'm happy to report that the first three tasks are now completed.

- Modifications to Rakudo actions/guts so that we registering classes, roles, subset types and routines in the namespace as we are compiling. These will be stub insertions that will be replaced by the Real Thing once we have it. - **Actually after discussion it didn't end up quite being done like this, but rather registering things in the compiler's internal symbol table. Of course, existing types are in the namespace though. Anyway, done.**
- Switching us to really do "use" at compile time; last time I tried this, it broke things in pre-compiled modules, but now this needs to be figured out properly. - **Well, we've switched. I think there may still be some problems to track down that affect November, but we are now doing use at compile time, at the point we encounter the directive.**
- Elimination of the hack that restricts us to using only type names that start with an uppercase character. - **Done. You can now write subs starting with uppercase letters and have them behave like subs, and classes/roles/enums/subset types with lowercase letters and have them behave like types.**

First I did a branch for the type registry stuff, which never did get merged, but served as a good "research project". I then cherry picked bits from it and did the final implementation directly in trunk, the final patch switching on the registry. No spectests have been regressed on, so I'm quite hopeful that November and other projects will see no regressions from this change.

Anyway, back to work and maybe more news later on today!
