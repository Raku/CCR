# Update on Rakudo test results
    
*Originally published on [2 June 2008](https://use-perl.github.io/user/pmichaud/journal/36564/) by Patrick Michaud.*

Earlier today I realized that the numbers I reported yesterday for Rakudo's "make spectest_regression" were incorrect -- the Test module was not reporting the number of tests skipped (345), so the actual number of tests passed is only 430.  That's still pretty good.

But on the plus side, since yesterday some excellent detective work and updating by moritz, bacek, particle, Auzon, and others means that we could add nine additional more test files into the spectest_regression target, and we're now passing 638 tests in the regression suite.  Not bad for a 1-day improvement.

I suspect that there's more like this -- tests that can be moved into the "passing" category by simple fixes to the test and/or Rakudo itself.  So, thanks to everyone who is helping to review the tests -- we're definitely making progress.
