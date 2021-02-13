# LTM for alternations
    
*Originally published on [2012-06-07](https://6guts.wordpress.com/2012/06/07/ltm-for-alternations/) by Jonathan Worthington.*

This month’s Rakudo development work has already seen us [switch to the new QRegex grammar engine](https://6guts.wordpress.com/2012/05/28/rakudo-switched-over-to-qregex/) for parsing Raku source, unifying it with the mechanism for user-space grammars and regexes. A week and a bit on, another major improvement in this space has also landed: alternations now participate in Longest Token Matching, as per spec. What does this mean? To give a simple example:

```` raku
> say "beer" ~~ /be|.*/
q[beer]
````

Here, the second branch of the alternation wins – because it matches more characters than the first branch. This is in contrast to sequential alternation (which you are likely more used to), which is done with the || operator in Raku:

```` raku
> say "beer" ~~ /be||.*/
q[be]
````

The `||` may remind you of the short-circuiting `or` operator, which is exactly what a sequential alternation in a regex does: we try the possibilities in order and pick the first one that matches. On the other hand, the `|` is a reminder of the `any` junction constructor, which is analogous to what happens in a regex too: we process all of the branches with a parallel NFA, trimming impossible options as we go, and the one that matches most characters will win. If multiple match, we take them in order of length until one matches.

Note that – just like with protoregexes – the thing we actually use the NFA on is the declarative prefix. Raku regexes are a mixture of declarative and procedural; the switch between them is seamless. The declarative bits are amenable to processing with an NFA.

Longest token matching is not only a Raku user-space feature, but also used when parsing Raku – and this goes for alternations too. In fact, the ability to quickly decide which branch to take out of a bunch of possible options is also important for parsing performance. STD, the standard grammar, is written so that trying things sequentially will usually give a correct parse. However, there are exceptions, and up until now they have been problematic. With this work, we now come closer to parsing things the way the standard grammar does. In fact, a lot of the tweaks I had to make in order to get the Raku grammar to parse things correctly again after implementing longest token matching for alternations were a case of aligning it more closely with STD, which is decidedly encouraging.

So, the branches in NQP and Rakudo containing this work have landed. Once again, it was a fairly deep and significant change, and pulling it off has involved various other improvements along the way (such as making tie-breaking by declaration order work reliably). Happily, the improvements we’ve made because we dogfood the grammar engine to parse Raku source will also make things better for those writing grammars in Rakudo. I merged it this evening, with no regressions in the spectests or in module space tests.

While I’ve put in most of the commits on this work, it certainly wasn’t a one person effort. *pmichaud*++ is once again to thank for the excellent design work behind this, and *moritz*++, *tadzik*++ and *kboga*++ have both helped with testing, fixing tests that had bad assumptions about LTM semantics and fixing Pod parsing to work with the new alternation semantics.

The next release is still two weeks off. I expect to spend my tuits, which should be in reasonable supply, on various follow-up tweaks as a result of the regex engine work, pre-compilation improvements and diving into the QAST work, which I’m hopeful will land in time for the July release. Meanwhile, stay tuned: I expect *pmichaud*++ will have some nice news about what he’s been cooking up for the June release coming up soon. :-)
