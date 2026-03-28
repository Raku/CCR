# November 5 2010 — aim for the eye!
    
*Originally published on [5 November 2010](http://strangelyconsistent.org/blog/november-5-2010-aim-for-the-eye) by Carl Mäsak.*

> 454 years ago today, the (second) Battle of Panipat was joined in northern India. The [Wikipedia entry](https://en.wikipedia.org/wiki/Battle_of_Panipat_(1556)) could use some editing, but here's the interesting strategic part of the battle:

> It seemed Hemu was on a winning track and Akbar's army would rout. However, Khan Zaman I, the veteran of many a wars and an able general had planned otherwise. With a much smaller army, his plan was clear. The warriors of that time, including Hemu wore armour completely covering their body specially the vulnerable organs except the eyes. After repeated attempts a stray arrow struck Hemu's eye and he was knocked down senseless, almost dead in his *howda* (elephant seat) on the elephant. Not seeing Hemu in his howda, Hemu’s army was in disarray and defeated in the ensuing confusion.

Some nice things about this: (1) they were using elephants in battle, that's got to look impressive; (2) one of the combatants is named Akbar. But he's on the winning side, so it does not make much sense for him to yell ["it's a trap!"](https://en.wikipedia.org/wiki/Admiral_Ackbar#Popular_culture). Neither was he a admiral; he was an emperor.

Instead of taking eight minutes to munch generate stuff for my blog, my static page generator now takes slightly above three minutes.

The change I made is adding in this subroutine, which returns `True` if a given `$target` file doesn't exist, or if it is older than its corresponding `$source` file.

```raku
sub nonexistent-or-older($target, :than($source)!) {
    return $target.IO !~~ :e
           || $target.IO.changed before $source.IO.changed;
}
```

I especially like the last line. I read it out loud as "or target IO changed before source IO changed", which is pretty much what the code is doing. I took a *teeny* bit of a liberty in using `before` rather than `<`, because it reads better. Generally I don't like that kind of catering to English-like code, but here it seemed too good to resist. Note that I kept `||` in favor of `or` &mdash; even I have my limits.

Anyway, it turned out that the subroutine was generalized and lost its pretty perfectly-readable last line; some files like `index.html` and `feed.atom` are composed from several source files, and they all need to be checked against the target. So the final version I ended up with was this:

```raku
sub nonexistent-or-older($target, :than(@sources)!) {
    return $target.IO !~~ :e
           || any map { $target.IO.changed before $_.IO.changed }, @sources;
}
```

[**Addendum:** *sorear*++ points out that I should be writing the above as `$target.IO.changed before any(@sources).IO.changed`. Clearly that's what the above code *wants* to look like, platonically speaking. And we're back at extreme readability. I have much to learn still about the wonders of Raku.]

Much of the work that remains with `psyde` is pushing calls such as this into a data structure so that whatever code the user produces, things like this will be called automatically. Right now I do it manually, and my `psyde` script is ~200 lines long. When everything is stacked neatly into an API, I might get away with as little as ~40. Maybe less.
