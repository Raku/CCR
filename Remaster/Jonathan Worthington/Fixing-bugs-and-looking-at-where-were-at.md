# Fixing bugs, and looking at where we're at
    
*Originally published on [5 August 2008](https://use-perl.github.io/user/JonathanWorthington/journal/37107/) by Jonathan Worthington.*

My Rakudo day last week finished with some useful discussions with *Patrick* on IRC fairly late into the European evening, and after them I felt too tired to write this report coherently. Finally, today I'm playing catch-up. :-) It was another day of fixing various little things, and also one of discovering that there are a few bigger items that it really would be useful to implement soon. The things that got done are:

- Implemented the `.eof` method on IO handles.
- Investigated the breakage of the `prefix:<:=>` operator. The previous implementation was a quick bit of work to get some basic IO working, and relied on other bits of Rakudo being in an early stage. Now those other bits are more advanced, we can't cheat any more, and thanks to me not getting a test in place for `prefix:<:=>, it got broken. I have made it now do the right thing in item context (read one line from the handle), however in list context (which is where you most want it), I'm afraid it remains broken (though you can use .eof now and write a while loop, at least). To fix it properly needs us to implement lazy lists, and there is no easy cheat that is much less work than just implementing lazy lists.
- The `self` keyword can now be used in nested scopes inside a method; that it didn't work was one of the small but surprising annoyances when writing OO code in Rakudo.
- Fixed a bug in Parrot that was blocking something *Patrick* was working on.
- Many spectests do things like `ok Foo.new` to check if an object was instantiated from a class. Before we didn't support evaluating objects in boolean context, so you'd get an exception (you may have encountered this when using the command line interface too). This is now fixed.
- I did a basic implementation of the `===` and `!===` operators, plus implemented the `WHICH` method on some of the immutable types. This was enough to pass pretty much all of the tests written specifically for this operator. However, there are tests of it in other test files that don't pass yet (for example, comparing two junctions with `===` doesn't yet work).

I also spent some time reviewing what tests we were skipping in spectest_regression. This is the target that runs the tests that we expect to pass, though with some thing skipped (the idea is that we can tell if a change just introduced a regression to what we were already passing). From reviewing that, I added a section to the ROADMAP file that details what needs doing to unskip the vast majority of them. A lot are smaller tasks that might be a good starting point for anyone wanting to dig into Rakudo.

For my Rakudo day this week, I will probably make a branch and take an initial stab at lazy lists. I'll do it in a branch as it will be a little messy, probably break various tests for a while and I know that *Patrick* will want to have input. We'll have plenty of time at YAPC::EU to hack on it together, but having a first cut there to play with and work on would probably be a good starting point and bring out some of the issues. Plus I expect I'll deal with some other little bits too.

Finally, I'll take the opportunity to note that Rakudo now is passing 2,100 spec tests, and to thank Vienna.pm for funding this (and for yet another wonderful tech/social meet last night...I so love living close enough to attend not just one, but two PM groups!)
