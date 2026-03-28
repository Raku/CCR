# Code generation and stone soup
    
*Originally published on [22 January 2010](http://strangelyconsistent.org/blog/code-generation-and-stone-soup) by Carl Mäsak.*

I don't know what kept me away from generating code for so long. Fear and prejudice, perhaps.

I've been trying it the last few days, and I have two things to say. First, it's like learning to program all over again. Remember that sense of power from the early days, when just picking up coding? "Hey, I can program this piece of code to do whatever I want." Well, guess what? That feeling comes back when one starts down on the path to madn... erm, to code generation. Only it's stronger. "Hey, I can program this piece of code to program *that* piece of code to do whatever it wants!" I think I've just discovered meta-hubris. Most likely, I'm not the first to do so.

Second, there's a flip-side to the feeling of power. That other feeling is how you feel when you knit your brows and wish that your neurons would line up a bit better so you could think more clearly about the problem at hand. Who would have thought, that feeling is also stronger when you're suddenly writing two different, entwined and related programs at the same time, in the same file. In my case, the knitted brows turn into an empty stare and a jaw left slackly agape, as I sit there wishing that I was better at context-switching between runloops.

Honestly, I think I expected `eval` to be the source of much programmer confusion, but I have to confess that it seems I underestimated the vistas it opens up when you buy into the idea of generating exactly the piece of code you need for the task (from an AST, say), and then `eval` it into a closure. That's what [the back end of a compiler](https://en.wikipedia.org/wiki/Compiler#Back_end) ends up doing, so maybe I shouldn't be so surprised that it's a versatile technique.

Lately, I've been in the business of squeezing every drop of juice out of the already implemented control flow constructs already implemented in Rakudo. I'm writing a p6regex→p6 compiler, you see. (Yes, that's [a rather crazy notion](https://masak.org/carl/bpw-2009-gge/talk.pdf); thanks for asking.) Along the way, I've often felt the need for not-yet-implemented control flow. This has led me to this hope-inducing maxim:

*Every type of control flow in programming languages is just convenient sugar for `if` statements and `while` loops.*

`if`s and `while`s are the stone soup to which all the rest of our control flow can be added as seasoning. `if`s let you conditionally skip ahead in code, and `while`s allow you to conditionally skip back. That's all you need.

Here are some examples.

- Switch statements are just sugar for chained `if`/`elsif`/`else` statements. Even Raku's `given`/`when` constructs.
- The variants `next`, `last` and `redo`, either with or without a label to affect a less-than-innermost loop, can be desugared to sad boolean-ish variables, plus some `if` statements to appropriately regulate the expression of the code inside the loop. (Yes, go ahead and twitch just thinking of it. That sugar is there for a reason.)
- Subroutines and subroutine calls can be simulated with the appropriate use of a switch statement and an explicit [call stack](https://en.wikipedia.org/wiki/Call_stack) stored in an array variable.
- Even exceptions, or more generally continuations, can be desugared in this way. As soon as you have total control of the call stack, you're free to save and rewind to some previous state to your heart's content.

Aside from the switch statements and unlabeled `next` etc, which already work very well in Rakudo, I've been doing the whole list of desugarings in [GGE](https://github.com/masak/gge) (the regex compiler). The part with the continuations was especially fun. I needed them for backtracking, at least as long as the compiler was only an interpreter.

But then, during a fruitful discussion with *diakopter*++, I was told how to emulate (delimited) `goto`s with a switch and a loop. The idea is quite obvious in retrospect: just keep the current 'label' in a variable, and switch on it in each iteration. Presto! I should have thought of that. I don't even need to [flee to PIR](adding-goto-to-your-raku-programi.html) any more.

I took the idea and generalized it to delimited `gosub`s: instead of keeping the current label in a scalar, keep it at the top of a stack. Define macro-like constructs to push to (`local-branch`) and pop from (`local-return`) the stack. Suddenly I don't need continuations as much.

Result: [this](http://gist.github.com/masak/283799). We send in the regex `/<[a..b]> | <[b..e]>/` on the top line, along with the target string `c` to match on. The program generates an AST, an anonymous subroutine which executes the regex in atomic Raku operations, and finally a match object which indeed finds `c` to be a match.

[Here's](http://gist.github.com/masak/283928) a similar but slightly more involved example. And [here's](http://gist.github.com/masak/284959) one doing captures and backreferences inside a quantified non-capturing group. Isn't that exquisite? (Ok, bad choice of word. Sorry.)

As I said, I wrote most of with a feeling of being not just in over my head, but of being in over my head *twice*. I'm still a bit surprised it works. The runtime compilation seems to introduce a bit of a speed penalty, but (1) it's a one-time cost, since you can re-use the regex object, and (2) I told you it would be slow.

The code-generating work still resides only in a local branch on my computer. I'll push it to `master` as soon as I'm done bringing GGE back to its former capabilities. (**Update 2010-01-24:** Done, and [done](https://github.com/masak/gge/commit/f9e2d4a3d33533270a54a523277d0b9bebd995cc).)

Code writing code. What a concept!
