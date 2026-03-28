# Weeks 4 and 5 of GSoC work on Buf — chrono-flies
    
*Originally published on [28 June 2010](http://strangelyconsistent.org/blog/weeks-4-and-5-of-gsoc-work-on-buf-chronoflies) by Carl Mäsak.*

Chrono-flies (*Drosophila chronogaster*, commonly known as "time-flies") are known for their fondness for arrows. Lately I've been distracted enough (by `$DAYJOB`, other Raku projects, and other non-Raku projects) to let two weeks pass by with only one commit in my local branch:

- `Buf` is now `Positional`, and you can index it with `postcircumfix:<[ ]>`.

I merged/pushed that one a few moments ago.

For good measure (pronounced "only one commit! how'd that happen?"), I did some pre-investigation this evening as to how one might read binary data from a file into a `Buf`. [*cotto*++ outlined how](https://irclogs.raku.org/parrot/2010-06-28.html#20:49-0002). Haven't finished thinking about this, but it does seem perfectly doable, which is a notch better than I feared. 哈哈

Also, worth noting here: remember how in Week 2, I [changed the `Buf` constructor spec](Week-2-of-gsoc-work-on-buf-the-power-of-swedish-beer.html) from slurpy array to non-slurpy array? Well, [pmichaud wondered why](https://irclogs.raku.org/perl6/2010-06-27.html#21:16-0005), and it led to an interesting discussion. Will synch up with jnthn to see if it perhaps merits changing back for consistency with other list-y types.
