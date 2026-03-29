# July 4 2012 — moving around I (compass directions)
    
*Originally published on [4 July 2012](http://strangelyconsistent.org/blog/july-4-moving-around-i-compass-directions) by Carl Mäsak.*

We learned to see (`look`) yesterday, but what about moving around (`walk`)?

```
$ bin/crypt
CRYPT
=====
You've heard there's supposed to be an ancient hidden crypt in these
woods. One containing a priceless treasure. Well, there's only one way
to find out...
> look     
The forest road stops here, and the gaps between the trees widen into a
patch of un-forest. The sky above is clear apart from a few harmless clouds.
> walk east
Sorry, I did not understand that.
> quit
```

Aww, that's not much fun! Let's fix that!

I'm doing this as I go along; I haven't prepared much before. That means that
sometimes I realize a bunch of stuff as I code. I prefer that; means things are
still fresh for me to explain. But it also means sometimes I change things back
and forth as I try for the best way to factor things. I pray your indulgence.

Anyway, taking a step back to design and language for a while:
  
> The player can **walk** in our adventure game, because we have a concept of **rooms**, each one having zero or more **exits** connecting to other rooms. We talk about **connecting** two rooms to give them exits to each other. Rooms can also be **disconnected**. Rooms and their connections form a sort of topology, a graph on which the player moves. The topology may change during the course of the game, as rooms connect to and disconnect from each other.

So, we implement [connecting two
rooms](https://github.com/masak/crypt/commit/0e3976e9f5ae622e4b3c4d662f1d59be4b7ddd59);
feels like a good start. And of course, you're not allowed to [use directions
that don't
exist](https://github.com/masak/crypt/commit/e0290f34333d4ff2cddeac09cf450bc2dd24c8ee).

Note that in our script, we make a distinction between `Crypt::Game` and
`Adventure::Engine`. The former is the actual crypt game, with its various
puzzles and descriptions; the latter is a general adventure game engine, which
handles regular things such as connecting rooms and walking. `Crypt::Game```
actually wraps `Adventure::Engine` and delegates some commands directly to
it (such as walking), but completely hides other commands (such as connecting
rooms). This division feels like it makes a lot of sense. (Essentially it
also means that as the month draws to an end, we could separate out the
```rakuAdventure::Engine` parts and publish them on modules.raku.org. Not that I
want to give any of you any ideas.)

Anyway, now we can [implement
walking](https://github.com/masak/crypt/commit/4b468fb3606bffe1f15dd1e9bb88101427d748ce).
And, as usual, we don't just think "happy path", but make sure [walking doesn't
work without an
exit](https://github.com/masak/crypt/commit/6dc36736bfbefda2ad41e09f035ba1d4926d42cb).

The `Crypt::Game` class now has a `BUILD` method that sets things up using
```rakuAdventure::Engine`. The idea is that this is how you "configure" an adventure
game; in the `BUILD` method. We'll see how that works out in practice.

(Actually the biggest point of cheating I introduced today was this line in the
above commit:

```raku
has $!player_location = 'clearing';
```

The problem with it is that it is in `Adventure::Engine`, which is the wrong
context for that initialization to be in. (Not all adventure games start in a
clearing.) I'll fix that in the next few days.)

And then we need to do one more thing to make `walk` work in the actual game.
We need to [bind CLI commands to method
calls](https://github.com/masak/crypt/commit/457e63f913a539b3f7e991c2736627fbe180e859).
Yes, I adapted that bit from the Hanoi game.

And lo, walking now works!

```
$ bin/crypt
CRYPT
=====
You've heard there's supposed to be an ancient hidden crypt in these
woods. One containing a priceless treasure. Well, there's only one way
to find out...
> walk south
Cannot walk south because there is no exit there.
> walk east
> quit
```

We would really like to get automatic descriptions when we walk into new
places. We'll handle that (*me checks schedule*) day after tomorrow. But note,
we *didn't* get an error message from walking east, which is exactly what we
wanted. (Because there is an exit east from the clearing to the hill.)

Just one last thing today. Have a look at what happens if I...

```
$ bin/crypt
CRYPT
=====
You've heard there's supposed to be an ancient hidden crypt in these
woods. One containing a priceless treasure. Well, there's only one way
to find out...
> walk east
> walk east
> walk east
> quit
```

Yeah, um. You might actually look at that output and figure out what's wrong.
Then again, you might not.

We only added one connection, between `clearing` and `hill`. Going east a
second time should blow up on us. *Unless*... unless the player position never
gets updated.

What do we do when finding something like this? We [add a failing test case and
make it
pass](https://github.com/masak/crypt/commit/4d8064f7a7bc76861c94f4e44128abd9cb26dcd4).

Yay!

That's it for today.
