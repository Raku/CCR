# November 8 2010 — Druid is back in town
    
*Originally published on [9 November 2010](http://strangelyconsistent.org/blog/november-8-2010-druid-is-back-in-town) by Carl Mäsak.*

> 63 years ago today, a Nazi exhibition called "Der ewige Jude" ("The Eternal Jew") was opened. I can't find any information on Wikipedia about the exhibition, but there's a ["documentary" with the same name](https://en.wikipedia.org/wiki/The_Eternal_Jew).

> Throughout the film, these supposed traits are contrasted to the Nazi state ideal: while Aryan men are shown to find satisfaction in physical labor and the creation of value, Jews are depicted as finding pleasure in money and a hedonist lifestyle. While members of the Aryan race live healthily, rich Jews are shown as living in bug-infested and dirty homes, even though they could afford better. The footage to convey this was actually captured in ghettos, where living conditions were very poor and unsanitary surroundings were virtually inevitable. While Germanic/Nordic man has an appreciation for Northern culture and imagery, Jews are alleged only to find satisfaction in the grotesque and decadent. Many things that run contrary to Nazi doctrine are associated with Jewish influence, such as modern art, cultural relativism, anarchist and socialist movements, sexual liberation, and the "obscure pseudo-science" of Albert Einstein.

The way I pick these subjects, by the way, is to wander Wikipedia semi-aimlessly until I find something that catches my eye. Today it was this; anti-Jewish propaganda from before WWII. I realize that's not a very cheerful subject, but it was what caught my eye (and I do think that it's an important piece of history to be aware of).

If you are angered or offended by my choice of historical subject today, please let me know. I will also provide a full refund at the exit.

For those of you who also think it's an important piece of history to be aware of, and who are interested in learning more: here's a set of [still images](https://web.archive.org/web/20100311085804/http://www.holocaust-history.org/der-ewige-jude/stills.shtml) from the movie, and here's the movie itself.

Today I realized some long-standing plans to get Druid to work.

It's been one of the victims of serious improvements to Rakudo (which, as you'll recall, got a new grammar engine going from `alpha` to `ng`). Druid was designed with an eye to OO class hierarchies, and even had a few regexes as public attributes. That trick no longer worked.

Well, it did work, if one but added `our` scoping to those attributes. Except that the regexes insisted on calling each other, and *that* didn't work. Actually, never mind. The details are complicated and don't matter. I fixed it. [Here's the fix](https://github.com/masak/druid/commit/383fc260b063743022895d5595ed8afdad6c3eba).

Current status: all the tests run again! There's one undefinedness warning in there somewhere waiting to be explored. Now that we have Working Code and Passing Tests, I'm sure there are a number of refactorings that could be made, including (but not limited to) [the tip *Tene*++ gave me](https://irclogs.raku.org/perl6/2010-11-08.html#22:30-0004).

As an extra bonus, the `druid` script runs! At least to the point where it draws the game board. And it does this with a slow kind of grace. I don't remember it being that slow before. Actually, it looks unacceptably slow.

Tomorrow, I might get around to figuring out why.
