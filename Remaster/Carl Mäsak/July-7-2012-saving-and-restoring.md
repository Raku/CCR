# July 7 2012 — saving and restoring
    
*Originally published on [7 July 2012](http://strangelyconsistent.org/blog/july-7-saving-and-restoring) by Carl Mäsak.*

I'm a bit extremely tired today. So I'll make this a quick one, because it's
really easy anyway.

Today we're implementing `save`/`restore` functionality, so saving in the
clearing and then restoring from somewhere else takes you back from the
clearing.

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
> save
Game saved.
> east
Hill
A flat, broad hill interrupts the dense-ish forest here. Only grass and
small bushes grow on the hill.
> in
Chamber
This is a cramped space just inside the hidden opening in the hill. The
sun gets in enough to illuminate the place. There are some scribblings on
the wall.
> restore
Clearing
The forest road stops here, and the gaps between the trees widen into a
patch of un-forest. The sky above is clear apart from a few harmless clouds.
> quit
```

Saving and restoring is usually a pain in games, because you have to capture
all the game state and serialize it somehow. Since we're doing everything with
events, our job is easier. We just [save all the
events](https://github.com/masak/crypt/commit/02ca38f7d6a2cf7cf42a777922283455be157796),
put them somewhere, and when we want to restore the game, we apply all the
saved events on a fresh game engine.

(I didn't choose to save to file here, so a save doesn't persist between
program runs. However, it's the principle I want to show here, and messing with
files would mostly just hide the interesting bits.)

It's *very* important in an adventure game that when you restore you're not
left with extra items or lingering state somehow. This cannot happen in our
factoring, because everything is flushed and re-created from the event stream.
The game is literally replayed behind the scenes to the point where you saved.

And there we are. Good night. `:-)```
