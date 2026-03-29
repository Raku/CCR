# Has it been three years?
    
*Originally published on [8 December 2017](http://strangelyconsistent.org/blog/has-it-been-three-years) by Carl Mäsak.*

[007](http://masak.github.io/alma/), the toy language, is turning three today. Whoa.

On its one-year anniversary, I wrote [a blog post](double-oh-seven.html) to chronicle it. It seriously doesn't feel like two years since I wrote that post.

On and off, in between long stretches of just being a parent, I come back to 007 and work intensely on it. I can't remember ever keeping a side project alive for three years before. (*Later note*: Referring to the language here, not my son.) So there is that.

So in a weird way, even though the language is not as far along as I would expect it to be after three years, I'm also positively surprised that it still *exists* and is *active* after three years!

In the previous blog post, I proudly announce that "We're gearing up to an (internal) v1.0.0 release". Well, we're *still* gearing up for v1.0.0, and we are closer to it. The details are in [the roadmap](https://github.com/masak/alma/blob/master/ROADMAP.md), which has become much more detailed since then.

Noteworthy things that happened in these past two years:

- I've gone full circle, [trying a *very difficult* thing first with strategy A, then with B, and now with A again](https://github.com/masak/alma/issues/212#issuecomment-320449569).
- I've had to invent a new term, "injectile", for [the bit of code a macro produces; often a copy of a quasi block](https://github.com/masak/alma/issues/212#issuecomment-330138105).
- An issue about quasi unquotes has stalled because parsing is hard enough without differently-shaped holes, and [was hijacked by very interesting discussions about syntax and whether "quasi" is a fitting name for the thing it signifies](https://github.com/masak/alma/issues/30).
- I've [understood new things about templates](https://github.com/masak/alma/issues/30#issuecomment-331633998).


Things that I'm looking forward to right now:

- Landing `macro infix:<ff>` in `master`, which is quite literally one small fix away at this point.
- Landing [a huge object system refactor](https://github.com/masak/alma/pull/242) that really cleans up the language.
- `is parsed`, also only a few steps away.
- Making a better web site, focused around language tutorials and API documentation.
- Writing a 007 parser in pure 007.


I tried to write those in increasing order of difficulty.

All in all, I'm quite eager to one day burst into `#raku` or `#rakuev` and actually showcase examples where macros quite *clearly* do useful, non-trivial things. 007 is and has always been about producing such examples, and making them run in a real (if toy) environment.

And while we're not quite over that hump yet, we're perceptibly closer than we were two years ago.

*Belated addendum*: Thanks and hugs to *sergot*++, to *vendethiel*++, to *raiph*++ and *eritain*++, for sharing the journey with me so far.
