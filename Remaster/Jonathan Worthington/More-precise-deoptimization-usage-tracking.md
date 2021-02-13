# More precise deoptimization usage tracking
    
*Originally published on [2018-07-21](https://6guts.wordpress.com/2018/07/21/more-precise-deoptimization-usage-tracking/) by Jonathan Worthington.*

In my [previous post](https://6guts.wordpress.com/2018/07/20/better-usage-information-in-the-moarvm-specializer/) here, I talked about deoptimization and its implications for usage information. If you didn’t read that post, I suggest reading it before continuing, since the work described in this post builds upon it. Further background on deoptimization and its use in MoarVM may be found in [my talk slides](http://jnthn.net/papers/2017-spw-deopt.pdf) from last year’s Swiss Perl Workshop.

### An example to consider

To keep things a bit simpler, we’ll look at an NQP program. NQP is a simplified subset of Raku, and so its naive compilation – before the optimizer gets at it – is much simpler than that produced by Rakudo. Here’s a small program to consider.

```` raku
class Wrapper {
    has $!x;
    method `x` { $!x }
}
class C { }

sub test($w) {
    my $var := "Used later";
    if nqp::istype($w.x, C) {
        "C"
    }
    else {
        $var
    }
}

my int $i := 0;
my $wrapper := Wrapper.new(x => C.new);
while $i < 1_000_000 {
    say(test($wrapper));
    $*i*++;
}
say(test(Wrapper.new(x => NQPMu)));
````

We’ll consider the `test` subroutine’s optimization. First, let’s walk through the bytecode before optimization. We always have a dummy empty basic block at the start of the graph, used for internal purposes, so we can disregard that.

````
  BB 0 (0x7f1be817b070):
    line: 7 (pc 0)
    Instructions:
      no_op           
    Successors: 1
    Predecessors: 
    Dominance children: 1
````

The next basic block starts with a bunch of `null` instructions, which will be mostly deleted. In the slow path interpreter, we null out registers in case code tries to read them as part of callframe setup. However, we get rid of that in the optimized code by letting the optimizer prove that such work is mostly not needed. Since we didn’t do any optimization yet, here’s all of those instructions.

````
  BB 1 (0x7f1be817b0f8):
    line: 7 (pc 0)
    Instructions:
      null              r5(1)
      null              r4(1)
      null              r3(1)
      null              r1(1)
      null              r0(1)
````

Next we receive the parameter.

````
      checkarity      liti16(1), liti16(1)
      param_rp_o        r0(2), liti16(0)
      paramnamesused  
````

Then we have the line `my $var := "used later";`. Rakudo is smarter than NQP in compiling such a thing: it would just emit a reference to a single constant string rather than boxing it each time like NQP’s simpler code-gen does.

````
      [Annotation: Line Number: x.nqp:7]
      const_s           r2(1), lits(Used later)
      hllboxtype_s      r3(2)
      box_s             r3(3),   r2(1),   r3(2)
      set               r1(2),   r3(3)
````

Now we have the code for `$x.w`. It starts out with a `decont`, since we may have been passed something in a `Scalar` container (note that NQP code may be called from full Raku code, so this is possible). We then look up the method and call it.

````
      [Annotation: INS Deopt One (idx 0 -> pc 46; line 9)]
      [Annotation: Logged (bytecode offset 40)]
      decont            r4(2),   r0(2)
    Successors: 2
    Predecessors: 0
    Dominance children: 2

  BB 2 (0x7f1be817b158):
    line: 9 (pc 46)
    Instructions:
      findmeth          r3(4),   r4(2), lits(x)
    Successors: 3
    Predecessors: 1
    Dominance children: 3

  BB 3 (0x7f1be817b1b8):
    line: 9 (pc 56)
    Instructions:
      [Annotation: INS Deopt One (idx 1 -> pc 56; line 9)]
      prepargs        callsite(0x7f1bf1f0b340, 1 arg, 1 pos, nonflattening, interned)
      arg_o           liti16(0),   r0(2)
      [Annotation: INS Deopt All (idx 3 -> pc 72; line 9)]
      [Annotation: INS Deopt One (idx 2 -> pc 72; line 9)]
      [Annotation: Logged (bytecode offset 66)]
      invoke_o          r3(5),   r3(4)
    Successors: 4
    Predecessors: 2
    Dominance children: 4
````

Notice how two various instructions here are annotated with `Deopt` points. These are places that we might, after optimization has taken place, insert an instruction that could cause us to deoptimize. The `pc 72` refers to the offset into the unoptimized bytecode that we should continue execution back in the interpreter.

There’s also various `Logged` annotations, which indicate instructions that may log some statistics – for example, about what code is invoked, and what type of value it returns (for `invoke_o`) or what kind of type we get out of a `decont` operation that actually had to read from a container.

Next up is the type check. Again, there’s a `decont` instruction, just in case the call to `$x.w` returned something in a container. We then have the `istype` instruction.

````
  BB 4 (0x7f1be817b218):
    line: 9 (pc 72)
    Instructions:
      [Annotation: INS Deopt One (idx 4 -> pc 78; line 9)]
      [Annotation: Logged (bytecode offset 72)]
      decont            r4(3),   r3(5)
    Successors: 5
    Predecessors: 3
    Dominance children: 5

  BB 5 (0x7f1be817b278):
    line: 9 (pc 78)
    Instructions:
      wval              r5(2), liti16(0), liti16(5) (P6opaque: C)
      istype            r6(1),   r4(3),   r5(2)
    Successors: 6
    Predecessors: 4
    Dominance children: 6
````

Next comes the `if` part of the branch:

````
  BB 6 (0x7f1be817b2d8):
    line: 9 (pc 94)
    Instructions:
      unless_i          r6(1),   BB(8)
    Successors: 8, 7
    Predecessors: 5
    Dominance children: 7, 8, 9

  BB 7 (0x7f1be817b338):
    line: 9 (pc 102)
    Instructions:
      const_s           r2(2), lits(C)
      hllboxtype_s      r4(4)
      box_s             r4(5),   r2(2),   r4(4)
      set               r5(3),   r4(5)
      goto              BB(9)
    Successors: 9
    Predecessors: 6
    Dominance children: 
````

Followed by the `else` part. And what is `r1(2)`? It’s the “Used later” string from earlier.

````
  BB 8 (0x7f1be817b398):
    line: 12 (pc 134)
    Instructions:
      set               r5(4),   r1(2)
    Successors: 9
    Predecessors: 6
    Dominance children: 
````

Finally, we’re done, and return the result of the branch of the `if` statement that was executed.

````
  BB 9 (0x7f1be817b3f8):
    line: 12 (pc 140)
    Instructions:
      PHI               r5(5),   r5(3),   r5(4)
      PHI               r4(6),   r4(5),   r4(3)
      PHI               r2(3),   r2(2),   r2(1)
      return_o          r5(5)
    Successors: 
    Predecessors: 7, 8
    Dominance children: 
````

### How we optimize it

Let’s now walk through the optimized output. The argument handling has been reduced to a single instruction that does an unchecked read of the incoming argument. This is because we’re producing a specialization for a particular input callsite shape and set of input arguments. In this case, it will be a single argument of type `Wrapper`.

````
  BB 0 (0x7f1be817b070):
    line: 7 (pc 0)
    Instructions:
      no_op           
    Successors: 1
    Predecessors: 
    Dominance children: 1

  BB 1 (0x7f1be817b0f8):
    line: 7 (pc 0)
    Instructions:
      sp_getarg_o       r0(2), liti16(0)
````

What comes next is the code to store that `"Used later"` string. The ops look fine, but do you notice something odd?

````
      const_s           r2(1), lits(Used later)
      hllboxtype_s      r3(2)
      [Annotation: INS Deopt One (idx 0 -> pc 46; line 9)]
      box_s             r1(2),   r2(1),   r3(2)
````

Yup, there’s a deopt annotation moved on to that `box_s`. Huh? Well, let’s look at what comes next.

````
      [Annotation: INS Deopt One (idx 1 -> pc 56; line 9)]
      sp_getspeshslot   r7(0), sslot(2)
    Successors: 2
    Predecessors: 0
    Dominance children: 2

  BB 2 (0x7f1be8356d38):
    Inlined
    line: 7 (pc 0)
    Instructions:
      [Annotation: FH Start (0)]
      [Annotation: Inline Start (0)]
      [Annotation: INS Deopt Inline (idx 5 -> pc 20; line 8)]
      set               r9(1),   r0(2)
      [Annotation: INS Deopt Inline (idx 6 -> pc 42; line 9)]
      sp_p6ogetvt_o    r11(1),   r9(1), liti16(8), sslot(4)
      [Annotation: FH End (0)]
      set               r3(5),  r11(1)
    Successors: 3
    Predecessors: 3
    Dominance children: 3
````

Recall that in the unoptimized code we next did `$w.x` by a `findmeth` instruction, which came after a `decont` of `$w`, and the we did an invocation of that method. What’s happened to all of that lot?

First, since `$w` is the argument we are producing a specialization for, we thus know it’s `Wrapper`, and we know that’s not a container type, so the `decont` can go. Since we also know its type and we know the method name, we can just resolve that method once. The resolution of it is then stored in a “spesh slot”, which you can think of as a constants table for this particular specialization. What follows is, instead of the invocation, the code for the `method `x` { $!x }`, which has been inlined. (The `sp_p6ogetvt_o` instruction is what attribute lookup has been optimized into.)

Oh, and about that `Deopt` annotation on the `box_s`? That’s just because code got deleted and it got shifted. We’ll look at the consequences of that later.

Here is the rest of the code:

````
  BB 3 (0x7f1be817b218):
    line: 9 (pc 72)
    Instructions:
      [Annotation: Inline End (0)]
      [Annotation: FH Goto (0)]
      [Annotation: INS Deopt One (idx 2 -> pc 72; line 9)]
      [Annotation: INS Deopt One (idx 4 -> pc 78; line 9)]
      sp_guardconc      r3(5), sslot(0), litui32(72)
      const_s           r2(2), lits(C)
      hllboxtype_s      r4(4)
      box_s             r5(3),   r2(2),   r4(4)
      PHI               r5(5),   r5(3)
      return_o          r5(5)
    Successors: 
    Predecessors: 2
    Dominance children: 6
````

Well, that’s pretty different from what we started out with too. What on earth has happened? Where did our `if` statement go?!

The `sp_guardconc` instruction is a guard. It checks, in this case, that we have a concrete instance of C in register `r3(5)`. It was inserted because the gathered statistics said that, so far, it had been such 100% of the time. The guard will deoptimize – that is, fall back to the interpreter – if it fails, but otherwise proceed. Since we have guarded that, then the `istype` will become a constant. That means we know which way the branch would go, and can delete the other part of the branch. A type check, a conditional branch, and a branch all go away, to be replaced by a single cheap guard.

### But what about that “Used later” string?

Notice how we executed:

````
      box_s             r1(2),   r2(1),   r3(2)
````

But its result value, `r1(2)`, is completely unused anywhere in the code that we have left after optimization. The instruction was, however, retained, for the sake of deoptimization. In the original code, the value was written prior to a guard that might deoptimize. Were we to throw it away, then after we deoptimized the interpreter would try to read a value that wasn’t written, and crash in some interesting way.

### The original approach

The original approach taken to this problem was to:

1. Whenever we see a `Deopt` annotation, take its index as our current deopt point
1. Whenever we see a write, label it with the current deopt point
1. Whenever we see a read, check it the deopt point of the write is not equal to the deopt point of the read. If that is the case, mark the write as needing to be retained for deopt purposes.

Effectively, if a value written before a deopt point might be read after a deopt point, then we retain it. That was originally done by bumping its usage count. In my last post here, I described how we switched to setting a “needed for deopt” flag instead. But in the grand scheme of things, that changed nothing much about the algorithm described above; only step 3 was changed.

Note that this algorithm works in the case of loops – where we might encounter a value being read in a PHI node prior to seeing it being written – because the lack of a deopt point recorded on the writer will make it unequal to the current deopt point.

### Correct, but imprecise

The problem with this approach isn’t with correctness, but rather with precision. A deopt retention algorithm is correct if it doesn’t throw away anything that is needed after a deoptimization. Of course, the simplest possible algorithm would be to mark everything as required, allowing no instruction deletions! The method described above is also correct, and marks fewer things. And for a while, it was enough. However, it came to be a blocker for various other optimizations we wish to do.

There are two particular problems that motivated looking for a more precise way to handle deopt usage. First of all, many instructions that *may* be replaced with a guard and deoptimize are actually replaced with something else or even deleted. For example, `decont` will often be replaced by a `set` because we know that it’s not a container type. A `set` can never trigger deoptimization. However, we had no way to update our deopt usage information based on this change. Therefore, something written before the `set` that used be a `decont` and read after it, but otherwise not needed, would be kept alive because the `decont` *could* have had a guard inserted, even though we know it did not.

A larger problem is that even when we might insert a guard, we might later be able to prove it is not needed. Consider:

````
my int $i = $str.chars;
````

The `chars` method will be tiny, so we can inline it. Here’s the code that we currently produce; I’ve shown the end of the inlining of the `chars` method together with the assignment into `$i`.

````
      chars            r15(1),  r14(1)
      hllboxtype_i     r13(1)
      [Annotation: INS Deopt Inline (idx 7 -> pc 134; line -1)]
      box_i            r13(2),  r15(1),  r13(1)
      [Annotation: FH End (0)]
      set               r2(5),  r13(2)
    Successors: 3
    Predecessors: 4
    Dominance children: 3

  BB 3 (0x7efe0479b5f0):
    line: 1 (pc 100)
    Instructions:
      [Annotation: Inline End (0)]
      [Annotation: FH Goto (0)]
      [Annotation: INS Deopt One (idx 3 -> pc 100; line 1)]
      sp_guardconc      r2(5), sslot(2), litui32(100)
      set               r2(6),   r2(5)
      set               r5(1),  r15(1)
      bindlex         lex(idx=0,outers=0,$i),   r5(1)
````

Since `$i` is a native integer lexical, we don’t need to box the native integer result of the `chars` op at all here. And you can see that we have done a rewrite such that `r15(1)` is used to assign to `$i`, *not* the boxed result. However, the `box_i` instruction is retained. Why?

The immediate reason is that it’s used by the guard instruction. And indeed, I will do some work in the future to eliminate that. It’s not a hugely difficult problem. But doing that *still* wouldn’t have been enough. Why? Because there is a deopt point on the guard, and the boxed value is written before it and used after it. This example convinced me it was time to improve our deopt handling: it was directly in the way of optimizations that could provide a significant benefit.

### A more precise algorithm

It took me three attempts to reach a solution to this. The first simple thing that I tried follows from the observation that everything written after the last deopt instruction in the optimized code can never possibly be used for deoptimization purposes. This was far from a general solution, but it did help a bit with very small functions that are free of control flow and have no or perhaps just some very early guards. This was safe, easy to reason about, easy to implement – but ultimately not powerful enough. However, it was helpful in letting me frame the problem and start to grapple with it, plus it gave me a set of cases that a more powerful solution should be able to take care of.

Attempt number two was to do a repeat of the initial deopt analysis process, but *after* the optimizations had taken place. Thus, cases where a `Deopt` annotation was on an instruction that was turned into something that could never deoptimize would not be counted. This quickly fell apart, however, since in the case where entire branches of a conditional were deleted then reads could disappear entirely. They simply weren’t there to analyze any more. So, this was an utter failure, but it did drive home that any analysis that was going to work had to build up a model of deoptimization usages *before* we performed any significant optimizations, and then manipulate that model safely even in the light of a mutated program graph.

Attempt three took much longer to come up with and implement, though thankfully was rather more successful. The new algorithm proceeds as follows.

1. When we see a write instruction – and provided it has at least one reader – place it into a set `OW` of writes with still outstanding reads.
1. When we see a deopt point, take the set `OW` and record the index of this deopt point on each of those writes. This means that we are now associating the writes with *which* deopt points are keeping them alive.
1. Whenever we see a read, mark it as processed. Check if the writer has now had all of its reads processed. If so, remove it from the set `OW`.

This algorithm works in a single pass through the program graph. However, what about loops? In a loop, no matter what order we traverse the graph in, we will always see some reads that happen before writes, and that breaks the algorithm that I described above.

After some amount of scribbling graphs and staring at them, I hit upon a way to solve it that left me with a single pass through the graph, rather than having to iterate to a fixed point. When we see a read whose writer was not yet processed, we put it into a set of reads that are to be processed later. (As an aside, we know thanks to the SSA form that all such instructions are `PHI` (merge) instructions, and that these are always placed at the start of the graph.) We will then process a pending read when we have processed all of the basic blocks that are its predecessors – which means that by then all possible writes will have been processed.

The result is that we now have a list of all of the deopt points that make use of a particular write. Then, after optimization, we can go through the graph again and see which deopt points actually had guards or other potentially deoptimizing instructions placed at them. For all the cases where we have no such instruction under that `Deopt` annotation, we can delete the deopt usage. That way, if all normal usages *and* deopt usages of a value are gone, and the writing instruction is pure, we can delete that instruction.

This further means that once we gain the ability to delete guards that we can prove are not required any longer – perhaps because of new information we have after inlining – we will also be able to delete the deopt usages associated with them.

Last but not least, the specializer’s log output also includes which deopt points are keeping a value alive, so we will be able to inspect the graph in cases where we aren’t entirely sure and understand what’s happening.

### Future work

With this done, it will make sense to work on guard elimination, so that is fairly high on my list of upcoming tasks. Another challenge is that while the new deopt algorithm is far more precise, it’s also far more costly. Its use of the DU chains means we have to run it as a second pass after the initial facts and usage pass. Further, the algorithm to eliminate unrequired deopt usages is a two pass algorithm; with some engineering we can likely find a way to avoid having to make the first of those. The various sets are represented as linked lists too, and we can probably do better than that.

One other interesting deoptimization improvement to explore in the future is to observe that any pure instructions leading up to a deopt point can be replayed by the interpreter. Therefore, we can deopt not to the instruction mapping to the place where we put the deopt point, but to the start of a run of pure instructions before that. That would in some cases allow us to delete more code in the optimized version.

Next time, I’ll be looking at how increasingly aggressive inlining caused chaos with our context introspection, and how I made things better. Thanks go to The Perl Foundation for making this work possible.
