# Raku multiple dispatch with the new MoarVM dispatcher

I recently wrote about the [new MoarVM dispatch mechanism](https://6guts.wordpress.com/2021/03/15/towards-a-new-general-dispatch-mechanism-in-moarvm/),
and in that post noted that I still had a good bit of Raku's multiple dispatch
semantics left to implement in terms of it. Since then, I've made a decent
amount of progress in that direction. This post contains an overview of the
approach taken, and some very rough performance measurements.

### My goodness, that's a lot of semantics

Of all the kinds of dispatch we find in Raku, multiple dispatch is the most
complex. Multiple dispatch allows us to write a set of candidates, which are
then selected by the number of arguments:

```raku
multi ok($condition, $desc) {
    say ($condition ?? 'ok' !! 'not ok') ~ " - $desc";
}
multi ok($condition) {
    ok($condition, '');
}
```

Or the types of arguments:

```raku
multi to-json(Int $i) { ~$i }
multi to-json(Bool $b) { $b ?? 'true' !! 'false' }
```

And not just one argument, but potentially many:

```
multi truncate(Str $str, Int $chars) {
    $str.chars < $chars ?? $str !! $str.substr(0, $chars) ~ '...'
}
multi truncate(Str $str, Str $after) {
    with $str.index($after) -> $pos {
        $str.substr(0, $pos) ~ '...'
    }
    else {
        $str
    }
}
```

We may write `where` clauses to differentiate candidates on properties that
are not captured by nominal types:

```raku
multi fac($n where $n <= 1) { 1 }
multi fac($n) { $n * fac($n - 1) }
```

Every time we write a set of `multi` candidates like this, the compiler will
automatically produce a `proto` routine. This is what is installed in the
symbol table, and holds the candidate list. However, we can also write our own
`proto`, and use the special term `{*}` to decide at which point we do the
dispatch, if at all.

```raku
proto mean($collection) {
    $collection.elems == 0 ?? Nil !! {*}
}
multi mean(@arr) {
    @arr.sum / @arr.elems
}
multi mean(%hash) {
    %hash.values.sum / %hash.elems
}
```

Candidates are ranked by narrowness (using topological sorting). If multiple
candidates match, but they are equally narrow, then that's an ambiguity error.
Otherwise, we call narrowest one. The candidate we choose may then use
`callsame` and friends to defer to the next narrowest candidate, which may do
the same, until we reach the most general matching one.

## Multiple dispatch is everywhere

Raku leans heavily on multiple dispatch. Most operators in Raku are compiled
into calls to multiple dispatch subroutines. Even `$a + $b` will be a multiple
dispatch. This means doing multiple dispatch efficiently is really important
for performance. Given the riches of its semantics, this is potentially a bit
concerning. However, there's good news too.

## Most multiple dispatches are boring

The overwhelmingly common case is that we have:

* A decision made only by the number of arguments and nominal types
* No `where` clauses
* No custom `proto`
* No `callsame`

This isn't to say the other cases are unimportant; they are really quite useful,
and it's desirable for them to perform well. However, it's also desirable to
make what savings we can in the common case. For example, we don't want to
eagerly calculate the full set of possible candidates for every single multiple
dispatch, because the majority of the time only the first one matters. This is
not just a time concern: recall that the new dispatch mechanism stores dispatch
programs at each callsite, and if we store the list of all matching candidates
at each of those, we'll waste a lot of memory too.

## How do we do today?

The situation in Rakudo today is as follows:

* If the dispatch is decided by arity and nominal type only, and you don't
  call it with flattening args, it'll probably perform quite decently, and
  perhaps even enjoy inlining of the candidate and elimination of duplicate
  type checks that would take place on the slow path. This is thanks to the
  `proto` holding a "dispatch cache", a special-case mechanism implemented
  in the VM that uses a search tree, with one level per argument.
* If that's the case but it has a custom `proto`, it's not too bad either,
  though inlining isn't going to be happening; it can still use the search
  tree, though
* If it uses `where` clauses, it'll be slow, because the search tree only
  deals in finding one candidate per set of nominal types, and so we can't
  use it
* The same reasoning applies to `callsame`; it'll be slow too

Effectively, the situation today is that you simply *don't* use `where`
clauses in a multiple dispatch if its anywhere near a hot path (well, and if
you know where the hot paths are, and know that this kind of dispatch is
slow). Ditto for `callsame`, although that's less commonly reached for. The
question is, can we do better with the new dispatcher?

### Guard the types

Let's start out with seeing how the simplest cases are dealt with, and build
from there. (This is actually what I did in terms of the implementation, but
at the same time I had a rough idea where I was hoping to end up.)

Recall this pair of candidates:

```raku
multi truncate(Str $str, Int $chars) {
    $str.chars < $chars ?? $str !! $str.substr(0, $chars) ~ '...'
}
multi truncate(Str $str, Str $after) {
    with $str.index($after) -> $pos {
        $str.substr(0, $pos) ~ '...'
    }
    else {
        $str
    }
}
```

We then have a call `truncate($message, "\n")`, where `$message` is a `Str`.
Under the new dispatch mechanism, the call is made using the `raku-call`
dispatcher, which identifies that this is a multiple dispatch, and thus
delegates to `raku-multi`. (Multi-method dispatch ends up there too.)

The record phase of the dispatch - on the first time we reach this callsite -
will proceed as follows:

1. Iterate over the candidates
2. If a candidate doesn't match on argument count, just discard it. Since the
   shape of a callsite is a constant, and we calculate dispatch programs at
   each callsite, we don't need to establish any guards for this.
3. If it matches on types and concreteness, note which parameters are involved
   and what kinds of guards they need.
4. If there was no match or an ambiguity, report the error without producing a
   dispatch program.
5. Otherwise, having established the type guards, delegate to the `raku-invoke`
   dispatcher with the chosen candidate.

When we reach the same callsite again, we can run the dispatch program, which
quickly checks if the argument types match those we saw last time, and if they
do, we know which candidate to invoke. These checks are very cheap - far
cheaper than walking through all of the candidates and examining each of them
for a match. The optimizer may later be able to prove that the checks will
always come out true and eliminate them.

Thus the whole of the dispatch processes - at least for this simple case where
we only have types and arity - can be "explained" to the virtual machine as
"if the arguments have these exact types, invoke this routine". It's pretty
much the same as we were doing for method dispatch, except there we only cared
about the type of the first argument - the invocant - and the value of the
method name. (Also recall from the previous post that if it's a multi-method
dispatch, then both method dispatch and multiple dispatch will guard the type
of the first argument, but the duplication is eliminated, so only one check is
done.)

### That goes in the resumption hole

Coming up with good abstractions is difficult, and therein lies much of the
challenge of the new dispatch mechanism. Raku has quite a number of different
dispatch-like things. However, encoding all of them directly in the virtual
machine leads to high complexity, which makes building reliable optimizations
(or even reliable unoptimized implementations!) challenging. Thus the aim is
to work out a comparatively small set of primitives that allow for dispatches
to be "explained" to the virtual machine in such a way that it can deliver
decent performance.

It's fairly clear that `callsame` is a kind of dispatch resumption, but what
about the custom `proto` case and the `where` clause case? It turns out that
these can both be neatly expressed in terms of dispatch resumption too (the
`where` clause case needing one small addition at the virtual machine level,
which in time is likely to be useful for other things too). Not only that, but
encoding these features in terms of dispatch resumption is also quite direct,
and thus should be efficient. Every trick we teach the specializer about doing
better with dispatch resumptions can benefit all of the language features that
are implemented using them, too.

### Custom protos

Recall this example:

```raku
proto mean($collection) {
    $collection.elems == 0 ?? Nil !! {*}
}
```

Here, we want to run the body of the `proto`, and then proceed to the chosen
candidate at the point of the `{*}`. By contrast, when we don't have a custom
`proto`, we'd like to simply get on with calling the correct `multi`.

To achieve this, I first moved the multi candidate selection logic from the
`raku-multi` dispatcher to the `raku-multi-core` dispatcher. The `raku-multi`
dispatcher then checks if we have an "onlystar" `proto` (one that does not
need us to run it). If so, it delegates immediately to `raku-multi-core`. If
not, it saves the arguments to the dispatch as the resumption initialization
state, and then calls the `proto`. The `proto`'s `{*}` is compiled into a
dispatch resumption. The resumption then delegates to `raku-multi-core`.
Or, in code:

```raku
nqp::dispatch('boot-syscall', 'dispatcher-register', 'raku-multi',
    # Initial dispatch, only setting up resumption if we need to invoke the
    # proto.
    -> $capture {
        my $callee := nqp::captureposarg($capture, 0);
        my int $onlystar := nqp::getattr_i($callee, Routine, '$!onlystar');
        if $onlystar {
            # Don't need to invoke the proto itself, so just get on with the
            # candidate dispatch.
            nqp::dispatch('boot-syscall', 'dispatcher-delegate', 'raku-multi-core', $capture);
        }
        else {
            # Set resume init args and run the proto.
            nqp::dispatch('boot-syscall', 'dispatcher-set-resume-init-args', $capture);
            nqp::dispatch('boot-syscall', 'dispatcher-delegate', 'raku-invoke', $capture);
        }
    },
    # Resumption means that we have reached the {*} in the proto and so now
    # should go ahead and do the dispatch. Make sure we only do this if we
    # are signalled to that it's a resume for an onlystar (resumption kind 5).
    -> $capture {
        my $track_kind := nqp::dispatch('boot-syscall', 'dispatcher-track-arg', $capture, 0);
        nqp::dispatch('boot-syscall', 'dispatcher-guard-literal', $track_kind);
        my int $kind := nqp::captureposarg_i($capture, 0);
        if $kind == 5 {
            nqp::dispatch('boot-syscall', 'dispatcher-delegate', 'raku-multi-core',
                nqp::dispatch('boot-syscall', 'dispatcher-get-resume-init-args'));
        }
        elsif !nqp::dispatch('boot-syscall', 'dispatcher-next-resumption') {
            nqp::dispatch('boot-syscall', 'dispatcher-delegate', 'boot-constant',
                nqp::dispatch('boot-syscall', 'dispatcher-insert-arg-literal-obj',
                    $capture, 0, Nil));
        }
    });
```

### Two become one

Deferring to the next candidate (for example with `callsame`) and trying the
next candidate because a `where` clause failed look very similar: both involve
walking through a list of possible candidates. There's some details, but they
have a great deal in common, and it'd be nice if that could be reflected in how
multiple dispatch is implemented using the new dispatcher.

Before that, a slightly terrible detail about how things work in Rakudo today
when we have `where` clauses. First, the dispatcher does a "trial bind", where
it asks the question: would this signature bind? To do this, it has to evaluate
all of the `where` clauses. Worse, it has to use the slow-path signature binder
too, which interprets the signature, even though we can in many cases compile
it. If the candidate matches, great, we select it, and then invoke it...which
runs the `where` clauses a second time, as part of the compiled signature
binding code. There is nothing efficient about this at all, except for it being
by far more efficient on developer time, which is why it happened that way.

Anyway, it goes without saying that I'm rather keen to avoid this duplicate
work *and* the slow-path binder where possible as I re-implement this using the
new dispatcher. And, happily, a small addition provides a solution. There
is an op `assertparamcheck`, which any kind of parameter checking compiles into
(be it type checking, `where` clause checking, etc.) This triggers a call to a
function that gets the arguments, the thing we were trying to call, and can
then pick through them to produce an error message. The trick is to provide a
way to invoke a routine such that a bind failure, instead of calling the error
reporting function, will leave the routine and then do a dispatch resumption!
This means we can turn failure to pass `where` clause checks into a dispatch
resumption, which will then walk to the next candidate and try it instead.

### Trivial vs. non-trivial

This gets us most of the way to a solution, but there's still the question of
being memory and time efficient in the common case, where there is no
resumption and no `where` clauses. I coined the term "trivial multiple dispatch"
for this situation, which makes the other situation "non-trivial". In fact, I
even made a dispatcher called `raku-multi-non-trivial`! There are two ways we can
end up there.

1. The initial attempt to find a matching candidate determines that we'll have
   to consider `where` clauses. As soon as we see this is the case, we go
   ahead and produce a full list of possible candidates that could match. This
   is a linked list (see my previous post for why).
2. The initial attempt to find a matching candidate finds one that can be picked
   based purely on argument count and nominal types. We stop there, instead of
   trying to build a full candidate list, and run the matching candidate. In
   the event that a `callsame` happens, we end up in the trivial dispatch
   resumption handler, which - since this situation is now non-trivial -
   builds the full candidate list, snips the first item off it (because we
   already ran that), and delegates to `raku-multi-non-trivial`.

Lost in this description is another significant improvement: today, when there
are `where` clauses, we entirely lose the ability to use the MoarVM multiple
dispatch cache, but under the new dispatcher, we store a type-filtered list of
candidates at the callsite, and then cheap type guards are used to check it is
valid to use.

### Preliminary results

I did a few benchmarks to see how the new dispatch mechanism did with a couple
of situations known to be sub-optimal in Rakudo today. These numbers do not
reflect what is *possible*, because at the moment the specializer does not
have much of an understanding of the new dispatcher. Rather, they reflect the
*minimal* improvement we can expect.

Consider this benchmark using a `multi` with a `where` clause to recursively
implement factorial.

```raku
multi fac($n where $n <= 1) { 1 }
multi fac($n) { $n * fac($n - 1) }
for ^100_000 {
    fac(10)
}
say now - INIT now;
```

This needs some tweaks (and to be run under an environment variable) to use the
new dispatcher; these are temporary, until such a time I switch Rakudo over to
using the new dispatcher by default:

```raku
use nqp;
multi fac($n where $n <= 1) { 1 }
multi fac($n) { $n * nqp::dispatch('raku-call', &fac, $n - 1) }
for ^100_000 {
    nqp::dispatch('raku-call', &fac, 10);
}
say now - INIT now;
```

On my machine, the first runs in 4.86s, the second in 1.34s. Thus under the new
dispatcher this runs in little over a quarter of the time it used to - a quite
significant improvement already.

A case involving `callsame` is also interesting to consider. Here it is without
using the new dispatcher:

```raku
multi fallback(Any $x) { "a$x" }
multi fallback(Numeric $x) { "n" ~ callsame }
multi fallback(Real $x) { "r" ~ callsame }
multi fallback(Int $x) { "i" ~ callsame }
for ^1_000_000 {
    fallback(4+2i);
    fallback(4.2);
    fallback(42);
}   
say now - INIT now;
```

And with the temporary tweaks to use the new dispatcher:

```raku
use nqp;
multi fallback(Any $x) { "a$x" }
multi fallback(Numeric $x) { "n" ~ new-disp-callsame }
multi fallback(Real $x) { "r" ~ new-disp-callsame }
multi fallback(Int $x) { "i" ~ new-disp-callsame }
for ^1_000_000 {
    nqp::dispatch('raku-call', &fallback, 4+2i);
    nqp::dispatch('raku-call', &fallback, 4.2);
    nqp::dispatch('raku-call', &fallback, 42);
}
say now - INIT now;
```

On my machine, the first runs in 31.3s, the second in 11.5s, meaning that with
the new dispatcher we manage it in a little over a third of the time that
current Rakudo does.

These are both quite encouraging, but as previously mentioned, a majority of
multiple dispatches are of the trivial kind, not using these features. If I
make the most common case worse on the way to making other things better,
that would be bad. It's not yet possible to make a fair comparison of this:
trivial multiple dispatches already receive a lot of attention in the
specializer, and it doesn't yet optimize code using the new dispatcher well.
Of note, in an example like this:

```raku
multi m(Int) { }
multi m(Str) { }
for ^1_000_000 {
    m(1);
    m("x");
}
say now - INIT now;
```

Inlining and other optimizations will turn this into an empty loop, which is
hard to beat. There is one thing we can already do, though: run it with the
specializer disabled. The new dispatcher version looks like this:

```raku
use nqp;
multi m(Int) { }
multi m(Str) { }
for ^1_000_000 {
    nqp::dispatch('raku-call', &m, 1);
    nqp::dispatch('raku-call', &m, "x");
}
say now - INIT now;
```

The results are 0.463s and 0.332s respectively. Thus, the baseline execution
time - before the specializer does its magic - is less using the new general
dispatch mechanism than it is using the special-case multiple dispatch cache
that we currently use. I wasn't sure what to expect here before I did the
measurement. Given we're going from a specialized mechanism that has been
profiled and tweaked to a new general mechanism that hasn't received such
attention, I was quite ready to be doing a little bit worse initially, and
would have been happy with parity. Running in 70% of the time was a bigger
improvement than I expected at this point.

I expect that once the specializer understands the new dispatch mechanism
better, it will be able to also turn the above into an empty loop - however,
since more iterations can be done per-optimization, this should still show up
as a win for the new dispatcher.

### Final thoughts

With one relatively small addition, the new dispatch mechanism is already
handling most of the Raku multiple dispatch semantics. Furthermore, even
without the specializer and JIT really being able to make a good job of it,
some microbenchmarks already show a factor of 3x-4x improvement. That's a
pretty good starting point.

There's still a good bit to do before we ship a Rakudo release using the
new dispatcher. However, multiple dispatch was the biggest remaining threat
to the design: it's rather more involved than other kinds of dispatch, and it
was quite possible that an unexpected shortcoming could trigger another round
of design work, or reveal that the general mechanism was going to struggle to
perform compared to the more specialized one in the baseline unoptimized,
case. So far, there's no indication of either of these, and I'm cautiously
optimistic that the overall design is about right.
