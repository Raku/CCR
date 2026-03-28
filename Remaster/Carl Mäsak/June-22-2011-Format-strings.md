# June 22 2011: Format strings
    
*Originally published on [29 June 2011](http://strangelyconsistent.org/blog/june-22-format-strings) by Carl Mäsak.*

A big language like Raku is full of smaller languages; little helpers that carry out duties that the regular language would be able to do, but less simply and elegantly.

Today we'll see such a language. It's used for formatting strings.

```raku
say sprintf "I have %d apples", 15;   # "I have 15 apples"
```

The new thing in the above are `sprintf`, the name of the subroutine that calls on the formatting language; and `%d`, a kind of placeholder for values. (The `d` stands for "decimal", so we're expecting the value to be printed as a base-10 integer.)

Ok, that's a start, but it doesn't give us much over `"I have $apples apples"` yet. What more do we have?

Well, look at this, for example:

```raku
say sprintf "I have %05d apples", 15;   # "I have 00015 apples"
```

That extra `05` there tells `sprintf` to print the value using five characters, and to fill with `0`s if needed. Convenient.

Here's another convenient thing we can use it for:

```raku
say "Thirds always give me trouble: ", 1/3
    # "Thirds always give me trouble: 0.333333333333333"
say sprintf "Thirds always give me trouble: %5.2f", 1/3
    # "Thirds always give me trouble:  0.33"
```

Whereas the `%d` is for integers, the `%f` is for floating-point values. (Since it's integers that are denoted by `%d`, it's probably best in this case not to think of non-integer numbers as "decimal numbers", which would be confusing.)

So. Any time you feel the need to round a number to two decimal places (or whatever) before printing it, don't reach for all manner of tricky arithmetic to do it. Reach for `sprintf`.

In fact, if it's only one single thing you want to format, there's a method to do that for you. And it's not called `.sprintf`, for once. It got a shorter name:

```raku
say 42.fmt("%4d");    # "  42"
```

The *reason* it got a shorter name is that it can do a few tricks that `sprintf` can't:

```raku
say [1, 2, 3].fmt("%5.2f");        # " 1.00  2.00  3.00"
say [1, 2, 3].fmt("%5.2f", ";");   # " 1.00; 2.00; 3.00"
```

In other words, it not only formats scalar values, but lists and arrays, too. (And hashes.)

Now the only missing piece is learning what other things you can format besides integers and floating-point numbers. Here's a list of the most important ones:

```
%s string
%d int
%x hexadecimal int
%X uppercase hexadecimal
%b binary int
%f float
% d int with a space before it
%+d int with a sign before it
%-8s left-justified string taking up 8 places
%08s string taking up 8 places, filled with 0s on the left
```

That's it for today.

Making code that outputs things look decent is notoriously hard. `sprintf` and `.fmt` at least help make the job a little easier. Don't forget to use them when you encounter a tricky formatting problem.
