# Can’t forget about memory issues
    
*Originally published on [2016-03-13](https://6guts.wordpress.com/2016/03/13/cant-forget-about-memory-issues/) by Jonathan Worthington.*

I pondered at the end of last week’s post that I might work on speeding up object construction this week. I didn’t, but I did get a bunch of other useful stuff done – and got started on one of the big tooling deliverables of my grant.

### Lazy string decoding

Last week, I’d been working on lazily decoding strings, so we could save some memory. I nearly got it working, and noted that *Timo* dropped [a patch](https://github.com/MoarVM/MoarVM/commit/a501a41e37e403f2cec6229b75e5e18c48c75496) that got rid of the SEGV. This week I reviewed that patch. It was correct in so far as it fixed the issue, but I noted that other code was vulnerable to running into the same problem. In summary, the JIT compiler has a dynasm macro for grabbing a string from the string heap, and a robust fix would ensure we always made sure the string was decoded before JITting an unconditional lookup to it. So, I [fixed it that way](https://github.com/MoarVM/MoarVM/commit/3c5d4fe9d2d217caa3965ca4dea05f4903dba11b). Code review for the win!

With the patches merged, Rakudo’s memory use for the infinite loop program went down by 1272 KB, which is a welcome win. You might imagine that we’d have saved something on startup time by not doing the decoding work also. The answer is yes, but it’s in noise if you simply use something like `time`. Thankfully, there is a good way to measure more accurately: use [callgrind](http://valgrind.org/docs/manual/cl-manual.html) to count the number of CPU instructions retired running the empty program. That shows a reduction of about 2.7 million instructions – significant, though less than 1%, which is why it’s noise on the wallclock time. Still, such changes add up.

### Other little memory savings

Glancing the [massif heap profiler](https://www.google.cz/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwjrh-L0lr7LAhXD8HIKHQVEDBwQFggiMAA&url=http%3A%2F%2Fvalgrind.org%2Fdocs%2Fmanual%2Fms-manual.html&usg=AFQjCNFLSE7Yv3eWCkeF2y14-hya8Z-PSg) output after the previous fix, it struck me that another huge use of memory allocations at startup is static frames. Static frames represent the static things we know about call frames. Call frames are the things created whenever you enter a routine or block, and keep hold of your lexical variables. The actual lexical storage is created every call frame (to understand why this is needed, consider recursion). However, things like the name of a routine, its bytecode, the mapping of lexical names to lexical storage slots in the call frame, and the ranges of code covered by exception handlers is “static” data. Therefore, we store it once in the “static frame”, and each call frame just points to its static frame.

You never actually see a static frame from MoarVM’s user-space. They’re an implementation detail. What you do see are coderefs (or “code objects”), which point to a static frame and also have an outer pointer, which is what makes closures work.

We already do partially lazily deserialize static frames. In short, we always deserialize the part you need for operations that just want to talk about it, and only deserialize the rest of the data if you ever actually call that code. That was a really quite good saving, but it looks from the profile like there may be value in trying to push that laziness evey further. Again, for a typical Raku program, only a tiny fraction of the code in CORE.setting will ever be mentioned or invoked.

So, that may be a future task, but it will be a little tricky compared to strings. What I also did notice, however, is that in a compilation unit, we kept two arrays: one of static frames, and one of code objects. We almost never indexed the static frames array, and none of the places we did would be on a hot path. Since it was always possible to reach the static frames through the code objects, I did [the refactor](https://github.com/MoarVM/MoarVM/commit/824748db35636f2bd989f201705569f57f6cfc60) to get rid of the static frames array. It’s only a 16KB saving for NQP, but with Rakudo’s sizable CORE.setting and the compiler, we save a more satisfying 134KB off the memory needed for the infinite loop program. We also save ourselves walking through those long arrays of code objects during full GC runs (you’ll note the removed GC calls in the patch), which is also good for the CPU cache – and of course saves some instructions.

Another slightly cheeky saving came from lazily allocating GC nursery semispaces. The MoarVM GC, like most modern GCs that need to manage sizable heaps, is generational. This means it manages objects that live a long time differently from those that live a short time. For short-lived objects, we use a technique known as semi-space copying. The idea is simple: you allocate two equal size regions of memory (4MB each, per thread, in MoarVM). You do super-cheap bump-the-pointer allocation in the currently active semi-space. Eventually, you fill it, which triggers garbage collection. All the living objects are then copied, either to the start of the other semi-space if we never saw them before, or into the old generation storage if they survived a previous GC and so are probably going to be fairly long-lived.

For simple programs, or short-lived threads, we never need to ask for the second semi-space. In the past we always did. Now [we don’t](https://github.com/MoarVM/MoarVM/commit/43edc3fafff3f9b6528e596fe5f454cf71a67eda). It actually took a lot less time to write/test that patch than it did to explain it now. :-) But also, it’s worth noting that it’s a bit of a con on…well…every modern OS, I’d guess. While a heap profiler like massif will happily show that we just saved 4MB off each small program or short-lived thread, in reality operating systems don’t really swallow up pages of physical RAM until programs touch them. So, this is mostly a perception win for those who see numbers that factor in “what we asked for”, but it’s an easy one, and may save a brk system call or so.

### Assorted small fixes

My work on speeding up accessors turned out to cause a regression in a module that was enjoying intropsecting accessor methods. It turns out I didn’t mark the generated methods rw when I should have, even if the generated code was correct. An [easy fix](https://github.com/rakudo/rakudo/commit/d2e31e8150ed3c68e5532449398420d5138c4d11).

Next up, I looked into a concurrency bug, where channels coerced to supplies and supplies coerced to channels would behave in the wrong way with exceptions. I guess it’s a pretty symmetry in some sense that we ended up with both directions broken, but both directions working is even prettier, so I [fixed](https://github.com/rakudo/rakudo/commit/6184e157e1ea20d6132d62b1bddf0d7b96497d65) [both](https://github.com/rakudo/rakudo/commit/eb02dc9f774015c23a1316a97f5460354d9b4cf9) cases.

It turned out that writing a submethod `Bool` didn’t work out right in all cases, while a method `Bool` always did. Boolification is fairly hot-path, so is fairly optimized (on the other hand, with our increasingly smart dynamic optimizer, we might be able to rid ourselves of the special cases in the future). For now, it was another [easy fix](https://github.com/rakudo/rakudo/commit/fac3d7481ad2fb683809196837be109912ba9123) (at least, if you know the MOP code well enough!)

Finally I took on a nasty SEGV found by *Larry*, which turned out to golf to a crash when concatenating strings that had Unicode characters in a fairly particular range at the end of the first string (there we likely a few other paths to the same bug). It turned out to be a [silly braino](https://github.com/MoarVM/MoarVM/commit/45e24e0733bd1d287d5ea8073c2e5cd225d9c12b) in the generation of the primary composite table used for NFC transformation.

### The EVAL memory monster

An RT ticket reported that `EVAL` of a regex appears to leak (it in fact asked about the `<$x>` regex construct, but that golfs to an `EVAL`):

```` raku
for ^500 { EVAL 'regex { abcdef }' }
````

My first tool against leaks is Valgrind, which shows what memory is allocated but not freed. So, I tried it and…no dice. We leak very little, and it all seems to be missing cleanup at exit. The size of the leak was constant, not proportional to the number of `EVAL`s. Therefore, I wasn’t looking at a real leak in the sense that MoarVM loses track of memory. All the memory the `EVAL`s tie up is released at shut-down – it’s just not released as early as it should be.

My next theory was that perhaps we seem to leak because we end up with lots of objects promoted to the old generation of the GC, which we collect irregularly. That quickly became unlikely, though. The symptom of this is typically that memory use has a sawtooth shape, with lots getting allocated then a sudden big release on full collections. However, that didn’t seem to happen; memory use just grew. To completely rule it out, I tweaked [the settings](https://github.com/MoarVM/MoarVM/blob/master/src/gc/collect.h#L6) to make us do full collections really often, and it didn’t help.

While doing this analysis, I was looking at profiles some. The primary reason was because the profiler records all the GC runs that happen, so I could easily see that full heap collects really were happening. However, looking at the profile pointed out a few easy optimizations to compilation.

The first was noting that the `QAST::Block.symbol` method – used by the compiler to keep various interesting bits of data about symbols – was doing a huge number of allocations of hashes and hash iterators. I noted in many cases [we don’t need to](https://github.com/raku/nqp/commit/78db547acd3f8442705ca18b2fa806a4b876771d).

This was a big win – in fact, far too big. The profiler seemed to report too few allocations now. I dug in and noticed that it indeed was missing various allocations that could happen during parameter binding, both with [slurpies](https://github.com/raku/nqp/commit/78db547acd3f8442705ca18b2fa806a4b876771d) and [auto-boxing](https://github.com/MoarVM/MoarVM/commit/8ee9b920df4b996c3748d92953856b56a4f71e18). Fixing that in turn showed up that the very same symbol method accounted for a huge amount of allocation as a result of boxing the $name parameter. So, I did a few fixes so that we could [turn that to str](https://github.com/raku/nqp/commit/c8db98ba4196e0f9d9ea4295ec11be75bc0f7f5b).

The profiling data also showed up a few other easy wins in the AST to MoarVM compiler. One was [opting NQP in](https://github.com/raku/nqp/commit/d257c274c198369ff9a2c8424dd7ba9d32d616e9) to a multiple dispatch optimization in MoarVM that Rakudo was already using. The other was a [few more native type annotations](https://github.com/raku/nqp/commit/5cbce49ca5aec18ebac0fac83792fe4658ee572c)to cut out some more allocations.

These together meant that my leaking example from earlier now ran in 75% of the time it used to. These improvements will help compilation speed generally too. The bad, if unsurprising, news is they did nothing at all to help with the leak.

A little further analysis showed that we never release the compilation unit and serialization context objects. That only leads to another question: what is referencing them, and so keeping them alive and preventing their garbage collection? That’s not an easy question to answer without better tooling. Happily, in my grant I’d already proposed to write a heap profiler, which can record snapshots of the GC-managed heap.

So, I’ve started work on building that. It’s not trivial, but on the other hand at least a good bit less difficult than writing a garbage collector. :-) Since I seem to have found plenty to talk about in this post already, I’ll save discussing the heap profiler until next week’s post – when it might actually be at the point of spitting out some interesting data. See you then!
