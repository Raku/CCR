# November 3 2009 — doing it with style and sophistication
    
*Originally published on [4 November 2009](http://strangelyconsistent.org/blog/november-3-2009-doing-it-with-style-and-sophistication) by Carl Mäsak.*

> 126 years ago today, a gentleman bandit in the American Old West, got away with his last stagecoach robbery, but left an incriminating clue that [eventually led to his capture](https://en.wikipedia.org/wiki/Charles_Bolles):

Wells Fargo Detective James B. Hume (who allegedly looked enough like Bolles to be a twin brother, moustache included) found several personal items at the scene, including one of Bart's handkerchiefs bearing the laundry mark F.X.O.7.<br></br>Wells Fargo detectives James Hume and Henry Nicholson Morse contacted every laundry in San Francisco, seeking the one that used the mark. After visiting nearly 90 laundry operators, they finally traced the mark to Ferguson & Bigg's California Laundry on Bush Street. They were able to identify the handkerchief as belonging to Bolles, who lived in a modest boarding house.

90 laundry operators! That's endurance, if you ask me. I think my favorite quote from that Wikipedia article is this:

> The fame he received for his numerous daring thefts is rivaled only by his reputation for style and sophistication.

If you're to be a villain in the Old West, why not do it with style?

It's Temporal Tuesday. Some of you might not know what "Temporal Tuesday" means; that's because I just invented the term.

I have a long-standing project, to make a lot of things right in the Raku spec on date and time. I'm not sure I can summarize those things succinctly here; instead, just read up on [all I've ever said about Temporal on IRC](https://irclogs.raku.org/search.html?query=temporal&type=words&oldest-first=True&nicks=masak&channel=perl6&message-type=conversation) if you're interested.

Anyway, I've decided to allocate parts of the November blog spree to actually making a solid case for a Temporal change. The idea is to have something to post to p6l by the end of the month. By "something", I mean a consistent [spec](https://github.com/masak/temporal-flux-rakusyn/blob/master/S32-setting-library/Temporal.pod), comprehensive spectests, and a working Rakudo implementation.

So that's what I started on today. Here's my progress: a [test file](https://github.com/masak/rakudo/blob/master/temporal.t) and a [class](https://github.com/masak/rakudo/blob/master/src/setting/Temporal.pm).
