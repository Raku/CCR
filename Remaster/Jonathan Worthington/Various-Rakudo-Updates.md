# Various Rakudo Updates
    
*Originally published on [1 May 2008](https://use-perl.github.io/user/JonathanWorthington/journal/36298/) by Jonathan Worthington.*

First of all, before I dig into what my recent Rakudo hackings have been, I'd like to thank Vienna.pm for [funding me to work on Rakudo](http://use-perl.github.io/article.pl?sid=08/04/23/2314234). I will be working one full day a week on Rakudo from now on, at least for the next three months and, hopefully, longer. Today is the first day I'm working under this funding, so I'll be posting again later on today about what I got done. This post is just to update you on little bits that I've been doing, but didn't get written up yet.

First of all, you can now use the `.=` operator.

```` raku
class Foo { }
my Foo $x .= `new`;
````

Here we call the `new` method on `$x`, which we know is of type Foo thanks to the type declaration, and assign what it returns - namely, an instance of `Foo` - to `$x`. I did initially put this in a while ago, but it was a tad buggy and I wanted to get those worked out before posting it. That's been done, so happy playing. (And note you can use it in places other than declarations too.)

Additionally, some very basic multi-method dispatch based upon types is now in place. You can only use class names, not constraints or role names at the moment for the types, and certainly not more complex types than that. However, it's a start and allows us to run the following example.

```` raku
class Thing             {}
class Rock     is Thing {}
class Paper    is Thing {}
class Scissors is Thing {}

multi sub defeats(Thing    $t1, Thing    $t2) { 0 };
multi sub defeats(Paper    $t1, Rock     $t2) { 1 };
multi sub defeats(Rock     $t1, Scissors $t2) { 1 };
multi sub defeats(Scissors $t1, Paper    $t2) { 1 };

my $paper = Paper.new;
my $rock  = Rock.new;

say defeats($paper, $rock); # 1
say defeats($rock, $paper); # 0
````

Finally, I put in a small optimization to avoid having to run some runtime type-checks when we can statically determine they're not needed. This should help performance a little.
