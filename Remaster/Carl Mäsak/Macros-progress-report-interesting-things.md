# Macros progress report: interesting things
    
*Originally published on [29 January 2012](http://strangelyconsistent.org/blog/macros-progress-report-interesting-things) by Carl Mäsak.*

I'm here to report that the macros grant is coming along nicely. I've been busier with `$dayjob` than anticipated, and so the schedule in the grant application is slipping a bit. But I have a fairly good view of the obstacles and to-do items ahead.

When we [last saw each other](Macros-progress-report-a-bit-of-d1.html), I was saying that "variable lookups from inside of the quasiquote end up confused". That's still true, and it's the big thing I want to fix before merging my work so far into the `master` branch, er, into the `nom` branch.

What I've done since last time:

- I [wrote a thorough explanation](https://gist.github.com/masak/1548053) of why ASTs need to carry around their original lexical environment. (Short explanation: they need to act like closures, but they aren't really so they need to fake it.)
- I [re-based the `macros` branch](https://github.com/rakudo/rakudo/tree/macros2) on the latest `nom`, and fixed a bunch of regressions in my code that fell out of that.
- I [started a test file](https://github.com/raku/roast/blob/master/S06-macros/macros-d1.t) with macro tests that are more adapted to the work that I'm doing than the tests that are already there. I hope to be able to absorb the ones that are there as we go along; right now they're not much use to me.

Now I'm well poised to go in and actually implement the lexical fixup I need for the ASTs to behave as if they're normal, honest-to-goblin closures. I just thought I'd blog this report in case I end up walking into the source code, never to return. `:-)```

The trick is this: [`.SET_BLOCK_OUTER_CTX`](https://github.com/rakudo/rakudo/blob/9719f7d99602fdaaa277a6bdec40a2fad5d5c5ea/src/Perl6/Actions.pm#L468). It lets you say "block, your `OUTER` is now this thingy". It's the kind of internal fixup that makes the cat walk by twice inside the Matrix.

Ok, I'm going in. See you on the other side.
