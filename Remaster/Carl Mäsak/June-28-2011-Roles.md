# June 28 2011: Roles
    
*Originally published on [6 July 2011](http://strangelyconsistent.org/blog/june-28-2011-roles) by Carl Mäsak.*

Having learned how to create classes, we might go on to create them to our hearts' content:

```raku
class Hammer {
    method hammer($stuff) {
        say "You hammer on $stuff. BAM BAM BAM!";
    }
}
class Gavel {
    method hammer($stuff) {
        say "You hammer on $stuff. BAM BAM BAM!";
    }
}
class Mallet {
    method hammer($stuff) {
        say "You hammer on $stuff. BAM BAM BAM!";
    }
}
```

But... notice something here? These three classes contain the exact same method, repeated in each class. We *have* to do that if we want each of `Hammer`, `Gavel` and `Mallet` to have the ability to `hammer`. (And that's reasonable.) But it's a pity that we have to triplicate the method.

Why is it a pity? Well, it's more to write, for one thing. Also, the methods might not be this close to each other in a real-world example, and one day we may decide to change something in the `hammer` method, not realizing that it's in three different places... which generally leads to a bunch of pain and suffering.

So here we are, with this new toy, classes, and already they exhibit a problem. We'd somehow like to *re-use* the `hammer` method in each three classes.

A new concept, the *role* comes to our rescue:

```raku
role Hammering {
    method hammer($stuff) {
        say "You hammer on $stuff. BAM BAM BAM!";
    }
}
```

Whereas classes are often named after an appropriate noun, roles are often named after a participle, such as `Hammering`. It's not a hard-and-fast rule, but it's a good rule of thumb. I really shouldn't be talking about thumbs, what with all the hammering going on...

Now the class definitions become easy:

```raku
class Hammer does Hammering {}
class Gavel  does Hammering {}
class Mallet does Hammering {}
```

Ah, yes. We *like* that.

What's happening under the hood when we do `does` on a class? All the methods from the role definition are copied into the class definition. Since it's a copy operation, we can do it with as many classes as we want.

So, here's what we do: we put methods in roles when we figure we'll re-use them.

But that's not the only benefit we get. There's at least two more:

```raku
my $hammer = Hammer.new;    # create a new hammer object
say $hammer ~~ Hammer;      # "Bool::True" -- yes, this we know
say $hammer ~~ Hammering;   # "Bool::True" -- ooh!
```

So the `$hammer` knows that it does `Hammering`. Essentially, we now have a way to ask not only what class an object belongs to, but also what roles it incorporates. That's useful if we're unsure what kind of object we're dealing with:

```raku
if $unkown_object ~~ Hammering {
    $unknown_object.hammer("that nail over there");     # will always work
}
```

Can a class take on several roles at once? Yes, it can:

```raku
role Flying {
    method fly {
        say "Whooosh!";
    }
}
class FlyingHammer does Hammering does Flying {}
```

Having a class do several roles in that way introduces an interesting possibility: that of *conflicts*, when two methods with the same name from two different roles try to occupy the same class. What happens in such a case? Well, there are at least three possibilities:

- First role wins. Its method gets to live in the class.
- Last role wins. It overwrites the previous method.
- Compilation fails. The conflict has to be resolved.

And option 3 is the right answer in this case. The reason for this is the same as before: as classes and projects grow larger, the programmer might not *realize* that there's a conflict between two roles somewhere. So we flag it.

```raku
role Sleeping {
    method lie {
        say "Reclining horizontally...";
    }
}
role Lying {
    method lie {
        say "Telling an untruth...";
    }
}
class SleepingLiar does Sleeping does Lying {}    # CONFLICT!
```

Next question, then: when there's a role conflict in a class, how do we fix it? Simple: by defining a method with that name in the class itself:

```raku
class SleepingLiar does Sleeping does Lying {
    method lie {
        say "Lying in my sleep....";
    }
}
```

If you want to call a method from a particular role, there's a syntax for that:

```raku
class SleepingLiar does Sleeping does Lying {
    method lie {
        self.Sleeping::lie;
    }
}
```

And that's roles. They mix in reusable behavior into classes.

Now, we're finally ready to tackle that text adventure of ours!
