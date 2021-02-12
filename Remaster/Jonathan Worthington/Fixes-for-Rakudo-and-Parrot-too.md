# Fixes for Rakudo, and Parrot too
    
*Originally published on [6 December 2008](https://use-perl.github.io/user/JonathanWorthington/journal/38035/) by Jonathan Worthington.*

This week's Rakudo day arrived, and I dug in to RT to see what I could do.

First, I ran accross a ticket that reported a problem with assignment of match objects. I thought we'd have fixed it while doing the assignment refactors, and after a quick check I found that we had. However, it seemed we didn't have any tests for that (unless I missed them), so I added some more. In doing so, I noticed that a test that relied on being able to check a Match object was of type Match failed. A one-line patch to Rakudo soon resolved that one, and later in the day I found a second ticket explicitly about that issue that the same fix also resolved.

I then dug into a something that I thought would be a short job, but that then ended up swallowing up much of the day. Such are things when you end up in Parrot guts. For a variety of reasons, we've ended up with Perl6Str - a PMC - along with Str - the actual string class. There's not that much that we implement in C that is Rakudo-specific, but there is the odd thing that we do that way, and thus the PMC's existence. It subclasses the default Parrot String PMC, and `Str` subclasses Perl6String and also `Any`. From the Rakudo point of view, the fact it inherits from anything other than Any is really an implementation detail, hidden away. The problem I was aiming to resolve was that, in a bunch of places - in fact most of them - we were creating Perl6Str rather than Str.

Simply switching them over caused a bunch of test failures. Loads of them. The first thing I discovered was that `isa` didn't always give the right answers when you inherited from a PMC. That was an easy fix, and then showed up a small bug in RakuObject (our implementation of the Raku metamodel) that had relied on `isa` being broken. I did an initial fix that I thought would deal with it, later realized it wasn't quite right and then did the correct one (was all a bit subtle). More serious bugs lay ahead, however: not only had Parrot not always been giving correct results for `isa`, but also it got MMD wrong when you were using a high level class that inherited from more than one level of PMC. It partly boiled down to a bit of implementation marked TODO in the code that makes PMCs feel more like high level classes. I got that working, but the fact that we were now building the correct MRO exposed some more code that relied on that bug. Wondering if it would ever end, I patched that, and found myself back with a working Parrot and Rakudo, with Perl6Str references now replaced with `Str`. Needless to say, Parrot has done pretty well out of today's fixes. Of course, Rakudo depends on Parrot working well, so diving in to sort things like this out now and then is worthwhile (I could have tried to paper over this lot, but it would only have bit us another month or two down the road in a different way anyway, I'd expect). I also found and deleted some now-useless code in object initialization, which will maybe shave just a little time from it.

One side-effect of the changes is that the previously failing test for using the `is also` trait on the `Str` class now passes: you can add a new method and then do `"foo".my_extra_method`. Resolving this bug is another reason I set out on switching to using `Str` in the first place - I just hadn't expected it to lead that that many other fixes.

With much of my day sucked up by that, I dug into the RT queue. I found some tickets that had already had the issues they described solved, and closed them up, to keep the queue a bit cleaner. I then took on a segfault that *Simon Cozens* (who has been doing some great work on Raku database interaction) discovered. Fixing up the problem in Rakudo was a one-line addition (it was a bug using attributes declared without a twigil).

However, Parrot really shouldn't segfault and I wanted to make sure it failed more gracefully next time. Looking in the debugger showed we were looking at garbage data, but didn't help me see why. Then I found that if I got the compiler to just spit out PIR, then tried to compile that PIR, it turned out it was invalid. A trace later, I realized that even if the PIR compiler bailed out at some point, it still tried to run the :init subs in the not-finished-compiling-yet bytecode. We now check if the compile actually succeeded before trying to run the resulting maybe-code!

I'd wanted to do more in Rakudo itself today, but ran out of time to finish anything more after that lot. I did, however, start work on a patch to get a much wanted feature:

```` raku
class Foo {
    has $.x = 42;
}
````
In place. That is, being able to set the initial value for an attribute. I'm not done yet, and I'm really too tired to finish it off properly today (having a bit of a cold doesn't help either), but maybe I can get it done over the weekend.

Thanks to Vienna.pm for funding today's fixes.
