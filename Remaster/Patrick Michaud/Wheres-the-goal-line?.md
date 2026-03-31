# Where's the goal line?
    
*Originally published on [1 July 2008](https://use-perl.github.io/user/pmichaud/journal/36834/) by Patrick Michaud.*

From a comment on rakudo.org:

> dstar said:*One thing I'm not clear on -- Rakudo is passing 1100 tests out of how many? IE, where's the goal line?*

Well, the "goal line" is by definition a moving target.  There's not a hard number we can cite -- even in Perl the size of the test suite constantly changes as new features are added and new bugs are found.  There will be a point at which we declare a particular set of tests as being the "official test suite" for Raku.0.0, but we're really not close to that point yet.  Here's what I *can* say about the test suite thus far:

The "official test suite" is being built from the test suite that was created for Pugs -- the Pugs test suite has approximately 19,000 tests in it.  But, the Pugs suite itself was somewhat disorganized and thus difficult to determine test coverage.  It also has many tests that are incorrect, either because the language specification has changed since they were written or because they were incorrect in the original.

Thus, Adrian Kreher (mentored by Moritz Lenz and Jerry Gay) is in the process of conducting a complete review and reorganization of the Pugs test suite into the "official test suite", or what we call the "spectests" (in t/spec/ of the Pugs repository).  We estimate that about 5,000 (25%-30%) of the tests in Pugs have been reviewed and migrated into t/spec/.  And just because a test appears in t/spec/ doesn't mean it's necessarily correct -- we continue to find places where the test doesn't exactly match the language specification (or the language specification is ambiguous and needs clarification in the test).

Within the 5,000 or so spectests, there's a subset of 75 test files (~1,500 tests) that have been identified as the "spectest regression suite" for Rakudo.  These are test files that we expect Rakudo to pass at any given moment in time, such that someone can do "make spectest_regression" and get back "All tests successful."  The developers also use this to make sure that any changes to Rakudo don't break existing functionality.  Of course, the spectest_regression suite is itself a rapidly moving target as Rakudo acquires more features and as the test suite evolves.  For example, at the beginning of June there were 52 files (892 tests) in the spectest regression suite, today (July 1) we have 75 files (1522 tests) in the regression suite.

And beyond all of this have been comments from Larry and others that eventually the official test suite will likely be double or triple the current size of the Pugs suite -- I think I've heard estimates of 40,000-50,000 tests in the suite when we're "finished".

So, return to the original question of "Where's the goal line?", you can see that there's not really a straightforward answer.  This is why I haven't been saying things like "passing 1100 out of *N* tests", because the exact value of *N* depends on what's being measured to depend on what one considers important, and until more of the official test suite is ready any useful *N* doesn't really correspond to the "goal line" of a released Raku.  So, the number I tend to focus on at the moment is the absolute rate of increase in passing tests -- currently it's about 100 new passing tests per week.  I expect that trend to continue or improve in the coming months.  As long as the number of passing tests is increasing, we're making progress.

An obvious intermediate goal is to have Rakudo passing at least the tests in the Pugs test suite.  This depends not only on Rakudo development progress, but also progress in reviewing the Pugs tests and migrating them into t/spec/ .  This is also why the Raku developers are constantly inviting and encouraging people to help with building and reviewing the test suite.  As mentioned above, only about 25%-30% of the Pugs test suite has made it into t/spec/, and many of those have been simply moved into t/spec/ without significant review or verification against the Synopses.  Once we have most of the Pugs test suite migrated to t/spec/ I'll probably start reporting passing tests relative to the size of overall suite.  (But I'll also continue reporting the passing rate increase as well.)

Lastly, this is a good place for me to repeat an invitation I made at YAPC::NA:  For those who are interested in helping with the test suite but don't know where to start, I suggest "adopting" a particular Raku feature or Synopsis section and saying "I'm going to develop the tests for that feature."  This doesn't require learning all of Raku, it only requires learning those parts of Raku that are necessary for testing that particular feature.  It also gives a sense of ownership for a part of Raku, as in "I did that part of the test suite".

I'll undoubtedly add more information about Raku testing in the near future, as it's an area where many hands can help make light work.

Thanks to dstar for asking the question that prompted this post.  :-)
