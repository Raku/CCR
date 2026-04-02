# More nom features and spectests, still 5x faster than master
    
*Originally published on [2 July 2011](https://pmthium.com/2011/07/more-nom-features-and-spectests-still-5x-faster-than-master/) by Patrick Michaud.*

Progress continues on the [nom branch of Rakudo](New-NQP-repository-new-nom-Rakudo-branch.html).  As of this writing we’re up to 89 spectest files and over 1000 passing spectests, which is a good improvement from just five days ago.  

We continue to see that nom performs much better than the previous version of Rakudo.  [Moritz Lenz added enough features](https://perlgeek.de/blog-en/perl-6/how-fast-is-nom.html) to be able to run the [mandelbrot fractal generator](https://github.com/colomon/mandelbrot/blob/master/bin/mandelbrot-color.pl) under nom, so we can compare speeds there.  Under master a 201×201 set took 16 minutes 14 seconds to run, in nom it “naively” took 4.5 minutes, and with some further optimizations Moritz has it running in 3 minutes, for a factor five improvement over the existing master branch. And there are still many more compiler-level optimizations that remain to be worked on. 

In the past couple of days I added the metaoperators back into nom. Furthermore, the new implementation is far more correct — metaoperators such as &infix:<X> and &infix:<Z> can now handle multiple list arguments instead of just two as in master.  We still haven’t added back the hyperoperators; I plan to do that in the next couple of days.

Jonathan has been attending the [Beijing Perl Workshop](https://conference.perlchina.org/) this week; his presentation slides are now available at [http://jnthn.net/articles.shtml](https://jnthn.net/articles.shtml).  Videos may be available soon.  Even with his travels, Jonathan has continued to implement some of the needed lexical and role support in nom, so that we’re generally unblocked in making needed progress in the branch.

Carl Mäsak wrote [a post introducing the Raku type system](../Carl\ Mäsak/June-24-2011-Types); after reading an early draft of his post we discovered that several of the builtin types (Code, Attribute, Signature, Parameter) have been mistakenly implemented as subclasses of Cool.  We’ve now fixed this in nom; we may or may not fix it in master.

Indeed, we’re already starting to phase out the master branch altogether.  Yesterday I made a commit to master that effectively freezes it to always test against a specific revision of the spectests.  This means we’re free to fudge and adapt the tests to the needs of the nom branch without concern for what it might do to testing in the master branch.

Speaking of tests, Moritz gave me some useful shortcut links for viewing different reports in our RT ticket queue.  I’ve now set up a page on rakudo.org where we can collect these report links and describe how the ticket queue works.  One of the more useful links is RT testneeded; this link shows a list of tickets that can be closed as soon as someone is able to confirm (or add) an appropriate test in the spectests.  Writing tests is fairly easy, if you’re interested in helping with Raku development, this can be a good place to start.

Here’s a summary list of features added to the nom branch since my last posting (five days ago):

-  Complex numbers and numeric operator fixes
-  Complex numbers have two native nums instead of Num objects
-  Rat literals
-  List.pop, List.reverse
-  Initial LoL (list of lists) implementation
-  map and grep
-  Many string methods and functions
-  metaoperators:  Rop, Zop, Xop, !op, op=, [op], [\op]
-  infix:<===>, infix:<eqv>
-  Hash and Array hold Mu values, scalars default to Mu constraint
-  Fixes to Configure.pl and –gen-parrot=branch
-  Proper handling of $_, $!, and $/
-  Improved exception handling and reporting
-  Hash and List slices, including autotrim on infinite indices

In the next few days I plan to have regexes working in nom, finish off the metaoperators, and improve string-to-number conversions (including radix conversions).

For people looking to learn some Raku, to help others with learning Raku, or to do a bit of both, Bruce Gray has started “[Flutter](https://github.com/Util/Flutter)” — a suite of “micro-demonstration screens” for Raku. Essentially each screen introduces or demonstrates a Raku feature or concept.  Flutter is still in the embryonic stage, so it could use both content and implementation improvements and I’m sure that patches and pull requests will be extremely welcome.

We can still use help with triaging spectests and other tasks, if you’re interested in hacking on code or otherwise helping out, email us or find us on IRC libera.chat/#raku.  We can also use help with adding useful links and developer information to rakudo.org, if you’re inclined to do some of that.
