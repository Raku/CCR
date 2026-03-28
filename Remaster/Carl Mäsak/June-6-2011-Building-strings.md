# June 6 2011: Building strings
    
*Originally published on [6 June 2011](http://strangelyconsistent.org/blog/june-6-2011-building-strings) by Carl Mäsak.*

Just as we can add numbers, we can "add" strings together. (Though we usually talk about it as *concatenation*.)

```raku
my $string = "Hello" ~ " World!";
say $string; # Hello World
```

That little tilde (`~`) is what's chaining the two strings together. Or, even chaining other things together into strings:

```raku
 my $answer = "The answer is " ~ (6 * 7) ~ ".";
 say $answer; # The answer is 42.
```

Pretty simple.

Sometimes we keep concatenating the same string over and over, and we wish there were a "multiplication" of strings, too. The good news: there is one. Just as we use `*` for multiplication of numbers, in Raku we use `x` for multiplication of strings.

```raku
my $fifty-pies = "pie" x 50;
say $fifty-pies; # piepiepiepiepiepie...
```

(Those things that start with a `#` are comments, by the way. They're seen by the programmer but not by the compiler, so we can put helpful notes in there. There's a whole lot of things to learn about when and how to write good comments... let's just settle for now that comments are best when they clarify intent ("Calculate the interest") and not mechanics ("Multiply $amount by $rate"). The latter should be evident from the code. By that rule, the above comments are somewhat dubious... but indulge us while we're in teaching mode, will you? `:-)`)

Here's a case where it would be an extremely good idea to use string multiplication:

```raku
my $spaces = "                    ";
```

Yes, those are 20 spaces, but it's not really easy to see, is it? This would be much clearer:

```raku
my $spaces = " " x 20;
```

And, of course, we would be free to make the number of spaces vary if we wanted, using &mdash; duh &mdash; a variable:

```raku
my $spaces = " " x $n;
```

So it's not just a convenient shorthand.

I know what you're thinking now. You're thinking "bar charts!". Hm, maybe not. But anyway, that's one thing we could do with our newly won power.

```raku
my $amount = prompt "Enter the amount: ";
my $bar = "=" x $amount;
say "That gives us a bar this long: $bar";
```

With bar charts, there's no telling how far you'll go within this organization, son. Stay tuned for tomorrow, and all you ever need to know about maths.
