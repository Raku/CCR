# Massively reducing MoarVM Fixed Size Allocator contention
    
*Originally published on [2017-04-22](https://6guts.wordpress.com/2017/04/22/massively-reducing-moarvm-fixed-size-allocator-contention/) by Jonathan Worthington.*

The latest MoarVM release, 2017.04, contains a significant improvement for multi-threaded applications, especially those that are CPU-bound. I mentioned the improvement briefly on Twitter, because it’s hard to be anything other than brief on Twitter. This post contains a decidedly less brief, though hopefully somewhat interesting, description of what I did. Oh, and also a bonus footnote in which I attempt to prove the safety (or lack of safety) of a couple of lock free algorithms, because that’s fun, right?

### The Fixed Size Allocator

The most obvious way to allocate memory in a C program is through functions like `malloc` and `calloc`. Indeed, we do this plenty in MoarVM. The `malloc` and `calloc` implementations in C libraries have certainly been tuned a bunch, but at the same time they have to have good behavior for a very wide range of programs. They also need to keep track of the sizes of allocations, since a call to `free` does not pass the size of the memory being released. And they need to try to avoid fragmentation, which can lead to out-of-memory errors occurring because the heap ends up with lots of small gaps, but none big enough to allocate a larger object.

When we know a few more properties of the memory usage of a program, and we have information around to know the size of the memory block we are freeing, it’s possible to do a little better. MoarVM does this in multiple ways.

One of them is by using a bump-the-pointer allocator for memory that is managed by the garbage collector. These have a header that points to a type table that knows the size of the object that was allocated, meaning the size information is readily available. And the GC can move objects around in memory, since it can find all of the references to an object and update them, meaning there is a way out of the fragmentation trap too.

The call stack is another example. In the absence of closures, it is possible to allocate a block of memory and use it like a stack. When a program makes a call, the current location in the memory block is taken as the address for the call frame memory, and the location is bumped by the frame size. This could be seen as a “push”, in stack terms. Because call frames are left in the opposite order to which they are entered, freeing them is just subtraction. This could be seen as a “pop”. Since holes are impossible, fragmentation cannot occur.

A third case is covered by the fixed size allocator. This is the most difficult of the three. It tries to do a better job than `malloc `and friends in the case that, at the point when memory is freed, we readily know the size of the memory. This allows it to create regions of memory that consist of N blocks of a fixed size, and allocate the memory out of those regions (which it calls “pages”). When a memory request comes in, the allocator first checks if it’s within the size range that the fixed size allocator is willing to handle. If it isn’t, it’s passed along to `malloc`. Otherwise, the size is rounded up to the nearest “bin size” (which are 8 bytes, 16 bytes, 24 bytes, and so forth). A given bin consists of:

- 1 or more pages, each with space for a certain number of allocations of the bin size
- A free list of available memory locations of that size, which is maintained as a linked list (that is, each location contains a pointer to the next free location, with a NULL marking the end)

If the free list contains any entries, then one of them will be taken. If not, then the pages will be considered. If the current page is not full, then the allocation will be made from it. Otherwise, another page will be allocated. When memory is freed, it is always added to the free list of the appropriate bin. Therefore, a longer-running program, in steady state, will typically end up getting all of its allocations from the free list.

### Enter threads

Building a fixed size allocator for a single-threaded environment isn’t all that difficult. But what happens when it needs to cope with being used in a multi-threaded program? Well…it’s complicated. Clearly, it is not possible to have a single global fixed size allocator and have all of the threads just use it without any kind of concurrency control. Taking an item off the freelist is a multi-step process, and allocating from a page – or allocating a new page – is even more steps. Without concurrency control, there will be data races all over, and we’ll be handed a SIGSEGV in record time.

It’s worth stopping to consider what would happen if we were to give every thread its own fixed size allocator. This turns out to get messy fast, as memory allocated on one thread may be freed by another. A seemingly simple scheme is to say that the freed memory is simply appended to the freelist of the freeing thread’s fixed size allocator. Unfortunately, this has two bad properties.

1. When the thread ends, we can’t just throw aways the pages – because bits of them may still be in use by other threads, or referenced in the free lists of other threads. So they’d need to be somehow “re-homed”, which is going to need some kind of coordination. Further measures may be needed to mitigate memory fragmentation in programs that spawn and join many threads during their lifetimes.
1. Imagine a producer/consumer setup, where one thread does allocations and passes the allocated memory to another thread, which processes the data in the memory and frees it. The producing thread will build up a lot of pages to allocate out of. The consuming thread will build up an ever longer free list. Memory runs out. D’oh.

So, MoarVM went with a single global fixed size allocator. Of course, this has the drawback of needing concurrency control.

### Concurrency control

The easiest possible form of concurrency control is to have threads acquire a mutex on every allocate and free operation. This has the benefit of being very straightforward to understand and reason about. It has the disadvantage of being extremely costly. Mutex acquisition can be relatively cheap, but it gets expensive when there is high contention – that is, lots of threads trying to obtain the lock. And since all CPU-bound threads will typically allocate some working memory, particularly in a VM for a dynamic language that doesn’t yet do escape analysis, that adds up to a *lot* of contention.

So, MoarVM did something more sophisticated.

First, the easy part. It’s possible to append to a free list with a CPU-provided atomic operation, provided taking from the freelist is also using one. So, no mutex acquisition is required for freeing memory. However, an atomic operation still requires a kind of locking down at the CPU level. It’s cheaper than a mutex acquire/release for sure, but there will still be contention between CPU cores for the cache line holding the head of the free list.

What about allocation? It turns out that we can *not* just take from a free list using an atomic operation without hitting the [ABA problem](https://en.wikipedia.org/wiki/ABA_problem) (gory details in footnote). Therefore, some kind of locking is needed to ensure an ordering on the operations. In most cases, the atomic operation will work on the first attempt (it’s competing with frees, which happen without any kind of locking, meaning a retry will sometimes be needed). In cases where something will complete very rapidly, a [spinlock](https://en.wikipedia.org/wiki/Spinlock) may be used in place of a full-on mutex. So, the MoarVM fixed size allocator allocation scheme boiled down to:

1. Acquire the spin lock.
1. Try to take from the free list in a loop, until either we succeed or the free list is seen to be empty.
1. Release the spin lock.
1. If we failed to obtain memory from the free list, take the slow path to get memory from a page, allocating another page if needed. This slow path does acquire a real mutex.

### Contention

First up, I’ll note that the strategy outlined above *does* beat the “just take a mutex for every allocate/free” approach – at least, in all of the benchmarks I’ve considered. Frees end up being lock free, and most of the allocations just do a spin lock and an atomic operation.

At the same time, **contention means contention**, and no lock free data structure or spinlock changes that. If multiple threads are constantly scrambling to work on the same memory location – such as the head of a free list – it’s going to get expensive. How expensive? On an Intel Core i7, obtaining a cache line that is held by another core exclusively – which it typically will be under contention – costs somewhere around 70 CPU cycles. It gets worse in a multi-CPU setup, where it could easily be hundreds of CPU cycles. Note this is just for one operation; the spinlock is a further atomic operation and, of course, it uses some cycles as it spins.

But how much could this end up costing in a real world Raku application? I recently had chance to find out, and the numbers were *ugly*. Measurements obtained by `perf` showed that a stunning **40%** of the application’s runtime was spent inside of the fixed size allocator. (Side note: `perf` is a sampling profiler, which – in my handwavey understanding – snapshots the callstack at regular intervals to figure out where time is being spent. My experience has been that sampling profilers tend to be better at showing up surprising costs like this than instrumenting profilers are, even if they are in some senses less precise.)

### Making things better

Clearly, there was significant room for improvement. And, happily, things are now muchly improved and my real-world program did get something close to a 40% performance boost.

To make things better, I introduced per-thread freelists, while leaving pages global and retaining global free lists also.

Memory is allocated in the first place from global pages, as before. However, when it is freed, it is instead placed on a per-thread free list (with one free list per thread per size bin). When a thread needs memory, it first checks its thread-local free list to see if there is anything there. It will only then look at the global free list, or the global pages, if the thread-local free list cannot satisfy the memory request. The upshot of this is that the vast majority of allocations and frees performed by the fixed size allocator no longer have any contention.

However, as I mentioned earlier, one needs to be very careful when introducing things like thread-local freelists to not create bad behavior when a thread terminates or in producer/consumer scenarios. Therefore:

- When a thread termiantes, it will donate all the locations on its free list back to the global free list. Since pages are entirely global, there isn’t a fragmentation issue.
- When a thread’s local free list for a particular size hits a limit, it will instead start to free to the global free list, which prevents unbounded free list growth in producer/consumer style programs.

So, I believe this improvement is both good for performance without being badly behaved for any cases that previously would have worked out fine.

### Can we do better?

Always! While the major contention bottleneck is gone, there are further opportunities for improvement that are worth exploring in the future.

- It would probably make sense to donate a bunch of free list entries to the global free list, rather than donating them individually. This would mean the contention of doing so only happened every N entries, not every entry, for the producer/consumer case. This is a fairly easy fix. (Homework, anyone? :-))
- The current scheme is vulnerable to false sharing. The strategy of packing allocations of the same size together in pages is, in a single-threaded program, typically good for the CPU cache. But in a multi-threaded program, we can end up placing allocations that individual threads use next to each other. This means they may end up on the same cache line (the 32-byte or 64-byte memory regions that CPU caches hold). This is a harder nut to crack.

### In summary…

If you have CPU-bound multi-threaded Raku programs, MoarVM 2017.04 could offer a big performance improvement. For my case, it was close to 40%. And the design lesson from this: on modern hardware, contention is really costly, and using a lock free data structure or picking the “best kind of lock” will not overcome that.
<hr />

**Footnote on the ABA vulnerability:** It’s decidedly interesting – at least to me – that prepending to a free list can be safely done with a single atomic operation, but taking from it cannot be. Here I’ll attempt to provide a proof for these claims.

We’ll consider a single free list whose head lives at memory location `F`, and two threads, `T1` and `T2`. We assume the existence of an atomic operation, `TRY-CAS(location, old, new)`, which will – in a single CPU instruction that may not be interrupted – compare the value in memory pointed to by `location` with `old` and, if they match, replace it with `new`. (CAS is short for Compare And Swap.) The `TRY-CAS` function evaluates to `true` if the replacement took place, and `false` if not. The threads may be preempted (that is, taken off the CPU) at any point in time.

To show that allocation is vulnerable to the ABA problem, we just need to find an execution where it happens. First of all, we’ll define the operation `ALLOCATE` as:

````
1: do
2:     allocated = *F
3:     if allocated != NULL
4:         next = allocated.next    
5: while allocated != NULL && !TRY-CAS(F, allocated, next)
6: return allocated
````

And `FREE(C)` as:

````
1: do
2:     current = *F
3:     C.next = current;
4: while !TRY-CAS(F, current, C)
````

Let’s consider a case where we have 3 memory cells, `C1`, `C2`, and `C3`. The free list head `F` points to `C1`, which in turn points to `C2`, which in turn points to `C3`.

Thread `T1` enters `ALLOCATE`, but is preempted immediately after the execution of line 4. At this point, `allocated` contains `C1` and `next` contains `C2`.

Next, `T2` calls `ALLOCATE`, and succeeds in making an allocation. `F` now points to `C2`. It again calls `ALLOCATE`, meaning that `F` now points to `C3`. It then calls `FREE(C1)`. At this point, `F` points to `C1` again, and `C1` points to `C3`. Notice that at this point, cell `C2` is considered to be allocated and in use.

Consider what happens if `T1` is resumed. It performs `TRY-CAS(F, C1, C2)`. This operation will succeed, because `F` does indeed currently point to `C1`. This means that `F` now come to point to `C2`. However, we earlier stated that `C2` is allocated and in use, and therefore should not be in the free list. Therefore we have demonstrated the code to be buggy, and shown how the bug arises as a result of the ABA problem.

What of the claim that the `FREE(C)` is not vulnerable to the ABA problem? To be vulnerable to the ABA problem, another thread must be able to change the state of something that the correctness of the operation depends upon, but that is *not* tested by the `TRY-CAS` operation. Looking at `FREE(C)` again:

````
1: do
2:     current = *F
3:     C.next = current;
4: while !TRY-CAS(F, current, C)
````

We need to consider `C` and `current`. We can very reasonably make the assumption that the calling program is well-behaved, and will never use the cell `C` again after passing it to `FREE(C)` (unless it obtains it again in the future through another call to `ALLOCATE`, which cannot happen until `FREE` has inserted it into the free list). Therefore, `C` cannot be changed in any way other than the code in `FREE` changes it. The `FREE` operation holds the sole reference to `C` at this point.

Life is much more complicated for `current`. It is possible for a preemption at line 3 of `FREE`, followed by another thread allocating the cell pointed to by `current` and then freeing it again, which *is* certainly a case of an ABA state change. However, unlike the situation we saw in `ALLOCATE`, the `FREE` operation does not depend on the content of `current`. We can see this by noticing how it never looks inside of it, and instead just holds a reference to it. An operation cannot depend upon a value it never accesses. Therefore, `FREE` is not vulnerable to the ABA problem.
