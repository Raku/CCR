# Last week: Unicode case fixes and much more
    
*Originally published on [2015-10-15](https://6guts.wordpress.com/2015/10/15/last-week-unicode-case-fixes-and-much-more/) by Jonathan Worthington.*

This report covers a two week period (September 28th through Sunday 11th October). However, the first week of it was almost entirely swallowed with teaching a class and the travel to and from that – so I’d have had precisely one small fix to talk about in a report. The second week saw me spend the majority of my working time on Raku, so now there’s plenty to say.

### A case of Unicode

I decided to take on a couple of Unicode-related issues that were flagged for resolution ahead of the 6.christmas release. The first one was pretty easy: implementing stripping of the UTF-8 BOM. While it makes no sense to have a byte order mark in a byte-level encoding, various Windows programs annoyingly insert it to indicate to themselves that they’re looking at UTF-8. Which led to various fun situations where Raku users on Windows would open a UTF-8 file and get some junk at the start of the string. Now they won’t.

The second task was much more involved. Unicode defines four case-changing operations: uppercasing, titlecasing, lowercasing, and case folding. We implemented the first three – well, sort of. We actually implemented the simple case mappings for the first three. However, there are some Unicode characters that become multiple codepoints, and even multiple graphemes, on case change. The German sharp S is one (apparently controversial) example, ligatures are another, and the rest are from the Greek and Armenian alphabets. First, I implemented case folding, now available as the fc method on strings in Raku. Along the way I made it handle full case folds that expand, and added [tests](https://github.com/raku/roast/blob/master/S32-str/fc.t). Having refactored various codepaths to cope with such expansion, it was then not too hard to get uc/tc/lc updated also. The final bit of fun was dealing with the interaction of all of this with NFG synthetics ([tests here](https://github.com/raku/roast/blob/master/S15-nfg/case-change.t#L49)). Anyway, now we can be happy we reach Christmas with the case folding stuff correctly implemented.

### Fixing some phasing issues with phasers

RT #121530 complained that when a `LEAVE` block threw an exception, it should not prevent other `LEAVE` and `POST` blocks running. I fixed that, and added a mechanism to handle the case where multiple `LEAVE` blocks manage to throw exceptions.

Amusingly enough, after fixing a case where we didn’t run a `LEAVE` block when we should, RT #121531 complained about us running them when we shouldn’t: in the case `PRE` phasers with preconditions failed. I fixed this also.

### The usual bit of regex engine work

When you call a subrule in a regex, you can pass arguments. Normally positional ones are used, but RT #113544 noted that we didn’t yet handle named arguments, nor flattening of positional or named arguments. I implemented all of the cases, and added tests.

I reviewed and commented on a patch to implement the `<?same>` assertion from the design docs, which checks that the characters either side of it are the same. I noted a performance improvement was possible in the implementation, which was happily acted upon.

Finally, I started looking into an issue involving LTM, character classes, and the ignorecase flag. No fix yet; it’s going to be a bit involved (and I wanted to get our case handling straightened out before really attacking this one).

### Copy-casta

We suddenly started getting some bizzare mis-compiles in CORE.setting, where references to classes near the end of it would point to completely the wrong things. It turned out to be a (MVMuint16) cast that should have been an (MVMuint32) down in MoarVM’s bytecode assembler – no doubt wrongly copied from the line above. It’s always a relief when utterly weird things end up not being GC bugs!

### A little profiler fix

If you did –profile on a program that called `exit`, the results were utterly busted. Now they’re correct.

### Other little bits

Here’s a collection of other things I did that are worth a quick mention.

- Reviewing new RT tickets and commits; of note, reviewing patch for making `:D` / `:U` types work in more places
- Eliminating remaining method `postcircumfix:<( )>` uses in Rakudo/tests. Looking into coercion vs. call distinction.
- Reviewing “make `Bool` an `enum`” branch
- Looking further into call vs. coercion and coercion API as part of RT #114026; post a [proposal for discussion](https://gist.github.com/anonymous/8efdab238ead35b1d4fa)
- Fix `CORE::.values` to actually produce values (same for other pseudo-packages); fix startup pref regression along the way
- Studying latest startup profile, identifying a recent small regression
- Investigate RT #117417 and RT #119763; request design input to work out how we’ll resolve it
- Fix RT #121426 (routines with declared return type should do `Callable[ThatType]`)
- Review RT #77334, some discussion about what the right semantics really are, file notes on ticket
- Fix RT #123769 (binding to typed arrays failed to type check)
- Write up a rejection of RT #125762
- Resolve RT #118069 (remove section on protos auto-multi-ing from design docs as agreed, remove todo’d tests)
- Fix RT #119763 and RT #117417 (bad errors due to now-gone colonpair trait syntax not being implemented)
- Reading up on module installation writings: S11, S22, gist with input from many in preparation for contributing to design work in the area

And that’s it. Have a good week!
