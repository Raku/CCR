# July 15 2012 — things which can be carried around
    
*Originally published on [16 July 2012](http://strangelyconsistent.org/blog/july-15-2012-things-which-can-be-carried-around) by Carl Mäsak.*

I thought these days of game engine implementation would be tedious, but it
turns out there are lots of interesting design questions lurking in here.
That's extra true for today's material, which is a bit late, but hopefully only
fashionably so.

We'll be occupying ourselves with the actions `take` and `drop` today. For this
purpose, we'll be introducing a new category of things: *carryable* things.
Only these can be picked up. (Oh, and "pick up" will end up being a synonym for
"take" in the game.)

Internally, taking something will amount to moving it to a special room called
"player inventory". Someone could theoretically add such a room to their
adventure game, and objects would magically appear there as they were taken by
the player. This is considered a feature, not a bug.

Let's see what the commits look like today.

- We start out as usual.

A player [can take
things](https://github.com/masak/crypt/commit/819d4aaadccced9f75dad59f9edbcd952eeabf02).

- But [only if the things are carryable](https://github.com/masak/crypt/commit/9a88a7ff57537a5cd1fa89c3ba26e9ed67af1611).

Right?

- I then back-port this carryability restriction to [putting things](https://github.com/masak/crypt/commit/a09a7a141729b575044ee296b93f2aa7b5b5135d)

As I realize that putting something is tantamount to taking it and dropping it in or
on some container or platform.

- What's the easiest way in a BDD setting to check that something was successfully picked up?

Well, you [can't take something
twice](https://github.com/masak/crypt/commit/08ad1f3e30fe3e11d02dbf7e6ec818f27721fffc),
so that's an excellent test.

- Realized that I hadn't required the player to be located somewhere before starting to take stuff

So I [added
that](https://github.com/masak/crypt/commit/f03f3ca205c09c563573d78bb469012f9d93cf17).

- Implemented [dropping things](https://github.com/masak/crypt/commit/a0b45bb49c6dab13cbe1302c021950ba92f88277).

Notice that, as usual, the game engine doesn't care about actually carrying out
the event until that's necessary for validation. This keeps us more honest with tests.

- Oh, and of course you can't drop something [that you're not holding](https://github.com/masak/crypt/commit/bfdb3509216407c9dfbd1a338815a0ba621efcdf).

That's just common sense.

- Here's the check that dropping actually works.

We know that taking works, because we
have a test against taking stuff twice. So we can make sure that dropping works
properly by [taking, dropping, and
taking](https://github.com/masak/crypt/commit/e831985429b53dfff1a8b100f892b5b2d1422b94)
something. This is quite possibly the most fun test I've ever written.

Taking and dropping form some kind of "complementary actions". They cancel each
other out in some way. This leads to fun interactions between their behaviors.
Maybe that's why there were a few more commits today than usual. Anyway, a nice
surprise that their behavior was so rich. I don't recall thinking as deeply
about this last year. Events seem to really bring out thinking about the
semantics of actions.

There are many ways to factor the internals, but in this case creating a
"player inventory" room and just shoving things there seemed like the simplest
thing that could possibly work. And, since they're *internals*, in some sense
it really doesn't matter if we cheat ourselves blue in there. We can always
change the internals, as long as the tests still work.

Tomorrow &mdash; really today because I'm late &mdash; is the last day of game
engine hacking. After that we'll start putting together the actual crypt game
in earnest.
