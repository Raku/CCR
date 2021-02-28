# Raku Is Slower Than My Fat Momma!
    
*Originally published on [7 April 2016](https://perl6.party//post/Perl-6-Is-Slower-Than-My-Fat-Momma) by Zoffix Znet.*

I notice several groups of people:
- folks who wish Raku's performance weren't mentioned;
- folks who are confused about Raku's performance;
- folks who gleefully chuckle at Raku's performance,
- reassured the threat to their favourite language XYZ hasn't arrived yet.

So I'm here to talk about the elephant in the room and get the first group out of hiding and more at ease, I'll explain things to the second group, and to the third group... well, this post isn't about them.

## Why is it slow?

The simplest answer: Raku is brand new. It's not the next Perl, but a brand new language in the Perl family. The *language spec* was finished less than 4 months ago (Dec 25, 2015). While *some* optimization has been done, the core team focused on getting things right first. It's simply unrealistic to evaluate Raku's performance as that of an extremely polished product at this time.

The second part of the answer: Raku is big.  It's easy to come up with a couple of one-liners that are much faster in other languages. However, a Raku one-liner loads the comprehensive object model, list tools, set tools, large arsenal of async and concurrency tools... When in a real program you have to load a dozen of modules in language XYZ, but can still stay with bare Raku to get same features, that's when performance starts to even out.

## What can ***you*** do about it?

Now that we got things right, we can focus on making them fast. Raku uses a modern compiler, so *in theory* it can be optimized quite a lot. It remains to be seen whether theory will match reality, but looking through numerous optimization commits made since the start of 2016, many stand out by the boosts they bring in:

- [Make Parameter.sigil about **20x faster**](https://github.com/rakudo/rakudo/commit/add25c771c5b82ab0ce5bd3f6c0e87a6e9334a2d)
- [Make Blob:D eq/ne Blob:D about **250x faster**](https://github.com/rakudo/rakudo/commit/1969a42525f69d930735009a1dbbc39f3e910888)
- [Make prefix ~^ Blob:D about **300x faster**](https://github.com/rakudo/rakudo/commit/fb74abc314efa2dcc7f4866f1378f40a17410a50)
- [Make ~|, ~& and ~^ about **600x faster**](https://github.com/rakudo/rakudo/commit/138441c97df2fc0603047b589e1fa71a126185f3)
- [Make int @a.append(1) **1800x faster**](https://github.com/rakudo/rakudo/commit/c70a18e9cd4aff36c2c7a6b8f9a62770c8c533b3)
- [Make Blob:D cmp/lt/gt/le/ge Blob:D **3800x faster**](https://github.com/rakudo/rakudo/commit/e3342da00e7cfca618acbab37b90f13a133c73f6)

Thus, the answer is: we're working on it... and we're making good progress.

## What can ***I*** do about it?

I'll mention three main things to keep in mind when trying to get your code to perform better: pre-compilation, native types, and of course, concurrency.

### Pre-Compilation

Currently, a large chunk of slowness you may notice comes from parsing and compiling code. Luckily, Raku automagically pre-compiles modules, as can be seen here, with a large Foo.pm6 module I'm including:

```` raku
$ raku -I. -MFoo --stagestats -e ''
Stage start      :   0.000
Stage parse      :   4.262
Stage syntaxcheck:   0.000
Stage ast        :   0.000
Stage optimize   :   0.002
Stage mast       :   0.013
Stage mbc        :   0.000
Stage moar       :   0.000
$ raku -I. -MFoo --stagestats -e ''
Stage start      :   0.000
Stage parse      :   0.413
Stage syntaxcheck:   0.000
Stage ast        :   0.000
Stage optimize   :   0.002
Stage mast       :   0.013
Stage mbc        :   0.000
Stage moar       :   0.000
````

The first run was a full run that pre-compiled my module, but the second one already had the pre-compiled Foo.pm6 available and the parse stage went down from 4.262 seconds to 0.413: a 1031% start-up improvement.

Modules you install from [the ecosystem](http://modules.raku.org/) get pre-compiled during installation, so you don't have to worry about them. When writing your own modules, however, they will be automatically re-pre-compiled every time you change their code. If you make a change before each time you run the program, it's easy to get the impression your code is not performing well, even though the compilation penalty won't affect the program once you're done tinkering with it.

Just keep that in mind.

### Native Types

Raku has several "native" machine types that can offer performance boosts in some cases:

```` raku
my Int $x = 0;
$*x*++ while $x < 30000000;
say now - INIT now;
# OUTPUT:
# 4.416726
my int $x = 0;
$*x*++ while $x < 30000000;
say now - INIT now;
# OUTPUT:
# 0.1711660
````

That's a 2580% boost we achieved by simply switching our counter to a native `int` type.

The available types are: `int`, `int8`, `int16`, `int32`, `int64`, `uint`, `uint8`, `uint16`, `uint32`, `uint64`, `num`, `num32`, and `num64`. The number in the type name signifies the available bits, with the numberless types being platform-dependent.

They aren't a magical solution to every problem, and won't offer huge improvements in every case, but keep them in mind and look out for cases where they can be used.

### Concurrency

Raku makes it extremely easy to utilize multi-core CPUs using [high-level APIs](http://docs.raku.org/language/concurrency#High-level_APIs) like Promises, Supplies, and Channels. Where language XYZ is fast, but lacks ease of concurrency, Raku can end up the winner in peformance by distributing work over multiple cores.

I won't go into details—you can consult [the documentation](http://docs.raku.org/language/concurrency) or watch [my talk that mentions them](https://youtu.be/paa3niF72Nw?t=32m14s) ([slides here](http://tpm2016.zoffix.com/#/33)). I will show an example, though:

```` raku
await (
    start { say "One!";   sleep 1; },
    start { say "Two!";   sleep 1; },
    start { say "Three!"; sleep 1; },
);
say now - INIT now;
# OUTPUT:
# One!
# Three!
# Two!
# 1.00665192
````

We use the `start` keyword to create three [Promises](http://docs.raku.org/type/Promise) and then use the `await` keyword to wait for all of them to complete. Inside our Promises, we print out a string and then sleep for at least one second.

The result? Our program has three operations that take at least 1 second each, yet the total runtime was just above 1 second. From the output, we can see it's not in order, suggesting code was executed on multiple cores.

That was quite easy, but we can crank it up a notch and use a `HyperSeq` to transform ordinary code into concurrent code with a single method call:

```` raku
for (1..4).race( batch => 1 ) {
    say "Doing $_";
    sleep 1;
}
say "Code took {now - INIT now} seconds to run";
# OUTPUT:
# Doing 1
# Doing 3
# Doing 2
# Doing 4
# Code took 1.0090415 seconds to run
````

We had a list of 4 items to work with. We looped over each of them and performed an expensive operation (in this case, a 1-second `sleep`). To modify our code to be faster, we simply called the [`.race` method](http://docs.raku.org/routine/race) on our list of 4 items to get a Hyper Sequence. Our loop remains the same, but it's now executing in a concurrent manner, as can be seen from the output: items are out of order and our total runtime was just over 1 second, despite a total of 4 seconds of sleep.

If the default batch size of `64` is suitable for you, it means you can go from a plain loop to a concurrent loop by simply typing 5 characters (`. r a c e`).

## Let's See Some Benchmarks

I won't show you any. There's hardly any sense in benchmarking *entire languages.* Clever one-liners can be written to support one point of view or another, but they simply abstract a problem into a simplistic singularity. Languages are different and they have vastly different tool kits to solve similar problems. Would you choose code that completes in 1 second and takes you 40 minutes to write or code that completes in 2 seconds, yet takes you 10 minutes to write? The choice depends on the type of application you're writing.

## Conclusion

Raku is a brand new product, so it doesn't make sense to compare it against software that existed for decades. It is being actively improved and, at least in theory, it should become performant on the level similar to other competing languages.

You don't have to wait for that to happen, however. Thanks to Raku's pre-compilation of modules, support of native types, and superb concurrency primitives you can substantially improve the performance of your code *right now.*

Some may disagree that Raku is slow, some may find it faster than another language, and some may say Raku is slower than my fat momma.

Who's to decide for you? Only you yourself can.
