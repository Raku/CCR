# More Parrot hacking
    
*Originally published on [28 November 2007](https://use-perl.github.io/user/pmichaud/journal/34993/) by Patrick Michaud.*

Another fruitful day of hacking.

The big change for the day is that explanatory comments were added to abc's *src/grammar-actions.pl* file; hopefully this will help people understand how it all works and fits together.  I also added a couple of notes to the grammar ( *src/grammar.pg* ), but we obviously need to explain that one a bit better as well.

In fact, now that the compiler tools are nearing completion it's a great time to write a "compiler tutorial" that describes the process of building a compiler for Parrot (using abc as the canonical example, of course).  But I think that will have to wait a week or so, as there's other code (raku!) that needs developing.

More improvements to the compiler toolkit today; completed the implementation of 'while', 'repeat_while' and 'try' nodes in PAST, and a couple of minor optimizations and improvements were made to the code generation.  Tonight I spent a couple of hours playing with some possible optimizations for better variable handling in the generated code.  The basics of what I tried worked nicely, but overall it's a very tricky problem in a dynamic system like Parrot, where some other subroutine or opcode can re-bind your symbols when you're not looking.  So, we'll leave this for a later optimization or something that someone else can attempt.  At this stage, working stable code definitely trumps fast and possibly unstable code.

NQP also got while/until/repeat_while/repeat_until statements added, in order to provide tests for PCT.  NQP doesn't have 'try' blocks yet... we may just save that for raku to test.  I also figured out how to finish out an implementation of class declarations in NQP, so that will be exciting.

Today on irc:#parrot Coke and others spent some very useful effort cleaning up outdated stuff in the Parrot repository and closing out obsolete RT tickets.  As for me, I think that I opened as many new tickets as I closed today.  :-|

This is a good place to mention that the Parrot developers hold weekly "status report" meetings on [#parrotsketch](https://irclogs.raku.org/parrotsketch) every Tuesday at 18:30 UTC.  The meetings are [archived](https://web.archive.org/web/20090419195038/http://www.parrotcode.org/misc/parrotsketch-logs).

Andy Lester posted a nice article on PerlBuzz about the ROADMAP that was published for raku -- thanks Andy!

Now to see how well these shiny new tools perform in building a real compiler, like, say, raku.  :-)

Pm
