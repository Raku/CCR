# The Rakudo move to QAST: progressing nicely
    
*Originally published on [2012-07-19](https://6guts.wordpress.com/2012/07/20/the-rakudo-move-to-qast-progressing-nicely/) by Jonathan Worthington.*

It’s been a little while since I wrote anything here. After all the work getting the new regex engine bootstrapped and alternations having longest token matching semantics, I’ve been taking things just a little bit easier. Only a little bit though…things have still been moving along nicely. :-)

My current focus is on getting Rakudo switched over to QAST, our refreshed abstract syntax tree design and implementation. What is an AST, you may wonder? Basically, it’s just a tree representation of the behavior of a program. As we parse programs in Raku, the grammar engine builds a parse tree. This is very tied to the syntax of the program, whereas an AST is all about semantics. A chunk of code known as the actions transforms pieces of the parse tree into an abstract syntax tree. Not all elements of your program are represented in the AST, however. Declarations are handled differently, through a mechanism called the world. If you pre-compile a module, the declarative bits are serialized; the AST, on the other hand, represents things that will actually run, so it needs to be turned into code for the target runtime.

Thus, the biggest part of QAST isn’t the AST nodes themselves. It’s the code that takes them and produces lower level code for a target VM; in Rakudo’s case, that is currently just Parrot, but we’re looking forward to targeting other VMs in the not too distant future also.
QAST is the successor to PAST (Q is just *P*++), and has a great deal in common with it. This is because actually, PAST is pretty nice. So what makes QAST nicer?

- It’s implemented in NQP, not PIR. This makes it much more pleasant to work on.
- It’s much more closely integrated with other parts of the compiler tool chain, including the bounded serialization support and 6model-based type system. All of the old stuff for talking about types as just string names is dead and buried.
- Since the AST nodes are now 6model objects, we can use natively typed attributes in many places. This should lead to memory usage improvements during compilation.
- The nodes being 6model objects means we can just serialize them using the existing serialization support. Why do we want to serialize AST nodes, you may ask? There are two immediate cases we have. One is *masak*++’s macros work, when a macro lives in a pre-compiled module. The other is because we want simple routines that can be inlined into other compilation units by the optimizer to carry their AST along with them. At the moment we support this but…it’s a very restricted hacky solution. Now with QAST I can toss a bunch of code I never really liked and simultaneously get a more capable optimizer. Win.
- It’s a bit smarter about compiling lexical accesses, which will result in better code in some cases.
- It handles native types better.
- The `nqp::op` abstraction layer is now incorporated into QAST itself. This means that the optimizer and other bits of the compiler can work completely in terms of abstract operations, independent of any particular virtual machine. This will help with porting, but incidentally has made a various bits of code cleaner too.
- The `nqp::op` layer has also been unified with the notion of operations in general (what used to be pasttype). In addition to this, operations can be overridden at a HLL level (meaning Rakudo can supply its view of operations where they differ from the simpler view NQP takes). This has been put to use already in the updated box/unbox model.
- Exception handlers were somewhat coupled to blocks in PAST. In QAST the handlers model is a bit different; in my view, it’s simpler and more flexible than what came before it also.
- VM specific things are now all arranged under a QAST::VM, which provides an escape hatch where it’s needed.
- Serialization of declarative elements now takes place during the final QAST compilation phase. This is significant because it opens the door to implementing optimizations that twiddle with declarative bits of the program. In the way things were set up in PAST, by the time the optimizer got hold of things, it was already too late.

There’s various other cleanups and improvements too, but I think the list above captures a lot of the niceness.

So, what’s the current status? I decided to go with updating Rakudo first, and do NQP later on. The overall plan of attack was:

1. Get QAST nodes defined and a QAST::Compiler in place that covers a lot of what PAST::Compiler could do before.
1. Keep using the original PAST compiler to build a raku executable, the core setting and Test.pm. Then also start building a parallel version of the compiler (qraku.exe) that would use QAST.
1. Get the basic sanity tests passing using qraku (note, the core setting is compiled with the original PAST-based raku executable still)
1. Next up, start attacking the spectests, and make a significant dent into them.
1. Once it’s capable of doing so, start using qraku to compile Test.pm also.
1. Continue tackling more of the spectests, to get most of them passing again.
1. Get the optimizer up and running with QAST, and make sure it doesn’t cause any regressions to the spectests.
1. Get qraku able to compile the core setting.
1. Make the qraku code be the main compiler code (so the raku executable is now using the QAST toolchain).
1. Sync up latest changes from the main development branch, triage the remaining handful of spectest issues and module space issues.
1. Merge! Beer!

Note that these steps aren’t at all similar in size. At the moment, thanks to much hacking by *masak*++ and myself, design input from *pmichaud*++ and feedback from *moritz*++ and *tadzik*++, we’re up to steps 6 and 7. This means that Rakudo using QAST is able to compile, run and pass the majority (I’d say about 95%) of the spectests, and that we have Test.pm being compiled with QAST-based Rakudo also. My current work is updating the optimizer and taking care of the last few things that I know absolutely have to be sorted out before trying out compiling the core setting. I’m currently optimistic that by the time the weekend is over, I’ll be onto step 9. I’m hopeful that by the following weekend, step 11 will have happened, and thus the August Rakudo release will be QAST based.

The standard for this branch landing is the same as for qbootstrap and altnfa, the last two sizable branches we landed: no regressions in the spectests and module space (unless, of course, they relied on bugs that this branch fixes). So from a user perspective, there’s nothing much to fear from this change, and plenty of nice things to look forward to that it will make possible.
