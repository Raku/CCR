# Fun with code blocks in Raku
    
*Originally published on [20 December 2008](http://strangelyconsistent.org/blog/fun-with-code-blocks-in-perl-6) by Carl Mäsak.*

Here's a little pattern I've discovered while hacking away at [a board game implementation](November-15-2008-a-pact.html) in Raku.

I had a subroutine called `input_valid_move`, whose job it was to read a move from `$*IN`, and return the move *if it was valid* according to the rules of the game. Easy enough.

```raku
repeat {
    print "\n", $player, ': ';
} until my $move = input_valid_move(...);
```

Now, there are several ways a move can be illegal, and I found myself printing and returning a lot from the sub:

```raku
unless $row_diff == 2 && $column_diff == 0
    || $row_diff == 0 && $column_diff == 2 {
    say 'Must be exactly two cells apart';
    return;
}
unless @heights[$row_1][$column_1]
    == @heights[$row_2][$column_2] {
    say 'Must be supported at both ends';
    return;
}
```

Notice the repetition? There were many (7) such tests for move correctness, and all of them made a boolean test, printed something and then returned from the sub:

```raku
if ( ... ) { # or 'unless'; depends
    say '...';
    return;
}
```

Repetition is a sign that there there is an abstraction just waiting to be created. I wanted to make an abstraction `flunk_move` that closed over the `say '...'; return` part of the above pattern, parametrizing the message printed. That way, I could just write this instead:

```raku
    flunk_move 'Must be exactly two cells apart'
        unless $row_diff == 2 && $column_diff == 0
            || $row_diff == 0 && $column_diff == 2;
    flunk_move 'Must be supported at both ends'
        unless @heights[$row_1][$column_1]
            == @heights[$row_2][$column_2];
```

Each move correctness test now became a single statement, instead of an `if/unless` statement containing two statements. As an added bonus, the most important part of the statement (the disqualification of the move) is now leftmost in the statement, something Damian Conway talks about in his book "Perl Best Practices".

But a new subroutine would not do as a repetition-reducing abstraction. The `return` statement in such a new sub, having moved from its original environment would be a no-op. I wanted to eat the cake and have it, too.

S06 states that the `return` function [throws a control exception that is caught by the current lexically enclosing `Routine`,](https://github.com/Raku/old-design-docs/blob/master/S06-routines.pod#The_return_function) and this fact turned out to be just what I needed. To decipher the Raku designese, the `return` in a `sub` returns from that `sub`, but the `return` in a bare block returns from the `sub` (or whatever) it was called from.

```raku
# not what I want -- the return does nothing
sub flunk_move($reason) { say $reason; return };
# what I want, using pointy block
-> $reason { say $reason; return };
# what I want, using placeholder variables
{ say $^reason; return };
```

Think of it in biological terms: a `sub` is like a [eukaryote](https://en.wikipedia.org/wiki/Eukaryote): a little more complex, handles advanced things like `return` when necessary. A bare block doesn't have all that advanced piping, and has to delegate its `return` calls to its surrounding host cell. In other words, a bare block is a bit like an [endosymbiont](https://en.wikipedia.org/wiki/Endosymbiont) [prokaryote](https://en.wikipedia.org/wiki/Prokaryote), a simple organism that in the course of evolutionary history ended up in a symbiotic relationship inside a larger eukaryotic cell.

Biological analogies aside, what it meant to me was that I could do this in my `sub input_valid_move`:

```raku
my &flunk_move = { say $^reason; return };
```

(There's the endosymbiont, right there! It can't return from itself, because it's just a humble code block, so it returns from its surrounding subroutine instead, which happens to be `input_valid_move`.) 

After that, I could use `&flunk_move` just as I wanted, as if it were a `return` statement with side effects. (Same code as above.)

```raku
    flunk_move 'Must be exactly two cells apart'
        unless $row_diff == 2 && $column_diff == 0
            || $row_diff == 0 && $column_diff == 2;
    flunk_move 'Must be supported at both ends'
        unless @heights[$row_1][$column_1]
            == @heights[$row_2][$column_2];
```

Some Smalltalk people extol the power in being able to define things like [the if statement](https://pozorvlak.livejournal.com/94558.html) from within the language, without any magical trickery to make it work. The pattern I discovered above uses the same kind of strengths, the ability to define my own slightly fancy return statement, and have it look like a built-in in subsequent code.

That kind of power is what makes Raku a joy to use.
