# June 18 2011: Junctions
    
*Originally published on [19 June 2011](http://strangelyconsistent.org/blog/june-18-2011-junctions) by Carl Mäsak.*

We've seen junctions a bit already. They showed up as a sidekick to the slightly longer logical operators:

```raku
if $answer == 1 || $answer == 3 { ... }
if $answer == 1 | 3 { ... }               # same thing
```

There's a third way to write it too, and that's by using a function form:

```raku
if $answer == any(1, 3) { ... }
```

The two latter forms mean exactly the same thing; both create a *junction*, a scalar value masquerading as several different scalar values.

The main thing we'd want to use a junction for is to highlight what it is we want to calculate. It's often the case that we *could* write things out with a `for` loop:

```raku
my $matched = False;
for @candidates {
    if $answer == $_ {
        $matched = True;
        last;
    }
}
if $matched { ... }
```

But it's much easier to just "pack" the whole looping into a junction:

```raku
if $answer == any(@candidates) { ... }   # same thing!
```

Under the hood, what happens with a junction is that several different alternatives are tried, and then the final result of the junction is extracted from that. With `any`, we want at least one alternative to evaluate to a true value; with `all`; we want all of them to yield something true.

You're free to think of `any` and `all` as running all of its alternatives in parallel and coming back with a result. That might actually come true sometime &mdash; things going off in sepearate threads and running concurrently &mdash; but right now it's just a possible future optimization.

Just to have this said: it's common for people to look at junctions, think they're really cool, and then expect them to do the following:

```raku
if any(@contestants).won {
    # do something with the winner
}
```

But we can't. Junctions answer questions like "does *any* of these..." or "do *all* of these..."; they don't pick out the things that match or fail to match and hand them back to you. Their *purpose* is to treat several things as a unit. If you find you wanted to tease out values of that unit, what you wanted was probably something more like this:

```raku
my $winner = @contestants.first({ .won });
if $winner {
    # do something with $winner
}
```

And with that, we're all set. See you tomorrow with more blogging.
