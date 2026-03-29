# July 26 2012 — doom and cavern collapse
    
*Originally published on [27 July 2012](http://strangelyconsistent.org/blog/july-26-2012-doom-and-cavern-collapse) by Carl Mäsak.*

If there is one thing I regret from the design of last year's game, it's making
`Doom` a thing.

Now, `Doom` was simply what killed you in the game. It was the only thing that
could kill you, in fact. But it wasn't really a *thing* in the game. You
couldn't pick it up, or see it. It wasn't anywhere. It just killed you. But at
that point, I had already created separate classes for most things in the game
to give them special behaviors, so creating yet another class for a *non*-thing
felt bad, but not very bad.

This year, I'm doing it right. In case you were wondering.

"What's right?" I hear you ask. What's right is a factoring which doesn't need
to put this functionality on an object, but just allows the game engine to
carry out what `Doom` used to do. Which, if we look at it, was three things:

- [End the game](https://github.com/masak/crypt/commit/f5c6aa34e8e2973eefd157c2348bb6ba84f6ddb1)...

- ...[after N turns](https://github.com/masak/crypt/commit/d6f6977816eb76dc0722e070e0b6fd7c5416f49f)...

(N is 3 in crypt)

- ...unless [the danger is averted](https://github.com/masak/crypt/commit/f8718d1d2ceec763ef0709476d90ecf927e7c675).

The interesting new technology here is *fuse hooks*, delayed actions which you
put into the game as closures. Other kinds of hooks go off when things are
handled in certain ways; fuse hooks go off after a given number of *ticks*
&mdash; discrete player actions.

Unless the game engine decides to defuse the fuse hook, in which case it never
goes off.

Note; this kind of factoring of things feels entirely natural and in line with
the rest of the design. I'm happy.

I ran to jnthn (on IRC), waving my arms enthusiastically and shouting "closures
are awesome because they give downstream the freedom to supply arbitrary code,
while giving upstream the freedom to choose when to invoke it!" jnthn said
everyone already knows this. So, um, well. OK. 哈哈

Anyway, we're well positioned to implement the last room of the game tomorrow.
Then the rest is just polishing and refactoring.

*A hat tip to *lue*++ who contributed [a failing test](https://github.com/masak/crypt/commit/bcff5bfaf658265634e9a41986770fd8bf90373a)
today. lue, [your test now passes](https://github.com/masak/crypt/commit/999dfc8571f7c69ae33af86775f00630faad365d)*
