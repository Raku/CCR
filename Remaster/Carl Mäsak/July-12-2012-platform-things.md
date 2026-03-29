# July 12 2012 — platform things
    
*Originally published on [13 July 2012](http://strangelyconsistent.org/blog/july-12-2012-platform-things) by Carl Mäsak.*

After sending off yesterday's post, I realized that I didn't have a sad-path
test for putting containers inside themselves.

Then I got to thinking how last year's game handles this. I gave it a whirl:

```
> put helmet in helmet
You put the helmet in the helmet.
```

OMG it worked!

But the funny thing isn't that this impossible act of self-containment is even
possible, but that later when I look at the room, the helmet is *gone*. So,
where is it? In itself, apparently. It's like the helmet now forms its own
little isolated universe, containing only one item: a helmet.

Or, more succinctly, I suck at programming. `:-)```

jnthn suggested I fix it in this year's game by throwing the exception
`X::Adventure::YoDawg`. [I
oblige](https://github.com/masak/crypt/commit/71900d3fe6283d37abdd63661840fcc8578bb9a0).

It's still possible to screw things up with some patience and two portable
containers, I guess. What we really need to guard against are arbitrary cycles
of containership. (Oh you silly adventure gamers!) I can't just forbid
higher-level containers, because it's entirely in order to put a helmet full of
water in the car, for example. Anyway, we'll solve the general case when we
need to. It'll be fun.

This wasn't at all what I was supposed to be doing today. I was supposed to
create platforms. Now, if containers are things you put other things *in*, then
platforms are things you put other things *on*. That was the design I ended up
with last year, and I think it'll hold up even this year.

From the point of view of the game, even platformhood is a kind of containment
relation, actually. A butterfly on a pedestal works much like a butterfly in a
car. So I can mostly just copy the tests that apply from yesterday, and make
them work:

- You can [put things on things](https://github.com/masak/crypt/commit/f125f79284baf33c2696f762115f82404f0e0dad).

(And I discovered that an event was unfortunately named.)

- But only [if the latter is a platform](https://github.com/masak/crypt/commit/6d2119f9f9d0678f78b0bc28f2406c6ce642bd80).

That's nice. But we also need to protect about the 'yo dawg' situation with
platforms. Otherwise we might get turtles all the way down. We [re-use the
`X::Adventure::YoDawg```
exception](https://github.com/masak/crypt/commit/576954e2faa792bb82329f313f1f503561ed8c52)
for this.

And we're done for today. Tomorrow we're gonna learn how to read.
