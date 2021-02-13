# Dynamic lookups and context introspection with inlining
    
*Originally published on [2018-07-22](https://6guts.wordpress.com/2018/07/23/dynamic-lookups-and-context-introspection-with-inlining/) by Jonathan Worthington.*

Inlining is one of the most important optimizations that MoarVM performs. Inlining lets us replace a call to some `Block`, `Sub`, or `Method` with the code that is inside of it. The most immediate benefit is to eliminate the overhead of calling, but that’s just the start. Inlined code has often already been specialized for a certain set of argument types. If we already have proven those argument types in the caller, then there’s no need to re-check them. Inlining can also expose pairs of operations that can cancel, such as box/unbox, and bring the point a control exception is thrown into the some body of code where it is caught, which may allow the exception throw to be rewritten to a far cheaper `goto`.

In a language like Raku, where every operator is a call to a multiple dispatch subroutine, inlining can be a significant win. In the best cases, inlining can lead to smaller code, because the thing that is inlined ends up being smaller than the bytecode for the call sequence. Of course, often it leads to bigger code, and so there’s limits to how much of it we really want to do. But still, we’ve been gradually pushing on with increasing the range of things that we’re able to inline.

The problem with inlining is that the very call boundaries it does away with may carry semantic significance for the program. In this post, I’ll talk about a couple of operations that became problematic as we ramped up our inlining capabilities, and discuss a new abstraction I recently added to MoarVM – the frame walker – which provides a common foundation for solving the problem.

### A little inlining history

Inlining first showed up in MoarVM back in 2014, not too many months after the type-specializing optimizer was added. MoarVM has done speculative optimizations from the start, performing deoptimization (falling back to the interpreter) in the case that an unexpected situation shows up. But what if we had to deoptimize in code that had been inlined? Then we’d have to pretend we never did the inlines! Therefore, MoarVM can *uninline* too – that is, untangle the results of inlining and produce a call stack as if we’d been running the unoptimized code all along.

MoarVM has also from the start supported nested inlines – that is, inlining things that themselves contained inlines. However, the initial implementation of inlining was restricted in what it could handle. The first implementation could not inline anything with exception handlers, although that was supported within a couple of months. It also could not inline closures. Only `sub`s in the outermost scope or from the `CORE.setting`, along with simple method calls, were possible to inline, because those were the only cases where we had enough information about what was being called, which is a decided prerequisite for inlining it.

Aside from bug fixes, things stayed the same until 2017. The focus in that time largely switched away from performance and towards the Raku.c release. Summer of 2017 brought some very large changes to how dynamic optimization worked in MoarVM, moving optimization to a background thread, along with changing and extending the statistics that were collected. A new kind of call optimization became possible, whereby if we could not prove what we were going to call, but the statistics showed a pattern, then we could insert a guard and speculatively optimize the call. Speculative inlining fell neatly out of that. Suddenly, a bunch more things could be considered for inlining.

Further work lifted some of the inlining restrictions. Deoptimization learned how to cope if we deoptimized in the middle of processing named arguments, so we could optimize code where that situation occurred. It became possible to inline many closures, by rewriting the lexical lookup operations into an indirection through the code object of the code that we had inlined. It also became possible to inline code involving lexical throws of exceptions and their handlers. Since that is how `return` works in Raku, that again made quite a few more things possible to inline. A more fine-grained analysis allowed us to do some amount of cross-language inlining, meaning bits of the Rakudo internals written in NQP could be inlined into the Raku code calling them, including closure cloning. I’ll add at this point that while it’s easy to write a list of these improvements now, realizing various of them was quite challenging.

Now it’s summer 2018, and my work has delivered some more advances. Previously, we would only do an inlining if we already had produced a specialized version of the callee. This usually worked out, and we sorted by maximum call stack depth and specialized deepest first to help with that. However, sometimes that was not enough, and we missed inlining opportunities. So, during the last month, I added support for producing code to inline on-demand. I also observed that we were only properly doing speculative (that is, based on statistics) inlines of calls made that were expected to return an object, but not those in void context. (If that sounds like an odd oversight, it’s because void calls were previously rare. It was only during the last month, when I improved code-gen to spot a lot more opportunities to emit void context calls, that we got a lot more of them and I spotted the problem.)

### More is better, no?

Being able to inline a wider range of calls is a good thing. However, it also made it far more likely that we would run into constructs that don’t cope well with inlining. We’ve got a long way by marking ops that we know won’t cope well with it as `:noinline` (and then gradually liberalizing that over time where it was beneficial). The improvements over the previous month created a more difficult problem, however. We have a number of ops that allow for introspection and walking of the call stack. These are used to implement Raku features such as the `CALLER::` pseudo-package. However, they are also the way that `$/` can be set by things like `match`.

Marking the `ctx` op as `:noinline` got us a long way. However, we ran into trouble because once a context handle has been obtained, one could then start traversing from it to callers or outers, and then starting some kind of lookup lookup relative to that point. But what if the caller was an inline? Then we don’t have a callframe to reference in the context object that we return.

A further problem was that a non-introspection form of dynamic lookup, which traverses the lexical chain hanging off each step of the dynamic chain, also was not aware of inlines. In theory, this would have become a problem when we started doing inlining of closures last year. However, since it is used in a tiny number of places, and those places didn’t permit inlining, we didn’t notice until this month, when inlining started to cover more cases.

Normal dynamic lookup, used for `$*foo` style variables, has been inline-aware for about as long as we’ve had inlining. However, this greatly complicated the lookup code. Replicating such inline compensation code in a bunch of places was clearly a bad idea. It’s a tricky problem, since we’re effectively trying to model a callstack that doesn’t really exist by using information telling us what it would look like if it did. It’s the same problem that deoptimization has to solve, except this time we’re just imagining what the call stack would look like unoptimized, not actually trying to recreate it. It’s certainly not a problem we want solved repeatedly around MoarVM’s implementation.

### A new frame walker

To help tackle all of these problems, I introduced a new abstraction: the specialization-aware frame walker. It provides an iterator over the call stack as if no inlining had taken place, figuring out as much as it needs to in order to recreate the information that a particular operation wants.

First, I used it to make caller-dynamic lookup inline-aware. That went pretty well, and immediately fixed one of the module regressions that was “caused” by the recent inlining improvements.

Next, I used it to refactor the normal dynamic lookup. That needed careful work teasing out the details of dynamic lookup and caching of dynamic variable lookups from the inlining traversal. However, the end result was [far simpler code](https://github.com/MoarVM/MoarVM/commit/7314e231055d37fa190ac9d2420f407c9df5e520), with much less duplication, since the JITted inline, interpreted inline, and non-inline paths largely collapsed and were handled by the frame walker.

Next up, contexts. Alas, this would be trickier.

### Embracing laziness

Previously, context traversal had worked eagerly. When we asked for a context object representing the caller or outer of a particular context we already had, we immediately walked one frame in the appropriate direction and produced a result. Of course, this did not go well if there were inlines, since it always walked one *real* frame, but that may have multiple inlined frames within it.

One possibility was to make the `ctx` op immediately deoptimize the whole call stack, so that we then had a chain of real call frames to traverse. However, when I looked at some of the places using `ctx`, it became clear this would have some very negative performance consequences: every regex match causing a global deopt was not going to work!

Another option, that would largely preserve the existing design, was to store extra information about the inline we were inside of at the time we walked to a caller. This, however, had the weakness that we might do a deoptimization between the two points, thus invalidating the information. That was probably also possible to fix up, but the complexity of doing so put me off that approach.

Instead, I switched to a model where “move to caller” and “move to outer” would be stored as displacements to apply when the context object was used in order to obtain information. The frame walker could make these movements, before doing whatever lookup was required. Thus, even if a deoptimization were to take place between obtaining the context and using it, we could still do a correct traversal.

### Too much laziness

This helped, but wasn’t quite enough either. If a context handle was taken and used immediately, things worked out fine. However, if the situation was like this:

````
+-------------------------+
| Frame we used ctx op on | (Frame 1)
+-------------------------+
             |
           Caller
             |
             v
+-------------------------+
|    Frame with inlines   | (Frame 2)
+-------------------------+
````

And then we used the handle some time later, things worked out less well. The problem was that I used the current return address of Frame 2 in order to understand which inline(s) we were inside of. However, if we’d executed more code in Frame 2, then it could have made another call. The current return address could thus point to the wrong inline. Oops.

However, since the `ctx` operation at the start of the lookup is never inlined, and a given call frame can only ever be called from one location in the caller, there’s a solution. If the `ctx` op is used to get a first-class reference to a frame on the call stack, we walk down the call stack and make sure that each frame called from inlined code preserves enough location information that we can later reconstruct what we need. It only needs to walk down the call stack until it sees a point where another `ctx` operation already preserved that information, so in programs with lots of use of the `ctx` op, we can avoid doing full stack walks each time, and just walk over recently created frames.

### In closing

With those changes, the various Raku modules exhibiting lookup problems since this month’s introduction of more aggressive inlining were fixed. Along the way, a common mechanism was introduced allowing us to walk a call stack as if no inlines had taken place. There’s at least one more place that we can use this: in order to make stack trace output not be sensitive to inlining. I’ll get to that in the coming weeks, or it might make a nice task for somebody looking to get themselves (more) involved with MoarVM development. Last but not least, I’d like to once again thank [The Perl Foundation](https://www.perlfoundation.org/) for organizing the funding that made this work possible.
