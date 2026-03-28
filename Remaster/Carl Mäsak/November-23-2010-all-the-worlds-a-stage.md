# November 23 2010 — all the world's a stage
    
*Originally published on [24 November 2010](http://strangelyconsistent.org/blog/november-23-2010-all-the-worlds-a-stage) by Carl Mäsak.*

> 2543 years ago today &mdash; assuming there was no [year 0](http://irclog.perlgeek.de/raku/2010-11-23#i_3025150) &mdash; [Thespis of Icaria](https://en.wikipedia.org/wiki/Thespis) won the first documented competition for Best Tragedy in Athens. Thespis is credited with the invention of acting out written plays.

> Thespis of Icaria (present-day Dionysos, Greece) (6th century BC), according to certain Ancient Greek sources and especially Aristotle, was the first person ever to appear on stage as an actor playing a character in a play (instead of speaking as him or herself).

But having invented "pretending you're someone else on stage", he didn't stop there.

> Capitalising on his success, Thespis also invented theatrical touring: he would tour various cities while carrying his costumes, masks and other props in a horse-drawn wagon ([see picture](https://en.wikipedia.org/wiki/File:Formella_15,_il_carro_di_Tespi_(Theatrica),_nino_pisano,_1334-1336.JPG)).

Historical documents are silent on whether he also had a manager.

We left off yesterday with garbled output:

```
Are y u eager t  see Per  6  eing re eased, s  y u  an write      
pr grams in it with ut w rrying if the  anguage is "d ne" yet?
```

Some key letters are missing, incidentally all also part of the word `block`. (Though there was no `k` in the above sentence to begin with.) My guess, without having looked at the code yet, is that there's a `.trans` call somewhere, and that it accidentally stringifies a regex or some other `Callable`.

Looking...

Um. Ok. So... this is going to be a bit unsatisfactory, from the point of view of lucid explanations. The problem went away as I diagnosed it.

Here are the details: there appears to be no piece of code actually causing this problem. In fact, I commented out the whole `Text::Markup::Wiki::MediaWiki` code path, and things *still* failed. At this point, I was a bit mystified.

In November (the wiki engine), we've introduced a *cache*, in order to speed up page generation. The cache stores the HTML generated from the source markup, and as I looked at the appropriate file in that cache, it looked broken in exactly the above way.

So I cleared the cache. And the problem went away.

The text looks OK now. But it doesn't generate HTML any more at all. It just spits out the original Mediawiki markup. And I have no idea why. (And yes, I did revert the change that turned off the `Text::Markup::Wiki::MediaWiki` code path.)

An excellent place to start investigating tomorrow.
