# Faster dispatches with MoarVM specializer plugins
    
*Originally published on [2018-06-09](https://6guts.wordpress.com/2018/06/09/faster-dispatches-with-moarvm-specializer-plugins/) by Jonathan Worthington.*

One of the goals for the [current round](http://news.perlfoundation.org/2018/01/grant-extension-request-perl-6-1.html) of my Perl Foundation Performance and Reliability grant is to speed up private method calls in roles, as well as assignments in to `Scalar` containers. What I didn’t expect at the time I wrote the grant application is that these two would lead to a single new mechanism in MoarVM to make them possible.

The `Scalar` container assignment improvements are still to come; currently I have a plan and hope to make good progress on it next week. I do, however, have a range of dispatch-related performance improvements to show, including the private method case.

### Background

MoarVM runs programs faster by analyzing how they run and producing specialized versions of parts of the program based on that information. It takes note of which code is run often (frequently called methods and hot loops), which types a block of code is called with, what types are returned from calls, what code a closure points to, and more. Note that it observes the runtime behavior, and so is not dependent on whether the program has type annotations or not.

Calls are one of the most important things that the optimizer considers, be they method calls, subroutine calls or invoking a received closure. Method calls are especially interesting, because with a call like `$obj.meth($arg)`, the method to be called depends on the exact type of `$obj`. Often, we end up producing a version of the code that is specialized for a particular type of `$obj`. We can therefore resolve the method once in this specialization, saving the method lookup overhead.

But there’s more. Once we know exactly what method we’ll be calling, and if the method is fairly small, we can inline it into the caller, thus eliminating the call overhead too. Further, since we are inlining a specialized version of the code and have already proved that we meet the conditions for using that specialization, we can eliminate type checks on parameters. Inlining is even more powerful than that: it opens the door to a wider range of analyses that would not be possible without it, which lead to futher program optimizations.

### The problem

We can do this kind of optimization with method calls because MoarVM understands about method calls. It knows that if it is holding the type of the invocant constant, then the result of the dispatch can also be considered a constant.

Unfortunately, there’s more than one case of method calling in Raku. While the majority of calls take the familiar `$obj.foo` form, we also have:

- Private method calls, of the form `$obj!foo` or `$obj!TrustsMe::foo````
- Qualified method calls, of the form `$obj.Some::Role.`meth`` (it may be a base class too, though this form is at its most useful in doing conflict resolution for roles)
- Duck method calls, of the form `$obj.?foo`, where if the method doesn’t exist then we just accept that and move along

In the first case, if the call is in a class, then we can resolve it at compilation time, since private methods aren’t virtual. Such calls are thus pretty fast. But what if the private method call is in a role? Well, then it was far slower. It took a method call on the meta-object, which then did a hash lookup to find the method, followed by invoking that method. This work was done by a call to a `dispatch:<!>` utility method. It was the same story for qualified calls and duck calls.

### So, let’s extend MoarVM to understand these kinds of calls?

So if normal method calls are faster because MoarVM understands them, surely we can do better by teaching it to understand these other forms of calling too? Perhaps we could add some new ops to the VM to represent these kinds of calls?

Maybe, but all of them come with their own rules. And those rules are already implemented in the metamodel, so we’d be doing some logic duplication. We make normal method calls fast by precomputing a method cache, which is just a hash table, and have the specializer do its lookups in that. While such an approach might work for private methods, it gets decidedly trickier in the other two cases. Plus those precomputed hashes take up a lot of space. There are hundreds of exception types in `CORE.setting` and every one of them has a precomputed hash table of all of its methods, with those methods from base classes denormalized in to it. This means hundreds of hashes containing mappings for all of the methods that are inherited from `Mu`, `Any`, and `Exception`. We do lazily deserialize these, which helps, but it’s still fairly costly. Introducing more such things, when I already want rid of that one, didn’t feel like a good direction.

### Let’s make MoarVM teachable

Earlier in the post, I wrote this:

> It [the optimizer] knows that if it is holding the type of the invocant [of a method call] constant, then the result of the dispatch can also be held constant.

And this is the key. The important thing isn’t that the specializer knows the precise semantics of the method dispatch. The important thing is that it knows the relationship between the arguments to a dispatch (e.g. the type that we’re calling the method on) and the result of the dispatch.

This, along with considering the challenges of optimizing `Scalar` assignments, led me to the idea of introducing a mechanism in MoarVM where we can tell it about these relationships. This enables the specializer to insert guards as needed and then simply use the calculated result of the dispatch.

### Specializer plugins

The new mechanism is known as “spesh plugins”, and I merged it into MoarVM’s master branch today. It works in a few steps. The first is that one registers a spesh plugin. Here’s the one for helping optimize private method calls:

````
nqp::speshreg('raku', 'privmeth', -> $obj, str $name {
    nqp::speshguardtype($obj, $obj.WHAT);
    $obj.HOW.find_private_method($obj, $name)
});
````

The registration provides the language the plugin is for, the name of the plugin, and a callback. The callback takes an object and a method name. The second line is the key to how the mechanism works. It indicates that the result that will be returned from this plugin will be valid provided the type of `$obj` precisely matches (that is, with no regard to subtyping relationships) the type of the `$obj` we are currently considering. Therefore, it establishes a relationship between the invocant type and the private method call result.

Then, we just need to compile a private method call like:

```` raku
self!foo($bar, $baz)
````

Into:

```` raku
nqp::speshresolve('privmeth', self, 'foo')(self, $bar, $baz)
````

Taking care to only evaluate `self` once (obviously not a problem for `self`, but in general it can be any expression, and may have side-effects).

And that’s it. So what happens at runtime?

When the interpreter encounters this call for the first time, it calls the plugin. It then stores the result along with the conditions. On later calls made in the interpreter, it uses this mapping table to quite quickly map the invocant type into the appropriate result. It’s a little cache. (Aside: this is a little more involved because we want lookups without locking, but also need to cope with multiple threads creating resolution races. Thanks to a generalized free-at-safepoint mechanism in MoarVM, this isn’t so hard.)

So that’s nice, and on its own would already be an improvement over what it replaced. But we haven’t even got to the exciting part yet! Each time we use this mapping, it records which mapping was used for the benefit of the optimizer. This information is stored in such a way that the specializer can work out which mappings are used with a particular set of parameter types to the method. So, in:

```` raku
role R {
    method `foo` {
        self!bar
    }
}
class C1 does R {
    method !`bar` { 1 }
}
class C2 does R {
    method !`bar` { 2 }
}
````

The method `foo` might be invoked with invocants of type `C1` and `C2`. Thus the mapping table for the call `self!bar` will have two entries. We may (if the code is hot) produce two specializations of method `foo`, and if we do, then we will also be able to see that there is only ever one target of the private method call in each case. Thus, we can inline the appropriate `!bar` into the matching specialization of `foo`.

### Results

Writing a module `PM.pm6` that contains:

```` raku
role R {
    method `m` { self!p }
    method !`p` { 42 }
}
class C does R {
}
for ^10_000_000 {
    C.m;
}
````

And then running it with `raku -I. -e 'use PM6'` used to run in 5.5s on my development machine. That’s only 1.8 million iterations of the loop per second, which means each is eating a whopping 1,650 CPU cycles assuming a 3GHz CPU.

With the new spesh plugin mechanism, it runs in 0.83s, over 6.5x faster. It’s over 12 million iterations of the loop per second, or around 250 CPU cycles per iteration. That’s still a good bit higher than would be good, but it’s a heck of a lot better.

Note that due to the way roles are handled in non-precompiled code, the use of the spesh plugin will not happen at present in a role in a script, thus why in this case I put the code into a module. This restriction can be lifted later.

### But wait, there’s more

I also wrote a spesh plugin for qualified dispatches, like `$obj.Foo::`meth``. This one guards on two of its inputs, and has an error case to handle. Notice how we can avoid replicating this logic inside of MoarVM itself and just write it in NQP code.

```` raku
nqp::speshreg('raku', 'qualmeth', -> $obj, str $name, $type {
    nqp::speshguardtype($obj, $obj.WHAT);
    if nqp::istype($obj, $type) {
        # Resolve to the correct qualified method.
        nqp::speshguardtype($type, $type.WHAT);
        $obj.HOW.find_method_qualified($obj, $type, $name)
    }
    else {
        # We'll throw an exception; return a thunk that will delegate to the
        # slow path implementation to do the throwing.
        -> $inv, *@pos, *%named {
            $inv.'dispatch:<::>'($name, $type, |@pos, |%named)
        }
    }
});
````

This gave an even more dramatic speedup. The program:

```` raku
role R1 {
    method `m` { 1 }
}
role R2 {
    method `m` { 2 }
}
class C does R1 does R2 {
    method `m` {
        self.R2::`m`
    }
}
for ^10_000_000 {
    C.m
}
````

Used to take 13.3s. With the spesh plugin in effect, it now takes 1.07s, a factor of more than 12x improvement.

### And even a little more…

I also wondered if I could get `$obj.?foo` duck dispatches to do better using a spesh plugin too. The answer turned out to be yes. First of all, here’s the plugin:

```` raku
sub discard-and-nil(*@pos, *%named) { Nil }
nqp::speshreg('raku', 'maybemeth', -> $obj, str $name {
    nqp::speshguardtype($obj, $obj.WHAT);
    my $meth := $obj.HOW.find_method($obj, $name);
    nqp::isconcrete($meth)
        ?? $meth
        !! &discard-and-nil
});
````

There’s a couple of cases I decided to measure here. The first is the one where we wrote code with a `.?` call to handle the general case (for example, in a module), but then the program using the module always (or > 99% of the time) gives an object where we can call the method.

```` raku
class C {
}
class D {
    method `m` { 42 }
}
for ^10_000_000 {
    (rand > 0.999 ?? C !! D).?`m`
}
````

The `rand` call, compare, and conditional are all costs in this code besides the call I wanted to measure, so it’s not such a direct measurement of the real speedup of `.?`. Still, this program went from taking 10.9s before to 4.29s with the spesh plugin in place – an improvement of 2.5x. It achieves this by doing a speculative inline of the method `m` anyway, and then using deoptimization to fall back to the interpreter to handle the 0.1% of cases where we get C and not D. (It then, at the end of the loop body, falls back into the hot code again.) Note that the inlining and deopt just naturally fell out of things the specializer already knew how to do.

But had this come at the cost of making really polymorphic cases slower? Here’s another benchmark:

```` raku
class C {
}
class D {
    method `m` { 42 }
}
for ^10_000_000 {
    (rand > 0.5 ?? C !! D).?`m`
}
````

This one goes from 7.60s to 4.92s, a 1.5x speedup. Spesh can’t just punt this to doing a deopt for the uncommon case, because there is no uncommon case. Still, the guard table scan comes out ahead.

(By the way, I think a lot of the slowness in this code – though I didn’t think of it when I wrote the benchmark – is that `rand` returns a `Num`, but `0.5` and `0.999` are `Rat`s, so it is doing a costly type coercion before comparing.)

### And what next?

Next I’ll be taking on `Scalar` containers and assignment, seeing what I can do with spesh plugins there, and hoping my ideas lead to as positive results as has been seen here.

Also, this isn’t the final word on the various benchmarks in this post either. I know full well that the current spesh plugin implementation is inserting some redundant guards, and a bit of effort on that front can probably get us another win.
