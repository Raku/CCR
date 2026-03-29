# July 6 2012 — room descriptions (look)
    
*Originally published on [6 July 2012](http://strangelyconsistent.org/blog/july-6-room-descriptions-look) by Carl Mäsak.*

Now that we have the mechanical underpinnings for connecting rooms the way we
want, let's [connect all the
rooms](https://github.com/masak/crypt/commit/262cd871708df58ea91b3c81b828fb050e59a255)
in the entire dungeon. The game is not really this simple, but being able to
walk between all the rooms will serve us well today.

Oh, and the CLI should really [announce the
rooms](https://github.com/masak/crypt/commit/e478ae2393329b113606eea037562ddce66e15fd)
as we enter them, so that we know where we are.

Does it work? Well, have a look for yourself:

```
CRYPT
=====
You've heard there's supposed to be an ancient hidden crypt in these
woods. One containing a priceless treasure. Well, there's only one way
to find out...
Clearing
> walk east
Hill
> walk in
Chamber
> walk south
Hall
> walk down
Cave
> walk northwest
Crypt
> walk southeast
Cannot walk southeast because there is no exit there.
> quit
```

So we can walk all the way into the dungeon... but when we try to turn around
and go back, we get a disappointing "no exit there" error.

Why? Well, we haven't made room connections bidirectional yet. [Let's do
that](https://github.com/masak/crypt/commit/9a7f528d5b92e1659cfa32c12f43a9b21581a6cf).

Now we can walk into the crypt, and then back out again.

```
$ bin/crypt
CRYPT
=====
You've heard there's supposed to be an ancient hidden crypt in these
woods. One containing a priceless treasure. Well, there's only one way
to find out...
Clearing
> walk east
Hill
> walk in
Chamber
> walk south
Hall
> walk down
Cave
> walk northwest
Crypt
> walk southeast
Cave
> walk up
Hall
> walk north
Chamber
> walk out
Hill
> quit
```

But I'm getting tired far too fast of having to write `walk` all the time. So
we [allow an abbreviated
way](https://github.com/masak/crypt/commit/a9c83c02de04f9604e4eb7a5dead4e5c5e148b7d)
to write this. More abbreviations to come, of course.

```
CRYPT
=====
You've heard there's supposed to be an ancient hidden crypt in these
woods. One containing a priceless treasure. Well, there's only one way
to find out...
Clearing
> east
Hill
> west
Clearing
> quit
```

It works. Nice.

Finally, we make the adventure engine [automatically `look` at new
rooms](https://github.com/masak/crypt/commit/8896863e9baa0130977bad88c65106e58dd95cef)
(whether we walk into them or are transported there). And then we make the CLI
[print descriptions when we
look](https://github.com/masak/crypt/commit/1c7f6e2f38bba5261ecba4d3e6f9be50b1106088).
(Only when doing this last commit did I notice that I had accidentally removed
the `look` command earlier in the commit history. Well, now it works again, and
without a special case.) We also add in all the room descriptions from last year.

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
> east
Hill
A flat, broad hill interrupts the dense-ish forest here. Only grass and
small bushes grow on the hill.
> in
Chamber
This is a cramped space just inside the hidden opening in the hill. The
sun gets in enough to illuminate the place. There are some scribblings on
the wall.
> south
Hall
It's hard to believe that this kind of room can fit under a hill. It's tall,
long, and quite spacious. Hieroglyphs adorn all four of the walls. The
floor slants a bit.
> down
Cave
This is a perfectly cylindrical chamber. An oversized fire-pit takes up most
of the floor space in the middle of the room. Ancient runes run along the
circumference of the wall. It's hot and stuffy.
> northwest
Crypt
The air is stale and smells a bit metallic. Three impenetrable sarcophagi
sit next to each other on the floor. On the walls are numerous finely
inscribed ideograms.
> quit
```

So, it's all starting to look like an adventure game. We can walk around and
look at stuff.

Tomorrow we'll add save/restore functionality to the game. This is wonderfully
easy because we're basing our whole design on serializable events.
