# June 23 2011: map and grep
    
*Originally published on [30 June 2011](http://strangelyconsistent.org/blog/june-23-map-and-grep) by Carl Mäsak.*

`for` loops are great, but sometimes they feel a bit heavy-handed. Here, let me give an example:

```raku
my @numbers = 1..10;
my @squares;
for @numbers {
    push @squares, $_ * $_;
}
```

You should be comfortable reading code such as the above by now: we populate the array `@squares` based on the contents of `@numbers`. The `for` loop is just to make sure we're visiting each element of `@numbers` once, and the `push` adds a new element to `@squares` as we do that.

We need to do this kind of "array population" quite a bit, so there's a function to help us do that. It's called `map`:

```raku
my @numbers = 1..10;
my @squares = map { $_ * $_ }, @numbers;
```

Ah, that's nicer.

The two pieces of code do the same thing. But the block we pass to `map` need only contain the *transformation* we want to effect. In this case, we want to transform the numbers to their squares. Just as with `for`, the inside of the `map` block recognizes the topic variable `$_`.

What we're passing in to `map` is, in fact, a little piece of code. We can highlight this fact by extracting the calculation into a subroutine, and pass in the subroutine to `map`:

```raku
sub square($n) {
    return $n * $n;
}
my @numbers = 1..10;
my @squares = map &square, @numbers;
```

(Yes, that `&` is a fourth sigil &mdash; one for referring to functions. Leaving out the `&` would call the function before it got a chance to be passed in to `map`.)

Functions that accept other functions as arguments (or that return functions) are called "higher-order functions". There's a whole programming paradigm built around them &mdash; functional programming. I am not kidding.

There's nothing to prevent you from `map`ping from one element to several, by the way:

```raku
for map { $_, $_ }, 1..3 {
    .say;    # "1 1 2 2 3 3"
}
```

There's another higher-order function that we shall go through today: `grep`. Whereas `map` *translates* from one whole list to another, `grep` lets you *filter* elements from a list.

We can start out the same way as with `map`, by doing it the long way, with a `for` loop:

```raku
my @primes;
for 2..100 {
    if is_prime($_) {
        push @primes, $_;
    }
}
say join " ", @primes;    # "2 3 5 7 11 13..."
```

So you see, it only includes a number in the `@primes` array *if* it `is_prime`.

With `grep`, it's just this:

```raku
my @primes = grep { is_prime($_) }, 2..100;
say join " ", @primes;    # "2 3 5 7 11 13..."
```

Or even just passing in the function directly:

```raku
my @primes = grep &is_prime, 2..100;
say join " ", @primes;    # "2 3 5 7 11 13..."
```

Oh, the `is_prime` function? No, it's not built in. I guess I should define it for you:

```raku
sub is_prime($n) {
    return ?($n %% none 2 .. $n - 1);
}
```

[Author's note: go back and add `%%` to the "Arithmetic" post, apparently we needed it. `:-)`]

So there we have it. `map` and `grep` are higher order functions that help you write common `for` loops in a shorter way. They help you focus on the code that means things and avoid the code that is always the same every time. Which is nice.
