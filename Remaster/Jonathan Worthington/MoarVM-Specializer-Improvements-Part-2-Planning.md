# MoarVM Specializer Improvements Part 2: Planning
    
*Originally published on [2017-09-17](https://6guts.wordpress.com/2017/09/17/moarvm-specializer-improvements-part-2-planning/) by Jonathan Worthington.*

It’s been a good while since I posted [part 1](https://6guts.wordpress.com/2017/08/06/moarvm-specializer-improvements-part-1-gathering-data/) of this little series. In the meantime, I paid a visit to the Swiss Perl Workshop, situated in a lovely hotel in the beautiful village of Villars. Of course, I was working on my slides until the last minute – but at least I could do it with this great view!

![Villars](dsc08286-small.jpg)

I gave two talks at the workshop, one of them about the MoarVM specializer ([slides](http://jnthn.net/papers/2017-spw-deopt.pdf), [video](https://www.youtube.com/watch?v=3umNn1KnlCY&list=PLOOlhkMvt_o7xFxLn1_7l3COEse6erc_u&index=4)). Spoiler alert: the talk covers much of what I will write about in this blog series. :-) Now that I’ve recovered from the talk writing and the travel, it’s time to get back to writing here. Before I dig in to it, I’d like to say thanks to The Perl Foundation and their sponsors, who have made this work possible.

### Where we left off

In the last part I discussed how we collected statistics about running code, in order to understand what to optimize and how to optimize it. The running example, which I’ll continue with, was this

```` raku
sub shorten($text, $limit) is export {
    $text.chars > $limit
        ?? $text.substr(0, $limit) ~ '...'
        !! $text
}
````

And an example of the kind of information collected is:

````
Latest statistics for 'infix:<~>' (cuid: 4245, file: SETTING::src/core/Str.pm:2797)

Total hits: 367

Callsite 0x7f1cd6231ac0 (2 args, 2 pos)
Positional flags: obj, obj

    Callsite hits: 367

    Maximum stack depth: 32

    Type tuple 0
        Type 0: Str (Conc)
        Type 1: Str (Conc)
        Hits: 367
        Maximum stack depth: 32
````

Which, to recap, tells us that the `~` infix operator was called 367 times so far, and was always passed two `Str` instances, neither of which was held in a `Scalar` container.

### The job of the planner

The planner is the component that takes this statistical data and decides what code to optimize and what cases to optimize it for. It turns out to be, at least at the time of writing, one of the [smaller parts](https://github.com/MoarVM/MoarVM/blob/master/src/spesh/plan.c) of the whole specialization subsystem; subtract memory management code and debug bits and it’s not much over 100 lines.

Its inputs are a list of static frames whose statistics were updated by the latest data. There’s no point considering anything whose statistics did not change, since there will be nothing new since the last time the planner saw them and so the conclusion would be the same. In Raku terms, a static frame may represent a routine (`Sub`, `Method`), `Block`, or `Code` thunk.

### Initial filtering

The first thing the planner looks at is whether the static frame got enough hits to be worth even considering investing time on. So if it sees something like this:

````
Latest statistics for 'command_eval' (cuid: 8, file: src/Perl6/Compiler.nqp:31)

Total hits: 1

No interned callsite
    Callsite hits: 1

    Maximum stack depth: 5
````

It can simply ignore it based on the total hits alone. Something that gets a single hit isn’t worth spending optimization effort on.

There are cases where the total hits are very low – perhaps just a single hit – but optimization is still interesting, however. Here is the loop that I used to make `shorten` hot so we could look at its statistics and plan:

```` raku
for 'x' x 50 xx 100000 {
    shorten($_, 42)
}
````

The statistics for the mainline of the program, containing the loop, start out like this:

````
Latest statistics for '<unit>' (cuid: 4, file: xxx.p6:1)

    Total hits: 1
    OSR hits: 273

    Callsite 0x7f1cd6241020 (0 args, 0 pos)

        Callsite hits: 1

        OSR hits: 273

        Maximum stack depth: 10
````

The total hits may well be 1, but obviously the loop inside of this code is hot and would be worth optimizing. MoarVM knows how to perform On Stack Replacement, where code running in a frame already on the callstack can be replaced with an optimized version. To figure out whether this is worth doing, it records the hits at “OSR points” – that is, each time we cross the location in the loop where we might replace the code with an optimized version. Here, the loop has racked up 273 OSR hits, which – despite only one hit in terms of entering the code at the top – makes it an interesting candidate for optimization.

### Hot callsites

In MoarVM, a callsite (of type `MVMCallsite`) represents the “shape” of a set of arguments being passed. This includes:

- How many positional arguments
- How many named arguments and what their names are
- Whether there is any flattening of arguments
- The register types of arguments (object, native `int`, native `num`, or native `str`)

When bytecode is produced, callsites are interned – that is to say, if we have two calls that are both passing two positional object arguments, then they will share the callsite data. This makes them unique within a compilation unit. When bytecode is loaded, then any callsites without flattening are further interned by the VM, meaning they are globally shared across all VM instances. This means that they can then be used as a kind of “key” for things like multi-dispatch caching. The specializer’s statistics are also aggregated by callsite.

The planner, therefore, takes a look at what callsites showed up. Often, code will be called with a consistent callsite, but things with optional parameters may not be. For example, if we were to run:

```` raku
sub foo(:$bar) { }
for ^100000 { rand < 0.9 ?? foo(bar => 42) !! `foo` }
````

The the statistics of `foo` might end up looking like this:

````
Latest statistics for 'foo' (cuid: 1, file: -e:1)

Total hits: 367

Callsite 0x506d920 (2 args, 0 pos)
  - bar

    Callsite hits: 331

    Maximum stack depth: 13

    Type tuple 0
        Type 0: Int (Conc)
        Hits: 331
        Maximum stack depth: 13

Callsite 0x7f3fd7461620 (0 args, 0 pos)

    Callsite hits: 36

    Maximum stack depth: 13

    Type tuple 0
        Hits: 36
        Maximum stack depth: 13
````

Unsurprisingly, the case where we pass `bar` is significantly more common than the case where we don’t, so the planner would in this case favor spending time making a specialization for the case where `bar` was passed.

As an aside, specialization by optional argument tends to be a good investment. A common pattern is:

```` raku
sub foo($bar, Bool :$some-option) {
    if $some-option {
        extra-`stuff`;
    }
}
````

In the case that `$some-option` is not passed, the specializer:

- Knows it’s a type object
- Can therefore knows that the boolification will come out to `False````
- Can therefore strip out the conditional and all the code in the `if` block

That stripping out of code might in turn bring the optimized version below the inlining limit, whereas before it might have been too big, which could bring about an additional win.

### Hot type tuples

Once one or more hot callsites have been identified, the types that were passed will be considered. In the best case, that turns out to be very boring. For example, here:

````
Latest statistics for 'chars' (cuid: 4219, file: SETTING::src/core/Str.pm:2728)

Total hits: 273

Callsite 0x7f1cd6231ae0 (1 args, 1 pos)
Positional flags: obj

    Callsite hits: 273

    Maximum stack depth: 14

    Type tuple 0
        Type 0: Scalar (Conc) of Str (Conc)
        Hits: 273
        Maximum stack depth: 14
````

The code is consistently called with a `Scalar` container holding a `Str` instance. Therefore, we can see this code is **monomorphic** in usage. It is quite clearly going to be worth spending time producing a specialization for this case.

In other cases, the code might be somewhat polymorphic:

````
Latest statistics for 'sink' (cuid: 4795, file: SETTING::src/core/List.pm:694)

Total hits: 856

Callsite 0x7f1cd6231ae0 (1 args, 1 pos)
Positional flags: obj

    Callsite hits: 856

    Maximum stack depth: 31

    Type tuple 0
        Type 0: Slip (Conc)
        Hits: 848
        Maximum stack depth: 31

    Type tuple 1
        Type 0: List (Conc)
        Hits: 7
        Maximum stack depth: 26
````

Here we can see the `sink` method is being called on both `Slip` and `List`. But it turns out that the `Slip` case is far more common. Thus, the planner would conclude that the `Slip` case is worth a specialization, and the `List` case is – at least for now – not worth the bother.

Sometimes, a situation like this comes up where the type distribution is more balanced. Any situation where a given type tuple accounts for 25% or more of the hits is considered to be **polymorphic**. In this case, we produce the various specializations that are needed.

Yet another situation is where there are loads of different type tuples, and none of them are particularly common. One place this shows up is in multiple dispatch candidate sorting, which is seeing all kinds of types. This case is **megamorphic**. It’s not worth investing the time on specializing the code for any particular type, because the types are all over the place. It is still worth specialization by callsite shape, however, and there may be other useful optimizations that can be performed. It can also be compiled into machine code to get rid of the interpreter overhead.

### Sorting

By this point, the planner will have got a list of specializations to produce. Specializations come in two forms: observed type specializations, which are based on matching a type tuple, and certain specializations, which are keyed only on an interned callsite (or the absence of one). Certain specializations are produced for megamorphic code. The list of specializations are then sorted. But why?

One of the most valuable optimizations the specializer performs is inlining. When one specialized static frame calls another, and the callee is small, then it can often be incorporated into the caller directly. This avoids the need to create and tear down an invocation record. Being able to do this relies on a matching specialization being available – that is, given a set of types that will be used in the call, there should be a specialization for those types.

The goal of the sorting is to try and ensure we produce specializations of callees ahead of specializations of their callers. You might have wondered why every type tuple and callsite was marked up with the maximum call depth. Its role is for use in sorting: specializing things with the deepest maximum call stack depth first means we will typically end up producing specialized code for potential inlinees ahead of the potential inliners. (It’s not perfect, but it’s cheap to compute and works out pretty well. Perhaps more precise would be to form a graph and do a topological sort.)

### Dumping

The plan is then dumped into the specialization log, if that is enabled. Here are some examples from our `shorten` program:

````
==========

Observed type specialization of 'infix:<~>' (cuid: 4245, file: SETTING::src/core/Str.pm:2797)

The specialization is for the callsite:
Callsite 0x7f1cd6231ac0 (2 args, 2 pos)
Positional flags: obj, obj

It was planned for the type tuple:
    Type 0: Str (Conc)
    Type 1: Str (Conc)
Which received 367 hits (100% of the 367 callsite hits).

The maximum stack depth is 32.

==========

Observed type specialization of 'substr' (cuid: 4316, file: SETTING::src/core/Str.pm:3061)

The specialization is for the callsite:
Callsite 0x7f1cd6231a60 (3 args, 3 pos)
Positional flags: obj, obj, obj

It was planned for the type tuple:
    Type 0: Str (Conc)
    Type 1: Scalar (Conc) of Int (Conc)
    Type 2: Scalar (Conc) of Int (Conc)
Which received 274 hits (100% of the 274 callsite hits).

The maximum stack depth is 15.

==========

Observed type specialization of 'chars' (cuid: 4219, file: SETTING::src/core/Str.pm:2728)

The specialization is for the callsite:
Callsite 0x7f1cd6231ae0 (1 args, 1 pos)
Positional flags: obj

It was planned for the type tuple:
    Type 0: Scalar (Conc) of Str (Conc)
Which received 273 hits (100% of the 273 callsite hits).

The maximum stack depth is 14.

==========

Observed type specialization of 'substr' (cuid: 2562, file: SETTING::src/core/Cool.pm:74)

The specialization is for the callsite:
Callsite 0x7f1cd6231a60 (3 args, 3 pos)
Positional flags: obj, obj, obj

It was planned for the type tuple:
    Type 0: Scalar (Conc) of Str (Conc)
    Type 1: Int (Conc)
    Type 2: Scalar (Conc) of Int (Conc)
Which received 273 hits (100% of the 273 callsite hits).

The maximum stack depth is 14.

==========

Observed type specialization of 'infix:«>»' (cuid: 3165, file: SETTING::src/core/Int.pm:365)

The specialization is for the callsite:
Callsite 0x7f1cd6231ac0 (2 args, 2 pos)
Positional flags: obj, obj

It was planned for the type tuple:
    Type 0: Int (Conc)
    Type 1: Scalar (Conc) of Int (Conc)
Which received 273 hits (100% of the 273 callsite hits).

The maximum stack depth is 14.

==========

Observed type specialization of 'shorten' (cuid: 1, file: xxx.p6:1)

The specialization is for the callsite:
Callsite 0x7f1cd6231ac0 (2 args, 2 pos)
Positional flags: obj, obj

It was planned for the type tuple:
    Type 0: Str (Conc)
    Type 1: Int (Conc)
Which received 273 hits (100% of the 273 callsite hits).

The maximum stack depth is 13.

==========
````

### Compared to before

So how does this compare to the situation before my recent work in improving specialization? Previously, there was no planner at all, nor the concept of certain specializations. Once a particular static frame hit a (bytecode size based) threshold, the type tuple of the current call was taken and a specialization produced for it. There was no attempt to discern monomorphic, polymorphic, and megamorphic code. The first four distinct type tuples that were seen got specializations. The rest got nothing: no optimization, and no compilation into machine code.

The sorting issue didn’t come up, however, because specializations were always produced at the point of a return from a frame. This meant that we naturally would produce them in deepest-first order. Or at least, that’s the theory. In practice, if we have a callee in a conditional that’s true 90% of the time, before there was a 10% chance we’d miss the opportunity. That’s a lot less likely to happen with the new design.

Another problem the central planning avoids is a bunch of threads set off executing the same code all trying to produce and install specializations. This was handled by letting threads race to install a specialization. However, it could lead to a lot of throwaway work. Now the planner can produce them once; when it analyzes the logs of other threads, it can see that the specialization was already produced, and not plan anything at all.

### Future plans

One new opportunity that I would like to exploit in the future is for derived type specializations. Consider assigning into an array or hash. Of course, the types of the assigned values will, in a large application, be hugely variable. Today we’d consider `ASSIGN-POS` megamorphic and so not try and do any of the type-based optimizations. But if we looked more closely, we’d likely see the type tuples are things like `(Array, Int, Str)`, `(Array, Int, Piranha)`, `(Array, Int, Catfish)`, and so forth. Effectively, it’s monomorphic in its first two arguments, and megamorphic in its third argument. Therefore, a specialization assuming the first two arguments are of type `Array` and `Int`, but without specialization of the third argument, would be a win.

### Next time…

We now have a specialization plan. Let’s go forth and optimize stuff!
