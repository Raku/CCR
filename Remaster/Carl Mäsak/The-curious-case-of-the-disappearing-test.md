# The curious case of the disappearing test
    
*Originally published on [28 September 2016](http://strangelyconsistent.org/blog/the-curious-case-of-the-disappearing-test) by Carl Mäsak.*

I've recently learned a few valuable things about testing. I outline this in my Bondcon talk &mdash; Bondcon is a fictional anti-conference running alongside YAPC::Europe 2016 in a non-corporeal location but unfortunately frozen in time due to a procrastination-related mishap, awaiting the only speaker's tuits &mdash; but I thought I might blog about it, too.

Those of us who use and rely on TDD know to test the software itself: the model, the behaviors, etc. But as a side effect of attaching TravisCI to the 007, another aspect of testing came to light: testing your repository *itself*. Testing code-as-artifact, not code-as-effect.

Thanks to TravisCI, we currently test a lot of linter-like things that we care about, such as four spaces for indentation, no trailing whitespace, and that `META.info` parses as correct JSON. That in itself is not news &mdash; it's just using the test suite as a linter.

But there are also various bits of *consistency* that we test, and this has turned out to be very useful. I definitely want to do more of this in the future in my projects. We often talk about *coupling* as something bad: if you change component A and some unrelated component B breaks, then they are coupled and things are bad.

But some types of coupling are necessary. For example, part of the point of the `META.info` is to declare what modules the project provides. Do you know how easy it is to forget to update `META.info` when you add a new module? (Hint: very.) Well, we have a test which double-checks.

We also have a consistency test that makes sure a method which does a certain resource-allocating thing also remembers to do the corresponding resource-deallocating thing. (Yes, there are still a few of those, even in memory-managed languages.) This was after a bug happened where allocations/deallocations were mismatched. The test immediately discovered another location in the code that needed fixing.

All of the consistency tests are basically programmatic ways for the test suite to send you a message from a future, smarter you that remembered to do some B action immediately after doing some A action. No wonder I love them. You could call it "managed coupling", perhaps: yes, there's non-ideal coupling, but the consistency test makes it manageable.

But the best consistency check is the reason I write this post. Here's the background. 007 has a bunch of builtins: subs, operators, but also all the types. These types need to be installed into the setting by the initialization code, so that when someone actually looks up `Sub` from a 007 program, it actually refers to the built-in `Sub` type.

Every now and again, we'd notice that we'd gotten a few new types in the language, but they hadn't been added as built-ins. So we added them manually and sighed a little.

Eventually this consistency-test craze caught up, and [we got a test for this](https://github.com/masak/007/commit/7baadd110c3fd844b902f469e1c93bc0426e31fa). The test is text-based, which is very ironic considering the project itself; but hold that thought.

Following up on a [comment by vendethiel](https://github.com/masak/007/commit/31b531946cc513476cbb9c8d966a08be35c6767c#commitcomment-17801202), I realized we could do better than text-based comparison. On the Raku types side, we could simply walk the appropriate module namespaces to find all the types.

There's a general rule at play here. The consistency tests are very valuable, and testing code-as-artifact is much better than nothing. But if there's a corresponding way to do it by *running the program* instead of just *reading* it, then that way invariably wins.

Anyway, [the test started doing Stash traversal](https://github.com/masak/007/commit/fe2ebe5a632446012ecff660de59af19132e9b1f), and after a [few](https://github.com/masak/007/commit/c36ca643f7d998369cb15716a2f32f7d6903d5c8) more [tweaks](https://github.com/masak/007/commit/68a91ab60f3dfb7ec7972621cb0e9b5cc2f31937) looked really nice.

And then the world paused a bit, like a good comedian, for maximal effect.

Yes, the test now contained an excellent implementation of finding all the types in Raku land. This is *exactly what the builtin initialization code needed* to never be inconsistent in the first place. The tree walker [moved into the builtins code itself](https://github.com/masak/007/commit/d622d372d4dfd10a705d978f940e16673eeaedd2). The test file vanished in the night, its job done forever.

And that is the story of the consistency check that got so good at its job that it disappeared. Because one thing that's better than managed coupling is... no coupling.
