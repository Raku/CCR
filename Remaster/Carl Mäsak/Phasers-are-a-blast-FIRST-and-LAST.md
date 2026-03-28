# Phasers are a blast: FIRST and LAST
    
*Originally published on [15 July 2010](http://strangelyconsistent.org/blog/phasers-are-a-blast-first-and-last) by Carl Mäsak.*

I started thinking about the `FIRST` and `LAST` phasers the other day, thanks to *moritz*++. My attention was on how to implement them in Yapsi, and my conclusions were mostly SIC, but they can be converted to Raku for public view.

For those who haven't kept up with the latest Raku terminology, "phasers" are what we call those all-caps blocks which fire at different *phases* during program execution. Perl's `perldoc perlmod` simply calls them "specially named code blocks", but in Raku it's been decided to call them "phasers".

So much for phasers. What do the `FIRST` and `LAST` phasers do? They don't exist in Perl. S04 describes them thus:

```raku
FIRST {...}       at loop initialization time, before any ENTER
 LAST {...}       at loop termination time, after any LEAVE
```

(There's a `NEXT` phasers too, which I'm not going to tackle today. The `ENTER` and `LEAVE` phasers are what they sound like; they trigger at block entrance and exit, respectively.)

Here's some code using these.

```raku
my @a = 1, 2, 3;
for @a -> $item {
    FIRST { say "OH HAI" }
    say $item;
    LAST { say "LOL DONE" }
}
```

The code, when run, should print the following:

```
OH HAI
1
2
3
LOL DONE
```

(At the time of writing, no Raku implementation implements the `FIRST` and `LAST` phasers yet.)

The goal of this post is *transforming* the phasers into code using more primitive constructs, but which still produces the above results. Oh, and it should work not only in this case, but in general.

Here's a first attempt. (Phaser-ful code to the left, rewritten code to the right.) It doesn't work.

```raku
my @a = 1, 2, 3;              my @a = 1, 2, 3;
                              say "OH HAI";
for @a -> $item {             for @a -> $item {
    FIRST { say "OH HAI" }
    say $item;                    say $item;
    LAST { say "LOL DONE" }
}                             }
                              say "LOL DONE";
```

More exactly, it does produce the desired output, but it doesn't work in general; it fails when `@a` is empty:

```raku
my @a;                        my @a;
                              say "OH HAI";
for @a -> $item {             for @a -> $item {
    FIRST { say "OH HAI" }
    say $item;                    say $item;
    LAST { say "LOL DONE" }
}                             }
                              say "LOL DONE";
```

This code would still produce `"OH HAI\nLOL DONE\n"`, which is wrong, because there is no first and last iteration for the empty `@a` array.

Ok, we say. No worries; a bit more ad hoc, but we can detect for emptiness. No problem.

```raku
my @a;                        my @a;
                              my $HAS_ELEMS = ?@a;
                              if $HAS_ELEMS {
                                  say "OH HAI";
                              }
for @a -> $item {             for @a -> $item {
    FIRST { say "OH HAI" }
    say $item;                    say $item;
    LAST { say "LOL DONE" }
}                             }
                              if $HAS_ELEMS {
                                  say "LOL DONE";
                              }
```

That works for an empty list, but it fails to work when the `FIRST` block accesses variables that only exist within the `for` loop:

```raku
my @a = 1, 2, 3;              my @a = 1, 2, 3;
                              my $HAS_ELEMS = ?@a;
                              if $HAS_ELEMS {
                                  $x # BZZT PARSE ERROR
for @a -> $item {
    my $x;
    FIRST { $x = 42 }
    say $item, $x;
}
```

So. Back to the drawing-board. Two seemingly opposing forces constrain our problem: we need to put the rewritten `FIRST` block *outside* the `for` loop, because we only want it to execute once; but we also need to put it *inside* the `for` loop, so that it can have access to the same lexical environment. Is there a compromise somewhere in there?

Yes. We put the `FIRST` block inside the `for` loop, but then we keep track of whether we've already executed it once, with a special variable hidden in the surrounding scope:

```raku
my @a = 1, 2, 3;              my @a = 1, 2, 3;
                              my $FIRST_PHASER_HAS_RUN = False;
for @a -> $item {             for @a -> $item {
    my $x;                        my $x;
                                  unless $FIRST_PHASER_HAS_RUN {
    FIRST { $x = 42 }                 $x = 42;
                                      $FIRST_PHASER_HAS_RUN = True;
                                  }
    say $item, $x;                say $item, $x;
}                             }
```

Now it all works. This is the general way to make the `FIRST` behave according to spec. In the presence of several loops within the same block, one can re-use the same variable for all of the loops, just resetting it before each one. Explicitly setting to `False` even the first time is quite important, in case someone ever implements the `goto` statement.

With the `LAST` phaser, we encounter exactly the same dilemma as with the `FIRST` loop. The `LAST` phaser has to be both inside and outside the block; inside because it has to have access to the loop block's variables, and outside because... well, because in general one doesn't know which iteration was the last one until it has already run.

At one point I had the idea to put the `LAST` block at the end of the loop block, checking the loop condition just before the placement of the `LAST` block, possibly saving it somewhere so it doesn't have to be re-evaluated. But the sad truth there's no realistic way to evaluate the loop condition from within the loop block; what if the expression contains a variable which is shadowed by another variable inside the loop block? There's just no way to make that fly.

The whole situation with the `LAST` block really looks hopeless... until one remembers about closures:

```raku
my @a = 1, 2, 3;              my @a = 1, 2, 3;
                              my $LAST_PHASER;
                              my $LOOP_HAS_RUN = False;
for @a -> $item {             for @a -> $item {
    my $x = "LOL DONE";           my $x = "LOL DONE";
    LAST { say $x }               $LAST_PHASER = { say $x };
                                  $LOOP_HAS_RUN = True;
}                             }
                              if $LOOP_HAS_RUN {
                                  $`LAST_PHASER`;
                              }
```

So in every iteration, we save away a closure *just in case* that particular iteration turns out to be the last one. Then we execute the last value assigned to the closure, provided the loop ever run. Sneaky, huh?

So that works in the general case. Of course, a clever optimizer which can detect with certainty that the loop will run at least once and that neither phaser uses loop-specific lexicals is perfectly entitled to rewrite the `FIRST` and `LAST` phasers to our first attempt. But the above rewritings work in the general case.

In explaining this to a colleague, a case of possible confusion involving the `FIRST` phaser was uncovered:

```raku
for 1, 2, 3 {
    my $x = 42;
    FIRST { say $x }
}
```

One might perhaps expect this code to print `"42\n"`, but in fact it prints `"`Any`"`. The reason is simple: whereas the lexical `$x` is reachable throughout the whole `for` loop, the *assignment* of `42` to it won't occur until *after* the `FIRST` block has executed. That's what `FIRST` blocks do, they execute first. Nevertheless, some people might expect assignments to be treated specially in some way, not counting as "real code" or whatever. But they are, and thus that's the result. In general, reading from freshly declared lexical variables in a `FIRST` block won't do you much good.

Lastly, there's this wording in S04:

> `FIRST`, `NEXT`, and `LAST` are meaningful only within the lexical scope of a loop, and may occur only at the top level of such a loop block.

I read that as saying that these kinds of blocks should be *illegal* if they are found in a block which isn't a loop block. STD.pm6 doesn't enforce this yet; it probably should.
