# November 20 2010 — leftmost longest whale wins
    
*Originally published on [20 November 2010](http://strangelyconsistent.org/blog/november-20-2010-leftmost-longest-whale-wins) by Carl Mäsak.*

> 190 years ago today, a whaleship called the *Essex* was [attacked by a whale](https://en.wikipedia.org/wiki/Essex_(whaleship)).

> She [the ship] was 87 feet (27 m) long, measured 238 tons, and was captained by the 28-year-old George Pollard, Jr. She is best known for being attacked and sunk by a sperm whale in the Pacific Ocean in 1820. The incident was an inspiration for Herman Melville's 1851 classic novel Moby-Dick.

A whaleship attacked and sunk by a whale? What a [reversal of expectations](https://theoatmeal.com/comics/irony)! Perhaps [Pac-Man](https://www.youtube.com/watch?v=fWL6j0SvqV0) said it best: "Looks like the hunters... have become the hunted."

So, tonight while re-watching the unbelievably bad *Battlefield Earth* &mdash; "a *Plan 9* for a new generation!" &mdash; I tinkered with a re-implementation of `.trans` that [once worked in November](November-17-2010-suppression-and-regressions.html) (the wiki engine). I ended up with [this](https://github.com/rakudo/rakudo/commit/9fe5972f60b9bf41aa73ac6e11893dbd185ee344).

If you'll look at that patch, there's one pattern that I haven't seen anyone else use yet. I needed to define a whole class `LongestSubstitutionMatcher`, but I didn't want to pollute any global namespace with that name, so I put it in a `my` variable inside the `Cool` class. Since `my` variables act a bit like static variables, I guess you could say that this is a way to make a static inner class in Raku. I don't know if this is something I'll use often, but it felt right for this purpose.

Oh, and the line in November that was supposed to work after I implemented this?

```raku
my $cleaned_of_whitespace = $trimmed.trans( [ /\s+/ => ' ' ] );
```

Wouldn't you know it, it's actually *wrong*! 哈哈 So not only did this once work in Rakudo, it worked wrongly. The array brackets (as gleaned from a cursory skim of S05) have no business being there, and the line should really be this:

```raku
my $cleaned_of_whitespace = $trimmed.trans( / \s+ / => ' ' );
```

With that [cleared up](https://github.com/viklund/november/commit/96527a7beacf4078a39181347b93bcd5e8659556), the error I'm now getting from November is this:

```
postcircumfix:<{ }> not defined for type `Str`
  in 'November::make_extlink' at line 1
  in <anon> at line 79:lib/November.pm
  [...]
```

I think I know why that might be. But this is a problem for next time.
