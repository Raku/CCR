# Mildew, Sprixel, Vill: In praise of the alternatives
    
*Originally published on [29 January 2010](http://strangelyconsistent.org/blog/mildew-sprixel-vill-in-praise-of-the-alternatives) by Carl Mäsak.*

Not all of Raku is Rakudo. Well, when I use Raku, it is. But I'm hoping 2010 will change that. We have a few other implementations out there, which fall in the "small but promising" category.

## Mildew

From the README:

> Mildew is an experimental implemention of Raku, written mainly in Perl5.  It is named in the tradition of 'yeast', 'slime' and 'mold', which were/are related projects.

I can't say I've ever understood the idea behind naming projects after icky things, but I like the projects as such. They seem to generate a kind of "basic research" which strengthens the foundations of Raku. The decade-old project has always been about attacking the enormously big task of implementing Raku from different angles — and I like the angle *pmurias*++ and *ruoso*++ are taking.

> Mildew uses the 'viv' parser and the STD.pm grammar to convert Raku
source code into an Abstract Syntax Tree.  An AST is a data structure
that describes what the Raku program is meant to do.  Mildew contains
various experimental backends selected by the -B and -C switches to
export or to execute the code in the AST.

Mildew targets both SMOP (written mostly in C) and the Google V8 JavaScript compiler.

## Sprixel

From the README:

> sprixel (anagram of perlsix): viv and STD.pm parse Raku source, emitting an Abstract Syntax Tree in YAML, then sprixel walks the AST using its trampolined, stackless, continuation passing style interpreter written in JavaScript and executed by Google's V8 JavaScript compiler and runtime engine.

I know *diakopter*++ is playing around with both JavaScript and C♯ implementations of Raku rule engines. That is also an area which excites me, and where I'm glad people are making headway.

## Vill

From the README:

> 'vill' is the ugly temporary name of this project that connects 'viv' as Raku front end to LLVM as code generating back end.  It sounds too much like 'vile', or mock German 'will', but it fits.

Heh.

> Unlike other Perl implementations such as Pugs, Rakudo, Sprixel and Mildew-js, 'vill' produces native executable files. [...]

Whoa! That's potentially *very* attractive.

> The slowest part of 'vill' is 'viv', because that runs as a separate Perl child process.  The medium term plan will be to use the STD.pm grammar, but replace the 'viv' parser with a new one to be written in C.  [...] If the dependency on 'viv' can be removed, the ugly 'vill' name will no longer be appropriate, and it will be time to think of a better one [...]

I'm actually hoping I might be able to help with the C-based parser.

## Conclusion

Rakudo is the implementation that shows up on the radar of most outsiders right now. (And with good reason.) But much exciting work is going on in the background, with implementations like mildew, sprixel and vill.

I'm sure this will come off as almost self-evident, but I'll say it anyway: the moment an alternative implementation will cross a threshold into the area of the *really* interesting, is when it provides a significant chunk of Rakudo's functionality (which is saying quite a lot), together with some feature that Rakudo doesn't have. Given Rakudo/Parrot's current performance, the most obvious feature would be speed. But it might also be something else, such as a bridge to Perl, or a very solid metamodel. The more ground-shaking the new feature, the less important will be the delta between the alternative implementation and Rakudo.

At the very least, I think one of the above implementations will pass through the Mach 1 barrier in 2010, and attract a serious user base, and more developers. I'd love for Rakudo (and Pugs) to have some company up there among the "big" implementations.

Exciting times!
