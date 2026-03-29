# Macros progress report: quantum yak shaving
    
*Originally published on [28 May 2012](http://strangelyconsistent.org/blog/macros-progress-report-quantum-yak-shaving) by Carl Mäsak.*

Ah, the busy life. I knew April was going to be filled with `$work`, but it
still pulled me away from blogging more than I expected. But things *have* been
moving along with the macros grant work. This post is about that.

As you might remember from [my last macros grant status update](Macros-progress-report-d1-merged.html), I expected to take a yak shaving detour:
  
> Looking ahead a bit, what's up next is D2. Informally, D2 consists of "getting those little `{{{$stuff}}}` thingies to work". We need a way to represent "there's a placeholder here" in the AST, because that's how the ASTs look during the static part of their lifetime (before macro application). It will require a new AST type. As it happens, PAST in nqp/Rakudo is just about to be replaced by the next generation of AST technology, and [*jnthn*++ is just about to start working on that](https://6guts.wordpress.com/2012/03/09/meta-programming-slides-and-some-rakudo-news/).  So it makes sense for me to assist him, since I'm now blocking on the new AST technology landing in Rakudo for my macros work. Aside from blocking, I expect D2 to be quite easy to implement.

This "next generation of AST technology" is called QAST; that's what you get if
you "increment" our current AST format PAST. Of course, as all geeks, we
on the `#raku` channel love backformations.

```
<felher> What does the 'Q' in QAST stand for?
<PerlJam> *P*++
<felher> Okay, what did the P stand for? :D
<tadzik> Parrot, Perl
<masak> felher: the "P" always stands for "Patrick Michaud" :P
<masak> felher: the gradual spread of the letter "Q" in the entire toolchain
        is a reflection on the fact that Patrick Michaud is upgrading from his
        ordinary, impressive self to a superhuman cyborg with capabilities
        that defy physics as we know it.
<masak> or so I've heard.
<felher> Of course! I should have known that! :)
** [Coke] backscrolls, and suggests: Quantum Michaud.*
<masak> that does sound like a superhero. a bit like Dr Manhattan.
<masak> Quantum Abstract Syntax Tree works quite well, too. practically a
        necessity if your language supports junctions :P
```

Let's talk about how QAST actually looks, and what I'm aiming to do here.

So, you have an expression like `my $area := 50`. During compilation, it
parses into a QAST tree looking like this:

```raku
Op :op<bind>
|
+-- Var :name<$area>, :decl<var>
|
+-- IVal :value(50)
```

Yeah, I know, that's almost too simple. (I'm simplifying, but only a little
bit. The remaining details are not important here.)

Now, for macros to work, as I said in the last post, we need a way to represent
"there's a placeholder here". Think about a very similar expression, `my $area
:= {{{$input}}}`. Eventually, the `{{{$input}}}` bit will be executed, the
`$input` will be evaluated, it *better* be found to be an AST fragment, and it
will be spliced into the AST of the quasi, which then gets spliced into the
program somewhere. But there are two phases here:

- The macro is parsed.
- A macro *call* is parsed, and...

- the macro is called,
- the quasi quote has its unquasi placeholders evaluated,
- the resulting AST is returned from the macro, and
- the AST gets spliced into the program code where the macro call was.

Between these two times, we need a form of storage for the yet-unevaluated
`{{{$input}}}`. It's like an ingested pill whose water-soluble shell allows it
to be transported into the stomach before it triggers.

We're making this shell a new QAST node, affectionately referred to as
`QAST::Unquote`.

So the QAST tree in the case of `my $area := {{{$input}}}` would look like
this:

```
Op :op<bind>
|
+-- Var :name<$area>, :decl<var>
|
+-- Unquote
    |
    +-- Var :name<$input>
```

That's where I'm heading right now.

But what I've been working on so far has been all of the more basic bits of
QAST. QAST isn't ready for prime time yet, and getting it there means working
on the QAST compiler. It's great fun, and it gives me an introduction to QAST
that I would probably have needed anyway.

Here's what I've done so far. You can sort of see how *jnthn*++ lets me have a go
at bigger and bigger bits.

- A unary operator [(test)](https://github.com/raku/nqp/commit/53d95cc57c988fce3bcbdf754cfa7f51d0fe14a6), [(implementation)](https://github.com/raku/nqp/commit/7179ed354511e824e45476c53f34ac225325ad05)
- A bigint conversion op [(here)](https://github.com/raku/nqp/commit/6f1b074724a3b28a354ef695538d5b1dc84d75bb)
- Lots of opcodes at the same time [(here)](https://github.com/raku/nqp/commit/0ce175f22ccce4038ee85e7a4a8a4e698fd3af60), [(here)](https://github.com/raku/nqp/commit/d36485eafc917009f57de9b60fed8e5c0e4b8a68)
- Keyed and positional operations [(keyed)](https://github.com/raku/nqp/commit/5d24bc1d40d29e31629314fa313d4ae888948f3c), [(more keyed)](https://github.com/raku/nqp/commit/8fc641598ebd9bd084e3a35470cba590eb5b384b), [(positional)](https://github.com/raku/nqp/commit/b0705d6b926ef84f49f65f76fcdf6451a19ba997)
- Looping constructs [(`while`/`until`)](https://github.com/raku/nqp/commit/694648e1b8045d7ea2f6ef34c5415584dc72c426), [(`repeat_while`/`repeat_until`)](https://github.com/raku/nqp/commit/a6c9a36d597f821ccd292697546abdd65932ac6b)
- `.symbol` getter/setter [(here)](https://github.com/raku/nqp/commit/9e3e240014f2f6e4ee889274cbcecb354689f83c), [(refinement)](https://github.com/raku/nqp/commit/b0b24cfd5744b3ee40c2b165f2d15d32b07d3f99)
- Named arguments [(`call`)](https://github.com/raku/nqp/commit/40e7584f51a48e0ee0057a94bd3ab1f2375eccb7), [(`callmethod`)](https://github.com/raku/nqp/commit/d124e9616cd471bc5cb09e145b2dd6c4a019f74c), [(refactor)](https://github.com/raku/nqp/commit/cd60db0b8767ce06cbc2a031e77baeff48f63f2d)
- Slurpy and flat [(slurpy)](https://github.com/raku/nqp/commit/2b55922b389cd27fb7c5872569add143f6f15316), [(flat)](https://github.com/raku/nqp/commit/b66b2e1f8fa6c1e25f14fc97c6dd905967bc37b8), [(flat and named)](https://github.com/raku/nqp/commit/39a8dad58517f9f3c54c7478238e8bf88492db29)

There's a bit left to go with building QAST. I don't know exactly how much.
When it looks like our kit is relatively complete, I'll turn to implementing
`QAST::Unquote`. I expect to blog again when this has happened.
