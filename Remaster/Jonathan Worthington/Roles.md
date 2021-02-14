# Roles
    
*Originally published on [18 December 2009](https://perl6advent.wordpress.com/2009/12/18/day-18-roles/) by Jonathan Worthington.*

As the snow falls outside, we grab a glass of mulled wine – or maybe a cup of eggnog – to enjoy as we explore today’s exciting gift – roles!

Traditionally in object oriented programming, classes have taken on two tasks: instance management and re-use. Unfortunately, this can end up pulling classes in two directions: re-use wants them to be small and minimal, but if they’re representing a complex entity then they need to support all of the bits it needs. In Raku, classes retain the task of instance management. Re-use falls to roles.

So what does a role look like? Imagine that we are building up a bunch of classes that represent different types of product. Some of them will have various bits of data and functionality in common. For example, we may have a `BatteryPower` role.

```` raku
role BatteryPower {
    has $.battery-type;
    has $.batteries-included;
    method find-power-`accessories` {
        return ProductSearch::find($.battery-type);
    }
}
````

At first glance, this looks a lot like a class: it has attributes and methods. However, we can not use a role on its own. Instead, we must compose it into a class, using the `does` keyword.

```` raku
class ElectricCar does BatteryPower {
    has $.manufacturer;
    has $.model;
}
````

Composition takes the attributes and methods – including generated accessors – from the role and copies them into the class. From that point on, it is as if the attributes and methods had been declared in the class itself. Unlike with inheritance, where the parents are looked at during method dispatch, with roles there is no runtime link beyond the class knowing to say “yes” if asked if it does a particular role.

Where things get really interesting is when we start to compose multiple roles into the class. Suppose that we have another role, `SocketPower`.

```` raku
role SocketPower {
    has $.adapter-type;
    has $.min-voltage;
    has $.max-voltage; 
    method find-power-`accessories` {
        return ProductSearch::find($.adapter-type);
    }
}

````

Our laptop computer can be plugged in to the socket or battery powered, so we decide to compose in both roles.

```` raku
class Laptop does BatteryPower does SocketPower {
}
````

We try to run this and…BOOM! Compile time fail! Unlike with inheritance and mix-ins, role composition puts all of the roles on a level playing field. If both provide a method of the same name – in this case, `find-power-accessories` – then the conflict will be detected as the class is being formed and you will be asked to resolve it. This can be done by supplying a method in our class that says what should be done.

```` raku
class Laptop does BatteryPower does SocketPower {
    method find-power-`accessories` {
        my $ss = $.adapter-type ~ ' OR ' ~ $.battery-type;
        return ProductSearch::find($ss);
    }
}
````

This is perhaps the most typical use of roles, but not the only one. Roles can also be taken and mixed in to an object (on a per-object basis, not a per-class basis) using the `does` and `but` operators, and if filled only with stub methods will act like interfaces in Java and C#. I won’t talk any more about those in this post, though: instead, I want to show you how roles are also Raku’s way of achieving generic programming, or parametric polymorphism.

Roles can also take parameters, which may be types or just values. For example, we may have a role that we apply to products that need to having a delivery cost calculated. However, we want to be able to provide alternative shipping calculation models, so we take a class that can handle the delivery calculation as a parameter to the role.

```` raku
role DeliveryCalculation[::Calculator] {
    has $.mass;
    has $.dimensions;
    method calculate($destination) {
        my $calc = Calculator.new(
            :$!mass,
            :$!dimensions
        );
        return $calc.delivery-to($destination);
    }
}
````

Here, the `::Calculator` in the square brackets after the role name indicates that we want to capture a type object and associate it with the name `Calculator` within the body of the role. We can then use that type object to call `.new` on it. Supposing we had written classes that did shipping calculations, such as `ByDimension` and `ByMass`, we could then write:

```` raku
class Furniture does DeliveryCalculation[ByDimension] {
}
class HeavyWater does DeliveryCalculation[ByMass] {
}
````

In fact, when you declare a role with parameters, what goes in the square brackets is just a signature, and when you use a role what goes in the square brackets is just an argument list. Therefore you have the full power of Raku signatures at your disposal. On top of that, roles are `multi` by default, so you can declare multiple roles with the same short name, but taking different types or numbers of parameters.

As well as being able to parametrize roles using the square bracket syntax, it is also possible to use the `of` keyword if each role takes just one parameter. Therefore, with these declarations:

```` raku
role Cup[::Contents] { }
role Glass[::Contents] { }
class EggNog { }
class MulledWine { }
````

We may now write the following:

```` raku
my Cup of EggNog $mug = `get_eggnog`;
my Glass of MulledWine $glass = `get_wine`;
````

You can even stack these up.

```` raku
role Tray[::ItemType] { }
my Tray of Glass of MulledWine $valuable;
````

The last of these is just a more readable way of saying `Tray[Glass[MulledWine]]`. Cheers!
