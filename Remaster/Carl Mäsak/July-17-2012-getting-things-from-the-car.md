# July 17 2012 — getting things from the car
    
*Originally published on [17 July 2012](http://strangelyconsistent.org/blog/july-17-2012-getting-things-from-the-car) by Carl Mäsak.*

Having created enough of the game engine, I now have a very pleasant DSL-like
thing in which to write crypt. Today in my commits I could write

```raku
.place_thing('car', 'clearing');
```

And then

```raku
.place_thing('flashlight', 'contents:car');
.place_thing('rope', 'contents:car');
.make_thing_openable('car');
```

This is much nicer than last year. And more flexible, as I hoped.

I found that in last year's game, I can examine the flashlight (which is in the
car), even without opening the car and revealing the flashlight. Now, you might
say, maybe the car has windows, but that wasn't the intent. I consider it a
bug, caused by hard-to-follow placement logic. Let's do better this year.

- We [put a car in the clearing](https://github.com/masak/crypt/commit/4eab8bbaf4e2163845c9800d7f7a4656b92e6174).

Bam! Ain't that cute?

- In relation to this, I [discovered and fixed a bug](https://github.com/masak/crypt/commit/fd3ee8ce59c858f6ef3972741997a38a3c20d967) having to do with programmer (my) confusion about when events are applied.

Some tests
failed because the game reported the things from the *last* room when walking from one
room to another. Yes, this happens because of my factoring with events. I'm not
completely used to it yet, it seems. Anyway, thank you, extensive test suite.

- Now we put the flashlight and the rope in the car

And make them [be revealed when
we open it](https://github.com/masak/crypt/commit/ae59ad95036c014d42b1539d0283eb1d18356b46).

- I make sure that a `look` command [reveals the insides of things](https://github.com/masak/crypt/commit/ae59ad95036c014d42b1539d0283eb1d18356b46)

For example the car.

- Then I make sure `examine` [works from the CLI](https://github.com/masak/crypt/commit/37e0d351574801f1c95a54aab50602aca02f6238)

And that when you open things, the CLI [says what, if anything, is
inside](https://github.com/masak/crypt/commit/afd7967d5792f7fae0e3705594bf4198e98ea525).

That's it for today. So what does the game look like now?

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
> examine car
Small, kind of old, and beginning to rust. But it still gets you places.
> examine flashlight
You see no flashlight here.
> open car
Opening the car reveals a flashlight and a rope.
> examine flashlight
You see no flashlight here.
> take flashlight
Sorry, I did not understand that.
> quit
```

Well, we're not repeating last year's error, for sure. But the last two
responses are wrong. Also, the car should appear in the description of the
room. Let's fix all those things tomorrow.
