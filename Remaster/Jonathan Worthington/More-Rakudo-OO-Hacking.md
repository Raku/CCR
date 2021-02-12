# More Rakudo OO Hacking
    
*Originally published on [7 February 2008](https://use-perl.github.io/user/JonathanWorthington/journal/35610/) by Jonathan Worthington.*

Since I last wrote, I've been continuing my work on Rakudo's OO support. Part of this has been reading and comprehending more of S12, part of it exchanging emails with Stevan Little and looking over some Moose stuff and a lot of it has been just grinding out the code. I'm happy to say that things are now a tad further on.

First of all, my initial work on attributes was some way out of line with S12 (mostly because it was just to get *something* working). With the latest work, attributes are now all stored as $!foo. If you write $.foo, you will get an accessor/mutator method generated. Note that the default eventually will be accessor only and you will write `is rw` to get a mutator too, but I think it's easier and more useful to people playing with Rakudo to be more liberal and allow both until that is in place. If you declare the attribute as `$x`, then it's `$!x` really but you get a lexical alias named `$x` so you can refer to it either way. This work brings the implementation somewhat closer to S12 than before.

Next up was inheritance. Helpfully, while I looked away from Rakudo for a little while due to $DAYJOB and entertaining a guest, someone put the parsing side of traits in. That meant I could dig straight into the semantics. The implementation here has already been through a few iterations, getting increasingly less hacky each time. What we have now actually calls trait_auxiliary:is, and applying a trait that is a class is just a standard case of applying a trait. No special cases - it's all decided by multiple dispatch. This also open the way to implementing any other traits that can be applied to a class. A final tweak allowed subclassing of built-in types such as `Bool`.

I've also started on roles. There is a long, long way to go here. However, composition is  started. It doesn't do conflict resolution correctly yet (just haven't had time to do what it needs to make it work yet; I will do so very soon).

And finally, it's a small thing, but I added parsing and code-gen for `self` too.

So, want an example?
```` raku
role Wob {
    method `be_tired` {
        say "I'm wobbed.";
    }
}

class Person {
    method `species` {
        "human";
    }
    method `describe_self` {
        say "I am a " ~ self.`species` ~ ".";
    }
}

class Geck is Person does Wob {
    method `species` {
        "geck"
    }
}

my $p1 = Person.`new`;
$p1.`describe_self`;     # I am a human.

my $p2 = Geck.`new`;
$p2.`describe_self`;     # I am a geck.
$p2.`be_tired`;          # I'm wobbed.
````
