# A few words on Raku versioning and compatibility
    
*Originally published on [2016-02-09](https://6guts.wordpress.com/2016/02/09/a-few-words-on-perl-6-versioning-and-compatibility/) by Jonathan Worthington.*

Recently, I put together a set of [guidelines for Raku versioning and backward compatibility](https://gist.github.com/jnthn/c10742f9d51da80226fa). They have been refined with input from the Raku community. Together, they amount to a read of over 4,000 words, and are fairly detailed. You can consider this post a TL;DR version of the guidelines, giving the big picture idea of what they mean.

### There’s more than one thing to version

In common with many languages, Raku has a clean separation of language version and compiler version. Just as C has language versions like C89, C99, and C11, Raku has versions 6.c, 6.d, 6.e, and so forth. To compile C you might be using GCC, Clang, MSVC, or something else, and these have their own version schemes. To compile and run Raku you’ll for now probably be using Rakudo, which has monthly releases with a boringly predictable naming scheme: 2015.11, 2015.12, 2016.01, etc.

### Raku language version = a test suite

A given Raku language version is defined by a test suite. An implementation that passes that test suite can claim to *provide* that version of the Raku language. Rakudo 2015.12 was the first release to provide Raku.c, because it passed the test suite. Rakudo 2016.01 also passes the test suite, and thus provides Raku.c too.

The `master` branch of the test suite represents the latest development of the Raku language. Language releases are represented by tags (implying that 6.c, for example, is immutable).

### Programs may declare which version they want

The first statement of a program (either a script or a module) may contain a `use` statement requesting a particular language version:

```` raku
use v6.c;
````

Implementations are required to refuse to run code for versions of Raku they do not provide.

### No language version declaration implies latest released version

Pretty much self explanatory. Asking for nothing in particular gets you the latest and greatest Raku version the implementation has to offer. Meaning that 20 years down the line, people wanting to show off the latest things won’t have to prefix all their example snippets with `use v6.n`.

Module installers/directories may be more demanding, and require modules to specify a language version. That’s a decision for the those making such tooling.

### An implementation may support many language versions at once

Assuming that we release a 6.d sometime during 2016 (remember that this means “release a test suite defining what 6.d is”), then Rakudo 2016.12 will provide both Raku.c and 6.d. To do that, it will be required to pass both the 6.c and 6.d test suites.

### Implementations will need to go to moderate effort to do this

New syntax (new operators, new phasers, etc.) introduced by 6.d should not be available to a program declaring `use v6.c`. This is to ensure that the syntactic additions do not cause breakage. For example, adding a `DONE` phaser could break any code that had a `DONE` sub and called it with listop syntax. Rakudo will, for now, support this by guarding such syntax in the parser with a version assertion. (Another strategy is to ship multiple parsers, presumably loading “on demand” those that are actually needed.)

Lexical aspects of the `CORE.setting` (the builtins) get the same treatment. Recall that in Raku, the builtins are not imported, but rather are in the outer lexical scope of the program. If 6.d adds new subs, different implementations of subs, new classes or roles, or new constants, they should go in a `CORE.d.setting`, or some equivalent. Implementations are free to choose exactly how they will structure things. In Rakudo, we’ll retain `CORE.setting` with the “base” set of things, and have a `CORE.d.setting` that overrides and adds or overrides things as needed for 6.d. This means that new Raku language versions can change the behavior of existing operators or subs in ways that are not backward compatible, without breaking code that declared in a `use` statement it wants a previous version of Raku.

Late-bound things (methods, dynamic variables) have different rules. See the full guidelines for the details, but the upshot is that 6.designers have a bit less flexibility in how they evolve methods on built-in types compared to subs, syntax, etc. Backward incompatible changes (as judged by the test suite) are not allowed; new methods or new overloads that don’t conflict with existing behaviors are. The other key difference is that no effort is made to “hide” methods added as part of newer versions of Raku from callers using an earlier version of the Raku language.

TL;DR, supposing you have a module that declares `use v6.c`:

- The onus is on Raku implementations to not let your program run into 6.d syntax changes or new subs/constants in the builtins
- The onus is on you to not use methods that did not exist in 6.c. However, tooling will probably come to exist to help out (for example some kind of `Module::FlightCheck` that uses rakudobrew to grab the 2016.01 release, which is known to support nothing later than 6.c, and run your module’s tests on it).

If you think the second part of this sucks, then read the guidelines to get an idea why the alternatives all suck harder. :-)

### Long Term Support and security releases

Rakudo releases every month, and since each release will provide a range of Raku language versions by passing their official test suites, then in a sense every one is an “official” release. To be very clear, there is no release we should talk about as being “the 6.c release of Rakudo” or “the 6.d release of Rakudo” (though some folks probably will anyway, no matter what I say, and they’ll most likely mean “the first Rakudo release that supported 6.c” or so).

What we *will* do is declare some releases as “Long Term Support” releases. This label will be applied to releases some time after they have been made, so we can support releases that we know behaved reasonably well in the wild – at least in their first month or so “out there”. For example, suppose that 2016.02 is fairly well received. We might declare it a LTS release, and we’ll declare with that the period of time we intend to “support” it for.

What does support mean? It means that, in the event of security patches or serious bug fixes, we’ll produce bug compatible releases of all current Long Term Support versions of Rakudo. For example, suppose 2016.02 and 2016.10 were marked as LTS releases for a period of 12 months. In December 2016, we find a serious security bug in Rakudo. We’d release a 2016.02.1 and 2016.10.1, which would branch from the 2016.02 and 2016.10 tags and have the required patch(es) cherry-picked in. This would allow upgrades to get the security fix with a very high degree of confidence that existing code will not break.

### Minor language versions

One thing we’d prefer to avoid is people declaring dependencies in their Raku code on particular compiler versions. There’s no way to prevent it, but we can try to reduce the temptation to do so. The typical use case would be wanting to depend on a particular bug fix. Fixes get coverage in the language test suite, and so will be part of the next language release – but since the major language versions will tend to have at least a year between them, that could be a bit too long to wait.

Therefore, we’ll also have minor language versions, named 6.c.1, 6.c.2, etc. These give something implementation-independent to depend on. Chances are these will be needed more in the short term than in the long term.

### What will we market?

Major language versions, primarily. We’ll use minor language versions to focus on incremental improvement and refinement. The interesting “next big thing” will be the major language versions. Each major language version will get a name. We’ve picked celebrations as the naming theme; 6.c was “Christmas”, and 6.d will be “Diwali”. (That doesn’t mean we’ll be pushing ourselves to actually ship it anywhere near where Diwali falls in the calendar. We already did that with Christmas, taking care to release on Christmas day.) So, look out for a talk on “What’s coming in Raku Diwali” at some conference later on in the year. :-)

