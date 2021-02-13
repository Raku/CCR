# NQP and 6model: big steps forward on Parrot and JVM
    
*Originally published on [2011-01-16](https://6guts.wordpress.com/2011/01/16/nqp-and-6model-big-steps-forward-on-parrot-and-jvm/) by Jonathan Worthington.*

Despite spending a chunk of the last week fighting off a pesky throat infection, it’s been pretty productive. Here’s a quick update on where things have got to.

Mostly, I’ve been working on getting nqp-rx (the Parrot implementation of the NQP language, which is the base that Rakudo is built on today) to use 6model. In my last post I set a goal that by the end of the month, all uses of the “class” keyword would be switched over to using 6model. Since NQP is bootstrapped, this is kind of a baptism by fire: to switch the class keyword to use 6model, it needs to be stable and complete enough to handle the use that the NQP compiler makes of classes. Happily, I’ve managed to pull this off during the last week – far sooner than I had expected. So if you build nqp-rx/nom today and run the tests, then you’re using 6model not only in the tests, but during the building of NQP itself.

That would be an exciting week in itself, but wait – there’s more! I also managed to port much of the multi-dispatch support introduced in the .Net CLR version of NQP/6model over to nqp-rx on Parrot too. The caching is missing, errors need improving and there’s the odd rough edge but overall it works. Both for multi subs and multi methods, with the correct proto semantics and including dispatch by arity, by type and using the :U/:D definedness constraints. This is a big step forward not only for nqp-rx, but also because it lays the foundation for introducing the new proto semantics and dispatch-by-definedness into Rakudo too.

This weekend, *mberends*++ came to visit and hack with me. Shortly after I announced my intention to work on 6model and an NQP implementation on the .Net CLR, he expressed an interest in porting that work to the JVM. While there’s been ported code showing up in the repo for a while, there’s never been anything actually runnable…until this weekend. Today, for the first time, 6model on JVM managed to run the meta-model bootstrap, a cut-down version of the NQP setting successfully initialized itself…and say(“hello world”) ran. \o/ Happily, a few test files run and pass already too.

Now that something actually runs, it’ll be a lot easier – and more rewarding – to hack on. A lot of the work is initially getting it up to the level of NQP on the .Net CLR – which of course will be a moving target. ;-) If you are interested in contributing to a Raku on JVM implementation, this is a good time to jump on board; getting NQP running and bootstrapped on the JVM is the first step on the path to Rakudo on the JVM. Get in touch with mberends if you want to help.

On the subject of helping, if NQP and Rakudo on the .Net CLR is more (or also :-)) your thing, then see my [file of low hanging fruit](https://github.com/jnthn/6model/blob/master/dotnet/LHF.txt) – tasks that should be relatively accessible and self-contained.

Finally, as planned, I wrote an [overview of 6model](https://github.com/jnthn/6model/blob/master/overview.pod). It discusses the motivation and scope, design principles and – at a high level – the architecture of it.

So, not a bad week. And what do I plan to do in the week to come? Mostly, work more on nqp-rx/nom:

- Tie up some of the multi-dispatch loose ends
- Get NQPClassHOW to publish a method cache, which should make things a bunch faster
- Get nqp-rx’s grammar keyword switched over to using 6model
- Start the planning for natively typed attributes

I’m also planning to do some more bits in NQP on the .Net CLR (of note, use the type context bits I added to avoid some more needless boxing/unboxing). Fun times! :-)
