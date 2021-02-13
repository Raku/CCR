# Framing the problem
    
*Originally published on [2016-04-21](https://6guts.wordpress.com/2016/04/21/framing-the-problem/) by Jonathan Worthington.*

In this post I’ll be talking a lot about call frames, also known as invocation records. Just to be clear about what they are, consider a sub:

```` raku
sub mean(@values) {
    @values.sum / @values
}
````

Whenever we call `mean`, we create a call frame. This holds the storage for the incoming `@values` parameter. It also holds some temporary storage we use in executing the sub, holding, for example, the `sum` method object we get back when looking up the method, and the result of calling `@values.sum`, which we then pass to `infix:</>`. Call frames also record outer and caller references (so we can resolve lexical and dynamic variables), the place to store the return value and go to on return, and other bits. It’s important to note that call frames are not 1:1 with subs/methods/blocks. Perhaps the best way to understand why is to consider a recursive sub:

```` raku
sub fac($n) {
    $n <= 1
        ?? 1
        !! $n * fac($n - 1)
}
````

There’s one `fac` sub but we need a call frame for each invocation of (that is, call to) `fac`, since the `$n` parameter will vary in each call. (Threads are another example where you’re “in” a sub multiple times at the same time.)

All complex software systems evolve from simple systems. MoarVM is no exception. Back when MoarVM started out, I knew I wanted to have invocation be cheap, and call frames be fairly lightweight. I also didn’t want them to be GC-allocated. I figured that code sat in a loop, only using native types and only calling things involving native types, should not create garbage that needed collecting. All good goals.

Fast forward a few years, and where are we? Let’s start out with the easy one to assess: frames aren’t GC-allocated. So that’s good, right? Well, sure, in that I got the natives property that I was after. However, since things like closures and continuations exist, not to mention that you can get a first-class reference to a call frame and traverse the outer/caller chain, the lifetime of frames is interesting. They most certainly don’t always just go away at the point of `return`. Therefore, they need to have their memory managed in some way. I went with reference counts, figuring that since we’d only need to twiddle them fairly occasionally, it’d be fairly OK. Trouble is, thanks to MoarVM supporting concurrent threads of execution, those counts need to be incremented and decremented using atomic operations. Those are CPU native, but they’re still a bit costly (more so on some CPUs that others).

There’s another, more hidden, cost, however – one I didn’t really see coming. MoarVM has a generational garbage collector, as discussed in my [previous post](https://6guts.wordpress.com/2016/04/15/heap-heap-hooray/). But frames are not garbage collectable objects. They’re managed by reference counts. So what happens when a reference counted frame is referenced by a second generation object? Well, there’s no risk of the frames going away too early; the reference count won’t be decremented until the gen2 object itself is collected. The problem is about the objects the frame references. Frames, not being garbage collectable, don’t have write barriers applied on binds into them. This means that they can come at any time to point to nursery objects. We solved this by keeping all objects referencing frames in the inter-generational root set. This is perfectly safe. Unfortunately, it also greatly increases the cost of garbage collection for programs that build up large numbers of closures in memory and keep them around. Of course, since write barriers are cheap but not free, we get a performance win on all programs by not having to apply them to writes to working registers or lexical.

So, how about invocation cost? Is invocation cheap? Well, first of all lets turn off inlining:

````
SET MVM_SPESH_INLINE_DISABLE=1
````

And measure 10 million invocations passing/receiving one argument using Perl, NQP, and Rakudo. Perl does them in 2.85s. NQP comes out a little ahead, at 2.45s. Rakudo strolls through them in an altogether too leisurely 6.14s. (Turn inlining back on, and Rakudo manages it in 3.39s.) So, if NQP is already ahead, is MoarVM really so bad? Well, it could certainly be better. On an idealized 3GHz GPU, each invocation is costing around 735 CPU cycles. That’s pricey. The other issue here is that just matching Perl on invocation speed isn’t really enough, because tons of things that aren’t invocations in Perl actually are in Raku (like, every array and hash index). In a “Raku is implemented in Raku” world, we need to squeeze a good bit more out of invocation performance.

And finally, what about size? An `MVMFrame` comes at a cost of 296 bytes. It points to a chunk of working space together with a lexical environment (both arrays). Every single closure we take also pays that fixed 296 byte cost (and, of course, the cost of the lexical environment storage, since that’s what we actually take closures for). Again, not staggeringly huge, but it adds up very quickly.

These are all areas that need improvement. In fact, they make up two of the entries in the performance section of the[proposal](http://news.perlfoundation.org/2016/02/grant-proposal-perl-6-performa.html) for the grant I’m doing this work under. So, I decided it was time to start thinking about how I’ll address them.

## Some measurements

I was curious how many frames end up referenced by garbage collectable objects against how many never end up in this situation. So, I quickly patched MoarVM to keep track of if a frame ever came to be referenced by a GC-able object:

````
diff --git a/src/core/frame.c b/src/core/frame.c
index ca1a4d2..f392aca 100644
--- a/src/core/frame.c
+++ b/src/core/frame.c
@@ -114,7 +114,10 @@ MVMFrame * MVM_frame_dec_ref(MVMThreadContext *tc, MVMFrame *frame) {
      * to zero, so we look for 1 here. */
     while (MVM_decr(&frame->ref_count) == 1) {
         MVMFrame *outer_to_decr = frame->outer;
-
+if (frame->refd_by_object)
+    tc->instance->*refd_frames*++;
+else
+    tc->instance->*non_refd_frames*++;
         /* If there's a caller pointer, decrement that. */
         if (frame->caller)
             frame->caller = MVM_frame_dec_ref(tc, frame->caller);
diff --git a/src/core/instance.h b/src/core/instance.h
index b14f11d..4f61000 100644
--- a/src/core/instance.h
+++ b/src/core/instance.h
@@ -365,6 +365,9 @@ struct MVMInstance {

     /* Cached backend config hash. */
     MVMObject *cached_backend_config;
+
+MVMuint64 refd_frames;
+MVMuint64 non_refd_frames;
 };

 /* Returns a true value if we have created user threads (and so are running adiff --git a/src/main.c b/src/main.c
index 5458912..1df4fe3 100644
--- a/src/main.c
+++ b/src/main.c
@@ -189,7 +189,9 @@ int main(int argc, char *argv[])

     if (dump) MVM_vm_dump_file(instance, input_file);
     else MVM_vm_run_file(instance, input_file);
-
+printf("Ref'd frames: %d\nNon-ref'd frames: %d\n",
+    instance->refd_frames,
+    instance->non_refd_frames);
     if (full_cleanup) {
         MVM_vm_destroy_instance(instance);
         return EXIT_SUCCESS;
````

And measured a few things (the names from the latter ones are benchmark names from rakuench):

````
Measured                    Ref'd       Non-ref'd       % Ref'd
========                    =====       =========       =======
NQP startup                 0           5259            0.0%
NQP regex tests             28065       1682655         1.6%
Compile Raku actions      115092      6100770         1.7%
Compile Raku grammar      130716      5451120         2.3%
Compile CORE.setting        2065214     55771097        3.8%
Raku startup              35          12822           0.3%
Compiling Test.pm6          39639       860474          4.4%
Compiling NativeCall.pm6    145426      1887682         7.2%
while_array_set             993701      6024920         14.1%
while_hash_set              1804        2024016         0.1%
for_assign                  1654        1020831         0.2%
for_concat_2                1743        2023589         0.1%
split_string_regex          8992750     19089026        32.0%
create_and_iterate_hash_kv  14990870    40027814        27.2%
parse_json                  10660068    42364909        20.1%
rc-forest-fire              3740096     16202368        18.8%
rc-mandelbrot               89989       5523439         1.6%
rc-man-or-boy-test          791961      7091381         10%
````

What can we infer from this? First of all, most NQP programs have at most just a few percent of their frames referenced by GC-able objects. With the Raku benchmarks, it’s all over the map, with split_string_regex being the “worst” case. NQP’s optimizer is much better doing lexical to local lowering, and flattening away scopes that we don’t really need. In Rakudo, we’re pretty weak at that. Clearly, some more work on this area could benefit Rakudo (and yes, it’s also on the list of things to do under my grant).

Secondly, since – even in the worst cases – the majority of frames never get themselves tied up with any “interesting” situations that causes them to become GC-referenced, a strategy that handles them differently – and hopefully far more efficiently – would give us a win.

### What GC-able things reference frames?

It was fairly easy to grep through the MoarVM source and make a list. I did so to help me think through the cases:

- A frame being closed over (closures)
- A frame being captured in a continuation
- A frame being referenced by an exception
- A local/lexical being referenced by a native reference
- A frame becoming the default outer thanks to “auto-close” (rare)
- A frame getting wrapped in a context object, to use it as a first-class object (also, hopefully, rare in any hot-path code)

It’s also interesting to note that a frame only ever “escapes” such that it can be touched by another thread if it becomes referenced by a GC-able object.

### What makes frames take up space?

Next, I decided to to through the `MVMFrame` data structure and see where the space is going, and what options might exist for saving that space. What follows is an analysis of all the fields in an `MVMFrame`.

````
/* The thread that is executing, or executed, this frame. */
MVMThreadContext *tc;
````

Interestingly, this one gets cleared after a certain point in the frame’s life, except if it’s captured in a continuation. Exception handling uses it to know if the frame is still on the call stack, which is interesting in various cases. GC marking uses it to know if it should mark `->work` (see below).

Interestingly, nothing seems to care overly much at the moment that it points to a particular thread context; they all want it for a flag. So, it’s certainly a candidate for removal. It’s also interesting to note that in every case where a frame is not referenced by an object, it is alive solely by being in a thread’s “call stack” – that is, the call chain from following the `->caller` pointer from the currently executing frame of a thread. So, the flag will only matter for frames that are GC-referenced.

````
/* The environment for this frame, which lives beyond its execution.
* Has space for, for instance, lexicals. */
MVMRegister *env;
````

Relevant for frames in whatever state.

````
/* The temporary work space for this frame. After a call is over, this
* can be freed up. Must be NULLed out when this happens. */
MVMRegister *work;
````

Relevant for frames that are still executing, or that are captured by a continuation. Cross-cuts whether they are GC-referenced.

````
/* The args buffer. Actually a pointer into an area inside of *work, to
* decrease number of allocations. */
MVMRegister *args;
````

Possibly could go away through a level of indirection, but it’s performance sensitive. Used together with…

````
/* Callsite that indicates how the current args buffer is being used, if
* it is. */
MVMCallsite *cur_args_callsite;
````

…this one.

````
/* The outer frame, thus forming the static chain. */
MVMFrame *outer;
````

Pretty much everything has an outer.

````
/* The caller frame, thus forming the dynamic chain. */
MVMFrame *caller;
````

Pretty much everything has a caller too.

````
/* The static frame information. Holds all we statically know about
* this kind of frame, including information needed to GC-trace it. */
MVMStaticFrame *static_info;
````

As you might guess, this is pretty important and useful. However, it’s also possible to obtain it – at the cost of a level of indirection – through the `->code_ref` below. Would need to measure carefully, since it’d increase the cost of things like lexical lookups from outer frames (and, once we get better at optimizing, that will be “most of them”).

````
/* The code ref object for this frame. */
MVMObject *code_ref;
````

The particular closure we were invoked as. Not something we can obviously lose, and needed for the lifetime of the frame in general.

````
/* Parameters received by this frame. */
MVMArgProcContext params;
````

Argument processing context. Every frame uses it to process its arguments. It’s only useful while `->work` is active, however, and so could be allocated as a part of that instead, which would reduce the cost of closures.

````
/* Reference count for the frame. */
AO_t ref_count;
````

Can go away provided we stop reference counting frames.

````
/* Is the frame referenced by a garbage-collectable object? */
MVMint32 refd_by_object;
````

Could also go away provided we stop reference counting frames and have some scheme for optimizing the common, non-referenced case.

````
/* Address of the next op to execute if we return to this frame. */
MVMuint8 *return_address;

/* The register we should store the return value in, if any. */
MVMRegister *return_value;

/* The type of return value that is expected. */
MVMReturnType return_type;

/* The 'entry label' is a sort of indirect return address
* for the JIT */
void * jit_entry_label;
````

These four are only used when the frame is currently on the call stack, or may be re-instated onto the call stack by a continuation being invoked. Could also live with `->work`, thus making closures cheaper.

````
/* If we want to invoke a special handler upon a return to this
* frame, this function pointer is set. */
MVMSpecialReturn special_return;

/* If we want to invoke a special handler upon unwinding past a
* frame, this function pointer is set. */
MVMSpecialReturn special_unwind;

/* Data slot for the special return handler function. */
void *special_return_data;

/* Flag for if special_return_data need to be GC marked. */
MVMSpecialReturnDataMark mark_special_return_data;
````

Used relatively occasionally (and the more common uses are candidates for spesh, the dynamic optimizer, to optimize out anyway). A candidate for hanging off an “extra stuff” pointer in a frame. Also, only used when a frame is on the call stack, with the usual continuation caveat.

````
/* Linked list of any continuation tags we have. */
MVMContinuationTag *continuation_tags;
````

Used if this frame has been tagged as a possible continuation “base” frame. Only relevant if that actually happens (which is quite rare in the scheme of things), and can only happen when a frame is on the call stack. A candidate for similar treatment to the special return stuff.

````
/* Linked MVMContext object, so we can track the
 * serialization context and such. */
/* note: used atomically */
MVMObject *context_object;
````

This is used when a context goes first-class. Thus, it implies the frame is referenced by at least one GC-able object (in fact, this points to said object). That’s fairly rare. It can happen independently of whether the frame is currently executing (so, unrelated to `->work` lifetime).

````
/* Effective bytecode for the frame (either the original bytecode or a
 * specialization of it). */
MVMuint8 *effective_bytecode;

/* Effective set of frame handlers (to go with the effective bytecode). */
MVMFrameHandler *effective_handlers;

/* Effective set of spesh slots, if any. */
MVMCollectable **effective_spesh_slots;

/* The spesh candidate information, if we're in one. */
MVMSpeshCandidate *spesh_cand;
````

These are all related to running optimized/specialized code. Only interesting for frames currently on the call stack or captured in a continuation (so, `->work` lifetime once again).

````
/* Effective set of spesh logging slots, if any. */
MVMCollectable **spesh_log_slots;

/* If we're in a logging spesh run, the index to log at in this
* invocation. -1 if we're not in a logging spesh run, junk if no
* spesh_cand is set in this frame at all. */
MVMint8 spesh_log_idx;

/* On Stack Replacement iteration counter; incremented in loops, and will
* trigger if the limit is hit. */
MVMuint8 osr_counter;
````

These 3 play part a part in dynamic optimization too, though more in the stage where we’re gathering information. Again, they have `->work` lifetime. The top may well go away in future optimizer changes, so not worth worrying over too much now.

````
/* GC run sequence number that we last saw this frame during. */
AO_t gc_seq_number;
````

This one is certainly a candidate for going away, post-refactoring. It serves as the equivalent of a “mark bit” when doing GC.

````
/* Address of the last op executed that threw an exception; used just
* for error reporting. */
MVMuint8 *throw_address;
````

May be something we can move inside of exception objects, and have them pay for it, not every frame. Worth looking in to.

````
/* Cache for dynlex lookup; if the name is non-null, the cache is valid
* and the register can be accessed directly to find the contextual. */
MVMString   *dynlex_cache_name;
MVMRegister *dynlex_cache_reg;
MVMuint16    dynlex_cache_type;
````

These also have `->work` lifetime. Give a huge speed-up on dynlex access, so (aside from re-designing that) they can stay.

````
/* The allocated work/env sizes. */
MVMuint16 allocd_work;
MVMuint16 allocd_env;
````

These exist primarily because we allocate `work` and `env` using the fixed size allocator, and so we need the sizes to free the memory.

````
/* Flags that the caller chain should be kept in place after return or
* unwind; used to make sure we can get a backtrace after an exception. */
MVMuint8 keep_caller;

/* Flags that the frame has been captured in a continuation, and as
* such we should keep everything in place for multiple invocations. */
MVMuint8 in_continuation;

/* Assorted frame flags. */
MVMuint8 flags;
````

It appears the top two could be nicely folded into `flags`. Also, the flags may only be relevant for currently executing frames, or those captured in a continuation, so this lot is a candidate to move to something with `->work` lifetime.

### Observations

Here are some things that stand out to me, and that point the way to an alternate design.

1. An `MVMFrame` presently carries a bunch of things in it that aren’t relevant unless the frame is either currently on a thread’s call stack or captured in a continuation.
1. This is an orthogonal axis to whether the frame is referenced by something that is garbage-collectable.
1. It’s further orthogonal to one of a number of relatively rare things that can happen and need storage in the frame.
1. Frames that are never referenced by a garbage collectable object will only ever have a reference count of 1, because they will only be alive by virtue of being either the currently executing frame of a thread, or in its caller chain.
1. Frames only become referenced by something garbage collectable in cases where we’d end up with some other garbage-collectable allocation anyway. For example, in the closure case, we allocate the code-ref that points to the referenced outer frame.
1. Let’s assume we were to allocate all frames using the GC, and consider the analysis that would let us known when we are able to avoid those allocations. The analysis needed would be [escape analysis](https://en.wikipedia.org/wiki/Escape_analysis).

### A new approach: the big picture

Taking these into account, I arrived at a way forward that should, I hope, address most of the issues at hand.

Every thread will have a chunk of memory that we’ll refer to as its “call stack”. Every new frame created during normal program execution will be allocated by making space for it, including its `->work` and `->env`, on this stack. This will need:

- No reference count, because we know it’s 1
- No `gc_seq_number`, because we can use the stack topology to make sure we only mark each frame once

Should this frame ever become referenced by a garbage collectable object, then we will GC-allocate a frame on the garbage-collected heap – as a totally normal garbage-collectable object. The frame state will be copied into this. The work space and environment will also be allocated from the fixed-size allocator, and the data migrated there.

Since this frame is now garbage-collectable, we have to check its `->caller` to see if it’s on the thread-local stack, or already been promoted to the heap. If the former, we repeat the above process for it too. This is in order to uphold the key invariant in this design: the thread-local stack may point to things in the garbage-collectable heap, but never vice-versa.

This means the reference counting and its manipulation goes away entirely, and that frames that are heap-promoted become subject to the usual generational rules. Frames that would never be heap-referenced never end up on the heap, don’t add to GC pressure, and can be cleaned up immediately and cheaply.

There are some details to care about, of course. Since generational collection involves write barriers, then binds into frames on the garbage-collectable heap will also be subject to write barriers. Is that OK? There are two cases to consider.

1. Binding of lexicals. Since most lexicals in Raku point to a `Scalar`, `Array`, or `Hash` in `my` declarations, or point directly to a read-only object if parameters, this is relatively rare (of course, write barriers apply to the `Scalar` itself). In NQP, loads of lexicals are lowered to locals already, and we’ll do some more of that in Rakudo too, making it rarer still. Long story short, we can afford write barriers on lexical binds.
1. Binding of stuff in `->work`, which basically means every write into the register set of the interpreter. This, we cannot afford to barrier. However, there are only two cases where a frame is promoted to the heap *and* has `->work`. One case is when it’s still executing, and so in the call chain of a thread. In this case, we can take care to always walk the objects in `->work` by simply following the call chain . The second case is when a continuation is taken. But here, there are no binds to registers until the continuation is invoked again – at which point things are back in a thread’s call chain.

### Refactoring towards it

The thing that makes this a somewhat scary piece of work is that, in making call frames potentially collectable objects, we break an assumption that has been there since week 1 of MoarVM’s development: that call frames never move. To maximize the chances of discovering problems with this refactor, I decided that step 1 would be to always allocate every single call frame on the heap. Only when that is working would I move on to optimizing away most of those heap allocations by adding the thread-local call stack.

MoarVM currently has 3 kinds of collectable:

- Objects
- Type objects
- STables

So, I [added a fourth](https://github.com/MoarVM/MoarVM/commit/1d922231c9798ca6cc0bbf61f957aedcc7bb0c20): call frames. As a result, `MVMFrame` [gains](https://github.com/MoarVM/MoarVM/commit/2ec94b72c7d03bf24759fefb8af5b4000ceba5e4) an `MVMCollectable` at the start of the data structure – which will be present whether it’s stack or heap allocated. This will start out zeroed when a frame is born on the call stack. This does two nice things: it gives us a way to know if a frame is GC-able or not, and also means the write barrier – without modification – will do the right thing on both stack and heap frames.

There were two more easy things to do. First was to add a [function to allocate a heap frame](https://github.com/MoarVM/MoarVM/commit/773c620e8c3fd591254e4e55f50f92d97bdf6a51). Second was to [factor out frame destruction from reference decrement](https://github.com/MoarVM/MoarVM/commit/ddc119732232f15bec9ae0430e03b190b706dffd), since the latter was going away.

Beyond that, there was nothing for it besides diving in, breaking the world, and then trying to put it back together again. I got a good start towards it – but the conclusion of this first step will have to wait for next week’s installment! See you then.
