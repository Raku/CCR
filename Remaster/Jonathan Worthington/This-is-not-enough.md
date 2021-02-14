# This is not enough!
    
*Originally published on [2011-09-17](https://6guts.wordpress.com/2011/09/17/this-is-not-enough/) by Jonathan Worthington.*

The time for some shiny new hardware came around. Sat next to me, purring decidedly more quietly that its predecessor, is my new main development machine: a quad core Intel Core i7, pimped out with 16 GB of RAM and a sufficiently generous SSD that it can hold the OS, compiler toolchain and projects I work most actively on. It’s nice having a [$dayjob](http://www.edument.se/) that likes keeping their hackers…er, consultants…well kitted out. :-)

So, the question I had to ask was: how fast can this thing run the Rakudo spectests? I tried, and with –jobs=8 (the sweet spot, it seems) it chugged its way through them in 220s. That’s vastly better than I’d ever been able to do before, and I could immediately see it was going to be a boon for my Rakudo productivity. 3 minutes 40 seconds. Not so long to wait to know a patch is fine to push. But…what if it was less? It’s fast but…this is not enough!

A while ago, *moritz*++ showed how the nom branch of Rakudo ran [mandelbrot 5 times faster than master](http://perlgeek.de/blog-en/perl-6/how-fast-is-nom.html). This was a fairly nice indicator. Around the time my new hardware arrived, an update was posted on #raku: mandelbrot was now down to 2 minutes on the same machine the original tests were done. Again, I was happy to see progress in the right direction but I couldn’t help but feel…this is not enough!

So, I took a few days break from bug fixing and features, and decided to see if things could get faster.

### Faster Attribute Access

One of the things I’ve had planned for since the early days of working on 6model is being able to look up attributes by index in the single inheritance case, rather than by name. I finally got around to finishing this up (I’d already put in most of the hooks, just not done the final bits). It’s not an entirely trivial thing to make work; at the point we parse an attribute access we don’t know enough about how the eventual memory layout of the object will be, or whether an indexed lookup will even work. Further, we have to involve the representation in the decision, since we can’t assume all types will use the same one. Mostly, it just involves a later stage of the code generation (PAST => POST in this case) having the type object reachable from the AST and asking it for a slot index, if possible.

Since I implemented it at the code-gen level, it meant the improvement was available to both NQP and Rakudo, so we get compiler and runtime performance improvements from it. Furthermore, I was able to improve various places where the VM interface does attribute lookups (for example, invocation of a code object involves grabbing the underlying VM-level thingy that represents an executable thing, and that “grabbing” is done by an attribute access on the code object). Attribute lookups never really showed up that high in the (C-level) profile, but now they’re way, way down the list.

### The P6opaque Diet

P6opaque is by far the most common object representation used in NQP and Rakudo. It’s generally pretty smart; it has a header, and then lays out attributes – including natively typed ones – just like a C structure would be laid out in memory. In fact, it mimics C structures well enough that for a couple of parts of the low-level parts of Rakudo we have C struct definitions that let us pretend that full-blown objects are just plain old C structures. We don’t have to compromise on having first class objects in order to write fast low-level code that works against them any more. Of course, you do commit to a representation – but for a handful of built-in types that’s fine.

So, that’s all rainbows and butterflies, so what was the problem? Back last autumn, I thought I knew how implementing mix-ins and multiple inheritance attribute storage was going to look; it involved some attributes going into a “spill hash” if they were added dynamically, or all of them would go there apart from any in a common SI prefix. Come this spring when I actually did it for real, a slightly smarter me realized I could do much better. It involved a level of indirection – apart from that level already existed, so there was actually no added cost at all. Thing is, I’d already put the spill slot in there, and naughtily used the difference between NULL and PMCNULL as the thing that marked out whether the object was a type object or not.

This week, I shuffled that indicator to be a bit in the PMC object header (Parrot makes several such bits available for us to use for things like that). This meant the spill slot in the P6opaque header could go away. Result: every object using the P6opaque representation got 4 (32-bit) or 8 (64-bit) bytes lighter. This has memory usage benefits, but also some speed ones: we get more in the CPU cache for one, and for another we can pack more objects into fixed sized pools, meaning they have less arenas to manage. Win.

### Constant Pain

In Raku we have `Str` objects. Thanks to 6model’s capability to embed a native Parrot string right into an object, these got about three times cheaper in terms of memory already in nom. Well, hopefully. The thing is, there’s a very painful way to shoot yourself in the foot at the implementation level. 6model differentiates coercion (a high level, language sensitive operation) from unboxing (given this object, give me the native thingy inside of it). Coercion costs somewhat more (a method call or two) than unboxing (mostly just some pointer follows). If you manage to generate code that wants a VM-level string, and it just has an object, it’ll end up doing a coercion (since at that level, it doesn’t know the much cheaper unbox is possible/safe). After reading some of the compiler output, I spotted a bunch of cases where this was happening – worst of all, with constant strings in places we could have just emitted VM-level constant strings! Fixing that, and some other unfortunate cases of coercion instead of unbox, meant I could make the join method a load faster. Mandelbrot uses this method heavily, and it was a surprisingly big win. String concatenation had a variant of this kind of issue, so I fixed that up too.

### Optimizing Lexical Lookup

We do a lot of lexical lookups. I’m hopeful that at some point we’ll have an optimizer that can deal with this (the analysis is probably quite tricky for full-blown Raku; in NQP it’s much more tractable). In the meantime, it’s nice if they can be faster. After a look over profiler output, I found a way to get a win by caching a low-level hash pointer directly in the lexpad rather than looking it up each time. Profilers. They help. :-)

### Optimized MRO Compuation

The easiest optimizations for me to do are…the ones somebody else does. Earlier this week, after looking over the output from a higher level profiler that he’s developing for Parrot, *mls*++ showed up with a patch that optimized a very common path of C3 MRO computation. Curiously, we were spending quite a bit of time at startup doing that. Of course, once we can serialize stuff fully, we won’t have to do it at all, but this patch will still be a win for compile time, or any time we dynamically construct classes by doing meta-programming. A startup time improvement gets magnified by a factor of 450 times over a spectest run (that’s how many files we have), and it ended up being decidedly noticeable. Again, not where I’d have thought to look…profiling wins again.

### Multi-dispatch Cache

We do a lot of multiple dispatch in Raku. While I expect an optimizer, with enough type information to hand, will be able to decide a bunch of them at compile time, we’ll always still need to do some at runtime, and they need to be fast. While we’ve cached the sorted candidate list for ages, it still takes a time to walk through it to find the best one. When I was doing the 6model on CLR work, I came up with a design for a multi-dispatch cache that seemed quite reasonable (of note, it does zero heap allocations in order to do a lookup and has decent cache properties). I ported this to C and…it caused loads of test failures. After an hour of frustration, I slept on it, then fixed the issue within 10 minutes the next morning. Guess sleep helps as well as profilers. Naturally, it was a big speed win.

### Don’t Do Stuff Twice

Somehow, in the switch over to the nom branch, I’d managed to miss setting the flag that causes us not to do type checks in the binder if the multi-dispatcher already calculated they’d succeed. Since the multi-dispatch cache, when it gets a hit, can tell us that much faster than actually doing the checks, not re-doing them is a fairly notable win.

### Results

After all of this, I now have a spectest run in just short of 170 seconds (for running 14267 tests). That’s solidly under the three minute mark, down 50s on earlier on this week. And if it’s that much of a win for me on this hardware, I expect it’s going to amount to an improvement measured in some minutes for some of our other contributors.

And what of mandelbrot? Earlier on today, moritz reported a time of 51 seconds. The best we ever got it to do in the previous generation of Rakudo was 16 minutes 14 seconds, making for a 19 times performance improvement for this benchmark.

### This is not enough!

Of course, these are welcome improvements, and will make the upcoming first release of Rakudo from this new “nom” development branch nicer for our users. But it’s just one step on the way. These changes make Rakudo faster – but there’s still plenty to be done yet. And note that this work doesn’t deliver any of the “big ticket” items I mentioned in my previous post, which should also give us some good wins. Plus there’s parsing performance improvements in the pipeline – but I’ll leave those for *pmichaud*++ to tell you about as they land. :-)
