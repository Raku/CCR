# Eliminating unrequired guards
    
*Originally published on [2018-09-29](https://6guts.wordpress.com/2018/09/29/eliminating-unrequired-guards/) by Jonathan Worthington.*

MoarVM’s optimizer can perform speculative optimization. It does this by gathering statistics as the program is interpreted, and then analyzing them to find out what types and callees typically show up at given points in the program. If it spots there is at least a 99% chance of a particular type showing up at a particular program point, then it will optimize the code ahead of that point as if that type would *always* show up.

Of course, statistics aren’t proofs. What about the 1% case? To handle this, a **guard** instruction is inserted. This cheaply checks if the type is the expected one, and if it isn’t, falls back to the interpreter. This process is known as deoptimization.

### Just how cheap are guards?

I just stated that a guard cheaply checks if the type is the expected one, but just how cheap is it really? There’s both direct and indirect costs.

The direct cost is that of the check. Here’s a (slightly simplified) version of the JIT compiler code that produces the machine code for a type guard.

````
/* Load object that we should guard */
| mov TMP1, WORK[obj];
/* Get type table we expect and compare it with the object's one */
MVMint16 spesh_idx = guard->ins->operands[2].lit_i16;
| get_spesh_slot TMP2, spesh_idx;
| cmp TMP2, OBJECT:TMP1->st;
| jne >1;
/* We're good, no need to deopt */
| jmp >2;
|1:
/* Call deoptimization handler */
| mov ARG1, TC;
| mov ARG2, guard->deopt_offset;
| mov ARG3, guard->deopt_target;
| callp &MVM_spesh_deopt_one_direct;
/* Jump out to the interpreter */
| jmp ->exit;
|2:
````

Where `get_spesh_slot` is a macro like this:

````
|.macro get_spesh_slot, reg, idx;
| mov reg, TC->cur_frame;
| mov reg, FRAME:reg->effective_spesh_slots;
| mov reg, OBJECTPTR:reg[idx];
|.endmacro
````

So, in the case that the guard matches, it’s 7 machine instructions (note: it’s actually a couple more because of something I omitted for simplicity). Thus there’s the cost of the time to execute them, plus the space they take in memory and, especially, the instruction cache. Further, one is a conditional jump. We’d expect it to be false most of the time, and so the CPU’s branch predictor should get a good hit rate – but branch predictor usage isn’t entirely free of charge either. Effectively, it’s *not that bad*, but it’s nice to save the cost if we can.

The indirect costs are much harder to quantify. In order to deoptimize, we need to have enough state to recreate the world as the interpreter expects it to be. I [wrote on this topic](https://6guts.wordpress.com/2018/07/21/more-precise-deoptimization-usage-tracking/) not so long ago, for those who want to dive into the detail, but the essence of the problem is that we may have to retain some instructions and/or forgo some optimizations so that we are able to successfully deoptimize if needed. Thus, the presence of a guard constrains what optimizations we can perform in the code around it.

### Representation problems

A guard instruction in MoarVM originally looked like:

````
sp_guard r(obj) sslot uint32
````

Where `r(obj)` is an object register to read containing the object to guard, the `sslot` is a spesh slot (an entry in a per-block constant table) containing the type we expect to see, and the `uint32` indicates the target address after we deoptimize. Guards are inserted after instructions for which we had gathered statistics and determined there was a stable type. Things guarded include return values after a call, reads of object attributes, and reads of lexical variables.

This design has carried us a long way, however it has a major shortcoming. The program is represented in SSA form. Thus, an invoke followed by a guard might look something like:

````
invoke r6(5), r4(2)
sp_guard r6(5), sslot(42), litui32(64)
````

Where `r6(5)` has the return value written into it (and thus is a new SSA version of `r6`). We hold facts about a value (if it has a known type, if it has a known value, etc.) per SSA version. So the facts about `r6(5)` would be that it has a known type – the one that is asserted by the guard.

The invoke itself, however, might be optimized by performing *inlining* of the callee. In some cases, we might then know the type of result that the inlinee produces – either because there was a guard inside of the inlined code, or because we can actually *prove* the return type! However, since the facts about `r6(5)` were those produced by the guard, there was no way to talk about what we know of `r6(5)` before the guard and after the guard.

More awkwardly, while in the early days of the specializer we only ever put guards immediately after the instructions that read values, more recent additions might insert them at a distance (for example, in speculative call optimizations and around spesh plugins). In this case, we could not safely set facts on the guarded register, because those might lead to wrong optimizations being done prior to the guard.

### Changing of the guards

Now a guard instruction looks like this:

````
sp_guard w(obj) r(obj) sslot uint32
````

Or, concretely:

```` raku
invoke r6(5), r4(2)
sp_guard r6(6), r6(5), sslot(42), litui32(64)
````

That is to say, it introduces a *new SSA version*. This means that we get a way to talk about the value both before and after the guard instruction. Thus, if we perform an inlining and we know exactly what type it will return, then that type information will flow into the input – in our example, `r6(5)` – of the guard instruction. We can then notice that the property the guard wants to assert is already upheld, and replace the guard with a simple `set` (which may itself be eliminated by later optimizations).

This also solves the problem with guards inserted away from the original write of the value: we get a new SSA version beyond the guard point. This in turn leads to more opportunities to avoid repeated guards beyond that point.

Quite a lot of return value guards on common operations simply go away thanks to these changes. For example, in `$a + $b`, where `$a` and `$b` are `Int`, we will be able to inline the `+` operator, and we can statically see from its code that it will produce an `Int`. Thus, the guard on the return type in the caller of the operator can be eliminated. This saves the instructions associated with the guard, and potentially allows for further optimizations to take place since we know we’ll never deoptimize at that point.

### In summary

MoarVM does lots of speculative optimization. This enables us to optimize in cases where we can’t prove a property of the program, but statistics tell us that it mostly behaves in a certain way. We make this safe by adding guards, and falling back to the general version of the code in cases where they fail.

However, guards have a cost. By changing our representation of them, so that we model the data coming into the guard and after the guard as two different SSA versions, we are able to eliminate many guard instructions. This not only reduces duplicate guards, but also allows for elimination of guards when the broader view afforded by inlining lets us prove properties that we weren’t previously able to.

In fact, upcoming work on escape analysis and scalar replacement will allow us to start seeing into currently opaque structures, such as `Scalar` containers. When we are able to do *that*, then we’ll be able to prove further program properties, leading to the elimination of yet more guards. Thus, this work is not only immediately useful, but also will help us better exploit upcoming optimizations.
