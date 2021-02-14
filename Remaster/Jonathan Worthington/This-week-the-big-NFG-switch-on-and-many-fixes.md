# This week: the big NFG switch on, and many fixes
    
*Originally published on [2015-04-30](https://6guts.wordpress.com/2015/04/30/this-week-the-big-nfg-switch-on-and-many-fixes/) by Jonathan Worthington.*

During my Raku grant time during the last week, I have continued with the work on Normal Form Grapheme, along with fixing a range of RT tickets.

### Rakudo on MoarVM uses NFG now

Since the 24th April, all strings you work with in Rakudo on MoarVM are at grapheme level. This includes string literals in program source code and strings obtained through some kind of I/O.

```` raku
my $str = "D\c[COMBINING DOT ABOVE]\c[COMBINING DOT BELOW]";
say $str.chars;     # 1
say $str.NFC.codes; # 2
````

This sounds somewhat dramatic. Thankfully, my efforts to ensure my NFG work had good test coverage before I enabled it so widely meant it was, for most Rakudo users, something of a non-event. (Like so much in compiler development, you’re often doing a good job when people don’t notice that your work exists, and instead are happily getting on with solving the problems they care about.)

The only notable fallout reported (and fixed) so far was a bizarre bug that showed up when you wrote a one byte file, then read it in using .get (which reads a single line), which ended up duplicating that byte and giving back a 2-character string! You’re probably guessing off-by-one at this point, which is what I was somewhat expecting too. However, it [turned out to be a small thinko of mine](https://github.com/MoarVM/MoarVM/commit/6ef0f8f5199a2ed0e29cbc47f42a65c38e5dc49d) while integrating the normalization work with the streaming UTF-8 decoder. In case you’re wondering why this is a somewhat tricky problem, consider two packets arriving to a socket that we’re reading text from: the bytes representing a given codepoint might be spread over two packets, as may the codepoints representing a grapheme.

There were a few other interesting NFG things that needed attending to before I switched it on. One was ensuring that NFG is closed over concatenation operations:

```` raku
my $str = "D\c[COMBINING DOT ABOVE]";
say $str.chars; # 1
$str ~= \c[COMBINING DOT BELOW];
say $str.chars; # 1
````

Another is making sure you can do case changes on synthetics, which has to do the case change on the base character, and then produce a new synthetic:

```` raku
my $str = "D\c[COMBINING DOT ABOVE]\c[COMBINING DOT BELOW]";
say $str.NFD; # NFD:0x<0044 0323 0307>
say $str.NFC; # NFC:0x<1e0c 0307>
say $str.lc.chars; # 1
say $str.lc.NFD; # NFD:0x<0064 0323 0307>
say $str.lc.NFC; # NFC:0x<1e0d 0307>
````

(Aside: I’m aware there are some cases where Unicode has defined precomposed characters in one case, but not in another. Yes, it’s an annoying special case ([pun intended](http://www.unicode.org/Public/UCD/latest/ucd/SpecialCasing.txt)). No, we don’t get this right yet.)

### Uni improvements

I’ve been using the Uni type quite a bit to test the various normalization algorithms as I’ve implemented them. Now I’ve also filled out various of the missing bits of functionality:

- You can access the codepoints using array indexing
- It responds to `.elems`, and behaves that way when coerced to a number also
- It provides `.gist` and `.raku` methods, working like `Buf`
- It boolifies like other array-ish things: true if non-empty

I also added tests for these.

### What the thunk?

There were various scoping related bugs when the compiler had to introduce thunks. This led to things like:

```` raku
try say $_ for 1..5;
````

Not having `$_` correctly set. There were similar issues that sometimes made you put braces around gather blocks when it should have worked out fine with just a statement. These issues were at the base of 5 different RT tickets.

### Regex sub assertions with args

I fixed the lexical assertion syntax in regexes, so you can now say:

```` raku
<&some-rule(1, 2)>
<&some-rule: 1, 2>
````

Previously, trying to pass arguments resulted in a parse error.

### Other assorted fixes

Here are a few other RTs I attended to:

- Fix and tests for RT #124144 (`uniname` explodes in a weird way when given negative codepoints)
- Fix and test for RT #124333 (SEGV in MoarVM dynamic optimizer when optimizing huge alternation)
- Fix and test RT #124391 (use after free bug in error reporting)
- Fix and test RT #114100 (`Capture.raku` flattened hashes in positionals, giving misleading output)
- Fix and test RT #78142 (statement modifier `if` + bare block interaction; also fixed it for `unless` and `given`)
