# Delegation With 'handles'
    
*Originally published on [9 April 2008](https://use-perl.github.io/user/JonathanWorthington/journal/36116/) by Jonathan Worthington.*

On the train over to Stockholm after the hackathon and on the plane back to Spain a day later, I implemented various cases of `handles` (not all of them, since the wildcard ones are trickier - they will get done probably along with a whole load of other work on attributes that needs doing). The `handles` trait verb is the thingy that lets you auto-generate methods that delegate to a methods on an attribute. Here's some examples of what you can do with this:

```` raku
class Bar { method a { say "a" }; method b { say "b" } }
class Foo1 { has $x handles 'a' } # one method
my $test = Foo1.new(x => Bar.`new`); $test.`a`
a
class Foo2 { has $x handles <a b> } # several
my $test = Foo2.new(x => Bar.`new`); $test.`a`; $test.`b`
a
b
class Foo3 { has $x handles :mya('a') } # rename one
my $test = Foo3.new(x => Bar.`new`); $test.`mya`;
a
class Foo4 { has $x handles (:mya('a'), :myb('b')) } # rename many
my $test = Foo4.new(x => Bar.`new`); $test.`mya`; $test.`myb`;
a
b
````

So, that's another small piece of the Raku implementation puzzle put into place.
