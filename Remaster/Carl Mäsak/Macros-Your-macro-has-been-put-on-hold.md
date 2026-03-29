# Macros: Your macro has been put on hold
    
*Originally published on [17 October 2015](http://strangelyconsistent.org/blog/macros-your-macro-has-been-put-on-hold) by Carl Mäsak.*

Yes, it is me. Back to blogging about macros. Feels good.

There has been some vigorous activity around 007 lately. It started around YAPC::Europe, but really lifted off in October, for some reason. It's like 007 started out as a throwaway experiment, but lately it's been coming into its own, driving its own development and spewing out interesting findings as a by-product.

*Side note: I expect to blog extensively about 007. Not today, though. For those of you who feel an irresistible urge to know more, I refer you to [the exquisitely crafted github.io page](https://web.archive.org/web/20151207112451/http://masak.github.io/007/) and [the README.md that has never received a single complaint for beeing too long and rambling](https://github.com/masak/alma/blob/master/README.md).*

Today the topic is the latest by-product to fall out of 007. I'm implementing quasi unquotes right now, and I realized:

**Macro calls can't expand right after they're parsed in a quasi, if the arguments have an unquote in them.**

I'm talking about something like this:

```raku
quasi {
    my-macro 1, {{{$ast}}}, 3;
}
```

Outside of a `quasi` block, as soon as the parser hit that `;` it would whoosh off and call `my-macro`. Clearly that's not possible here, because there's an unquote there, a hole that's waiting to be filled with `$ast`.

So we must wait, patiently, until the `quasi` gets evaluated. (This usually happens when the surrounding macro is invoked. Quasis don't *have* to be found in macros, though typically they are. So we could also call this "splice-time", since likely the unquote is about to be spliced into code.) Once we're in the right scope and on the right instruction, we have an `$ast`, we can fit it into the unquote, and *then*, not before, we can expand `my-macro`.

Frankly I'm surprised this took me so long to realize. I don't seem to be alone; [S06](https://github.com/Raku/old-design-docs/blob/master/S06-routines.pod#Macros) has this to say about when macros are called:
  
> Macros are functions or operators that are called by the compiler as soon as their arguments are parsed (if not sooner).

This could be a confusion of terminology: the `{{{$ast}}}` was *parsed*, but we still don't know what expression it will contain. We still don't know what it *is*.

Maybe it should say something like this:
  
> Macros are functions or operators that are called by the compiler as soon as their arguments are known.

The question arises: should we call unquote-less macros immediately, but hold off unquote-ful macros until the quasi is evaluated? In my opinion, no, for reasons of consistency. Let's just "hold all calls" instead:

**Macro calls don't expand right after they're parsed in a quasi, they expand when the quasi is evaluated.**

Be aware, this is by no means a bad thing. Macros as a whole get more flexible and capable if they're put on hold in quasis. I don't have a full example ready, but imagine we had a data structure (like a HTML DOM or something) expressed as code, and we send it off to a macro. Thanks to macro calls being put on hold, we can now code-gen stuff *recursively* based on the specific contents of the data structure. [That's pretty far out.](http://www.youtube.com/watch?v=g8f_XCH3zmM)

Previously (when macro calls always evaluated right after they were parsed, a design we now know can't work), whenever you put a recursive macro call inside the macro itself, you were hosed as either the parser [disappeared into the black lagoon](https://www.muppetlabs.com/~breadbox/intercal-man/s04.html) as it explored the feasibility of recursion without a base case... or it would just fail outright because we caught that case. Now, instead, you *can* recurse, as long as you put the macro call in the `quasi` block.

So I'm pretty happy with this discovery. (And I'm fully prepared for *TimToady* coming along saying that he knew this already, and I just didn't read the spec in the right way. 😜)

There's more. This finding is part of a larger trend where *parsing* gets un-tangled from another, later process that I don't yet have a really good name for. Within the scope of this post, let's call it *checking*... and I'll reserve the right to call it something better once I have a better name. Suggestions welcome. ("Checking" is slightly unfortunate, because it sounds like it would happen at `CHECK` time. Some of these things, such as the macro expansion, need to happen before that.)

Some random examples of checking:

- You declare a variable `$COMPILING::x`. As the quasi is evaluated, we need to check whether to report a "potential difficulty" when `$x` was already declared in that scope. Same with functions, classes, etc.
- A synthetic variable reference `$x` was injected into an unquote, and now we need to check whether it actually refers to something in the mainline.
- Some stuff gets injected into a parameter list, and we need to make sure that the parameter list still is valid structurally.

Many things that we consider to be part of parsing turn out to be part of checking, when you start to think about it. Taking quasis seriously leads to needing to tease parsing and checking apart. Some parts of checking we still want to do ASAP, interleaved with parsing. (For example: I'd expect to get an immediate "not declared" error if I typo'd a variable inside a quasi. Shouldn't have to wait until I call the macro.)

The rabbit hole goes deep on this one. If we expect quasis to have unquotes for operators, then we can't even reliably parse an expression into a *tree*, because the exact structure of that tree depends on the precedence and maybe associativity of the operator we haven't injected yet! This leads to the uncomfortable question of what a quasi really *is*, if it isn't a Qtree representation of some code. In this case at least, it seems the best we can do is store the sequential order of terms and operators, so that we can expand them into the correct tree upon checking. (And this needs to be reflected somehow in Qtree introspection.) This *should* worry you: producing that tree is what parsing traditionally does. But here we provably can't: heck, the operator we end up injecting might not even be *defined* yet.

Despite all, I'm hopeful. I'm happy quasis force macros to late-bind, because that makes macros more useful. I'm curious where the whole parsing/checking distinction will lead. The stuff with the operators looks challenging, but that's an improvement over what we had before in that slot, which was "what huh wait I don't even".

## Not addressed in this prop... hey, wait

This isn't a proposal. It's just the harsh, undeniable reality. I find that the five-or-so things I usually bring up as addressed or not addressed aren't really relevant here.

However, let's do a quick summary, since it's been long since I posted about this:

- **The `{{{ }}}` syntax being universally hated**

&mdash; Got some ideas. Watch this space.

- **Quasi slices only being usable in term position**

&mdash; 007 is currently breaking new ground on this.

- **Macro parameters/operands being restricted to expressions**

&mdash; This one is still a bit unclear, but there's hope. Maybe a good enough `is parsed` will help.

- **Macros having a story in grammars/slangs**

&mdash; Ummm, um. Oh! Look! Squirrel!

- **Manipulexity of program elements**

&mdash; 007 is currently breaking new ground on this. In brief, Qtrees are living up to the hype.
