# A Little Reflection
    
*Originally published on [13 August 2009](https://use-perl.github.io/user/JonathanWorthington/journal/39455/) by Jonathan Worthington.*

> I still remember the sunlight on your face that warm November day,
> And I still remember my heartbeat quickened by desire, unaware of prices I would pay
> I still remember the closing door the night we said goodbye,
> And I still remember losing you for good and knowing that a part of me had died
> *Memory - Redemption*

Sorry it's been a while since I last posted - YAPC::Europe and preparing for it were something of a distraction, as has been visiting some family and friends, though the real killer has been that in the last month I've managed to have myself a couple of colds/flu-ish things that left me without a great deal of energy during a lot of the time I've been here at home and working. Anyway, I think I've almost shaken off the current infection, and amongst it all I've been able to keep my Hague Grant moving along - in so far as the code, if not the blogging.

One of the big pieces of my grant that I've been working on is improving Rakudo's support for introspecting classes and roles. Before I started working on this, Rakudo didn't really have any such support. Of course, Parrot provided all of the primitives. But there was some work to be done in building up an implementation of the Raku introspection interface around it.

To introspect an object, first you need to get hold of its metaclass. This class actually provides the various introspection-related methods. The metaclass can be obtained by using the .HOW macro (actually in Rakudo, implemented as a method, but we'll fix that in the future). All metaclass methods take as a first parameter the thing that you want to introspect. So for example, if I want to find the parents of the built-in List class, I would do (showing this using the REPL):

```` raku
> say List.HOW.parents(List).raku
[Any, Object]
````

Where `.raku` gets a Perlish representation of a data structure (think `Data::Dumper` built into the language). At this point you may be thinking, gee, this sucks, I have to say List twice. Which is why there's a `.^` operator, that evaluates what is on its left hand side once, calls `.HOW` on it, then calls the method you specify on the metaclass, fudging what was evaluated on the LHS in as the first argument to the call. Thus instead of the above you can just do:

```` raku
> say List.^parents.raku
[Any, Object]
````

Which is much better. .^parents takes a few options too.

```` raku
> class A { }
> class B { }
> class C is A is B { }
> say C.^parents.raku; # all, flat list
[A, B, Any, Object]
> say C.^parents(:local).raku; # immediate only
[A, B]
> say C.^parents(:tree).raku; # all, tree
[[A, [Any, [Object]]], [B, [Any, [Object]]]]
````

Of course, it's not just parents that can be introspected, but also methods and attributes - both on your own classes and built-in ones. For example, here we look at the methods defined in the Num class. Note the use of the parallel dispatch operator - implemented earlier on in this grant - to get the name property of each of the methods returned in the list from the methods method; we then join the list.

```` raku
> say Num.^methods(:local)>>.name.join(", ");
tan, cos, sin, pred, acosec, sinh, asinh, cosech, acosech,
acotan, Str, asec, cotanh, acotanh, sech, ACCEPTS, asech, atan,
acos, tanh, asin, atanh, cosh, cosec, acosh, succ, WHICH, perl,
cotan, atan2, Scalar, sec
````

Here is a very similar example for introspecting attributes.

```` raku
> say Pair.^attributes(:local)>>.name.join(", ");
$!key, $!value
````

While I have been using these with `:local`, they also support being called parameterless to get all attributes up the hierarchy, as well as :tree to build something similar to what you saw earlier for `.^parents`.

At this point you may have realized that all of this means that you can use a module at the REPL and then explore its classes using the introspection interface.

Anyway, for my final trick, here's some code that walks a class hierarchy and prints out an ASCII tree-ish thing depicting the class hierarchy. To stop it going and printing all the stuff in Any and Object - classes inherit from Any by default - I've put in a little check for that. It makes the output shorter and probably more useful.

```` raku
multi describe($c, $prefix) {
    take "$prefix " ~ $c.raku ~ "\n";
    for $c.^attributes(:local) {
        take "$prefix + Attribute: " ~ .name ~ "\n";
    }
    for $c.^methods(:local) {
        take "$prefix + Method: " ~ .name ~ "\n";
    }
}

multi describe(@list, $prefix) {
    for @list -> $item {
        unless $item eq Any|Object {
            describe($item, $prefix ~ "    ");
        }
    }
}

multi describe($start) {
    return [~] gather {
        describe($start, "");
        describe($start.^parents(:tree)[0], "");
    }
}
````

This code demonstrates not only introspection, but also multiple dispatch by sigil, `gather` / `take`, the reduce meta-operator (which combined with `gather` / `take` lets us build up a string from a bunch of recursive routines without having to worry about building up and passing along a return value all the way up), junctions and a bunch of more basic features. Here's an example program using this.

```` raku
class A {
    has $.a;
}
class B is A {
    has $!b;
    method `foo` { }
}
class C is B {
    has $.c;
    method `bar` { }
}
say describe(C);
````

And the output:

```` raku
 C
 + Attribute: $!c
 + Method: bar
 + Method: c
     B
     + Attribute: $!b
     + Method: foo
         A
         + Attribute: $!a
         + Method: a
````

Notice how it shows the auto-generated accessor methods for the non-private attributes too.

So, that's introspection. Have fun, send bug reports. :-)
