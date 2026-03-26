# November 13, 2008 — the storm after the storm
    
*Originally published on [14 November 2008](http://strangelyconsistent.org/blog/november-13-2008-the-storm-after-the-storm) by Carl Mäsak.*

38 years ago today, what has been called the [20th century's worst natural disaster](https://en.wikipedia.org/wiki/1970_Bhola_cyclone) claimed between 300,000 and 500,000 lives in one night, primarily as a result of the storm surge that flooded much of the low-lying islands of the Ganges Delta.

> The Pakistan Meteorological Department issued a report calling for "danger preparedness" in the coastal regions in danger during the day on November 12. As the storm neared the coast, a "great danger signal" was broadcast on Pakistan Radio. Survivors later said that this meant little to them, but that they had recognised a No. 1 warning signal as representing the greatest possible threat. It is estimated that 90% of the population in the area was aware of the cyclone before it hit, but only about 1% sought refuge in fortified structures.

Though destructive of people and property, the storm finally led to the creation of a new state.

> The Pakistani government was severely criticized for its handling of the relief operations following the storm, both by local political leaders in East Pakistan and in the international media. The opposition Awami League gained a landslide victory in the province, and continuing unrest between East Pakistan and the central government triggered the Bangladesh Liberation War, which concluded with the creation of the state of Bangladesh.

Longish post. I'll document, as best I can, why a simple piece of code that I thought would take one (half-hour) day, instead took three.

Oh, and sensitive readers, people who are used to code actually getting prettier and more reasonable as it matures, or who are used to programming on stable, well-established platforms, should perhaps consider slowly putting this blog post away and closing their browser tab. Things'll get nasty, I'm afraid.

Behold my [first attempt](https://gist.github.com/masak/24637). There's much I like about this code (which, by the way, transforms something like `"foo\n\nbar\nbaz"` into `"<p>foo</p>\n\n<p>bar baz</p>"`, a useful transformation when you're building HTML from markup):

- It's short and to the point.
- I discovered that something like `/\n ** 2..*/` actually works in Rakudo (well, PGE) already. How cool is that? (I guess this would be written `/\n{2,}/` in Perl.)
- Though the `.trans` method call is already a workaround — we don't yet have the moral equivalent of `$string ~~ s/\s+/ /` in Rakudo — it's quite clear and concise.

But alas, it was not meant to last. Because when I ran it, Rakudo yelped:

```
too few arguments passed (2) - 3 params expected
```

Turned out that the `.trans` call was the culprit. See the error? No, I didn't either. In fact, similar calls worked in other files in the code base. `.trans` takes a list of pairs as an argument. When the invocant is counted among the arguments, we have 2 arguments, not 3. Why did it want 3 arguments all of a sudden?

*pmichaud*++ [explained](https://irclogs.raku.org/perl6/2008-11-11.html#16:39) on #perl6: the `.split` returns a list of strings — however, instead of a list of *Rakudo* strings (called `Perl6Str` internally in Parrot), it returned a list of *Parrot* strings (called `Str` **[Update 2008-11-13: no, `String`. *pmichaud*++]**). Only Rakudo strings have the Raku string methods on them, of course. So the next method call on those strings will likely fail. Like `.trans`, for example.

But why the strange error message? Well, as it turns out (grr!), Parrot strings *also* have a `.trans` method, which happens to modify the string in-place and take 3 arguments. I've come across this method [before](https://github.com/Raku/old-issue-tracker/issues/203), in similar situations of abstraction leakage.

So, in other words, not good. But it can be fixed, right? Turns out, [not right now](https://irclogs.raku.org/perl6/2008-11-11.html#16:46). ☹ Something called "HLL type mapping" is needed before this can be adequately fixed. Now, HLL type mapping is the interesting issue of converting between the object types of different High Level Languages on top of Parrot. In this case, Rakudo and PGE. Mapping data types sensibly between different languages sounds like a non-trivial problem to me. I hope someone starts working on it soon, so that I can use `.trans` on my `.split` list of strings.

But what I needed there and then was a workaround. [Here it is](https://gist.github.com/masak/24656). No, it doesn't look as nice as before. I'm glad you noticed, very astute of you. *And* it doesn't work. What it did was turn up [yet another bug](https://irclogs.raku.org/perl6/2008-11-12.html#12:32).

This time it turned out to be a [lexicals issue](https://irclogs.raku.org/perl6/2008-11-12.html#22:20): the gather block somehow got old values in variables, values which were the latest fad in the last iteration, but which are currently outdated in this one. (For those of you who are unsure of what a lexical is, you can think of it as the thing which stands between you and undeserved pain when you're programming. That doesn't simplify things too much.)

Ah. Well, since this problem involved gather/take, which is essentially sugar for array/push, I settled on pushing to arrays instead. [Here's attempt number three](https://gist.github.com/masak/24663). Not as sexy, but it works. You heard right: my third attempt at this code worked. Yay.

I won't need to go through the list of advantages and compare. Those advantages disappeared in the first watering-down iteration. The second only made it worse. It's actually a recurring phenomenon: workarounds in November tend towards pseudocode. It's still pseudocode dressed as Raku, to be sure, but the conversion is always accompanied with a certain sadness, because you know you're (temporarily) walking away from some cool Raku feature, which you itched to use.

Here's hoping that the destruction and mayhem I've described above will eventually lead to the creation of a stable, dependent Raku. I'm crashing Rakudo today, so that it won't crash for you tomorrow.

(P.S. Just [talked](https://irclogs.raku.org/perl6/2008-11-13.html#12:25) to *pmichaud*++. He says that solving both the above problems might actually not be very far into the future. I'm looking forward to see the pseudocode curl up into beautiful code again.)

[Update 2008-11-14: *pmichaud*++ surprises with an almost-clean workaround with only one extra line, working *today*. The world just got a tad brighter again.]
