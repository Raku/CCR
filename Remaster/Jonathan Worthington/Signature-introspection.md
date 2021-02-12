# Signature introspection
    
*Originally published on [27 October 2009](https://use-perl.github.io/user/JonathanWorthington/journal/39810/) by Jonathan Worthington.*

One of my Hague Grant tasks was to get a signature introspection interface into the specification and get Rakudo conforming to it. While there may still be some minor tweaks to come, this part is essentially done now. You can read the spec additions in [S06](http://svn.pugscode.org/pugs/docs/Perl6/Spec/S06-routines.pod).

First off, you can call .signature on any block to get hold of its signature object - an instance of the `Signature` classs. Calling `.params` on a `Signature` object will in turn give you a List of `Parameter` objects, which describe each of the parameters specified in the signature. We are able to introspect the types, the names, whether the parameter is optional, get a closure that returns any default value and more. Here's an example.

```` raku
sub example(Int $x, Str $y?) { }
my $sig = &example.signature;
for $sig.params -> $param {
    say "Name: {$param.name}, Type: {$param.type}, Optional: {$param.optional}";
}
````

This gives the output:

````
Name: $x, Type: `Int`, Optional: 0
Name: $y, Type: `Str`, Optional: 1
````

To make sure that all of the information was really there and accessible, I then went and re-implemented the `.raku` method on a `Signature` in Raku in the setting, using the `Parameter` objects. The new version lacked several of the bugs that the previous version had, which cleared up a few RT tickets. And finally, *moritz*++ wrote a bunch of spectests for signature introspection, following the new spec.
