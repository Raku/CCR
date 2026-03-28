# June 14 2011: Logic operators
    
*Originally published on [14 June 2011](http://strangelyconsistent.org/blog/june-14-2011-logic-operators) by Carl Mäsak.*

We all know about `if` statements and true/false values by now.

```raku
if 2 + 2 == 4 {
    say "Yay, math still works!";
}
```

But sometimes we need to check that two things are both true:

```raku
my $coin = ("heads", "tails").roll;
my $die  = (1..6).roll;
if $coin eq "heads" && $die == 6 {
    say "You, sir or madam, are a lucky person.";
}
```

Or sometimes we want to check that at least one of two things is true:

```raku
my $pram = (True, False).roll;
my $jetski = (True, False).roll;
if $pram || $jetski {
    say "Seems we'll be able to get over the river...";
}
```

That's all quite straightforward. Logic usually is.

The only thing worth remembering is that `&&` and `||` are *short-circuiting*, which means that the evaluation of values stops as soon as the final truth value is certain. Here's a demonstration of how that works:

```raku
True  && say "OH HAI";                # "OH HAI"
False && say "this isn't printed";    # ""
True  || say "this isn't printed";    # ""
False || say "OH HAI AGAIN";          # "OH HAI AGAIN"
```

So, again, the rule is that if we need to evaluate the right part of the expression to know the value, we do. If we don't need to, we don't.

If you're wondering about, between `||` and `&&`, which operator "wins" and binds its values the tightest, I'll tell you: it's `&&`. This is because `&&` is the "multiplicative one, and `||` is the additive one. And the multiplicative operator always binds tighter:

```
 additive op    multiplicative op
     +                  *           numeric
     ~                  x           string
     ||                 &&          logic
binds loosely     binds tightly
```

You might be wondering why the `||` and `&&` are doubled. That's because we're saving the single-character variants for something much cuter... instead of doing this:

```raku
if $answer == 1 || $answer == 4 || $answer == 9 {
    say "That's a pretty square reply.";
}
```

We can get rid of a bunch of repetition and do this:

```raku
if $answer == 1 | 4 | 9 {
    say "That's a pretty square reply.";
}
```

I assume you can see the usefulness of that. `:-)```

Tomorrow we'll do a game, with chocolate in it!
