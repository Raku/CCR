# Pushups, repetition, and newbies
    
*Originally published on [22 March 2010](http://strangelyconsistent.org/blog/pushups-repetition-and-newbies) by Carl Mäsak.*

A while ago, I found a website called [one hundred pushups](https://hundredpushups.com/), with the help of which you're supposed to be able to build enough arm muscle strength to be able to perform 100 pushups in a row.

The way the site goes about helping you reach this goal made me think about Raku, because... well, because everything does. 哈哈 But really, there's something to take away from the method employed by this site.

I'm on [week 4](https://hundredpushups.com/week4.html) now. If you'll have a look at that page, you'll see it's basically just three tables with numbers, one table for each of the three days of exercise in the week. Week 3 is also just three tables. Week 2 and week 1 are also just three tables each. *All the weeks are just a set of three tables.* The whole website is just built around eighteen tables of suitably increasing numbers. I don't even read the rest of the text on the pages anymore, I just look at the numbers.

If there is any such thing as a "secret" to exercise, it's *repetition of tasks within one's limits*. I can't do 120 pushups, but if I'm allowed minute-long breaks, I can do 24 pushups five times. (I'll still be exhausted, but compare that to trying to do them all at once — I wouldn't be able to finish.) It's pretty clear to me that, primitive as those tables may be, they do have the desired effect.

The connection to Raku programming? Well, I can't write a grammar engine implementing the whole of Raku regex behaviour. That's crazy talk; I have no prior experience whatsoever. But give me half a year of tinkering, about five or six refactorings and 250 commits, and things at least slide within the range of [the possible](https://github.com/masak/gge).

*viklund*++ and I couldn't just sit down and write a wiki engine in Rakudo in 2008, because no-one'd written *anything* in Rakudo in 2008... but give us a quiet summer and fifteen weeks of recurring meetups of sitting down and toying around, each week solving a little problem of some sort... eventually we ended up with something that you could [log in edit pages](https://github.com/viklund/november) with.

Perhaps even more similarly, I guess it would take me a full week or so to submit 700 Rakudo bugs, if I spent eight hours a day on it, giving each bug five minutes. Of course, bugs are not discovered with a frequency that'd make that possible, but even if they were, I'd probably hate the whole job halfway through Monday. As it is now, it's quite fun to be the masakbot. Bleep bloop.

And that's the thing. When you do things frequently but always within the range of your abilities, it doesn't *feel* like productive work, it doesn't *feel* like learning, and it doesn't *feel* like progress. But it is. I've learned more as a programmer in these past two years than in any other two years of my life, just because *I come back and do little things I already know how to do, in new and slightly different ways.* And I do that a hundred times a month. It adds up.

We've been getting some new nicks on the `#raku` channel lately, and a common question is: "I want to learn/help/contribute. Where do I start?". The real answer to that is "Well, if you have to ask...", but we're friendly so we don't say that. We often end up saying a variant of the following:

> Stick around, look for something that catches your fancy (app writing, blogging, writing tutorials/docs, compiler development, sharpening the spec, submitting bug reports, tending the test suite, hugging trolls) and then just do that, for as much and as long as you want. Most importantly, have fun!

Though not meant that way, it may come off as a bit dismissive, as if we didn't care what the newcomer does, or didn't care where resources are being invested; but the real reason we answer like that is that we hope that our new gal or guy will find a sweet spot where they can just come back and do things again and again with small variations and it just stays fun and inspirational, like a child's game or a relaxing hobby.

Because that's how a lot of us are passing the time on `#raku`. In a constant state of play; because that's how we and Raku grow the fastest.
