# How to mangle the initial state
    
*Originally published on [20 December 2013](https://perl6advent.wordpress.com/2013/12/20/day-20-how-to-mangle-the-initial-state/) by Elizabeth Mattijsen.*

The past year saw the (at least partial) implementation of several variable traits.  But before we get into that, the past year **also** saw *Nil* getting implemented closer to spec in Rakudo. If you read [the spec](http://design.raku.org/syn/S02.html#Nil), you will know that `Nil` indicates the **absence** of a value.  This is different from being undefined, as we saw [in an earlier blogpost this year](https://rakuadvent.wordpress.com/2013/12/02/day-02-the-humble-type-object/).  So what does that mean?

```` raku
$ raku -e 'my $a = 42; say $a; $a = Nil; say $a'
42
(Any)
````

So, assigning `Nil` will reset a scalar container to its default value, which (by default) is the type object of that container.  Which is *(Any)* if nothing is specifically specified.

## Enter the "is default" variable trait

If you want to specify the default value of a variable, you can now use the `is default` variable trait:

```` raku
$ raku -e 'my $a is default(42); say $a; say $a.defined’
42
True
````

So oddly enough, even though we haven’t assigned anything to the variable, it now has a defined value.  So let’s assign something else to it, and then assign `Nil`:

```` raku
$ raku -e 'my $a is default(42) = 69; say $a; $a = Nil; say $a'
69
42
````

Of course, this is a contrived example.

## "is default" on arrays and hashes

It gets more interesting with arrays and hashes. Suppose you want a Bool array where you can only switch "off" elements by assigning False?  That is now possible:

```` raku
$ raku -e 'my Bool @b is default(True); say @b[1000]; @b[1000]=False; say @b[1000]'
True
False
````

Of course, type checks should be in place when specifying default values.

```` raku
$ raku -e 'my Bool $a is default(42)'
===SORRY!=== Error while compiling -e
Type check failed in assignment to '$a'; expected 'Bool' but got 'Int’
````

Note that this type check is occurring at compile time.  Ideally, this should also happen with arrays and hashes, but that doesn’t happen just yet.  Patches welcome!

Using `is default` on arrays and hashes interacts as expected with `:exists` (well, at least for some definition of expected :-):

```` raku
$ raku -e 'my @a is default(42); say @a[0]; say @a[0].defined; say @a[0]:exists'
42
True
False
````

Note that even though each element in the array appears to have a defined value, it does **not necessarily** exist.  Personally, I would be in favour of expanding that to scalar values as well, but for now `:exists` does not work on scalar values, just on slices.

## It’s not the same as specifying the type

What’s wrong with using type objects as default values?  Well, for one it doesn’t set the **type** of the variable.  Underneath it is still an *(Any)* in this case:

```` raku
$ raku -e 'my $a is default(Int) = "foo"; say $a'
foo
````

So you don’t get any type checking, which is probably **not** what you want (otherwise you wouldn’t take all the trouble of specifying the default).  So don’t do that!  Compare this with:

```` raku
$ raku -e 'my Int $a = "foo"'
Type check failed in assignment to '$a'; expected 'Int' but got 'Str'
````

Which properly tells you that you’re doing something wrong.

## Nil assigns the default value

Coming back to `Nil`: we already saw that assigning it will assign the default value.  If we actually specify a default value, this becomes more clear:

```` raku
$ raku -e 'my $a is default(42) = 69; say $a; $a = Nil; say $a'
69
42
````

In the context of arrays and hashes, assigning `Nil` has a subtly different effect from using the `:delete` adverb.  After assigning Nil, the element **still** exists:

```` raku
$ raku -e 'my @a is default(42) = 69; say @a[0]; @a[0] = Nil; say @a[0]:exists'
69
True
````

Compare this with using the `:delete` adverb:

```` raku
$ raku -e 'my @a is default(42) = 69; @a[0]:delete; say @a[0]; say @a[0]:exists'
42
False
````

One could argue that assigning Nil (which assigns the default value, but which is **also** specced as indicating an absence of value) should be the same as deleting.  I would be in favour of that.

## Argh, I want to pass on Nil

The result of a failed match, now also returns `Nil` (one of the other changes in the spec that were implemented in Rakudo in the past year).  However, saving the result of a failed match in a variable, will assign the default value, losing its Nilness, Nilility, Nililism (so much opportunity for creative wordsmithing :-).

```` raku
$ raku -e 'my $a = Nil; say $a'
(Any)
````

It turns out you can specify `Nil` as the default for a variable, and then It Just Works™

```` raku
$ raku -e 'my $a is default(Nil) = 42; say $a; $a = Nil; say $a'
42
Nil
````

## Introspection

You can use the `VAR` macro to introspect variables to find out its default value, without having to do something as destructive as assigning Nil to it:

```` raku
$ raku -e 'my @a is default(42); say @a.VAR.default'
42
````

This also works on system variables like `$/`:

```` raku
$ raku -e 'say $/.VAR.default'
Nil
````

And can also be used to interrogate other properties:

```` raku
$ raku -e 'say $/.VAR.dynamic’
True
````

But this gets us into material for a blog post for another day!

## Conclusion

The `is default` variable trait allows you to manipulate the default value of variables and elements in arrays and hashes.  Together with the new meaning of `Nil`, it is a powerful means of mangling initial values of variables to your satisfaction.

