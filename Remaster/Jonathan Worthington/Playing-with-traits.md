# Playing with traits
    
*Originally published on [21 August 2009](https://use-perl.github.io/user/JonathanWorthington/journal/39504/) by Jonathan Worthington.*

````
Fly on the wings of despair
No one is holding you back
The call of the wild is internal
Conquer the silence you fear
Tomorrow will not fade to black
Remember
No one can save you today
*Wings Of Despair - Kamelot*
````

Welcome to the final post in my Hague Grant updates. Yup, I've made it through, and will soon be submitting the final report. In the meantime, let me talk a bit about the remaining big topic in my grant that I have not yet discussed: traits.

Traits are the Raku way of hooking in to various declarations. The mechanism is based upon multiple dispatch. That is, it's possible to write a trait handler by writing a multi-dispatch sub that declares what sort of declaration it applies to and how it is identified. The types of declarations that can be hooked into in this way are:

- Classes and roles
- Routines
- Variables
- Attributes

Generally, a trait handler will be called with some object representing the thing being declared, something representing the trait and, optionally, any arguments that were supplied.

A few days back, somebody (sorry, forget who) on #raku was asking about being able to introduce additional accessor methods for an attribute. If I can't remember their handle, I sure ain't going to remember their use case, so let me make one up. In Raku, we can write:

```` raku
class ValueWithError {
    has $.min_value;
    has $.value;
    has $.max_value;
}
````

And we get a class that lets us represent a value as best we have it with minimum and maximum values that it could be, which we presumably compute by knowing the errors in some calculations. Thing is, everyone using our class keeps trying to call `.min` and `.minimum` instead of `.min_value`, so we decide that we may as well support those too. Well, we could write some accessor methods ourselves, but instead we'll write a small bit of code that introduces a new trait called "aliased". After we've implemented this, we'll then be able to write:

```` raku
class ValueWithError {
    has $.min_value is aliased<min minimum>;
    has $.value;
    has $.max_value is aliased<max maximum>;
}
````

So, let's get started. First, we need to declare a trait handler.

```` raku
multi trait_mod:<is>(AttributeDeclarand $a, $names, :$aliased!) {

}
````

The first argument to a trait handler is always the declarand - that is, something representing the thing being declared. For attributes that is an instance of AttributeDeclarand, which gives us a reference to the container but also some extra bits of information, such as the attribute's name and the metaclass of the class it is defined in. Beyond this, we either need a required named argument matching the name of the trait, which we put as a named parameter at the end of the signature, or we need the second positional parameter to be the name of a type. When dispatching a trait, the compiler will see if it's a known type name, and dispatch with the type object for that type if so and a named parameter if not. Finally, we can optionally add another positional parameter if we want our trait to be able to accept arguments (here, that will contain the list of names we will alias to).

Now we'll start to fill out this stub a little bit.

```` raku
multi trait_mod:<is>(AttributeDeclarand $a, $names, :$aliased!) {
    my $accessor_name = $a.name.substr(2);
    for $names.list -> $name {
        say "aliasing $name to $accessor_name";
    }
}
````

AttributeDeclarand has a `.name` property, which will hold the name of the attribute. Remember that all attributes have a real name of `$!foo`, even if declared `$.foo` to get an accessor generated. We take this and strip off the `$!` at the start, to get the name of the generated accessor method that we will forward to. Then we will take `$names` (which were the set of arguments that were passed to the trait), put it into list context and iterate over it. For now, I just added a say in there, so if we actually try creating the class I showed earlier, we'll get the following output:

```` raku
aliasing min to min_value
aliasing minimum to min_value
aliasing max to max_value
aliasing maximum to max_value
````

So, what is the magic that we need to do in order to finish this? Well, we need to use the metaclass - accessible through the AttributeDeclarand object - and with it add a method. And what do we add? Well, we'll use the anonymous method syntax, the indirect method call syntax and closure semantics to build us a forwarder method, and then in the loop call add_method on the metaclass to add that method under each of the aliased names. Our final code looks like this - I also include the class and some example code.

```` raku
multi trait_mod:<is>(AttributeDeclarand $a, $names, :$aliased!) {
    my $accessor_name = $a.name.substr(2);
    my $meth = method { self."$accessor_name" };
    for $names.list -> $name {
        $a.how.add_method($a.how, $name, $meth);
    }
}

class ValueWithError {
    has $.min_value is aliased<min minimum>;
    has $.value;
    has $.max_value is aliased<max maximum>;
}

my $v = ValueWithError.new(value => 42, min_value => 41.5, max_value => 42.8);
say $v.min_value;
say $v.min;
say $v.minimum;
say $v.max_value;
say $v.max;
say $v.maximum;
````

And here is the output:

````
41.5
41.5
41.5
42.8
42.8
42.8
````

And that's it, we wrote our first trait handler - and it was actually useful! And with that, I bring this series of blog posts on my current Hague Grant to an end. I hope they've been interesting. Worried you're going to miss them? Well, fear not - in a couple of days I'll be applying for my next Hague Grant. In the meantime, have fun playing with and finding creative ways of breaking the new features. :-)
