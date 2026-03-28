# Week 6 of Web.pm — Hitomi draft, November work
    
*Originally published on [4 May 2009](http://strangelyconsistent.org/blog/week-6-of-webpm-hitomi-draft-november-work) by Carl Mäsak.*


> *Moses put his han ovur teh see, An Ceiling Cat mayk big wind that blowd see all nite till see wuz drei lan so kitties no get wet. teh waterz wer dvided. Teh izrelites crosd see on drei urth an no get wet. but tehr wuz walls o water on teh sieds. But teh gypshuns An teh charyots chaysd tehm OMG!!* — Exodus 14:21-23

Things are moving forward. I'm enjoying myself within the Web.pm project, thinking of new ideas to try, and discussing a lot with other people. When looking at the milestones, it still feels like we're on track — though sometimes the "weeks" are slightly longer than seven days, due to the, er, intricacies of time allocation.

Anyway, this week was about 7 days long, and I used my 10 allocated hours for the following:

- Absorbed and toyed with suggested drafts for Hitomi, sent in by *moritz*++ and *Tene*++. (Reminder: "Hitomi" is an XML templater, tightly modeled after Python's Genshi.) Both these drafts uncovered new bugs in Rakudo, most of which subsequently were fixed.
- I like the grammar/actions approach arrived at in the latest iteration, but the thing is that actions, being fired in a bottom-up manner, are inadequate for a templater working top-down. I believe the actions should constitute a first pass over the template, building an abstract syntax tree whose nodes correspond to expression evaluations, for loops, and if statements. This tree can then be processed top-down. I've yet to see someone do this latter part. I don't believe it's difficult, just as-yet undone and therefore not entirely obvious.
- One thing I look forward to in Hitomi is writing it on top of the Parrot Compiler Toolkit — same platform as Rakudo is written on — because that'll mean that the PIR generated can be targetted especially for templates, and thus hopefully a bit faster. While [discussing](https://irclogs.raku.org/perl6/2009-04-29.html#09:00) this with moritz, however, it became evident that there are backsides to tying Hitomi into a particular back-end. The [conclusion](https://irclogs.raku.org/perl6/2009-04-29.html#09:30) was that Hitomi will he a two-headed beast, one pure Raku implementation and one PCT implementation. Both will run against the same test suite to keep things honest.
- Continued fixing deficiencies in November so that I can port it over to `Web::Request` and `Web::Response`. As `STD.pm` and Rakudo evolve, atrocities from the past keep haunting us. That is, we've written things like `Hash %properties` in parameter lists, thinking that meant "the hash `%properties`". Suddenly, when parameter checking gets a little stricter, it turns out that it really means "the hash of hashes `%properties`", and things fail. Live and learn.
- Similarly, there was a type check in the test that used `.WHAT eq` and broke when the return values of `.WHAT` suddenly changed. The `.WHAT eq` isn't Best Practices Raku to begin with; it was a workaround becuase smartmatching didn't work in that particular case. The blocking bug had since been fixed, so I changed to smartmatching.
- All tests now pass in `master`, just as they should. I've set up a nightly smoke, and I plan to expand this to both the bleeding Rakudo and the latest monthly release. That will give us excellent data for keeping November's `master` passing in the future.
- In a local branch, I finally started on the translation work of s/CGI/Web.pm/. It feels great, but also raises a number of questions that I'll have to discuss with Ilya when he gets back, since he wrote many of the underpinnings of November. I hope to have something substantial to show by the end of next week.


I wish to thank The Perl Foundation for sponsoring the Web.pm effort.
