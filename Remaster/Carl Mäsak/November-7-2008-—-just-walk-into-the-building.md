# November 7, 2008 — just walk into the building
    
*Originally published on [8 November 2008](http://strangelyconsistent.org/blog/november-7-2008-just-walk-into-the-building) by Carl Mäsak.*

101 **[Update: no, 91. *kaare*++ for noticing]** years ago today, it was October 25 in Russia. (Yes, I know that seems awfully odd until you learn about the [Julian calendar](http://en.wikipedia.org/wiki/Julian_calendar) they used at that time and place.) The Bolshevik takeover of government buildings had begun already the day before, but on this day the Winter Palace, the seat of the Provisional government, was captured.

The Winter Palace is located in [Saint Petersburg](http://en.wikipedia.org/wiki/Saint_Petersburg) (Санкт-Петербург), coincidentally the birth town of my late grandmother. At the time, it was called Petrograd (Петроград), and after 1924 up until the fall of the Soviet union, it went by the name Leningrad (Ленинград).

[Wikipedia](http://en.wikipedia.org/wiki/October_Revolution) on the takeover:

> Later official accounts of the revolution from the Soviet Union would depict the events in October as being far more dramatic than they actually had been. (See firsthand account by British General Knox). Official films made much later showed a huge storming of the Winter Palace and fierce fighting, but in reality the Bolshevik insurgents faced little or no opposition and were practically able just to walk into the building and take it over.

Things to do before I die: just walk into the main government building of a country and take it over.

Today, continuing on the theme from [yesterday](November-6-2008-—-making-waves.html), I implemented `.fmt` in Rakudo. The patch is sitting in the [RT](https://github.com/Raku/old-issue-tracker/issues/393), awaiting *pmichaud*++'s review.

I must admit that apart from furthering Rakudo, this kind of work is quite far from core November work. It helps Rakudo grow and evolve, but it doesn't do very much for November, since the general rule there is pretty much "do whatever works", so two ways to do something are not significantly better than one way. `.fmt` is just a wrapper to `sprintf`, so it's basically a second way to do something.

Having said that, there are some advantages to spending time on Rakudo as well. For one thing, Rakudo gets more well-deserved attention if it has more features and more people working on it. With a faster-moving Rakudo, November can reap earlier benefits, and expect bugs to get fixed even faster. (Though if you haven't noticed, bug response has been amazing of late.)

Secondly, implementing things helps me learn about Rakudo internals, and Parrot, and PIR — all of which can be of great future use for not-yet-planned features/additions in November. So, it's an investment. Can't hurt to become familiar with one's platform.

Thirdly, I simply got so caught up in implementing `.fmt`, that I'm not sure I could have just stopped and done something else. ☺

Anyway, now that I'm done with that, my plans for the immediate November future are:

- Work on the skin I thought I'd have done [by Monday](November-3-2008-—-today-is-Skin-Monday.html).
- Start working in earnest on the [MediaWiki markup](http://github.com/viklund/november/commits/mediawiki-markup).

Both these tasks are totally unblocked, and essentially just waiting for me to pour time and effort into them.
