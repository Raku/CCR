# A whole heap of work
    
*Originally published on [2016-03-21](https://6guts.wordpress.com/2016/03/21/a-whole-heap-of-work/) by Jonathan Worthington.*

The majority of my Raku grant time in the last week went on building a heap snapshot mechanism in MoarVM. But, before I dug into that, I worked on…

### More memory savings!

While I expect we’ll find plenty of interesting memory savings – not to mention the source of the `EVAL` memory leak – through the heap snapshots I’m working on, there’s still a good bit of info to be had from C-level heap profiling tools and taking a careful look at various data structures. This week, I found and improved 3 such things.

Every block, routine, or even thunk that we compile gets an ID that is unique within its compilation unit (that is, a body of code that is compiled at once). This is used to be able to refer to it unambiguously. Historically – dating all the way back to the Parrot days – these needed to be a bit more unique than just within a compilation unit. This made them fairly long, and since something like the Raku builtins have into the tens of thousands of them, they added up quickly. So, I [shortened them](https://github.com/raku/nqp/commit/27e99d4a587103b1cb23c0b0715eda5827a94ea5) a good bit, knocking 188KB of NQP’s base memory, 1424KB off Rakudo’s base memory, and making the compiled CORE.setting a nice 288KB smaller.

These routines, blocks, and thunks are all represented down in MoarVM as static frames – a data structure I’ve talked about a bit in previous posts here. Aware that we have a lot of them, I looked to see if there were any more relatively easy savings to be made. I discovered a couple.

First up, we were keeping around a small map of the bytecode that was used to indicate instruction boundaries. This was used for precisely one thing: outputting instruction offsets when showing low-level backtraces. We never actually show that data to any normal Raku end user. It was useful to have around early on in MoarVM’s development, but I can’t remember the last time I needed that information to debug something. It’s also hugely misleading these days, as the VM is often running specialized bytecode with lots of virtualization and indirection stripped out. So, I [just got rid of it](https://github.com/MoarVM/MoarVM/commit/44fcdb3504586587a54118aad84903215e0b6c21). We only generated these for the bytecode of static frames that were actually run, but it also saved a pointer for all static frames. In total, it was another 316KB off NQP’s base memory, and 1088KB off Rakudo’s.

Finally, back when I added the profiler, static frames got a few new fields. They’re totally unused when we’re not applying any kind of instrumentation, however. So, I [pulled them out](https://github.com/MoarVM/MoarVM/commit/44fcdb3504586587a54118aad84903215e0b6c21) into a single struct, reducing us to just one pointer per static frame for this state. That was another 144KB off NQP, and 1036KB off Rakudo.

These total to around 3.5MB off the base size of Rakudo (measured by running the empty loop program), and all give further savings once extra modules are loaded or more of CORE.setting is used.

### Multi caches get a size boost

I analyzed some code from *RabidGravy* doing sine wave generation, and noticed it was doing a lot of slow-path multi-dispatch. It turns out we were overflowing the multi caches, which in turn would be harming our ability to inline. While this points at a design issue I want to look into a little further, giving the caches a [size boost](https://github.com/MoarVM/MoarVM/commit/99bf383cb101058ece7840d26e3b1e020a733762) provided some instant relief, getting the code down to 60% of its previous runtime. This does mean we use a bit more memory, but only for multis that we actually call, which isn’t all that many just for a normal startup.

### Heap snapshots

This week I got a lot of work in on heap snapshots. First of all, what is a heap snapshot? It’s a representation of the memory allocated by a program, and under the management of the VM. In MoarVM this consists of three things:

- Objects (both type objects and instances)
- Shared Tables (aka “STables”), which hold the common things for a given meta-object and representation pairing
- Call frames

The first two are managed by the GC; in fact, most code in the GC doesn’t care which it’s dealing with. The third is managed for now by reference counts (the reasons why, and how this gives a mix of great properties and awful properties, is a discussion for another day!)

The point isn’t to capture all of the data on the heap, but rather to capture the size, identity, and reference structure of the data. Size is easy enough to understand – it’s just about how many bytes are used. Identity is about what type an object has (the class name, for example), what type an STable represents, and what block or routine in the code a particular call frame is an invocation of. Together with counting how many items we have, we can use size and idendity data to answer questions like, “what kinds of objects are using up loads of memory”. I’ll be intersted to use this to see what’s eating up memory in NQP and Rakudo, before you even start doing any interesting work.

Reference structure is more interesting. It’s about what things point to, or refer to, other things. MoarVM has a reachability based GC. When we garbage collect, we start from a set of roots, which consist of things like the call stacks of each running thread along with other per-thread and per-VM state. We then – conceptually, at least – “mark” all the objects that these roots reference and put them on a todo list. We then visit them, asking each of them what they reference, and putting those objects onto the todo list. By taking care never to put an already marked object onto the todo list, we can be confident we’ll eventually terminate with an empty list. At the end, all of the unmarked objects are declared unreachable, and we can free them up. (And just to drive it home: this is a good way to conceptually understand what a reachability GC does, but does not reflect the way modern VMs that need to efficiently manage a large number of objects actually do it. And, like nearly all abstractions, it hides details that can matter in reality. Again, a topic for another day. :-))

Anyway, the reference structure is all about answering *why* a given object is still in memory. What path from the roots is keeping it alive? This is the sort of data that will help me understand the leaky `EVAL` bug I mentioned a week or so back.

Taking a heap snapshot involves capturing all of the raw data. It’s rather important that the process of taking a heap snapshot does not impact the liveness of the things in the snapshot. The instrumenting profiler, which was primarily built for giving us insight into microbenchmarks and how the dynamic optimizer works with them, references real type objects and static frames in its data set, which is then post-processed. In doing so, it keeps them alive. But the heap snapshotter doing this would be a disaster! It would distort the set of live objects, which it exists to measure. So, rule 1 is that the heap snapshot data structure must never hold any references to GC-managed objects. In fact, that’s probably the only really important rule. Of course, it’s going to affect the amount of memory the VM uses, but that must not show up in any way in the results. Most of the remaining challenge in taking heap snapshots is about trying to capture the data in a sufficiently compact way that it’s just large rather than utterly huge.

Another interesting question is when to take heap snapshots. A fairly good time is just after a GC run. Why? Because we’re in a state of “stop the world” at that point anyway, so we really are taking a snapshot of an atomic point in time with regard to the execution of the program. So, that’s where it’s done. (Note that this doesn’t bias things, in so far as we’d never be wanting to include unreachable things into the snapshot anyway.)

Anyway, by this point I’ve got pretty far with the code that does the snapshotting. It happily finds all object and STable references, and I’m part of the way through frames, which will mean it can snapshot the memory associated with closures properly. So, not much more work to go on producing the snapshots themselves.

Once I’ve got complete snapshots being produced, the next task will be to build some tools to analyze them. There will also be some work to make the snapshots a bit more detailed (for example, including the names of object attributes, so it’s easier to see the path keeping an object alive). I’ll probably take on some basic analysis tooling first, however, because I think even without that added context the snapshots will still be hugely revealing. Stay tuned for next week’s report for more!
