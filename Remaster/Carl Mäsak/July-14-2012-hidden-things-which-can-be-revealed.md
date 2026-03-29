# July 14 2012 — hidden things which can be revealed
    
*Originally published on [14 July 2012](http://strangelyconsistent.org/blog/july-14-2012-hidden-things-which-can-be-revealed) by Carl Mäsak.*

So, here's the idea: there's no door in sight, but when you examine the grass,
the door suddenly appears! Well, it was there all the time, but you couldn't
*see* it until you went examining something else nearby.

So, we want to be able to

- place objects,
- tell them to disappear,
- and then bind some logic into examining other objects that will...
- ...tell them to re-appear.

The first feature is already in place. The second feature means we want a
`hide_thing` method and an `X::Adventure::NoSuchThingHere` exception when we
examine a hidden object.

The third feature means we want an `on_examine` method to hook arbitrary logic
into examining objects. And the fourth feature means we want a an
`unhide_thing` method which causes the object to appear and be examinable.

Taking a step back, we have a situation with two actors here: the adventure
game itself, and the player. The adventure game is always aware of objects,
even when they are hidden. But to the player it should appear as if... well it
shouldn't appear, basically. "Invisible" is what we're after here. Though
"completely transparent to player actions" probably captures the intent even
better. The game should play dumb and go "door? what door?".

Let's begin.

- I realized that I wasn't disallowing looking, examining, putting, and reading before the player has been placed somewhere.

So [I did
that](https://github.com/masak/crypt/commit/1744ffdb7e7b52ec1ddddfd174761ca3ab2c8196).
Undertested so far, but I'd rather have the checks in for now.

- Next up, [implement `hide_thing`](https://github.com/masak/crypt/commit/2bfc22dac7e42e059867fceac82577e820dad715)

Test it by trying to examine the hidden thing and failing.

- In fact, you [can't open hidden things either](https://github.com/masak/crypt/commit/20e37abd5b01b6aa535114255f73fe31eb398e56).

So there.

- Finally, we unhide a door by hooking up examining some grass to the door
being unhidden.

Then we [examine the grass and try to open the door](https://github.com/masak/crypt/commit/51ce8171d8dc4a80a4436599bbdcf9587be167df).
It works!

Another day's work done.

I just realized that the `on_try_exit` and `on_examine` methods are outside of
the whole event system. I don't really know what to think about that. Maybe it
will become a pain point, maybe not. We'll see.

Anyway, the whole model is deepening day by day. This is nice. We're growing a
game here.
