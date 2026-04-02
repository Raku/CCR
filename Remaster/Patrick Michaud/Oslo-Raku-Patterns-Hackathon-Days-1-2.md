# Oslo Raku Patterns Hackathon, Days 1-2
    
*Originally published on [22 April 2012](https://pmthium.com/2012/04/oslo-perl-6-patterns-hackathon-days-1-2/) by Patrick Michaud.*

For the past couple of days I’ve been in Oslo, Norway, attending the Raku Patterns Hackathon sponsored by [Oslo Perl Mongers](https://oslo.pm), Jan Ingvoldstad IT, and NUUG Foundation. A lot of things are happening at the hackathon, as you’ll see below.

First, Oslo itself is every bit as nice as I remember from attending the [Nordic Perl Workshop](http://www.perlworkshop.no/npw2009/) in 2009 (and another hackathon that took place then). And once again, the hackathon organizers (Jan, Karl, Salve) — have done an amazing job in making sure that all of us at this hackathon can remain productive at working on Raku as well as having a good time while we’re here. The food, facilities, and hospitality have been outstanding.

*moritz*++ and *jnthn*++ have already [blogged](https://perlgeek.de/blog-en/perl-6/2012-oslo-hackathon-report.html) [about](../Jonathan\ Worthington/Hackathoning-in-Oslo.html) their work thus far at the hackathon; here are a few other things that have taken place while we’re here:

- Friday morning I noticed in the latest Rakudo compiler release notes that autovivification of hashes and arrays still wasn’t fully implemented in the nom version of Rakudo. So, I spent a bit of time early Friday confirming with *jnthn*++ and *masak*++ about some autovivification edge cases, and then implemented the rest of what we need from autoviv. So, that’s an important feature restored.

- *jnthn*++ worked on getting the :i (:ignorecase) flag working for interpolated literals in regexes; I helped a bit with that, but in the process noticed just how bad things were for people who had Parrot compiled without ICU. There were lots of failing spec tests and problems with doing case-insensitive regexes matches, even for simple strings. The crux of the problem was that Parrot simply threw exceptions for case conversions of several Unicode encodings whenver ICU was present, even if the strings involved had only ASCII or Latin-1 characters.  I noticed that this problem affected several of the people attending the hackathon today (including *jnthn*++), so I decided it could not be allowed to live.  So, I added a patch to Parrot that enables more case conversions when ICU isn’t present, as long as all of the codepoints involved are in ASCII or Latin-1 (which the majority of them are). If ICU is present, Parrot continues to use ICU, but if ICU isn’t available, Parrot is at least able to handle case conversions for most of the strings we encounter.

- We had a lot of relative newcomers to Raku today,  *masak*++ took some time to give them all an excellent tour of the [Raku universe](https://raku.org).  Based on masak’s introduction, several of today’s attendees were able to quickly start contributing some very useful additions to Raku and Rakudo.

- Marcus Ramberg vastly improved the “-h” option to the Rakudo executable, listing many more of the available and useful options. Then Marcus and *tadzik*++ fixed up the “–doc” option as well, which extracts documentation from the program code and displays it in a readable form.

- *masak*++ stumbled across a bug involving comparisons of Pair objects with uninitialized variables; we ultimately tracked it down to an issue of comparing things against +Inf and -Inf. A couple of short patches fixed that problem.

- Geir Amdal added some methods to IO to retrieve file stat times from the operating system. We had these method in the Beijing release but they had not yet been ported to nom — it’s good to have them back.

- Salve (*sjn*++) and several other hackers started a project of developing a much better set of reviewed examples for newcomers to examine. I pointed out the Raku examples repository (which hasn’t had updates in quite a long time) and suggested they work on adopting/reorganizing it. At sjn’s suggestion, *moritz*++ added the push hooks so that commits to rakuxamples show up on the #raku channel, and throughout the day we were all treated to seeing improvements to the existing examples and hearing very useful comments about what the folks were seeing and experiencing there.

- *sjn*++ also asked about how one would determine the Rakudo version number from within a program; while that information has been somewhat available via `$*RAKU.version`; it wasn’t really in a useful form. So, late this evening I reworked the implementation of `$*RAKU` somewhat so that it’s possible to determine the compiler, compiler version, compiler release number, and other information. *moritz*++ also at one point needed a way to determine the version of nqp being used to build Rakudo; I didn’t add it yet but will squeeze that in tomorrow. I’m not entirely happy with the way `$*RAKU` is set up now; hopefully we can get some design and specification clarifications for it soon. At any rate, compiler version information is now available to programs to examine.

- On a related note, while reviewing version number information in Synopsis 2 I noticed that there’s a Version class we don’t yet implement — it doesn’t seem too hard to add so I may prototype one tomorrow.

- *jnthn*++ and I were able to spend some much needed time plotting out the next moves for the AST implementation, currently called QAST. QAST is part of the nqp implementation, and is the successor to PAST (part of the Parrot repository). Some of the refactors we’ll be able to make in QAST look like they will enable huge improvements in speed, readbility, and writability of compilers in NQP. (See [*jnthn*++’s blog post](../Jonathan\ Worthington/Hackathoning-in-Oslo.html) for more details on QAST.)

There’s of course much more that happened, including many bug fixes and improvements, but those are some of the bigger items. I’m hoping to find some time tomorrow to chase down some largish bugs in Rakudo’s regular expression engine, to ease the pain further for others. I think we may also have a discussion about Rakudo’s List implementation and its features and next steps.

My thanks again to Salve, Jan, and Karl for organizing this hackathon — it has really enabled us to resolve some long standing issues and make good plans for the next phases of development.
