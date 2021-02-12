# The first day back on Rakudo
    
*Originally published on [4 November 2008](https://use-perl.github.io/user/JonathanWorthington/journal/37807/) by Jonathan Worthington.*

So, back from my vacation, it was time to dive back into Rakudo. I spent the day mostly dealing with tickets people have been filing - fixing a range of smaller problems felt like a good way of getting back into, and caught up with, the codebase. Here are the things that I've got done today.

- A while ago I wrote a patch that made it possible to use classes defined in other modules. However, this in turn broke some uses of pre-compiled modules. Today, with a fix to a Parrot segfault along the way, I did a different patch that gets us the best of both worlds for now - pre-compiled modules work again, and using modules with classes in them still works (including pre-compiled modules with classes).
- Applied a patch from *Chris Dolan* to make modules that recursively use each other not lead to infinite recursion in Rakudo. Thanks, *Chris*!
- If you match a regex against an array in Raku, it tests each element of the array and is true when at least one of them matches. For hashes, it tests each of the keys. Getting this functionality into Rakudo was requested in a ticket; I implemented it, plus added some tests.
- Fixed bug that led to exception when you tried to create an enum with just a single element in it. Added tests for this. Also noticed there weren't any tests for anonymous enumerations, so added a few (including the one-value case).
- Got classes declared with a namespace (`class Foo::Bar { }`) working - before the methods weren't stored properly. Put the test for this into spectest_regression too.
- Tweaked the fudging a bit inside one test so we could add it to spectest_regression, and added another one that we were already fully passing but hadn't got in spectest_regression. Both related to OO, which needs more tests, so it's good to get a few more.
- Enhanced `does` and `but` so they will work with instances of PMCs. This was what meant you could not do "'Today' but Monday" style things before now.  Also fixed a couple of other things in but with enums (regression). This got at least one more test passing (so we can track any further regression on that issue now).
- Closed another use related ticket; the supplied example code to show the problem now worked. It may have started working in use fixes done earlier on today, in my patch or in the patch from *Chris*.
- Looked through another couple of tickets; commented on one of them on what problem it actually exposed, though don't have a fix yet, and discussed another one on #raku to try and understand the ticket more.

Before I went away, I was rather behind on doing my Rakudo Day reports - I'll get the couple of missing ones written up and posted soon; I'm going to try and keep to posting them on the day now as I did at the start, and write them as I do stuff, rather than hacking until beyond midnight and then falling asleep before I get around to writing anything up! :-) Thanks to Vienna.pm for funding today's hacking, and to everyone who has been playing with Rakudo and sending in bugs and patches.
