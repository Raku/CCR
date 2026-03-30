# Another busy week in Rakudo development
    
*Originally published on [31 May 2008](https://use-perl.github.io/user/pmichaud/journal/36558/) by Patrick Michaud.*

It's been another big week in Rakudo Perl and Parrot development,
with a lot of visible signs of progress and also a lot of "behind the
scenes" sort of things as well.  This updates some of the important
events of the week (and there was a lot), and then it'll be time for
me to craft my next "monthly report" for the Mozilla Foundation and
TPF grants.

Earlier today I also posted an article on parrotblog.org: Raku metaclasses for Parrot.  This article goes into some detail about Raku metaprogramming and the library I wrote about last week.

Late last week I noticed that Rakudo's code for parsing and building
Pairs was getting a bit out of whack, and also that there was a *lot*
of special-casing on `infix:<,>` that shouldn't be there -- building
lists in the AST is something that should come more naturally.  So,
over the weekend I ripped out the old argument and Pair handling code
and put in something much saner.  As a result, Rakudo now parses pairs
and arguments correctly.  But doing this also pointed up a couple
of major issues:

- Raku's `list` function doesn't really follow the model for
Pair arguments and named arguments, and
- Parrot's argument passing conventions aren't really up to handling
what Raku requires.

The problems with argument passing I already knew about, but I was
waiting until we needed action on it to do anything about it.  But
since Rakudo started handling pairs and named arguments correctly,
we ended up with quite a few RT tickets that generally came down to
"Parrot's argument handling doesn't support that yet."  So, I posted a message to parrot-porters to resolve the issue, and after a few discussions we now know how we're going to solve it.

As far as `list` goes, the problem becomes apparent with something like:
```raku
list(1, 2, c=>3, 4, d=>5)
```

This is intended to create a list with five elements (including two
Pairs), but according to Synopsis 6 the `c=>3` and `d=>5` should
be treated as named arguments and not positional ones.  Anyway, some
approaches for dealing with this were discussed in #raku and during
the weekly design meeting, and I expect it'll be resolved soon.  Watch
the synopses and mailing lists for details.

While fixing up Pairs and infix:<,> I also added the ternary `?? !!`
operator to NQP, and fixed both NQP and Rakudo to correctly access 
array elements by integer (since Parrot doesn't always distinguish 
the two cleanly on its own).  We'll undoubtedly have to revisit this
issue again in the future, though, when we start to do slices.

After that I started looking at Rakudo's code for handling List objects,
and it had gotten kind of ugly.  Methods weren't in any particular
order, and a lot of them were doing their work by using indexed
element accesses instead of iterators.  So, I started a major refactor
of all of the base classes, and in the process figured out how to
properly handle scalar and list contexts.  Thus, the following 
long-standing bugs/annoyances now work in Rakudo:
```raku
my @a = 1;              # works, used to turn @a into an Int
my $a = (1, 2, 3);      # works, $a becomes an Array
my %h = (a=>1, b=>2);   # works -- used to not work at all :-P
```
In addition, functions and lists now also understand flattening
in list context at the operator level (list contexts for parameters 
will be coming soon).  We don't have lazy lists yet, but with this 
work in place we have the right framework for adding them.

One nice outcome of this is that we're rapidly expanding the scope
of tests in the official suite (spectests) that we can now run and/or pass.  Vasily Chekalkin (bacek), Moritz Lenz, and Jerry Gay were very productive this week terms of finding spectests that can be added to the regression target, fixing tests that were incorrect, and suggesting or providing fixes to Rakudo that would enable it to pass more tests.  Moritz even developed a script that runs all of the tests in the suite and suggests those that may be candidates for adding to the regression list.

As of this writing Rakudo's spectest_regression target is running 43 test files in the suite, passing 775 tests.  It's a small number to begin with, but I expect it to grow rapidly and will update this statistic in future posts.  The other thing we're discovering is how much we really want to improve Rakudo's parsing speed, but that will be coming with PGE improvements soon.

[**Update:**  Oops!  A bug in Test.pm caused the number of passing tests to be misreported -- the actual number was 430.  See [my next post](Update-on-Rakudo-test-results.html) for details. --Pm]

While all of this was taking place, Jonathan was doing lots of [travel and presentations](../Jonathan Worthington/Rakudo-Hacking-and-Talks.html) about Rakudo and Parrot.  But he still managed to find time to come up with an implementation for mutable Scalar variables as PMCs.  Of course, that presented an issue of its own because Jonathan was working in a branch while I was crazily refactoring everything in the trunk.  (Sorry, Jonathan!)  Merging the two back together took the better part of a day, but that was primarily because PMCs (written in C) can take a fair bit of work to troubleshoot and find all of the miscues.  In this case it's even more difficult than usual because a Perl6Scalar PMC delegates nearly everything to its contents, and we have to be judicious about what gets delegated and when.  Plus in the process I was also refactoring things in src/parser/actions.pm to be more sane and use less inline PIR.  As usual, Jonathan did a terrific job on a piece of the puzzle that I wasn't too keen on tackling myself.

Also, take a look at [what Jeff Horwitz has been doing with mod_raku](https://web.archive.org/web/20080820105957/http://www.smashing.org/jeff/node/35).  His work shows that we really can start to do real applications with Rakudo and Parrot.

I'm very pleased with all that was accomplished this week.  However, for everything we achieved I think we identified another important piece that we're ready to tackle next.  That's probably good.  We're also finding that finally all of the infrastructure is coming together to let more people hack and test Rakudo and Parrot.
