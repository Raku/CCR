# "It's beginning to look a lot like Christmas..."
    
*Originally published on [10 December 2008](https://use-perl.github.io/user/pmichaud/journal/38058/) by Patrick Michaud.*

A *lot* has happened with Rakudo Perl over the past few days.  The biggest news is that Rakudo is now supporting list assignment and list slices.  (Hash slices will show up in a day or two.)  Now that we have those features working, I can finally start to say that Rakudo Perl is starting to feel to me like, well, *Raku*.

So, while we're still a good distance from an true Raku release (a.k.a. "Christmas"), today we at least seem to have a tree with some shiny ornaments on it and even a few presents under the tree.  :-)

Getting slices and assignment to work required a fair bit of refactoring of the base classes and operations, and I also did a lot of code cleanup which really needed to be done anyway.  While cleaning up assignment code I also fixed up the assignment metaoperators (things like `+=`, `*=`, etc.) so that most of them are automatically generated instead of written by hand.  Then for fun I went ahead and added some basic Raku reduction operators.

I'm sure some are asking "What in the world are 'reduction operators'?"  Well, they are another of the many shiny new presents Raku is bringing us.  A reduction operator is indicated by square brackets, and it turns an infix operator into a list operator.  For example, while infix:<+> adds only two operands, the `[+]` operator will add together all of the elements of a list.  Similarly, `[*]` means "multiply all of the elements of the list", and `[<=]` returns true if the elements of a list are numerically sorted.

```raku
$sum = [+] @x;                      # sum all elements of @x
$smallest = [min] $a, $b, $c, $d;   # minimum of $a, $b, $c or $d
$issorted = [<=] @x;                # true if @x is numerically sorted
$fact = [*] 1..$n;                  # $n factorial
```

Today Jonathan extended some of the work I did on reduction operators to add more of them, and then added many of the infix hyperoperators (e.g., >>+<<) and cross operators.  See [Jonathan's post](../Jonathan\ Worthington/Hyper-cross-reduction-operators-IO-tweaks-and-more..html) for more details about those.

All of us working with Parrot and Rakudo are excited at the progress being made with Rakudo -- as of tonight we're closing in on 4,900 passing spectests, and I'm hoping we can make it to 5,000 by Tuesday's Parrot release.  It really means I need to find a day to review the existing tests and RT tickets for things we're really passing or could be passing with just a little bit of effort.

I'll also be working to update our milestone and roadmap documents, and try to present a much clearer picture of where things presently stand for Rakudo.

On a Parrot note, this past weekend I also made some improvements to PGE and Parrot that give us a ~20% improvement in parsing and code generation speed.
