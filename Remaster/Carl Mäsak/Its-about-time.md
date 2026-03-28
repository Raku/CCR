# It's about time
    
*Originally published on [9 April 2010](http://strangelyconsistent.org/blog/its-about-time) by Carl Mäsak.*

*jnthn*++ touched upon the subject. I thought I'd do the same. We're [rewriting the Temporal spec from scratch](https://www.nntp.perl.org/group/perl.perl6.language/2010/04/msg33480.html). It's not the first time this happens, but for some reasons, this attempt feels better than the previous ones.

Ever since the Web.pm work had its course [plotted](Week-11-of-webpm-hitomi-does-templating.html) in more detail — not to mention since the work on [GGE](https://github.com/masak/gge) — I feel I belong to the "shameless copycat" school of design. More specifically, in many domains *not* directly related to the Raku core model, our best chance of success is likely not to be oh-so-clever, but to start with something that works well in some other language (big-sister Perl, Ruby, Haskell, JavaScript, what-have-you), adapt it to Raku idioms, and ship it. In the case of Temporal, the clear winner was CPAN's DateTime, a subset of which is now in Synopsis 32.

Imitation may be the sincerest form of flattery, but basing your design on something that already works also seems a fairly safe way to make sure that the design you end up with isn't and abstraction-laden heap of wishful thinking.
