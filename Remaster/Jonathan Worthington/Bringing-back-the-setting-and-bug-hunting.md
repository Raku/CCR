# Bringing back the setting, and bug hunting
    
*Originally published on [16 November 2009](https://use-perl.github.io/user/JonathanWorthington/journal/39904/) by Jonathan Worthington.*

This is a report on what I did on my Rakudo Day on Friday, but didn't manage to finish writing up until now.

It was time to switch focus from building up metamodel primitives in the Rakudo refactor for a bit and dig into the work of bringing back a bunch of the Raku setting - the built-in classes and functions that are implemented in Raku. In doing so, I knew I'd discover lots of other little bits that would need putting back, which would guide my efforts. I chose to work towards bringing back Any-num.pm first - various bits relating to numbers. Preparing to do that led me to fix up a whole raft of other bits.

- Needed to bring the way we parsed method declarations more in line with STD.pm.
- Needed to update the identifier rule to match STD.pm so we could have identifiers with hyphens in.
- Got basic support for when/default blocks in place; *mathw*++ had already done given blocks.

After that, I could also bring Int.pm back into the setting. That went pretty smoothly, though needed a few tweaks since subs have `my` scope by default in Raku now, something that we never updated master to handle, but have got right from the start in the ng branch. Adding that in allowed me to get rid of a few of the "cheats" that we'd had in place beforehand.

Continuing on the theme of number handling, my next act was to try and bring back `Rat` and `Complex`. `Rat` went in with a bit more hassle. I discovered that I'd managed to make a mess of declaration order mapping between source and the PAST tree we built. Happily, once I understood the problem, the fix was only a few lines of patching. However, then I hit on something else weird: we seemed to be calling wrong multi-candidates.

I was sure I'd made a mistake in the code-gen...but no, it all looked right. Bug in the signature generation? Nope, those looked good too. It wasn't going to be a multi-dispatcher bug really, given that this had been brought in practically unchanged from master - or at least, without any notable changes. After a lot of searching I discovered that we really weren't entering the multi-dispatcher at all, but instead always jumping to the same candidate - but only in other code in the setting, not in stuff done in the REPL. Realizing it was only an issue with code in the same compilation unit was a big clue. Due to changes in the way we're doing code generation now - in order to not create so many bogus objects of the wrong type at startup that we only then have to re-bless - a nasty Parrot issue had shown up to crash the party. Worse, while I'd call it an optimization bug, *pmichaud*++ correctly pointed out that a lot of existing code was almost certainly going to be relying on things working this way - the optimization was providing a feature, pretty much. Thus my proposal to just disable it wasn't quite going to fly. This issue still somewhat remains "to solve", but I'm hopeful we'll get some solution of some sort today, as I suspect it's going to become a bit of a serious blocker otherwise. Blocker as in, we probably can't pass any of the multi dispatch tests before it's fixed, even though the dispatcher itself is likely fine. What a PITA.

After hunting that down, I only really had time to get Complex.pm back in. There was much commenting out still, but that will guide me on what I needed to hack on next. And happily, having put these bits back led *colomon*++ to hack away on them a bit over the weekend. Thanks to Vienna.pm for sponsoring my work on Rakudo.
