# Three bugs that bug me right now
    
*Originally published on [27 January 2009](http://strangelyconsistent.org/blog/three-bugs-that-bug-me-right-now) by Carl Mäsak.*

I'm stuck, *thrice*, and the Rakudo devs are nowhere to be seen. So I'm venting my frustration on you, the reader, an innocent third party, instead. Unfair? You bet.

```
<masak> moritz_: how can I tell RT "I care a lot about this bug"?
<moritz_> masak: blog about it *g*
<masak> 哈哈
```

## Bug number one

Happily hacking away on my not-yet-ready-for-the-world SVG emitter, I trigger a [pairs passing bug](https://github.com/Raku/old-issue-tracker/issues/650) while sending things to a constructor, and then once more when passing a hash through a method. Development comes to a screeching halt.

## Bug number two

I'm working on the list parsing in the MediaWiki parser for November. List parsing is tricky, but fortunately the grammar and PGE stuff is really stable already. There's this new method, though: `Grammar.parse("string")`, to be used instead of the obsoleted syntax `"string" ~~ Grammar`. I use the `.parse` method, and things [blow up](https://github.com/Raku/old-issue-tracker/issues/648). I might be able to work around this one, temporarily putting `Grammar::TOP` in a regex. But it'll mean rewriting a whole lot of code that should work as it is. [**Update 2009-01-28:** It didn't need that much rewriting, but unfortunately it turned out that the bug was endemic, not merely limited to `.parse`. So, still stuck.] [**Update 2009-03-06:** Fixed in 0bbdb57 by *pmichaud*++.]

## Bug number three

I'm hunting down a silly bug in the did-somebody-just-win subroutine in Druid — a subroutine to which I might dedicate a blog post of its own one day, by the way — only to discover that under some very special circumstances, `.clone` [messes up the original objects](https://github.com/Raku/old-issue-tracker/issues/660). The result is spooky action at a distance, and my algorithm ends up returning basically random results. Not good. [**Update 2009-02-11:** Fixed in 59024e0 by *jonathan*++.]

## kthxbai

I know that when the most constructive thing I can do is to complain, I'm pretty far down the Maslow hierarchy. I've tried to analyze the above bugs myself by reading Rakudo source, but haven't gotten anywhere so far. I'm eager to continue what I was doing in each of the above projects. I look forward to putting updates in this post, with little plus marks next to the person that decides to have pity on my rakudobug suffering.

plz fix. kthxbai.
