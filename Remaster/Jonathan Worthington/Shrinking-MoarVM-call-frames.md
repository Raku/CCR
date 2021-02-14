# Shrinking MoarVM call frames
    
*Originally published on [2017-07-30](https://6guts.wordpress.com/2017/07/30/shrinking-moarvm-call-frames/) by Jonathan Worthington.*

Last week, I did some work to greatly decrease the size of call frames, also know as invocation records, in MoarVM. In theory, a call frame is created whenever a sub, method, regex, or block is entered. In reality, scopes may be flattened away at compile time, which decreases the number of call frames needed. Further to that, dynamic optimization at runtime leads to inlining, which has the same result except it can do it with late-bound calls, even with callees in different compilation units. Even with these optimizations (and in part because of their limitations), most programs will still need to create and destroy many call frames over their lifetime, making their setup and tear-down a hot path, and their size a factor in program memory performance.

The work I’ll describe in this post has been funded by [OETIKER+PARTNER AG](http://www.oetiker.ch/), who responded to my recent [funding call](https://6guts.wordpress.com/2017/05/12/looking-for-perl-6-rakudo-and-moarvm-development-funding/). In fact, they’re funding around 10 hours of work per month over the space of a year, so this will be just the first of a number of posts describing work that they are making possible. So, thanks!

### Background

The `MVMFrame` data structure has been there since the very earliest days of MoarVM. My memory is hazy, but I suspect it was among the first dozen data structures that I sketched out when starting to design and implement the VM. Initially, call frames were reference counted and allocated out of a special pool. Now they live either in a per-thread callsite region allocated by incrementing a pointer and deallocated by decrementing the pointer, much like a traditional call stack, or on the heap if they “escape” (as a result of a closure, exception throw, or continuation). At present, that heap promotion is always lazy (so call frames are always born on the call stack).

Therefore, the size of an `MVMFrame` impacts:

- How much memory we have to allocate in the call stack region, and thus how quickly we fill up that region if we’re recursing deeply
- How much memory we have to touch when setting up a frame (which impacts on CPU cache utilization); until the work described in this post the frame memory was cleared by a `memset` call, so the size also impacted how much work that had to do
- How much we have to copy if promoting the frame onto the heap
- How soon we’ll have to GC again (smaller frames on the heap mean longer until we fill the nursery and have to collect)
- How much memory closures take

Over the years, `MVMFrame` has grown. Various things were added in support of additional features. However, not all of those things are used by all frames. Additionally, some of them, while used widely, were both quite rarely read and very cheap to compute when they were needed, meaning it was better to just re-calculate them on demand.

### Effective handlers and bytecode

Two pointers were taken up for storing the effective handlers and bytecode. The bytecode holds the instructions to execute, and the handlers are the regions of that bytecode covered by exception handlers. At first, these fields did not exist in `MVMFrame`. The bytecode and handlers weren’t properties of a given call, but of the code being called (known as the “static frame” in MoarVM). So why these fields?

They were introduced with the dynamic optimizer. This produces one or more versions of the frame’s bytecode specialized by callsite and type. The specialized version of the code is selected based upon what the callee passes. Since the specialized bytecode contains different (typically many less) instructions, the code offests covered by exception handlers move also, so we need to use an updated table of those when locating an exception handler.

It was certainly convenient to hang pointers to these two off the frame. But we could always locate them just by following the `spesh_cand` pointer in the frame, if it was set, or the `static_info` pointer if not. And this isn’t something that we needed to do so often that this extra dereference was going to add up. The only common path we needed to do it on was on return. But we’d be losing the instruction to set it in the invocation, so it about balances anyway – and that’s before the considering the memory savings.

With those gone, `MVMFrame` shrunk 2 pointers, or 16 bytes in a 64-bit environment.

### Throw address

When an exception was thrown, MoarVM stored the address in the program that it was thrown at into…a pointer in the currently executing frame. It then referenced the frame from the exception object. And that was pretty much all the throw address field was used for. This was a very easy 8 bytes (64-bit pointer) to win: just store the address in the exception object, where it belongs anyway. D’oh.

### Rarely used things

Some things are used by just a small handful of frames:

- Continuation tags (used to find the base of a continuation when taking it)
- Slots to cache dynamic lexical lookups (so `$*FOO` can be found faster)
- Special return handlers (a way for the VM to set up internal callbacks when returning into a particular frame, which is a technique used to avoid nested interpreter instances, which are a huge problem when combined with continuations)
- A slot to keep an invoked call capture alive

These added up to 8 pointers and one 16-bit integer. By moving them into an “extras” data structure hung off the frame, and allocated on demand, space equivalent to 7 pointers could be saved off the frame. With 64-bit pointers, that’s 56 bytes of savings for most frames. The `CORE.setting` compilation ends up with only 6% of frames needing this extra storage space.

### Alignment

With a 16-bit integer moved off into the extras I realized that, with a little care, we could re-order things, force an enum to only use a single byte, and save another 8 bytes off `MVMFrame`, simply by not needing some empty wasted padding space in the struct (C compilers insert this to make sure memory reads are aligned to correct boundaries).

### Saving a memset

That’s 88 bytes of savings, which is around a cache line and a half on a typical CPU. It also means that nearly all of the things left in `MVMFrame` were being initialized on every invocation as part of the callframe setup. Meaning? That the `memset` of `MVMFrame` could go away, at the cost of just inserting a couple of instructions to manually zero or NULL things out (some of them on rarely taken paths).

### But wait, there’s more…

While I was working on this, and looking at profiles, I noticed that a large number of allocations came from creating a buffer to keep track of which named arguments had been used and which had not (for the sake of error reporting and slurpy argument handling). We allocated a byte array, but only really need a bit per named argument. So, I turned the field into a union of a 64-bit bit field for when there are at most 64 named arguments (which is probably just about every real world use case), and fall back to the old byte array approach otherwise.

### All in all…

These changes provide some memory use reductions, but more importantly are good for CPU cache locality. They also knock 2% off the number of CPU instructions run during CORE.setting compilation; many other programs should see a similar improvement (how much depending on how much of a hot path invocation is, and how many closures they take).
