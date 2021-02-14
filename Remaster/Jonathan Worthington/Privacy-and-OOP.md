# Privacy and OOP
    
*Originally published on [11 December 2011](https://perl6advent.wordpress.com/2011/12/11/privacy-and-oop/) by Jonathan Worthington.*

There are a number of ways in which Raku encourages you to restrict the scope of elements of your program. By doing so, you can better understand how they are used and will be able to refactor them more easily later, potentially aiding agility. Lexical scoping is one such mechanism, and subroutines are by default lexically scoped.

Let’s take a look at a class that demonstrates some of the object oriented related privacy mechanisms.

```` raku
class Order {
    my class Item {
        has $.name;
        has $.price;
    }
    
    has Item @!items;
    
    method add_item($name, $price) {
        @!items.push(Item.new(:$name, :$price))
    }
    
    method discount {
        self!compute_discount
    }
    
    method total {
        self!compute_subtotal - self!compute_discount;
    }
    
    method !compute_subtotal {
        [+] @!items>>.price
    }
    
    method !compute_discount {
        my $sum = self!compute_subtotal;
        if $sum >= 1000 {
            $sum * 0.15
        }
        elsif $sum >= 100 {
            $sum * 0.1
        }
        else {
            0
        }
    }
}
````

Taking a look at this, the first thing we notice is that `Item` is a lexical class. A class declared with `my` scope can never be referenced outside of the scope it is declared within. In our case, we never leak instances of it outside of our Order class either. This makes our class an example of the aggregate pattern: it prevents outside code from holding direct references to the things inside of it. Should we ever decide to change the way that our class represents its items on the inside, we have complete freedom to do so.

The other example of a privacy mechanism at work in this class is the use of private methods. A private method is declared just like an ordinary method, but with an exclamation mark appearing before its name. This gives it the same visibility as an attribute (which, you’ll note, are also declared with an exclamation mark – a nice bit of consistency). It also means you need to call it differently, using the exclamation mark instead of the dot.

Private methods are non-virtual. This may seem a little odd at first, but is consistent: attributes are also not visible to subclasses. By being non-virtual, we also get some other benefits. The latest Rakudo, with its optimizer cranked up to its highest level, optimizes calls to private methods and complains about missing ones at compile time. Thus a typo:

```` raku
self!compite_subtotal - self!compute_discount;
````

Will get us a compile time error:

````
===SORRY!===
CHECK FAILED:
Undefined private method 'compite_subtotal' called (line 18)
````

You may worry a little over the fact that we now can’t subclass the discount computation, but that’s likely not a good design anyway; for one, we’d need to also expose the list of items, breaking our aggregate boundary. If we do want pluggable discount mechanisms we’d probably be better implementing the strategy pattern.

Private methods can, of course, not be called from outside of the class, which is also a compile time error. First, if you try:

```` raku
say $order!compute_discount;
````

You’ll be informed:

```` raku
===SORRY!===
Private method call to 'compute_discount' must be fully qualified
with the package containing the method
````

Which isn’t so surprising, given they are non-virtual. But even if we do:

```` raku
say $o!Order::compute_discount;
````

Our encapsulation-busting efforts just get us:

```` raku
===SORRY!===
Cannot call private method 'compute_discount' on package Order
because it does not trust GLOBAL
````

This does, however, hint at the get-out clause for private methods: a class may choose to trust another one (or, indeed, any other package) to be able to call its private methods. Critically, this is the decision of the class itself; if the class declaration didn’t decide to trust you, you’re out of luck. Generally, you won’t need `trusts`, but occasionally you may be in a situation where you have two very closely coupled classes. That’s usually undesirable in itself, though. Don’t trust too readily. :-)

So, lexical classes, private methods and some nice compiler support to help catch mistakes. Have an agile advent. :-)
