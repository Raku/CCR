# Here be heredocs
    
*Originally published on [10 April 2015](http://strangelyconsistent.org/blog/here-be-heredocs) by Carl Mäsak.*

I used to consider Raku heredocs a clear-cut symptom of second-system syndrome: taking a useful feature and weighing it down with extravagant bells and whistles until it cannot move. I read the specification for them and would think, leave well enough alone. Don't fix it if it ain't broken.

Since nowadays I've done a complete reversal on that opinion, and really love Raku's heredocs, I thought I would write my take on them.

## Indentation

The most noticeable part of Raku heredocs as compared to Perl ones is that Raku heredocs can be indented.

In Perl, you'd do this:

```perl
for my $n (reverse 1..99) {
    my $n1 = $n - 1;
    my $n_s = $n == 1 ? "" : "s";
    my $n1_s = $n1 == 1 ? "" : "s";
    print <<"VERSE";
$n bottle$n_s of beer on the wall!
$n bottle$n_s of beer!
Take one down, pass it around,
$n1 bottle$n1_s of beer on the wall!
VERSE
}
```

Heredocs could be said to be "anti-socially indented" compared to the rest of the program. If you quickly scan through a program, you'll see the general structure of it by how things are indented... plus a number of heredoc blocks of text completely ruining the picture.

I remember rationalizing this to myself. Thinking "oh well, heredocs are a bit special, they 'deserve' to stand out from the rest of the program the way they do". I no longer think that. In fact, I'd say the effect gets worse the bigger your application is. Bigger applications tend to rely more on nested blocks and indentation. So this is not likely to be a big problem for straightforward scripts with no control flow to speak of. But it is a problem as your application grows.

Here's how I would write the corresponding Raku heredoc.

```raku
for reverse 1..99 -> $n {
    my $n1 = $n - 1;
    my $n_s = $n == 1 ?? "" !! "s";
    my $n1_s = $n1 == 1 ?? "" !! "s";
    say qq :to 'VERSE';
        $n bottle$n_s of beer on the wall!
        $n bottle$n_s of beer!
        Take one down, pass it around,
        $n1 bottle$n1_s of beer on the wall!
        VERSE
}
```

I'd say visually, that's a big improvement. S02 explains what's going on: "Leading whitespace equivalent to the indentation of the delimiter will be removed from all preceding lines."

I should note that even in Perl, you could conceivably do manual de-indenting. Something like this:

```raku
for my $n (reverse 1..99) {
    my $n1 = $n - 1;
    my $n_s = $n == 1 ? "" : "s";
    my $n1_s = $n1 == 1 ? "" : "s";
    print join "\n", map { substr $_, 8 } split /\n/, <<"VERSE";
        $n bottle$n_s of beer on the wall!
        $n bottle$n_s of beer!
        Take one down, pass it around,
        $n1 bottle$n1_s of beer on the wall!
VERSE
}
```

But (a) that still leaves the terminator in an awkward position, and (b) doing it manually is extra code to get right and to maintain. (Of course, as *nine*++ pointed out on the channel, you can put the right amount of indentation into the terminator symbol. But, ick. I much prefer not having to do that.)

## The `.indent` method

As a nice unintended side effect of implementing heredocs, we ended up with an `.indent` method on strings in core.

```raku
> say "foo".indent(4 * $_) for ^5;
foo
    foo
        foo
            foo
                foo
```


The method works with a negative argument. In which case it (of course) *removes* indentation instead. If there's not enough to remove, it warns. (But it still gives you a sensible result.)

```raku
> say "Give up?\n  Never!".indent(12).indent(-4 * $_) for ^5;
            Give up?
              Never!
        Give up?
          Never!
    Give up?
      Never!
Give up?
  Never!
Asked to remove 16 spaces, but the shortest indent is 12 spaces  in block <unit> at <unknown file>:1
Give up?
Never!
```

As the final crowning touch, the method accepts a `*` (whatever) argument. Meaning, in this case, "(consistently) remove the biggest amount of indentation you can get away with". This is a nice default. Also, that's basically what heredocs end up doing, if for the purposes of de-indenting you consider the terminator to be part of the string.

The surface reason to add this method was that this was something heredocs needed to do internally *anyway*. But as it turns out, `.indent` is just a generally useful method to have around. It's possible to implement yourself (`lines`, `map`, `join`), but why bother? It's right there.

I'm happy about the way `.indent` turned out. It's even fairly sane in how it handles different kinds of whitespace &mdash; to the degree anything involving mixing tabs and spaces can really be referred to as "sane".

## The heredoc terminator

Heredocs all work by setting up a *terminator symbol*. When the parser sees this symbol alone on a line later, it'll know that the heredoc ends. The terminator itself is not part of the heredoc string.

Here's how I write it:

```raku
say qq :to 'VERSE';
    $n bottle$n_s of beer on the wall!
    $n bottle$n_s of beer!
    Take one down, pass it around,
    $n1 bottle$n1_s of beer on the wall!
    VERSE
```


In the few example heredocs in S02 and S03, the spec chooses to write things together a bit more, and to use slashes around the terminator symbol:

```raku
say qq:to/VERSE/;
    $n bottle$n_s of beer on the wall!
    $n bottle$n_s of beer!
    Take one down, pass it around,
    $n1 bottle$n1_s of beer on the wall!
    VERSE
```

I think the choice of slashes here is unfortunate, because it makes it look like `/VERSE/` is a regular expression literal. It isn't, it's just a string with funny delimiters. I don't know that I can stop the inevitable and prevent others from using slashes there, but myself, I'm going to try to use string quotes.

The exact choice of quotes doesn't determine whether the heredoc interpolates or not. Only the `q` or `qq` operator determines that. Which feels more sane anyway.

A word of warning if, like me, you decide to use single quotes around your terminator: you have to put in some whitespace between the `to` and the single quote. This is because `to'VERSE` is a valid identifier in Raku. That's why I put in the whitespace both before and after the `:to`. And now that it's there, I think I like it better. I might not always put it in, for example when the heredoc operator is part of a bigger expression and needs to be more of a visual pill in itself. But here, `qq :to 'VERSE'` looks nice and laid-back to me.

Or you could use `qq:to<VERSE>`, which also conveys "this is a string" and doesn't have the above apostrophe problem.

## Indentation, revisited

Let me tell you a story that conveys quite well the Raku maxim of "tormenting the implementors" (to benefit the users).

It's about this kind of code:

```raku
my $description = "not exactly Sparta,\nbut still nice";
say qq :to 'TEXT';
    Wow, this is $description!
    TEXT
```

Before July 2013, this used to warn about not-enough whitespace during de-intentation. Why? Because the `$description` string has two lines, and the second line does not have the required four spaces (or equivalent) of indentation that the terminator requires!

Yes, you read that right. Before the dust settled around exactly how to implement heredocs, you could get warnings because the interpolated *strings* in the heredoc were not properly indented. The heredoc itself would look fine in the code, but you'd still get the warning.

Arguably there are two "local optima" involved, though. Two possible ways in which we could view the process of interpolation/de-indentation. Let me lay them out for you:

- 
First, the heredoc string is finalized by interpolating all the variables into it. The resulting string is then de-indented.
- 
The heredoc is a sequence of constant strings separated by interpolations (either variables or expressions in `{}` blocks). The constant strings are de-indented, but the interpolations are left as-is.

The first model has fewer moving parts, and is easier to implement. The second model is easier to understand for the user, but more work for the implementor.

We ended up having the first model in Rakudo for a while, and I argued for the second model. Eventually *TimToady* settled the matter:

```
<*TimToady*> the intent is that heredoc indent is a textual feature, not a shortcut for a run-time feature
<*TimToady*> yes it's harder, but STD does it that way (and so niecza, I think)
<*TimToady*> it's what the user wants, not the implementor
```

In the end, *timotimo*++ implemented the second model, and all was well. You won't get de-indentation warnings from inside your interpolated variables.

...Furthermore, as a nice bonus, the constant string fragments can actually be de-indented at compile time! Because they're constant, and known at compile time. Under the former model we couldn't do that, since the entire string wasn't known until that point in the code at runtime (in the general case).

## The limits of sanity

One final thing. One niggling little bit of discomfort remains.

You currently can't do this:

```raku
constant INTRO = q :to 'INTRO';
    Space: the final frontier.
    These are the voyages of the starship Enterprise.
    Its continuing mission: to explore strange new worlds,
    to seek out new life and new civilizations,
    to boldly go where no one has gone before.
    INTRO
```

A constant declaration gets evaluated and assigned to at parse-time, as soon as the parser sees the semicolon at the end of the declaration. And that's the problem, because at the point the parser hasn't yet seen the promised heredoc, and so it has nothing to assign to the constant.

The problem is perhaps a little easier to see if the constant declaration is re-written as a `BEGIN` block instead. `BEGIN` blocks also run ASAP, as the closing `}` is being parsed. This also doesn't work:

```raku
my $INTRO;
BEGIN { $INTRO = q:to/INTRO/; }
    Space: the final frontier.
    These are the voyages of the starship Enterprise.
    Its continuing mission: to explore strange new worlds,
    to seek out new life and new civilizations,
    to boldly go where no one has gone before.
    INTRO
```

I get that there are good reasons for disallowing the above two constructions. It's just that... I don't know, it feels slightly unfair. Heredocs are very nice and work well, constants are very nice and work well. If you combine them, the result ought to be twice as nice and also work well. But it isn't, and it doesn't.

In the case of de-indentation of interpolated variables, it was more of a clear-cut case of writing a bit more compiler code to DWIM things for the user. In this case... the stakes are higher. Because if the above were to work, we'd have to create an exception to one-pass parsing, something that Raku values very highly.

```
<*TimToady*> masak: the fundamental problem with making the
  constant lookahead for the heredoc is that it
  violates the one-pass parsing rule
<masak> *TimToady*: yes, I realize that.
<*TimToady*> in fact, STD used to do the lookahead like Perl
  does, and I rewrote it to avoid that :)
<*TimToady*> in fact, the discussion at S02:4474 stems from
  that time
```

In spite of all this, I remain hopeful. Maaaaaybe we can deviate ever so slightly from the one-pass parsing rule just to be a bit more DWIM-y to users who like both constants and heredocs. Maybe, just maybe, there's a clean way to do that. There's an [open RT ticket](https://rt.perl.org/Public/Bug/Display.html?id=117853) that keeps hoping there is.

In the meantime, there's also a workaround. If I just put the semicolon after the heredoc, things work out.

```raku
constant INTRO = q :to 'INTRO'
    Space: the final frontier.
    These are the voyages of the starship Enterprise.
    Its continuing mission: to explore strange new worlds,
    to seek out new life and new civilizations,
    to boldly go where no one has gone before.
    INTRO
;
```

It's not ideal, but it will do in the interim.

**Update 2015-04-11:** Not four hours after I published my post, *TimToady*++ had constants with heredocs patched (cleanly) into Rakudo. He also updated S02. So I'm officially out of discomforts. 哈哈

Anyway, that was my story about heredocs. Here's to heredocs! 🍻
