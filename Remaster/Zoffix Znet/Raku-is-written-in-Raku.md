# Raku is written in... Raku
    
*Originally published on [22 January 2016](https://perl6.party//post/Perl-6-is-written-in...-Perl-6) by Zoffix Znet.*

Today, I've done something strange.

No, there weren't drugs involved, I merely sent a patch for Rakudo for a bug I reported a few weeks back. But the patch is... interesting.

First, about the "bug." Newest JSON spec lets you have anything as the top level thing. I spotted a few modules in the [Raku ecosystem](http://modules.raku.org/) that still expected an object or an array only, and the vendor-specific (possibly to be made hidden in the future) `to-json` subroutine provided by core Rakudo behaved the same as well.

One of the modules got fixed right away and today, seeing as there were no takers, I went in to fix the bug in Rakudo myself. Since I'm a lazy bum, I merely went in to that one fixed module and just copied the fix over!

But wait a second... ain't the Raku module written in Raku? How did I manage to "just copy it over"? What sorcery is this! Surely you lie, good sir!

Here are the Rakudo and the module patches one above the other. Try to figure out which one is for Rakudo:

![which one is Rakudo](http://blogs.perl.org/users/zoffix_znet/source2.png)

Give up yet? The code above the black bar is the [patch made in JSON::Tiny module](https://github.com/rakudo/rakudo/pull/687/files) and the code below it is the [patch I made for Rakudo](https://github.com/rakudo/rakudo/pull/687/files).

As surprising and amazing as it is, most of Raku is actually written in Raku! The [NQP (Not Quite Perl)](https://github.com/raku/nqp) provides the bricks and the mortar, but when it comes to the drywall, paint, and floorboards, you're full in the Raku territory.

## So what does this all mean?

I'm not a genius programmer and I'm quite new to Raku too, but I was able to send in a patch *for the Raku compiler* that fixes something. And it's not even the first time [I sent some Raku code](https://github.com/rakudo/rakudo/pull/635/files) to improve Rakudo. Each one of the <strong>actual users of Raku</strong> can fix bugs, add features, and do optimizations. For the most part, there's no need to learn some new arcane thing to hack on the innards of the compiler.

Imagine if to fix your car or to make it more fuel efficient, all you had to do was learn how to drive; if to rewire your house, all you had to do is learn how to turn on TV or a toaster; if to become a chef, all you had to do was enjoy a savory steak once in a while. And not only the users of Raku are the potential guts hackers, they also have *direct interest* in making the compiler better.

So to the [speculations on the potential Raku Killer App](http://blogs.perl.org/users/jt_smith/2016/01/perl-6s-killer-app---async.html), I'll add that one of the Raku's killer apps is Raku itself. And for those wishing to add *"programming a compiler"* onto their résumés, simply clone [the Rakudo repo](https://github.com/rakudo/rakudo) and go to town on it... there are [plenty of bugs to squish](http://rt.perl.org).
