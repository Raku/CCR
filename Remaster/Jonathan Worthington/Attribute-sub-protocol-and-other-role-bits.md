# Attribute sub-protocol and other role bits
    
*Originally published on [10 December 2009](https://use-perl.github.io/user/JonathanWorthington/journal/39997/) by Jonathan Worthington.*

Work in the ng branch continues; this post is an update on some of the work I've done on a slightly broken-up Rakudo Day (things have been a tad disrupted while I've come over to England for the month).

Perhaps the most exciting bit of news is that I've done an implementation of the attribute meta-protocol. The main upshot of this is that we now don't hard-code the creation of accessors, but rather call a `compose` routine on the `Attribute` object - the meta-object that represents an attribute - and it does the accessor creation. Amongst other things, this opens the door for custom accessor generation, which I believe is something that many Moose extensions do, and so will be useful for Raku meta-programmers. As a bonus, the `Attribute` class is implemented in NQP, not PIR.

I've also continued working on roles. I'm happy to say that, unlike in master, we implement the `does` and `but` operators - which do runtime mix-ins of roles - in Raku now. They don't actually do much - the heavy lifting is done by the `RoleToObjectApplicator` class. That one is implemented in NQP, with only one small Parrot-specific bit. It feels great to be writing these bits in something higher level, and - importantly - means they're all building on a fairly small set of primitives rather than having deep magic everywhere.

In other smaller bits of news, I got the dotty form of `.=` working, and also implemented the `.^` dotty operator too (which makes metaclass calls prettier).

All in all, I'm fairly happy with how things are shaping up. I'm hoping another Rakudo-day sized push and we'll be able to run many of the roles related tests again, but this time atop a much cleaner and more correct implementation, a large part of which is in Raku (or NQP, which is a subset of Raku). Thanks to Vienna.pm for sponsoring this work.
