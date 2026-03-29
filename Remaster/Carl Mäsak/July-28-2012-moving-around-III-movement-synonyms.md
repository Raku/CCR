# July 28 2012 — moving around III (movement synonyms)
    
*Originally published on [28 July 2012](http://strangelyconsistent.org/blog/july-28-2012-moving-around-iii-movement-synonyms) by Carl Mäsak.*

The game is finished. Now we're making it better. There's a lot of things to
make better.

Like,

- The [help text](https://github.com/masak/crypt/commit/dc328199a2a1cb6aefc3c3ae039b4b68b052378d).

- Writing [`n` instead of `north`](https://github.com/masak/crypt/commit/8325b8e6b8fddeff21b0d8059c13d81e30b9490c)

optionally with `go` or `walk` before it. That was today's task, as far as I can tell.
A disproportionately small one.

Oh, and just playing the game for a while, I noticed that I couldn't examine
things once I had taken them. So I [fixed
that](https://github.com/masak/crypt/commit/b8f270b6bab68a8332568b9f90250ba3c09e7dfa).
Speaking of which,

- There's now an [inventory
command](https://github.com/masak/crypt/commit/8d2d80880bc73bf110accc9cebccf89bed20d74f).

Ah, it's fun to be playing the game again.

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
> inventory
You are empty-handed.
> open car
You open the car.
Opening the car reveals a flashlight and a rope.
> take flashlight
You take the flashlight.
> take rope
You take the rope.
> inventory
You are carrying:
A flashlight.
A rope.
> quit
Thanks for playing.
```

There's still a few days left. I need as many people as possible to get in
there, play the game, and flush things out that are wrong or could be improved.
So if you have a few minutes, give the game a whirl. I'll do my best to fix
things quickly.

I'm sure there are bugs in there. [Help me find them](https://github.com/masak/crypt/)!
