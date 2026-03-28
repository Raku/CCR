# June 4 2011: Loops
    
*Originally published on [4 June 2011](http://strangelyconsistent.org/blog/june-4-2011-loops) by Carl Mäsak.*

Even with `if` statements giving us the power to make a program do some things but not others, the program execution is still restricted to flowing from top to bottom, making one pass over everything, and then stopping.

We're about to change that.

In fact, let's break in this new loop feature by utterly mis-using it. Let's write a program that loops `forever`.

```raku
loop {
    say "Infinite tube of toothpaste!";
}
```

This program will repeat its message about eternal dental hygiene until you pull the plug, hit Ctrl-C, or issue a `kill` command from a different terminal window. It simply has no instruction to stop. The `loop` here really means "loop forever".

Before entirely writing this off as a feature we'll never use, let's just point out that most games work just like this. The central action of a game is usually a loop with some game logic inside.

Of course, there's always a "quit" menu option, or some winning condition, or other ways to end the game. Likewise, there's a `last` command that bails us out of a loop.

```raku
loop {
    my $had-enough = prompt "Have you had enough yet? ";
    if $had-enough eq "yes" {
        last;
    }
}
```

This loop doesn't loop forever, only until we cry uncle.

Note that we have to write exactly the string "yes" to get out of that loop. Writing "Y" or "yeah" or even "Yes" will not do. That's because eq, the string comparison operator, compares two strings *exactly*, just as the numeric comparison operator == compares two numbers exactly. Either things are exactly equal or, well, they're not.

Let's address a possible point of confusion right away: just because the command is called `last`, it doesn't just mean "after we're finished with this round of the loop, we won't do any more". It really means "stop doing the loop *right now*, and continue after it". Of course, in the case above, there's no code after the loop, so the program ends.

We now have all the pieces in place for building a guessing game. We'll do that tomorrow.
