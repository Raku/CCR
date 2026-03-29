# Where in the sky
    
*Originally published on [21 September 2016](http://strangelyconsistent.org/blog/where-in-the-sky) by Carl Mäsak.*

Our 1.5yo has a favorite planet. By a long margin, it's Mars.

I've told him he's currently on Earth, and shown him where, and he's OK with that. Mars is still the favorite. Earth's moon is OK too.

Such an interest does not occur &mdash; pun not intended &mdash; in a vacuum. We have a book at home (much like [this one](https://www.amazon.com/National-Geographic-First-Space-Little/dp/1426310145/), but a different one, and in Swedish), and we open it sometimes to admire Mars (and then everything else). 

But what really left its mark is the Space Room in our local [Tekniska Museet](https://www.tekniskamuseet.se/) &mdash; a complete dark room with projectors filling a wall with pictures of space. Using an Xbox controller, you decide where to fly in the solar system. If anything, this is what made Mars real for our son. In that room, we've orbited Mars. We've stood on its surface, looking at the Mars moons in the Mars sky. We've admired a Mars sunrise, standing quiet together in the red sands.

Inevitably, I got the first hard science question I couldn't answer from him a couple of weeks ago.

I really should have seen it coming. I was dropping him off at kindergarten. Before we went inside, I crouched next to him to point up at the moon above the city. He looked at it and said "Moon" in Swedish. Then he turned to me, eyes intent, and said "Mars?". It was a question.

He had put together that the planets we were admiring in the book and in the Space Room were actually up there somewhere. And now he just wanted me to point him towards Mars.

I had absolutely no idea. I told him it's not on the sky right now, but for all I knew, it might have been.

Now I really want to know how to find this out. Sure, there are calculations involved. I want to learn enough about them to be able to write a small, understandable computer program for me. It should be able to answer a question such as "Where in the sky is Mars?". Being able to ask it for all the planets in our solar system seems like an easy generalization without much extra cost.

Looking at tutorials like [this one with illustrations](https://www.davidcolarusso.com/astro/) and [this one with detailed calculations](https://stjarnhimlen.se/comp/tutorial.html), I'm heartened to learn that it's not only possible to do this, but more or less the steps I hoped:

- Find out where the Earth and Mars are in a particular instance, using some sensible 3D coordinate system centered on the sun.
- Find out how the Earth is currently rotated in the same coordinate system, and where on Earth you're standing.
- Rotate accordingly. Get coordinates on your subjective sky.

There are many complicating factors that together make a simple calculation merely approximate, and the underlying reasons are frankly fascinating, but it seems that if I just want to be able to point roughly in the right direction and have a hope of finding a planet there, a simple method will do.

I haven't written any code yet, so consider this a kind of statement of intent. I know there must be oodles of "night sky" apps and desktop programs that already present this information... but my goal is to make the calculation myself, with a program, and to get it right. Lovingly handcrafted planetary positions.

It would also be nice to be able to ask "Where in the sky is the moon?" (that one's easy to double-check) or "Where in the sky is the International Space station?". If anything, that ought to be a much simpler calculation, since these orbit Earth.

Once I can reliably calculate all the positions, being able to know at what time things rise and set would also be very useful.

I went outside to throw the garbage last night, and it turned out it was a cloudless late evening. I saw some of the brighter stars, even from the light-polluted vantage point of our yard. I may have been gazing on Mars without knowing it. It's a nice feeling to find out how to learn something. Even nicer when it's for your child, so you can show him his favorite planet in the sky.
