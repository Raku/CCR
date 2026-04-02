# New regex engine for nqp and nom, now passing 7K spectests
    
*Originally published on [14 July 2011](https://pmthium.com/2011/07/new-regex-engine-for-nqp-and-nom-now-passing-7k-spectests/) by Patrick Michaud.*

Nom and nqp now have a new regular expression engine (currently known as “QRegex”) that I’ve implemented over the past week.

As progress continued on the [new “nom” branch of Rakudo](New-NQP-repository-new-nom-Rakudo-branch.html) since my [last posting](More-nom-features-and-spectests-still-5x-faster-than-master.html), it was becoming increasingly evident that regular expression support would end up being the next major blocker.  I think we were all expecting that nom would initially use the same regular expression engine that nqp (and nqp-rx) have traditionally used.  However, as I starting working on this, it began to look as though the amount of effort and frustration involved would end up being almost as large as what would be needed to make a cleaner implementation up front, and would leave a quite messy result.

So, last week I started on designing and implementing a new engine. Today I’m happy to report that nom is now using the new QRegex engine for its pattern matching, and that making a new engine was undoubtedly a far better choice than trying to patch in the old one in an ugly manner.

So far only nom’s runtime is using the new regex engine; the nqp and rakudo parsers are still using the older (slow) one, so I don’t have a good estimate of the speed improvement yet. The new engine still needs protoregexes and a couple of other features before it can be used in the compilers, and I hope to complete that work in the next couple of days.  Then we’ll have a good idea about the relative speed of the new engine.

I’m expecting QRegex to be substantially faster than the old one, for a variety of reasons.  First, it should make far fewer method calls than the old version, and method calls in Parrot can definitely be slow.  As an example I did some profiling of the old engine a couple of weeks ago, and the “!mark_fail” method accounted for something like 60% or more of the overall method calls needed to perform the parse.

Qregex does its backtracking and other core operations more directly, without *any* method calls for backtracking.  So I expect that this one change will reduce the number of method calls involved in parsing by almost a factor of 3.  Other common operations have also eliminated the method call overhead of the previous engine.

The new engine also uses a fixed-width encoding format internally, which means that we no longer pay a performance penalty for matching on unicode utf-8 strings.  This will also enable us to eventually use the engine to do matching on bytes and graphemes as well as codepoints.

I also found quite a few places where I could drastically reduce the number of GCables being created.  In some cases the old engine would end up creating multiple GCables for static constants, the new engine avoids this.  A couple of new opcodes will enable QRegex to do substring comparisons without having to create new STRING gcables, which should also be a dramatic improvement.

I’ve already prototyped some code (not yet committed) that will integrate a parallel-NFA and longest-token-matching (LTM) into QRegex, so we’ll see even more speed improvement.

And did I mention the new engine is implemented in NQP instead of PIR?  (Although it definitely has a lot of PIR influence in the code generation, simply by virtue of what it currently has to do to generate running code.)

Ultimately I’m expecting the improvements already put into QRegex to make it at least two to three times faster than its predecessor, and once the NFA an LTM improvements are in it ought to be even faster than that.  And I’ve already noted new places ripe for optimizations… but I’m going to wait for some new profiles before doing too much there.

Another key feature of the new engine is that the core component is now a NQP role instead of a class.  This means that it’s fairly trivial for any HLL to make use of the engine and have it produce match objects that are “native” to the HLL’s type system, instead of having to be wrapped.  The wrapping of match objects in the old version of Rakudo was always a source of bugs and problems, that we can now avoid.  Credit goes to [Jonathan Worthington](http://jnthn.net/) for [6model](../Jonathan\ Worthington/NQP-and-6model-big-steps-forward-on-Parrot-and-JVM.html), which enables QRegex to do this, and indeed the ability to implement the engine using roles was what ultimately convinced me to go this route.

While I’ve been working on regexes, Moritz Lenz, Will Coleda, Tadeusz Sośnierz, Solomon Foster, and others have continued to add features to enable nom to pass more of the spectest suite. As of this writing nom is at 244 test files and 7,047 tests… and that’s before we re-enable those tests that needed regex support.  The addition of regexes to nom should unblock even more tests and features.

Some of the features added to nom since my [previous post on July 2](More-nom-features-and-spectests-still-5x-faster-than-master.html):

- Regexes
- Smart matching of lists, and other list/hash methods and functions
- Fixes to BEGIN handling and lexicals
- Implementation of nextsame, callsame, nextwith, callwith
- More introspection features
- Methods for object creation (.new, .bless, .BUILD, etc.)
- ‘is rw’ and return value type checking traits on routines
- Auto-generation of proto subs
- Junctions
- Backtraces

We’ve also done some detailed planning for releases that will transition Rakudo and Rakudo Star from the old compiler to the new one; I’ll be writing those plans up in another post in the next day or two.
