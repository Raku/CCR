# July 25 2012 — putting out the fire
    
*Originally published on [26 July 2012](http://strangelyconsistent.org/blog/july-25-2012-putting-out-the-fire) by Carl Mäsak.*

I got a nice email today.

```
Date: Wed, 25 Jul 2012 10:54:09 -0600
Message-ID: <CA+0_sj5kWQYV35jGosyWjbCUKMCXrtOj=6r34qT6bhnH7VRWkw@mail.gmail.com>
Subject: crypt test cases with water
From: Bruce Armstrong <...>
To: cmasak@gmail.com
Carl,
  I've been following your crypt game with interest.  It has been thought provoking.
Today's post brought out the tester in me and I have a few sad path tests that
unfortunately complicate things.
Water is not a normal object, but it is treated as such, so currently...
You can take water without a helmet.
Once taken, the water is gone
You can put the water in the car and pick it back up again
It has been fun to read these posts.  I thank you for writing this all up and look
forward to seeing how you handle these and other conditions that come up.
```

Well, I thank *you*, dear tester! Your submissions entered into the [growing
list of ways to mess with the game](http://gist.github.com/masak/3034482), thus
making you eligible for the [promised Amazon book](Another-month-of-blogging-adventure-game-here-i-come.html).

Also, I took the time to fix the bugs you discovered:

- You [can't pick up the water with your hands](https://github.com/masak/crypt/commit/d51648ba83db766b610d6c2af9fd9f5e45793d9b) anymore.

Just like last year's version. (This commit contains an ugly fix. I need to introduce
sagas to make this nicer. But not today.)

- You [can put water in your car](https://github.com/masak/crypt/commit/59cb5dfade5fe8eaccef6ff8d45e28966312ebe7), but all that happens is it gets wet.

The middle bug, "Once taken, the water is gone", is really the core issue, as I
see it. Water isn't so much a "thing" as it is a "mass noun", and you should be
able to have as many of it as you like in different places of the game. The
game engine is not happy with such multi-location objects right now. Rather
than address the problem head on, I went with last year's solutions. If it
turns out that this becomes a pain point, I might evolve a more permanent
solution.

Now, let's move on to today's commits:

- You can [put out the fire](https://github.com/masak/crypt/commit/00f8e1f6943229fb99b07f7a15a6afe0e4343ec0) with a bit of water.

Oh, you're supposed to be able to put the water *on* the
fire too, with the same effect. Forgot about that. Will get to it tomorrow.

- Once the fire is put out, you can [walk into the crypt](https://github.com/masak/crypt/commit/772c8d83b737623b92b3b2ef4098b691aef37f55).

Well, that was easy. It feels like the game engine mostly has what I need now,
and I can just make method calls and it obeys. A nice feeling overall. The game
engine is in for a number of overhauls, though. I'll get to them as stuff
settles down. Good thing I have a test suite. 哈哈

Tomorrow we'll grab the treasure from the crypt, trigger total cavern collapse,
and die. It'll be fun.
