# June 16 2011: Subroutines
    
*Originally published on [17 June 2011](http://strangelyconsistent.org/blog/june-16-2011-subroutines) by Carl Mäsak.*

Our programs are getting rather long, and they're all in one piece. Even with `if`s and loops to make it more fun, it's all just one big string of instructions. As our programs keep expanding, that will be harder and harder to maintain.

We need a way to subdivide our programs. Enter the subroutine. (Or, shorter, the "sub".)

```raku
sub miniprogram {  # declare it
    say "Hello.";
    say "I'm a little isolated world of my own.";
    say "And now I'm finished. kthxbai";
}
miniprogram;       # call it
```

A legitimate question at this point is: "Why did we do that?" More exactly, what did we gain from putting code inside a subroutine and then calling the subroutine? Isn't it always more straightforward to... not do that?

Well, no. There are at least two good reasons for stowing away code in subroutines:

- We can give pieces of code descriptive names. That's more important than one might think.
- We can call the same piece of code from several different places. That means that we avoid repeating that same stretch of code; instead we just repeat a small subroutine name each time.

Later, there'll be a third good reason, having to do with modules and the sharing of code.

It's worth mentioning two more things about subroutines. First, they can return values:

```raku
sub roll_die {
    return (1..6).roll;
}
say roll_die;    # and it rolls the die
```

The `return` there means "exit the sub immediately with the following value". `return`ing with no value is fine, too. You can `return` at the end of a subroutine, or from the middle of it. Whatever value you return becomes the value of the whole sub call. You can take that value, store it in a variable, print it, etc. If you don't have a `return` in your subroutine, the last value in the routine will be returned automatically.

The other thing that's worth knowing is that you can pass things *into* a sub.

```raku
sub add($a, $b) {
    return $a + $b;
}
say add(10, 25);    # "35"
```

Well, that was easy! You just declare a number of *parameters* &mdash; `$a` and `$b` in this case &mdash; and then you can call the subroutine with that many values.

Here's another example:

```raku
sub greet($name) {
    say "Hello $name";
}
greet(prompt "What's your name? ");    # "Hello <name>"
```

This program will first prompt for a name, and whatever the user types in will be used as a parameter `$name` by the `greet` sub. (What `prompt` returns, `greet` will consume.)

In a lot of places, the parentheses are optional, and a matter of taste. This also works:

```
greet prompt "What's your name? ";     # "Hello <name>"
```

It's up to you whether you think that's clearer of more confusing. `:-)```

The important thing to remember, if you *do* use parentheses, is that they should come directly after the sub name, without intervening space:

```raku
add(4, 4);    # will work
add (4, 4);   # will NOT work
```

Usually whitespace doesn't matter that much, but for sub calls (and things like indexings) it does matter.

There's a lot more to say about subroutines. But this will serve us for now.
