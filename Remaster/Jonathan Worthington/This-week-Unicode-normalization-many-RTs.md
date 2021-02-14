# This week: Unicode normalization, many RTs
    
*Originally published on [2015-04-12](https://6guts.wordpress.com/2015/04/12/this-week-unicode-normalization-many-rts/) by Jonathan Worthington.*

After some months where every tuit was sacred, and so got spent on implementing Raku rather than writing about implementing Raku, I’m happy to report that for the rest of 2015 I’ll now have time to do both again. \o/ I recently decided to take a step back from my teaching/mentoring work at [Edument](http://www.edument.se/) and dedicate a good bit more time to Raku. The new [Raku core development fund](http://www.perlfoundation.org/perl_6_core_development_fund) is a big part of what has enabled this, and a huge thanks must go to WenZPerl for providing the initial round of funding to make this happen. I wrote up a [grant application](http://news.perlfoundation.org/2015/04/grant-proposal-perl-6-release.html), which contains some details on what I plan to be doing. In short: all being well with funding, I’ll be spending 50% of my working time for the rest of 2015 doing Raku things, to help us towards our 2015 release goals.

As part of the grant, I’ll be writing roughly weekly progress reports here. While the grant application is open for comments still, to make sure the community are fine with it (so far, the answer seems to be “yes!”), I’ve already been digging into the work. And when I looked at the list of things I’ve already got done, it felt like time already to write it up. So, here goes!

### Uni and NF-whatever

One of the key goals of the grant is to get Normal Form Grapheme support in place. What does that mean? When I consider Unicode stuff, I find it helps greatly to to be clear about 3 different levels we might be working at, or moving between:

- **Bytes: **the way things look on disk, on the wire, and in memory. We represent things at this level using some kind of encoding: UTF-8, UTF-16, and so forth. ASCII and Latin-1 are also down at this level. In Raku, we represent this level with the `Buf` and `Blob` types.
- **Code points:** things that Unicode gives a number to. That includes [letters](http://www.fileformat.info/info/unicode/char/006f/index.htm), [diacritics](http://www.fileformat.info/info/unicode/char/0307/index.htm), [mathematical symbols](http://www.fileformat.info/info/unicode/char/2282/index.htm), and even a [cat face with tears of joy](http://www.fileformat.info/info/unicode/char/1f639/index.htm). In Raku, we represent a bunch of code points with the `Uni` type.
- **Graphemes: **things that humans would usually call “a character”. Note that this is not the same as code points; there are code points for diacritics, but a typical human would tell you that it’s something that goes on a character, rather than being a character itself. These things that “go on a character” are known in Unicode as combining characters (though a handful of them, when rendered, visually enclose another character). In Raku, we represent a bunch of graphemes with the `Str` type – or at least, we will when I’m done with NFG!

Thus, in Raku we let you pick your level. But `Str` – the type of things you’d normally refer to as strings – should work in terms of graphemes. When you specify an offset for computing a substring, then you should never be at risk of your “cut the crap” grapheme (which is, of course, made from two codepoints: [pile of poo](http://www.fileformat.info/info/unicode/char/1F4A9/index.htm) with a [combining enclosing circle backslash](http://www.fileformat.info/info/unicode/char/20e0/index.htm)) getting cut into two pieces. Working at the codes level, that could easily happen. Working at the bytes level (as C# and Java strings do, for example), you can even cut a code point in half, dammit. We’ve been better that *that* in Raku pretty much forever, at least. Now it’s time to make the final push and get Str up to the grapheme level.

Those who have played with Raku for a while will have probably noticed we do have `Str` (albeit at the code point level) and `Buf` (correctly at the bytes level), but will not have seen `Uni`. That’s because it’s been missing so far. However, today I landed some bits of Uni support in Rakudo. So far this only works on the MoarVM backend. What can we do with a Uni? Well, we can create it with some code points, and then list them:

```` raku
my $codepoints = Uni.new(0x1E0A, 0x0323);
say $codepoints.list.map(*.base(16)); # 1E0A 323
````

That’s a [Latin capital letter D with dot above](http://www.fileformat.info/info/unicode/char/1E0A/index.htm), followed by a [combining dot below](http://www.fileformat.info/info/unicode/char/0323/index.htm). Thing is, Uniocde also contains a [Latin capital letter D with dot below](http://www.fileformat.info/info/unicode/char/1e0c/index.htm), and a [combining dot above](http://www.fileformat.info/info/unicode/char/0307/index.htm). By this point, you’re probably thinking, “oh great, how do we even compare strings!” The answer is normalization: transforming equivalent sequences of code points into a canonical representation. One of these is known as Normal Form Decomposed (aka. NFD), which takes all of the pre-composed characters apart, and then performs a stable sort (to handwave a little, it only re-orders things that don’t render at the same location relative to the base character; look up Canonical Combining Class and the Unicode Canonical Sorting Algorithm if you want the gory details). We can compute this using the Uni type:

```` raku
say $codepoints.NFD.list.map(*.base(16)); # 44 323 307
````

We can understand this a little better by doing:

```` raku
say uniname($_) for $codepoints.NFD.list;
````

Which tells us:

```` raku
LATIN CAPITAL LETTER D
COMBINING DOT BELOW
COMBINING DOT ABOVE
````

The other form you’ll usually encounter is Normal Form Composed (aka. NFC). This is (logically, at least) computed by first computing NFD, and then putting things back together into composed forms. There are a number of reasons this is not a no-op, but the really important one is that computing NFD involved a sorting operation. We can see that NFC has clearly done some kind of transform just by trying it:

```` raku
my $codepoints = Uni.new(0x1E0A, 0x0323);
say $codepoints.list.map(*.base(16)); # 1E0C 307
````

We can again dump out the code point names:

```` raku
LATIN CAPITAL LETTER D WITH DOT BELOW
COMBINING DOT ABOVE
````

And see that the normal form is a [Latin capital letter D with dot below ](http://www.fileformat.info/info/unicode/char/1e0c/index.htm)followed by a [combining dot above](http://www.fileformat.info/info/unicode/char/0307/index.htm).

There are a number of further details – not least that Hangul (the beautiful Korean writing system) needs special algorithmic handling. But that’s the essence of it. The reason I started out working on Uni is because NFG is basically going a step further than NFC. I’ll talk more about that in a future post, but essentially NFG needs NFC, and NFC needs NFD. NFD and NFC are well defined by the Unicode consortium. And there’s more: they provide an epic test suite! 18,500 test cases for each NFD, NFKD, NFC, and NFKC (K is for “comparability”, and performs some extra mappings upon decomposition).

Implementing the Uni type gave me a good way to turn the Unicode conformance tests into a bunch of Raku tests – which is [what I’ve done](https://github.com/raku/roast/tree/master/S15-normalization). Of course, we don’t really want to run all 70,000 or so of them every single spectest, so I’ve marked the full set up as stress tests (which we run as part of a release) and also generated 500 sanity tests per normalization form, which are now passing and included in a normal spectest run. These tests drove the implementation of the four normalization forms in MoarVM ([header](https://github.com/MoarVM/MoarVM/blob/master/src/strings/normalize.h), [implementation](https://github.com/MoarVM/MoarVM/blob/master/src/strings/normalize.c)). The inline static function in the header avoids doing the costly Unicode property lookups for a lot of the common cases.

So far the normalization stuff is only used for the `Uni` type. Next up will be producing a test suite for mapping between `Uni` and (NFG) `Str`, then `Str` to `Uni` and `Buf`, and only once that is looking good will I start getting the bytes to `Str` direct path producing NFG strings also.

### Unicode 7.0 in MoarVM

While I was doing all of the above, I took the opportunity to upgrade the MoarVM Unicode database to use the Unicode 7.0 database.

### Unsigned type support in NativeCall

Another goal of my work is to try and fix things blocking others. Work on Raku database access was in need of support for unsigned native integer types in NativeCall, so I jumped in and implemented that, and added tests. The new functionality was put to use within 24 hours!

### RTs

Along with the big tasks like NFG, I’m also spending time taking care of a bunch of the little things. This means going through the RT queue and picking out things to fix, to make the overall experience of using Raku more pleasant. Here are the ones I’ve dealt with in the last week or so:

- Fix, add test for, and resolve RT #75850 (a capture \( (:a(2)) ) with a colonpair in parens should produce a positional argument but used to wrongly produce a named one)
- Analyze, fix, write test for, and resolve RT #78112 (illegal placeholder use in attribute initializer)
- Fix RT #93988 (“5.” error reporting bug), adding a typed exception to allow testability
- Fixed RT #81502; missing undeclared routine detection for BEGIN blocks and include location info about BEGIN-time errors
- Fixed RT #123967; provided good error reporting when an expression in a constant throws an exception
- Tests for RT #123053 (Failure – lazy exceptions – can escape try), but no fix yet. Did find a few ways to fix it that didn’t work, but led to two other small improvements along the way.
- Typed exception for bad type for variable/parameter declaration; test for and resolve RT #123397
- Fix and test for RT #123627 (bad error reporting of “use Foo Undeclared;”)
- Fix and test for RT #123789 (SEGV when assigning type object to native variable), plus harden against similar bugs
- Implemented `where` post-constraints on attributes/variables. Resolves RT #122109; unfudged existing test case.
- Handle `my (Int $x, Num $y)` (RT #102414) and complain on `my Int (Str $x)` (RT #73102)
