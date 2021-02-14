# Taking a couple of steps backwards to fix a GC bug
    
*Originally published on [2016-11-30](https://6guts.wordpress.com/2016/12/01/taking-a-couple-of-steps-backwards-to-fix-a-gc-bug/) by Jonathan Worthington.*

When I popped up with a post here on Raku OO a few days ago, somebody noted in the comments that they missed my write-ups of my bug hunting and fixing work in Rakudo and MoarVM. The good news is that the absence of posts doesn’t mean an absence of progress; I’ve fixed dozens of things over the last months. It was rather something between writers block and simply not having the energy, after a day of fixing things, to write about it too. Anyway, it seems I’ve got at least some of my desire to write back, so here goes. (Oh, and I’ll try and find a moment in the coming days to reply to the other comments people wrote on my OO post too.)

### Understanding a cryptic error

There are a number of ways MoarVM can come tumbling down when memory gets corrupted. Some cases show up as segmentation faults. In other cases, the VM comes across something that simply does make any kind of sense and can infer that memory has become corrupted. Two panics commonly associated with this are “zeroed target thread ID in work pass” and “invalid thread ID XXX in GC work pass”, where XXX tends to be a sizable integer. At the start of a garbage collection – where we free up memory associated with dead objects – we do something like this:

1. Go through all the threads that have been started, and signal those that are not blocked (e.g. waiting for I/O, a lock acquisition, or for native code to finish) to come and participate in the garbage collection run.
1. Assign each non-blocked thread itself to work on.
1. Assign each blocked thread’s work to a non-blocked thread.

So, every thread – blocked or not – ends up assigned to a running thread to take care of its collection work. It’s the participation of multiple threads that makes the MoarVM GC parallel (which is a different thing to having a concurrent GC; MoarVM’s GC can barely claim to be that).

The next important thing to know is that the every object, at creation, is marked with the ID of the thread that allocated it. This means that, as we perform GC, we know whether the object under consideration “belongs” to the current thread we’re doing GC work for, or some other one. In the case that the ID in the object header doesn’t match up with the thread ID we’re doing GC work for, then we stick it into a list of work to pass off to the thread that is responsible. To avoid synchronization overhead, we pass then off in batches (so there’s only synchronization overhead per batch). This is far from the only way to do parallel GC (other schemes include racing to write forwarding pointers), but it keeps the communication between participating threads down and leaves little surface area for data races in the GC.

The funny thing is that if none of that really made any sense to you, it doesn’t actually matter at all, because I only told you about it all so you’d have a clue what the “work pass” in the error message means – and even that doesn’t matter much for understanding the bug I’ll eventually get around to discussing. Anyway, TL;DR version (except you did just read it all, hah!) is that if the owner ID in an object header is either zero or an out-of-range thread ID, then we can be pretty sure there’s memory corruption afoot. The pointer under consideration is either to zeroed memory, or to somewhere in memory that does not correspond to an object header.

### So, let’s debug the panic!

Getting the panic is, perhaps, marginally better than a segmentation fault. I mean, sure, I’m a bit less embarrassed when Moar panics than SEGVs, and perhaps it’s mildly less terrifying for users too. But at the end of the day, it’s not much better from a debugging perspective. At the point we spot the memory corruption, we have…a pointer. That points somewhere wrong. And, this being the GC, it just came off the worklist, which is full of a ton of pointers.

If only we could know where the pointer came from, I hear you think. Well, it turns out we can: we just need to detect the problem some steps back, where the pointer is added to the worklist. In `src/gc/debug.h` there’s this:

```` C
#define MVM_GC_DEBUG 0
````

Flip that to a 1, recompile, and magic happens. Here’s a rather cut down snippet from in `worklist.h`:

```` C
#if MVM_GC_DEBUG
#define MVM_gc_worklist_add(tc, worklist, item) \
    do { \
        MVMCollectable **item_to_add = (MVMCollectable **)(item); \
        if (*item_to_add) { \
            if ((*item_to_add)->owner == 0) \
                MVM_panic(1, "Zeroed owner in item added to GC worklist"); \
                /* Various other checks here.... */ 
        } \
        if (worklist->items == worklist->alloc) \
            MVM_gc_worklist_add_slow(tc, worklist, item_to_add); \
        else \
            worklist->list[worklist->*items*++] = item_to_add; \
    } while (0)
#else
#define MVM_gc_worklist_add(tc, worklist, item) \
    do { \
        MVMCollectable **item_to_add = (MVMCollectable **)(item); \
        if (worklist->items == worklist->alloc) \
            MVM_gc_worklist_add_slow(tc, worklist, item_to_add); \
        else \
            worklist->list[worklist->*items*++] = item_to_add; \
    } while (0)
#endif
````

So, in the debug version of the macro, we do some extra checks – including the one to detect a zeroed owner. This means that when MoarVM panics, the GC code that is placing the bad pointer into the list is on the stack. Then it’s a case of using GDB (or your favorite debugger), sticking a breakpoint on `MVM_panic` (spelled `break MVM_panic` in GDB), running the code that explodes, and then typing `where`. In this case, I was pointed at the last line of this bit of code from `roots.c`:

```` C
void MVM_gc_root_add_frame_roots_to_worklist(MVMThreadContext *tc, MVMGCWorklist *worklist,
                                             MVMFrame *cur_frame) {
    /* Add caller to worklist if it's heap-allocated. */
    if (cur_frame->caller && !MVM_FRAME_IS_ON_CALLSTACK(tc, cur_frame->caller))
        MVM_gc_worklist_add(tc, worklist, &cur_frame->caller);

    /* Add outer, code_ref and static info to work list. */
    MVM_gc_worklist_add(tc, worklist, &cur_frame->outer);
````

So, this tells me that the bad pointer is to an `outer`. The `outer` pointer of a call frame points to the enclosing lexical scope, which is how closures work. This provides a bit of inspiration for bug hunting; for example, it would now make sense to consider codepaths that assign `outer` to see if they could ever fail to keep a pointer up to date. The trouble is, for such an incredibly common language feature to be broken in that way, we’d be seeing it everywhere. It didn’t fit the pattern. In fact, both my private $dayjob application that was afflicted with this, together with the whateverable set of IRC bots, had in common that they did a bunch of concurrency work and both spawned quite a lot of subprocesses using `Proc::Async`.

### But where does the pointer point to?

Sometimes I look at a pointer and it’s obviously totally bogus (a small integer usually suggests this). But this one looked feasible; it was relatively similar to the addresses of other valid pointers. But where exactly does it point to?

There are only a few places that a GC-managed object can live. They are:

- In a thread’s `tospace` – that is, the region of memory for young objects that we allocate in, and copy objects into during a GC run
- In a thread’s `fromspace` – that is, the region of memory for young objects that we evacuate and copy objects out of during a GC run
- In one of the memory blocks that make up the old generation, where long-lived objects eventually end up

So, it would be very interesting to know if the pointer was into one of those. Now, I could just go examining it in the debugger, but with a dozen running threads, that’s tedious as heck. Laziness is of course one of the virtues of a programmer, so I wrote [a function to do the search](https://github.com/MoarVM/MoarVM/commit/c63d64987c0c8276fdc183f30cb077b3f8e7bce3) for me. Another re-compile, reproducing the bug in GDB again, and then calling that routine from the debugger told me that the pointer was into the `tospace` of another thread.

### Unfortunately, thinking is now required

Things get just a tad mind-bending here. Normally, when a program is running, if we see a pointer into `fromspace` we know we’re in big trouble. It means that the pointer points to where an object used to be, but was then moved into either `tospace `or the old generation. But when we’re in the middle of a GC run, the two spaces are flipped. The old `tospace` is now `fromspace`, the old `fromspace` becomes the new `tospace`, and we start evacuating living objects in to it. The space left at the end will then be zeroed later.

I should mention at this point that the crash only showed up a fraction of the time in my application. The vast majority of the time, it ran just fine. The odd time, however, it would panic – usually over a zeroed thread owner, but sometimes over a junk value being in the thread owner too. This all comes down to timing: different thread are working on GC, in different runs of the program they make progress at different paces, or get head starts, or whatever, and so whether the zeroing of the unused part of `tospace` happened or not yet will vary.

### But wait…why didn’t it catch the problem even sooner?

When the `MVM_GC_DEBUG` flag is turned on, it introduces quite a few different sanity checks. One of them is in `MVM_ASSIGN_REF`, which happens whenever we assign a reference to one object into another. (The reason we don’t simply use the C assignment operator for that is because the inter-generational write barrier is needed.) Here’s how it looks:

```` C
#if MVM_GC_DEBUG
#define MVM_ASSIGN_REF(tc, update_root, update_addr, referenced) \
    { \
        void *_r = referenced; \
        if (_r && ((MVMCollectable *)_r)->owner == 0) \
            MVM_panic(1, "Invalid assignment (maybe of heap frame to stack frame?)"); \
        MVM_ASSERT_NOT_FROMSPACE(tc, _r); \
        MVM_gc_write_barrier(tc, update_root, (MVMCollectable *)_r); \
        update_addr = _r; \
    }
#else
#define MVM_ASSIGN_REF(tc, update_root, update_addr, referenced) \
    { \
        void *_r = referenced; \
        MVM_gc_write_barrier(tc, update_root, (MVMCollectable *)_r); \
        update_addr = _r; \
    }
#endif
````

Once again, the debug version does some extra checks. Those reading carefully will have spotted `MVM_ASSERT_NOT_FROMSPACE `in there. So, if we used this macro to assign to the `->outer` that had the outdated pointer, why did it not trip this check?

It turns out, because it only cared about checking if it was in fromspace of the current thread, not all threads. (This is in turn because the GC debug bits only really get any love when I’m hunting a GC bug, and once I find it then they go back in the drawer until next time around.) So, I [enriched that check](https://github.com/MoarVM/MoarVM/commit/3736562a902c9f856bfa960b1373a0e7ef2e81bf) and…the bug hunt came to a swift end.

### Right back to the naughty deed

The next time I caught it under the debugger was not at the point that the bad `->outer` assignment took place. It was even earlier than that – lo and behold, inside of some of the guts that power `Proc::Async`. Once I got there, the problem was clear and [fixed in a minute](https://github.com/MoarVM/MoarVM/commit/4be6b384b802e2c48df077e84f3c1f372dd632dc). The problem was that the `callback` pointer was not rooted while an allocation took place. The function `MVM_repr_alloc_init` can trigger GC, which can move the object pointed to by `callback`. Without an `MVMROOT` to tell the GC where the `callback` pointer is so it can be updated, it’s left pointing to where the `callback` used to be.

So, bug fixed, but you may still be wondering how exactly this bug could have led to a bad `->outer` pointer in a callframe some way down the line. Well, `callback` is a code object, and code objects point to an outer scope (it’s actually code objects that we clone to make closures). Since we held on to an outdated code object pointer, it in turn would point to an outdated pointer to the `outer` frame it closed over. When we invoked `callback`, the `outer` from the code object would be copied to be the `outer` of the call frame. Bingo.

### Less is Moar

The hard part about GCs is not just building the collector itself. It’s that collectors bring invariants that are to be upheld, and a momentary lapse in concentration by somebody writing or reviewing a patch can let a bug like this slip through. At least 95% of the time when I handwavily say, “it was a GC bug”, what I really mean was “it was a bug that arose because some code didn’t play by the rules the GC requires”. A comparatively tiny fraction of the time, there’s actually something wrong in the code living under `src/gc/`.

People sometimes ask me about my plans for the future of MoarVM. I often tell them that I plan for there to be less of it. In this case, the code with the bug is something that I hope we’ll eventually write in, say, NQP, where we don’t have to worry about low-level details like getting write barriers correct. It’s just binding code to libuv, a C library, and we should be able to do that using the MoarVM native calling support (which is likely mature enough by now). Alas, that also has its own set of costs, and I suspect we’d need to improve native calling performance to not come out at a measurable loss, and that means teaching the JIT to emit native calls, but we only JIT on x64 so far. “You’re in a maze of twisty VM design trade-offs, and their funny smells are all alike.”
