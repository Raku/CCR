# APW2014 and the Rakudo Great List Refactor
    
*Originally published on [15 October 2014](https://pmthium.com/2014/10/apw2014/) by Patrick Michaud.*

This past weekend I attended the 2014 Austrian Perl Workshop and Hackathon in Salzburg, which turned out to be an excellent way for me to catch up on recent changes to [Raku](https://raku.org/) and [Rakudo](https://rakudo.org/). I also wanted to participate directly in discussions about the Great List Refactor, which has been a longstanding topic in Rakudo development.

What exactly is the “Great List Refactor” (GLR)? For several years Rakudo developers and users have identified a number of problems with the existing implementation of list types — most notably performance. But we’ve also observed the need for user-facing changes in the design, especially in generating and flattening lists.  So the term GLR now encompasses all of the list-related changes that seem to want to be made.

It’s a significant (“great”) refactor because our past experience has shown that small changes in the list implementation often have far-reaching effects. Almost any bit of rework of list fundamentals requires a fairly significant refactor throughout much of the codebase. This is because lists are so fundamental to how Raku works internally, just like the object model. So, as the number of things that are desirable to fix or change has grown, so has the estimated size of the GLR effort, and the need to try to achieve it “all at once” rather than piecemeal.

The pressure to make progress on the GLR has been steadily increasing, and APW2014 was significant in that a lot of the key people needed for that would be in the same location. Everyone I’ve talked to agrees that APW2014 was a smashing success, and I believe that we’ve now resolved most of the remaining GLR design issues. The rest of this post will describe that.

This is an appropriate moment to recognize and thank the people behind the APW effort. The organizers did a great job.  The Techno-Z and ncm.at venues were fantastic locations for our meetings and discussions, and I especially thank ncm.at, Techno-Z, yesterdigital, and [vienna.pm](https://vienna.pm.org/) for their generous support in providing venues and food at the event.

So, here’s my summary of GLR issues where we were able to reach significant progress and consensus.

## You are now leaving flatland

(Be sure to visit our gift shop!)

Much of the GLR discussion at APW2014 concerned flattening list context in Raku. Over the past few months and years Raku has slowly but steadily reduced the number of functions and operators that flatten by default. In fact, a very recent (and profound) change occurred within the last couple of months, when the `.[]` subscript operator for Lists switched from flattening to non-flattening. To illustrate the difference, the expression

```raku
(10,(11,12,13),(14,15)).[2]
```

previously would flatten out the elements to return 12, but now no longer flattens and produces `(14,15)`. As a related consequence, `.elems` no longer flattens either, changing from 6 to 3.

Unfortunately, this change created a inconsistency between Lists and Lists, because `.[]` and `.elems` on Lists continued to flatten. Since programmers often don’t know (or care) when they’re working with a List or a List, the inconsistency was becoming a significant pain point. Other inconsistencies were increasing as well: some methods like `.sort`, `.pick`, and `.roll` have become non-flattening, while other methods like `.map`, `.grep`, and `.max` continue to flatten. There’s been no really good guideline to know or decide which should do which.

Flattening behavior is great when you want it, which is a lot of the time.  After all, that’s what Perl does, and it’s a pretty popular language. But once a list is flattened it’s hard to get the original structure if you wanted that — flattening discards information.

So, after many animated discussions, review of lots of code snippets, and seeking some level of consistency, the consensus on Raku flattening behavior seems to be:

- List assignment and the `[ ]` array constructor are unchanged; they continue to flatten their input elements. (Arrays are naturally flat.)
- The for statement is unchanged. `for @a,@b { ... }` flattens `@a,@b` and applies the block to each element of `@a` followed by each element of `@b`. Note that flattening can easily be suppressed by itemization, thus `for @a, $@b { ... }` flattens `@a` but does all of `@b` in a single iteration.
- Method calls tend to not flatten their invocant. This most impacts `.map`, `.grep`, and `.first`… the programmer will have to use `.flat.grep` and `.flat.first` to flatten the list invocant.  Notably, `.map` will no longer flatten its invocant — a significant change — but we’re introducing `.for` as a shortcut for `.flat.map` to preserve a direct isomorphism with the `for` statement.There’s ongoing conjecture of creating an operator or syntax for flattening, likely a postfix of some sort, so that something like `.|grep` would be a convenient alternative to `.flat.grep`, but it doesn’t appear that decision needs to be made as part of the GLR itself.
- Argument lists continue to depend on the context in which they are bound: flattening for slurpy parameters, top-level itemizing for slice parameters, and non-flattening (or deferred flattening) for Positionals.
- The above two points produce a general guideline that method call invocants are generally not-flattened, while function call arguments are more likely to be.

```raku
((1,2), 3, (4,5)).map({...}) # iterates over three elements
map {...}, ((1,2),3,(4,5))   # iterates over five elements

(@a, @b, @c).pick(1)         # picks one of three arrays
pick 1, @a, @b, @c           # flatten arrays and pick one element

```

- We think it will be very difficult to have a guideline that applies 100% of the time — there will be a few exceptions to the rule but they should generally feel natural.
- The flattening behavior of operators continues to be specific to each operator — some will flatten, others will not. Fortunately, any flattening behavior should be grouped by precdence level, is generally dwimmy, and there are easy ways to use contextualizers to quickly switch to the behavior you want.

## United List Severance

As a result of improvements in flattening consistency and behavior, it appears that we can eliminate the List type altogether. There was almost unanimous agreement and enthusiasm at this notion, as having both the List and List types is quite confusing.

List was originally conceived for Raku as a “hidden type” that programmers would rarely encounter, but it didn’t work out that way in practice. It’s nice that we may be able to hide it again — by eliminating it altogether. 🙂

Thus `infix:<,>` will now create Lists directly. It’s likely that comma-Lists will be immutable, at least in the initial implementation. Later we may relax that restriction, although immutability also provides some optimization benefits, and Jonathan points out that may help to implement fixed-size Arrays.

Speaking of optimization, eliminating List may be a big boost to performance, since Rakudo currently does a fair bit of converting Lists to Lists and vice-versa, much of which goes away if everything is a List.

## A few more times around the (loop) blocks

During a dinner discussion Jonathan reminded me that Synopsis 4 has all of the looping constructs as list generators, but Rakudo really only implements `for` at the moment. He also pointed out that if the loop generators are implemented, many functions that currently use `gather/take` could potentially use a loop instead, and this could be much more performant. After thinking on it a bit, I think Jonathan is on to something. For example, the code for `IO::Handle.`lines`` currently does something like:

```raku
gather {
    until not $!PIO.eof {
        $!ins = $!ins + 1;
        take self.get;
    }
}
```

With a lazy `while` generator, it could be written as

```raku
(while not $!PIO.eof { $!*ins*++; self.get });
```

This is lazily processed, but doesn’t involve any of the exception or continuation handling that `gather/take` requires. And since `while` might choose to not be strictly lazy, but ``lines`` definitely should be, we may also use the `lazy` statement prefix:

```raku
lazy while not $!PIO.eof { $!*ins*++; self.get };
```

The `lazy` prefix tells the list returned from the `while` that it’s to generate as lazily as it possibly can, only returning the minimum number of elements needed to satisfy each request.

So as part of the GLR, we’ll implement the lazy list forms of all of the looping constructs (`for`, `while`, `until`, `repeat`, `loop`). In the process I also plan to unify them under a single `LoopIter` type, which can avoid repetition and be heavily optimized.

This new loop iterator pattern should also make it possible to improve performance of `for` statements when performed in sink context. Currently `for` statements always generate calls to `.map`, passing the body of the loop as a closure. But in sink context the block of a `for` statement could potentially be inlined. This is the way blocks in most other loops are currently generated. Inlining the block of the body could greatly increase performance of `for` loops in sink context (which are quite common).

Many people are aware of the problem that constructs such as `for` and `map` aren’t “consuming” their input during processing. In other words, if you’re doing `.map` on a temporary list containing a million elements, the entire list stays around until all have been processed, which could eat up a lot of memory.

Naive solutions to this problem just don’t work — they carry lots of nasty side effects related to binding that led us to design immutable Iterators. We reviewed a few of them at the hackathon, and came back to the immutable Iterator we have now as the correct one. Part of the problem is that the current implementation is a little “leaky”, so that references to temporary objects hang around longer than we’d like and these keep the “processed” elements alive. The new implementation will plug some of the leaks, and then some judicious management of temporaries ought to take care of the rest.

## I’ve got a sinking feeling…

In the past year much work has been done to improve sink context to Rakudo, but I’ve never felt the implementation we have now is what we really want. For one, the current approach bloats the codegen by adding a call to `.sink` after every sink-context statement (i.e., most of them). Also, this only handles sink for the object returned by a Routine — the Routine itself has no way of knowing it’s being called in sink context such that it could optimize what it produces (and not bother to calculate or return a result).

We’d really like each Routine to know when it’s being called in sink context.  Perl folks will instantly say “Hey, that’s `wantarray`!”, which we long ago determined [isn’t generally feasible in Raku](http://faq.raku.org/#want).

However, although a generalized `wantarray` is still out of reach, we *can* provide it for the limited case of detecting sink contexts that we’re generating now, since those are all statically determined. This means a Routine can check if it’s been called in sink context, and use that to select a different codepath or result.  Jonathan speculates that the mechanism will be a flag in the callsite, and I further speculate the Routine will have a macro-like keyword to check that flag.

Even with detecting context, we still want any objects returned by a Routine to have `.sink` invoked on them.  Instead of generating code for this after each sink-level statement, we can do it as part of the general return handler for Routines; a Routine in sink context invokes `.sink` on the object it would’ve otherwise returned to the caller.  This directly leads to other potential optimizations:  we can avoid `.sink` on some objects altogether by checking their type, and the return handler probably doesn’t need to do any decontainerizing on the return value.

As happy as I am to have discovered this way to pass sink context down into Routines, please don’t take this as opening an easy path to lots of other wantarray-like capabilities in Raku. There may be others, and we can look for them, but I believe sink context’s static nature (as well as the fact that a false negative generally isn’t harmful) makes it quite a special case.

## The value of consistency

One area that has always been ambiguous in the Synopses is determining when various contextualizing methods must return a copy or are allowed to return `self`. For example, if I invoke `.values` on a List object, can I just return `self`, or must I return a clone that can be modified without affecting the original? What about `.list` and `.flat` on an already-flattened list?

The ultra-safe answer here is probably to always return a copy… but that can leave us with a lot of (intermediate) copies being made and lying around. Always returning `self` leads to unwanted action-at-a-distance bugs.

After discussion with Larry and Jonathan, I’ve decided that true contextualizers like `.list` and `.flat` are allowed to return `self`, but other method are generally obligated to return an independent object.  This seems to work well for all of the methods I’ve considered thus far, and may be a general pattern that extends to contextualizers outside of the GLR.

## Now it’s just a SMOPAD

(small matter of programming and documentation)

The synopses — especially Synopsis 7 — have always been problematic in describing how lists work in Raku. The details given for lists have often been conjectural ideas that quickly prove to epic fail in practice. The last major list implementation was done in Summer 2010, and Synopsis 7 was supposed to be updated to reflect this design. However, the ongoing inconsistencies (that have led to the GLR) really precluded any meaningful update to the synopses.

With the progress recently made at APW2014, I’m really comfortable about where the Great List Refactor is leading us. It won’t be a trivial effort; there will be significant rewrite and refactor of the current Rakudo codebase, most of which will have to be done in a branch. And of course we’ll have to do a lot of testing, not only of the Raku test suite but also the impact on the module ecosystem. But now that much of the hard decisions have been made, we have a roadmap that I hope will enable most of the GLR to be complete and documented in the synopses by Thanksgiving 2014.

Stay tuned.
