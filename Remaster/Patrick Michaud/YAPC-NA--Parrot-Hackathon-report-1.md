# YAPC::NA -- Parrot Hackathon report #1
    
*Originally published on [16 June 2008](https://use-perl.github.io/user/pmichaud/journal/36693/) by Patrick Michaud.*

[Rakudo spec regression status:  64 files, 779 tests]

Throughout YAPC::NA I'm hoping to make frequent posts about various
events taking place, including the hackathons and other
discussions.  The Parrot hackathon took place yesterday
and today, and we've had a lot of contributors and some
excellent progress.  A brief summary of some things that
have occurred during the hackathon:

Moritz noticed [a post on Perl Monks](https://www.perlmonks.org/?node_id=692090) about Rakudo not yet supporting %\*ENV; I forwarded it to rakudobug@perl.org to be filed as an RT ticket, and just a few minutes after that Jonathan had a working implementation.

Scott Duff (PerlJam) tested and closed a long-standing patch from Zev Benjamin to supply the 'run' function in Rakudo.

Bacek made some fixes to S29-list/minmax.t and so we've been able to add that as another set of tests to our spectest_regression suite.  Jerry Gay also noticed some additional tests for spectest_regression.  As of this writing Rakudo is now passing 779 tests in the spectest_regression suite.

Jerry Gay (particle) updated the mk_language_shell.pl script to automatically include the optable rules.

I did more refactoring and updating of the Range operators, as well as added the ternary ?? !! operator to Rakudo.

Olivier Mengu&eacute; (dolmen) supplied patches to add the .raku method to Bool and Range types.

Chromatic has been cleaning up a lot of IMCC issues, improving constant string handling, and otherwise applying tons of patches to Parrot.  Right now Parrot has 658 outstanding tickets -- we're hoping that can go below 650 by Tuesday's Parrot release.

Allison, chromatic, and I had a discussion about adding new branch opcodes to Parrot that PGE can use in lieu of bsr/ret for local subroutines.  We came up with the "push and branch/jump" and "pop and branch/return" opcodes.  These work like bsr/ret, but instead of using Parrot's internal control stack they allow the user to provide a stack such as ResizableIntegerArray, which can be much more efficient at storing and processing addresses.

Coke struggled a bit with Tcl on Parrot, but managed to update it to use the new control exception types in Parrot (and that Rakudo and NQP are now using for their 'return' statements).

I spent most of Saturday looking at trying to make a precompiled form of Rakudo's Test.pm script, so that we aren't re-compiling it upon each test execution.  But I ran into some snags having to do with :load/:init handling, so I've stepped back from that for a day or two to re-think it (and there's been plenty of other good things going on).

Everyone at the hackathon seems to be having a terrific time, and we're getting lots done.  I know that this report misses a few people who were working on documentation -- I'll try to get details in my next post.
