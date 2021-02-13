# Back from vacation, hackathon coming up!
    
*Originally published on [2012-04-05](https://6guts.wordpress.com/2012/04/05/back-from-vacation-hackathon-coming-up/) by Jonathan Worthington.*

So, I’m back from vacation. Turns out Argentina is a pretty awesome place to vacation in, too. As well as wonderful food and delicious imperial stout (amongst other good beers), there was walking like this…

![walking like this](bp-11.jpg)

…and other cool stuff, like glaciers…

![Glaciers](bp-2.jpg)

…and so even though the laptop came with me, it was just too much fun to be outside, especially when the weather was good so much of the time. I did sneak in a few patches, though, most notably implementing `PRE` and `POST` phasers.

Anyway, I’m safely back, after an 8 hour flight delay from Buenos Aires and a small bus accident at Frankfurt airport. Yes, this airport fails SO hard they managed to screw up the 2 minute bus trip from the plane to the terminal…anyway, I got off with just a few small cuts. Suggest taking the train to YAPC::Europe this summer… :-)

So, what’s coming up? Well, this month brings a [Raku hackathon in Oslo](https://gist.github.com/1711730), where I look forward to being together with a bunch of other Rakudo and Raku folks. I’m sure we’ll get some nice stuff done, and some future directions worked out. I’m happy that one of the most industrious Perl Mongers groups I know when it comes to organizing such events is also set in a very pleasant city situated in a beautiful country. :-) By the way, it’s still very possible (and very encouraged) to sign up if you want to come along.

As *moritz*++ noted on rakudo.org, we’re [skipping doing a distribution (Star) release](http://rakudo.org/2012/04/05/no-rakudo-star-release-for-march-2012-stay-tuned-for-april/) based on the March compiler release since an unfortunate bug slipped in that busted precompilation of modules that used `NativeCall`. We hold ourselves to higher standards of stability in the distribution releases (which are user focused) than the compiler ones (which just ship at the same time each month), and this would have been too big a regression. The good news is that I’ve patched the bug today, so we’re now all clear for doing an April one – and what a nice release it should be.

Well, time for dinner here – which I’ll be having with *masak*++. No doubt macros will come up, and what’s needed to get us along to the next level with those. Stay tuned; the next month should be interesting in Rakudo land. :-)
