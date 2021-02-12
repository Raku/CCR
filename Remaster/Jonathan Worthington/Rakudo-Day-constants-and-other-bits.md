# Rakudo Day: constants, and other bits
    
*Originally published on [29 April 2009](https://use-perl.github.io/user/JonathanWorthington/journal/38888/) by Jonathan Worthington.*

```` raku
constant Pi = 3.14;
say Pi; # 3.14
Pi = 42; # error
````

If your Rakudo is built with ICU, you can use unicode characters for the name too. :-) Also, you can use a name with a sigil:

```` raku
constant $pi = 3.14;
say $pi; # 3.14
$pi = 42; # error
````

And even use the constant as a type constraint...

```` raku
constant answer = 42;
my answer $x = 42; # ok
$x = 43; # dies
````

*masak* asked if we could possibly report the provided and expect types when reporting type-check failures, to give better feedback. I implemented this, and also managed to simplify and fix another bug inside the signature binder along the way, which had meant the following would not work:

```` raku
sub foo(@a) { say @a.elems }
foo([1,2]|[3,4,5]);
````

This will now auto-thread and call foo twice, the first time outputting 2 and the second time 3.

I also fixed a couple of other little bugs in Rakudo.

- You could not write things like `module Foo { if 1 { say 42 } }` (basically, anything involving an inner non-routine block placed directly inside a package). This is now fixed.
- Subtypes based upon user-defined classes and roles didn't always work. I fixed this up and added tests.
- We did a poor job of reporting typed arrays and hashes hashes when doing `.raku` on a `Signature` (which is what the multi-dispatcher does on ambiguity reports). I did some work to improve the output here.

Finally, *Tene* has been working for a while on getting Rakudo to live in its own HLL namespace in Parrot, which will enable us to clear up a few other things and no doubt resolve a few tickets (it'll stop us colliding with Parrot internal bits for one). There was some debugging work to do, so I spent a couple of hours on this, and got us a lot further than we were. Still much to do, but we'll get there.

Thanks to Vienna.pm for sponsoring this Rakudo Day.
