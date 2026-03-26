# Attitude
    
*Originally published on [8 February 2009](http://strangelyconsistent.org/blog/attitude) by Carl Mäsak.*

Moritz seems to have an uncanny ability to get me to blog lately, with just a single line of IRC conversation. Last time it was [a tongue-in-cheek suggestion](Three-bugs-that-bug-me-right-now.html) for how to draw attention to blocker bugs. This time it was a light-hearted but oh-so-true comment on my complaining, for the N-th time, about being [blocked in various places](https://irclogs.raku.org/perl6/2009-01-29.html#12:42), with no-one to fix my bugs for me:

```raku
<moritz_> in the old days you'd just worked around it
```

I proceeded to explain to him why these particular bugs were non-workaroundable, and he had the cheerful audacity to suggest workarounds for them. Hrm.

It was somewhere around then that I realised that I had lost that industrious spirit that helped us build November last summer, despite all the obstacles at that time. Dang.

Several thoughts have struck me since then. The expression "it is a poor workman who blames his tools" applies here; I should complain less and JFDI more. In a way, rakudobugs and their corresponding workarounds actually help code quality in our projects, because we have a very legitimate reason to return to a particular piece of code and rewrite it when the rakudobug is fixed. But for that to work, "just write a `# RAKUDO` comment and move on" has to be the dominant paradigm.

Another is the Swedish expression "Det är inte hur man har det, utan hur man tar det". (Loosely, "Attitude trumps situation.") By which I mean, the more I complain about bugs which block me, the more it will *feel* that way, with less code being written as a result.

It turns out that at least bug number three in [that last blog post](Three-bugs-that-bug-me-right-now.html) wasn't an absolute blocker by far. I managed to rewrite that code, and I believe [the end result](https://github.com/masak/druid/commit/5444d9fa17a0419770899a3b4de773a0285f09ee) even became more readable, on top of actually working as intended. Damnit, even the saying "every obstacle is an opportunity in disguise", despite being such a clichéd cliché, applies here.

I haven't had much time to look at the two other bugs in the list, but it wouldn't surprise me if they, too, are more a question of having the right attitude than of anything else. If nothing else, I'll just write a `# RAKUDO` comment and move on.

Lastly, just because I'm one of the heaviest Rakudo abusers in the world, that *still* doesn't give me the right to expect anything in terms of feature implementation speed or bug fixing speed. It's an open-source project, propelled by people who do it for their love of the Raku idea, or because they secured that grant, or both. Rakudo has been coming along nicely during the last half year, but due to a combination of circumstances its core devs just haven't been available very much in January. I must learn to accept that.

In the end, I'm glad I realised that I'd gone from industrious workarounditude to excessive complainulexity; in the future, I'll try and re-focus on the former, because I believe that's the way I can best help the Rakudo effort along.

Nobody can take your mojo from you. Except perhaps yourself.
