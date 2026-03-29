# July 16 2012 — things which are part of the scenery
    
*Originally published on [17 July 2012](http://strangelyconsistent.org/blog/july-16-2012-things-which-are-part-of-the-scenery) by Carl Mäsak.*

This will be a quick one. I dove in today and implemented what I needed. Uhh,
except for the
[bug](https://github.com/masak/crypt/commit/cb6dffc11c8f00ab9992d04d520a407270d2918f)
[fixes](https://github.com/masak/crypt/commit/e5c519899a8489d912d4882017a27af14c4f5e61)
I committed along the way because I discovered recently introduced bugs.

Uhm, and except for getting momentarily stuck on the last one. It really wasn't
that difficult, I just managed to misplace my programmer ability for a few
minutes. That happens. The tests kept telling me "no, that's still not it", so
I kept trying until I got it right.

So here's what's new today:

- When you `look` at things, the `PlayerLooked` event returned now includes a [list of things](https://github.com/masak/crypt/commit/d807669a4a8e780a964b6bdae00f01c0ed989cc4).

Amazingly, adding this did not break any tests.

- However, there's a way to make things "part of the scenery".

That means
they're still in the room, but they're [not included in that
list](https://github.com/masak/crypt/commit/af694afa26008e8b50d8aeb872257a1f85761503).

It's interesting. I can feel that focusing on the verbs (as it were) is making
this a better program than last year. What's interesting is that my brain's
spare cycles are figuring out the *internal* representation of the game engine.
How are rooms and things and containerships represented? I now have a fairly
good idea of this, even for the things I haven't implemented yet.

It's like separating the behavioral outside from the implementational inside
makes it easier to think about both of them separately.

Anyway, we've now had a really good start on "general adventure game
mechanics". I'll probably need a few more course corrections as I map out the
game itself. I'll need to flesh out the container semantics, etc. But the big
brush strokes are there now.

We're ready to implement crypt itself. Let's start doing that tomorrow.
