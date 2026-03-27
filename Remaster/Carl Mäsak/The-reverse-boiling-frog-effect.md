# The reverse boiling frog effect
    
*Originally published on [20 July 2009](http://strangelyconsistent.org/blog/the-reverse-boiling-frog-effect) by Carl Mäsak.*

We don't always notice improvements when they happen individually over a long time. It's sort of a reverse [boiling frog](https://en.wikipedia.org/wiki/Boiling_frog) effect.

Seven months ago, around New Year, I tried out an idea of mine in Rakudo. The exercise dug up a lot of bugs, and I [blogged about it](Scripters-now-is-the-time.html). A few days ago, I tried the same thing again. The code is not yet ready to be pushed, so I can't show you (sorry), but I wanted to share how different it is to write in Raku on top of Rakudo now, as compared to half a year ago. I hadn't realized how much had happened.

You see, I took a look at my 100 lines of code from December/January, and immediately thought *this calls for a rewrite*.

My new solution was based around classes. It was much neater. The old code contained some pretty hefty workarounds related to array indexing. Nowadays, classes work much better, and the array indexing bug is long gone. The encapsulation into classes also made for a cleaner design, standing on the shoulders of which I could solve my problem a little further than last time.

The blog post I wrote in December was called "Scripters, now is the time!" because Rakudo was 20% an interesting development platform and 80% in need of eyeballs to dig up shallow bugs. Now, half a year and [1264 Rakudo-commits](https://github.com/rakudo/rakudo/commits/) later, I feel the figures have been reversed. What's nice is that I can still call out "Scripters, now is the time!" and mean it just as much. Rakudo rocks a little more each day.

Come [join the party](http://rakudo.org/).
