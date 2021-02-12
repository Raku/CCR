# Ramblings on Rakudo startup
    
*Originally published on [21 August 2009](https://use-perl.github.io/user/JonathanWorthington/journal/39500/) by Jonathan Worthington.*

I try and blog about each Rakudo day on the day it happens or shortly thereafter. Occasionally I fail. This post is a result of such a failure. Worse, I was silly enough to leave myself the following notes:

- Fixed a couple of minor RT tickets.
- Worked on branch to investigate eliminating reblessing into Perl6MultiSub

Which are, uh, really great for writing a blog post from a couple of months later. Anyway, since exactly what RT tickets I fixed on that day are probably not of so much interest now, plus I'd have to go and figure out what the date was and what I committed and hope the commit messages had the RT ticket IDs in, I'll instead spend a while talking about what the branch was all about. It actually didn't end up getting merged, but some of the things discovered in it have been applied already, and one of the things I explored in it is going to happen in the future anyway.

Folks playing with Rakudo will probably have noticed that our startup time is, well, not exactly stellar. Part of the blame lay with Parrot for a while, but the Parrot team have done some really great work on improving things in that aspect, and a lot of it now is that Rakudo just does a lot of work at startup. Basically, at startup, for every block (including routines) we do some setup work. One of those bits of setup work is transforming the Parrot MultiSub data structure into a Perl6MultiSub, which implements the Raku multiple dispatch semantics. What would be far better would be to create that in the first place. That needed a Parrot tweak first, which I did.

The thing is, Perl6MultiSub depends on the subs having a Raku Signature object attached to them. A `Signature` object in Raku stores details of the parameters that a block or routine takes, along with any type constraints, whether the parameter is optional or not and so forth. (Right now, some of that is duplicated in Parrot's own signature handling, but Rakudo will be moving away from that and binding entirely based upon its own `Signature` objects in the next couple of months.) And thus arose an issue: we were using multiple dispatch in various places in Rakudo, but specifying things using some Parrot syntax unrelated to the Raku `Signature` objects. Some of them were guts, but others were things that really needed to end up with Raku signatures as they'd be user facing.

Basically, the thing that really killed the branch was that there were just too many places that we'd have to tweak, and it wasn't worthwhile doing that yet. These days, we are writing more and more bits of Rakudo in Raku. We build a first stage compiler, then run it to compile the built-ins. All of those get a Raku `Signature` object generated for them. Writing a signature object by hand in PIR, on the other hand, is a lot of effort. I did work out a way to generate them for a lot of cases, and that led to ideas about caching and possible sharing of signatures, which I expect we will implement in the future. But overall, it was too much pain, considering that if we waited to do the change for some months, it'd be a bunch less painful. It has been worth keeping in mind during development since then, though, and I am trying keep us on a path that will lead to this conversion eventually.

The other big cost at startup is the creation of the signature objects. This is something that I expect will become much cheaper in the next couple of months, as I review and refactor the way we build them. I'm also considering if - or how far - we can try and do more at compile time and less at runtime in this area.

Anyway, that was a quick little look through some Rakudo guts. Hope it wasn't excessively uninteresting. And thanks to Vienna.pm for funding this Rakudo day a couple of months ago. :-)
