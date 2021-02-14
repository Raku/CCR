# This week: fixing lots of things
    
*Originally published on [2015-06-14](https://6guts.wordpress.com/2015/06/14/this-week-fixing-lots-of-things/) by Jonathan Worthington.*

My first week of Raku work during June was spent hunting down and fixing bugs, some of them decidedly tricky and time-consuming to locate. I also got a couple of small features in place.

### Unicode-related bugs

RT #120651 complained that our UTF-8 encoder wrongly choked on non-characters. While there were defined as “not for interchange” in the Unicode spec, this does not, it turns out, mean that we should refuse to encode them, as clarified by Unicode [Corrigendum 9](http://www.unicode.org/versions/corrigendum9.html). So, I did what was needed to bring us in line with this.

RT #125161 counts as something of an NFG stress test, putting a wonderful set of combiners onto some base characters. While this was read into an NFG string just fine, and we got the number of graphemes correct, and you could output it again, asking for its NFD representation exploded. It turned out to be a quite boring bug in the end, where a buffer was not allowed to grow sufficiently to hold the decomposition of such epic graphemes.

Finally, I spent some time with the design documents and test suite with regard to strings and Unicode. Now we know how implementing NFG turned out, various bits of the design could be cleaned up, and several things we turned out not to need could go away. This in turn meant I could clean them out of the test suite, and close the RT tickets that pointed us towards needing to review/implement what the tests in question needed.

### Two small features

In Raku we have `EVAL` for evaluating code in a string. We’ve also had `EVALFILE` in the design and test suite for a while, which evaluates the code in the specified file. This was easily implemented, resolving RT #125294.

Another relatively easy, but long-missing, feature was the quietly statement prefix. This swallows any warnings emitted by the code run in its dynamic scope. Having recently improved various things relating to control exceptions, this one didn’t take long to get in place.

### Concurrency bug squishing continues

In the last report, I was working on making various asynchronous features, such as timers, not accidentally swallow a whole CPU core. I’d fixed this, but mentioned that it exposed some other problems, so we had to back to fix out. The problem was, quite simply, that by not being so wasteful, we ran into an already existing race condition much more frequently. The race involved lazy deserialization: something we do in order to only spend time and memory deserializing meta-objects that we will actually use. (This is one of the things that we’ve used to get Rakudo’s startup time and base memory down.) While there was some amount of concurrency control in place to prevent conflicts over the serialization reader, there was a way that one thread could see an object that another one was part way through deserializing. This needed a lock-free solution for the common “it’s not a problem” path, so we would not slow down every single wval instruction (the one in MoarVM used to get a serialized object, deserializing it on demand if needed). Anyway, it’s now fixed, and the core-eating async fix is enabled again.

I also spent some time looking into and resolving a deadlock that could show up, involving the way the garbage collector and event loop were integrated. The new approach not only eliminates the deadlock, but also is a little more efficient, allowing the event loop thread to also participate in the collection.

Finally, a little further up the stack, I found the way we compiled the given, when, and default constructs could lead to lexical leakage between threads. I fixed this, eliminating another class of threading issues.

### The case of the vanishing exception handler

Having our operators in Raku be multi-dispatch subroutines is a really nice bit of language design, but also means that we depend heavily on optimization to get rid of the overhead on hot paths. One thing that helps a good bit is inlining: working out which piece of code we’re going to call, and then splicing it into the caller, eliminating the overhead of the call. For native types we are quite good at doing this at compile time, but for others we need to wait until runtime – that is, performing dynamic optimization based upon the types that actually show up.

Dynamic optimization is fairly tricky stuff, and of course once in a while we get caught cheating. RT #124191 was such an example: inlining caused us to end up missing some exception handlers. The issue boiled down to us failing to locate the handlers in effect at the point of the inlined call when the code we had inlined was the source of the exception. Now, a tempting solution would have been to fix the exception handler location code. However, this would mean that it would have to learn about how callframes with inlining look – and since it already has to work differently for the JIT, there was a nice combinatoric explosion waiting to happen in the code there. Thankfully, there was a far easier fix: creating extra entries in the handlers table. This meant the code to locate exception handlers could stay simple (and so fast), and the code to make the extra entries was far, far simpler to write. Also, it covered JIT and non-JIT cases.

So, job done, right? Well…sadly not. Out of the suite of tens of thousands of specification tests, the fix introduced…6 new failures. I disabled JIT to see if I could isolate it and…the test file exploded far earlier. I spent a while trying to work out what on earth was going on, and eventually took the suggestion of giving up for the evening and sleeping on it. The next morning, I thankfully had the idea of checking what happened if I took away my changes and ran the test file in question without the JIT. It broke, even without my changes – meaning I’d been searching for a problem in my code that wasn’t at all related to it. It’s so easy to forget to validate our assumptions once in a while when debugging…

Anyway, fixing that unrelated problem, and re-applying the exception handler with inlining fix that this all started out with, got me a passing test file. Happily, I flipped the JIT back on and…same six failures. So I did have a real failure in my changes after all, right? Well, depends how you look at it. The final fix I made was actually in the JIT, and was a more general issue, though in reality we could not have encountered it with any code our current toolchain will produce. It took my inlining fixes to produce a situation where we tripped over it.

So, with that fix applied too, I could finally declare RT #124191 resolved. I added a test to cover it, and was happy to be a tricky bug down. Between it and the rest of the things I had to fix along the way, it had taken the better part of a full day worth of time.

### Don’t believe all a bug report tells you

RT #123686 & RT #124318 complained about the dynamic optimizer making a mess of temp variables, and linked it also to the presence of a where clause in the signature. Having just worked on a dynamic optimizer bug, I was somewhat inclined to believe it – but figured I should verify the assumption. It’s good I did; while you indeed could get the thing to fail sooner when the dynamic optimizer was turned on, running the test case for some extra iterations made it explode with all of the optimization turned off also. So, something else was amiss.

Some bugs just smell of memory corruption. This one certainly did; changing things that shouldn’t matter changed the exact number of iterations the bug needed to occur. So, out came Valgrind’s excellent memcheck tool, which I could make whine about reads of uninitialized memory with…exactly one iteration to of the test that eventually exploded. It also nicely showed where. In the end, there were three ingredients needed: a block with an exit handler (so, a `LEAVE`, `KEEP`, `UNDO`, `POST`, `temp` variable or `let` variable), a parameter with a `where` clause, and all of this had to be in a multi-dispatch subroutine. Putting all the pieces together, I soon realized that we were incorrectly trying to run exit handlers on fake callframes we make in order to test if a given multi-candidate will bind a certain set of arguments. Since we never run code in the callframe, and only use it for storage while we test if the signature could bind, the frame was never set up completely enough for running the handlers to work out well. It may have taken some work to find, but thankfully very easy to fix.

### Other assorted bits

I did various other little things that warrant a quick mention:

- Fix RT #125260 (sigils of placeholder parameters did not enforce type constraints)
- Fix RT #124842 (junction tests fudged for wrong reason, and also incorrect)
- Fix attempts to auto-thread `Junction` type objects, which led to weird exceptions rather than a dispatch failure; add tests
- Review a patch to fix a big endian issue in MoarVM exception optimization; reject it as not the right fix
- Fix Failures that were fatalized reporting themselves as leaked/unhandled
- Investigate RT #125331, which is seemingly due to reading bogus annotations
- Fix a MoarVM build breakage on some compilers
