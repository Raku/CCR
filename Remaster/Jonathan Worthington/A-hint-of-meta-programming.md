# A hint of meta-programming
    
*Originally published on [2011-08-01](https://6guts.wordpress.com/2011/08/01/a-hint-of-meta-programming/) by Jonathan Worthington.*

After a few patches to deal with some meta-circularity issues, I’ve got to the point where I have at least a very basic example of a custom meta-class working in the nom branch of Rakudo. All this does is print out the name of each method that gets looked up, before deferring to the normal handling of method dispatch. However, I’m sure that now that I’m at this point, much more interesting things are already very possible, though no doubt there’s some rough edges I still need to deal with.

Anyways, to the code! Here’s a module, LoggedDispatch.pm.

```` raku
my class LoggedDispatch is Metamodel::ClassHOW is Mu {
    method find_method($obj, $name) {
        note "Looking up method $name";
        nextsame;
    }
    
    method publish_method_cache($obj) {
        # Suppress this, so we always hit find_method.
    }
}

# Export this as the meta-class for the "class" package declarator.
my module EXPORTHOW { }
EXPORTHOW.WHO.<class> = LoggedDispatch;
````

Taking it from the top, we inherit from `Metamodel::ClassHOW`, which is the default implementation of Raku classes. There’s actually no requirement to do this – in some future posts I’ll show you how you can easily piece together meta-classes from the ground up – but in this case all we really want to do is a small tweak to the existing behavior. For now, we also inherit from `Mu`. (Aside: at the moment, since `ClassHOW` is what defines classes, it falls “outside” of the Raku type hierarchy. That’s in some ways understandable but also in some ways very awkward. I’ve more than one approach to dealing with this, but need to think more on the problem.)

Now, on to the meat of the problem. Conceptually, every method dispatch on an object gets that object’s meta-object and calls `find_method` on it, passing in the method name to find. Therefore, in order to intercept this, we need to override `find_method` – which is what we do. We simply print the name of the method to STDERR using `note`, then use `nextsame` to defer to the actual method lookup algorithm. Pretty easy. However, there’s a twist.

As you might imagine, dispatching methods is a hot-path. If we have to call a method in order to work out what method to call – and if that had to do the same in turn – things would get really very slow indeed. Thus, it’s possible to publish a method cache, which is dead fast to look in. However, it’s also going to mean that `find_method` never gets called – which is where we’re going to put our logging stuff. While for an optimized version of this we could compute a bunch of closures to do the logging and populate a cache with those, for now we just suppress generation of the cache.

That gets us down to the last bit. There’s a (lexical) `EXPORT` package for exporting symbols, but we want to do something a bit different here: we want to tell the compiler that when this module is used, it should use our meta-class whenever the user writes a class (that is, uses the package declarator `class`). For now (note, API liable to change) that’s done by installing an entry in an `EXPORTHOW` module.

And with that, we’re done. Here’s an example program.

```` raku
use LoggedDispatch;

class A {
    method `m1` { say 42 }
    method `m2` { say 99 }
}

for 1..2 {
    A.m1;
    A.m2;
}
````

And here’s the output:

````
Looking up method BUILD
Looking up method m1
42
Looking up method m2
99
Looking up method m1
42
Looking up method m2
99
````

The first line of this may be a little surprising – something goes looking for a `BUILD` method at some point. But it’s maybe not such a surprise: it’s a method with special meaning to object construction, and we can imagine that at some stage during the class composition, something got interested in whether the class had one (in this case, it’s the bit of code that creates a build plan, in order to optimize object instantiation).

At the start of the post, I used the term meta-circularity. If you weren’t sure what it meant, you’re now in a position to understand it. Here, we wrote a Raku class to extend the meaning of Raku classes. Meta-circularity is very simply the property of being able to use a language to extend itself, rather than having to do so by going and writing some other special or lower-level language to do so. And I’m really happy that I’ve been able to tie up the last few loose ends so that we can start to do that in the nom branch now.
