# July 13 2012 — things which you can read
    
*Originally published on [13 July 2012](http://strangelyconsistent.org/blog/july-13-2012-things-which-you-can-read) by Carl Mäsak.*

Today, as promised, we're going to learn how to read.

The implementation of this (from last year) is easier than I remembered.
Reading things is the same as examining them. Except that you can only read
readable things. Simple.

If you're following along this series, you'll notice that this is the third day
we implement a feature with approximately the same commits:

- You can [read things](https://github.com/masak/crypt/commit/e6f9ee6e27f7d97761af8e20c51a73c859c38b36).
- But only [if they're declared readable](https://github.com/masak/crypt/commit/9dc36152ae8556842cb36174dd15753cdfa5fda0).

As you can see, it's the usual happy-path, sad-path stuff. With the validation
creeping in towards the end.

Oops, I actually introduced another event `Adventure::PlayerRead` along the
way, rather than re-using `Adventure::PlayerExamined`. Didn't mean to do that.
But thinking about it, I think I'll leave it that way. Examining something and
reading something *could* be different things, even if they aren't in `crypt`.

Another oops: I realized I'm not at all checking that the things the player
reads (or puts, for that matter) are there in the same room as the player. I
could write tests for that today, but I'll just put it on my TODO list and get
back to it. We're going to have to revise the whole "which things can I
see/take/do things with" a few times along the way anyway.

Tomorrow it's time for things which play peek-a-boo.
