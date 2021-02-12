# Attributes, Attributes, Attributes!
    
*Originally published on [13 June 2008](https://use-perl.github.io/user/JonathanWorthington/journal/36677/) by Jonathan Worthington.*

After not sleeping great, it took a couple of cups of tea to get me going this morning. I like coffee too, but haven't gotten around to getting myself a good coffee machine for this place yet, and nice tea beats instant coffee. (And this is how you know that, even though I live in Slovakia, my inner Britt is still alive.) Anyway, while I was getting properly conscious, and before digging into the main task of the day, I did a little more work on ranges: essentially, getting the versions of the range operator with endpoints to work. Thus you can now do:

```` raku
say $_ for 1..5;    # 1\n2\n3\n4\n5\n
say $_ for 1^..5;   # 2\n3\n4\n5\n
say $_ for 1..^5;   # 1\n2\n3\n4\n
say $_ for 1^..^5;  # 2\n3\n4\n
````

So, that's another little bit of progress on ranges. Now, onto the meaty stuff. Today was, as the title hints, about attributes. For a while, you've been able to declare attributes on classes in Rakudo, but the support has been fairly primitive. Today I expanded it someone, and then I dug into getting composition of attributes from roles working. Composition of methods has worked for a while, but until today there was no support for attribute composition. So, some details.

First, accessor/mutator methods are now generated correctly. If you now write:

```` raku
has $.badgers;
````

Then you get an accessor method. Trying to use it as an lvalue will now fail, as per the specification. If you want to have a mutator as well as an accessor, then you must write:

```` raku
has $.badgers is rw;
````

Additionally, while you could put type constraints on variables and `sub` / `method` parameters before now, you couldn't put them on attributes. As of today, you can do so.

```` raku
has Int $.badgers is rw;
````

And, as with variables, if you don't supply an initialization value, then in the case above your badgers attribute will be initialized to an `Int` proto-object. If you specify a role or some more complex or junctional type, then you just get a `Failure` object. Talking of junctional types, you can now list many types on variables (and attributes) and get them all enforced.

```` raku
subset Percent of Int where 1..100;
subset Even of Int where { $^n % 2 == 0 };
my Even Percent $x = 42;   # OK
my Even Percent $y = 101;  # Type check failed
my Even Percent $z = 11;   # Type check failed
````

You can write disjunctions as well, according to The Spec, but I've not figured out how STD.pm proposes we parse those yet.

Then came getting attributes in roles working. In roles there are two ways to introduce attributes: with `has` and with `my`. If you introduce a private attribute (the only kind you can introduce) with `my`, then it is role private. It will not be accessible outside of the role (including in the class it is composed into or in other roles), will always get a slot of its own and will never conflict with attributes of the same name either in the class or from other roles. It is, as `my` suggests, lexically scoped within that role and invisible outside of it.

The other thing you can do is introduce attributes that get composed into the class, with `has`. In this case, the semantics of the attribute are the same as if you had declared it in the class itself. However, you may also get a composition conflict. This happens when both the class and a role, or many roles, introduce attributes with the same name but different types. Basically, if there are multiple declarations of an attribute of the same name and they all have the same type, then they will all share one storage location. If they differ in type, it's a conflict (at composition time). This sounds odd at first, but actually makes properties work nicely.

All of what I just described is implemented as of today, and I've written basic tests for some of it (and more are to come, but I'm too tired to do any more today). It's a lot of detail, but I will try to explain it with some more concrete examples over the coming weeks as I get more progress in on roles. (I'll also talk about it in my Raku OO talk at YAPC::EU, if you're going to be there; the slides will be available for everyone after the conference too.) Once again, a big thanks to Vienna.pm for funding this work.
