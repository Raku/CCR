# New NQP repository, new “nom” Rakudo branch
    
*Originally published on [8 February 2011](https://pmthium.com/2011/02/new-nqp-repository-new-nom-rakudo-branch/) by Patrick Michaud.*

As mentioned in the [last week’s NQP Roadmap](NQP-Roadmap-201101.html), we’ve now broken out the new 6model-based NQP into its own repository on GitHub:  [https://github.com/Raku/nqp](https://github.com/Raku/nqp) .  We know there may be a bit of confusion between the two versions; just remember that “nqp-rx” always refers to the older one and “nqp” without the -rx refers to the new one.

Today Jonathan also created the “nom” branch in the Rakudo repository where we’ll be converting Rakudo over to using the new NQP.  We expect this process to take several weeks.  Rakudo compiler releases will continue to be made from the existing “master” branch until the new branch is ready.

Our hope and expectation is that the April 2011 Rakudo Star release will be using the new 6model implementation.  Stay tuned!
