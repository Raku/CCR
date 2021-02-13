# Faster box/unbox and Int operations
    
*Originally published on [2018-09-28](https://6guts.wordpress.com/2018/09/28/faster-box-unbox-and-int-operations/) by Jonathan Worthington.*

My work on Raku performance continues, thanks to a renewal of my grant from The Perl Foundation. I’m especially focusing on making common basic operations faster, the idea being that if *those* go faster than programs composed out of them also should. This appears to be working out well: I’ve not been directly trying to make the `Text::CSV` benchmark run faster, but that’s resulted from my work.

I’ll be writing a few posts in on various of the changes I’ve done. This one will take a look at some related optimizations around boxing, unboxing, and common mathematical operations on `Int`.

### Boxing and unboxing

Boxing is taking a natively typed value and wrapping it into an object. Unboxing is the opposite: taking an object that wraps a native value and getting the native value out of it.

In Raku, these are extremely common. `Num` and `Str` are boxes around `num` and `str` respectively. Thus, unless dealing with natives explicitly, working with floating point numbers and strings will involve lots of box and unbox operations.

There’s nothing particularly special about `Num` and `Str`. They are normal objects with the `P6opaque` representation, meaning they can be mixed into. The only thing that makes them *slightly* special is that they have attributes marked as being a box target. This indicates the attribute out as being the one to write to or read from in a box or unbox operation.

Thus, a `box` operations is something like:

- Create an instance of the box type
- Find out where in that object to write the value to
- Write the value there

While unbox is:

- Find out where in the object to read a value from
- Read it from there

### Specialization of box and unbox

A `box` is actually two operations: an allocation and a store. We know how to fast-path allocations and JIT them relatively compactly, however that wasn’t being done for `box`. So, step one was to *decompose* this higher-level op into the allocation and the write into the allocated object. The first step could then be optimized in the usual way allocations are.

In the unspecialized path, we first find out where to write the native value to, and then write it. However, when we’re producing a specialized version, we almost always know the type we’re boxing into. Therefore, the object offset to write to can be calculated once, and a very simple instruction to do a write at an offset into the object produced. This JITs extremely well.

There are a couple of other tricks. Binds into a `P6opaque` generally have to check that the object wasn’t mixed in to, however since we just allocated it then we know that can’t be the case and can skip that check. Also, a string is a garbage-collectable object, and when assigning one GC-able object into another one, we need to perform a write barrier for the sake of generational GC. However, since the object was just allocated, we know very well that it is in the nursery, and so the write barrier will never trigger. Thus, we can omit it.

Unboxing is easier to specialize: just calculate the offset, and emit a simpler instruction to load the value from there.

I’ve also started some early work (quite a long way from merge) on escape analysis, which will allow us to eliminate many box object allocations entirely. It’s a great deal easier to implement this if allocations, reads, and writes to an object have a uniform representation. By lowering box and unbox operations into these lower level operations, this eases the path to implementing escape analysis for them.

### What about Int?

Some readers might have wondered why I talked about `Num` and `Str` as examples of boxed types, but not `Int`. It is one too – but there’s a twist. Actually, there’s *two* twists.

The first is that `Int` isn’t actually a wrapper around an `int`, but rather an arbitrary precision integer. When we first implemented `Int`, we had it always use a big integer library. Of course, this is slow, so later on we made it so any number fitting into a 32-bit range would be stored directly, and only allocate a big integer structure if it’s outside of this range.

Thus, boxing to a big integer means range-checking the value to box. If it fits into the 32-bit range, then we can write it directly, and set the flag indicating that it’s a small `Int`. Machine code to perform these steps is now spat out directly by the JIT, and we only fall back to a function call in the case where we need a big integer. Once again, the allocation itself is emitted in a more specialized way too, and the offset to write to is determined once at specialization time.

Unboxing is similar. Provided we’re specializing on the type of the object to unbox, then we calculate the offset at specialization time. Then, the JIT produces code to check if the small `Int` flag is set, and if so just reads and sign extends the value into a 64-bit register. Otherwise, it falls back to the function call to handle the real big integer case.

For boxing, however, there was a second twist: we have a boxed integer cache, so for small integers we don’t have to repeatedly allocate objects boxing them. So boxing an integer is actually:

1. Check if it’s in the range of the box cache
1. If so, return it from the cache
1. Otherwise, do the normal boxing operation

When I first did these changes, I omitted the use of the box cache. It turns out, however, to have quite an impact in some programs: one benchmark I was looking at suffered quite a bit from the missing box cache, since it now had to do a lot more garbage collection runs.

So, I reinstated use of the cache, but this time with the JIT doing the range checks in the produced machine code and reading directly out of the cache in the case of a hit. Thus, in the cache hit case, we now don’t even make a single function call for the box operation.

### Faster Int operations

One might wonder why we picked 32-bit integers as the limit for the small case of a big integer, and not 64-bit integers. There’s two reasons. The most immediate is that we can then use the 32 bits that would be the lower 32 of a 64-bit pointer to the big integer structure as our “this is a small integer” flag. This works reliably as pointers are always aligned to at least a 4-byte boundary, so a real pointer to a big integer structure would never have the lowest bits set. (And yes, on big-endian platforms, we swap the order of the flag and the value to account for that!)

The second reason is that there’s no portable way in C to detect if a calculation overflowed. However, out of the basic math operations, if we have two inputs that fit into a 32-bit integer, and we do them at 64-bit width, we know that the result can never overflow the 64-bit integer. Thus we can then range check the result and decide whether to store it back into the result object as 32-bit, or to store it as a big integer.

Since `Int` is immutable, all operations result in a newly allocated object. This allocation – you’ll spot a pattern by now – is open to being specialized. Once again, finding the boxed value to operate on can also be specialized, by calculating its offset into the input objects and result object. So far, so familiar.

However, there’s a further opportunity for improvement if we are JIT-compiling the operations to machine code: the CPU has flags for if the last operation overflowed, and we can get at them. Thus, for two small `Int` inputs, we can simply:

1. Grab the values
1. Do the calculation at 32-bit width
1. Check the flags, and store it into the result object if no overflow
1. If it overflowed, fall back to doing it wider and storing it as a real big integer

I’ve done this for addition, subtraction, and multiplication. Those looking for a MoarVM specializer/JIT task might like to consider doing it for some of the other operations. :-)

### In summary

Boxing, unboxing, and math on `Int` all came with various indirections for the sake of generality (coping with mixins, subclassing, and things like `IntStr`). However, when we are producing type-specialized code, we can get rid of most of the indirections, resulting in being able to perform them faster. Further, when we JIT-compile the optimized result into machine code, we can take some further opportunities, reducing function calls into C code as well as taking advantage of access to the overflow flags.
