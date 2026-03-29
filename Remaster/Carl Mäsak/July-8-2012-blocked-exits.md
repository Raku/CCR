# July 8 2012 — blocked exits
    
*Originally published on [8 July 2012](http://strangelyconsistent.org/blog/july-8-blocked-exits) by Carl Mäsak.*

I don't quite remember what I meant by "blocked exits" when I wrote the month
plan... But let's improvise! Way I see it, it can mean two things. So we'll do
them both today.

We're in a position where the game looks like this:

```
$ bin/crypt 
CRYPT
=====
You've heard there's supposed to be an ancient hidden crypt in these
woods. One containing a priceless treasure. Well, there's only one way
to find out...
Clearing
The forest road stops here, and the gaps between the trees widen into a
patch of un-forest. The sky above is clear apart from a few harmless clouds.
> quit
```

Oh, but first I just want to fix a thing that's starting to bother me.
(Itch-based programming for the win!) I don't see the possible exits, and so I
walk wrong and have to edit the game logs so you won't think my player is a
drunken idiot. Let's [add
exits](https://github.com/masak/crypt/commit/c9841be088255a1177857b370645cf1e0562aded).

```
$ bin/crypt 
CRYPT
=====
You've heard there's supposed to be an ancient hidden crypt in these
woods. One containing a priceless treasure. Well, there's only one way
to find out...
Clearing
The forest road stops here, and the gaps between the trees widen into a
patch of un-forest. The sky above is clear apart from a few harmless clouds.
You can go east.
> east
Hill
A flat, broad hill interrupts the dense-ish forest here. Only grass and
small bushes grow on the hill.
You can go west and south.
> south
Chamber
This is a cramped space just inside the hidden opening in the hill. The
sun gets in enough to illuminate the place. There are some scribblings on
the wall.
You can go north and south.
> south
Hall
It's hard to believe that this kind of room can fit under a hill. It's tall,
long, and quite spacious. Hieroglyphs adorn all four of the walls. The
floor slants a bit.
You can go north and down.
> down
Cave
This is a perfectly cylindrical chamber. An oversized fire-pit takes up most
of the floor space in the middle of the room. Ancient runes run along the
circumference of the wall. It's hot and stuffy.
You can go up and northwest.
> northwest
Crypt
The air is stale and smells a bit metallic. Three impenetrable sarcophagi
sit next to each other on the floor. On the walls are numerous finely
inscribed ideograms.
You can go southeast.
> quit
```

That's better.

The first kind of "blocked exit" we have is that we're not supposed to be able
to just walk into the crypt. In the last year's game, there was an
`on_try_exit` hook method that got the last word on whether you could really
take that exit, returning `True` or `False` as appropriate. (So the exit is
*there*, and you can see it, but you may not be able to take it.)

That still sounds like a rather good approach, so let's [do it that
way](https://github.com/masak/crypt/commit/6759b92a4a9e0fb8a56a2821e9f663c007761e98).
We haven't started talking about *things* at all yet, so let's just forbid that
exit unconditionally for now. And come back and fix it later when we can have
nice things.

```
$ bin/crypt
CRYPT
=====
You've heard there's supposed to be an ancient hidden crypt in these
woods. One containing a priceless treasure. Well, there's only one way
to find out...
Clearing
The forest road stops here, and the gaps between the trees widen into a
patch of un-forest. The sky above is clear apart from a few harmless clouds.
You can go east.
> east
Hill
A flat, broad hill interrupts the dense-ish forest here. Only grass and
small bushes grow on the hill.
You can go west and south.
> in
Chamber
This is a cramped space just inside the hidden opening in the hill. The
sun gets in enough to illuminate the place. There are some scribblings on
the wall.
You can go north and south.
> south
Hall
It's hard to believe that this kind of room can fit under a hill. It's tall,
long, and quite spacious. Hieroglyphs adorn all four of the walls. The
floor slants a bit.
You can go north and down.
> down
Cave
This is a perfectly cylindrical chamber. An oversized fire-pit takes up most
of the floor space in the middle of the room. Ancient runes run along the
circumference of the wall. It's hot and stuffy.
You can go up and northwest.
> northwest
You try to walk past the fire, but it's too hot!
> quit
```

The second thing we'll be doing today is to [block the entry to the
chamber](https://github.com/masak/crypt/commit/776705280972db51c456bdaafa766295d9295090).
It's supposed to be triggered by a door being opened. Again, we don't have
doors yet, because we don't have things yet. So we just remove that exit for
now.

```
$ bin/crypt
CRYPT
=====
You've heard there's supposed to be an ancient hidden crypt in these
woods. One containing a priceless treasure. Well, there's only one way
to find out...
Clearing
The forest road stops here, and the gaps between the trees widen into a
patch of un-forest. The sky above is clear apart from a few harmless clouds.
You can go east.
> east
Hill
A flat, broad hill interrupts the dense-ish forest here. Only grass and
small bushes grow on the hill.
You can go west.
> quit
```

The world just shrank quite a bit. Feels kinda weird.

For the next *week* (wow!) we'll be implementing the foundations for things,
and then we'll start putting them in the game itself. Apparently things will be
on our mind.
