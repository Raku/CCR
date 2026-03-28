# June 11 2011: arrays
    
*Originally published on [11 June 2011](http://strangelyconsistent.org/blog/june-11-2011-arrays) by Carl Mäsak.*

All the variables we've seen so far have had dollar signs (`$`) up front. We call them *scalar variables*. They are distinguished by the fact that they have room for one value at a time.

```raku
my $greeting = "Hello, World!";
say $greeting;
```

Today we'll talk about a new kind of variables, *array variables*, which can contain a sequence of values, and which are written with an at-sign (`@`):

```raku
my @ingredients = "flour", "salt", "sugar", "milk", "eggs", "butter";
say "To make pancakes, you need these ingredients:";
say @ingredients.join(" ");  # "flour salt sugar milk eggs butter"
```

So the variable `@ingredients` contains six things, all string values in this case. But they could easily be numbers, or other kinds of values.

Note that we made use of the method call `.join(" ")` when we wanted to print the array. It makes sure to put a space between each value before printing them. (`.join` takes an array or a list and produces a single string, putting a separator &mdash; `" "` in this case &mdash; between each element.)

Had we just printed the elements, the ingredients would've been harder to read:

```raku
say @ingredients;  # "floursaltsugarmilkeggsbutter"
```

Try saying that quickly five times. :P

There's also a way to fill up an array element by element:

```raku
my @ingredients;  # created empty
push @ingredients, "flour";
push @ingredients, "salt";
push @ingredients, "sugar";
push @ingredients, "milk";
push @ingredients, "eggs";
push @ingredients, "butter";
```

And then we can take them out again one by one if we want:

```raku
# we've already done all the push-ing
say pop @ingredients; # "butter"
say pop @ingredients; # "eggs"
say pop @ingredients; # "milk"
say pop @ingredients; # "sugar"
say pop @ingredients; # "salt"
say pop @ingredients; # "flour"
```

But, hey, look at that! They came out backwards!

That's no coincidence. `push` adds to the end of the array, and `pop` removes from the end of the array. Together they make the array act like a so-called *stack*; think of a stack of plate, where you always add and remove plates at the top.

But surely we could get things out in a non-reversed order if we wanted? Yes, of course:

```raku
# we've already done all the push-ing
say shift @ingredients; # "butter"
say shift @ingredients; # "eggs"
say shift @ingredients; # "milk"
say shift @ingredients; # "sugar"
say shift @ingredients; # "salt"
say shift @ingredients; # "flour"
```

So, `shift` removes things from the start of the array. Together, `push` and `shift` act like a *queue*, like a line of people waiting for something. You won't get served until all the people ahead of you have been.

To complete the set of operations, there's a fourth one called `unshift` which adds something to the start of the array. That's the least used one.

```
unshift ---> +-------+ <--- push
             | array |
  shift <--- +-------+ ---> pop
             +-------+ <--- push
             | stack |
             +-------+ ---> pop
             +-------+ <--- push
             | queue |
  shift <--- +-------+
```

Finally, there's a way to operate on individual values if we want to:

```raku
my @ingredients = "flour", "salt", "sugar", "milk", "eggs", "butter";
say @ingredients[3];        # "milk" -- keep in mind, we start indexing at 0
@ingredients[3] = "cream";  # ooh, luxury pancakes!
say @ingredients.join(" "); # "flour salt sugar cream eggs butter"
```

I don't know about you, but I'm going to make myself some pancakes *right now*. Tomorrow we'll tackle `for` loops.
