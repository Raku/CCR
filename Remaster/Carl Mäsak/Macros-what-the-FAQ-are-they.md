# Macros: what the FAQ are they?
    
*Originally published on [17 January 2016](http://strangelyconsistent.org/blog/macros-what-the-faq-are-they) by Carl Mäsak.*

*Thank you *sergot*++ for eliciting these answers out of me, and prompting me to
publish them.*

#### Q: Is it common to be totally befuddled by all these macro-related concepts?

Yes! In fact, that seems to be the general state of mind not just for people
who hear about these things now and then, but also for those of us who have
chosen to implement a macro system! 😝

Seriously though, these are not easy ideas. When you don't deal with them every
day, they naturally slip away from your attention. The brain prefers it that
way.

#### Q: I keep seeing all these terms: quasis, unquotes, macros... I *think* I know what some of them are, but I'm not sure. Could you explain?

Yes. Let's take them in order.

#### Q: OK. What the heck is a quasi?

Quasis, or quasiquotes, are a way to express a piece of code as objects. An
average program doesn't usually "program itself", inserting bits and pieces of
program code using other program code. But that's exactly what quasis are for.

Quasis are not strictly necessary. You could create all those objects by hand.

```raku
quasi { say "OH HAI" }        # easy way
Q::Block.new(Q::Statement::Expr.new(Q::Postfix::Call.new(
    Q::Identifier.new("say"),
    Q::Literal::Str.new("OH HAI")
)));                          # hard way
```

It's easier to just write that quasi than to construct all those objects.
Because when you want to structurally describe a bit of code, it turns out the
easiest way to do that is usually to... write the code.

(By the way, take the `Q::Block` API with a huge grain of salt. It only exists
for 007 so far, not for Raku. So the above is educated guesses.)

#### Q: Why would we want to create those Q objects? And in which situations?

Excellent question! Those Q objects are the "API for the structure of the
language". So using it, we can query the program structure, change it during
compile time, and even make our own Q objects and use them to extend the
language for new things.

They are a mechanism for taking over the compiler's job when the language isn't
flexible enough for you. Macros and slangs are a part of this.

#### Q: Do you have an example of this?

Imagine a `format` macro which takes a format string and some arguments:

```raku
say format "{}, {}!", "Hello", "World";
```

Since this is a macro, we can check things at compile time. For example, that
we have the same number of directives as arguments after the format string:

```raku
say format "{}!", "Hello", "World";                        # compile-time error!
```

In the case of sufficient type information at compile time, we can even check
that the types are right:

```raku
say format "{}, robot {:d}!", "Hello", "four-nineteen";    # compile-time error!
```

#### Q: Ooh, that's pretty cool!

I'm not hearing a question.

#### Q: Ooh, that's pretty... cool?

Yes! It is!

#### Q: Why is it called "quasiquote"? Why not "code quote" or something?

Historical reasons. In Lisp, the term is quasiquote. Raku's quasiquotes are
not *identical*, but probably the nearest thing you'll get with Raku still
being Perl.

Traditionally, quasiquotes have unquotes in them, so let's talk about them.

#### Q: Right. What's an unquote?

In Java, you have to write something like `"Hello, " + name + "!"` when
interpolating variables into a string. Java developers don't have it easy.

In Perl, you can do `"Hello, $name!"`. This kind of thing is called "string
interpolation".

Unquotes are like the `$name` interpolation, except that the string is a quasi
instead, and `$name` is a Qtree that you want to insert somewhere into the quasi.

```raku
quasi {
    say "Hello," ~ {{{$name}}};
}
```

Just like the `"Hello, $name"` can be different every time (for example, if we
loop over different `$name` from an array), unquotes make quasis potentially
different every time, and therefore more flexible and more useful.

To tie it to a concrete example: every time we call the `format` macro at
different points in the code, we can pass it different format strings and
arguments. (Of course.) These could end up as unquotes in a quasi, and thus
help to build different program fragments in the end.

In other words, a quasi is like a code template, and unquotes are like
parametric holes in that template where you can pass in the code you want.

#### Q: Got it! So... macros?

Macros are very similar to subroutines. But where a sub call happens at run
time, a macro call happens at compile time, when the parser sees it and knows
what to send as arguments. At compile time, it's still early enough for us to
be able to contribute/modify Q objects in the actual program.

So a macro in its simplest form is just a sub-like thing that says "here,
insert this Qtree fragment that I just built".

#### Q: So quasis are used inside of a macro?

Yes. Well, they're no more tightly tied to each other than `given` and `when```
are in Perl, but they're a good fit together. Since what you want to do in a
macro is return Q objects representing some code, you'd naturally reach for a
quasi to do that. (Or build the Q objects yourself. Or some combination of the
two.)

#### Q: Nice! I get it!

Also not a question.

#### Q: I... get it?

Yeah! You do!

#### Q: Ok, final question: is there something that you've omitted from the above explanation that's important?

Oh gosh, yes. Unfortunately macros are still gnarly.

The most important bit that I didn't mention is hygiene. In the best case, this
will just work out naturally, and Do What You Mean. But the deeper you go with
macros, the more important it becomes to actually know what's going on.

Take the original quasiquote example from the top:

```raku
quasi { say "OH HAI" }
```

The identifier `say` refers to the usual `say` subroutine from the setting.
Well, *unless* you were actually doing something like this:

```raku
macro `moo` {
    sub say($arg) { callwith($arg.lc) }
    return quasi { say "OH HAI" }
}
`moo`;    # 'oh hai' in lower-case
```

What we mean by hygiene is that `say` (or any identifier) always refers to the
```rakusay` in the environment where the `quasi` was written. Even when the code gets
inserted somewhere else in the program through macro mechanisms.

And, conversely, if you did this:

```raku
macro `moo` {
    return quasi { say "OH HAI" }
}
{
    sub say($arg) { callwith("ARGLEBARGLE FLOOT GROMP") }
    `moo`;    # 'OH HAI'
}
```

Then `say` would still refer to the setting's `say`.

Basically, hygiene is a way to provide the macro author with basic guarantees
that wherever the macro code gets inserted, it will behave like it would in the
environment of the macro.

The same is *not* true if we manually return Q objects from the macro:

```raku
Q::Block.new(Q::Statement::Expr.new(Q::Postfix::Call.new(
    Q::Identifier.new("say"),
    Q::Literal::Str.new("OH HAI")
)));
```

In this case, `say` will be a "detached" identifier, and the corresponding two
examples above would output `"OH HAI"` with all-caps and `"ARGLEBARGLE FLOOT
GROMP"`.

The simple explanation to this is that code inside a quasi can have a
surrounding environment (namely that which surrounds the quasi)... but a bunch
of synthetically created Q objects can't.

We're planning to use this to our advantage, providing the safe/sane
quasiquoting mechanisms for most things, and the synthetic Q object creation
mechanism for when you want to mess around with unhygiene.

#### Q: Excellent! So when will all this land in Raku? I'm so eager to...

Ok, that was all the questions we had time for today! Thank you very much, and
see you next time!
