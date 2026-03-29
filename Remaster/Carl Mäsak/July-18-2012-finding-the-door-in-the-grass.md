# July 18 2012 — finding the door in the grass
    
*Originally published on [19 July 2012](http://strangelyconsistent.org/blog/july-18-finding-the-door-in-the-grass) by Carl Mäsak.*

Many small commits went in today. First, I decided to fix the things that were
missing from yesterday:

- You can [take the rope and flashlight](https://github.com/masak/crypt/commit/9f3040392660ebf6cff869db5a1c9a54155c30c8) from the car.

- But [not without opening the car](https://github.com/masak/crypt/commit/a309abbc97c17956f8466c6bbbb69d8d19bd4aad) first.

Happy path, sad path, see?

- Also, you can [examine things in the car](https://github.com/masak/crypt/commit/4c6b7f1d52b17cb0b633fe56660ef91c68cf684c).

- `look` [includes the things in the room](https://github.com/masak/crypt/commit/b10aab3cfbaa975a0d3fab63c0dc5c1295b111a3).

Bit of a temp solution, and some duplication, but works for now.

- When you take something, [the game says you take it](https://github.com/masak/crypt/commit/42c3cf2bc1b712b4276b6a30e44b56edeaba6f96).

- Added [a quit message](https://github.com/masak/crypt/commit/21ccca88c2fe412957f027a7869c13da29a3ff5d), just like last year.

Therefore, now it looks like this:

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
> examine car
Small, kind of old, and beginning to rust. But it still gets you places.
> examine flashlight
You see no flashlight here.
> open car
Opening the car reveals a flashlight and a rope.
> examine flashlight
The flashlight, a trusty Flexmann 520, has been serving you for countless
adventures.
> take flashlight
You take the flashlight.
> quit
Thanks for playing.
```

The only small detail that's wrong now is that there should be a "custom
description" for the car, and the game should really say "Your car is parked
here." I have a plan for how to fix this. But not today. All in due time.

Now, what I *really* meant to do today was this:

- You can [open the door on the hill](https://github.com/masak/crypt/commit/50aeeb08534b73d37ffc12ba0fe6ce78b40887cc).
- But not without [first examining the grass](https://github.com/masak/crypt/commit/bb4788a700be527003a6223e6628793256c5d887) where the door is hidden.
- Or, as it happens, [the bushes](https://github.com/masak/crypt/commit/a2c7c9e5c574102eeabfae41b5c288b46aa188d4).
- Then, let's [open the door and walk through](https://github.com/masak/crypt/commit/dcd529a43f048194854113291357a99e38ca9326).
- But walking south is only supposed to work [if you open the door first](https://github.com/masak/crypt/commit/27722eec71fb8f5528f41aeb6e4809760c151792), silly.

Implementing this game is great; today more than previous days I'm feeling just
how great. The foundation I've built in the first part of the month is not just
suitable for building adventure games, it's *perfect*.  It's fantastic. Look at
this:

```raku
# Things on hill
.place_thing('grass', 'hill');
.make_thing_implicit('grass');
.place_thing('bushes', 'hill');
.make_thing_implicit('bushes');
.place_thing('door', 'hill');
.make_thing_openable('door');
.hide_thing('door');
.on_examine('grass', { .unhide_thing('door') });
.on_examine('bushes', { .unhide_thing('door') });
.on_open('door', { .connect(<hill chamber>, 'south') });
```

It's an adventure game world building API! (Yes, others will be able to take it
and run with it too, as long as I separate `Adventure::Engine` out into its own
module and publish it on [raku.land](https://raku.land)).

And not just that. The tests are wonderful, too!

```raku
my $game = Crypt::Game.`new`;
$game.open('car');
is $game.examine('flashlight'),
    Adventure::PlayerExamined.new(
        :thing<flashlight>,
    ),
    'examining the flashlight in the car';
```

I'm very happy about how this is turning out. All programming should be like
this.
