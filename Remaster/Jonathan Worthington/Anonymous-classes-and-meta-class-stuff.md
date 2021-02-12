# Anonymous classes and meta-class stuff
    
*Originally published on [18 July 2008](https://use-perl.github.io/user/JonathanWorthington/journal/36958/) by Jonathan Worthington.*

Today was this week's Rakudo day, and I spent it continuing my work on the S12 (objects) implementation. The biggest new addition this week is that you can now write anonymous classes.

```` raku
my $c = class {
    has $.x;
    method foo { say "OH HAI" }
};
my $obj = $c.new(x => 42); # Instantiate it
$obj.foo; # OH HAI
say $obj.x; # 42
````

I've got tests written for anonymous classes with attributes and methods; you should be able to inherit and compose roles too, but I didn't get tests for those done yet. Anyone who feels like writing such tests, please do feel free - they go in S12-classes/anonymous.t (in the t/spec, in the Pugs repository).

We've been able to write multi-dispatch subs where the dispatch was type rather than arity based for a little while. As I start to think about implementing the real Raku multiple dispatch algorithm soon, I wanted to make sure that multi-methods worked with the current Parrot algorithm. I'd never thought to try it, but it occurred to me that there wasn't really any good reasons why it wouldn't work either. It turns out it didn't work, but the fix wasn't hard either. So, I did what was needed and now you can write multi methods in classes. Arity based dispatch should be fine; type based has all the issues multi-subs do until I get the real Raku multi-dispatch algorithm in place that knows about roles, constraints and so forth.

After that, I set about adding the `.^` method call operator. This means "call on the meta-class". S12 changed recently to make things a bit saner here. Before it was specified that you would be able to write things like:

```` raku
my @methods = $obj.HOW.methods;
````

To introspect the methods of the object `$obj`. However, this doesn't quite work out, since you are invoking "methods" on the meta-class, and there's no promise that just one class will have one meta-class; the meta-class may be shared amongst many classes, depending on your meta-model. So now you have to pass in the object to introspect as the first parameter to methods on the meta-class.

```` raku
my @methods = $obj.HOW.methods($obj);
````

Which is a bit of a mouthful, which is why there is the `.^` operator, allowing you to write the above like this:

```` raku
my @methods = $obj.^`methods`;
````

This operator sorts out getting the meta-class by calling HOW, and inserting `$obj` as a parameter to the meta-class method. Note that "methods" on the meta-class isn't implemented yet, though it's probably not far off being done. Today I modified our existing meta-class methods to match the new S12 changes, then implemented the `.^` operator. So this gets us on the way towards more introspection support. While I was in that area of the code, I moved the auto-vificiation (`WHENCE`) stuff out of the RakuObject code (which is meant to be more generic than what Rakudo needs) and put it into the Rakudo code, which should make some upcoming refactors pmichaud has planned on RakuObject a tad easier.

I also looked at starting to get a few other things in place to flesh objects out. One of them is `.WHERE`, which simply returns the memory address of an object. That didn't take long. Then I read up on `.WHICH`, which returns an object's identity value, which is what will allow us to implement value type semantics to go with the `===` comparison operator. For normal objects, it just returns the memory address of the object; I put this in place. Next us is to override it in the value types, and then the `===` operator can be added. This is probably fairly low hanging fruit for anyone who fancies digging into Rakudo some, by the way.

In other bits, I've applied a patch from *Carl Masak* during the day, and this evening helped *Chris Fields*, who has happily implemented transliteration for us and is now working on `.match` on strings, to debug a rather subtle Rakudo bug. I got to the bottom of what's wrong, but resolution is to be discussed. But hopefully we have one soon and then we can have .match defined on strings - another piece in the S05 puzzle! We've a long way to go yet, but bit by bit, day by day, Rakudo is coming together. And last but not least, I'd like to thank to Vienna.pm for funding my weekly Rakudo day.
