# Unpacking data structures with signatures
    
*Originally published on [20 February 2010](https://use-perl.github.io/user/JonathanWorthington/journal/40196/) by Jonathan Worthington.*

My signature improvements Hague Grant is pretty much wrapped up. I wrote a couple of posts already about the new signature binder and also about signature introspection. In this post I want to talk about some of the other cool stuff I've been working on as part of it.

First, a little background. When you make a call in Raku, the arguments are packaged up into a data structure called a capture. A capture contains an arrayish part (for positional parameters) and a hashish part (for smok^Wnamed parameters). The thing you're calling has a signature, which essentially describes where we want the data from a capture to end up. The signature binder is the chunk of code that takes a capture and a signature as inputs, and maps things in the capture to - most of the time, anyway - variables in the lexpad, according to the names given in the signature.

Where things get interesting is that if you take a parameter and coerce it to a `Capture`, then you can bind that too against a signature. And it so turns out that Raku allows you to write a signature within another signature just for this very purpose. Let's take a look.

```` raku
multi quicksort([$pivot, *@values]) {
    my @before = @values.grep({ $^n < $pivot });
    my @after = @values.grep({ $^n >= $pivot });
    (quicksort(@before), $pivot, quicksort(@after))
}
multi quicksort( [] ) { () }
````

Here, instead of writing an array in the signature, we use [...] to specify we want a sub-signature. The binder takes the incoming array and coerces it into a `Capture`, which essentially flattens it out. We then bind the sub-signature against it, which puts the first item in the incoming array into `$pivot` and the rest into `@values`. We then just partition the values and recurse.

The second multi candidate has a nested empty signature, which binds only if the capture is empty. Thus when we have an empty list, we end up there, since the first candidate requires at least one item to bind to `$pivot`. Multi-dispatch is smart enough to know about sub-signatures and treat them like constraints, which means that you can now use multi-dispatch to distinguish between the deeper structure of your incoming parameters. So, to try it out...

```` raku
my @unsorted = 1, 9, 28, 3, -9, 10;
my @sorted = quicksort(@unsorted);
say @sorted.raku; # [-9, 1, 3, 9, 10, 28]
````

It's not just for lists either. An incoming hash can be unpacked as if it had named parameters; for that write the nested signature in `(...)` rather than `[...]` (we could have use `(...)` above too, but `[...]` implies we expect to be passed a `Positional`). For any other object, we coerce to a capture by looking at all of the public attributes (things declared has `$.foo`) up the class hierarchy and making those available as named parameters. Here's an example.

```` raku
class TreeNode { has $.left; has $.right; }
sub unpack(TreeNode $node (:$left, :$right)) {
    say "Node has L: $left, R: $right";
}
unpack(TreeNode.new(left => 42, right => 99));
````

This outputs:

```` raku
Node has L: 42, R: 99
````

You can probably imagine that a multi and some constraints on the branches gives you some interesting possibilities in writing tree transversals. Also fun is that you can also unpack return values. When you write things like:

```` raku
my ($a, $b) = `foo`;
````

Then you get list assignment. No surprises there. What maybe will surprise you a bit is that Raku actually parses a signature after the my, not just a list of variables. There's a few reasons for that, not least that you can put different type constraints on the variables too. I've referred to signature binding a lot, and it turns out that if instead of writing the assignment operator you write the binding operator, you get signature binding semantics. Which means...you can do unpacks on return values too. So assuming the same TreeNode class:

```` raku
sub `foo` {
    return TreeNode.new(left => 'lol', right => 'rofl');
}
my ($node (:$left, :$right)) := `foo`;
say "Node has L: $left, R: $right";
````

This, as you might have guessed, outputs:

```` raku
Node has L: lol, R: rofl
````

Note that if you didn't need the `$node`, you could just omit it (put keep the things that follow nested in another level of parentheses). This works with some built-in classes too, by the way.

It works for some built-in types with accessors too:

```` raku
sub `frac` { return 2/3; }
my ((:$numerator, :$denominator)) := `frac`;
say "$numerator, $denominator";
````

Have fun, be creative, submit bugs. :-)
