# Enums and the &quot;but&quot; operator
    
*Originally published on [10 July 2008](https://use-perl.github.io/user/JonathanWorthington/journal/36895/) by Jonathan Worthington.*

This week's Rakudo day (Tuesday was catching up last week's) came around and this time I worked on some more high level, visible stuff. A while ago I quickly implemented the anonymous enum constructor, which essentially is a hash constructor on steroids. This week I got a lot of progress in on the (rather more advanced) named `enum`s. This means that you can now write things like:

```` raku
enum Day <Mon Tue Wed Thu Fri Sat Sun>;
say Mon; # 0 - the underlying value
say Day::Wed; # 2 - the underlying value
````

Notice how the names lie under the `Day` namespace, but are also imported into the current namespace too (and if you have an enum from some external library in the future, and you import that, the same thing will happen). There are some subtleties relating to symbol collisions that we aren't handling yet (we need a type name registry in Rakudo first). You can also use pairs to set the starting values or the values at any point in the enum too, as with the anonymous ones. A cool thing is that we evaluate the list at compile time to get the set of values, and then can construct the role/class and so forth at compile time too, rather than having to work that all out at runtime.

One of the trickier bits of enums is working out what they actually are. You are in fact introducing a role named `Day` in the above example, and that means you can mix it into anything else using `does` or `but`. The `but` keywords a like `does`, but it knows how to take one member of an enumeration and generalize it to the enumeration role, then mix than it. Additionally, it operates on a copy of the original value rather than being destructive. So we can do things like:

```` raku
enum Maybe <No Yes>;
my $x = 0 but Yes;
say $x; # 0
say $x.Maybe; # 1, since it's Yes
say $x.No; # 0, because $x.Maybe is not 0
say $x.Yes; # 1, because $x.Maybe is 1
````

Note here that `.No` and `.Yes` return true only if `.Maybe` (the property, which you can also assign to) matches that value.

```` raku
enum Maybe <No Yes>;
my $x = 0 but No;
say $x; # 0
say $x.Maybe; # 0, since it's No
say $x.No; # 1, because $x.Maybe is 0
say $x.Yes; # 0, because $x.Maybe is not 1
````

Note that you can use the `but` operator whenever you would use `does` but want a copy of the value operated on rather than the original (the expression as a whole evaluates to the copy that had the mixin applied). The `but` operator actually is implemented in terms of the `does` operator under the hood.

Also note that `0 but True` doesn't quite work yet, or at least isn't affecting the outcome of if statements. This isn't a problem in the enumerations implementation, but rather seems an inconsistency in the spec. Hopefully a mail to perl6-language will get that cleared up - I'll write it tomorrow, when I've got some sleep.

In other minor happenings today, I found and fixed a segfault in Parrot, helped trace a couple of other Parrot issues and fixed the Rakudo `does` operator bug where it lost the association with the proto-object in the modified object. Yesterday, I had some quite long and detailed discussions with both *Larry* and *Patrick* over signatures. I think we've got the spec side of things, where it wasn't completely clear before, worked out. However, we still have some details of the implementation left to completely work out (basically, issues about how data-ish and how procedural-ish signatures really are). I'm hopeful we can resolve these in the next week, so I've got a good base to start building the Raku MMD implementation on top of.

As usual, thanks to Vienna.pm for funding my Rakudo hacking.
