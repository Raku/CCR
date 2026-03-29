# July 22 2012 — playing the Hanoi game
    
*Originally published on [23 July 2012](http://strangelyconsistent.org/blog/july-22-2012-playing-the-hanoi-game) by Carl Mäsak.*

I felt a curious lack of energy today, on the day when it was time to do the
important merge of the Hanoi subgame (developed on the first two days of this
month), and the bigger adventure game (developed since then).

Nevertheless, I made it, though admittedly I haven't tested it much, and pieces
are missing. Hey, the tests pass! The rest will have to come piece by piece
later.

(Mostly what's missing is actually hooking up all the nice `Hanoi::` event
types to the CLI so that it can tell the player what's going on. Oh, and
parsing commands correctly on the CLI. That's missing, too.)

Here's what happened today:

- Playing around with the game, I noticed that the hall was still lit.

[Fixed
that](https://github.com/masak/crypt/commit/647e1b7f056acf06f01aa782c3705f3e1ffbc9ce).
It was a rather large fix because I realized I had a bug in the "is there a light
source here" logic &mdash; ultimately caused by assuming the wrong location
of the player because of not-yet-applied events. (Tricky, that one!)

- Oh, and no-one had disconnected the chamber and the hall by default

So I [did
that](https://github.com/masak/crypt/commit/875023b9db7a389967621e2af38f62f761e2649e)
too before I started with today's real hacking.

- Now, I [hooked up the CLI](https://github.com/masak/crypt/commit/532054147e50b56a98ab0899fbf40e513cc4f20b) to show the Hanoi game whenever the player is in the hall.

This required
lifting the Hanoi game drawing logic out of the `Hanoi::Game` class into its
own subroutine. No big deal.

- Then it was time to [put the Hanoi game in Crypt](https://github.com/masak/crypt/commit/1a921765e3db2a77b98d1a2e6ff9ab24245edb60).

This was the most hair-tearing commit I have made this month. I ended up choosing
the least painful of a number of painful options. `Crypt::Game` has to intercept
events that move the player from `Adventure::Engine`, in order to correctly forbid
the player from playing the Hanoi game outside of the hall.

I'll have more to say about this factoring in the next few days. I'm glad it
worked out, and as far as I can see it will work very well for what we want.

Note that we got our first crypt-specific exception with this:
`X::Crypt::NoDisksHere`, which happens when you try to play Hanoi outside of
the hall. It clearly belongs in the crypt domain, and not the adventure domain
(which doesn't know about Hanoi) or the Hanoi domain (which doesn't know about
player locations).

See you tomorrow, when we will play with fire a bit.
