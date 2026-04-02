# Lots of Rakudo-nom progress, starts to run spectests
    
*Originally published on [27 June 2011](https://pmthium.com/2011/06/lots-of-rakudo-nom-progress-starts-to-run-spectests/) by Patrick Michaud.*

[The nom branch of Rakudo](New-NQP-repository-new-nom-Rakudo-branch.html) continues to develop at a blistering pace. Yesterday nom finally had a working Test.pm, which meant we could start testing it against the spectest (“roast”) suite.  As of this writing nom is passing 50 spectest files.  By way of comparison, the master branch passes 551 spectest files, so we’re already about 9% of the way there.  And I expect that number to grow — many of the spectests fail because nom is missing relatively minor features that can be easily restored.  At this rate, I’m thinking it’s very possible that the next monthly release of Rakudo (July) will be based on the nom branch instead of the old master branch.

I’ve also worked further on [nom’s list implementation](Raku-lists-episode-1.htmml), and it’s now *faster* than lists and iteration in master.  In fact, for loops in the nom branch now run about *80% faster* than they did in the master branch.

We continue to eliminate PIR from the code base in nom.  For the core setting, we’re down to 143 instances of ‘pir::’ and 22 instances of ‘Q:PIR’.  The rest have been replaced by generic ‘nqp::’ opcodes that can someday be targeted to other virtual machine backends.  Currently we’ve defined about 83 nqp:: opcodes that are used in implementing the core setting.  For efficiency reasons we might not ever be able to eliminate all PIR from the core setting, but we should be able to get it to be small enough that it can be walled-off into VM-specific code files.

To give an idea of how fast things are moving — here’s a summary of the features that have been added to nom in the past seven days:

-  `fail`
-  lexically scoped returns
-  for-style loops and map, 80% faster than master
-  better infinite lazy list handling
-  gather/take
-  try statements
-  package-scoped variables, subs, and methods
-  whatever currying
-  Test.pm
-  lots of builtin operators and methods
-  dynamic variables, PROCESS and GLOBAL namespaces
-  IO objects, including $*IN, $*OUT, $*ERR
-  literal values in signatures
-  quantified method dispatch (.?method, .+method, .*method)
-  basic roles, including Associative, Positional, and Callable
-  basic support for natively-typed lexicals (e.g., ‘int’, ‘str’, ‘num’)
-  argument interpolation
-  list assignment
-  new say and .gist semantics
-  magical string increment and decrement
-  sequence operator
-  series operator
-  preliminary BEGIN/CHECK/INIT/END phasers
-  smart matching (~~)
-  inlined assignment

So, you can see things are active.  We’re also in need of testers and people who can help us triage spectests and figure out what is causing them to not run.  If you’re interested in hacking on code or helping with the tests — email us or find us on IRC libera.chat/#raku!
