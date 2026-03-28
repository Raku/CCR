# June 24 2011: Types
    
*Originally published on [2 July 2011](http://strangelyconsistent.org/blog/june-24-2011-types) by Carl Mäsak.*

I can put a string value in a variable:

```raku
my $greeting = "Hello again!";
```

The *type* of the string value is `Str`. That's the kind of value it is; it's different from `Int` and `Regex`, for example.

If I want to make sure that all that ever ends up in that variable is a string value, I can write it like this:

```raku
my Str $greeting = "Hello again!";
```

In a very real sense, `my Str $greeting` means "here's the new variable `$greeting`, and it will only ever contain `Str` values". If we later try to do this:

```raku
$greeting = 5;    # not a Str
```

...then Raku will throw a fit and say that it expected a `Str` but got an `Int`. Clever implementations might even do this during program compilation, i.e. before it even runs.

That's types. They catch mistakes in the code, like variables that are supposed to contain one type of value but gets assigned another. They're like little checkpoints that make sure everything's OK.

A reasonable question at this point is: yes, but what good are they? You never make mistakes when you code, right? (Right, right?) Well, even under the assumption that our own code is perfect and free of bugs all the time, there's always... other programmers. They use your variables and your subroutines all wrong, because they don't know better. And you can restrict that misuse by giving the variables types.

Yes, subroutine parameters can be given types as well:

```raku
sub duplicate(Str $s) {
    return $s ~ $s;
}
```

Now people *have* to call your `duplicate` subroutine with a `Str` value.

```raku
say duplicate("hi!");      # "hi!hi!"
duplicate(42);             # Expected Str, got Int
```

Actually, we might decide that a type error there is a bit harsh. After all, Perl figures out that `42 ~ 42` is a string concatenation of two things that happen to be `Int`s, so why shouldn't `duplicate`? We'd like to loosen the restriction a little, be a bit more forgiving. That's when we use the `Cool` type:

```raku
sub duplicate(Cool $s) {
    return $s ~ $s;
}
say duplicate("hi!");       # "hi!hi!"
say duplicate(42);          # "4242"
```

`Cool` is a type that brings together all those values in Perl that traditionally are exchangable for one another: `Str`, `Int`, `Num`, `Bool`, `Array`, `Hash`. Not all scalar values are `Cool`; `Regex` isn't `Cool`, for example.

We're starting to see that some types "contain" other types, in the sense that a `Str` value is always a `Cool` value, but a `Cool` value doesn't have to be a `Str` value. The tree of all such containments is called the type hierarchy, and the bits we've talked about so far hang like this in that hierarchy:

```
                             Mu
                              |
                              |
                     +--------+---------+
                     |                  |
                     |                  |
                    Any              Junction
                     |
                     | 
             +-------+---------+-------+
             |                 |       |
             |                 |       |
           Cool             Whatever Routine
             |                         |
             |                         |
 +----+---+---+----+-----+        +----+----+
 |    |   |   |    |     |        |         |
 |    |   |   |    |     |        |         |
Bool Int Num Str Array Hash      Sub      Regex
```

Many important types are collected under `Cool`. `Cool` contains a great many useful methods, that are thereby all accessible from the subtypes of `Cool`.

The `Whatever` type contains one value: the `*` that we've seen in array indexings and `substr` calls. `Sub` is the type of subroutines, `Regex` is the type of regexes, and both of these belong to a type called `Routine`. (There are more types of `Routine`, but we haven't introduced them yet. Soon, young padwan.)

All normal types are subtypes of `Any`. In fact, if you don't give a variable a type declaration, `Any` is the type it will have. `Any` is in many senses the top type of the "normal" type system.

The only thing that lies outside of it is `Junction`, the special scalar value that can act like many values simultaneously. Junctions with their autothreading and inside-out behaviors may appear magical at times, but all that magic really stems from the fact that they're outside of the "normal" type hierarchy.

At the very top, uniting the normal `Any` and the abnormal `Junction`, sits the ur-type... `Mu`. It is the mother of all types, the emptiness from which the world sprang forth. It is the silent lowing of the cosmic cow, a disturbing ripple in the fabric of existence itself. It is the riddle of emptiness in a world of chaos. It is nothing, and everything.

In practice, `Mu` doesn't show up much in code. The silent lowing kinda gets to you after a while. `:-)` In the majority of cases, `Any` is adequate.

We'll let our old friend the smartmatch operator (`~~`) make a final reappearance in this post:

```raku
say Str      ~~ Cool;  # "Bool::True"
say Regex    ~~ Cool;  # "Bool::False"
say Array    ~~ Any;   # "Bool::True"
say Any      ~~ Any;   # "Bool::True"
say Junction ~~ Any;   # "Bool::False"
```

Indeed, this is the usual way to test for type matching.

Enjoy!
