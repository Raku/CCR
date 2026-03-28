# Weeks 6 and 7 of GSoC work on Buf — roundtrip
    
*Originally published on [10 July 2010](http://strangelyconsistent.org/blog/weeks-6-and-7-of-gsoc-work-on-buf-roundtrip) by Carl Mäsak.*

*Warning: this blog post doesn't contain any puns at all. It's just a boring update about my progress. If you don't believe me, just go ahead and read it. I dare you.*

Been working on file I/O and `Buf`s lately. It's tough work, but I'm now at a point where things run. Some highlights:

- I [asked on Parrot](https://irclogs.raku.org/parrot/2010-07-04.html#14:47) how to write binary data. Got enough help to get me started coding an `IO.write` method.
- I realized that I didn't like at all how the IO spec described `IO.read` and `IO.write`. So I rewrote it.
- Having got the `IO.write` method working, I wrote an `IO.read` method along the same lines. [Here they are](https://github.com/rakudo/rakudo/commit/692aa15f2538858028934b8e26910199cc5fdc53).

Now, these new methods obviously write and read bytes to and from files, but the tests indicate that things don't properly round-trip yet. Part of that is because the tests want the example string "föö" to encode as iso-8859-1, but there's no logic that does that yet. My slightly sleepy brain tells me there's more to the story though, or the string wouldn't come back garbled as "fÃ¶". (Interesting how that somehow *feels* like a small piece of [mojibake](https://en.wikipedia.org/wiki/Mojibake), before the brain even takes in the individual characters.)

Another nice highlight was my question about [how `Buf`s should stringify](https://irclogs.raku.org/perl6/2010-07-09.html#13:38), which [*TimToady* just answered](https://irclogs.raku.org/perl6/2010-07-09.html#23:09) on #raku. That should be a smop to implement.
