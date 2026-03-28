# June 27 2011: Classes
    
*Originally published on [4 July 2011](http://strangelyconsistent.org/blog/june-27-2011-classes) by Carl Mäsak.*

I thought I'd get philosophical as we get further into this post, but first let's jump right into an example:

```raku
my Bool $collected = False;
sub dispense_ticket {
    return "Sorry, you already got a ticket."
        if $collected;
    $collected = True;
    return "Here's your free ticket. Lunch is on us today. Enjoy!";
}
say dispense_ticket;    # "Here's your free ticket..."
say dispense_ticket;    # "Sorry, you already got a ticket."
say dispense_ticket;    # "Sorry, you already got a ticket."
```

So. It's a function that only "works once". With the `$collected` variable, we can keep track of whether the `dispense_ticket` subroutine has been called before. The variable contains a little bit of *state* that helps the subroutine remember what's happened before.

But &mdash; as usual &mdash; there's a problem. Some greedy people figure out that they can just do `$collected = False` in the code before calling `dispense_ticket`, and with that neat little trick they can have unlimited lunches for themselves *and* their pet lizards. The system is too open; something needs to be done.

First, let's discuss a solution that would not work: putting the data inside an array or a hash. That kind of "hiding" makes the information slightly more cumbersome to access, but someone who really wanted to change the value would essentially be as able to as before. Arrays and hashes are "transparent" in the sense that anyone who can see them, can also see inside them.

The real solution involves a new type of data structure besides arrays and hashes. Let me introduce the *class*:

```raku
class Dispenser {
    has Bool $!collected;
    method dispense_ticket {
        return "Sorry, you already got a ticket."
            if $!collected;
        $!collected = True;
        return "Here's your free ticket. Lunch is on us today. Enjoy!";
    }
}
my $d = Dispenser.new;
say $d.dispense_ticket;    # "Here's your free ticket..."
say $d.dispense_ticket;    # "Sorry, you already got a ticket."
say $d.dispense_ticket;    # "Sorry, you already got a ticket."
```

Whoa, whoa! Ok, the program sort of looks like it did before, but there's a bunch of new stuff there as well. Let's go through them one by one.

- The state variable and the sub are now in a `class` block. In putting them there, we're also *defining* a new class called `Dispenser`; we're adding a new type to the program, just as we did yesterday with the `subset` declaration. Only this time, we're not just specializing an old type; we're defining a completely new one.
- The `my` in the variable declaration has mutated to `has`, and there's a new, strange bang sign (`!`) after the sigil! Don't panic; these two changes are related. By this mechanism, we're basically saying that the variable belongs not to the class itself, but to any *object* of that class. Variables belonging to objects in this way are called *attributes*.
- The `sub` keyword has mutated to being a `method`. That's fine; we're already familiar with methods from before and know they're called with a dot, like this: `$d.dispense_ticket`. And that turns out to be what we then do.
- Before we can get out our only ticket, we have to create a new `Dispenser` object. We do that by calling the `.new` method on `Dispenser`. That's not a method we defined; every class gets a (default) `.new` method for free.

The goal we wished for &mdash; that of *encapsulating* the state within a barrier &mdash; has now been reached. There's no honest way someone can reach the `$!collected` attribute inside the `$d` object and flip its bit. The state is protected from the outside world, and the `Dispenser` class has full control over it.

Now let's review what new concepts fell out of this little exercise.

A **class** is something like a blueprint of a group of similar things. We call these things **objects**. In the example above, `Dispenser` is a class and `$d` contains an object of that class. (Objects are always objects *of* some class or other. Often we hear the term "**instance** of a class", as well. Same thing.)

An object generally contains *state* (**attributes**) as well as *behavior* (**methods**). We recognize the attributes as regular variables, but what's different this time around is that they *belong* to an object, and they're *hidden* inside that object. We call this **encapsulation**. (Literally, "forming a shell around".) The methods of a class have access to an object's attributes &mdash; like `dispense_ticket` has to `$!collected` above &mdash; but things outside of the class don't have access to attributes.

This is where I wax a bit philosophical. The thought of classes and objects is very ingrained in our collective unconscious, because they've been a part of philosophical thinking for two millennia and a half: Plato spoke about *forms* or *ideas*, these are the unchanging abstract entities on which real-world objects supposedly are based.

So every mug you've seen in your life would, according to Plato, belong to this ideal `Mug` form; would, let's say, be an instance of that form. Every dog would be an instance of `Dog`; every box would be an instance of `Box`... all physical things in the world would just be imperfect realizations of their corresponding perfect ideals. According to Plato.

It's because of this ancient subdivision that we tend to have both classes *and* objects when programming. The class takes care of the collective concerns, like the declaration of attributes and methods, whereas the objects take care of the nitty-gritty stuff, such as actually interacting with the program.

The line is (intentionally) blurry sometimes. The class `Dispenser` behaves very much like an object when we call `.new` on it, for example. That's good, because we need to call `.new` on *something*.

Speaking of which...

```raku
my $d1 = Dispenser.new;
say $d1.dispense_ticket;    # "Here's your free ticket..."
say $d1.dispense_ticket;    # "Sorry, you already got a ticket."
my $d2 = Dispenser.new;
say $d2.dispense_ticket;    # "Here's your free ticket..."
```

Oops. `:-)```

Well, we could have predicted this would happen. (Both from a that's-how-attributes-work standpoint, and from a people-will-do-anything-for-free-lunch standpoint.) We have not eliminated the problem of people getting multiple free lunches, but we have *contained* the problem, and now we only have to solve the &mdash; hopefully simpler &mdash; issue of preventing `Dispenser` propagation. (Hm... a singleton? Or some kind of authentication mechanism?)

It turns out that as your programs grow bigger and bigger, they also grow more complex and difficult to maintain. Subroutines were introduced as a way to keep the complexity in check, and divide up the program in smaller part. Classes are the same kind of medicine, but they go one step further by actually encouraging encapsulation of state within objects.

Objects: they encapsulate state, and regulate the ways you can modify that state. They're little worlds in themselves, worlds where you, the author, make the rules.

Now if you'll excuse me, I have to go refill the dispenser. People are grabbing tickets like crazy...
