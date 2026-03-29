# July 19 2012 — filling your car with leaves
    
*Originally published on [20 July 2012](http://strangelyconsistent.org/blog/july-19-filling-your-car-with-leaves) by Carl Mäsak.*

Started out the day with having to fix up crypt, because updating and
installing latest Rakudo as part of releasing it earlier this evening
apparently pulled in a change that broke stuff.

Oh well. A little reminder that the spectests don't protect against anything.

Anyway, today's job: making it possible to put leaves into the car.

```
<jnthn> WHY...do you put leaves in a car?!
<masak> it's completely useless.
<masak> but it works!
```

Actually, I remember the thrill of putting in this message last year. Making
adventure games is very much about anticipating things the player might try,
even silly things. When putting the leaves in the car, the player gets the
message `"Great. Now your car is full of leaves."` as if this was an especially
silly thing to try. Which it is, of course.

So, two steps to make this work:

- You can [take the leaves](https://github.com/masak/crypt/commit/009372068ab4f87b6443b598b5e458ca67161550) over at the hill.

- You can [put them in the car](https://github.com/masak/crypt/commit/867e41d17a0cbe17d2aabbc6ad27a88e686da0b7)

And the player will open the car if it isn't open already, put the leaves in,
and the game will give its remark.

The last one led to a new event class `Adventure::GameRemarked` &mdash; thanks
for naming suggestions, *jnthn*++ &mdash; and to a new hook method `on_put`.
Notice that containers and platforms share the same `on_put` mechanism. That
seemed appropriate.

So here's what we can do now:

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
There is a car here.
You can go east.
> east 
Hill
A flat, broad hill interrupts the dense-ish forest here. Only grass and
small bushes grow on the hill.
You can go west.
> take leaves
You take the leaves.
> west
Clearing

> put leaves in car
You open the car.
You put the leaves in the car.
Great. Now your car is full of leaves.
> quit
Thanks for playing.
```

Yay!

Hm, there's an extra newline in there after going back west to `Clearing`. Will
fix that tomorrow. A perfectionist never rests.