### Trying out the future

One question the above raises is how to try out the latest implementation work towards the next major version. For that, we’ll use versions such as 6.d.a (6.d “alpha”). So:

```` raku
use v6.d.a;
````

Will get you access to the stuff we expect to be in 6.d. Note these lettered versions will really be giving you the current work in progress and come with absolutely no backward-compatibility or stability promises, and support for them will be dropped swiftly after the actual language release of 6.d.

### Where will new spectests go? Do I need to tag them somehow?

In the `master` branch of the repository of all spectests, and they need no tagging up besides the usual fudging. Released language versions are handled as tags, which are immutable.

### Are the spectests really enough to specify a language?

I think they’re the best tool we have for the job at the moment. We might want to look towards property based testing ala QuickCheck some more, but that’s still a test-based approach. Natural language doesn’t have the precision, but more critically lacks the verifiability (that is, you can’t run a Raku compiler against a natural language specification). Formal methods, such as operational or denotational semantics, offer greater precision than tests, but the intersection of people who know how to apply those and who want to contribute to Raku is probably tiny. Certainly they lack the accessibility of a test suite expressed in Raku, and so would take us away from the goal of Raku being a community’s language.

All that said, it’s fairly clear we need anywhere between 2 and 10 times the current number of tests to have comfortable coverage of both the language and its wide array of built-ins. We’ll be looking into coverage analyses to help us understand where those tests are most lacking.

### You didn’t answer my really important question about Raku versioning!

Then leave a comment, and maybe I’ll do a follow-up post to answer it. :-)
