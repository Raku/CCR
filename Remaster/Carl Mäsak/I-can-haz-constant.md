# I can haz constant?
    
*Originally published on [22 April 2010](http://strangelyconsistent.org/blog/i-can-haz-constant) by Carl Mäsak.*

Let's try this format. Mixing #raku IRC logs with more detailed explanations, sort of like a movie and a commentator track.

```
<masak> over lunch, since I'm so into scoping of different kinds right now, we got to talking about class-bound variables again. my colleague jonalv, whose home language is Java, thought that it was a shocking omission not to have class-based variables.
<masak> I explained how 'my' and 'our' didn't do what was intended, since lexpads and packages are orthogonal to OO inheritance.
```

"Orthogonal" is quickly becoming one of my favourite terms in language design. It doesn't mean "at an angle of ninety degrees", but rather "along independent dimensional axes", that is, "not having anything to do with one another".

The two things that are orthogonal here are ordinary variable scoping on the one hand, and (method) inheritance on the other. In particular, a deriving class typically isn't lexically nested inside its base class, nor is it a subpackage of it, not even in the case of `A::B` deriving from `A`. (Unless they're nested in code, but in the general case they aren't.)

```
<masak> when I talked about 'state' variables, he was a bit mollified and admitted that the need wasn't as great for class-bound variables.
<masak> and when I explained about the non-need for class-level methods due to type objects, I had almost convinced myself that we don't need class/static variables :)
<masak> but one use case that I can see is something akin to a constant defined in a class, which ought to be reachable from all its methods and the methods in derived classes.
```

When I learned about `static` fields in Java, even the examples were contrived. They looked much like this:

```raku
class Car { // this is Java code
    static long cars_produced = 0;
    public `Car` {
        ++cars_produced;
    }
}
```

Here's where Raku's `state` initializer feels a *little* bit like Java's `static` scope declarator.

```raku
class Car { # this is Raku code
    submethod `BUILD` {
        state $cars-produced = 0;
        ++$cars-produced;
    }
}
```

In both pieces of code above, the variable counting all the cars ever produced since the beginning of the program will begin at 0 and increase by one every time we construct a new car.

However, the visibility is different. In Raku, the variable is only visible inside the `BUILD` submethod. If we want all methods to see it, we'll have to move it out to the larger class scope. (And then we don't need `state`, because the class block is only run once. We can use `my` to tie it to the lexical class block, or `our` to tie it to the class package. In the latter case, it can be referred to from the outside as `Car::cars-produced`.)

But that *still* doesn't give us the inheritance that we like to associate with classes. The Java code would keep ticking up cars even if we derived a `RollsRoyce` class from `Car`, as long as we called ``super`` from within the `RollsRoyce` constructor. The Raku code will behave the same (and automatically) since we put our initialization in the `Car.BUILD` submethod, which would get called by `RollsRoyce.BUILDALL`. But in Raku, we can only *see* the variable when inside `Car`, not when inside `RollsRoyce`. Java doesn't have this issue.

Excuse the crappy non-real-life example. 哈哈 But two more realistic use cases bring us back to the IRC discussion in question.

The first is one or more constants that a class might want to share with its deriving classes. That feels pretty natural. The second is enums, which are basically constants packaged in a convenient form.

I like throwing out items for discussion like this on #raku. You never know who will pick them up, but I usually learn something from them, and sometimes the spec even gets improved as a result. This time, *TimToady* replied:

```
<*TimToady*> std: has constant $.pi = 3;
<p6eval> std 30419: OUTPUT«ok 00:01 110m␤»
<jnthn> o.O
<*TimToady*> *masak*++ was conjecturing class-based constants, but it already falls out
<*TimToady*> in fact, that was one of the reasons the constant declarator moved from being a scope_declarator to being a type-declarator, so we could use it in arbitrary scopes
```

Well, that does take care of the constants use case. Nice! You use `has` and twigils to get you the inheritance behaviour. Why didn't I think of that?

Here's why I think it's extra nice: rather than make this an issue of scoping and visibility, the `has constant` construct makes it an issue of *immutability*. Given this information, the compiler is free to optimize as much as it can, but (unlike Java) we never had any need to invent a "class level" scope, where static things are stored. That aligns with the rest of Raku; we don't have 'static methods' either, for example — but you can achieve much the same things through other means.

```
<masak> *TimToady*: 'has constant' still makes me happy. what's my best solution if I want to do something similar with an enum? (i.e. share it between a class and all its descendants.) enum is also a type declarator, but the name doesn't have a twigil...
[...]
<*TimToady*> masak: testing a patch for 'has enum $.meth <foo bar>'
<masak> *TimToady*: \o/
```

I love it when existing parts of the design just melt together into something even more useful than the sum of its constituent parts. The fact that I can be part of that process makes the work on Raku feel much less like work and much more like an adventure.

So now, I can haz constant! And enums! I expect they will come in handy, especially since I will be on the lookout for possible uses for them.

As for class-based *variables*, Raku still doesn't have them. I don't see a similarly good way to add them to the language. On the other hand, I also don't have a better use case for them than that crappy `Car` example.
