# July 30 2012 — tying up various loose ends
    
*Originally published on [31 July 2012](http://strangelyconsistent.org/blog/july-30-2012-tying-up-various-loose-ends) by Carl Mäsak.*

Seems I was wise enough to plan a day or two of general cleaning up at the end
of this month. I'm making good use of those days now.

I'm now idly playing the game, finding stuff that comes up wrong, and fixing
them. The number of things I'm finding tells me there aren't enough of you
trying the game out and finding stuff. I encourage you to try it; the game is
complete now, and all the bugs you find are trophies you can carry with pride.

Today's work:

- Made the hanoi game [actually exist in the adventure game](https://github.com/masak/crypt/commit/3aadbbfecbd721fe8827db2faf6858c50dc0ba37).

Should've done this from the beginning. Makes the boundary between the
contexts cleaner.

- Tried out the hanoi game on the CLI, and found a few bugs, [which I fixed](https://github.com/masak/crypt/commit/e67c6b00aee6042606eee62662a20096f5e6a5b5).

- Noticed that you can't unlock the hanoi achievement by placing the tiny disk on the right rod, something that should clearly work.

[Fixed
that](https://github.com/masak/crypt/commit/8a48e3600e7901dc9f76810a551a80303c2d0777).
(Yes, I had this issue in the hanoi game itself, and now I had it again. I
could have avoided the repeat by implementing sagas, I think. But I haven't yet.)

- I got "You already have the tiny disk" after taking, putting back, and attempting to take the tiny disk again.

Seems there was an event applier
missing in `Adventure::Engine`. [Fixed
that](https://github.com/masak/crypt/commit/a561385dae8270acb9f113ad3395b262ce89b239).

- Another embarassing one: I put the tiny disk on the pedestal... and the hanoi game state gets printed.

[Fixed that
too](https://github.com/masak/crypt/commit/f98518be7936ea8234b5ec5571e5ffc9ef364467).
Apparently, I suck at programming.

- Didn't get any feedback when putting the tiny disk on the pedestal and avoiding certain doom.

[Fixed
that](https://github.com/masak/crypt/commit/236f76eaec337bc111ab1507ddff6163df05bd81).

- Finally, [the CLI should exit](https://github.com/masak/crypt/commit/5e290dd3b77338e13d576492f72fe915a548b738) when the game finishes.

Now it does.

I can also happily report that I've played the whole game through on the CLI.
So has *lue*++. So should you.

I meant to split the different parts of the game into modules today. But I'm
out of time, so I'll do that tomorrow instead. In the meantime, find bugs and
report them to me. I know you want to.
