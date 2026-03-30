# Even more fun from raku and Parrot
    
*Originally published on [3 January 2008](https://use-perl.github.io/user/pmichaud/journal/35272/) by Patrick Michaud.*

Progress continues on Raku for Parrot and the Parrot compiler tools.  Things are starting to happen so quickly now that it's hard to remember them all for these journal posts.  I'll need more frequent posts.  In the meantime, if anyone notices that I've overlooked something newsworthy then let me know and I'll add it to the next post.

I think the biggest splash over the past couple of days appears to be that we now have a "make raku" target that directly creates an executable binary for raku on Parrot.  So now someone with a working Parrot can do:
```
$ make raku
$ ./raku hello.pl
```

There are still some limitations -- in particular, the raku executable is dependent on files in the Parrot build installation (the binary requires a few hard-coded paths to Parrot libraries).  Fixing this is likely going to require getting Parrot's 'make install' target to work properly, which is a long-standing issue of its own.  So, it's not a perfect solution yet.  Also, the process for building the standalone executable may not work on all platforms -- we need more feedback from different platforms.  Still, being able to treat raku as a standalone executable goes a long way to making it easier use and experiment with.

The magic for creating an executable binary from Parrot bytecode comes from chromatic and Jerry Gay's pbc_to_exe script.  A number of important contributions and improvements also came from Will Coleda, Bernhard Schmalhofer, Andy Lester, and Francois Perrad.  It's impressive to see how quickly it all came together.

In fact, based on this Andy Lester is *already* [asking for the "-e" option to be implemented in raku](https://github.com/Raku/old-issue-tracker/issues/45).  And the question about Raku standard command line options also came up during today's Raku design team meeting.  Larry says he will be looking at what options every Raku implementation should be providing, and that will give us something solid to work from.  In the meantime someone will likely implement the '-e' option.  :-)

Yesterday I added the "defined-or" operator and the @*ARGS array to the raku compiler, so now the [Towers of Hanoi example](http://www.rakufoundation.org/raku/index.cgi?tower_of_hanoi) works with raku on Parrot:
```
$ ./raku hanoi.pl
ndisks = 3
AB
AS
BS
AB
SA
SB
AB
$
```

In other news on raku compiler improvements, Jonathan Worthington added a preliminary version of 'given'/'when', and even performed the commit "live on stage" at the Israeli Perl Workshop.  Jonathan has also added more to his Junctions implementation.  Personally, I had feared that Junctions was likely to be one of the more difficult pieces for us to add -- especially autothreading support -- but based on Jonathan's implementation and some IRC conversations with him I think it might go a lot easier than I originally expected.  Time will tell...

Jonathan also implemented a 'set_outer' method that should let us implement a workable `eval` function, but I think we'll also need a couple of PCT/PAST improvements for it.

Jerry Gay has been adding radix conversions to raku, and today started on named/optional/slurpy parameters to subroutines.  He's already implemented the same features for NQP, so he has a good model to work from when doing the raku implementation.

Yesterday I started a long-awaited refactor of the "official Raku test suite", which is currently housed in the Pugs repository.  Essentially I'm hoping to reorganize the tests along the lines of the chapters and sections given in the Synopses and the Perl camel book, to make it easier to locate tests and determine where to add new ones.  So far I've only done a few of the operator tests from S03, but have notes about other tests that belong in S02 and S04.  As part of refactoring the tests into more a more sane organization, we're also verifying that they are still correct with the latest synopses and that all of the details are covered.  Where things need more work, we're adding "XXX" notes so that others can come along and improve the tests even further.

The "make spectest" target is now active again in raku on Parrot, and as more tests make it through the refactor we'll be adding them to the spectest suite in Parrot.  Of course, others are very welcome to contribute tests, help with the test refactoring, and the like.  All you need is a Pugs commit bit, which is very easy to obtain.

Larry, Jerry, and I also had an excellent conversation last night about ways different Raku implementations can mark the test suite with todo/skip flags without stepping all over each other.  I very much like what we ended up with... but since this post is already getting a bit long I'll describe it all in a subsequent post (probably also when there are some examples to point to).

The thing I haven't done yet that I want to do is to have an example of using Raku to create built-in functions for the raku on Parrot compiler.  If anyone can write up an example of a Raku builtin function or method that is itself written in Raku, then I'll be very glad to get it integrated into the compiler so we can use it as a template/example for others to follow.

In other news, Will Coleda is working on a web interface to quickly summarize tickets in RT that are of high-priority to the raku compiler (or other efforts).  When it's finished I hope it will make it easier for us to point people to where effort is needed.

Jeff Horwitz has written an interesting article on the Parrot wiki that describes how mod_parrot works.  It's worth a look if you'd like to see more about mod_parrot, especially since mod_parrot integrates the whole Parrot stack from HLL languages down to embedding and NCI interfacing.

In fact, this is a good place for me to point out that the Raku wiki has also gotten received quite a bit of reorganization and improvement this past week; many thanks go to Conrad Schneiker, Aaron Trevena, Herbert Breunung, and others for the updates.  Please feel free to help us flesh it out -- even just asking questions or saying "this is confusing" is very helpful!

Finally, in the -Ofun department:  Tonight Will Coleda used my "create a Parrot language" script to start a LOLCODE implementation for Parrot.  Then Simon Cozens (lathos) extended it to include variable support.  Given that it didn't even exist four hours ago, it's a pretty good demonstration that Parrot's compiler and language tools are working the way we want.

**Update:** Simon has also [blogged about his experience](https://web.archive.org/web/20080229042235/http://blog.simon-cozens.org/post/view/1323) in writing compilers for Parrot using Raku.

You can see that there is a huge amount of activity taking place with Raku and Parrot; in fact, most of what I've written about here has occurred in the 72 hours since my last journal post (December 31).  And there's undoubtedly some stuff that I've overlooked.  Next on my list of things to work on is more test suite improvements, implementing `eval`, addressing a few RT tickets, making sure that people working on the compilers can continue to be productive, and adding more documentation and details so that others can more easily join in the fun.

As always, more to come...
