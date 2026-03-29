# Macros progress report: D1 merged
    
*Originally published on [10 March 2012](http://strangelyconsistent.org/blog/macros-progress-report-d1-merged) by Carl Mäsak.*

I've merged my first chunk of work, known to the [grant application](https://news.perlfoundation.org/2011/09/hague-grant-application-implem.html) as "D1", into the `nom` branch of Rakudo. Concretely, this means three things:

- The next release of Rakudo (release #50, due 2012-03-22) will be the first release of any Raku implementation to feature AST macros.
- People who have a new-enough revision of the `nom` branch checked out can play around with basic macros already.
- There's just three chunks of work left to do. `:-)```

The work has progressed nicely so far. It's been a little trickier than I expected, but not insurmountable yet, and I've received plenty of support from *jnthn*++. The time estimates were way too optimistic, it turned out &mdash; partly because the grant took a while to get accepted, partly because  `$dayjob` keeps wanting tuits &mdash; but at least I'm not stuck.

One interesting aspect of the grant that I didn't expect is that much of my thinking happens in gists. Increasingly, I'm beginning to see gists as a sort of "semi-private blog posts". They're notes mainly left for myself and my creative process, and they don't clutter up the blog feed, but they're there if people are interested enough to see how sausage is made. I don't go back and "fix" gists when I learn new things that contradict what's in them &mdash; I just write new ones.

Here, just for reference, I collect all the gists I've made so far philosophizing on macros:

- [Musings on macros](https://gist.github.com/masak/1148915)
- [Macros and short-circuiting](https://gist.github.com/masak/1149126)
- [More thoughts on macros](https://gist.github.com/masak/1156662)
- (at this point, I wrote the [grant application](https://news.perlfoundation.org/2011/09/hague-grant-application-implem.html))
- [D4, deconstructed](https://gist.github.com/masak/1293853)
- [I'm thinking about macros again](https://gist.github.com/masak/1548053)
- [Cool use for a macro: meta for](https://gist.github.com/masak/1809356)
- [The lifetime of a macro invocation](https://gist.github.com/masak/1853560)

I have one more gist coming up that I haven't written yet, about how macro-argument AST thingies are thunkish and rebind to their outer context just like closures do.

The other "artifacts" that have fallen out of the grant work so far, are:

- A [spectest file](https://github.com/raku/roast/blob/7bbd58b13e8cd7c692ad8d6730159b311b8dedd3/S06-macros/macros-d1.t). Too few tests in it, even though I've tested everything I can think of. There will be more tests for D2, I'm sure.
- A [monolithic commit](https://github.com/rakudo/rakudo/commit/e29b2f18665dd3bd5aa31692317f64713d789a7a) to Rakudo, representing my D1 work. I did a bunch of rebase operations on the way to keep current with the `nom` branch, and each time I folded a number of commits into a single one, because I considered most commits after the original one from September to be "oh right"-type afterthoughts. Not sure how this rhymes with jnthn's [post about atomic commits](https://web.archive.org/web/20150906222535/https://blog.edument.se/2012/03/09/love-your-version-history-and-itll-love-you-back/)... I'm a bit divided on the issue.
- A talk, at [Deutscher Perl Workshop](https://conferences.yapceurope.org/gpw2012/) in Erlangen. You can [see the slides here](https://masak.org/carl/gpw-2012-macros/talk.pdf).


Looking ahead a bit, what's up next is D2. Informally, D2 consists of "getting those little `{{{$stuff}}}` thingies to work". We need a way to represent "there's a placeholder here" in the AST, because that's how the ASTs look during the static part of their lifetime (before macro application). It will require a new AST type. As it happens, PAST in nqp/Rakudo is just about to be replaced by the next generation of AST technology, and [*jnthn*++ is just about to start working on that](https://6guts.wordpress.com/2012/03/09/meta-programming-slides-and-some-rakudo-news/). So it makes sense for me to assist him, since I'm now blocking on the new AST technology landing in Rakudo for my macros work. Aside from blocking, I expect D2 to be quite easy to implement.

See you again at the next milestone. And possibly at part-way resting stops in between.
