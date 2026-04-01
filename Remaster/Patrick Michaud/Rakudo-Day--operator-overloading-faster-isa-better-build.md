# Rakudo Day:  operator overloading, faster isa, better build
    
*Originally published on [28 August 2009](https://use-perl.github.io/user/pmichaud/journal/39543/) by Patrick Michaud.*

July and August have been really busy months with conferences and
vacations, so I've fallen a bit behind on Rakudo days for my 
Vienna.pm grant.  However, now my travels are largely finished and
the kids are back in school again, so I'm hoping I can manage at
least two Rakudo days per week until I'm caught up with the
original schedule.

This week's major task did indeed need two days: I've now enabled
operator overloading for many of Rakudo's builtin operators.
Previously Rakudo has allowed some custom operators to be
defined, but overloading the builtin operators (such as infix:<+>)
would generally result in "Null PMC in find_method" errors.

The main approach I ended up taking for this was to re-implement
most of the existing operators (previously written in PIR) as
Raku multisub definitions with inline PIR.  This ended up being 
somewhat more difficult than it might sound or appear from simply
reading the patch -- part of the challenge is that if any variant
of an operator is written using Raku multisubs, then all of them
must be written that way.  But since we had been generating PIR
for the Whatever and Junction variants of some builtins, that meant
rewriting those versions as well (and figuring out a way to get
Rakudo to create WhateverCode objects from the setting).

Anyway, the hardest pieces are now done, so that many of the built-in
operators can be overloaded with custom variants.  I'm sure a lot of
people will start taking advantage of those; for example, I'm hoping 
that [SF](https://lastofthecarelessmen.blogspot.com)</a> will be 
able to update his [Vector class](https://lastofthecarelessmen.blogspot.com/2009/08/perl-6-class-vector.html) to overload the builtin operators now.

There are still some operators that need to be moved to the setting;
although I've been able to migrate prefix:<-> and prefix:<~>, attempting
to do the same with prefix:<+> causes a failure in one of the spectests.
We'll keep plugging away at it until we figure it out.

I"m also seeking clarification about the definitions of some of the
relational ops; for example, infix:<==> and infix:<eq> are defined in
terms of the infix:<===> operator, but I'm curious about the definitions
of the other relational ops.

One item that greatly concerned me about moving the operators into the
settings was the possibility that it would significantly slow down Rakudo,
because subs compiled from Raku result in a lot more code than
hand-written PIR subs do.  I even explored some ways to be able to
automatically rebless PIR multisubs into Rakudo equivalents.  However, 
I decided to just try the Raku approach (we'll ultimately need to do
that anyway), and I was pleasantly surprised that the changes didn't 
result in significant speed hit to the spectests.  Indeed, my timings
show that the use of the Raku versions may in fact be slightly
faster.  I'm not sure how this can be possible, but my best guess at this
point is that Rakudo's custom multisub dispatcher (which Jonathan 
wrote as part of his [Hague Grant](https://news.perlfoundation.org/post/hague_perl_6_grant_request_tra) is somehow significantly faster
than Parrot's default multi-dispatch.  But that's just a guess on my part...

Speaking of speed, yesterday I also finished and committed another 
significant change to Parrot's "isa" functions for testing if a PMC 
is an instance of a given type.  For a long time Parrot has used 
type name (string) comparisons to check isa membership; this is 
not only a bit slow,
but it can also result in unwanted type name collisions.  Ideally
the comparison should test the identities of the class objects;
but getting this to work required cleaning a few other pieces of
Parrot's object and class handling.  When it was all finished we
obtained a ~4.5% overall speed improvement in Rakudo's spectests.

Lastly, I've done some more work on improving Rakudo's build and
install environment.  We now have Rakudo building from an installed
Parrot, and yesterday I improved Rakudo's `Configure.pl` so that
it warns with a more useful error message if the files needed from
a Parrot devel installation aren't present.

Next I'll need to review the ticket queue again to see how many
tickets have been resolved by the above changes.  I'll also want
to see about adding the tighter/looser/equiv traits to user-defined
operators.  But mainly I'm glad that we can now start to do some
more advanced operator handling and overloading in Rakudo.

Thanks as always to Vienna.pm for sponsoring this work.
