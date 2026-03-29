# July 21 2012 — it's too dark in here!
    
*Originally published on [21 July 2012](http://strangelyconsistent.org/blog/july-21-2012-its-too-dark-in-here) by Carl Mäsak.*

Implementing flashlight/torch logic is straightforward but not without its
surprises. Nevertheless, I have two commits for you today as well.

- First, we [switched off the light](https://github.com/masak/crypt/commit/e90ce36e75c3d845951f22490e93c5dbfb8916cb) in the hall.

Now to get the flashlight to work.

- If the flashlight has been switched on, it should [light up the room](https://github.com/masak/crypt/commit/bc2bb141e7ea50a526db00736814d6d39c6f0d4e).

Actually, it's not that simple. The flashlight can be switched on because
it's a *light source*. And then it has to be actually on. And then it has
to be *in the room*, or in the player's inventory, which is conceptually
in the room, too. Finally we have to tell the game engine that `use` has the
particular meaning `switch on` for light sources. Phew!

I'm happy about today's harvest of events:

- `PlayerLookedAtDarkness```
- `RoomMadeDark```
- `PlayerUsed```
- `ThingMadeALightSource```
- `LightSourceSwitchedOn```

Very descriptive. Oh, and there should also be an exception `TooDark`, but
there's nothing in the hall yet to try it on. Will add it tommorrow.

I'm starting to suffer very slightly from scaling issues. The whole `bin/crypt```
file is now 2485 lines long, but that's partly because it contains
*everything*: game engine, crypt game, hanoi subgame, and tests for all of
them. So there's some splitting up to do before the month is over.

But there's also the fact that the `Adventure::Engine` class has 21 attributes,
which is a bit much. I suspect it could easily be given a few inner classes to
handle rooms and things separately, and that that would help combat the
monolithic list of attributes. Luckily, such a refactor will be very
straightforward, since we're not exposing any internals at all.

Tomorrow will be interesting &mdash; that's when we integrate the hanoi game we
wrote at the beginning of the month. I... I hope it fits in with the rest of
the game. 哈哈
