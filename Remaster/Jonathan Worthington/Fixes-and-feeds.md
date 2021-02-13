# Fixes…and feeds
    
*Originally published on [2010-07-18](https://6guts.wordpress.com/2010/07/18/fixes-and-feeds/) by Jonathan Worthington.*

It’s less than two weeks to Rakudo * now. I’ve been putting most my coding efforts of late – which have been somewhat limited by hotter temperatures than I like and a little RSI – into trying to deal with some of the bugs in RT that will cause people most annoyance. Of course, Rakudo * will have bugs – it’s a viewing point on the way up the Raku mountain. However, I’ve been looking at some of perhaps the most irritating ones…

- A failed multi-method dispatch not even telling you the name of the method you failed to dispatch to, let alone what type it was on or even a list of possible candidates that would match given the right arguments
- Lexical sub calls from attribute initializers not working
- Horribly cryptic errors if you mistype an operator category or use a trait that there exists no handler for
- Custom operator declarations being useless in pre-compiled code
- No mkdir/chdir/way to get a directory listing

All of which are things I’ve now fixed. I’ve also dug into working on pls, the module installer, to get it working on Win32. It isn’t there yet, but it’s closer. I’m optimistic that I’ll have that fixed up in time for R\*.

Many others have been working hard on Rakudo too, of course. *pmichaud*++ has been dominating the commit list with an epic amount of patches of late doing such things as fixing closures and improving our REPL. *masak*++ has been continuing to work away at his GSoC project to give us binary IO and Buf support. *colomon*++ has continued his great work on numerics. *moritz*++ has been doing lots of stuff on the built-in types and functions. *lue*++ got Rakudo supporting binding again. I remember back to the days when Rakudo had so many less contributors, and I longed for more. It’s great that the team has grown – and continues to grow.

Of course, a little work on some more features is hard to resist, and recent list refactors by *pmichaud*++ made getting a first very basic cut of feed operators in place relatively low hanging fruit (the full blown thing is rather harder, mind). So I dug in and did it, and now you can re-write things like:

```` raku
my @foo = 0,5,2,4,1,3;
my @sorted-squares = sort map { $_ ** 2 }, @foo;
say @sorted-squares.perl;
````

Using feed operators as:

```` raku
my @foo = 0,5,2,4,1,3;
@foo ==> map { $_ ** 2 }
     ==> sort
     ==> my @sorted-squares;
say @sorted-squares.perl;
````

Which reads nicely, and lets you write the steps in the order they occur. You can also install “taps” which capture the state at the current step along the pipeline:

```` raku
my @foo = 0,5,2,4,1,3;
@foo ==> map { $_ ** 2 }
     ==> my @unsorted-squares
     ==> sort
     ==> my @sorted-squares;
say @unsorted-squares.perl;
say @sorted-squares.perl;
````

Which produces the output:

````
[0, 25, 4, 16, 1, 9]
[0, 1, 4, 9, 16, 25]
````

The `<==` operator does the same in the other direction, by the way. Of course, the spec says a lot more about feed operators than these basics that I’ve implemented here. But I imagine this covers a lot of use cases – and of course few bits of the spec survive an implementation attempt without some tweaks, so it’s nice to have got the convergence ball rolling on another little bit of it. Plus it’s another “ooh shiny” for R\*.

And with the temperature now somewhat more realistic for sleeping in, I’ll go and get some rest. :-)
