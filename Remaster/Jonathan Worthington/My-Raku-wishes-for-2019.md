# My Raku wishes for 2019
    
*Originally published on [2019-01-02](https://6guts.wordpress.com/2019/01/02/my-perl-6-wishes-for-2019/) by Jonathan Worthington.*

This evening, I enjoyed the New Year’s fireworks display over the beautiful Prague skyline. Well, the bit of it that was between me and the fireworks, anyway. Rather than having its fireworks display at midnight, Prague puts it at 6pm on New Year’s Day. That makes it easy for families to go to, which is rather thoughtful. It’s also, for those of us with plans to dig back into work the following day, a nice end to the festive break.

![Fireworks in Prague](DSC01495.jpg)

So, tomorrow I’ll be digging back into work, which of late has involved a lot of Raku. Having spent so many years working on Raku compiler and runtime design and implementation, it’s been fun to spend a good amount of 2018 using Raku for commercial projects. I’m hopeful that will continue into 2019. Of course, I’ll be continuing to work on plenty of Raku things that are for the good of all Raku users too. In this post, I’d like to share some of the things I’m hoping to work on or achieve during 2019.

### Partial Escape Analysis and related optimizations in MoarVM

The MoarVM specializer learned plenty of new tricks this year, delivering some nice speedups for many Raku programs. Many of my performance improvement hopes for 2019 center around escape analysis and optimizations stemming from it.

The idea is to analyze object allocations, and find pieces of the program where we can fully understand all of the references that exist to the object. The points at which we can cease to do that is where an object escapes. In the best cases, an object never escapes; in other cases, there are a number of reads and writes performed to its attributes up until its escape.

Armed with this, we can perform scalar replacement, which involves placing the attributes of the object into local registers up until the escape point, if any. As well as reducing memory operations, this means we can often prove significantly more program properties, allowing further optimization (such as getting rid of dynamic type checks). In some cases, we might never need to allocate the object at all; this should be a big win for Raku, which by its design creates lots of short-lived objects.

There will be various code-generation and static optimizer improvements to be done in Rakudo in support of this work also, which should result in its own set of speedups.

Expect to hear plenty about this in my posts here in the year ahead.

### Decreasing startup time and base memory use

The current Rakudo startup time is quite high. I’d really like to see it fall to around half of what it currently is during 2019. I’ve got some concrete ideas on how that can be achieved, including changing the way we store and deserialize NFAs used by the parser, and perhaps also dealing with the way we currently handle method caches to have less startup impact.

Both of these should also decrease the base memory use, which is also a good bit higher than I wish.

### Improving compilation times

Some folks – myself included – are developing increasingly large applications in Raku. For the current major project I’m working on, runtime performance is not an issue by now, but I certainly feel myself waiting a bit on compiles. Part of it is parse performance, and I’d like to look at that; in doing so, I’d also be able to speed up handling of all Raku grammars.

I suspect there are some good wins to be had elsewhere in the compilation pipeline too, and the startup time improvements described above should also help, especially when we pre-compile deep dependency trees. I’d also like to look into if we can do some speculative parallel compilation.

### Research into concurrency safety

In 6.d, we got non-blocking `await` and `react` support, which greatly improved the *scalability* of Raku concurrent and parallel programs. Now many thousands of outstanding tasks can be juggled across just a handful of threads (the exact number chosen according to demand and CPU count).

For Raku.e, which is still a good way off, I’d like to having something to offer in terms of making Raku concurrent and parallel programming *safer*. While we have a number of higher-level constructs that eliminate various ways to make mistakes, it’s still possible to get into trouble and have races when using them.

So, I plan to spend some time this year quietly exploring and prototyping in this space. Obviously, I want something that fits in with the Raku language design, and that catches real and interesting bugs – probably by making things that are liable to occasionally explode in weird ways instead reliably do so in helpful ways, such that they show up reliably in tests.

### Get Cro to its 1.0 release

In the 16 months since I revealed it, [Cro](https://cro.services/) has become a popular choice for implementing HTTP APIs and web applications in Raku. It has also attracted code contributions from a couple of dozen contributors. This year, I aim to see Cro through to its 1.0 release. That will include (to save you following the roadmap link):

- Providing flexible HTTP reverse proxying support
- Providing a number of robustness patterns (timeout, retry, circuit breaker, and so forth)
- Providing Cro support some message queue protocols
- Ensuring Cro’s features work on MacOS and Windows
- Providing some further help for those building server-side web applications (templating, an easier time setting up common login flows, etc.)
- Conducting a security review
- Specifying a stability/deprecation policy
- Lots of polishing

### Comma Community, and lots of improvements and features

I founded [Comma IDE](https://commaide.com/) in order to bring Raku a powerful Integrated Development Environment. We’ve come a long way since the Minimum Viable Product we shipped back in June to the first subscribers to the Comma Supporter Program. In recent months, I’ve used Comma almost daily on my various Raku projects, and by this point honestly wouldn’t want to be without it. Like Cro, I built Comma because *it’s a product I wanted to use*, which I think is a good place to be in when building any product.

In a few months time, we expect to start offering Comma Community and Comma Complete. The former will be free of charge, and the latter a commercial offering under a subscribe-for-updates model (just like how the supporter program has worked so far). My own Comma wishlist is lengthy enough to keep us busy for a lot more than the next year, and that’s before considering things Comma users are asking for. Expect plenty of exciting new features, as well as ongoing tweaks to make each release feel that little bit nicer to use.

### Speaking, conferences, workshops, etc.

This year will see me giving my first keynote at a European Perl Conference. I’m looking forward to being in Riga again; it’s a lovely city to wander around, and I remember having some pretty nice food there too. The keynote will focus on the concurrent and parallel aspects of Raku; thankfully, I’ve still a good six months to figure out exactly what angle I wish to take on that, having spoken on the topic many times before!

I also plan to submit a talk or two for the German Perl Workshop, and will probably find the Swiss Perl Workshop hard to resist attending once more. And, more locally, I’d like to try and track down other Perl folks here in Prague, and see if I can help some kind of Praha.pm to happen again.

I need to keep my travel down to sensible levels, but might be able to fit in the odd other bit of speaking during the year, if it’s not too far away.

### Teaching

While I want to spend most of my time building stuff rather than talking about it, I’m up for the occasional bit of teaching. I’m considering pitching a 1-day Raku concurrency workshop to the Riga organizers. Then we’ll see if there’s enough folks interested in taking it. It’ll cost something, but probably much less than any other way of getting a day of teaching from me. :-)

### So, down to work!

Well, a good night’s sleep first. :-) But tomorrow, another year of fun begins. I’m looking forward to it, and to working alongside many wonderful folks in the Perl community.
