# Meta-programming slides, and some Rakudo news
    
*Originally published on [2012-03-09](https://6guts.wordpress.com/2012/03/09/meta-programming-slides-and-some-rakudo-news/) by Jonathan Worthington.*

I’m just back from a trip to the German Perl Workshop. Of course, the food was great and the beer was greater. :-) I was also very happy to see various Rakudo hackers in person; *moritz*++ was one of the organizers, and *tadzik*++ attended and gave a talk also. Much fun was had, and some hacking happened too. :-)

You may be interested to check out the [slides from my talk on meta-programming in Raku](http://jnthn.net/papers/2012-gpw-meta-programming.pdf). It covers some of the things we’ve been able to do for a while, as well as having a new example that shows off an interesting use of bounded serialization in combination with meta-programming. Also, I have now submitted this talk to the French Perl Workshop, which will take place in June. :-)

As for Rakudo progress, here’s some of the things that have been going on.

- The bounded serialization branch has landed (and thus will be in the next release)! This has, as hoped, greatly decreased Rakudo’s startup time – an improvement that has been welcomed by a bunch of folks on #raku. Module and setting pre-compilation is now also faster, along with loading of pre-compiled modules. Win all around.
- Thanks to the serialization, various things have been unblocked. Amongst them, the constant declarator now takes non-literals on its RHS, and the `BEGIN` and `CHECK` phasers now work in r-value context. In both cases, the values are serialized if these things are done in a pre-compiled module.
- *masak*++ merged his initial work on macros. While there’s much more to do in this area yet, it’s great that we now have the basics in place, enabling declarations of macros and quasis. I’m sure masak will blog about this soon – keep a lookout for it.
- *tadzik*++ has got us some support for the `Set`, `Bag`, `KeySet` and `KeyBag` types.
- *moritz*++ cleaned up match handling, and also implemented the :exhaustive and `:nth` match adverbs. So, that’s two out of three branches mentioned in my last post landed. :-)
- Stunning progress on phasers! We now support `ENTER`, `LEAVE`, `KEEP`, `UNDO` and `START`. The `LEAVE`, `KEEP` and `UNDO` drew very heavily on work by *mls*++. Additionally, `FIRST`, `NEXT` and `LAST` are supported inside for loops (though not yet available in other loops). I’m fairly fired up to do `PRE` and `POST` too, though need some spec clarifications first.

*moritz*++ has also been continuing his excellent typed exceptions work; we discussed how to handle typed exceptions in the metamodel during the workshop, which should extend their reach to cover even more of the errors that can crop up.

So, all in all, lots of progress, and we’ve still just under two weeks to go until the March release. Having landed the bounded serialization work, I’ve been enjoying doing some feature development; right now, I have a branch that is muchly cleaning up name handling, improving name interpolation and getting various of the missing pseudo-packages in place. I expect to have this work completed in time to go in to the release also.

Beyond that, it’ll be time for me to dig back into some of the fundamentals again. Most immediately, that will be getting QRegex to be the engine we use to parse NQP and Raku code (currently, we use QRegex for compiling the regexes and grammars you write in your Raku programs, but still use the previous generation engine for parsing Raku source). This will allow us to eliminate a vast swathe of Parrot PIR code that we depend on (the new regex compiler is written in NQP), aiding portability. I aim to land this in time for the April release; I’ve already done significant pieces of the work towards it.

Probably somewhat in parallel with that (though set to land after it), I’ll also be taking on our AST and AST compiler. This work will see it being ported from PIR to NQP, switched over to use 6model objects (which means we can use natively typed attributes to make the nodes more memory efficient, and also serialize the nodes as macros require) and given much better handling of native types. Generally I’m hoping for compilation performance improvements and better code generation. This will also eliminate our last large PIR dependency, thus clearing the final hurdle for making a real stab at targeting an extra backend.

One slight slowdown will be that I’m taking a vacation during the second half of March. I’m going to a land far away, and plan to spend most of my time seeing it, and checking out their food and drink. The laptop is coming, though, so it won’t be a complete stop; my stress levels are happily in fairly good shape right now, so I don’t need my vacation to be a complete break with normality, just a refreshing change of scene. :-)
