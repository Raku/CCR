# Macros: Placeholdeeers!
    
*Originally published on [4 December 2014](http://strangelyconsistent.org/blog/macros-placeholdeeers) by Carl Mäsak.*

*Alternative blog post title: finally, a rant about the `{{{ }}}` syntax.*

The macro blog post train lumbers on. Remember, the goal here is to [view
macros from all
perspectives](https://www.google.com/search?tbm=isch&q=picasso+cubist+images),
or at least all of them that somehow pertain to Raku. There's a whole lotta
perspectives! Together they will form a "cloud" of suggestions, forces, and
decisions... and then, magically, something wildly appropriate will crystallize
out of the chaos, suggesting a way forward.

In the meantime, it will seem like I'm recklessly firing RFCs on myself until
I'm buried under them. What can I say? You need a lot of different parts to
build a... [SPACESHIP!](https://www.youtube.com/watch?v=7TYJyCCO8Dc)

Today's episode brings you [vanviegen's macro
proposal](https://github.com/jashkenas/coffeescript/pull/3171) from our friends
over at the CoffeeScript world. You should read the OP in that one, but as a
public service, I will also translate <del>all</del><ins>some of</ins> the
Coffee code snippets into Highly Plausible Raku.

```raku
# optionally compiled debug info
macro debug(*@args) {
    if (DEBUGGING) {            # it's a constant defined somewhere
        Q::Call.new(
            Q::Literal.new(     # (handwave)
                "debugImpl"
            )
        )
    }
}
```

vanviegen's proposal doesn't have a notion of `quasi` blocks. At first I
thought that was pretty lame, and clearly not a step up from what we already
have implemented. But then...

```raku
# mandatory swap example
macro swap($a, $b) {
    Q.codeToNode({
        my ($x, $y) = $y, $x;
    }).subst(
        '$x' => $a,         # o.O
        '$y' => $b,
    );
}
```

...uuummmm.

Hold on just a minute. Let's all freeze our immediate reaction, and render that
in Current Actual Raku:

```raku
# mandatory swap example
macro swap($a, $b) {
    quasi {
        ({{{$a}}}, {{{$b}}}) = {{{$b}}}, {{{$a}}};
    }
}
```

(Which [works](http://irclog.perlgeek.de/raku/2014-12-04#i_9759758), by the way.)

Ok, so here's my reaction:

- v's macro system doesn't use quasiquotes.

It doesn't need them. It has realized
that we already have a mechanism for expressing code as a value: blocks.

- If we left it at that, macros would be no more powerful than subroutines, which are already callable blocks.

What quasis offer is a way to *insert* parameterized
code into the bigger fixed template.

- v's macro system lets us inject things from the *outside* using the `.subst` call on `AST`s.

It's a different mechanism to unquoting, but it fills exactly the same
semantic role.

- Man, those triple curly unquotes are ugly.

What were we thinking!? I mean, people
accuse us for having been color-blind when drawing
[Camelia](https://raku.org/img/camelia-logo.png), but... were we like "ooh, Lisp
must have been successful *because* of the parentheses. Let's do them in
triplicate!"

Ok, enough making fun of our own choices. I think what we're seeing here is an
interesting solution, but I don't think we should rush to adopt it wholesale.
I'll try to be more clear, or at least less circumscript, in what follows.

But I also think I've figured out something about templating syntax.

> *All templating syntax sucks.*

&mdash; masak's Deplorable Truth About Templating Syntax

It doesn't matter what you do: your templating syntax is going to suck. The
template placeholders are a kind of out-of-band signaling, OK. "Hey hey, a
thing gets inserted here!" You need a syntax for the placeholders. The syntax
cannot blend in too naturally into the surrounding text because (a) if people
don't notice them then we have a problem, and (b) if they're too close to
normal syntax then there are also parsing collisions.

So you have to make them stand out, which means making them look somehow
unnatural. Visual pills. Ugly. I guess that's what we went for with the `{{{
}}}` syntax: maximal ugly. Something that would *never, ever* be confused with
sane and decent code. Someone might at some point find a reason to write *two*
opening braces in normal code. But *three*? So it's collision-safe. And ugly.

Don't believe me when I say that all templating syntax sucks? Fine, I'll bring
you examples:

- [sprintf](https://perldoc.perl.org/functions/sprintf.html).

I could stop here.

- [`Template::Toolkit`](https://metacpan.org/pod/Template::Tutorial::Web).

Combining square brackets, percent signs, and COBOL-style uppercase keywords.

- [py3k's completely revamped format strings](https://docs.python.org/3/library/string.html#formatstrings).

Actually, that's not so bad. But braces? In Python? I thought that was
`SyntaxError: not a chance`.

Anyway, you can't go right with a templating system. It's like the Prime
Directive in Star Trek. The string would be better off if you left it in its
natural state, but for one reason or another, *you just have to inject those
out-of-band placeholders* and mess things up a bit. Just a little, because
things will be "better". After which... things are not in a natural state any
more. Your string is full of percents, your HTML no longer validates, your
Python has braces, and your Raku has a *lot* of braces.

But v's macro system offers an interesting alternative. No quasi quotes, no
unquoting. Nothing needs to be out-of-band anymore. Things are injected from
the outside.

I'm going to list what I perceive as pros and cons of this proposal. In
increasing complexity order, so pros and cons will interleave.

- **Pro**

No more `{{{ }}}`. Yay!

- **Pro**

No more `quasi` blocks. Actually, this one deserves a bit more than
just a "Yay!" &mdash; quasis are currently our way to represent code as ASTs,
but it's like Raku's quasis bypass the standard way in Perl to quote code:

```
AST form    ........^..................^........
                    |                  |
lambda form ........|..................|........
                    |
real code   ........|...........................
            p6's current way      v's codeToNode
```

Rakudo's quasi implementation has already validated how much quasis piggyback
on blocks/lambdas. v's macro system validates that in a more direct way.

- **Con**

There are now extra moving parts. We have to make up new variables
`$x` and `$y` just so we can substitute them. The reader is expected to
mentally do the substitution in `.subst` to see what the eventual code will be.

- **Pro**

There's a neat sleight-of-hand that goes on there that you won't have
thought about until I point it out: we feel like we're swapping out
*variables*, but what we're really doing is substituting *pieces of AST*.
It's that subtle difference between "the value in `$x`" (which does not even
enter into the picture on this level), "the variable `$x`" (the thing we feel
we're manipulating), and "the piece of AST denoting the variable `$x`" (the
thing we are actually manipulating).

- **Con**

We're finding `$x` and `$y` using short strings of *text*. Eww. It's
partly a scoping thing. `$x` and `$y` are already out of scope, and so we
cannot refer to them directly. It's partly a convenience thing. Strings are the
simplest way to state what we are looking for. In fact, we don't really have a
symbol type in Raku that we could use instead. But it still feels wrong.

- **Pro**

The code inside of the block is *really* undisturbed. Plus, I could
imagine someone using this to her advantage, naming the variables in suggestive
ways to either show their symmetry with the things we want to substitute, or
show their function as placeholder variables. I would take the undisturbed swap
statement any day over the hectic mess of triple braces.

- **Pro**

It strikes me that we don't need to substitute just variables, we
could substitute operators, too. Still need to figure out a way to accept them
into the macro in the first place, though.

- **Con**

Does this whole thing remind you of beta reduction in lambda calculus?
Yeah, me too. The thing we run into then is [capture-avoiding
substitutions](https://en.wikipedia.org/wiki/Lambda_calculus#Capture-avoiding_substitutions).
To give a concrete example:

```raku
my $greeting = Q.valToNode("OH HAI");
Q.codeToNode({
    say $s;
    sub foo($s) {
        say $s;
    }
    foo("two!");
}.subst(
    '$s' => $greeting,
);
```

When this AST is injected and executed, it should print "OH HAI" and then
"two!" (because `$s` got substituted once), not print "OH HAI" and then fail to
dispatch (because `$s` got substituted three times).

So the thing about capture-avoiding substitutions can be summarized as "shallow
occurrences are fine, but hands off if nested blocks bind something". This is
not so much a show-stopper as a "must think about this" and "must write tests
that melt brain".

- **Con**

The thing that truly bothers me, though, is this:

```raku
macro example($in1, $in2) {
    Q.codeToNode({
        say $x;
        say $y;
    }).subst(
        '$x' => $in1,
        '$y' => $in2,
    );
}
my $x = 5;
my $y = 42;
example($y + $y, $x);
```

I guess I would expect this code to spit out first 84 and then 5. But I fear it
might well embark on a holy journey of infinite substitution, or maybe
compromise somehow and output 10 and 5 or something. Someone is welcome to
explain to me how my worries are unfounded. But from what I can see, this macro
system suffers from the kind of naming clashes that gensymming seeks to avoid.

So... that's where I'll leave things today. I still think that this fairly
simple macro system is *interesting* in what it teaches us about our own.

By the way, it's quite amazing how close it is to Raku's own macro system.
I've studied a fair number of them at this point, and this one is very close.
Which is kinda weird, with Raku being what it is mixing compile and runtime,
and CoffeeScript being what it is, compiling down to JavaScript and then
getting out of the way.

Maybe we will ditch quasi blocks. Maybe we'll keep them. Either way, it's
clear that we will get rid of the `{{{ }}}` syntax in favor of something else.
This blog post shows the contours of that other thing, but the contours still
remain fuzzy.

## Not addressed by this proposal

Identified in [a previous post](Macros-progress-report-after-a-long-break.html).

- Macro parameters/operands being restricted to expressions
- Macros having a story in grammars/slangs
- Manipulexity of program elements

## Addressed (yay!) by this proposal

- Quasi slices only being usable in term position
- The `{{{ }}}` syntax being universally hated
