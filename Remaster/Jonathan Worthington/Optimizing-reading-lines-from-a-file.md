# Optimizing reading lines from a file
    
*Originally published on [2017-07-02](https://6guts.wordpress.com/2017/07/02/optimizing-reading-lines-from-a-file/) by Jonathan Worthington.*

Reading lines from a file and processing them one at a time is a hugely common scripting task. However, to date our performance at this task has been somewhat underwhelming. Happily, a grateful Raku fan stepped up in response to my recent [call for funding](https://6guts.wordpress.com/2017/05/12/looking-for-perl-6-rakudo-and-moarvm-development-funding/), offering 25 hours of funding to work on whatever I felt was most pressing, but with a suggestion that perhaps I could look at some aspect of I/O performance. Having recently been working on [refactoring I/O](https://6guts.wordpress.com/2017/06/08/sorting-out-synchronous-io/) anyway, this was very timely. So, I crafted a benchmark and dug in.

### The benchmark and a baseline

Perl is considered to have very good I/O performance, so I figured I’d use that as a rough measure of how close Raku was to performing well at this task. A completely equivalent benchmark isn’t quite possible, but I tried to pick something representative of what the average programmer would write. The task for the benchmark was to take a file with one million lines, each having 60 characters, loop over them, and add up the number of characters on each line. That number would then be printed out at the end (it’s important that benchmarks calculating results return or consume the result in some way, as a sufficiently smart optimizer may otherwise manage to eliminate the work we think we’re measuring). The rules were that:

- The file should be read as UTF-8
- The number of characters in the line should exclude the line ending

The Perl benchmark for this came out as follows:

```` perl
perl -e 'open my $fh, "<:encoding(UTF-8)", "longfile";
         my $chars = 0;
         while ($_ = <$fh>) { chomp; $chars = $chars + length($_) };
         close $fh;
         print "$chars\n"'
````

With the Raku one looking like this:

```` raku
raku -e 'my $fh = open "longfile";
          my $chars = 0;
          for $fh.lines { $chars = $chars + .chars };
          $fh.close;
          say $chars'
````

I’ll note right off that in Raku there are likely ways, today, to do a bit better. For example, the `$chars` variable could be given a native `int` type, and it’s entirely possible that a while loop might come out faster than the `for` loop. Neither of those are representative of what a typical programmer looking at the documentation and diving in to implementing stuff would do, however. I suspect that Perl experts could similarly point out some trick I’ve missed, but I’m trying to benchmark typical use.

One slight unfairness is that the Raku solution will actually count the number of grapheme clusters, since strings are at grapheme level. This entails some extra processing work, even in the case that there are no multi-codepoint clusters in the input file (as there were not in this case). But again, the average user making comparisons won’t much care for such technicalities.

All measurements were made on modern hardware with an Intel Xeon 6-core CPU and a fast SSD, and on Linux.

At the point I started work, the Raku solution clocked in at 2.87s, to just 1.13s for Perl. This made Raku a factor of 2.5 times slower.

### First hints from the profile

The whole I/O stack recently got a good overhaul, and this was the first time I’d looked at a profile since that work was completed. Looking at the output from `--profile` immediately showed up some rather disappointing numbers. Of all callframes, 57.13% were JIT-compiled. Worse, basically nothing was being inlined.

At this point, it’s worth recalling that Raku is implemented in Raku, and that there’s quite a bit going on between the code in the benchmark and ending up in either things implemented in C or a system call. The call to `lines` returns an `Iterator` object. Reading a line means calling the `pull-one` method on that `Iterator`. That in turn calls the `consume-line-chars` method on a `$!decoder` object, and that method is what actually calls down to the VM-backed decoder to read a line (so there’s a level of indirection here to support user provided decoders). The return value of that method then has `defined` called on it to check we actually got a line back. If yes, then it can be returned. If not, then `read-internal` should be called in order to fetch data from the file handle (given buffering, this happens relatively rarely). Running the loop body is a further invocation, passing the read line as a parameter. Getting the `chars` count is also a method call (which, again, actually calls down to the VM guts to access the string’s grapheme count).

That’s quite a lot of method calling. While the VM provides I/O, decoding, and finding input up to a separator, the coordination of that whole process is implemented in Raku, and involves a bunch of method calls. Seen that way, it’s perhaps not surprising that Raku would come in slower.

There are, however, things that we can do to make it fast anyway. One of them is JIT compilation, where instead of having to interpret the bytecode that Raku is compiled in to, we further translate it into machine code that runs on the CPU. That cuts out the interpreter overhead. Only doing that for 57% of the methods or blocks we’re in is a missed opportunity.

The other really important optimization is inlining. This is where small methods or subroutines are taken and copied into their callers by the optimizer. This isn’t something we can do by static analysis; the point of methods calls is polymorphism. It is something a VM doing dynamic analysis and type specialization can do, however. And the savings can be rather significant, since it cuts out the work of creating and tearing down call frames, as well as opening the door to further optimization.

### The horrors in the logs

There are a couple of useful logs that can be written by MoarVM in order to get an idea of how it is optimizing, or failing to optimize, code. The JIT log’s main point of interest for the purpose of optimization is that it can indicate why code is not being JIT-compiled – most commonly because it contains something the JIT doesn’t know about. The first thing in this case was the call into the VM-backed decoder to extract a line, which was happily [easily handled](https://github.com/MoarVM/MoarVM/commit/78ac0ad54c27f06c542273e5d1db57ba399b6924). Oddly, however, we still didn’t seem to be running the JIT-compiled version of the code. Further investigation uncovered an unfortunate mistake. When a specialized version of a method calls a specialized version of another method, we don’t need to repeat the type checks guarding the second method. This was done correctly. However, the code path that was taken in this case failed to check if there was a JIT-compiled version of the target rather than just a specialized bytecode version, and always ran the latter. I [fixed that](https://github.com/MoarVM/MoarVM/commit/21ee1a5048c76c7163adeaab6b56b8fd43173542), and went from 57.13% of frames JIT-compiled to 99.86%. Far better.

My next point of investigation is why the tiny method to grab a line from the decoder was not being inlined. When I took a look at the post-optimization code for it, it turned out to be no surprise at all: while the logic of the method was very few instructions, it was bulked out by type checking of the incoming arguments and return values. The `consume-line-chars` method looks like this:

```` raku
method consume-line-chars(Bool:D :$chomp = False, Bool:D :$eof = False --> Str) {
    my str $line = nqp::decodertakeline(self, $chomp, $eof);
    nqp::isnull_s($line) ?? Str !! $line
}
````

Specializations are always tied to a callsite object, from which we can know whether we’re being passed a parameter or not. Therefore, we should be able to optimize out those checks and, in the case the parameter is being passed, throw out the code setting the return value. Further, the `*%_` that all methods get automatically should have been optimized out, but was not being.

The latter problem was fixed [largely by moving code](https://github.com/MoarVM/MoarVM/commit/8fe17d3b3fa81221ae45fb45e127280e1aee563c), although tests showed a regression that needed a [little more care](https://github.com/MoarVM/MoarVM/commit/2e9aff7feba166edaa7fecc6041de48058e56a3c) to handle – namely, that a sufficiently complex default value might do something that causes a deoptimization, and we need to make sure we can fall back into the interpreter and have things work correctly in that case.

While these changes weren’t enough to get `consume-line-chars` inlined, they did allow an inlining elsewhere, taking the inline ratio up to 28.49% of call frames.

These initial round of changes took the Raku benchmark from 2.87s to 2.77s, so about 3.5% off. Not much, but something.

### Continuing to improve code quality

The code we were producing even pre-optimization was disappointing in a few ways. Firstly, even though a simple method like `consume-line-chars`, or `chars`, would never possibly do a `return`, we were still spitting out a return exception handler. A little investigation revealed that we were only doing analysis and elimination of this for `sub`s but not `method`s. Adding that analysis [for methods too](https://github.com/rakudo/rakudo/commit/b0a1b6c31c8ee93dec53ba117bd2d8b68bfcfd31) took the time down to 2.58s. Knocking 7% off with such a small change was nice.

Another code generation problem lay in `consume-line-chars`. Access to a native lexical can be compiled in two ways: either just by reading the value (fine if it’s only used as an r-value) or by taking a reference to it (which is correct if it will be used as an l-value). Taking a reference is decidedly costly compare to just reading the value. However, it’s always going to always have the correct behavior, so it’s the default. We optimize doing so away whenever we can (in fact, all the most common l-value usages of it never need a reference either).

Looking at `consume-line-chars` again:

```` raku
method consume-line-chars(Bool:D :$chomp = False, Bool:D :$eof = False --> Str) {
    my str $line = nqp::decodertakeline(self, $chomp, $eof);
    nqp::isnull_s($line) ?? Str !! $line
}
````

We can see the read of `$line` here is, since `consume-line-chars` is not marked `is rw`, an r-value. Unfortunately, it was compiled as an l-value because the conditional compilation lost that context information. So, I [addressed that](https://github.com/raku/nqp/commit/cabe421f025ad1196f78f351c21a7b5b73ea90cd) and taught Rakudo to [pass along return value’s r-value context](https://github.com/rakudo/rakudo/commit/8ff980e78082f2219ccd9c3fb624b05a32bedbcb).

A native reference means an allocation, and this change cut the number of GC runs enormously, from 182 or them to 41 of them. That sounds like it should make a sensational difference. In fact, it got things down to 2.45s, a drop of just 5%. Takeaway lesson: allocating less stuff is good, but MoarVM’s GC is also pretty good at throwing away short-lived things.

### Meanwhile, back in the specializer…

With the worst issues of the code being fed into MoarVM addressed, it was back to seeing why the specializer wasn’t doing a better job of stripping out type checks. First of all, it turned out that optional named arguments were not properly [marking the default code dead](https://github.com/MoarVM/MoarVM/commit/c43f436103961669a812f11ab4180a951443ecc6) when the argument was actually passed.

Unfortunately, that wasn’t enough to get the type tests stripped out for the named parameters to `consume-line-chars`. In fact, this turned out to be an issue for *all* optional parameters. When doing type analysis, and there are two branches, the type information has to be merged at join points in the control flow graph. So it might see something like this in the case that the argument was not passed:

````
    Bool (default path) \   / Unknown (from passed path)
                         \ /
                   Result: Unknown
````

Or maybe this in the case that it was passed:

````
    Bool (default path) \   / Scalar holding Bool (from passed path)
                         \ /
                   Result: Unknown
````

In both cases, the types disagree, so they merge to unknown. This is silly, as we’ve already thrown out one of the two branches, so in fact there’s really no merge to do at all! To fix this up, I [marked variables (in single static assignment form) that died](https://github.com/MoarVM/MoarVM/commit/c08e4c29c220b27cf2826cf1f6fee48c754f9247) as a result of a basic block being removed. To make the dead basic blocks from argument analysis actually be removed, we needed to [do the dead code removal earlier](https://github.com/MoarVM/MoarVM/commit/bca35a4b8102f809442b6969e8f9e56b4f11492a) as well as doing it at the very end of the optimization process. With that marking in place, it was then possible to [ignore now-dead code’s contribution to a merge](https://github.com/MoarVM/MoarVM/commit/c0fcf1d7d83cf15cc1ce471eb6994fb8fbf1d5fe), which meant a whole load of type checks could now be eliminated. Well, in fact, only in the case where the optional was passed; a [further patch to mark the writers of individual instructions dead](https://github.com/MoarVM/MoarVM/commit/ec6d1cd7b960358396a02bc87f1bfed8dd32d147) for the purpose of merges was needed to handle the case where it was not.

That left the return type being checked on the way out, which also seemed a bit of a waste as we could clearly see it was a `Str`. After a tweak to Rakudo to [better convey type information](https://github.com/rakudo/rakudo/commit/7edf9da6b65758f5d69617cdbf892135ad8e4074) in one of its VM extension ops, that check was optimized out too.

And for all of this effort, the time went from…2.45s to 2.41s, just 2% off. While it’s cheaper to not type check things, it’s only so costly in the first place.

A further win was that, with the code for `consume-line-chars` now being so tiny, it should have been an inlining candidate. Alas, it was not, because the optional arguments was still having tracking information recorded just in case we needed to deoptimize. This seemed odd. It turned out that my earlier fix for this was too simplistic: it would leave them in if the method would *ever* deoptimize, not just if it would do it while handling arguments. I [tightened that up](https://github.com/MoarVM/MoarVM/commit/ebe2bb0b38bdae266ef39cca39da69096c8ee64e) and the time dropped to 2.37s, another 2% one. Again, very much worth it, but shows that invocation – while not super cheap – is also only so costly.

With `consume-line-chars` inlining now conquered, another area of the code we were producing caught by eye: boolification was, in some cases, managing to box an `int` into an `Int` only to them immediately unbox it and turn it into a `Bool`. Clearly this was quite a waste! It turned out that an earlier optimization to avoid taking native references had unexpected consequences. But even nicer was that my earlier work to pass down r-value context meant I could [delete some analysis and just use that mechanism instead](https://github.com/rakudo/rakudo/commit/241d292568a48f787145fc84f0da960bf8eba27c). That was worth 4%, bringing us to 2.28s.

### Taking stock

None of these optimizations so far were specific to I/O or touched the I/O code itself. Instead, they are general optimization and code quality improvements that will benefit most Raku programs. Together, they had taken the lines benchmark from 2.87s to 2.28s. Each may have been just some percent, but together they had knocked 20% off.

By this point, the code quality – especially after optimization – was far more pleasing. It was time to look for some other sources of improvement.

### Beware associativity

Perhaps one of the easiest wins came from spotting the `pull-one` method of the lines iterator seemed to be doing two calls to the `defined` method. See if you can spot them:

```` raku
method pull-`one` {
    $!decoder.consume-line-chars(:$!chomp) // $!handle.get // IterationEnd
}
````

The `//` operator calls `.defined` to test for definedness. Buy why two calls in the common case? Because of associativity! Two added parentheses:

```` raku
method pull-`one` {
    $!decoder.consume-line-chars(:$!chomp) // ($!handle.get // IterationEnd)
}
````

Were worth a whopping 8%. At 2.09s, the 2 second mark was in sight.

### Good idea, but…

My next idea for an improvement was a long-planned change to the way that simple `for` loops are compiled. With `for` being defined in terms of `map`, this is also how it had been implemented. However, for simple cases, we can just compile:

```` raku
for some-iteratable { blah }
````

Not into:

```` raku
some-iterable.map({ blah }).sink-all;
````

But instead in to something more like:

```` raku
my \i = some-iterable.iterator;
while (my \v = i.pull-one) !== IterationEnd {
    blah
}
````

Why is this an advantage? Because – at least in theory – now the `pull-one` and loop body should become possible to inline. This is not the case if we call `map`, since that is used with dozens of different closures and iterator types. Unfortunately, however, due to limitations in MoarVM’s specializer, it was not actually possible to achieve this inlining even after the change. In short, because we don’t handle inlining of closure-y things, and the way the on-stack replacement works means the optimizer is devoid of type information to have a chance to doing better with `pull-one`. Both of these are now being investigated, but were too big to take on as part of this work.

Even without those larger wins being possible (when they are, we’ll achieve a tasty near-100% inlining rate in this benchmark), it brought the time down to the 2.00s mark. Here’s [the patch](https://github.com/rakudo/rakudo/commit/9b0b9effe5fee1f35497cf97a5e7bda9bb083507).

### Optimizing line separation and decoding

Profiling at the C level (using callgrind) showed up some notable hot spots in the string handling code inside of MoarVM, which seemed to offer the chance to get further wins. At this point, I also started taking measurements of CPU instructions using `callgrind` too, which makes it easier to see the effects of changes that may come out as noise on a simple time measurement (even with taking a number of them and averaging).

Finding the separator happens in a couple of steps. First, individual encodings are set up to decode to the point that they see the final character of any of the line separators (noting these are configurable, and multi-char separators are allowed). Then, a second check is done to check if the multi-char separator was found. This is complicated by needing to handle the case where a separator was not found, and another read needs to be done from a file handle.

It turns out that this second pass was re-scanning the entire buffer of chars, rather than just looking close to the end of it. After checking there should not be a case where just jumping to look at the end would ever be a problem, I [did the optimization](https://github.com/MoarVM/MoarVM/commit/1f5be6a63ab3c2c2ac7e04cdc1ecd40c1739d284) and got a reduction from 18,245,144,315 instructions to 16,226,602,756, or 11%.

A further minor hot-spot was re-resolving the CRLF grapheme each time it was needed. It turned out [caching that value](https://github.com/MoarVM/MoarVM/commit/5814822f1319569bce60ba586a1fef62334521ed) saved around 200 million instructions. Caching the [maximum separator length](https://github.com/MoarVM/MoarVM/commit/f0854ac46d29448f868643267d74967c14bc9c52) saved another 78 million instructions. The wallclock time now stood at 1.79s.

The identification of separators when decoding chars seemed the next place to find some savings. CPUs don’t much like having to do loops and dereferences on hot paths. To do better, I [made a compact array of the final separator graphemes](https://github.com/MoarVM/MoarVM/commit/a8f2ac74fa7280425438b77baef148be5318518d) that could be quickly scanned through, and also introduced a [maximum separator codepoint filter](https://github.com/MoarVM/MoarVM/commit/8fa18578372819434cbc26901fe45e6f7e4c0f7c), which given the common case is control characters works out really quite well. These were worth 420 million and 845 million instructions respectively.

Next, I turned to the UTF-8 decoding and NFG process. A modest 56 million instruction win came from [tweaking this logic](https://github.com/MoarVM/MoarVM/commit/8972ab2ee2e6774c2c9ffcbc62b004e319a40f3f) given we can never be looking for a separator *and* have a target number of characters to decode. But a vast win came from adding a normalization [fast path](https://github.com/MoarVM/MoarVM/commit/a6abd3c6654413d2230470dbaa82b7b3a2b05762) for the common case where we don’t have any normalization work to do. In the case we do encounter such work, we simply fall into the slow path. One nice property of the way I implemented this is that, when reading line by line, one line may cause a drop into the slow path, but the next line will start back in the fast path. This change was worth a whopping 3,200 million decrease in the instruction count. Wallclock time now stood at 1.37s.

### Better memory re-use

Another look at the profile now showed `malloc`/`free` as significant costs. Could anything be done to reduce the number of those we did?

Yes, it turned out. Firstly, [keeping around a decoding result data structure](https://github.com/MoarVM/MoarVM/commit/9c5ea41cc7742d694e3bf7b78cc7333807f1c8f6) instead of freeing and allocating it every single line saved a handy 450 million instructions. It turned out that we were also copying the decoded chars into a new buffer when taking a line, but in the common case that buffer would contain precisely the chars that make up the line. Therefore, this buffer could simply [be stolen](https://github.com/MoarVM/MoarVM/commit/e48266b5e7d2fc3da42f94d3678483b75df574a7) to use as the memory for the string. Another 400 million instructions worth dropped away by a call less to `malloc`/`free` per line.

### Micro-optimizations

A few futher micro-optimizations in the new UTF-8 decoding fast-path were possible. By [lifting some tests out of the main loop](https://github.com/MoarVM/MoarVM/commit/ea1f506170ebb7d41f3e761ae0b3391534e1859e), [reading a value into a local](https://github.com/MoarVM/MoarVM/commit/b885d996d6664757ad9d9c2c7fc168b49af8b3d6) because the compiler couldn’t figure out it was invariant, and [moving some position updates so they only happen on loop exit](https://github.com/MoarVM/MoarVM/commit/369c0c5ca6f45aafcaa43e4d4cc03c5d7b8e4231), a further 470 million instructions were removed. If you’re thinking that sounds like a lot, this is a loop that runs every single codepoint we decode. A million line file with 60 chars per line plus a separator is 61 million iterations. These changes between them only save 7 cycles per codepoint; that just turns out to be a lot when multiplied by the number of codepoints!

### The final result

With these improvements, the Raku version of the benchmark now ran in 1.25s, which is just 44% of the time it used to run in. The Perl version still wins, but by a factor of 1.1 times, not 2.5 times. While an amount of the changes performed during this work were specific to the benchmark in question, many were much more general. For example, the separator finding improvements will help with this benchmark in all encodings, and the code generation and specializer improvements will have far more cross-cutting effects.

### Actually, not so final…

There’s still a decent amount of room for improvement yet. Once MoarVM’s specializer can perform the two inlinings it is not currently able to, we can expect a further improvement. That work is coming up soon. And beyond that, there will be more ways to shave off some instructions here and there. Another less pleasing result is that if Perl is not asked to do UTF-8 decoding, this represents a huge saving. Ask Raku for ASCII or Latin-1, however, however, and it’s just a small saving. This would be a good target for some future optimization work. In the meantime, these are a nice bunch of speedups to have.
