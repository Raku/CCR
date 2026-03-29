# July 11 2012 — things which contain other things
    
*Originally published on [11 July 2012](http://strangelyconsistent.org/blog/july-11-2012-things-which-contain-other-things) by Carl Mäsak.*

Today I showed a fourteen-year-old how to do rot-13 using Raku. Reaction:
"that's awesome". It's things like this that make me realize why I value
talking about programming and explaining programming.

Though I botched it up. I messed around with `chr` and `ord` and modulo, when
there's a much shorter and neater way to do it:

```
sub rot13 { $^s.trans('a..z' => 'n..za..m', 'A..Z' => 'N..ZA..M') }
```

On the bright side, I get to show that solution tomorrow, and he'll probably
thin it's even more awesome. 哈哈

Today was another pleasant day of just writing tests and implementing them. I
thought I would have one happy path and two sad paths, just like yesterday. But
checking with the original game from last year showed that the last sad path
was actually a happy path too.

Here's today's action:

- You can [put things in
things](https://github.com/masak/crypt/commit/a9fe2f791bd27ee81d84eb9b66d6ed6849bb8299).
- But only if the latter [are
containers](https://github.com/masak/crypt/commit/0161050d5f4c52c58d7d4f23b07b50dbdb1181eb).
- If you put something in a container which is closed, the game will assume you
meant to [open it
first](https://github.com/masak/crypt/commit/38a7ce04933e14c6dfbc0a4a79970cd33d6865aa).

This was the first time I was tempted to call one behavior (`open`) from
another (`put_thing_in`). Eventually I decided against, because my factoring
doesn't make that easy. Which means I will be duplicating some opening logic
inside of the other method. That may or may not become a pain point in the
future; I'll certainly keep an eye out for code smells.

The last commit of the day still leaves things in a slightly unfinished state;
the `put_thing_in` neglects to apply the events like all other such methods do.
Rather than just instinctively adding that bit of code, I'll note that it
should be added as part of a test failing. So there's at least one missing
test. `:-)` I can think of a test to expose this case of a missing `apply`; can
you?
