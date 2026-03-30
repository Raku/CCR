# New features, code, and brainstorms
    
*Originally published on [22 May 2008](https://use-perl.github.io/user/pmichaud/journal/36494/) by Patrick Michaud.*

The big headline for this week is that [The Perl Foundation received a very large grant to support Raku development](https://news.perlfoundation.org/post/tpf_receives_large_donation_in), so we're all very excited about that.

I'm also pleased at the increasing number of contributors we have to Rakudo and Parrot.  Some highlights over the past week:

- Moritz Lenz refactored the test harness so that make spectest_regression gives far more usable output.

-Eevee contributed an implementation of the 'reduce' method to List objects.  Thus one can now write:
```raku
##  long version of [+] operator
my $sum = (1..6).reduce { $^a + $^b };
``
- Vasily Chekalkin added a .kv method for hashes, and .sort and .map for lists.
- Tene (Stephen Weeks) continued to improve placeholder variables and topic handling in blocks.
- Jonathan continued his amazing work by implementing private methods, .?, .+, and .* forms of method calls, specifying the name of an invocant in method signatures, the prefix:<^> operator, and much more.

This week I spent most of my hacking time (1) brainstorming; (2) implementing a new Raku-like metaclass system for Parrot, the compiler tools, and Rakudo; and (3) answering questions and closing RT tickets.

Most of the brainstorming I did was on "major pieces" that we will need for implementing Raku on Parrot.  First, thanks to the new metaclass system (described below and next post), I finally figured out how to refactor PGE's base Match, Regex, and Grammar classes to be much less convoluted than they are now.  In the process I also figured out how we can implement *protoregexes* from Synopsis 5, which should improve our parsing speed a fair bit and also allows us to bring Rakudo's grammar much closer to STD.pm.  The change I have in mind still doesn't bring us full "longest-token-matching" capabilities yet, but it will still be a substantial improvement.

PGE also needs a little bit of refactoring for its operator precedence parser in order to properly handle list vs. item assignment.  Since that's one of the highest priorities for Rakudo at the moment, I'll be tackling that this week also.

The other thing that finally started to make sense to me was how to handle variables (mutables) in Parrot.  After discussing the ideas with Jonathan last week, our plan now is to create a Mutable PMC that can serve as the base implementation for variable types like Scalar, Array, and Hash.  It should simplify a lot of things in Rakudo's implementation.

The new Rakuobject.pbc metaclass library replaces the old Protoobject.pbc library that PGE and PCT were using, as well as the various "Perl6Protoobject" classes that Rakudo perl was using.  This means we now have common metaobject model underpinning the various Parrot tools that have Raku-like behaviors.  In particular, every class gets a protoobject, objects in the class have standard Raku methods like .WHAT and .HOW, and the like.

On Tuesday I converted PGE and PCT over to the new metaclass library, and then Jonathan, Jerry Gay, and I did a massive hacking session yesterday to convert Rakudo over to the new library.  Moritz addition of the "spectest_regression" target was a *huge* help to making it all work correctly.  Thanks to everyone's help we were able to make this massive internal change in the span of just a few hours.

I'm quite happy with the final result -- the underlying implementations are all much cleaner and more regular than they were before, and we were able to eliminate a fair bit of cruft that had been accumulating in Rakudo and PCT.  So it was well worth the effort, and will greatly simplify things for people who later work with the compiler tools or Rakudo.

I'll post more details about the Rakuobject library in my next post.  I still also need to write up the details of the PCT code generation changes I made last week, but that's a bit more involved and so I may save that for much later (so I can keep up my momentum on writing code that we really need sooner rather than later).

Questions and comments welcomed as always.
