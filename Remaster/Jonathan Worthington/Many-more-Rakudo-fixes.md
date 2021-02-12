# Many more Rakudo fixes
    
*Originally published on [13 February 2009](https://use-perl.github.io/user/JonathanWorthington/journal/38475/) by Jonathan Worthington.*

Since I had no time for Rakudo day last week, this week I'm doing two of them, in order to get caught up a bit! So, here's what I got done today. Some of the tickets I dealt with today weren't just a clear-cut case of "this is wrong", but often needed careful checking against the spec, or clarifications to it; I even rejected one bug report, since it expected something to work that went against the spec (plus there was a failing test for it, which I now removed).

Anyway, here's a list of the things that got fixed.

- Fixed the `is copy` trait on parameters when applied to array and hash parameters; now it does the Right Thing on them. Wrote some tests.
- Fixed a couple of Null PMC accesses that could show up when you had empty blocks (which took some subtle placement, given that if you get it wrong hash composers break...) Anyway, `my $x = -> {}; my $y = $x` and `my $x = do given 5 {}` will just give you an undef in `$x` now, not a Null PMC access.
- Fixed `:x($n)` in `.subst` - both the string and regex variants - to handle the case where `$n` is greater than the number of matches that can be done (it should hand back the original string; before it would do as many as it could and then hand back the string).
- Fixed a couple of different bugs when using the `Whatever` (`*`) when doing smart-matches with arrays, plus added them to the test suite.
- where clauses on parameters in routines would not allow you to just write something to smart-match against, but instead required a block. This is now fixed, so you can write `sub foo($bar where /baz/) { }` and such things.
- Subtypes (anonymous and otherwise) did not enforce that parameters to blocks were read-only by default. This is now fixed and tested.
- Implemented the prompt built-in.
- When you use a role as a class, it should "pun" a class that does that role and nothing else. This is still something we're working on, but today I fixed a missing case: you can now pun a role into a class and use the punned class to inherit from.
- Implemented the special smart-match form for a method call on the RHS, which calls the method on the RHS on the thingy on the LHS and gives a boolean result. This is nice for doing predicate tests on an object using `given` / `when`.

```` raku
class A {
    has $.x;
    method nothing { $.x == 0 }
    method large { $.x > 100 }
};
for 0,100,200 -> $x {
    say "Considering $x";
    given A.new(:$x) {
        when .nothing { say "nothing" }
        when .large { say "large" }
    }
}
Output:
Considering 0
nothing
Considering 100
Considering 200
large
````

I have also reviewed quite a lot of tickets, and closed quite a few that related to issue that had now been fixed (either as a side-effect of fixing other tickets, or thanks to ongoing development). Between the fixes on this Rakudo Day and the one earlier in the week (along of course with the input and help of others) we have gone from over 270 tickets on Wednesday morning to 245 tickets now. So while we've some way from the more manageable size of queue that I'd like - one that I can review fairly quickly and mostly keep in my head - we're some steps closer. :-) Thanks very much to Vienna.pm for funding this work.
