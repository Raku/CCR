# Today's Rakudo Progress: Object Initialization And Grammars
    
*Originally published on [1 May 2008](https://use-perl.github.io/user/JonathanWorthington/journal/36308/) by Jonathan Worthington.*

Today's work has been a mixture of refactoring and clean-ups that had been on the want list for a while, but just hadn't happened, as well as making some new things work.

First, the initial work I did on types attached them to variables, but what we really needed was a more general way to attach properties. Therefore, there is now a hash of properties instead, where we can stash other stuff.

Next up, I had based pairs on the Parrot Pair PMC, though as Patrick pointed out it's so far off being right for Raku (for example, it's mutable, the Raku one isn't) that we might as well just have our own. Dropping the Parrot Pair PMC and doing that took me all of ten minutes of work, and we get the semantics of pairs a bit more correct too. So that's much cleaner now.

A few days back, dakkar sent in a bug report regarding inheritance. It was almost correct code, but didn't work on Rakudo, since initialization of parent attributes was not yet implemented. I've now implemented this, and I'll borrow the example from the bug report to demonstrate it.

```` raku
class Foo {
    has $.x;
    method boo { say $.x }
}

class Bar is Foo {
    method set($v) { $.x = $v }
}

my Foo $u .= new(:x(5));
$u.boo;                    # 5

$u= Bar.new(Foo{ :x(12) }); # This is what now works
$u.boo;                    # 12
$u.set(9);
$u.boo;                    # 9
````

This is not some magical hacky syntax just to make constructors work; you can use it in the general case to associate some vivification data with a proto-object, which gives you a copy of it back with the data attached. It's a bit like currying the object instantiation. So after making the above work, it wasn't much more work to get the following working.

```` raku
class Foo { has $.x }
my $foo42 = Foo{ :x(42) };
my $test = $foo42.`new`;
say $test.x; # 42
````

Note that the original `Foo` itself isn't changed. We'll have to revisit this again later, because the way I've done it now doesn't have the lazy semantics it's eventually meant to have. It makes the common use case work, though.

With some time spent on objects, I moved onto some improvements to regex stuff. The upshot of this is that you can now use grammar to group regexes into a namespace.

```` raku
grammar Test {
    regex Load { \d+s };
    rule Loads { <Load> of <Load> };
}
if "100s of 1000s" ~~ Test::Loads { say "yes" }
yes
````

Note that this is just the start of grammars; inheritance doesn't yet work and you can't smart-match against them yet. It's a stop forward, though.

If you're an avid Rakudo follower, you'll have noted that `regex`, `rule` and `token` all (wrongly) did the same thing before today. I've fixed that too now (there was some behind the scenes work in being able to pass options to the compiler that will be useful elsewhere, as to users of the Parrot Compiler Toolkit in general). In a nutshell, token and rule don't backtrack, where as regex does, and additionally rule translates spaces to the <ws> rule, whereas normally they have no effect on the match.

```` raku
# Demonstrating :ratchet semantics (rule like token here).
 > regex WillBT { a*a }
 > token WontBT { a*a }
 > if "aaa" ~~ WillBT { say "yes" } else { say "no" }
 yes
 > if "aaa" ~~ WontBT { say "yes" } else { say "no" }
 no

# Demonstrating :sigspace semantics.
 > regex Test1 { \d \d };
 > rule Test2 { \d \d };
 > if "12" ~~ Test1 { say "yes" } else { say "no" }
 yes
 > if "1 2" ~~ Test1 { say "yes" } else { say "no" }
 no
 > if "12" ~~ Test2 { say "yes" } else { say "no" }
 no
 > if "1 2" ~~ Test2 { say "yes" } else { say "no" }
 yes
````

So, that's what got done today. I'd like to thank Vienna.pm for funding this work, and hope you'll have fun playing with it, breaking it and reporting bugs. :-)
