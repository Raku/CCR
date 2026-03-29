# Macros progress report: D2 merged
    
*Originally published on [2 November 2012](http://strangelyconsistent.org/blog/macros-progress-report-d2-merged) by Carl Mäsak.*

The grant that I'm currently working on, the [macros grant](https://news.perlfoundation.org/2011/09/hague-grant-application-implem.html),
has now reached its D2 milestone. That is, the so-called "unquotes" work
as advertised in Rakudo:

```raku
macro apply($code, $argument) {
    quasi {
        {{{$code}}}( {{{$argument}}} );
    }
}
apply sub ($t) { say $t }, "OH HAI";    # prints "OH HAI"
```

Macros are *routines*, and so they take parameters. The above `apply` macro
takes some `$code` and an `$argument`, and calls the former with the latter.
It's as if, when the macro expansion is all done, what's left in the code
is the following line:

```raku
(sub ($t) { say $t })("OH HAI");    # prints "OH HAI"
```

Of course, we never actually *see* this line, and in the compiler it's never
textually substituted like that, because the substitution all happens on the
level of syntax trees, not on the level of text.

The new thing in this picture is the `{{{ }}}` thingies: the so-called
*unquotes*. Back in [my last progress report](Macros-progress-report-quantum-yak-shaving.html),
we still didn't have unquote support in nqp. Now we do. In fact, we got unquote
support already back in August. That, it turns out, was the easy bit.

Then the conceptual problems appeared. For a few months, whenever I thought
about macros, my brain would melt trying to think about those problems. It took
quite a while to go from unquotes existing to them being actually useful. What
follows is an explanation of the problem and its solution.

The problem is one of *context*. By that, we mean the variable bindings seen by
a piece of code. Psychologically, we expect a piece of code to see the variables
in its lexical environment, that is, all the variables declared in all
surrounding blocks.

```raku
my $a;
sub f {
    my $b;
    sub {
        my $c;
        # $a, $b, $c visible here
    }
}
```

The exciting and highly useful thing about closures is that they honor this
expectation, while simultaneously being *first-class values* that you can pass
around between parts of your program. This combination of static bindings and
dynamic function values is so powerful that you can use it to emulate the
object encapsulation so espoused by OO enthusiasts.

In the above case, the sub `f` implicitly returns its inner sub, which can
be transported across the Russian tundras, stored in a dank wine cellar for
75 years before being uncorked... but when finally called, it will *still*
remember its `$a`, `$b`, and `$c` bindings. That's because closures aren't
just containers of statements. They also hold a reference to an `OUTER` block
through which variable lookups can be made.

(And in the above case, `$b` and `$c` are properly encapsulated. `$a` isn't,
since it's globally visible.)

We want macros to behave the same. That is, `quasi` blocks should behave like
closures.

```raku
macro f {
    my $a = "OH HAI";
    quasi {
        say $a;
    }
}
my $a = "B... BOOOOM!";
f;      # OH HAI
```

It's the same principle: after the `f;` call has been conceptually replaced by
`say $a;` this code should still remember its context, its origins, namely the
macro body. The fact that `say $a;` doesn't print `"B... BOOOOM!"`, from the
variable in the mainline scope, is part of what's called *hygiene*. Hygiene
means that just like with closures, bindings inside are isolated from bindings
outside by default.

(The term "hygiene" is often conflated in people's minds with the term
"AST-based macros". The two are not the same. AST-based macros are necessary
but not sufficient for hygiene. End of rant.)

But wait a minute. These two situations are obviously very similar. In the case
of the closure, we know that the closure must keep an `OUTER` reference to
remember its context. What is it in the macro case that remembers the context?

The `quasi` construct generates an AST, a syntax tree, that then gets spliced
into the mainline code where the `f;` call used to be. This AST must be the
vessel for the context information. So, just like a closure is a bunch of
statements plus a context, an AST object must be a tree plus the context
information. If the AST *didn't* have a context, the above macro expansion
couldn't be hygienic.

We must perform unholy surgery on the block that eventually results from the
quasi AST. The block will naturally have mainline context, but we want to
*recontext* it to have macro context. So in the Rakudo macro expansion code,
there is some code that transplants the context from the AST object to the new
block. It involves a Rakudo-specific op called `raku_get_outer_ctx`. It's only
used for this code path.

This much was clear already when I was merging D1. Now for the new
complications.

Macro expansions consist of *two* stages of substitution, and this is what
makes them useful:

- **Unquotes are replaced by ASTs**, typically arguments originating from the outisde of the macro.
- **The macro invocation is replaced by the AST** returned from applying the macro to its arguments.

When implementing D1, I sorted out my thoughts by writing lots of ruminating
gists. During this phase of the work, I've composed fewer gists, but an
unexpected thing happened: the more time passed, the more I realized how much I
had *misnamed* the variables in the macro code I had contributed to Rakudo.

It wasn't that I was careless about naming when I first wrote that code.
Instead, my understanding of the macro domain had shifted so much that the
choices of names I had made started to feel wrong. Today I landed [a
long-awaited
refactor](https://github.com/rakudo/rakudo/commit/203f97e264e1c61e18a61163eef49bba03b806f1)
which not only unified the three macro-invocation code paths, but also fixed
all the now slighty-off variable names. Quite a relief.

Here's part of what changed. During D1, a lot of AST objects in source ended up
being called **quasi ASTs**. Nowadays, the following distinction is made:

- **quasi ASTs** are what `quasi` blocks generate. Naturally.
- **argument ASTs** are the things that the parser generates as it parses the macro arguments, just before it invokes the macro.
- **macro ASTs** are what's returned from a macro, to be spliced back into the mainline code.

There is overlap. A macro AST has been generated as either a quasi AST or an
argument AST at some point or other. But the focus here is where the ASTs are
coming from. And it turns out that matters a lot. Quasi ASTs and argument ASTs
are quite different. Hence the need for precision.

By the way, there is possibly a fourth kind of AST, one that we don't have yet,
but that is totally possible once people start building macro libraries and
stuff:

- **synthetic ASTs**

Syntax trees built up programmatically from individual
AST nodes or smaller ASTs.

Don't know yet if that's going to become a reality. Until it does, `quasi```
blocks fill much the same role.

Once we had unquotes working in Rakudo, the one glaring omission was that
the unquotes didn't behave hygienically. Which was a shame because, again,
people really expect hygiene to work:

```raku
macro test($value) {
    my $a = "B... BOOOOM!";
    quasi {
        say {{{$value}}};
    }
}
my $a = "OH HAI";
test $a;    # OH HAI nowadays, used to B... BOOOOM!
```

Just as the quasi AST should remember its own original context, so should the
argument AST that ends up in `$value`. It used not to, and so the context it
got was the quasi's, resulting in `"B... BOOOOM!"` above. A little ironic
that it was the successful recontexting of the quasi AST that messed things
up for the argument AST.

For months I struggled with the problem of how to recontext the argument
ASTs. I developed a solution in a branch, which finally worked as it should,
except that it *still* didn't recontext the ASTs properly! Argh!

My plan of attack had been to set the context at the time of unquote
evaluation, as the quasi is evaluated when running the macro. The other
day, jnthn pointed out that this approach may be overly complicated: maybe
the context could be set at the time of argument collection, just before
calling the macro. This is definitely simpler. Not least because at this
point, the parser actually *is* in the context it wants to set! And in
particular, no block surgery was needed this time.

I tried it. It worked. This solution almost feels *too* simple, and I'm not
sure yet it will let us do all the things we want to do. But all the tests
pass, and I have hammered this solution with tricky situations that might
break, and it's holding up so far. So, we now have hygienic macros with
unquotes in Rakudo.

Here are the macro-related gists that I wrote during this period. They are in
various states of obsolescence at this point, but still potentially
informative:

- [Proceedings: What are macros?](https://gist.github.com/masak/abd360db840a0719da2f)
- [macros use case by FROGGS](https://gist.github.com/masak/3438222)
- [It's all about context](https://gist.github.com/masak/3634046)
- [pack, unpack, pack, unpack](https://gist.github.com/masak/3678362)

The other artifacts that have emerged since D1 are as follows:

- A [new spectest file](https://github.com/raku/roast/blob/master/S06-macros/unquoting.t).

Also, thanks to a suggestion by *moritz*++, the macro spectest files are now
[much better
named](https://github.com/raku/roast/commit/0710d57620707c076175f129eb1ab08df427b840).

- A number of commits to the `nom` branch of Rakudo:
- [can parse unquotes in quasis](https://github.com/rakudo/rakudo/commit/98591b486467b72f925d3cea0bcfa7155f6e313c)
- [backpedal on throwing an exception](https://github.com/rakudo/rakudo/commit/1b9b70b1d0813cebd2b3d4dab2805be1d7abc13f)
- <a href="https://github.com/rakudo/rakudo/commit/30c0302b747a553b7f97191919930c06effe3575">`<statementlist>`, not `<EXPR>`</a>
- [implement unquote splicing](https://github.com/rakudo/rakudo/commit/b7e189599c2787d7b3cbfb2865bbfb406fdc042f)
- [`X::TypeCheck::MacroUnquote` -> `X::TypeCheck::Splice`](https://github.com/rakudo/rakudo/commit/fc88876a1bc08eb6c5b39be4ae8b9f72d366c604)
- [throw `X::TypeCheck::Splice` everywhere](https://github.com/rakudo/rakudo/commit/7d10d1aae2288b9e7c9529c9899bd845ced808fc)
- [make comment more precise](https://github.com/rakudo/rakudo/commit/e5b94e343b237fa644ccff2abb583f0331ea74ad)
- [refactor](https://github.com/rakudo/rakudo/commit/e7ab9ace23569bb2d5fe5550288efb8c0cbacd4b)
- [wrap macro-arg ASTs in thunks](https://github.com/rakudo/rakudo/commit/9bb7de6dbf77b29298dae64ed5707e08061f065a)
- [unify macro code paths](https://github.com/rakudo/rakudo/commit/203f97e264e1c61e18a61163eef49bba03b806f1)
- [make macro expansion ignore empty ASTs](https://github.com/rakudo/rakudo/commit/02688057bb7e44557c614155370cd57209733e1c)

- A number of commits to the `nqp` project:

- [added `QAST::Unquote`](https://github.com/raku/nqp/commit/1f54496f467ce76307afedb8e0992c1206aa7ea6)
- [added `.evaluate_unquotes` method to QAST nodes](https://github.com/raku/nqp/commit/c2236072abf2f4d743f0b02d750fc5ac32b88f00)
- [add `.evaluate_unquotes` to BVal and Block](https://github.com/raku/nqp/commit/2f7b14d66b5777f7f4d680cdbd787d284828c1f2)
- [shallow-clone nodes with kids](https://github.com/raku/nqp/commit/bc734932e9f7a8b63938fcb8ea8d23a057cd596f)

- Two more deliveries of the macros talk: one at French Perl Workshop in
Strasbourg, and one at YAPC::Europe in Frankfurt.

And once again, it's time to glance at what's ahead in the grant work. D3
promises to deliver hygiene. As explained above, D2 already provides this; I
actually could have declared the milestone D2 finished at the point I got
unquotes working in Rakudo (in August), but it felt slightly disingenuous to do
so, because unquotes aren't really useful until they're fully hygienic. Anyway,
half of D3 ends up being already done. What still needs to be implemented is
the `COMPILING::` pseudopackage, which gives the macro author several ways to
opt out of hygiene. This is sometimes very powerful, even if it makes sense for
it not to be the default.

My grant reports have been sparse lately. I'm hopeful that the wait until the
next one won't be as long.
