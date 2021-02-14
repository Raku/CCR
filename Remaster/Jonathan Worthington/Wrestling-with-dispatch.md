# Wrestling with dispatch
    
*Originally published on [2010-10-17](https://6guts.wordpress.com/2010/10/17/wrestling-with-dispatch/) by Jonathan Worthington.*

It turns out that I’m having to take a slight diversion from meta-model work to spend a while worrying over dispatch – because not dealing with the design issues now will only make for more refactoring and pain later. Further to that, it’s going to have an impact on how bits of the meta-model API should look.

Dispatch is essentially about flow control between chunks of code at the inter-block level. We often talk about dispatch as being what happens when:

- You invoke a block of code (maybe a routine)
- You call a method
- You do a multi dispatch
- You are in a wrapper and want to move to the thing you wrapped, or at least the next wrapper

However, I’m also wondering if we should consider the case of throwing an exception in with dispatch. It is also a dispatch in a sense – a dispatch to an exception handler. Running the handler may or may not indicate that some kind of stack unwinding is required. But actually getting to the handler is a kind of dispatch.

It may be useful to break dispatches up into groups.

- Simple dispatch – where we have a code object and just need to invoke it. This is the case when we have an only sub, for example, or a closure.
- Complex dispatch – when we need to work out what to dispatch to based upon some kind of information. This is true for multiple dispatch, method dispatch and wrappers.

For all complex dispatches, we have the concept of a candidate list. A candidate list is a list of things that we can work out way through calling. In a method dispatch, it’s all the methods through the MRO with a matching name. In a multi-dispatch, it’s all the matching candidates. In the case of wrapping, it’s the various wrappers, down towards the original routine that we wrapped. When we have these candidate lists, we have various operations that we can perform on them.

- Invoke the first candidate. This is what we usually want to do.
- Call the next candidate in the list (e.g. `callsame`, `callwith`)
- Defer to the next candidate in the list (e.g. `nextsame`, `nextwith`)
- Toss the remaining candidates (e.g. `lastcall`)

In some cases, we may end up with three different dispatches active at the same time for what is, from the caller’s perspective, just a method call. This shows up if you call a method (thus we’re in the method dispatcher) that happens to be a multi method (so we’re going to need to use the multi dispatcher) but somebody wrapped the `proto` (so we’re working our way through the wrapping candidate list too).

So, here’s some of the things I’m pondering.

First up, let’s look at how we obtain and iterate over candidate lists. For all complex dispatchers, in the general case, we have no idea up front whether we’re going to need the whole set of possible candidates or just the first one. (We may one day be able to build sufficient static analysis to know in *some* cases.) This means that we either need to:

- Compute the whole set up front. This has the advantage that we can cache the whole computed set in some cases – for example, we could hang it in the v-table rather than just sticking the immediate, first candidate to call there. We can make deferral be as simple as array indexing (that is, real machine-level array indexing). We don’t have to keep any extra state around to let us compute more candidates later, because we already have computed them all. The cost is that we may end up doing far more work than we actually need in the cases where we can’t cache a candidate list somewhere.
- Have the dispatchers be “first class” and actually just a Raku level routine that we’re in. Deferral is handled by a control exception being thrown and caught, and we rely on the dispatch bottoming out because at some point you’ll call something that’s not a dispatcher. Like dating an exciting girl in a far away land, this approach sounds beautiful and romantic (it’s always nice to be writing Raku in Raku), but the distance we have to go between the call being made and running the thing we’re dispatching to makes things impractical. Or less metaphorically, I don’t think the performance will cut it. Raku programs are built out of dispatches. If there’s somewhere we want to choose speed over “wow I wrote this bit of guts in Raku!”-factor, this is it.
- Do something a bit like what Rakudo does today: just compute the first candidate, but keep information around to compute more. (Well, I lie. Rakudo only does that in the method dispatcher. The multi-dispatcher doesn’t know how to continue where it left off; it just creates the illusion that it does in multi-method dispatch because the method dispatcher obtains the list of possibilities at the current “level”.) This approach needs one to work out where that state is actually stored. It is more optimal for the common case but only when the candidate list for the common case is unchacheable…apart from I think all the common cases are cacheable anyway, which kinda mitigates the win. Well, and probably ends up costing more because we have to keep more information around to resume the dispatch, rather than just an array index.

Second, dispatchers are first class from a referential point of view even if not in their implementation (actually, the issues are almost certainly orthogonal). That is, if I write &foo and we have some multi foo in scope then I refer to the whole set of candidates available *from the point of view of the current scope*. That is, in:

```` raku
class Drink { }
class Beer is Drink { }

proto foo($x) { {*} }
multi foo(Drink $x) { 42 }

my $c;
{
    multi foo(Beer $x) { 69 }
    $c = &foo;
}

say $c(Beer.new);
````

We’d expect the output to be 69, not 42.

Similar for `$obj.can(‘meth-name’)` – it returns something that we should be able to invoke and that will provide access to the whole candidate list. In these two cases, what are we actually getting a reference to? It can’t simply be a code object because we expect deferral to work. Instead, it probably needs to be a “dispatcher instance”, instantiated with (or curried with) the candidate list.

This is not really stated in the Raku specification anywhere though, so far as I can see. It perhaps needs to be, however, because we probably have to make the differentiation in ways that are user visible. For example, I expect that taking a multi and doing `.candidates`, or getting a method through `.^methods`, will almost certainly *not* give you something that will ever work in the case of deferral, since it gets you a code object, not something with a candidate list.

This code object vs dispatcher distinction comes and bites fairly hard in the case of multiple dispatch. A while ago, the specification for multiple dispatch changed quite drastically. I remain disappointed that I wasn’t consulted on the changes by the Raku design team, given I’ve led the way in implementation work on multiple dispatch in Raku in the last couple of years. The essence of the change is that whenever you do a multiple dispatch, you first call a proto, which in turn delegates to the multi-dispatcher.

This was done to help answer questions like “what does it mean to wrap a multi”, which was just not possible before. Now it simply means “you wrap the proto”. Answers to “what is the arity of a multi” and “what is the signature of a multi” now boil down to the same answer – whatever the proto declares. Further, this means that you have the possibility to do something pre-dispatch and post-dispatch. These are the good consequences, and I don’t disagree with they are improvements. However, there are some less good ones too.

One immediate one – though one I know how to deal with – is that now every single multi-dispatch is, in the unoptimized case, two Raku level invocations. Remember this hits every single operator invocation. Yes, ouch. This means that if we want to implement this scheme without a bad performance hit, we have to implement some basic inlining support.

An issue I don’t want to consider right now – but will probably happen – is a stream of (very justified) complaints from Raku users that “I have to write this proto thing that I never had to before – why the boilerplate?”

Here’s the one that is making my life much trickier, though. Consider:

```` raku
class Drink { }
class Beer is Drink { }

proto foo($x) { {*} }
multi foo(Drink $x) { 42 }

my $c;
{
    multi foo(Beer $x) { 69 }

    $c = &foo;

    &foo.wrap(sub ($x) { "lol " ~ callsame; });
}

say $c(Beer.new);
say foo(Beer.new);
````

I think most folks would agree the output of this should be “lol 69”, followed by “lol 42”. The question is, how do we actually make this work? Consider what’s in `$c`. It references some `&foo` from the inner scope. But here’s the problem: what is this `&foo`?

- It can’t just mean the `proto`, because otherwise it doesn’t capture the notion of the candidate list from the point of view of the inner scope.
- BUT when we call `.wrap` – or any other methods – we are calling them on the `proto`. And note that it clearly influenced the `proto` itself, not some clone of it, because it’s changed from the point of view of the outer scope too.

That is, it needs to be the `proto` apart from when we do a dispatch. But that’s not where the problems end. Suppose we did manage to delegate all method calls off to the `proto` apart from `.candidates`, which obtains the current view of the candidate list. How does the `{*}` inside the (now wrapped) proto, which actually enters the multi-dispatcher, get hold of this candidate list?

We have a kind of inside-out thing going on here. On the one hand, we’re invoking the proto to do the multiple dispatch, but the proto is actually just calling a wrapper, which wants to have its own candidate list. That is, if you imagine a stack of dispatchers, we have the candidate list for the multi-dispatcher in our hands when we invoke the proto, but it instead wants to push a wrapper dispatcher on the stack to go through the wrapper candidate list. It’s not until we hit the `{*}` – if we ever do – that we need to take the candidate list from the scope we captured a reference in (or invoked from, in the simple case) and give it to the multi-dispatcher.

And coming up with a robust – let alone performant – implementation of this is what’s currently tying me in knots. I didn’t even talk about closure semantics yet. Consider:

```` raku
class Drink { }
class Beer is Drink { }

proto foo($x) { * }

my $c;
multi foo(Beer $x) { $c = { nextsame } }
multi foo(Drink $x) { say "badger" }

foo(Beer.new);
$c for ^4;
````

For this to work, the current state of the candidate list iteration also needs to be lexically scoped too. We currently make this work in the methods case in Rakudo by making the dispatch state immutable and storing it in a lexical. Anyway, it’s yet another thing to consider into the design.

I guess my overall gripe here is that we’re going from a model that) is easy enough to implement and understand (despite having some real issues for “power users”), to something that seems to have a less obvious clean implementation, makes people write more boilterplate and relies on inlining optimizations to be decently performant. And while the specification offers the implementor a wish list of things that should work, there’s not so much in the way of guidance on how one might actually structure things.
