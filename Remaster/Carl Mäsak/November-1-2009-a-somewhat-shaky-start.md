# November 1 2009 — a somewhat shaky start
    
*Originally published on [2 November 2009](http://strangelyconsistent.org/blog/november-1-2009-a-somewhat-shaky-start) by Carl Mäsak.*

254 years ago today, an earthquake [stirred](https://en.wikipedia.org/wiki/1755_Lisbon_earthquake) the city of this year's YAPC::EU, Lisbon:

> In 1755, the earthquake struck on the morning of 1 November, the Catholic holiday of All Saints' Day. Contemporary reports state that the earthquake lasted between three-and-a-half and six minutes, causing gigantic fissures five metres (15 ft) wide to appear in the city centre. Survivors rushed to the open space of the docks for safety and watched as the water receded, revealing a sea floor littered by lost cargo and old shipwrecks. Approximately forty minutes after the earthquake, an enormous tsunami engulfed the harbour and downtown, rushing up the Tagus river, "so fast that several people riding on horseback ... were forced to gallop as fast as possible to the upper grounds for fear of being carried away". It was followed by two more waves. In the areas unaffected by the tsunami, fire quickly broke out, and flames raged for five days.

In *Candide*, Voltaire later used the Lisbon disaster as "a salutary counterexample" of the idea that we live in "the best of all possible worlds". Apparently, his contemporaries needed to have that pointed out to them.

At the start of my first November Month day, 193 tests out of a total of 202 pass. 9 tests fail. 7 files give parse errors.

That's actually not too bad for a Raku project, where it's a positive surprise if there are tests at all. But it's not enough; we used to pass all tests with flying colors. Time to re-establish November's position as a pioneer project! Time to rectify those bit-rotted tests.

First failure: the only test in `t/markup/mediawiki/16-pre.t`. That's because that feature isn't implemented yet. I mark it as a TODO.

The next one (`t/markup/mediawiki/08-formatting-and-links.t`) seems more interesting: I get `Too many positional parameters passed; got 3 but expected 2`. It's a glitch in the Matrix; [it happens when they change something](https://www.imdb.com/title/tt0133093/quotes). ☺ Investigating...

Oh yes. This line:

```raku
my $actual_output = $converter.format($input, $link_maker);
```

should never have worked, because the method `format` looks like this:

```raku
method format($text, :$link_maker, :$extlink_maker, :$author) {
```

I suppose you see it right away, but just in case, let me spell it out: that's one positional parameter (`$text`) in the method declaration, but we try to pass two positionals (`$input` and `$link_maker`) in the call. (Rakudo/Parrot reports "got 3 but expected 2", seemingly overshooting both counts by 1, since it includes the invocant as a parameter/argument. Something that will confuzzle Raku newbies till the end of time, no doubt.)

Anyway, the fix is simple:

```raku
my $actual_output = $converter.format($input, :$link_maker);
```

(How did this ever work previously? Бог knows.)

Onto the next one. `t/tags/update_tags.t` is reported as a failure, but it passes here. Strange. Let's ssh over to feather and try it there.

Hm. It turned out to be a sort of 'phantom error', caused by my previous unsuccessful attempts to make the `raku` executable work from any directory without running `make install`. *moritz*++ later helped me with this, by basically reading aloud from the README. (The solution is to install things locally with the `--gen-parrot` argument to `Configure.pl`.)

The failure in `t/dispatcher/06-set-param.t` feels like the first genuine one. Worse, it practically requires me to understand the code I'm trying to fix. Not sure I'm up for that...

Oh! I see what it is. The test assumes that the `Test::is` function returns 1 (or `Bool::True`) if it succeeds, but it does no such thing. [*moritz*++ opines that it should](https://irclogs.raku.org/perl6/2009-11-01.html#21:31-0006), though, as should all the other similar test functions. Might patch it some other day, if some enterprising soul doesn't beat me to it.

`t/storage/modification.t` and `t/utils/get_period.t` both suffered from bitrot as the function `int` is now spelled `.Int` (and is a method). The fix was as simple as tracking down and substituting in three different files.

And that's it! All tests pass again. Both November and I feel slightly less rotten. As an extra service, I manually re-ran the HTML smoker, so you can see the result for yourselves. Behold: PASS. I think green might be my favorite color. Your mileage may vary if you're visiting from the future, or from a parallel universe. (But you, the seasoned time/multiverse traveller, probably don't need such disclaimers.)

Just as Lisbon, November has been shaken around slightly by the forces of nature, but eventually bounced back. November: alive and kicking, and stronger than ever! \☮/
