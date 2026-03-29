# Macros: thunkish parameters
    
*Originally published on [13 October 2014](http://strangelyconsistent.org/blog/macros-thunkish-parameters) by Carl Mäsak.*

*The macro thing is big, and I/we need to think about the design a bit, and what we want. This is the first of a series of blog posts in which I focus on one issue at a time, leaving space for people to comment and discuss. My hope is that a solution will emerge/crystallize from the individual needs and features discussed. For a while, though, it will feel like I'm writing RFCs. Don't expect me to stay consistent from one such RFC to another.*

## Feature: macro parameters

Macros today are declared at the routine level. That is, a macro is a kind of subroutine, or very close to a subroutine. We find it in normal sub form or in operator form:

```raku
macro foo($x, $y) { ... }
macro infix:<!>($x, $y) { ... }
```

But if you're a parameter, you might feel discriminated by this deal. The parameters that come into a macro are always `AST` objects, because that's what's being a macro means. The parameters have no choice about it &mdash; with the current design.

What if they could choose? What if a routine was a macro if at least one of the parameters was "thunked"?

```raku
sub foo(THUNK $x, THUNK $y) { ... }
sub infix:<!>(THUNK $x, THUNK $y) { ... }
```

"Thunk" is a concept that we use in the spec today to mean "evaluated lazily/by need". S06 describes it as "a closure that uses the current lexical scope parasitically". That is, it has some block-like characteristics (not evaluated immediately; has its own `$/` and `$!`), but not others (no separate scope; variable declarations "leak" outside).

*By the way, syntax is negotiable and the diametrical opposite of set in stone. In this post and subsequent ones, I will reach for whatever syntax comes to mind, and then not give it a second thought. My focus will be on semantics, and syntax will have to come after that when we know what we want.*

## `macro` keyword gone

The `macro` keyword is gone under this regime. It's no longer needed to indicate that a routine is a macro, since the `THUNK` keyword already signals this. (*Or*, in the universe with toggled beardedness, the `macro` keyword stays and has to be used iff the `THUNK` keyword is used. Assuming normal beardedness for the rest of the post, though.)

What does this give us? It gives us the ability to have some parameters be normal values, and others not.

```raku
sub foo(THUNK $x, $y) { ... }
sub infix:<!>($x, THUNK $y) { ... }
```

## Actual, real-world examples

But here we actually have better examples than just `foo` and `infix:<!>`. This is needed today with some thunkish operators, like the logicals and `xx`, both of which thunkify their operands in different ways:

```raku
sub infix:<||>($lhs, THUNK $rhs) { ... }
sub infix:<xx>(THUNK $elem, $n) { ... }
```

This is less about "OMG, `infix:<||>` should be defined in user space" (which may or may not be possible, due to circular chainsaw-itis) and more about "wouldn't it be nice if thunking of parameters/operands could happen in user space?".

There are also some thunks that we can't easily define as subroutines: statement-modifying `if` and `for`, attribute defaults, and parameter defaults. These are all too tied into the Raku grammar (as "special forms" rather than expressions), and so we can't really reach them. But one can still imagine a statement-mod `for` being defined like that:

```raku
sub statement_mod_loop:sym<for>(THUNK $statement, @values) { ... }
```

## Implementation

This is easiest to discuss with a relatively real example. Let's pretend that we could implement `infix:<xx>` like this:

```raku
sub infix:<xx>(THUNK $elem, $n) {
    (^$n).map: { {{{$elem}}} };
}
```

There's now no longer a sense of the macro code being executed once at parse and once at run. Therefore, the `quasi` block is gone, because it's no longer being used to separate these two phases. Instead, `infix:<xx>` gets called every time it occurs in code. For example:

```raku
sub star { <★ ✯ ✶>.roll }
for 1..10 -> $stars {
    say [~] `star` xx $stars;
}
```

This one still needs to do 10 calls to `infix:<xx>`, and 55 calls to `star`.

However, there may still need to be some shenanigans happening at parse time in order to set up the routine so that it `AST`-ifies the thunkish arguments. It's almost as if the argument evaluator needs to be constructed by the macro declaration (so that it knows to evaluate this thing but `AST`-ify that thing), and then shipped to its appropriate caller locations.

Some consequences of this: I *think* that makes it possible for macros to be used before declaration. Because the thing is now predominantly runtime. As long as we can guarantee that all caller locations will get the right argument evaluator so that it doesn't send values where it should send `AST`s. But that information shouldn't be a problem to apply retrospectively, as far as I can see. That same information also *has* to survive being exported outside of a package, in the case of exported macros.

## Not addressed by this proposal

Identified in [a previous post](Macros-progress-report-after-a-long-break.html).

- The `{{{ }}}` syntax being universally hated
- Quasi slices only being usable in term position
- Macro parameters/operands being restricted to expressions
- Macros having a story in grammars/slangs
- Manipulexity of program elements
