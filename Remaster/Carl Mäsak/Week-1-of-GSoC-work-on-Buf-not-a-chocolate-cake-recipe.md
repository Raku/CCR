# Week 1 of GSoC work on Buf — not a chocolate cake recipe
    
*Originally published on [28 May 2010](http://strangelyconsistent.org/blog/week-1-of-gsoc-work-on-buf-not-a-chocolate-cake-recipe) by Carl Mäsak.*

No-one likes to trawl through long grant progress reports that read like a recipe for chocolate cake, but without the chocolate cake. So I'll be mercifully brief.

- [Implemented](https://github.com/rakudo/rakudo/commit/c5fdb17fb3e642ef2789fa4ef5b27be72295d267) `Str.encode` and `Buf.decode`.
- Discovered two things in Parrot from doing Buf.decode. The first was a bug which *bacek*++ fixed quickly.
- The second was that [Parrot can't decode lists of bytes](https://irclogs.raku.org/perl6/2010-05-28.html#13:29). That's why [test 8](https://gist.github.com/masak/417142) fails. We've been [discussing](https://irclogs.raku.org/parrot/2010-05-28.html#13:46-0006) [how to](https://irclogs.raku.org/parrot/2010-05-28.html#14:23) [proceed](https://irclogs.raku.org/perl6/2010-05-28.html#14:41) from here.

By the [plan](https://gist.github.com/masak/360097) I'm supposed to work on constructors and indexing now, but I gravitated towards the Str.encode and Buf.decode stuff because that's where I left off last time I worked on this. There's still plenty of time next week to do the constructors and indexing.

Not used to writing a report this small. But I think I like it. 哈哈

(What, this thing? Yes, it so happens it's a [chocolate cake](https://www.kevinandamanda.com/best-chocolate-cake-recipe/). No, you can't have any. Get your own.)
