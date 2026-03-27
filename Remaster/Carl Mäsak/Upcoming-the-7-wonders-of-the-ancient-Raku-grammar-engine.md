# Upcoming: the 7 wonders of the ancient Raku grammar engine
    
*Originally published on [25 November 2009](http://strangelyconsistent.org/blog/upcoming-the-7-wonders-of-the-ancient-perl-6-grammar-engine) by Carl Mäsak.*

As [PGE](https://en.wikipedia.org/wiki/Parser_Grammar_Engine) is successively being replaced and superceded by *pmichaud*++'s [nqp-rx](https://github.com/raku/nqp-rx), I find myself stuck in the past, wanting to investigate how regex-based parsing has been done all this time in Rakudo. I became so hung up on it that I started [writing my own Raku port](https://github.com/masak/gge/) of it, and [gave a presentation](https://masak.org/carl/bpw-2009-gge/talk.pdf) about it at Baltic Perl Workshop.

But somehow, that wasn't enough. I want more. I plan to [write a code review](Code-reviews-a-manifesto.html) of PGE, somewhere around Christmas 2009. But before that, I'd like to blog about the things I've learned looking at the PGE code: about parsing, about parsers, and about regular expressions.

That's why, as soon as [this November thing](Here-we-go-again-another-full-month-of-november.html) comes to a conclusion, I'll be blogging about "the 7 wonders of the ancient Raku grammar engine". The intended target group is people who feel they could use a comprehensive walk through the internals of a regex parser, thus getting a firmer grip on regular expressions. I figure if I unload all such info in a series of posts, the review itself can focus more on the literary aspects of the PGE source code. Also, the series, about two posts a week, will coincide with my finishing up GGE, the PGE port.

You might ask yourself what the 7 wonders might be. I don't know yet, but I have some ideas already. Those who watched my presentation know I like quantifiers, and readers of this blog know [I have a soft spot for `OPTable` ](What-you-can-do-with-ggeoptable-that-you-couldnt-without.html). But we'll see; no need for premature solidification.
