# -n and -p, part three
    
*Originally published on [10 September 2011](http://strangelyconsistent.org/blog/dash-n-and-dash-p-part-three) by Carl Mäsak.*

*(This blog post is part three of a series; there's also a [part one](n-and-p.html) and a [part two](n-and-p-part-two.html).)*

Shortly after I wrote the [last post](n-and-p-part-two) on `-n` and `-p`, and how I didn't really understand what a setting was in Raku, *sorear*++ and *TimToady*++ filled me in on all of the details. So here I am, a third time, to pass the knowledge on.

I wrote last time that I found the term "setting" confusing and overloaded. That's because I thought it was a single, defined thing. In effect, there's no *the* setting in Raku; there can be many at the same time.

A setting is simply something that surrounds your code on the outside. (Haskell has a [Prelude](https://haskell.org/onlinereport/standard-prelude.html), but a prelude only comes before your code. A setting envelopes your code both before and after.) Your code simply finds itself lexically inside some setting or other. In technical parlance, whatever is the `OUTER::` of your code is a setting.

So, you *can* have several settings, just like I wished for. They stack, you see. Or rather *peel*, like onion layers. One man's setting is another man's code, all the way outwards into the final `OUTER::` nothingness of empty space.

And &mdash; the final piece of the puzzle &mdash; the big default "here, friend, are all of your builtins" setting is called `CORE`. I'd always wondered why we keep saying both "setting" and `CORE`. (And why Rakudo calls the directory `src/core`, not `src/setting`.) That's why; `CORE` is just a setting among others.

The discussion &mdash; which consists mostly of sorear and *TimToady* telling how things really are &mdash; can be found [here](https://irclogs.raku.org/perl6/2011-09-05.html#19:57).

And now I think I'm finally done writing on how `-n` and `-p` work. 哈哈
