# Progress and minor frustration
    
*Originally published on [19 November 2009](https://use-perl.github.io/user/JonathanWorthington/journal/39917/) by Jonathan Worthington.*

This is a summary of what I did on my Rakudo day on Monday as well as other little bits of random hacking since then on the Rakudo ng branch.

- Corrected dispatches on proto-objects, and along the way fixed a few things that were quite likely bugs in master.
- Got signature introspection back in place.
- Switched back on `@` requiring the Positional role and `&` requiring the Callable role when binding parameters.
- Got parallel dispatch back in place, and we parse it a like STD now.
- Added back parsing of fatarrow, and its ability to be used to supply named parameters
- Added back submethods.
- Made `.=` parse and work again; we almost certainly need to re-visit the way I did it, though, since while I didn't find a better way yet, myself and Pm both agree the current way is not ideal.
- Put back `Inf`, `-Inf`, `+Inf` and `NaN`, which parse as literals.
- Brought `.arity` and `.count` back over from Rakudo master and simplified them a bit along the way, thanks to other refactors.
- Get placeholder variables parsing and mostly working again.

So, a whole grab back of little bits here and there. Things continue to come together nicely, but a source of some frustration is that our passing test count remains low. The issue here isn't that we aren't adding back lots and lots of things, but that the test files often require features aside from the things they're actually testing. This is part and parcel of having a Raku test harness - indeed, one issue we have is that we didn't put back eval yet, so `eval_dies_ok` tests can't yet be run. But another issue is the temptation for test writers - and I'm just as guilty as anyone - to write tests using Raku language features unrelated to the thing being tested themselves. For example, many of the tests for signature introspection rely on the parallel dispatch operator. The test file itself is beautiful and elegant, but unfortunately I'm still working towards putting back things we need - even though I have signature introspection back in place - because of other features it just assumes. So I expect we'll hit a point where we very suddenly get back loads of tests - the problem is that in the meantime, we don't have as much testing to tell us of regressions as would be ideal.

OK, time for me to fly to Latvia, for the first Baltic Perl Workshop, now! :-) Thanks to Vienna.pm for funding this work.
