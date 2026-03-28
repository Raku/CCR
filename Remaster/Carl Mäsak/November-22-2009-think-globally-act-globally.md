# November 22 2009 — think globally, act globally
    
*Originally published on [23 November 2009](http://strangelyconsistent.org/blog/november-22-2009-think-globally-act-globally) by Carl Mäsak.*

> 27 years ago today, a 10-year old girl read the news, asked a question, and [changed the course of the world](https://en.wikipedia.org/wiki/Samantha_Smith). The Wikipedia article has the story, which is in some sense larger than life, with a fairy tale beginning and a sad, blunt ending:

During this period, large anti-nuclear protests were taking place across Europe and North America, while the November 20, 1983, screening of ABC's post-nuclear war dramatization The Day After became one of the most anticipated media events of the decade.

In this atmosphere, on November 22, 1982, Time magazine published an issue with [then Soviet's General Secretary] Andropov on the cover. When [Samantha] Smith viewed the edition, she asked her mother, "If people are so afraid of him, why doesn't someone write a letter asking whether he wants to have a war or not?" Her mother replied, "Why don't you?"

She wrote the letter, Andropov answered, and in the reply was an invitation to Russia. The correspondance is too long to reproduce here, but not too long to [go and read on Wikipedia](https://en.wikipedia.org/wiki/Samantha_Smith#Life). Bottom line, the General Secretary invited her to Soviet Russia, and she went there, as a sort of ambassador. She became a media phenomenon, both in the US and in Soviet Russia.

She died three years later in a tragic plane crash. She [has her own stamp](https://en.wikipedia.org/wiki/File:USSR_stamp_S.Smith_1985_5k.jpg).

Today I asked *jnthn*++ what to do if I wanted to help with the `ng` branch. He suggested I put in `&open`.

I found that `t/spec/S16-filehandles/io.t` would probably be a good file to make pass, since it contained a lot of `&open` tests. So I ran it.

It didn't parse. `!~~` was missing. This is the only standard operator which *shouldn't* be added automatically by the `!` metaoperator, because it doesn't do the boolean negation of `~~`. Where the latter calls `ACCEPTS`, the former calls another method, `REJECTS`. I [put in `!~~` ](https://github.com/rakudo/rakudo/commit/218aee648a0742ba690ad6eabcad7dcc0cffafec) in `ng`.

The test file, which had now started running, failed on not finding the `.pick` method on `Range`. I started to put it back in `Any-list.pm`, where it had been in `master`. It contained features which are not implemented in `ng` yet, such as binding and `gather`. I wrote limited workarounds.

While I was in `Any-list.pm`, I noticed a misplaced `.perl` method, which should really be in `List.pm`. I [moved it](https://github.com/rakudo/rakudo/commit/44092124a13e614f01fe4b5a22da411f44509a1c).

Before I committed my `.pick` implementation, I was foolish enough to run it. Doing that revealed that `Range` doesn't have a `.list` method implemented. Well, I can do that, I thought. So I did.

But when I tried running *that*, it failed because it uses `&push`, which isn't implemented either. The `.pick` implementation I had written also uses `&push`, in the code which workarounds the lack of `gather`. I was informed that putting in `&push` would be non-trivial in some ways.

At this point, I [called it a night](https://en.wikipedia.org/wiki/Sleep). Now I better understand what *jnthn*++ means when he's saying that trying to put in one thing in `ng` usually leads to having to put in a bunch of things. It's very true. But it was also really fun to help, in a small way. I will likely do it again soon.
