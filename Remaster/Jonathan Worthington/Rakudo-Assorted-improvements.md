# Rakudo: Assorted improvements
    
*Originally published on [11 November 2008](https://use-perl.github.io/user/JonathanWorthington/journal/37859/) by Jonathan Worthington.*

Today was this week's Rakudo day, but between this and the previous post I'd got a bit of hacking done too. During a mini-hackathon at my apartment after the excellent Twin City Perl Workshop, I got a first cut of the 'is also' trait for classes implemented. This means that you can add extra methods to an existing class (you will be able to do this with attributes in the future, but that's harder to implement).

```` raku
class Foo {
    method test1 { say 1 }
}
my $x = Foo.new;
class Foo is also {
    method test2 { say 2 }
}
$x.test2; # 2
````

The thing that prompted me to implement this is that we want to start writing many built-ins in Raku, but will also want to keep some bits in PIR. We should only define the class in one place, and then add to it in another. This change will allow us to do this. Hopefully it's the last blocker to getting a Raku prelude - *Patrick* is, I believe, going to be trying this out pretty soon. Today I made sure we had a regression test running for this feature.

Afterwards, I looked at sorting out one of our other long-standing issues: you could not write:

```` raku
my Num $x = 42;
````

Because it would fail with a type check error. Num was supposed to accept `Int` values. I fixed this, but the regression tests then started failing for multiple dispatch - an area I'm still actively working on. I boiled the problem down to being the same issue with candidate sorting that was plaguing other code, and dug in to taking a look at what was going on. Some stepping through with the debugger late, I soon found what was going on: we were removing edges from the type narrowness graph too early, and depending on the order in which multis were defined could end up considering two candidates as tied when producing the dispatch order when in fact the type narrowness analysis had determined otherwise. A fix to this later, and that (and no doubt other issues) were resolved. Tests passed, and the patch went it.

I checked on another multiple dispatch ticket quickly, to see if that one too was now resolved. The issue mentioned in the ticket was fixed - at least, it was when I ran it in the REPL, so I marked the ticket resolved. Then I realized the applicable spectest was still failing. A little digging later, I noticed that we were creating subset types a bit too late, moved them to the same time we created classes (which isn't right yet, but that's a harder problem to tackle). I found another incomplete bit of the multi dispatch stuff along the way, but decided to leave that for another time (it's still something of a work in progress). Anyway, long story short, this much now works (and is spectested):

```` raku
subset Even of Int where { $_ % 2 == 0 };
subset Odd  of Int where { $_ % 2 == 1 };
multi sub test_subtypes(Even $y){ 'Even' }
multi sub test_subtypes(Odd  $y){ 'Odd'  }
say test_subtypes(3); # 'Odd'
say test_subtypes(4); # 'Even'
````

I was happy to have another patch from *Chris Dolan*, which fixed up another place where we had a problem with nested namespaces. Applying the patch, however, caused a bunch of spec tests to fail. I was surprised, since it looked good to me. Digging deeper, it turned out to be a code generation issue in PCT. I resolved that, and then the patch worked just great. :-) While doing that, I noticed that there had been some partial breakage to grammars during some other changes. I fixed that too, then made sure we had test coverage for both of these issues, so they don't come back again.

It's always nice to see people playing with Rakudo and doing stuff. japhb has now got some OpenGL things working in Rakudo, and was interested in having the `MAIN` sub supported. The idea of `MAIN` is that, if the program is run from the command line, this is the entry point. There's some really cool stuff that happens in terms of parsing command line arguments and turning them into named parameters - indeed, *Jerry Gay* aka particle has got a grant to work on this, so I didn't dig into that. Instead I just pass them as positionals to `MAIN`. It's a start, and you should have all of the goodies as Jerry reaches that part of his grant in the next couple of months. :-) As a taster:

```` raku
sub MAIN($first, $second) {
    say $first + $second;
}
````

When invoked as "raku test.p6 7 35" outputs 42.

Finally, I did a first cut of `$?PACKAGE`, a variable that tells you what package you are currently in.

Thanks to Vienna.pm for sponsoring today's work.
