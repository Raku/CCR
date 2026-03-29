# July 27 2012 — triggering doom and dying
    
*Originally published on [28 July 2012](http://strangelyconsistent.org/blog/july-27-2012-triggering-doom-and-dying) by Carl Mäsak.*

While we did build the machinery for triggering delayed cavern collapse
yesterday (which due to general lateness is already day-before-yesterday;
sorry), there's still a matter of hooking things up so that the cavern
actually collapses right on top of the hapless adventurer.

Talk about a sad path. 哈哈

I thought I might as well add the conditions for winning while I'm at it.
This has always been my favorite part of crypt. Even though it's a
straight-out-of-Indiana-Jones kind of cliché. There's only one item heavy
enough to replace the butterfly on the pedestal... and it comes from the Hanoi
subgame, a source of inventory that the player is likely to overlook.

So, today's commits:

- If you take the butterfly from its pedestal, you [trigger the alarm](https://github.com/masak/crypt/commit/cf18e6e8b457feb3a459fd9f5e45d3e93a08673f)

And you have three moves to get out. Walking is a move. You're four rooms
in.

- So you panic for three moves and then [you die](https://github.com/masak/crypt/commit/acf6aefb87d17bdd0f0c346f43251f6191067ae9).

- Alternatively, you can go [get the tiny disk](https://github.com/masak/crypt/commit/07222ec4f5360b67bde31915e854359b5167cb9b) from the Hanoi game.

Note how the tiny disk is essentially created out of
thin air as we attempt to take it from the game. On second thought, this is
a bit *too* magical; I might just put them in a special Hanoi container
instead. But this was a fun way to do it. :)

- Finally, you [replace the butterfly with the disk](https://github.com/masak/crypt/commit/e3b2633181a2e2f02592496304ce55a559521fb1)

Emerge from the cavern, and win the game. Yay!

Well, that's it. You can now play through the whole game and even win it. At
least the tests claim you can; I haven't played the game through the CLI for
quite some time now. 哈哈

The next few days will go to various cleanup, adding conveniences (such as an
inventory, or verb synonyms), and generally refactoring the game and making it
nicer, shorter, and more future-proof.

The game is about 3k lines long now, by the way. Compare against last year's
game: 1k lines. Also compare against the biggest Raku source file I know
(STD.pm6): 6k lines. This is a fairly big project. Adventure games are complex
stuff.

According to tomorrow's schedule &mdash; today's schedule, that is &mdash; I'll
be adding movement synonyms. I'll probably do that and a few other cleanups.
