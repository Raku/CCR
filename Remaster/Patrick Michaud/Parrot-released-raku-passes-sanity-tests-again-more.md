# Parrot released, raku passes sanity tests again, more!
    
*Originally published on [18 December 2007](https://use-perl.github.io/user/pmichaud/journal/35140/) by Patrick Michaud.*

Happy birthday, Perl!

On this 20th birthday of Perl, I'd like to express my appreciation to Larry Wall (and his family) for the many years of leadership, dedication, wit, wisdom, and sacrifice that he has put into Perl.  Of course, there are many more people who deserve our thanks for Perl, too many to list here, but Larry has always been a fixture of the community and I'm so thankful for his efforts.

Today Parrot 0.5.1 (Hatachi) was released, and quite frankly it's another big leap in Parrot and Raku development.  So much has happened since my last journal post of a week ago that it's hard to know where to begin!  The big news is that as of today the raku compiler is once again passing all of the 00-parrot and 01-sanity tests, so we can begin attacking the official test suite again.  In other news:

* Jerry Gay made even more progress on the Punie (Perl 1) compiler under Parrot, using PCT and NQP he managed to get slurpy arguments working, and all of the tests passing.  To me this is a signature achievement, and it shows that the compiler tools (PCT, PAST, and NQP) are working as we had intended.

* Jerry has also been instrumental in getting raku to pass its test suites again, particularly in adding constructs to the grammar, including "for", regexes, "END", and the like.  So, we're passing the basic test suite again.

For those who might be concerned that we seem to have done a lot of work "just to get back to where we already were", I can only say that from an ease-of-development the raku compiler we have now is far ahead of what we had before.  Unlike the previous compiler, we're finding that new features are easily added to the system, and that many changes aren't requiring me to shepherd many of the low-level details.  For example...

* Flavio Glock joined the Parrot effort this week in a big way, and has been exploring NQP and raku and how they can fit in with the KindaRaku (kp6) effort.  Flavio has brought us many useful ideas and insights from kp6, and today he added BEGIN blocks to the raku compiler.  We've also got some initial ideas about handling `eval` in raku, which will be very useful.  Right now we're blocking on some issues dealing with lexical variable handling, but Jonathan Worthington has said he'll take a look at that.

* Jonathan Worthington has also been eager to play with junctions in Raku, so earlier this week he added an early implementation of a Junction object type.  It even works for some simple things, although it doesn't yet do any sort of autothreading.  On top of that, Jonathan also added postcircumfix:( ) (subroutine call), postcircumfix:{ } (hash index), and a working implementation of the '&' sigil.  Of course, what I really liked best about this were [his frequent comments about how easy and fun it was to work with the raku compiler](https://web.archive.org/web/20080224235108/http://www.jnthn.net/cgi-bin/blog_read.pl?id=589).  That makes me feel good.

Oh, and by the way, Jonathan also managed the Parrot 0.5.1 release today.  Great work!

* chromatic implemented the "copy" opcode that we'll be needing to properly handle assignment in raku and other compilers.  That was likely to become a huge obstacle to getting things to work properly, and I'm glad the ball for it is back in the PAST/raku court so that we can finish that off.

As for me, most of what I've been doing is answering questions on IRC and doing any refactors or cleanups that need to be done to allow others to implement features.  So, I worked on things like
   * getting :slurpy to work in PAST (needed for Punie and raku)
   * getting raku to talk directly to PGE again for regex matching
   * refactoring block generation in raku to better handle formal params
   * refactoring the PCT::HLLCompiler object and PAST/POST compilers to be a bit saner
   * describing various changes/improvements we're likely to want in Parrot

So, it's been a very productive week, and I'm hoping this next week can be equally productive.  The things I plan to focus on for this week:

* some more documentation and articles about PCT, PAST, and NQP, and getting started with raku (including more detailed notes for new hackers)

* Scott Duff (PerlJam) has an article half-written about Raku regexes that is waiting for a usable implementation, so I'd like to see raku get far enough along that he can publish his article based on raku

* Jeff Horwitz is doing lots of amazing things with mod_parrot, and he says that if we can get modules working in raku that he'll be able to write mod_raku in Raku.  So, 'module' is high on my list of things to accomplish.

* Of course, we're going to return to the effort of getting raku to pass as many of the official Raku tests (from the pugs test suite) as we can, and refactoring tests as appropriate.

Stay tuned, take a look at the pieces that are coming together, and if you can, come join the fun!
