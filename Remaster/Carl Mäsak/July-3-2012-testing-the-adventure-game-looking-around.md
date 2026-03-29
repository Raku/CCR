# July 3 2012 — testing the adventure game, looking around
    
*Originally published on [3 July 2012](http://strangelyconsistent.org/blog/july-3-testing-the-adventure-game-looking-around) by Carl Mäsak.*

Let's write an adventure game. Again. ☺

We can start by [writing a command
loop](https://github.com/masak/crypt/commit/247f52c0bc26534d372b4211050f146bc739cdef).
It's a reduced version of the loop we wrote yesterday for the Hanoi game.

```
$ bin/crypt 
CRYPT
=====
You've heard there's supposed to be an ancient hidden crypt in these
woods. One containing a priceless treasure. Well, there's only one way
to find out...
> look 
Sorry, I did not understand that.
> quit
```

Neat. But the game doesn't understand `look` yet. We need to do something about
that. Time to write our first test.

We [implement
looking](https://github.com/masak/crypt/commit/c848fd4cfe1ffabf0deb16c46ac7a173c7feec5b).
See how easy it is. (Yes, we are hardcoding things when we can get away with
it. But that's OK; then we'll need to write tests to make sure they can
change.)

Now we [hook looking into the command
loop](https://github.com/masak/crypt/commit/2efa9e7e9b6a61e994ea7cdbba8dfbc99f55b053).

Now this happens:

```
$ bin/crypt 
CRYPT
=====
You've heard there's supposed to be an ancient hidden crypt in these
woods. One containing a priceless treasure. Well, there's only one way
to find out...
> look
<clearing>
> quit
```

Well, it works, but... we have some presentation issues. Last year we added a
file `descriptions` with text descriptions of everything. Let's [do that
now](https://github.com/masak/crypt/commit/a36b8dd89fce10613c0aaf75e21636cf06fd1a3d),
and plug it into the `PlayerLooked` event.

Now things look like this:

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
> quit
```

We're off to a good start.

Some observations: notice how we're following a model-view kind of thinking
here. The `Crypt::Game` class is the model, and our ``MAIN`` method is a view.
We don't bother the model with the actual descriptions of things; these end up
in the view.

I was a bit hesitant in making `PlayerLooked` an event. It felt like looking
might be a "pure" operation without side effects. Then I remembered that
sometimes in the game looking *does* have side effects. So it definitely
belongs there. If looking didn't have side effects, we might handle looking
entirely in the ``MAIN`` method. But I think I prefer it this way.

Ok, that's it for today. Tomorrow we'll add walking around to our repertoire.
