# Two days. 562 new passing tests.
    
*Originally published on [22 December 2008](https://use-perl.github.io/user/pmichaud/journal/38130/) by Patrick Michaud.*

For some unknown reason I woke up at 3am on Saturday morning and couldn't
get back to sleep.  So, I decided I might as well use the time for some 
productive Rakudo hacking.  

I decided to start by reviewing the spectest 
suite a bit.  In the past couple of days I've noticed 
that although we've been increasing the number of spectests that Rakudo
passes, we didn't seem to be shrinking the number of tests that are
in the spectest suite but don't attempt to run (the grey area
in the graphs).  So, I decided to review the test files that we
*don't* run, instead of the ones we do.  I also reviewed the RT
queue for patches to apply.

By 23:59 on Sunday, we had 526 more passing tests than we started
with on Saturday.  In fact, in the past two weeks Rakudo has increased
its count of passing spectests by over 1,000.  We're now at 5,790
total passing tests.


Here's some of what was accomplished this weekend:

- recognize the difference between array and hash subscripting.
- align with a change to S02 that now uses \c for decimal character encoding
- added the .kv method to Pair, to enable the pair.t spectests
- recognize more unicode codepoints (though still not all) as alphabetic
- enable the various unicode bracketing characters for quotes
- added the unicode versions of the infix hyperops we added last week
- added the `p5=>` "fat comma" operator
- cleaned up the readline method on IO
- recognize radix conversions in strings
- add +Inf, -Inf, and NaN processing
- add some workarounds so that Complex numbers work again (they broke with mmd)
- implement the use of the "whatever star" in list and array slices

Getting the "whatever star" to work was a nice surprise -- thunking
the arguments to postcircumfix:<[ ]> turned out to be quite a bit
easier than I had expected.  Rakudo can now do things like 
```raku
 @a[*-10 .. *-1] ` to get the last ten elements of an array.
```

Over the weekend Cory Spencer submitted several incredibly useful 
patches to fix array initialization in `my` lists and properly refactor
many of the list builtins.  He has two more patches in the queue that I
plan to review and likely apply tomorrow morning.

Overall, I'm very satisfied with the progress Rakudo contributors
have made over the past couple of weeks.  In addition to getting
new features to work, there's also been a lot of internal
refactoring and cleanup that will make things more efficient and
help with the next phases of development.  So, although I'm not
sure that we'll be able to repeat the past couple of weeks, things
still look very good for ongoing improvements to Rakudo.

Don't forget:  we have a Rakudo Perl Twitter feed if you want to be notified of all of the new updates to Rakudo Perl.
