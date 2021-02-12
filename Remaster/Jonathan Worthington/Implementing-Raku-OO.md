# Implementing Raku OO
    
*Originally published on [23 January 2008](https://use-perl.github.io/user/JonathanWorthington/journal/35462/) by Jonathan Worthington.*

So last time I wrote, I hoped not to get too many issues that kept me from hacking on Raku and Parrot. As it happens, I did get sick and that wiped me out for about a week. :-( This week I've had a more fun reason not to be doing so much, which is that I've got a friend visiting me. They're the first person I've had to visit since I got my own place out here in Spain, so it's been great fun showing them some places, taking them on a tapas crawl (lots of delicious food and beer) and so on.

Amongst it all, I found time to write a few lines of code for the Raku compiler. I really, really didn't want to go to Ukraine and talk about the Raku object model without people being able to play with it. So...I started implementing it. And now you can have classes with methods and attributes.

```` raku
class Foo {
    has $a;
    method set {
        $a = "w00t";
    }
    method get {
        say $a;
    }
}

my $x = Foo.`new`;
$x.`set`;
$x.`get`; # prints w00t
````

No accessor and/or mutator methods yet, but I plan to do those next. Then I will do compile time role composition, provided everyone is happy with me doing so. I already implemented roles and the composition algorithm in Parrot anyway, so it should be relatively easy to get the basics of that into the Raku compiler too.

Beyond that, my personal roadmap (as in, what I plan to hack on if it doesn't get in the way of what others are doing) is:

- Refactoring to get every non-Junction type inheriting from Any.
- Parsing type annotations on parameters and variables.
- Getting those type annotations to be applied to MMD (so we get type-based MMD dispatch as well as the arity based one that already works).
- Re-implementing junction auto-threading in terms of MMD, as it should be done.
