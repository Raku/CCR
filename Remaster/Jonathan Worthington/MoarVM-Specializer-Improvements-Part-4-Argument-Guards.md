# MoarVM Specializer Improvements Part 4: Argument Guards
    
*Originally published on [2017-11-09](https://6guts.wordpress.com/2017/11/09/moarvm-specializer-improvements-part-4-argument-guards/) by Jonathan Worthington.*

So far in this series, I have discussed how the MoarVM dynamic optimizer [gathers statistics](https://6guts.wordpress.com/2017/08/06/moarvm-specializer-improvements-part-1-gathering-data/), uses them to [plan what to optimize](https://6guts.wordpress.com/2017/09/17/moarvm-specializer-improvements-part-2-planning/), and then [produces specialized versions of hot parts of a program](https://6guts.wordpress.com/2017/11/05/moarvm-specializer-improvements-part-3-optimizing-code/) to speed up execution. In this final part, I’ll look at how we switch from unoptimized code into optimized code, which centers around argument guards.

### But wait, what about code-gen?

Ah, yes, I knew somebody would ask that. At the end of part 3, we had a data structure representing optimized code, perhaps for a routine, method, or block. While going from bytecode to a CFG in SSA form was a fairly involved process, going back to bytecode is far simpler: we iterate the basic blocks in order, iterate each of the instructions within a basic block, and write out the bytecode for each of instructions. Done!

There are, of course, a few complications to take care of. When we have a forward branch, we don’t yet know the offset within the bytecode of the destination, so a table is needed to fix those up later. Furthermore, a new table of exception handler offsets will be needed, since the locations of the covered instructions and handlers will have moved. Beyond those bits of bookkeeping, however, there’s really not much more to it than a loop spitting out bytecode from instruction nodes.

Unlike bytecode that is fed into the VM from the outside, we don’t spend time doing validation of the specialized bytecode, since we can trust that it is valid – we’re generating it in-process! Additionally, the specialized bytecode may make use of “spesh ops” – a set of extra opcodes that exist purely for spesh to generate. Some of them are non-logging forms of ops that would normally log statistics (no point logging after we’ve done the optimizations), but most are for doing operations that – without the proofs and guards done by spesh – would be at risk of violating memory safety. For example, there’s an op that simply takes an object offset and reads a pointer or integer from a certain number of bytes into it, which spesh can prove is safe to do, but in general would not be.

What I’ve described so far is the portable behavior that we can do on any platform. So it doesn’t matter whether you’re running MoarVM on x86, x64, ARM, or something else, you can take advantage of all the optimizations that spesh can do. On x64, however, we can go a step further, and compile the spesh graph not back into specialized MoarVM bytecode, but instead into machine code. This eliminates the interpreter overhead. In MoarVM, we tend to refer to this stage as “the JIT compiler”, because most people understand JIT compilation as resulting in machine code. In reality, what most other VMs call their JIT compiler spans the same space that both spesh and the MoarVM JIT cover between them. MoarVM’s design means that we can deliver performance wins on all platforms we can run on, and then an *extra* win on x64. For more on the machine code generation process, I can recommend watching [this talk](https://www.youtube.com/watch?v=N5_drt7TEqE) by brrt, who leads work on it.

### Argument guards

By this point, we have some optimized code. It was generated for either a particular callsite (a certain specialization) or a combination of callsite and incoming argument types (an observed type specialization). Next, we need a mechanism that will, upon a call, look at the available specializations and see if any of them match up with the incoming arguments. Provided one is found that matches, we can then call it.

My original approach to this was to simply have a list of specializations, each tagged with a callsite and, for each object argument index, an expected type, whether we wanted a type object or a concrete object, and – for container types like `Scalar` – what type we expected to find on the inside of the container. This was simple to implement, but rather inefficient. Even if all of the type specializations were for the same callsite, it would be compared for each of them. Alternatively, if there were 4 specializations and 3 were on the same callsite, and one was on a second callsite, we’d have to do 3 failed comparisons on it to reach the final one that we were hunting.

That might not sound overly bad, because comparing callsites is just comparing pointers, and so somewhat cheap (although it’s branching, and branches aren’t so friendly for CPUs). Where it gets worse is that parameter type checks worked the same way. Therefore, if there were 4 specializations of the same callsite, all of them against a `Scalar` argument with 4 different types of value inside of it, then the `Scalar` would have to be dereferenced up to 4 times. This isn’t ideal.

My work during the summer saw the introduction of a new, tree-structured, approach. Each node in the tree represents either an operation (load an argument to test, read a value from a `Scalar` container) with a single child node, or a test with two child nodes representing “yes” and “no”. The leaves of the tree either indicate which specialization to use, or “no result”.

The tree structure allows for loads, tests, and dereferences to be lifted out. Therefore, each argument needs to be loaded once, checked against a particular type once, and dereferenced once if it’s a container. So, if there were to be specializations for `(Scalar:D of Int:D, Str:D)` and `(Scalar:D of Int:D, Num:D)`, then the first argument would be loaded one time and tested to see if it is a `Scalar`. If it is, then it will be dereferenced once, and the resulting value tested to see if it’s an `Int`. Both alternatives for the second argument are placed in the tree underneath this chain of tests, meaning that they do not need to be repeated.

Arg guard trees are dumped in the specializer log for debugging purposes. Here is how the output looks for the situation described above:

````
0: CALLSITE 0x7f5aa3f1acc0 | Y: 1, N: 0
1: LOAD ARG 0 | Y: 2
2: STABLE CONC Scalar | Y: 3, N: 0
3: DEREF_RW 0 | Y: 4, N: 0
4: DEREF_VALUE 0 | Y: 5, N: 0
5: STABLE CONC Int | Y: 6, N: 0
6: LOAD ARG 1 | Y: 7
7: STABLE CONC Int | Y: 8, N: 9
8: RESULT 0
9: STABLE CONC Str | Y: 10, N: 0
10: RESULT 1
````

As the output suggests, the argument guard tree is laid out in a single block of memory – an array of nodes. This gives good cache locality on the lookups, and – since argument guard trees are pretty small – means we can use a small integer type for the child node indices rather than requiring a pointer worth of space.

### Immutability wins performance

Additional specializations are generated over time, but the argument guard tree is immutable. When a new specialization is generated, the existing argument guard tree is cloned, and the clone is modified to add the new result. That new tree is then installed in place of the previous one, and the previous one can be freed at the next safe point.

Why do this? Because it means that no locks need to be acquired to use a guard tree. In fact, since spesh runs on a single thread of its own, no locks are needed to update the guard trees either, since the single specializer thread means those updates are naturally serialized.

### Calls between specialized code

In the last part of the series, I mentioned that part of specializing a call is to see if we can map it directly to a specialization. This avoids having to evaluate the argument guard tree of the target of the call, which is a decidedly nice saving. As a result, most uses of the argument guard are on the boundary between unspecialized and specialized code.

But how does the optimizer see if there’s a specialization of the target code that matches the argument types being passed? It does it by evaluating the argument guard tree – but on facts, not real values.

### On Stack Replacement

Switching into specialized code at the point of a call handles many cases, but misses an important one: that where the hot code is entered once, then sits in a loop for a long time. This does happen in various real world programs, but it’s especially common in benchmarks. It’s highly desirable to specialize the hot loop’s code, if possible inlining things into the loop body and compiling the result into machine code.

I discussed detection of hot loops in an earlier part of this series. This time around, let’s take a look at the code for the `osrpoint` op:

````
OP(osrpoint):
    if (MVM_spesh_log_is_logging(tc))
        MVM_spesh_log_osr(tc);
    MVM_spesh_osr_poll_for_result(tc);
    goto NEXT;
````

The first part is about writing a log entry each time around the loop, which is what bumps the loop up in the statistics and causes a specialization to be generated. The call to `MVM_spesh_osr_poll_for_result` is the part that checks if there is a specialization ready, and jumps into it if so.

One way we could do this is to evaluate the argument guard in every call to `MVM_spesh_osr_poll_for_result` to see if there’s an appropriate optimization. That would get very pricey, however. We’d like the interpreter to make decent progress through the work until the optimized version of the code is ready. So what to do?

Every frame gets an ID on entry. By tracking this together with the number of specializations available last time we checked, we can quickly short-circuit running the argument guard when we know it will give the very same result as the last time we evaluated it, because nothing changed.

````
MVMStaticFrameSpesh *spesh = tc->cur_frame->static_info->body.spesh;
MVMint32 num_cands = spesh->body.num_spesh_candidates;
MVMint32 seq_nr = tc->cur_frame->sequence_nr;
if (seq_nr != tc->osr_hunt_frame_nr || num_cands != tc->osr_hunt_num_spesh_candidates) {
    /* Check if there's a candidate available and install it if so. */
    ...

    /* Update state for avoiding checks in the common case. */
    tc->osr_hunt_frame_nr = seq_nr;
    tc->osr_hunt_num_spesh_candidates = num_cands;
}
````

If there is a candidate that matches, then we jump into it. But how? The specializer makes a table mapping the locations of `osrpoint` instructions in the unspecialized code to locations in the specialized code. If we produce machine code, a label is also generated to allow entry into the code at that point. So, mostly all OSR does is jump execution into the specialized code. Sometimes, things are approximately as easy as they sound.

There’s a bonus feature hidden in all of this. Remember deoptimization, where we fall back to the interpreter to handle rarely occurring cases? This means we’ll encounter the `osrpoint` instructions in the unoptimized code again, and so – once the interpreter has done with the unusual case – we can enter back into the specialized, and possibly JIT-compiled code again. Effectively, spesh factors your slow paths out for you. And if you’re writing a module, it can do it differently based on different application’s use cases of the module.

### Future idea: argument guard compilation to machine code

At the moment, the argument guard tree is walked by a little interpreter. However, on platforms where we have the capability, we could compile it into machine code. This would perhaps allow branch predictors to do a bit of a better job, as well as eliminate the overhead the interpreter brings (which, given the ops are very cheap, is much more significant here than in the main MoarVM interpreter).

### That’s all, folks

I hope this series has been interesting, and provided some insight into how the MoarVM specializer works. My primary reason for writing it was to put my recent work on the specializer, [funded by The Perl Foundation](http://news.perlfoundation.org/2017/07/grant-extension-approved-perl-.html), into context, and I hope this has been a good bit more interesting than just describing the changes in isolation.

Of course, there’s no shortage of further opportunities for optimization work, and I will be reporting on more of that here in the future. I continue to be [looking for funding](https://6guts.wordpress.com/2017/05/12/looking-for-perl-6-rakudo-and-moarvm-development-funding/) to help make that happen, beyond what I can do in the time I have aside from my consulting work.
