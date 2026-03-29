# July 20 2012 — putting the leaves in the basket
    
*Originally published on [21 July 2012](http://strangelyconsistent.org/blog/july-20-putting-the-leaves-in-the-basket) by Carl Mäsak.*

Well, this'll be a short one.

- I added the basket, and [you can put the leaves in it](https://github.com/masak/crypt/commit/5fcb6488f78e72309f99bc972cd00886533471b1)

Causing the game to allow you further into the caverns.

- The I [added the sign](https://github.com/masak/crypt/commit/5d29eb516ff2ef27688be960ffe68ad942eba654), and [you can read it](https://github.com/masak/crypt/commit/116c42168608affbafbad7eb327ac5f4ced8e635)!

Today was the first day when I did a test that went "ok, we'll just pretend
we've played the game all the way to the chamber". It was easy, just pre-play
the game in a subroutine and return it.

I meant to do the walls today, but I think I'll save that until later. They're
funny but kinda special-cased, and I'll need to figure out how to do them.

I'm now convinced that passing callbacks into the game engine the way I'm doing
is a bit too powerful. Discussing with *jnthn*++, I figured out a better, safer
way to do it. Will make that change sometime in the next few days, too.
