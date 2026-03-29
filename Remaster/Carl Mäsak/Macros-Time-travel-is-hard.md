# Macros: Time travel is hard
    
*Originally published on [27 October 2015](http://strangelyconsistent.org/blog/macros-time-travel-is-hard) by Carl Mäsak.*

Let's say you're a [plucky young time traveler from the
80s](https://tvtropes.org/pmwiki/pmwiki.php/Film/BackToTheFuture1985) and you go
back to the 50s because Libyan terrorists are chasing you and then you
accidentally mess things up with the past and your time machine DeLorean
is broken and you need to fix that too...

Dealing with the different phases involved in macros is a bit like dealing
with the two time streams: the new present, which is very early compared
to what we're used to, and the future, which we would like to get back to
intact. ([The slow
path](https://tvtropes.org/pmwiki/pmwiki.php/Main/TheSlowPath), wasn't much
of an option for Marty, and it isn't for us either as macro authors.)

Let's try a new way of thinking of all this, instead of compile time and
runtime. Those terms quickly get muddled with macros, since a macro *runs*
(so it's kind of runtime), but it has `BEGIN`-time semantics (so it's
definitely compile-time).

Let's call the two phases **early** and **late**. Instead. What the compiler
does happens **early**. What the normal program does happens **late**. M'kay?

`BEGIN` blocks? Early. `constant` declarations? Early. `CHECK` blocks? Also
early, though kind of at the 11th hour of early. Role bodies get executed
early when they're getting concretized into a class.

Most everything else? Late. That is, in the 80s where Marty belongs. And
where most people run most of their code.

Macro bodies run early too. Except for the (often-occurring) quasi block at
the end, which runs late. This is how you should probably think about macros:
they have a "preparation area" where you get to do some initialization early,
and then they have a "code area" whose code runs, inline where you called
the macro, late.

Got it? Like these terms? Eh, I guess they work. I don't expect we'll keep
them around, but let's explore them.

So much for setup. I had a thought today, which led me down some wrong paths.
I'd like to try and relate it. Partly because it's "fun" to analyze one's
own failure modes. Partly because, and believe me on this, macros are gnarly.
Far be it from me to discourage people from using macros &mdash; the past
few months of thinking and investigations have convinced me that they're
useful, that they have a clear place in Raku, and that we can make them
well-designed. But *wow* are they weird sometimes.

Macros are so strange that once you wrap your head around closures, and accept
that they're actually quite a natural consequence of first-class functions and
lexical lookup, macros come along and make your brain go "wait, what?".

Part of that, I'm sure, is the weird (but consistent) scoping semantics you
get from macros. But part of it is also the early/late distinction.

Ok, so back to what happened. I was thinking about [implementing a 007 runtime
in 007](https://github.com/masak/alma/issues/51), and in particular how the
runtime would invoke functions, especially built-in functions. I realized I
would probably need a huge table of built-in function mappings at some point
in the runtime. In Raku, it'd look something like this:

```raku
my %builtins =
    say => &say,
    abs => &abs,
    min => &min,
    max => &max,
    # ...and so on, for far too many lines...
;
```

As you see, it's all mappings from strings to the runtime's own built-ins. Yep,
welcome to the world of metacircular runtimes.

So I wondered, "hm, shouldn't we be able to write a macro that takes a string
value (that we get from a `Q::Identifier`) and dynamically looks it up in the
current environement?". And indeed, I quickly came up with this:

```raku
macro lookup(name) {
    return Q::Identifier( melt(name) );
}
```

So easy! This example presupposes
[`melt`](https://github.com/masak/007/issues/61), which is a kind of evaluation
built-in for Qtrees. We need to use `melt` because the `name` that we get in is
a Qtree representing a name, not a string. But `melt` gives us a string.

Oh, and it works and everything!

```raku
lookup("say")("OH HAI");    # OH HAI
```

Unfortunately, it's also completely useless. Specifically, `lookup` doesn't
fulfill its original purpose, which was to allow *dynamic* lookup of names in
the scope.

Why? Because we're running the macro **early**, and so variables like
`ident_name` cannot be `melt`ed because they don't have a meaningful value yet
&mdash; they will, but not until **late** &mdash; only constants and literals
like `"say"` have meaningful values. But in all such cases, we could just
replace `lookup("say")` with... `say`. D'oh!

Ok, so that didn't work. My next bright idea was to make use of the fact that
`quasi` blocks run late. So we can get our dynamism from there:

```raku
macro lookup_take_II(name_expr) {
    quasi {
        my name = {{{name_expr}}};
        # great, now I just need to... ummm....
    }
}
```

There's no correct way to conclude that thought.

Why? Because you're in a quasi, which means you're back in the 80s, and you
want to do a 50s thing, but you can't because the time machine is gone. In
other words, it's late, and suddenly you wish it was early again. Otherwise how
are you going to build that dynamic identifier? If only there were a `lookup```
macro or something! 😀

This has been the "masak stumbles around in the dark" show. Hope you enjoyed.
I also hope this shows that it's easy to go down the wrong path with macros,
before you've had something like four years of practice with them. Ahem.

Anyway, these ponderings eventually led to the `melt` builtin &mdash; coming
soon to a 007 near you! &mdash; which, happily *will* solve the problem of
dynamic lookup (as detailed in [the issue
description](https://github.com/masak/007/issues/61). So all's well that ends
well.

Macros are not a handgun that can accidentally shoot you in the foot if you
use them wrong. They're more like an powered-off laser cannon which, if you
look at it the wrong way, will shoot you in *both* feet, *and* your eyes and
then your best friend's feet. That kind of power sure can come in handy
sometimes! I'm convinced we as a community will learn not just to harness and
contain that power, but also how to explain to ourselves how to best use
the laser cannon so that it does not accidentally fire too early, or too late.
Gotta stay in phase.
