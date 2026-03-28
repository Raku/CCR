# June 3 2011: If statements
    
*Originally published on [4 June 2011](http://strangelyconsistent.org/blog/june-3-2011-if-statements) by Carl Mäsak.*

Let's say we like our sauna to be between 80 and 90 degrees Celsius. We write a small program to remind us of this fact:

```raku
my $temperature = prompt "Enter sauna temperature: ";
if $temperature < 80 {
    say "The sauna is too cold!";
}
elsif $temperature > 90 {
    say "The sauna is too hot!";
}
else {
    say "Aaaah, this is just right.";
}
```

For the first time, we're seeing a program that's making choices. There are three `say` commands in there, but only one of them will be run each execution.

The way it all works is probably fairly straightforward, and is reflected in how the code sounds when we read it out loud:

- **If** the temperature is lower than 80 (degrees Celsius), say that the sauna is too cold,
- **elsif** the temperature is higher than 90, say that the sauna is too hot,
- **else** say that it's just right.

Note that `else` is spelled with a total of two `e`s, but that there's only one `e` in `elsif`.

One might ask, with a certain tinge of curiosity, what things we can write after an `if` or an `elsif`. The answer is, almost anything. We've been using the comparison operators `<` and `>` above, but there's also comparison for equality (`==`), and comparison for inequality (`!=`), and many others. In fact, we could write anything there that could be seen as either a true or false value. As a general rule, most things are true values, but `0`, the empty string `""` and undefined things are false values.

Be mindful that assignment has one equals sign (`=`), but equality comparison has two (`==`). They work quite differently; the first one makes things equal, the second one only checks if they are.

The curly braces (`{ ... }`) that we put after each test need to be there. They're a kind of grouping mechanism, so that there's no ambiguity as to where the conditional code ends and the usual code begins again. It's often the case that we want to do a number of things if something is true. In such a case, we'd just put many statements inside the curly braces.

Finally, in our example we had `if`/`elsif`/`else`, but it's possible to mix and match, and have `if`/`elsif`/`elsif`/`else`, or just `if`/`else`, or even just `if`. It depends what you want to do.

Boy, is it hot in here. Next time we'll throw our program for a loop.
