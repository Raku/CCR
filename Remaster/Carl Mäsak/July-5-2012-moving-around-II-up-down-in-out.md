# July 5 2012 — moving around II (up/down, in/out)
    
*Originally published on [6 July 2012](http://strangelyconsistent.org/blog/july-5-moving-around-ii-up-down-in-out) by Carl Mäsak.*

First, by request, I'm [implementing
'help'](https://github.com/masak/crypt/commit/42e66425fb83f4eb2cce4ddbe5d5215b5163ed82)
in the game. (*seldon*++) Better sooner than later, I guess.

```
$ bin/crypt
CRYPT
=====
You've heard there's supposed to be an ancient hidden crypt in these
woods. One containing a priceless treasure. Well, there's only one way
to find out...
> help
Here are some (made-up) examples of commands you can use:
look
[walk] north/south/east/west
> quit
```

I'll make sure to keep the help message up-to-date as I add functions to the
game.

I [implemented the up/down
directions](https://github.com/masak/crypt/commit/aedec5ff877878172219b58b43422f5eadd36c2b).
As part of this, because it was easier to test it that way, I cleared up the
misplaced 'clearing' initialization from yesterday. This quite naturally
required the new event `Adventure::PlayerWasPlaced` (for giving the player an
initial position) and `X::Adventure::PlayerIsNowhere` (for trying to move when
this wasn't done). Things are in the right place now and everyone's happy.

Hm, it also means I just implemented a teleportation mechanism! Probably not
such a bad idea for a general adventure game. Though I won't need it in Crypt.

[Implementing
in/out](https://github.com/masak/crypt/commit/1e9e0cfc887b7975119ed0df1223b3e05d38892e)
is a little more involved, since we're now out of primary directions. The
compass directions and up/down are all primary directions. "In" and "out" are
just aliases for one of those. So we wire up the event
```rakuAdventure::DirectionAliased` which lets us call some of the existing
directions "in" or "out".

None of this actually allows us to play the game any further. So it's a good
thing I implemented 'help' so I have something to show today apart from passing
tests!

Also, note that I'm quite aware that connections are not yet two-way. They
should be. That is, when we connect 'clearing' to 'hill' in the east direction,
then 'hill' should also connect to 'clearing' in the west direction. We'll need
this soon, maybe as soon as tomorrow.

Anyway, tomorrow we'll tackle room descriptions in earnest. Probably I'll add
all rooms in one go, and make sure walking between them works.
