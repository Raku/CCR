# Macros progress report: after a long break
    
*Originally published on [2 October 2014](http://strangelyconsistent.org/blog/macros-progress-report-after-a-long-break) by Carl Mäsak.*

I am going to make no pretense at covering everything here. My goal with this post is simply to bring us largely up-to-date with the current ideas about macros in Raku and possible directions we're taking. A post about this has been sorely missing for a while now.

In order not to retread old ground, this post assumes that you have read [day 23's post about macros](https://perl6advent.wordpress.com/2012/12/23/day-23-macros/) in the 2012 Raku Advent calendar. That post remains a very good high-level summary of all the work so far.

## Current status

In brief, D2 has been completed, and the half-way point of the grant has been reached. For convenience, here are the four implementation deliverables from the [grant application](http://news.perlfoundation.org/2011/09/hague-grant-application-implem.html):

- D1: declare and call macros
- D2: splicing
- D3: hygiene/unhygiene
- D4: delayed declarations

D3 and D4 still remain. In fact, D3 is "half done" too, as hygiene naturally fell out of the way we did D1 and D2. Though that does mean that unhygiene will be the comparatively tricky one to get right.

## Snag: what people really want

Over the years, I've noticed three odd things about Raku macros:

- Many trivial uses of macros can be written as a subroutine instead. (And the compiler/optimizer will take care of things like inlining and dead code elimination.)
- Many Raku regulars keep using phrases like "it's really a macro" and "it's macroish" in ways that don't conform with current spec.
- People who are trying out macros for the first time tend to try one specific thing &mdash; I'll get back to which one &mdash; that simply doesn't work.

From these three pieces of data, I conclude the following: **we're implementing the wrong thing**. (And I didn't even mention "Everybody hates the `{{{ }}}` syntax.")

Let me qualify that a bit. We do want macros, in the sense that we do want a construct that can ["generate, analyze and typecheck code"](https://scalamacros.org/). However that construct ends up looking, we want it to be hygienic, and composable, and to cover the use cases people tend to expect macros to cover.

The implementation outlined in [S06](https://github.com/Raku/old-design-docs/blob/master/S06-routines.pod#Macros), with its quasiquoting and its focus on lexical scopes, tries to be a good citizen by rising above the horrid level of C macros and Perl source filters. The intention is admirable, but the result ends up being not more than the sum of its parts, but less.

Just like textual C macros, S06's macros focus on generating code. That is, the typical use case is "the macro desugars to some code". There's no rich awareness of the context in which the macro is evaluated, nor of the pieces of program structure that are passed to the macro (through parameters) or created within it (through quasiquoting). The `AST` objects being passed around are basically tiny useless black boxes rather than (say) awesome hyperintelligent extraterrestrial self-assembling nanorobots with X-ray vision and a sense of tact and grace. This fact puts a huge damper on the "analyze and typecheck" part of things.

People have proposed a way to fix this: just make the `AST` objects transparent, and allow read-write access to the underlying QAST. This was my first thought as well three years ago when I started thinking about these things, but I now believe that will lead to macros being largely horrible. We can talk more about the exact reasons for this in a later post, but in summary they are: QAST is an implementation detail internal to nqp. It's brilliantly designed, but its target audience is the compiler. Even though macros run during compilation, the macro author is not a compiler, and would not enjoy having to think like one. The abstractions inside of QAST cut up territories very unlike the abstractions inside of a macro author's head.

But it's worse. S06 has two examples of unquotes in quasiquotes, and both of them are inside of expressions. The premise here is that a quasi-unquote splices an expression into a bigger expression. Let me repeat, because this is important: **expression**, as in `EXPR`, as in S03 and operators and precedence. So far so good.

Now we come to the thing that all macro newcomers (rightly, in my view) expect to work. It's something like this:

```raku
sub {{{$subname}}}() { ... }
class {{{$classname}}} { ... }
```

There are two reasons this does not work.

One: the unquotes are not standing in for an expression, nor for a part of one. In this case, they are standing in for an identifier (that's being declared) **in a syntactic form**. That's indeed not an expression; if it were, then it would be valid to write `sub 2 + `2` { ... }`. (It's not.)

Two: recall the way an AST macro is invoked. The parser parses the macro name and all the arguments, builds ASTs of all the arguments, and invokes the macro, passing those ASTs. At no point during the parsing of the macro argument does the parser acknowledge that it's parsing a macro. Therefore, just like with a normal subcall (or operator expression), the only thing the arguments (operands) can be is expressions. [☹](http://www.sadtrombone.com/).

So we're left in the situation where the spec only allows unquotes inside expressions, but most of the useful and interesting cases of macros that people naturally come up with want to use unquotes in places that are not expressions.

## Rethinking macros

We're in a situation where we need to do two things with Raku macros to get them to live up to their potential and deserve to make it into Raku.0:

Firstly, we need to **let the macros establish themselves** in the evolving story about Raku slangs. Thanks to *jnthn*++, slangs have rudimentary support in Rakudo already. Thanks to *FROGGS*++ and the `v5` slang, we know a whole lot more about the requirements and limitations of slangs. Macros need to fit into this, and provide a kind of bridge to slangs. (Have too many routines and types? Put them in a module! Have too many macros? Turn them into a slang!) As part of this, macros even need to establish themselves in the story of grammars and parsing. S06 was written a year after S05, but the real maturation of grammars happened half a decade after that.

I want us to have the cake and eat it. I want syntactic macros (whether hygienic or not), but I also want to define special forms in the language, on the same level as `if` statements. Special forms almost universally bend TTIAR somewhere. Why can't our syntactic macros do that? Why do we have to resort to textual macros for that? Unacceptable.

*If you want some of my raw thought-dumps about these things, I refer you to the IRC logs. Specifically, look [here](https://irclogs.raku.org/perl6/2014-09-07.html#08:04) and [here](https://irclogs.raku.org/perl6/2014-09-09.html#12:27-0005).*

Secondly, we need an abstraction representing a **program element**. Something that can be traversed, filtered, inspected, and transformed. Want a macro that flips the blocks in an `if-else` statement? The macro lets you get hold of an object of type `Q::IfStatement`, and it has easily discoverable methods to do the rest. Meanwhile, in a parallel universe, a ragged, hapless copy of yourself scowls at a `QAST::Op` node with its `$!op` attribute set to `"if"`, trying to make it do the right thing.

Zooming out and looking more generally, we need a "third level" to our program structure. The first level is the parse tree (or "concrete syntax tree"), generated by the Raku parser itself. The second level is `QAST`, generated by actions firing as parser rules complete successfully. QAST is what gets sent on through the optimizer and eventually gets serialized to backend output. But what we need is one level above that: something that captures the programmer's concept of the program structure. We need "QAST but without the AST". Let's call it "Q" or "Qtree" so we can talk about it. If you want a sneak peek at this, have a look at what IntelliJ does with [PSI element types for Java program elements](https://github.com/JetBrains/intellij-community/tree/master/java/java-psi-api/src/com/intellij/psi). (And many other languages, such as Python and Ruby and JavaScript.)

*Again, IRC infodump: [here](https://irclogs.raku.org/perl6/2014-08-22.html#19:48).*

In the subsequent macro grant posts, expected at least once every two weeks from now on, I explore these topics further. I intend to explore existing macro systems, drawing examples and inspiration for mechanisms from things like Scheme, Scala, Racket, Clojure, AngularJS, and sweet.js.

Here's to macros! 🍸
