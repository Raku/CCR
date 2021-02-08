How naming of variables works in Raku
=====================================

In the first four articles in this series comparing Perl to Raku, we looked into some of the issues you might encounter [when migrating code](Migrating-Perl-code-to-Raku.md), how [garbage collection works](Garbage-Collection-in-Raku.md), why [containers replaced references](Containers-in-Raku.md), and using [(subroutine) signatures](How-Subroutine-Signatures-work-in-Raku.md) in Raku and how these things differ from Perl.

Here, in the fifth article, we will look at the subtle differences in [sigils](https://www.perl.com/article/on-sigils/) (the symbols at the start of a variable name) between Perl and Raku.

An overview
-----------

Let's start with an overview of sigils in Perl and Raku:

| Sigil | Perl       | Raku        |
| :---: | :--------: | :---------: |
|   @   | Array      | Positional  |
|   %   | Hash       | Associative |
|   &   | Subroutine | Callable    |
|   $   | Scalar     | Item        |
|   *   | Typeglob   | n/a         |

When you define an array in Perl, you create an expandable list of scalar values and give it a name with the sigil **@**:

```` perl
# Perl
my @foo = (1,2,3);
push @foo, 42;
say for @foo;  # 1␤2␤3␤42␤
````

When you define an array in Raku, you create a new [**Array**](https://docs.raku.org/type/Array) object and *bind* it to the entry by that name in the lexical pad. So:

```` raku
# Raku
my @foo = 1,2,3;
push @foo, 42;
.say for @foo;  # 1␤2␤3␤42␤
````

is functionally the same as in Perl. However, the first line is syntactic sugar for:

```` raku
# Raku
my @foo := Array.new( 1,2,3 );
````

This binds (rather than assigns) a new **Array **object to the lexically defined name **@foo**. The **@** sigil in Raku indicates a type constraint: if you want to bind something into a lexpad entry with that sigil, it *must* perform the **[Positional](https://docs.raku.org/type/Positional.html)** role. It's not hard to determine whether a class performs a certain role using smartmatch:

```` raku
# Raku
say Array ~~ Positional;   # True
````

You could argue that all arrays in Raku are implemented in the same way as [tied arrays](https://perldoc.perl.org/functions/tie.html) are implemented in Perl. And that would not be far from the truth. Without going too deep into the specifics, a simple example might clarify this. The **AT-POS** method is one of the key methods of a class implementing the **Positional** role. This method is called whenever a single element needs to be accessed. So, when you write:

```` raku
# Raku
say @a[42];
````
you are executing:

```` raku
# Raku
say @a.AT-POS(42);
````

Of course, this is not the only method you could implement; there are [many more](https://docs.raku.org/language/subscripts#Methods_to_implement_for_positional_subscripting).

Rather than having to bind your class performing the **Positional** role, there's a special syntax using the **is** trait. So instead of having to write:

```` raku
# Raku
my @a := YourClass.new( 1,2,3 );
````

you can write:

```` raku
# Raku
my @a is YourClass = 1,2,3;
````

In Perl, tied arrays are notoriously slow compared to "normal" arrays. In Raku, arrays are similarly slow at startup. Fortunately, Rakudo optimizes hot-code paths by inlining and "just in timing" (JITing) [opcodes](https://en.wikipedia.org/wiki/Opcode) to machine code where possible. (Thanks to advancements in the optimizer, this happens sooner, more often, and better).

% (Hash vs. Associative)
------------------------

Hashes in Raku are implemented similarly to arrays; you could also consider them a tied hash (using Perl terminology). Instead of the **Positional** role used to implement arrays, the **[Associative](https://docs.raku.org/type/Associative)** role should be used to implement hashes.

Again, a simple example might help. The **AT-KEY** method is one of the key methods of a class implementing the **Associative** role. This method is called whenever the value of a specific key needs to be accessed. So, when you write:

````
# Raku
say %h<foo>;
````

you are executing:

````
# Raku
say %h.AT-KEY("foo");
````

Of course, there are [many other methods](https://docs.raku.org/language/subscripts#Methods_to_implement_for_associative_subscripting) you could implement.

& (Subroutine vs. Callable)
---------------------------

In Perl, there is only one type of callable executable code, the subroutine:

```` perl
# Perl
sub frobnicate { shift ** 2 }
````

And, if you want to pass on a subroutine as a parameter, you need to get a reference to it:

```` perl
# Perl
sub do_stuff_with {
    my $lambda = shift;
    &$lambda(shift);
}
say do_stuff_with( \&frobnicate, 42 );  # 1764
````

In Raku, multiple types of objects can contain executable code. What they have in common is that they consume the **[Callable](https://docs.raku.org/type/Callable)** role.

The **&** sigil forces binding to an object performing the **Callable** role, just like the **%** sigil does with the **Associative** role and the **@** sigil does with the **Positional** role. An example very close to Perl is:

```` raku
# Raku
my &foo = sub ($a,$b) { $a + $b }
say foo(42,666);  # 708
````

Note that even though the variable has the **&** sigil, you do *not* need to use it to execute the code in that variable. In fact, if you ran the code in a **BEGIN** block, there would be no difference compared to an ordinary **sub** declaration:

```` raku
# Raku
BEGIN my &foo = sub ($a,$b) { $a + $b } # same as sub foo()
````

In contrast to Perl, in Raku, a **BEGIN** block can be a single statement without a block, so it shares its lexical scope with the outside. But we'll look more at that in a future article.

The main advantage to using an **&** sigilled variable is that it will be known at compile time that there will be *something* executable in there, even if that *something* isn't yet known.

There are other ways to set up a piece of code for execution:

```` raku
# Raku
my &boo = -> $a, $b { $a + $b }  # same, using a Block with a signature
my &goo = { $^a + $^b }          # same, using auto-generated signature
my &woo = * + *;                 # same, using Whatever currying
````

If you'd like to know more:

- [Block with a signature](https://docs.raku.org/type/Block)
- [Autogenerated signatures](https://docs.raku.org/language/variables#index-entry-%24%5E)
- [Whatever currying](https://docs.raku.org/type/Whatever)

The one you use depends on the situation and your preferences.

Finally, you can also use the **&** sigil inside a signature to indicate that the callee wants something executable there. Which brings us back to the first two code examples in this section:

```` perl
# Perl
sub frobnicate { shift ** 2 }
sub do_stuff_with {
    my $lambda = shift;
    &$lambda(shift);
}
say do_stuff_with( \&frobnicate, 42 );  # 1764
````

```` raku
# Raku
sub frobnicate { $^a ** 2 }
sub do-stuff-with(&lambda, $param) { lambda($param) }
say do-stuff-with( &frobnicate, 42 );  # 1764
````

Note that in Raku you don't need to take a reference; you can simply pass the code object (as indicated by the **&** sigil) as a parameter.

$ (Scalar vs. Item)
-------------------

Compared to the **@**, **%** and **&** sigils, the **$** sigil is a bit bland. It doesn't enforce any type checks, so you can bind it to any type of object. Therefore, when you write:

```` raku
# Raku
my $answer = 42;
````

something like this happens:

```` raku
# Raku
my $answer := Scalar.new(42);
````

except at a very low level. Therefore, this code won't work, in case you wondered. And that's all there is to it when you're declaring scalar variables.

In Raku, **$** also indicates that whatever is in there should be considered a single item. So, even if a scalar container is filled with an **Array** object, it will be considered a single item in situations where iteration is required:

```` raku
# Raku
my @foo = 1,2,3;
my $bar = Array.new(1,2,3);  # alternately: [1,2,3]
.say for @foo;  # 1␤2␤3␤
.say for $bar;  # [1 2 3]
````

Note that the latter case does only *one* iteration vs. *three* in the former case. You can indicate whether you want something to iterate or not by prefixing the appropriate sigil:

```` raku
# Raku
.say for $@foo;  # [1 2 3] , consider the array as an item
.say for @$bar;  # 1␤2␤3␤  , consider the scalar as a list
````

But maybe this brings us too far into line-noise land. Fortunately, there are also more verbose equivalents:

```` raku
# Raku
.say for @foo.item;  # [1 2 3] , consider the array as an item
.say for $bar.list;  # 1␤2␤3␤  , consider the scalar as a list
````

\* (Typeglobs)
--------------

As you may have noticed, Raku does not have a **\*** sigil nor the concept of <a href="https://en.wikipedia.org/wiki/Perl_language_structure#Typeglob_values">typeglobs</a>. If you don't know what typeglobs are, you don't have to worry about this. You can get by very well without having to know the intricacies of symbol tables in Perl (and you can skip the next paragraph).

> In Raku, the sigil is part of the name stored in a [symbol table](https://en.wikipedia.org/wiki/Symbol_table), whereas in Perl the name is stored *without* the sigil. For example, in Perl, if you reference **$foo** in your program, the compiler will look up **foo** (without sigil), then fetch the associated information (which is an array), and look up what it needs at the index for the **$** sigil. In Raku, if you reference **$foo**, the compiler will look up **$foo** and directly use the information associated with that key.

Please do *not* confuse the **\*** used to indicate slurpiness of parameters in Raku with the typeglob sigil in Perl — they have nothing to do with each other.

Sigilless variables
-------------------

Perl does not support sigilless variables out of the box (apart from maybe left-value subroutines, but that would be very clunky indeed).

Raku does not directly support sigilless variables either, but it does support binding to sigilless names by prefixing a backslash (**\**) to the name in a definition:

```` raku
# Raku
my \the-answer = 42;
say the-answer;  # 42
````

Since the right-hand side of the assignment is a constant, this is basically the same as defining a constant:

```` perl
# Perl
use constant the_answer => 42;
say the_answer;  # 42
````

```` raku
# Raku
my constant the-answer = 42;
say the-answer;  # 42
````

It's more interesting if the right-hand side of a definition is something else. Something like a container! This allows for the following syntactic trick to get sigilless variables:

```` raku
# Raku
my \foo = $ = 41;                # a sigilless scalar variable
my \bar = @ = 1,2,3,4,5;         # a sigilless array
my \baz = % = a => 42, b => 666; # a sigilless hash
````

This basically creates nameless lexical entities (a scalar, an array, and a hash), initializes them using the normal semantics, and then binds the resulting objects (a **Scalar** container, an **Array** object, and a **Hash** object) to the sigilless name, which you can use as any other ordinary variable in Raku.

```` raku
# Raku
say ++foo;     # 42
say bar[2];    # 3
bar[2] = 42;
say bar[2];    # 42
say baz<a b>;  # (42 666)
````

Of course, by doing this you will lose all the advantages of sigils, specifically with regard to interpolation. You will then always need to use **{ }** in interpolation.

```` raku
# Raku
say "The answer is {the-answer}.";  # The answer is 42.
````

The equivalent is more cumbersome in most versions of Perl:

```` perl
# Perl
say "The answer is @{[the_answer]}.";  # The answer is 42.
````

Summary
-------

All variables in Raku could be considered tied variables when thinking about them using Perl concepts. This makes them somewhat slow initially. But runtime optimizations and JITting of hot-code paths (at one point to machine code) already make it faster than Perl variables in some benchmarks.

The **@**, **%**, and **&** in Raku do not create any specific objects, rather they indicate a type constraint that will be applied to the object a name is bound to. The **$** sigil is different in that respect, as there is no type constraint to be enforced.

The **@** and **$** prefixes indicate listification and itemization, respectively, although it's probably more readable to use the **.list** and **.item** methods instead.

With a few syntactic tricks, you *can* program Raku without using any sigils in variable names.
