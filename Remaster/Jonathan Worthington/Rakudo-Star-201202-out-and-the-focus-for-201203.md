# Rakudo Star 2012.02 out – and the focus for 2012.03
    
*Originally published on [2012-02-29](https://6guts.wordpress.com/2012/02/29/rakudo-star-2012-02-out-and-the-focus-for-2012-03/) by Jonathan Worthington.*

I’ve just cut the [February 2012 release of Rakudo Star](http://rakudo.org/2012/02/28/rakudo-star-2012-02-released/). The good news is that we got a bunch of nice improvements into the release.

- More typed exceptions, and better backtraces. This work has been done by *moritz*++; I’ll simply point you to his [excellent blog post](http://perlgeek.de/blog-en/perl-6/2011-02-exceptions.html) on that topic today. I think everyone working with Rakudo will appreciate the new backtraces, which cut out a lot of the uninformative details and are thus much more focused.
- `FatRat` is now implemented. This type gives you rational number support with big integer semantics for both the numerator and denominator. The Rat type now correctly degrades to a Num if the denominator gets too large, as per spec (this avoids performance issues in certain cases). Again, we’ve *moritz*++ to thank for this.
- We have object hashes! You can now make a declaration like: `my %hash{Any};` Which will have keys of type `Any`. You can constrain this as you wish. You can also still constrain the value in the usual way: `my Int %hash{Any};` This latter example gives you a hash with `Int` values and object keys, meaning that keys are not coerced to strings, as is the default. Thus, using `%hash.keys` will give you back the original objects. Identify is done based on `.WHICH` and thus `ObjAt`.
- The coercion syntax, `Int($foo)`, is now implemented. This gives you another – perhaps neater – way to write `$foo.Int`, but types may also implemented the method `postcircumfix:<( )>` if the target type is the one that knows how to do the coercion.
- The reduction meta-operator used to have crazy bad performance, and parsed dodgy in some cases. Both of these issues are now resolved; it’s an order of magnitude faster and parses more correctly.
- Various regex improvements and more problems caught at compile time, which I discussed in my [previous post](https://6guts.wordpress.com/2012/02/10/bounded-serialization-better-regexes-and-better-errors/).

As always, there’s a bunch of bug fixes and other tweaks – see the Rakudo ChangeLog for more details.

Naturally, one release done simply means another one to work towards. :-) If you’ve been following along with my posts, you’ll have noticed that the bounded serialization work I’ve been doing didn’t make it in to the 2012.02 release; it just wasn’t done in time. The good news is that it’s well on course to land in very good time for the 2012.03 release.

Today I got to the milestone of having a Rakudo binary, with a serialized CORE.setting, that will compile Test.pm and attempt the spectests. There’s a bunch of failures (which I expected), but a lot more passes than fails. Anyway, that means things are essentially working and I’m into triage mode. I’ve also got some very preliminary data on what kind of improvements it brings.

Just from trying it out, I could feel that startup was faster, as hoped. *tadzik*++ built the bounded serialization branch and the current main development branch and compared the time they took for a simple “hello world” (such a simple program that startup cost will dominate). The result: the bounded serialization branch ran it in around 25% of the time. I think we can squeeze a bit more out yet, but achieving startup in a quarter of the time we do today is a big improvement. Loading time for pre-compiled modules will see a similar improvement.

I also checked memory consumption when compiling CORE.setting. The bounded serialization branch uses 60% of the memory that the main development branch uses. I’d been hoping that this work would cut memory usage by around a third, and it’s done at least that. I didn’t measure the speedup for this task yet; while the other bits are fair comparisons, this one would not be yet even if I had a figure, since the optimizer is currently disabled (one of the transformations causes issues; I’m not expecting it to be a huge pain to resolve, but was more focused on the critical path to running spectests again so I could understand the fallout better).

Once the busted spectests are running again, I’ll get this merged, then dig in to exploiting some of the opportunities it makes available. I’m hoping we can get some more nice features in place for the next release also; *moritz*++ has already got branches for sink context and the `:exhaustive` modifier in regexes in progress, and I’ve got some ideas of things to hack on… :-)
