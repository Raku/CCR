# The view from the inside: using meta-programming to implement Rakudo
    
*Originally published on [18 December 2011](https://perl6advent.wordpress.com/2011/12/18/the-view-from-the-inside-using-meta-programming-to-implement-rakudo/) by Jonathan Worthington.*

In [my previous article](https://rakuadvent.wordpress.com/2011/12/14/meta-programming-what-why-and-how/) for the Raku advent calendar, I looked at how we can use the meta-programming facilities of Rakudo Raku in order to build a range of tools, tweak the object system to our liking or even add major new features “from the outside”. While it’s nice that you can do these things, the Raku object system that you get by default is already very rich and powerful, supporting a wide range of features. Amongst them are:

- Classes
- Parametric roles
- Attributes
- Methods (including private ones)
- Delegation
- Introspection
- Subset (aka. refinement) types
- Enums

That’s a lot of stuff to implement, but it’s all done by implementing meta-objects, and therefore we can take advantage of OOP – with both classes and roles – to factor it. The only real difference between the meta-programming we saw in my last article and the meta-programming we do while implementing the core Raku object system in Rakudo is that the meta-objects are mostly written in NQP. NQP is a vastly smaller, much more easily optimizable and portable subset of Raku. Being able to use it also helps us to avoid many painful bootstrapping issues. Since it is mostly a small subset of Raku, it’s relatively easy to get in to.

In this article, I want to take you inside of Rakudo and, through implementing a missing feature, give you a taste of what it’s like to hack on the core language. So, what are we going to implement? Well, one feature of roles is that they can also serve as interfaces. That is, if you write:

```` raku
role Describable {
    method `describe` { ... }
}
class Page does Describable {
}
````

Then we are meant to get a compile time error, since the class `Page` does not implement the method “describe”. At the moment, however, there is no error at compile time; we don’t get any kind of failure until we call the describe method at runtime. So, let’s make this work!

One key thing we’re going to need to know is whether a method is just a stub, with a body containing just `…`, `???` or `!!!`. This is available to us by checking its `.yada` method. So, we have that bit. Question is, where to check it?

Unlike classes, which have the meta-object `ClassHOW` by default, there  isn’t a single `RoleHOW`. In fact, roles show up in no less than four different forms. The two most worth knowing about are `ParametricRoleHOW` and `ConcreteRoleHOW`. Every role is born parametric. Whether you explicitly give it extra parameters or not, it is always parametric on at least the type of the invocant. Before we can ever use a role, it has to be composed into a class. Along the way, we have to specialize it, taking all the parametric things and replacing them with concrete ones. The outcome of this is a role type with a meta-object of type `ConcreteRoleHOW`, which is now ready for composition into the class.

So that’s roles themselves, but what about composing them? Well, the actual composition is performed by two classes, `RoleToClassApplier` and `RoleToRoleApplier`. `RoleToClassApplier` is actually only capable of applying a single role to a class. This may seem a little odd: classes can do multiple roles, after all. However, it turns out that a neat way to factor this is to always “sum” multiple roles to a single one, and then apply that to the class. Anyway, it would seem that we need to be doing some kind of check in `RoleToClassApplier`. Looking through, we see this:

```` raku
my @methods := $to_compose_meta.methods($to_compose, :local(1));
for @methods {
    my $name;
    try { $name := $_.name }
    unless $name { $name := ~$_ }
    unless has_method($target, $name, 1) {
        $target.HOW.add_method($target, $name, $_);
    }
}
````

OK, so, it’s having a bit of “fun” with, of all things, looking up the name of the method. Actually it’s trying to cope with NQP and Rakudo methods having slightly different ideas about how the name of a method is looked up. But that aside, it’s really just a loop going over the methods in a role and adding them to the class. Seems like a relatively opportune time to spot the yada case, which indicates we require a method rather than want to compose one into the class. So, we change it do this:

```` raku
my @methods := $to_compose_meta.methods($to_compose, :local(1));
for @methods {
    my $name;
    my $yada := 0;
    try { $name := $_.name }
    unless $name { $name := ~$_ }
    try { $yada := $_.yada }
    if $yada {
        unless has_method($target, $name, 0) {
            pir::die("Method '$name' must be implemented by " ~
            $target.HOW.name($target) ~
            " because it is required by a role");
        }
    }
    elsif !has_method($target, $name, 1) {
        $target.HOW.add_method($target, $name, $_);
    }
}
````

A couple of notes. The first is that we’re doing binding, because NQP does not have assignment. Binding is easier to analyze and generate code for. Also, the has_method call is passing an argument of 0 or 1, which indicates whether we want to consider methods in just the target class or any of its parents (note that there’s no True/False in NQP). If the class inherits a method then we’ll consider that as good enough: it has it.

So, now we run our program and we get:

````
===SORRY!===
Method 'describe' must be implemented by Page because it is required by a role
````

Which is what we were after. Note that the “SORRY!” indicates it is a compile time error. Success!

So, are we done? Not so fast! First, let’s check the inherited method case works out. Here’s an example.

```` raku
role Describable {
    method `describe` { ... }
}
class SiteItem {
    method `describe` { say "It's a thingy" }
}
class Page is SiteItem does Describable {
}
````

And…oh dear. It gives an error. Fail. So, back to `RoleToClassApplier`. And…aha.

```` raku
sub has_method($target, $name, $local) {
    my %mt := $target.HOW.method_table($target);
    return nqp::existskey(%mt, $name)
}
````

Yup. It’s ignoring the `$local` argument. Seems it was written with the later need to do a required methods check in mind, but never implemented to handle it. OK, that’s an easy fix – we just need to go walking the MRO (that is, the transitive list of parents in dispatch order).

```` raku
sub has_method($target, $name, $local) {
    if $local {
        my %mt := $target.HOW.method_table($target);
        return nqp::existskey(%mt, $name);
    }
    else {
        for $target.HOW.mro($target) {
            my %mt := $_.HOW.method_table($_);
            if nqp::existskey(%mt, $name) {
                return 1;
            }
        }
        return 0;
    }
}
````

With that fixed, we’re in better shape. However, you may be able to imagine another case that we didn’t yet handle. What if another role provides the method? Well, first let’s see what the current failure mode is. Here’s the code.

```` raku
role Describable {
    method `describe` { ... }
}
role DefaultStuff {
    method `describe` { say "It's a thingy" }
}
class Page does Describable does DefaultStuff {
}
````

And here’s the failure.

````
===SORRY!===
Method 'describe' must be resolved by class Page because it exists
in multiple roles (DefaultStuff, Describable)
````

So, it’s actually considering this as a collision. So where do collisions actually get added? Happily, that just happens in one place: in `RoleToRoleApplier`. Here’s the code in question.

```` raku
if +@add_meths == 1 {
    $target.HOW.add_method($target, $name, @add_meths[0]);
}
else {
    # More than one - add to collisions list.
    $target.HOW.add_collision($target, $name, %meth_providers{$name});
}
````

We needn’t worry if we just have one method and it’s a requirement rather than an actual implementation – it’ll just do the right thing. So it’s just the second branch that needs consideration. Here’s how we change things.

```` raku
if +@add_meths == 1 {
    $target.HOW.add_method($target, $name, @add_meths[0]);
}
else {
    # Find if any of the methods are actually requirements, not
    # implementations.
    my @impl_meths;
    for @add_meths {
        my $yada := 0;
        try { $yada := $_.yada; }
        unless $yada {
            @impl_meths.push($_);
        }
    }

    # If there's still more than one possible - add to collisions list.
    # If we got down to just one, add it. If they were all requirements,
    # just choose one.
    if +@impl_meths == 1 {
        $target.HOW.add_method($target, $name, @impl_meths[0]);
    }
    elsif +@impl_meths == 0 {
        $target.HOW.add_method($target, $name, @add_meths[0]);
    }
    else {
        $target.HOW.add_collision($target, $name, %meth_providers{$name});
    }
}
````

Essentially, we filter out those that are implementations of the method rather than just requirements. If we are left with just a single method, then it’s the only implementation, and it satisfies the requirements, so we add it and we don’t need to do anything further. If we discover they are all requirements, then we don’t want to flag up a collision, but instead we just pick any of the required methods and pass it along. They’ll all give the same error. Otherwise, if we have multiple implementations, then it’s a real collision so we add it just as before. And…it works!

So, we run the test suite, things look good…and commit.

````
3 files changed, 48 insertions(+), 6 deletions(-)
````

And there we go – Rakudo now supports a part of the spec that it never has before, and it wasn’t terribly much effort to put in. And that just leaves me to go to the fridge and grab a Christmas ale to relax after a little meta-hacking. Cheers!
