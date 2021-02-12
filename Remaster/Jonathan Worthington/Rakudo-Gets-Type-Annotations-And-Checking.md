# Rakudo Gets Type Annotations And Checking
    
*Originally published on [7 April 2008](https://use-perl.github.io/user/JonathanWorthington/journal/36095/) by Jonathan Worthington.*

I spent the weekend and most of Monday at the Oslo QA Hackathon. While I'm not a QA expert, it did provide me with time and a relative lack of distractions to get some work done on Rakudo. It was also nice seeing lots of Perl folks, some of whom I've not seen in quite a while. The Hackathon has had a very productive atmosphere with lots getting done; in this post 

I'll describe some of my Rakudo exploits.

The biggest thing I have been working on is type annotations. This now works with both variable declarations and in the signatures of subroutines and methods, although writing them in a multi-method doesn't lead to any type-based MMD just yet. Attributes of classes can't have types yet either. 

There are some quirks with various built-in types (including `Str` and `Code` types), though many others work fine (`Int`, `Num`, `Pair`, etc). With your own classes, roles and subset types, it should work just fine.

So, for example, if you declare a variable as having type `Int`, then try and assign a string to it, you'll get a type check failure (we'll get a nicer error message in the end).

```` raku
my Int $x = 42; # this is ok
my Int $x = "hello"; # this is not
Type check failed
````

Here's a class example.

```` raku
class Foo { }
class Bar is Foo { }
class Baz { }
my Foo $x; $x = Foo.`new`; # ok, Foo is a Foo
my Foo $x; $x = Bar.`new`; # ok, Bar is a Foo
my Foo $x; $x = Baz.`new`; # not OK
Type check failed
my Bar $x; $x = Foo.`new`; # not OK; Foo is not a Bar
Type check failed
````

Refinement types also work with this.

```` raku
subset EvenInt of Int where { $_ % 2 == 0 };
my EvenInt $x = 4; say $x;
4
my EvenInt $x = 4; say $x; $x = 3; say $x;
4
Type check failed
````

You can do all of this with parameters too, as well as declaring an anonymous refinement.

```` raku
sub Test(Int where { 0 < $_ <= 100 } $x) { say $x }
Test(50)
50
Test(0) # fails constraint
Parameter type check failed
Test("50") # not an Int
Parameter type check failed
````

Of course, if we drop the `Int` from the above, then we get coercion:

```` raku
sub Test(where { 0 < $_ <= 100 } $x) { say $x }
Test(50)
50
Test("50") # matches constraint when numified
50
Test(0) # still fails it, as expected
Parameter type check failed
````

Getting this to work forced me to refactor the type hierarchy somewhat - a job that needed doing, but that I'd been putting off (partly out of not trusting myself to do it right). It was a tad nasty, and needed some fixes inside Parrot too. However, the net result is that the majority of built-in object types, such as `Int`, now inherit from `Any` (which we didn't have before), and that in turn inherits from Object. The `Any` distinction will be needed to get junction auto-threading of arguments to work properly; my initial attempt was inefficient and broken. We'll most likely need to do HLL type mapping and similar before that will really work too, though. But anyway, now the following things give what you'd expect.

```` raku
if 42 ~~ Any { say "yes" }
yes
if 42 ~~ Object { say "yes" }
yes
if 42 | 43 ~~ Any { say "yes" }
if 42 | 43 ~~ Object { say "yes" }
yes
if 42 | 43 ~~ Junction { say "yes" }
yes
````

I've done a few other things, but I've got a work meeting here tomorrow, so I'm going to sleep now and write about them soon.
