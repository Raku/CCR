# Catching up: two Rakudo Days  from December
    
*Originally published on [6 February 2010](https://use-perl.github.io/user/JonathanWorthington/journal/40161/) by Jonathan Worthington.*

Today plenty happened in Rakudo land - in fact, it was my most active day's Rakudo hacking in quite a while. *colomon*++ also made some great commits, and between us a lot of things moved forward today. For my part, hashes and pairs are in much better shape.

I wrote before that I'd got some Rakudo days left to write up; there are two of them, but I'll cover them both in this post, since some of the work crossed the two of them anyway. Here's what I got up to between them.

- Filled out attribute composition logic for role application. A good chunk of this was written in NQP - in fact, all of the role appliers are. :-) Along the way I brought roles up to speed with the attribute part of the meta-object protocol - I'd forgotten that when doing it for classes, though since we couldn't compose attributes at that time it wasn't so interesting anyway. The end result was that we could pass S14-role/attributes.t again.
- The specification states that if in a role you do inheritance, then this is just passed on to the class that the role is eventually composed in to, and added to that class's parents. We never had any support for this in master; with a neat meta-model approach it became rather easier to get it in place in ng.
- Got `BUILD` / `CREATE` fixed up a bit and added back support for `has $.answer = 42` style declarations, again through the new attribute sub-protocol.
- Got us handling non-block where blocks again, and added `Block.ACCEPTS` back - in Raku.
- We had various "helpers" to let us do some of the low-levelish stuff in PIR. This is mostly for the places where we need those things in place in order to be able to compile the rest of the built-ins that are written in Raku. However, a couple of these helpers knew too much about Parrot and too little about the meta-model, which abstracts it away. So, I re-wrote some of those in terms of the meta-model. Much cleaner.
- Before we relied entirely on Parrot for our "do we do this role" checks. However, given the unfortunate semantic mis-match between Parrot's built-in role support and what we need for Raku (I did try and influence things in a different direction back when we were doing Parrot's role support, but failed), I've been gradually working us towards not relying on those for Raku's role support. (In master, it felt to me like we have almost as much code working around the semantics of Parrot roles as we'll need to have to not use them.) Anyways, the divorce isn't quite complete yet, and it's not even a goal for the ng branch. However, I did make a notable step towards it by getting our .does checks implemented entirely in terms of the meta-model. In the long run, I'm hoping we may be able to write the entire role implementation in NQP, which helps with the even-longer-run dreams I have of Rakudo having additional backends. But that's for The Future. :-)
- Cleaned up and re-enabled sigil based type checking in signatures.

Thanks to Vienna.pm for sponsoring me to hack on Rakudo, not only for these two days, but also throughout 2009!
