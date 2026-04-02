# Rakudo (nom) reaches milestone — no more .pir files!
    
*Originally published on [14 June 2011](https://pmthium.com/2011/06/rakudo-nom-reaches-milestone-no-more-pir-files/) by Patrick Michaud.*

As Jonathan Worthington and I have posted in various articles, we’re working on a [new implementation of Rakudo Raku](../Jonathan\ Worthington/Rakudo-on-6model-gets-underwayi.html) (the nom branch) that is based on a new meta-object model instead of the object system provided by Parrot.

Today we reached a nice milestone of sorts, as I removed the last “.pir” file from the Rakudo-nom source tree.  This means that all of the source code files in the Rakudo repository are now “Raku”.  (Some of the files are actually in NQP, which is a Raku lite of sorts.  See [this article](New-NQP-repository-new-nom-Rakudo-branch.html) for more details.)

To be certain, there are still some PIR features embedded in some of the source files — either using pir::opcode or the old Q:PIR syntax.  However, we’re steadily eliminating any of this Q:PIR code that is being used, and the pir:: opcodes will ultimately replaced with abstract nqp:: operations that can be more universal than just Parrot.

Otherwise Rakudo-nom is progressing nicely, within the past week we’ve been restoring and updating a lot of the core Raku features.  We already have multisubs, basic list and hash operations, basic parametric roles, and the like.  We’re also stubbing in many features that have been missing from the master branch, such as Stringy and LoL.

The nom branch isn’t yet at a point where it can compile Test.pm and pass tests, but at the speed things are moving it won’t be long before we are.  I can say that developing the core Raku compiler code on the new object model is far more straightforward and easier than it was under the previous Parrot object system.  Credit goes to Jonathan and the others who helped him for this — it’s a huge improvement.  We also hope to see some dramatic speed improvements over Rakudo master, as well as vastly improved optimization possibilities.

We don’t have a solid projection for when the nom branch will replace the current Rakudo master, but I expect it to happen well before the end of this summer.

In an upcoming post I’ll describe all of the old-and-new terms that have been occurring in the Rakudo universe (“6model”, “nom”, “nqp”, “master”, “nqp-rx”, “Rakudo Star”, “parrot”, “zavolaj”, etc.), to give a better idea of how this all fits together.  Stay tuned!
