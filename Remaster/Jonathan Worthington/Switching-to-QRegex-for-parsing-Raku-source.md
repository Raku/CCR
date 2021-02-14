# Switching to QRegex for parsing Raku source
    
*Originally published on [2012-05-26](https://6guts.wordpress.com/2012/05/26/switching-to-qregex-for-parsing-perl-6-source/) by Jonathan Worthington.*

I planned to blog when I finished hacking on Rakudo stuff today. The headline has shifted about three times during the day, however, as I was able to make progress much faster than expected. Well, also because I was having fun and have stayed up doing this until 3am… :-)

### So, what am I up to?

Since last summer, Rakudo has used two distinct regex engines. One is QRegex. If you’ve been writing grammars and regexes in Rakudo, you’ve been using it. It’s the shiny new one, doing LTM (Longest Token Matching) with an NFA, tracking the (now very occasional) regex spec changes and getting new features. It is implemented in NQP. The other one is far older, doesn’t do LTM apart from for literal prefixes, and is written in PIR. We’ve continued to use this for parsing Raku source in Rakudo, as well as parsing NQP source in NQP.

I think it goes without saying that we’d rather have just one regex engine, and that working in a high level language is much more productive. So, we’ve wanted to switch everything over to QRegex for quite a while. At the same time, there’s been many other more pressing things to do, so the switch has been a “nudge it along now and then” project.

The work towards this has been ongoing for a few months in the qbootstrap branch in the NQP repository. The “q” comes from QRegex, but why “bootstrap”? Well, because there’s a fun little bit of circularity going on here. QRegex is written in NQP, but at the same time we want to use it as the engine for parsing NQP. It has to be able to parse and compile itself. Mix that with bounded serialization, and you need to make darn sure you’re doing your separate compilation right. Anyway, if you were wondering, “why didn’t you write it in NQP in the first place”, now you know why. You have to be able to parse NQP before you can write a program in NQP. :-)

Anyway, here’s what I thought I’d be excitedly reporting earlier on today.

### Finally, the “qbootstrap” branch bootstraps!

This is a really nice milestone. In the last couple of days, I’ve been picking away at the qbootstrap branch, tracking down the last test failures, trying to make sure that an NQP built with QRegex was going to be able to compile itself. Not just that, but also that the compiled output would in turn be able to compile itself again. Finally, I managed to get there today. If you build the qbootstrap branch in NQP now, the only regex engine you’re using is QRegex. The older one isn’t built in the branch; in fact, the files are removed just to be really sure all was working properly.

And that would have been a nice thing to report, but…

### The Rakudo compiler executable builds on NQP/qbootstrap!

It was always clear that Rakudo would need changes. Having got an NQP that does everything with QRegex to hand, I set it on building the Rakudo compiler. Note that when I say compiler, I do not mean CORE.setting – the 11,000+ line library with all the built-ins. Just the core of the compiler itself.

I was ready for trouble here. Rakudo’s grammar is notably more complicated than the one in NQP. However, in the end it was all relatively painless. A few updates to syntax, a few tweaks to use updated libraries, and…it built! That didn’t mean it had produced a parser that would actually work, of course. But that it got through all of the compiler source with so few complaints was very encouraging.

So, I thought, with that done, why not hack on? And so now…

### The Rakudo CORE.setting builds on NQP/qbootstrap!

This took more effort. I was ready for this to take O(days), not O(hours). Especially when the first thing I got was a segfault a fraction of a second in to the compilation process. Thankfully, that turned out to be an easy fix. And then we got up to…line 106 and failed. What was wrong?

After tracing what the protoregex LTM calculations were doing, it soon became apparent it was trying to wrong branch first. Happily, though, the fix was to delete a lookahead. Even nicer, it was one we had got in order to work around lack of proper transitive LTM in the previous regex engine. Well, that was a win. Onto the next failure…

Over the next couple of hours, I tracked down and fixed a variety of issues, some in the grammar and some in QRegex itself. And finally…it built! But what about the spectests?

### The spectest fallout is not too bad

The first run through the spectests looked horrible, with over a third of the test files – if not more – showing up with issues. Thankfully, I quickly realized that many of them shared a common and easily fixed root cause, due to a bug in handling a very common syntactic construct (quote words, of all things!)

The second run – and the way things stand now – looks much better. Out of over 600 test files, less than 30 exhibit failures that will need to be investigated. To say that within the last 24 hours I didn’t even have QRegex able to build NQP, this is great progress. Of course, while I’ve spearheaded this part of the work, much credit must go to *pmichaud*++, who built the vast majority of QRegex.

### The plan from here

Earlier, I expected in this post to be saying there’s a 50/50 chance we’d ship the June Rakudo release with QRegex used for parsing. By now, I’d say there’s at least a 90% chance we will do so. The next monthly compiler release isn’t until the 21st of June; I’d want to land such a big switchover at least two weeks before that, and that currently feels very achievable. I’ll keep you posted.

### What does this actually mean for Rakudo end users?

This work isn’t so much about immediate wins as it is about having a good base to build another round of user-facing improvements atop of. That said, there will be some nice improvements available right away.

- The work done in the qbootstrap branch has vastly improved protoregex handling. The NFA evaluation currently stands at around 15-20 times faster, and the NFA construction is now transitive into subrule calls to other protoregexes (both a correctness and parse performance win). Your own grammars will benefit from these improvements.
- Parsing Raku is a pretty decent stress test for the engine, and of course showed up some bugs, with have been fixed. Again, this improves the experience for those using grammars and regexes in Rakudo.
- Having one regex engine in memory instead of two should give a slight memory usage reduction.

Here’s some of the follow-up things that will come along as a result of this.

- Once some of the “get stuff working” bits of the implementation are optimized, Rakudo should be able to parse Raku source faster than before.
- Work on precedence traits for user defined operators should now be unblocked.
- Further convergence with the way STD parses things should be possible.
- We can start considering how to implement things like slangs.

Further, if one of the things you’re looking forward to is Rakudo running on a VM besides Parrot, then this work also eliminates one of our last two large components written in PIR.

Anyways, it’s decidedly now time for some sleep. ‘night!
