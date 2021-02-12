# Lexical Subs In Rakudo
    
*Originally published on [2 April 2009](https://use-perl.github.io/user/JonathanWorthington/journal/38741/) by Jonathan Worthington.*

The big bit of progress today was that I got lexical subs working.

```` raku
{
    my sub `foo` { say "pes" }
    `foo`; # pes
}
`foo`; # An error; sub is lexically scoped in the block
````

Actually, getting that far was the easy bit. The harder bit was making leixcally scoped multi subs work, which is a good deal more interesting. That's because rather than a wholesale replacement, you have to clone the set of outer candidates and then add the new ones. That is:

```` raku
my multi `bar` { say 1 }
{
    my multi bar($x) { say 2 }
    bar; # 1 - from the outer candidate
    bar('man'); # 2 - from the inner candidate
}
bar; # 1 - from the outer candidate, which is still visible here
bar('girl'); # error - inner candidate out of scope
````

Of course, if that block was a closure or something we'd invoke many times (e.g. a sub with many lexically scoped inner multi subs), we really don't want to have to do all of the copying and augmenting of the outer candidate list per call (that'd be a bit of a performance killer). So some of the effort went into making sure we persist those. Plus while we had tests for single-dispatch lexical subs, we hadn't any for multi-dispatch lexical subs, so I wrote a bunch.

I probably mentioned recently that I've been working on import stuff, and that actually we're not doing it right just yet because we import into the package by default and not the lexpad. This bit of work on lexical subs is one step towards being able to do it right. However, there are other issues. Another big blocker that Rakudo users may be familiar with is that this:

```` raku
my $x = 5; class A { method x { say $x } }; A.new.x
````

Doesn't work. The main reason we couldn't get it to work was due to a fairly long-standing Parrot bug. Today I got out my trusty C debugger and set about hunting the pesky thing down. Eventually I did and committed a fix to Parrot and a test, which was great apart from it only revealed another separate problem somewhere else that got in the way. After a long discussion with *Patrick*, we're not at a solution for that one yet. We understand it just fine, but the solution (and making sure it's a good one) will take a bit more thought. But anyway, I'm hopeful that we will nail this bug in the near future.

I also did a few other more minor things.

- Found we were passing half of unlink.t, so fudged those we failed and added it to the list of spectests that Rakudo runs.
- Made `print`, `say`, `printf` and so forth use `$*OUT`, so re-binding it to something else works. Added a spectest for that.
- I got `START` statements working recently. We almost passed all of the tests, but had to skip those that required `START` blocks to be usable as terms as well as statements. Today I did that final step, and un-fudged four more tests.

Much thanks to Vienna.pm for funding today's Rakudo work.
