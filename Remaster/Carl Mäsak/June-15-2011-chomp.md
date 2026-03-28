# June 15 2011: chomp!
    
*Originally published on [15 June 2011](http://strangelyconsistent.org/blog/june-15-2011-chomp) by Carl Mäsak.*

The good news: You have a chocolate bar, and you're sharing it with a friend!

The bad news: the upper left corner of the chocolate bar is poisoned! Oh noes!

So now you're both in a really odd game were you're taking turns biting lower-right chunks off the chocolate bar, each of you plotting your way to not being the one with the poisoned corner. Oh man, how did it end up this way? No-one knows.

```raku
say "Chomp -- don't eat the poisoned corner!";
say "";
my $WIDTH  = 15;
my $HEIGHT = 10;
my @bar;
push @bar, "#" ~ "." x ($WIDTH - 1);
for 2 .. $HEIGHT {
    push @bar, "." x $WIDTH;
}
my $player = 1;
PLAYER:
loop {
    say @bar.join("\n");
    say "";
    my $coords;
    my $row;
    my $column;
    INPUT:
    loop {
        $coords = prompt "Player $player, move (m, n): ";
        if $coords !~~ /^ (\d+) \s* ',' \s* (\d+) $/ {
            say "Unrecognized move syntax. Please write it like '1, 2'";
            redo INPUT;
        }
        $row    = $0;
        $column = $1;
        if $row > @bar.elems
           || $column > @bar[$row - 1].chars {
            say "That piece was already eaten.";
            redo INPUT;
        }
        if $row == 1 && $column == 1 {
            last PLAYER;
        }
        last INPUT;
    }
    for @bar[$row - 1 .. $HEIGHT - 1] {
        $_ = .substr(0, $column - 1);
    }
    if $player == 1 {
        $player = 2;
    }
    else {
        $player = 1;
    }
}
say "Augh, poison! And it doesn't taste too good, either.";
say "The end.";
```

A few things are worth pointing out in the above code.

- There are a lot of ways we could represent the chocolate bar, but having it as an array of strings which we can the just print out seems like a nice compromise. Taking bites of the bar then corresponds to taking `substr`s of the strings. Which isn't too bad.
- There's a loop in our loop. We need to `redo` and `last` on both of them, and things can turn a bit confusing. So we put *labels* on the loops, and then we can use them to identify them. Look "how well things read" after we do that: `redo INPUT` (when the input wasn't kosher), `last PLAYER` (when the game is lost), `last INPUT` (when we get the input right).
- Pay especial notice to how, in `$row > @bar.elems || $column > @bar[$row - 1].chars`, we are making implicit use of the short-curcuiting behavior of the `||` operator. On the left side, we're checking if `$row` is out of range, and *only if it's not* do we proceed and actually use it on the right side to index the array. This is one of the most common uses of short-circuiting.
- There are a bunch of `$var - 1` strewn across the latter part of the main game loop. That's because we expose a 1-based coordinate system to the players of the game, but our array and strings are all 0-based, because that's the way Raku does things. That kind of "model compensation" between slightly different world views is very common, as well. Get used to it. `:-)```

That's it for today; enjoy your chocolate. I'd tell you what we're heading for next, but I don't know yet. Have to make the second half of the schedule first.
