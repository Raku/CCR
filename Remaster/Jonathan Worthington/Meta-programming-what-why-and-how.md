# Meta-programming: what, why and how
    
*Originally published on [14 December 2011](https://perl6advent.wordpress.com/2011/12/14/meta-programming-what-why-and-how/) by Jonathan Worthington.*

Sometimes, it’s good to take ones understanding of a topic, throw it away and try to build a new mental model of it from scratch. I did that in the last couple of years with object orientation. Some things feel ever so slightly strange to let go of and re-evaluate. For many people, an object really is “an instance of a class” and inheritance really is a core building block of OOP. I suspect many people who read this post will at this point be thinking, “huh, of course they really are” – and if so, that’s totally fair enough. Most people’s view of OOP will, naturally, be based around the languages they’ve applied object orientation in, and most of the mainstream languages really do have objects that are instances of classes and really do have inheritance as a core principle.

Step back and look around, however, and things get a bit more blurry. JavaScript doesn’t have any notion of classes. CLOS (the Common Lisp Object System) does have classes, but they don’t have methods. And even if we do just stick with the languages that have classes with methods, there’s a dizzying array of “extras” playing their part in the language’s OO world view; amongst them are interfaces, mixins and roles.

Roles – more often known as traits in the literature – are a relatively recent arrival on the OO scene, and they serve as an important reminder than object orientation is not finished yet. It’s a living, breathing paradigm, undergoing its own evolution just as our programming languages in general are.

And that brings me nicely on to Raku – a language that from the start has set out to be able to evolve. At a syntax level, that’s done by opening up the grammar to mutation – in a very carefully controlled way, such that you always know what language any given lexical scope is in. Meta-programming plays that same role, but in the object orientation and type system space.

So what is a meta-object? A meta-object is simply an object that describes how a piece of our language works. What sorts of things in Raku have meta-objects? Here’s a partial list.

- Classes
- Roles
- Subsets
- Enumerations
- Attributes
- Subroutines
- Methods
- Signatures
- Parameters

So that’s meta-objects, but what about the protocol? You can read protocol as “API” or “interface”. It’s an agreed set of methods that a meta-object will provide if it wants to expose certain features. Let’s consider the API for anything that can have methods, such as classes and roles. At a minimum, it will provide:

- add_method – adds a method to the object
- methods – enables introspection of the methods that the object has
- method_table – provides a hash of the methods in this type, excluding any that may be inherited

What about something that you can call a method on? It just has to provide one thing:

- find_method – takes an object and a name, and returns the method if one exists

By now you may be thinking, “wait a moment, is there something that you can call a method on, but that does not have methods”? And the answer is – yes. For example, an `enum` has values that you can call a method on – the methods that the underlying type of the enumeration provides. You can’t actually add a method to an enum itself, however.

What’s striking about this is that we are now doing object oriented programming…to implement our object oriented language features. And this in turn means that we can tweak and extend our language – perhaps by subclassing an existing meta-object, or even by writing a new one from scratch. To demonstrate this, we’ll do a simple example, then a trickier one.

Suppose we wanted to forbid multiple inheritance. Here’s the code that we need to write.

```` raku
my class SingleInheritanceClassHOW
    is Metamodel::ClassHOW
{
    method add_parent(Mu $obj, Mu $parent) {
        if +self.parents($obj, :local) > 0 {
            die "Multiple inheritance is forbidden!";
        }
        callsame;
    }
}
my module EXPORTHOW { }
EXPORTHOW.WHO.<class> = SingleInheritanceClassHOW;
````

What are we doing here? First, we inherit from the standard Raku implementation of classes, which is defined by the class `Metamodel::ClassHOW`. (For now, we also inherit from `Mu`, since meta-objects currently consider themselves outside of the standard type hierarchy. This may change.) We then override the `add_parent` method, which is called whenever we want to add a parent to a class. We check the current number of (local) parents that a class has; if it already has one, then we die. Otherwise, we use `callsame` in order to just call the normal `add_parent` method, which actually adds the parent.

You may wonder what the `$obj` parameter that we’re taking is, and why it is needed. It is there because if we were implementing a prototype model of OOP, then adding a method to an object would operate on the individual object, rather than stashing the method away in the meta-object.

Finally, we need to export our new meta-object to anything that uses our module, so that it will be used in place of the `class` package declarator. Do do this, we stick it in the `EXPORTHOW` module, under the name `class`. The importer pays special attention to this module, if it exists. So, here it is in action, assuming we put our code in a module si.pm. This program works as usual:

```` raku
use si;
class A { }
class B is A { }
````

While this one:

```` raku
class A { }
class B { }
class C is A is B { }
````

Will die with:

```` raku
===SORRY!===
Multiple inheritance is forbidden!
````

At compile time.

Now for the trickier one. Let’s do a really, really simple implementation of aspect oriented programming. We’ll write an aspects module. First, we declare a class that we’ll use to mark aspects.

```` raku
my class MethodBoundaryAspect is export {
}
````

Next, when a class is declared with `is SomeAspect`, where `SomeAspect` inherits from `MethodBoundaryAspect`, we don’t want to treat it as inheritance. Instead, we’d like to add it to a list of aspects. Here’s an extra trait modifier to do that.

```` raku
multi trait_mod:<is>(Mu:U $type, MethodBoundaryAspect:U $aspect) is export {
    $aspect === MethodBoundaryAspect ??
        $type.HOW.add_parent($type, $aspect) !!
        $type.HOW.add_aspect($type, $aspect);
}
````

We take care to make sure that the declaration of aspects themselves – which will directly derive from this class – still works out by continuing to call `add_parent` for those. Otherwise, we call a method `add_aspect`, which we’ll define in a moment.

Supposing that our aspects work by optionally implementing entry and exit methods, which get passed the details of the call, here’s our custom meta-class, and the code to export it, just as before.

```` raku
my class ClassWithAspectsHOW
    is Metamodel::ClassHOW
{
    has @!aspects;
    method add_aspect(Mu $obj, MethodBoundaryAspect:U $aspect) {
        @!aspects.push($aspect);
    }
    method compose(Mu $obj) {
        for @!aspects -> $a {
        for self.methods($obj, :local) -> $m {
            $m.wrap(-> $obj, |args {
                $a.?entry($m.name, $obj, args);
                my $result := callsame;
                $a.?exit($m.name, $obj, args, $result);
                $result
            });
        }
        }
        callsame;
    }
}
my module EXPORTHOW { }
EXPORTHOW.WHO.<class> = ClassWithAspectsHOW;
````

Here, we see how `add_aspect` is implemented – it just pushes the aspect onto a list. The magic all happens at class composition time. The compose method is called after we’ve parsed the closing curly of a class declaration, and is the point at which we finalize things relating to the class declaration. Ahead of that, we loop over any aspects we have, and the wrap each method declared in the class body up so that it will make the call to the entry and exit methods.

Here’s an example of the module in use.

```` raku
use aspects;
class LoggingAspect is MethodBoundaryAspect {
    method entry($method, $obj, $args) {
        say "Called $method with $args";
    }
    method exit($method, $obj, $args, $result) {
        say "$method returned with $result.`perl`";
    }
}
class Example is LoggingAspect {
    method double($x) { $x * 2 }
    method square($x) { $x ** 2 }
}
say Example.double(3);
say Example.square(3);
````

And the output is:

````D raku
Called double with 3
double returned with 6
6
Called square with 3
square returned with 9
9
````

So, a module providing basic aspect orientation support in 30 or so lines. Not so bad.

As you can imagine, we can go a long way with meta-programming, whether we want to create policies, development tools (like `Grammar::Debugger`) or try to add entirely new concepts to our language. Happy meta-hacking.
