# Classes, attributes, methods and more
    
*Originally published on [11 December 2009](https://perl6advent.wordpress.com/2009/12/11/day-11-classes-attributes-methods-and-more/) by Jonathan Worthington.*

We excitedly tear the shiny wrapping paper off today’s gift, and inside we find something that nobody could object to! It’s the Raku object model, in all its class-declaring, role-composing, meta-modelling glory. But before we get too carried away with the high-powered stuff, let’s see just how easy it is to write a class in Raku.


```` raku
class Dog {
    has $.name;
    method bark($times) {
        say "w00f! " x $times;
    }
}
````

We start off by using the class keyword. If you’re coming from a Perl background, you can think of class as being a bit like a variant of package that gives you a bunch of classy semantics out of the box.

Next, we use the has keyword to declare an attribute along with an accessor method. The . that you see in the name is a twigil. Twigils tell you something special about the scoping of a variable. The . twigil means “attribute + accessor”. Other options are:


```` raku
has $!name;       # Private; only visible in the class
has $.name is rw; # Generates an l-value accessor
````

Next comes a method, introduced using the method keyword. method is like sub, but adds an entry to the methods table of the class. It also automatically takes the invocant for you, so you don’t have to write it in the parameter list. It is available through self.

All classes inherit a default constructor, named new, which maps named parameters to attributes. We can call this on Dog – the type object of the Dog class – to get a new instance.

```` raku
my $fido = Dog.new(name => 'Fido');
say $fido.name;  # Fido
$fido.bark(3);   # w00f! w00f! w00f!
````

Notice that the method call operator in Raku is `.` rather than Perl’s `->`. It’s 50% shorter, and will be familiar to developers coming from a range of other languages.

Of course, there’s inheritance, so we can introduce a yappy puppy.

```` raku
class Puppy is Dog {
    method bark($times) {
        say "yap! " x $times;
    }
}
````

There’s also support for delegation.


```` raku
class DogWalker {
    has $.name;
    has Dog $.dog handles (dog_name => 'name');
}
my $bob = DogWalker.new(name => 'Bob', dog => $fido);
say $bob.name;      # Bob
say $bob.dog_name;  # Fido
````

Here, we declare that we’d like calls to the method `dog_name` on the class `DogWalker` to forward to the name method of the contained `Dog`. Renaming is just one option that is available; the delegation syntax offers many other alternatives.

The beauty is more than skin deep, however. Beneath all of the neat syntax is a meta-model. Classes, attributes and methods are all first class in Raku, and are represented by meta-objects. We can use these to introspect objects at runtime.

```` raku
for Dog.^methods(:local) -> $meth {
    say "Dog has a method " ~ $meth.name;
}
````

The `.^` operator is a variant on the `.` operator, but instead makes a call on the metaclass – the object that represents the class. Here, we ask it to give us a list of the methods defined within that class (we use `:local` to exclude those inherited from parent classes). This doesn’t just give us a list of names, but instead a list of `Method` objects. We could actually invoke the method using this object, but in this case we’ve just ask for its name.

Those of you into meta-programming and looking forward to extending the Raku object model will be happy to know that there’s also a declarational aspect to all of this, so uses of the `method` keyword actually compile down to calls to `add_method` on the meta-class. Raku not only offers you a powerful object model out of the box, but also provides opportunities for it to grow to meet other future needs that we didn’t think of yet.

These are just a handful of the great things that the Raku object model has to offer; maybe we’ll discover more of them in some of the other gifts under the tree. :-)
