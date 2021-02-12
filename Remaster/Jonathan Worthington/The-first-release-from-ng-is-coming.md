# The first release from ng is coming!
    
*Originally published on [18 February 2010](https://use-perl.github.io/user/JonathanWorthington/journal/40190/) by Jonathan Worthington.*

Tomorrow's regularly scheduled Rakudo release is the first one since the long-running "ng" branch became master. It represents both a huge step forward and at the same time a fairly major regression. Internally, the changes are enormous; some of the biggest include:

- We're parsing using a new implementation of Raku regexes by *pmichaud*++. It is a huge improvement, supporting amongst other things protoregexes, a basic form of LTM, variable declarations - including contextuals - inside regexes and more. The AST it generates is part of the PAST tree rather than having a distinct AST, which is a neater, more hackable approach. The issues with lexical scopes and regexes are resolved. Closures in regexes work.
- NQP is also re-built atop of this. It incorporates regex and grammar support, so now we run both grammar and actions through the one compiler. It's bootstrapped.
- In light of those major changes, we started putting the grammar back together from scratch. A large part of this was copy and paste - from STD.pm. The grammar we have now is far, far closer to STD than what we had before. Operator precedence parsing is handled in the same kind of way. We've started to incorporate some of the nice STD error detection bits, and catch and nicely report some Perl-isms.
- Since the grammar got re-done, we've been taking the same approach with the actions (the methods that take parse tree nodes and make AST nodes). Thanks to contextual variable support and other improvements, a lot of stuff got WAY cleaner.
- The list/array implementation has been done over, and this time it's lazy. There's certainly rough edges, but it's getting better every day. The work to implement laziness has led to many areas of the spec getting fleshed out, too - a consequence of being the first implementation on the scene I guess.
- All class and role construction is done through a meta-model rather than "magic". The Parrot role composition algorithm is no longer relied upon, instead we have our own implementation mostly written in NQP.
- The assignment model was improved to do much less copying, so we should potentially perform a bit better there.
- Lexical handling was refactored somewhat, and the changes should eliminate a common source of those pesky Null PMC Access errors.

Every one of these - and some others I didn't mention - are important for getting us towards the Rakudo * release. The downside is that since we've essentially taken Rakudo apart and put it back together again - albeit on far, far better foundations - we're still some way from getting all of the language constructs, built-in types and functions back in place that we had before. It's often not just a case of copy-paste; many of the list related things now have to be written with laziness in mind, for example.

So anyway, if you download tomorrow's release and your code doesn't compile or run, this post should explain - at least at a higher level - why. After a slower December and January, Rakudo development has now once again picked up an incredible pace, and the last couple of week's efforts by many Rakudo hackers have made this release far better than I had feared it was going to be. If we can keep this up, the March release should be a very exciting one.
