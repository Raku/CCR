# Tag Your Dists
    
*Originally published on [10 March 2017](https://perl6.party//post/Tag-Your-Dists) by Zoffix Znet.*

If you ever asked for a name suggestion for your latest shiny Raku module, the suggestions you received may have been much shorter than you expected.  Why name your module `WebService::Google::PageRank` and require the programmer to type that many characters each time they use the module? `Google::PageRank```` or even just `PageRank` are pretty damn good.

You may be tempted to use very long names to aid discoverability, but there's a much better tool for that purpose in Raku. Tags in the META file!

## Camelia Wants YOU To Tag Your Dists

Tags are just a `"tags"` key in your `META6.json` file that points to an array of strings. What sort of tags should you use? It's up to you. Pick a couple of short words that describe your module best and use those.

Here's an example of tags in my [`IRC::Client` module](https://modules.raku.org/dist/IRC::Client):

```` raku
...
"tags"         : [ "Net", "IRC" ],
"perl"         : "6.c",
"name"         : "IRC::Client",
"version"      : "3.006004",
"description"  : "Extendable Internet Relay Chat client",
"depends"      : [
],
...
````

As for what tags people use, I'm not yet sure. As I write this, the branch that adds tag support for [modules.raku.org](https://modules.raku.org) is rebuilding its database and I doubt many dists used tags yet since... well, we didn't use them anywhere.

Speaking of using them...

## Camelion Wants YOU To Tag Your Dists

![camelion](camelion.png)

Tags visibility on [modules.raku.org](https://modules.raku.org) is only the beginning. I'm also developing a small utility called [*Camelion*](https://github.com/zoffixznet/camelion).

Paired with a web service, its aim is to make installing sets of modules much easier, particularly for users unfamiliar with the Raku ecosystem.  Whether you plan on doing Web development, crypto, network programming, or develop games, *Camelion* will hook you up with all the modules you need.

However, to be able to do that effectively, *Camelion* needs a well-tagged ecosystem. So, please, help everyone find your modules.

Please tag your dists.
