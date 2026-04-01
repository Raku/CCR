# The Rakudo-ng branch
    
*Originally published on [11 November 2009](https://use-perl.github.io/user/pmichaud/journal/39874/) by Patrick Michaud.*

As I [wrote a few weeks ago](Hague-grant-work-the-new-regex-engine-and-NQP.html),
the period since Rakudo's October release has been one of a lot of
refactoring and rebuilding to a new grammar and core implementation.  So far everything
has gone almost exactly as I outlined at the end of that post, so this
is just a status update to let people know where we are.

The new version of NQP (nqp-rx) has been substantially completed
and includes many new features that weren't available in the previous
regex engine.  In particular, Raku grammars can now support
protoregexes, and we also have the ability to execute code blocks,
declare variables, and add parameters to regexes.  The new version
of NQP is also bootstrapped, which means that the code for all of 
NQP (and its regex engine) is mostly written in NQP.

On October 30, Jonathan and I started a new branch
(called "ng" for "new grammar" or "next generation")
for refactoring Rakudo to use the new NQP and regex engine 
implementation.  Nearly all of our work since then has been in
this new branch, and I think it is going exceedingly well.
Today we were able to get the sanity tests and core compiler
to where it can again begin compiling and running the test suite.

Outwardly this probably seems like very slow progress for 10 days
of effort, but running the test suite doesn't tell the whole story.  
In the process of getting to this point, we also knocked off several
of the critical features needed for Rakudo Star that weren't
possible in the previous version of Rakudo, including lazy lists,
proper array element vivification,
dynamically generated metaoperators, correct handling of 
containers and constant values, better dispatch semantics, and a 
whole host of other features that make the Rakudo core much 
stronger and easier to work with as we move forward from here.

Not only that, but we're already at the level where we are
implementing builtin classes and methods in Raku (as opposed
to PIR).  And we're also taking this as an opportunity
to rewrite some of the previous PIR-based components into Raku.

So, *over the next couple of weeks we will continue to focus on bringing the new "ng" branch up to the same level as the current "master" branch.*  When we do that, the "ng" branch will likely
become the new master branch.  I'm still a little reluctant to
give a time estimate for when we'll make this switch, but given 
our current momentum (and the ease in which things are coming 
together) I suspect it won't be far off -- a few weeks at most.
More importantly, unless we hit any major roadblocks, I expect 
we will have nearly all of the critical components needed for 
Rakudo Star (and certainly the most challenging ones) implemented 
by the end of December.  We'll then use the remaining months
until April to add other important but less-critical features,
continue improving performance, and work on packaging and
documentation issues.

Most of the progress reports (and 
Twitter messages) I'll be
writing over the next few weeks will be about progress in nqp-rx
and in the "ng" branch as opposed to the Rakudo "master" branch.
Stay tuned!
