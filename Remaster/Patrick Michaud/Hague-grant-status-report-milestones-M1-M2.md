# Hague grant status report, milestones M1/M2
    
*Originally published on [24 November 2009](https://use-perl.github.io/user/pmichaud/journal/39939/) by Patrick Michaud.*

Below is the milestone status report I submitted for my Hague Grant; the [original grant description](https://news.perlfoundation.org/post/tpf_awards_first_hague_grant_t)

----------

Rakudo Perl and PCT improvements
Hague grant status report, milestones M1/M2

This is a milestone report for the "Rakudo Perl and PCT improvements"
Hague Grant.  Rakudo Perl is a Raku [2] implementation built on top
of the Parrot Virtual Machine.

The overall purpose of this grant is to design and implement the
components needed to align Rakudo Perl's parsing parsing more closely
with the current Raku specification and to increase the level of
Raku code used to implement the compiler itself.

This report focuses on the completion of the deliverables needed
for milestones M1 and M2 in the grant description, and marks
the "halfway" checkpoint for the grant.  Originally this checkpoint
was expected to be reached in early 2009, but significant changes
to Parrot, Rakudo, and Raku in the months shortly after this
grant was awarded delayed progress on some M1 and M2 items until
later in 2009.  However, progress on many other items in the
grant were on time or accelerated, such that even though this
is officially the "halfway" checkpoint report, in reality almost
all grant deliverables are completed, and the "final" report
for this grant can be expected in December 2009.

A significant event during this grant period has been the planning
and announcement of "Rakudo Star", a "usable and useful Raku release"
to occur in April 2010.  Rakudo Star is not intended to be a
complete implementation of Raku, but rather to be an official
"interim" release that provides sufficient features to be a viable
platform for consideration by application developers.  Much of the
overall Rakudo project effort, including work to be performed
under this grant and other Hague grants, has been prioritized
and focused on ensuring the successful release of Rakudo Star
in April 2010.  Indeed, nearly half of the "critical must-have"
features identified in the Rakudo Star ROADMAP depend on
the deliverables from this grant; the current state of
progress described by this milestone grant report is exactly
as planned and required by the Rakudo Star ROADMAP.

The specific items to be achieved under milestones M1 and M2 are:

- M1-1:  PGE internal refactors and initial protoregex implementation
- M1-2:  Selected protoregex constructs added to Rakudo's grammar
- M1-3:  Interface design for pre-compilation and external libraries

- M2-1:  Completed protoregex implementation
- M2-2:  Initial implementation of longest token matching in PGE
- M2-3:  Completed Rakudo grammar migration to protoregexes
- M2-4:  Initial implementations of external HLL library support

Items M1-3 and M2-4 concern handling of library precompilation and
external interfaces; these were achieved in late 2008 and early 2009.
Rakudo Perl allows library modules to be precompiled to Parrot .pir
and/or .pbc modules for faster loading and execution; indeed, the
Test.pm module is precompiled to substantially reduce the time needed
for Rakudo to run the Raku official test suite ("spectests").  Many
applications and libraries written for use with Rakudo similarly
pre-compile the modules to achieve better load performance.

An interface for loading external libraries (including those written
in other Parrot high level languages) was prototyped and added to
Parrot and Rakudo in early 2009; this interface is being continually
refined and improved in response to changes in the Raku specification.

The remaining milestone items concern the implementation of protoregexes
and longest token matching (LTM), and the integration of these features
into Rakudo.  The initial expectation of the grant was that these features
would be added to the existing Parrot Grammar Engine (PGE), and
subsequently used by Rakudo through PGE.  However, as work progressed
it became apparent that the changes needed to PGE would significantly
impact backwards compatibility and run counter to Parrot's official
stability goals.  Therefore, instead of modifying PGE I have built
a new regex engine essentially from scratch and embedded the engine
directly into a new version of NQP (the lightweight Perl6-like
language used to build the Rakudo compiler).

The new engine directly supports protoregexes (M1-1 and M2-1), a
limited form of longest token matching (M2-2), and is much more
consistent with the Raku specification and STD.pm implementation
as they have evolved over the past couple of years.  In addition,
instead of compiling regular expressions directly to PIR (as PGE does),
the new engine compiles regular expressions to the same abstract
syntax tree representation (PAST) used by other HLL compilers in Parrot.
This allows better integration of regex support with higher level
languages (e.g., HLL closures and variables embedded in regexes).
It also may facilitate migrating the regex engine to backends other
than Parrot at some point in the future.  Another key feature is
that the new NQP and regex implementations are largely self-hosted
-- that is, the source code is written in NQP itself, further
enhancing maintenance and retargetability.  The source code repository
for this new version of NQP and regular expression support is
currently hosted on GitHub at.

Earlier this year Jonathan Worthington and I reviewed the tasks
needed for Rakudo to migrate to protoregexes and the standard
grammar (STD.pm), as well as achieve the other critical features
needed for Rakudo Star.  Because the Raku specification has evolved
substantially from when Rakudo's existing grammar and compiler
were first started, we decided that we would likely be more
successful rebuilding Rakudo from a "fresh grammar" (including
protoregexes) rather than try to incrementally refactor the
old grammar.

This rebuilding work has been proceeding in the "ng" ("new grammar")
branch of the Rakudo repository, and thus far I am extremely
pleased with our progress and results.  The new grammar in this
branch makes full use of protoregexes (M1-2 and M2-3), and is
extremely consistent with the parsing model used by STD.pm .
Furthermore, in the new branch we have already been able to
implement critical Raku features (lazy lists, proper lexical
handling, lexical subs) that were extremely difficult to achieve
in the previous implementation.

All of the items listed for milestones M1 and M2 of the grant have
now been realized.  Over the next few weeks I expect to continue
work on (re)building the Rakudo-ng branch; when it is passing
a comparable percentage of the test suite as the existing Rakudo
releases we will officially redesignate Rakudo-ng as the mainline
development trunk.  (The ng branch is effectively the mainline
for development already -- we simply want newcomers to Rakudo to get
the "more complete implementation" in the old master branch instead
of the "rapidly catching up" version in the ng branch.)

In the process of completing this migration I also expect to
complete the remaining deliverables (D1-D7) for this grant.  To
briefly review where we are with respect to each grant deliverable:

### D1: (Implementation of protoregexes and longest token matching)

Essentially complete, with a few more improvements needed
for better longest token matching semantics inside of
regular expressions.

### D2: (Alignment of Rakudo's parser and grammar with STD.pm.)

About 70% complete.  Rakudo's grammar in the ng branch
is very close to STD.pm, with only minor additions and updates
(and redesignation of the branch as 'master') needed to
complete this task.  It's worth noting that the goal for D2
is "alignment" of the Rakudo and STD.pm grammars as opposed
to "adoption"; indeed, in several areas STD.pm is changing
to reflect some of the ideas being pioneered by the Rakudo
grammar implementation.

### D3: (Develop Raku builtins for Rakudo, p6-based "Prelude".)

Complete.  Raku now uses the term "core setting" instead
of "Prelude" for its builtin classes and functions.  Since
early 2009 Rakudo has increasingly relied on Raku-based
definitions of its builtin classes.  In the Rakudo-ng branch,
most of the builtins not already written in Raku are
placed in the "src/cheats/" directory in the expectation
that they will eventually be rewritten as Raku.

#### D4: (Develop and improve Rakudo's ability to use external libraries.)

Essentially complete, although further work is ongoing to
bring Rakudo and the compiler tools up-to-date with recent
changes to the Raku specification in this area, and to
provide further documentation.

#### D5: (Continue developing official Raku test suite.)

An ongoing task, but complete for the purposes of the grant.
At the time the grant proposal was written (September 2008),
the test suite contained approximately 7,000 tests and Rakudo
was passing 2,700 of these (38%).  As of this writing, the
test suite contains over 38,000 tests and Rakudo master
passes over 32,000 (85%).

#### D6: (Create additional tests for regex engine and library components.)

About 50% complete.  The NQP repository contains tests for the
new regex implementation and protoregexes, some additional tests
need to be written for the library interoperability components.

#### D7: (Publish weekly reports on Raku implementation progress.)

Ongoing and on track.  Although reports have not come out weekly,
there has been regular communication through our monthly release
process, updates to the Rakudo ROADMAP, the Rakudo twitter
feed, regular posts to use.raku and mailing lists, updates
to the raku.org and rakudo.org websites, and other channels.
The goal of D7 has been to ensure increased visibility into
Raku and Rakudo progress, this has been largely achieved
and will become even more apparent as we near the Rakudo Star
release in April 2010.

Thus the primary tasks remaining for completion of this grant come
from deliverables D2, D4, and D6:

1. increased alignment between Rakudo's grammar and STD.pm,
2. improved longest token matching support, and
3. update HLL library interfaces, documentation, and tests
4. write final grant summary and report

Of these, only #2 represents any significant or time-consuming
effort; the others are likely to be achieved in the normal course of
ongoing Rakudo development.  The remaining work on longest token
matching will be performed with the primary goal of meeting the
needs of the Rakudo Star release.

In summary, all of the items listed for milestones M1 and M2
of the grant have now been realized, and many items in the
remaining M3 and M4 milestones have also been completed.  The
few remaining deliverables for this grant are expected to
be achieved before the end of 2009.
