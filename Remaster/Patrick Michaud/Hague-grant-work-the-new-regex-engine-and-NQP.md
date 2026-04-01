# Hague grant work: the new regex engine and NQP
    
*Originally published on [21 October 2009](https://use-perl.github.io/user/pmichaud/journal/39779/) by Patrick Michaud.*

It's been quite a while since I've written any articles about
Rakudo's progress, but the delay in articles has been because
I've been really focused on code development for a number of
things we're going to need quickly for 
[Rakudo Star](Building-a-"useful-release-of-Raku".html)

At long last I've made the time to make substantial progress on my 
[Hague Grant](https://news.perlfoundation.org/post/tpf_awards_first_hague_grant_t), 
which will enable us to bring Rakudo's grammar and parser much
more in line with the current 
STD.pm grammar.
In fact, looking at the
Rakudo ROADMAP
one can see that a significant number of the critical tasks needed for
Rakudo Star are depending on the "PGE refactors" identified in the
grant.

This brings me to one of the major points of this post:
In the weeks that follow this month's release we expect that
Rakudo will be quite unstable as we undertake some much-needed
refactoring and redevelopment of some of Rakudo's core pieces.
The biggest change will be a complete replacement of Rakudo's
underlying grammar; the grammar we have today is still largely
based on the Raku grammar as it existed in January 2008, but
STD.pm and the Raku specification have evolved significantly
since then.  

Jonathan and I believe that now's the time
to bite the bullet and make another big refactor to bring Rakudo
in line with the spec, even though it will likely involve a
rework of many features and perhaps a few significant
(but temporary) regressions.  So, if you see some chaos and
upheaval in Rakudo development in the next few weeks, it's
a planned and necessary sort of mayhem.

Many of the needed grammar changes will be possible because
of the grant work on protoregexes and a new operator precedence
parser.  Originally the plan was to build these features into
the Parrot Grammar Engine (PGE), but after thinking long and
hard about it I concluded that it would
be better to redesign and reimplement a new regex engine than
to try to fix PGE.  For one, I think maintaining backwards
compatibility would be a significant challenge (and a drain
on my energy and resources).  Another reason favoring a
rewrite is that we now have better language tools available
for Parrot, and a rewrite can take advantage of those tools.

Thus, instead of compiling directly to PIR, the new regex
engine compiles to Parrot's abstract syntax tree
representation (PAST).  In addition, the source code
for the regex engine is written in NQP instead of PIR.

For those not familiar with NQP, it's a Raku-like language I
designed for Parrot in conjunction with the Parrot Compiler
Toolkit.  NQP acts like a "mini Raku", it understands a
subset of Raku language constructs and can generate Parrot
code that doesn't rely on additional runtime libraries.
Most of the HLL compiler authors for Parrot have been using
NQP to generate PAST, and it's proven to be much easier to
write and maintain than PIR.

Since the regex engine will now be written using NQP, it 
also seemed fitting that NQP would receive the ability to 
use Raku regexes and grammars directly.  Adding regexes
and grammars to the NQP language means that a compiler writer
can write nearly all of the components (parser, ast conversion, 
runtime libraries) using NQP.  This is in contrast to the existing
setup that requires multiple languages and APIs.

The new version of NQP is currently called "nqp-rx" ("NQP with regexes");
I may come up with another name for the bundle but I'm somewhat
attached to "NQP".  This new version also has a new source code
repository (separate from Parrot) -- it's [hosted on GitHub](https://github.com/Raku/nqp).

Since mid-September I've been working on nqp-rx, and I'm very
pleased with how it's all coming together.

For example, late last week I completed most of the work on 
the new regex engine.  This first version includes a very naive
implementation of protoregexes, which PGE lacked, and ultimately 
should perform pattern matching and parsing more efficiently than PGE does.  
It now compiles to PAST instead of directly to PIR, which means
it will fit more cleanly with the rest of Rakudo, especially
with being able to handle lexical variables and code blocks in
regexes.

More importantly, the regex compiler is **self-hosted** (or 
"bootstrapped").  In other words, the regex engine is able to 
parse and compile the specification that was used to build 
itself.  Stated another way, the regex engine is written 
using Raku grammars and regular expressions that it knows 
how to compile.

Since completing the regex bootstrap I've been working on 
creating the new version of 
NQP based on the new regex engine.  Over the weekend I created
some common rules for parsing number and quoted string tokens,
and yesterday and today I completed a new operator precedence
parser (all of these based on the STD.pm equivalents).  Now
all of the pieces are in place to create a new NQP compiler,
which I plan to do over the next couple of days.  And, like 
the regex engine, I'm planning to make this new version of 
NQP self-hosted as well.

So, when all of this is completed, NQP will continue to be a 
"Raku lite" language, but it will also support grammars, 
regular expressions, protoregexes, longest token matching, 
a very powerful operator precedence parser, attributes on
classes, and a fair bit more.  It should
also be a bit faster than the previous NQP, and have a few
additional optimizations (such as inlining of blocks).  

Thus, here's a quick rundown of the status and plan for
the next couple of weeks:

- Parrot 1.7 was released today (October 20)
- Jonathan has just completed [a significant refactor of Rakudo's signature binding code](../Jonathan\ Worthington/The-new-Rakudo-signature-binder-has-landed.html) and merged it into Rakudo's master.
- Scott Duff ("PerlJam") will be cutting the October Rakudo release on Thursday, based on the Parrot 1.7 release.
- Immediately following the Parrot release, new code for the Parrot Calling Conventions is set to be merged to the Parrot trunk.  This is one of the major tasks (B) listed in Rakudo's ROADMAP.
- In the days following the Rakudo release, we'll be working to synchronize the multidispatch and binding algorithms in Rakudo with the new Parrot calling conventions.
- Also in the next few days, we'll complete implementation of nqp-rx, or at least bring it to the point that it can be used instead of the previous compiler tools for building Rakudo.
- When we're comfortable that the Parrot calling conventions work has sufficiently stabilized, we'll start a new branch for the major refactor of Rakudo's internals, switching to the new compiler tools, and updating the grammar to be much closer to STD.pm.
- We don't know how long this last piece will take, but it could easily occupy most of the month before the November Rakudo release.
- During the time that work is taking place in the branch, we don't expect much progress or changes to be made in Rakudo's master branch, so that people can continue to use and test the "more functional" version.
- If work bogs down in the branch, we'll regroup and come up with an alternate plan.  But I don't think this likely.

It looks to be an exciting couple of weeks!  I'll be writing 
more articles with details about the new regex engine, NQP
implementation, and Rakudo conversion to the new tools.
I hope and expect that by the November release we'll be 
completely switched over to the new regex engine and
have knocked out a large number of the "critical" items 
on the ROADMAP for Rakudo Star.
