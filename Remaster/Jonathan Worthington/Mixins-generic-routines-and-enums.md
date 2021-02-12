# Mixins, generic routines and enums
    
*Originally published on [19 June 2008](https://use-perl.github.io/user/JonathanWorthington/journal/36731/) by Jonathan Worthington.*

Rakudo day came around again, and I pushed everything else that is keeping me busy these days aside and focused on getting more of Raku implemented. This week there are a handful of new features; as is the norm of late, I have been continuing my focus on the object model and the type system.

I started off the day with some refactoring. I wanted to bring us more in line with STD.pm - the standard Raku grammar - as well as parse some additional bits of syntax that we didn't parse before for some new things that are coming in the not too distant future. Getting us closer to STD.pm's grammar rules could have been done without that much shuffling around, but there was an action method that was more than long enough already lying behind it all. I didn't like the thought of making it even longer and harder to follow when I came to add to it in a week or two, and the re-arrangement of the grammar presented an obvious way to break the action method up into several methods. So, I did that and that bit of the codebase is now a bit cleaner, and ready for when I and others need to build more on top of it.

So, what's new? Probably the most major new feature this week is that you can now compose roles into an object at runtime, mix-in style. Here is an example from the tests to illustrate some of the semantics.

```` raku
role R { method test { say 42 } }
class C { has $.x }
my $y = C.new(x => 100);
$y does R;
$y.test; # 42 (called method from role)
say $y.x; # 100 - we didn't destroy old attribute values
````

There is also some special syntax, implemented too, for initializing values of a role that have a single attribute. For example, imagine we wrote an Answer role:

```` raku
role Answer { has $.answer is rw }
````

Then we can do the following:

```` raku
role Answer { has $.answer is rw }
my $x = 100;
$x does Answer(42);
say $x; # 100
say $x.answer; # 42
````

If you're thinking now, "is this the return 0 but True thingy I once saw", the the answer is almost, yes. However, unlike `does`, the `but` operator creates, operates on and returns a copy of the value rather than the original. It also does some special handling of values from enumerations. It is defined in terms of `does`, so we're part of the way to `but`. Getting the enumerations right is the harder part to implement.

The other major new feature I got in today was generic subs/methods. With these, you capture the type of a parameter in the call signature. You can then use it inside the sub or method. This means that we can write a sub that prints the type of the parameter it is passed just by doing:

```` raku
sub saytype(::T $x) { say T }
saytype(42); # Int
saytype("Mam pivo"); # Str
````

You can use T anywhere you would use a type otherwise.

```` raku
sub test(::T $x) { my T $y = "OH HAI" }
test(42) # Type check failed
test("hi") # Works
````

Note the variable `$y` inside the sub is constrained to be the same type as whatever the parameter to the sub was. In the first case, we pass an `Int`, so `$y` is constrained to be an `Int` and the assignment fails. In the second case, we pass a `Str`, so the assignment is successful. One remaining to-do feature is to let you use T elsewhere in the signature after you have declared it; that will be on my hit list for next week.

Finally, to round off the day, I took something a little easier. I've been eying enumerations for implementation, and the anonymous enum constructor was somewhat easier than the full-blown named one (which I'm still fully getting my head around). Basically, it can take a list of values and hand back a hash mapping each of them to ascending integers.

```` raku
my %ooks = enum < ook! ook. ook? >;
say %ooks<ook!>; # 0
say %ooks<ook.>; # 1
say %ooks<ook?>; # 2
````

You can instead write a pair (in a list constructor that parses them as pairs, mind) to specify the starting value, which may be a string too.

```` raku
my %meta = enum [ :foo('A'), 'bar', 'baz' ];
say %meta<foo>; # A
say %meta<bar>; # B
say %meta<baz>; # C
````

You can stick a pair at any point in there to change the indexing scheme too, or just use a load of mappings to set up your enum. At this point, it may seem like a fancy way of constructing a hash - and in a sense, it kinda is. However, the non-anonymous case introduces something somewhat more powerful, which as mentioned earlier can be used with `but`, and also as a predicate function and in a smart match. Hopefully I get those in sometime in the coming weeks.

So, that's what got done on this week's Rakudo day. Another one next week, and thanks as always go to Vienna.pm for making this possible.
