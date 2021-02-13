# Grant status update
    
*Originally published on [2015-07-02](https://6guts.wordpress.com/2015/07/02/grant-status-update/) by Jonathan Worthington.*

Over the last 3 months, I’ve been working on my [Raku Development Fund grant](http://news.perlfoundation.org/2015/04/grant-proposal-perl-6-release.html). Those of you following the blog will have seen plenty of posts in that time about what I’ve been up to. This post, 3 months in, is more administrative than technical, but it contains some nice statistics. (And there’ll be another of the regular weekly-ish reports coming in the next few days!)

### Time worked

I have worked a total of 165 hours and 38 minutes. This means there are around 84 hours worth of funding remaining on the grant. I expect to deliver nearly all of these hours by the end of July.

April was by far the most productive month (75 hours). May was the month I got married, and I took time from all of my work for that, so worked only 41 hours on the grant. June was a little better (50 hours) but still around 20 hours short of what I’d hoped, largely due to poor health at the start of the month.

### Major achievements

The biggest achievement of the work so far is the implementation of NFG (Normal Form Grapheme) in Rakudo on MoarVM. Along the way, I also implemented the Uni class, which provides all of the Unicode normalization forms. The last two monthly releases of Rakudo, made in late May and late June, have had strings working at grapheme level. By now, there are no known outstanding issues in RT relating to NFG support.

Much progress has been made on improving the stability of our concurrent programming features, with various reports from users of improvement. Issues certainly remain, but a number of the most serious bugs have now been addressed.

Startup time is now decidedly lower than at the start of the grant. Measuring informally on my development machine against Perl, Rakudo now starts up in just 40% of the time taken to load Perl with Moose, and 160% of the time taken to load Perl with Moo. I’d like to note that I’m certainly not the only person to thank for these startup time improvements; some have come from other Rakudo and MoarVM contributors. And, of course, there’s room for improvement yet!

Both the startup improvements and other work have also helped to lower the base memory footprint, though we certainly have some work to go in this area. Private memory consumed by Rakudo Raku on MoarVM running the simple infinite loop program is still twice that of Perl with Moose loaded, for example. On the other hand, this is just half the memory we once swallowed. One notable improvement I worked on is getting hashes to use a good bit less memory.

### RT tickets

I’ve been addressing bugs and missing features noted in the RT queue. 85 unique RT tickets are mentioned in my work log, almost all of which had an outcome of being resolved by the work I did. They were all over the map: semantic wrongness, bad error reporting, crashes, unimplemented things, and so forth.

### Further funding needed

There’s enough funding “in the pot” for me to continue my work through July. In that time, I plan to deliver multi-dimensional arrays (including the native packed variety), further address concurrency issues, and resolve more RT issues.

I’d very much like to continue this work for the rest of the year, as we approach the Christmas release. Any potential donors may like to read more about the [Raku Core Development Fund](http://news.perlfoundation.org/2015/04/grant-proposal-perl-6-release.html).
