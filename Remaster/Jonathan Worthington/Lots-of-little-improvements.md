# Lots of little improvements
    
*Originally published on [30 June 2009](https://use-perl.github.io/user/JonathanWorthington/journal/39196/) by Jonathan Worthington.*

I'm back from a nice break in Italy and have been digging back in to Raku stuff again. Today I've been doing a Vienna.pm-funded Rakudo day, and here's what I got up to.

First off, I went for a look through our RT queue. We now have over 400 tickets that are either new or open. While on the one hand that means we've a lot of work to do, it's also a sign that people, more and more, are playing with and exercising Rakudo. In just browsing through it, I found a bunch of things I could work on and hopefully resolve fairly easily during the day, and also another bunch of things that were already resolved. Just spotting the latter allowed me to mark 3 tickets resolved.

A couple of the things I worked on related to subtyping. Of note, the standard grammar accepted:

```` raku
subset Foo of Int;
````

Without requiring a `where` clause. Rakudo now also accepts this, and our parsing is a little closer to STD.pm too (we parse traits on subtypes, but we don't do anything with them just yet). Next, I got Rakudo to support a neater syntax for declaring anonymous subtypes in signatures. If you just want to match a specific value, you can write the value in the signature, and that's it. For example, here is yet another way to do factorial (a recursive version).

```` raku
multi factorial(0) { 1 }
multi factorial(Int $n) { $n * factorial($n - 1) }
say factorial(5); # 120
````

A signature `:(0)` is equivalent to `:(Int $ where 0)`. This means that it will sort in the candidate list with `Int`. More generally, any literal value in where will get a nominal type based on the `.WHAT` of the value and have the value made into an anonymous subtype, so the signature `:("tava")` is just like `:(Str $ where "tava")`. I added some tests for all of this too.

*Lyle*++ had sent in a patch a while back for `$*CWD` and `chdir`. I took a look at these today. The `$*CWD` one looked pretty good, so I applied that with just a minor tweak. The `chdir` one needed some more attention and fixing up first, but I got that applied and extended the tests to better exercise it. Then I got both test files added to spectest.data. So now `chdir` and `$*CWD` are both functional. Here's some play with them in the REPL.

```` raku
 > my $fh = open("spectest.data", :r);
Unable to open filehandle from path 'spectest.data'
in Main (<unknown>:1)
 > say $*CWD;
C:\Consulting\parrot\trunk\languages\rakudo
 > chdir "t";
 > say $*CWD;
C:\Consulting\parrot\trunk\languages\rakudo\t
 > my $fh = open("spectest.data", :r);
 >
````

We had a couple of tickets relating to the interaction of //= and state variables. A little investigation, some discussion on #parrot and a fix later, I was able to unfudge tests and mark those resolved. A small inheritance bug was a similar story.

Finally, in preparation to improve type check failure error reporting and resolve at least one ticket in that area, I factored all type check error generation out to one routine, which we now call consistently. That means errors that previously missed out mentioning the expected and received types now do so, and the other issues I can fix - on some future Rakudo day - in one place, and everywhere that reports such errors will benefit.

In the course of the day, I also discovered a couple of other tickets that I had opened up to investigate at the start of the day were also already-fixed issues, so I made sure we had proper test coverage and got them closed up.

So, a pretty productive day. Thanks to Vienna.pm for funding!
