# A sudden insight
    
*Originally published on [15 October 2010](http://strangelyconsistent.org/blog/a-sudden-insight) by Carl Mäsak.*

Sometimes things seem to click and fall into place inside my brain. Previously
unrelated concepts turn out to be have commonalities after all.

For example, I said yesterday on #raku that I'd realized, teaching Perl,
that taking away `wantarray` was only a logical next step after taking away
sigil variance. Moritz was way ahead of me, though: he had [blogged about
exactly this](https://perlgeek.de/blog-en/perl-6/immutable-sigils-and-context.html)
a year ago.

But a much deeper insight hit me on the Sunday, when *jnthn*++ was talking, and
explaining how `Capture`s and `Signature`s form two sides of a function call
binding:

```raku
 caller                     callee
Capture <---> binder <---> Signature
```

and then showing a slide that looked like this:

```raku
my ($some, $random, $things) := some-`function`;
```

The point of the slide is that `Signature`s aren't just used in function
declarations; they're used in the above case as well. I've always thought that
this was a random, fortuitous bonus use of it...

...but then Liz turned to me and whispered "that's because `return` is just
another function call". And right then and there, I went through some sort of
mini-enlightenment. How beautiful!

Later, Liz divulged that this was the kind of insight that came naturally when
one had programmed in [continuation-passing style](https://en.wikipedia.org/wiki/Continuation-passing_style)
for a while. It'd be interesting to learn whether CPS is the reason for
```rakuSignature`s being used in bindings like this in Raku. For some reason, my
guess is no.

Anyway, Raku surprising me with its consistency is only appropriate,
given the name of this blog.
