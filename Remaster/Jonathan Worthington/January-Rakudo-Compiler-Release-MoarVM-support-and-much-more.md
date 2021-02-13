# January Rakudo Compiler Release: MoarVM support and much more
    
*Originally published on [2014-01-24](https://6guts.wordpress.com/2014/01/24/january-rakudo-compiler-release-moarvm-support-and-much-more/) by Jonathan Worthington.*

This month’s Rakudo compiler was cut today, and there’s a bunch of good stuff in there. In this post I’ll take a quick look at what’s been done.

### MoarVM Support

This is the first Rakudo compiler release to have support for building and running on [MoarVM](http://www.moarvm.org/), a new VM being built especially for Raku and NQP (the Raku subset a sizable chunk of Rakudo is written in). MoarVM support is not quite up to the level of the JVM and Parrot backends yet. It passes less specification tests than either of them – though it’s getting awfully close (Rakudo on MoarVM passes over **99%** of the specification tests that Rakudo on the JVM – the current leader – does). Thus, you can actually run a heck of a lot of Raku code just fine on it already. I used it recently in a pair programming session and we only hit one bug in the couple of hours we were using it.

The fast-path for signature binding that I mentioned in my [previous post](https://6guts.wordpress.com/2014/01/08/a-rakudo-on-moarvm-update/) has also been put in place. It did, as hoped, lead to a fairly dramatic speedup. The workload of building Rakudo’s built-ins and running the specification test suite was also a good basis for doing some GC tuning, which led to further improvements. By this point, on my box, Rakudo on MoarVM now has:

- The lowest startup time of any Rakudo backend
- The shortest spectest time of any Rakudo backend
- For the CORE.setting build and spectests, the smallest memory footprint of any Rakudo backend

Other Rakudo developers have reported similar findings. I need more time to look into the exact numbers, but it would appear that Rakudo on MoarVM is also the fastest to build. CORE.setting build time is roughly competitive with on the JVM now (but how roughly seems to vary quite widely – I think it depends on what JVM or even version is being used), but startup time for NQP on MoarVM is rather lower, meaning that those parts of the build go by faster.

The focus for the next month or two will be getting into a position where we can produce a Rakudo Star release that uses MoarVM. This means digging through the last 1% of failing spectests and dealing with them, finishing the work of getting Panda (our module installer) to work with Rakudo on MoarVM, and then hunting bugs that keep us from running the modules. Getting NativeCall working will also be a notable task, although given we already have a NativeCall in C working against 6model (the one we built for Parrot), there is a lot of prior art this time – unlike on the JVM.

On performance – we’re not even scratching the surface of what’s possible. MoarVM’s design means it has a lot of information to hand to do a good amount of runtime specialization and optimization, but none of this is implemented yet. I aim to have a first cut of it in place within the next few months. Once we have this analysis and specialization framework in place, we can start thinking about things such as JIT compilation.

### Rakudo on JVM Improvements

Probably the *best* news in this release for anybody working with Rakudo on JVM is that the `gather` / `take` stack overflow bug is now fixed. It was a fun one involving continuations and a lack of tailcall semantics in an important place, but with doing the MoarVM implementation of continuations in my recent past, I was in a good place to hunt it down and get a fix in. A few other pesky issues are resolved, including a regex/closure interaction issue and sometimes sub-optimal line number reporting.

The other really big piece of JVM-specific progress this month has been *arnsholt*++ continuing to work on the plumbing to get us towards full `NativeCall` support for JVM. This month, a number of the big missing pieces landed. `NativeCall` working, and the modules that depend on it working, is the last big blocker for a Rakudo Star on JVM release, and it’s now looking quite possible that we’ll see that happen in the February one.

### General Rakudo Improvements

While a lot of energy went on the things already mentioned, we did get some nice things in place that are independent of any of the particular backend: improvements to the `Nil` type, the sequence operator, sets and bags, adverb syntax parsing, regex syntax errors, aliased captures in regexes, and numerics. MoarVM’s rather stricter interpretation of closure semantics than we’ve had in place on other backends has also led to various code-gen fixes, which may lead to better performance in certain scenarios across the board too (one of those, “I know it probably should but I didn’t benchmark” situations).

I’d like to take a moment to thank everyone who contributed to this month’s release. This month had the highest Rakudo contributor count in a good while – and I’m hopeful we can maintain and exceed it in the months to come.
