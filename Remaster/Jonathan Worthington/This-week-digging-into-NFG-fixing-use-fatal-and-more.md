# This week: digging into NFG, fixing “use fatal”, and more
    
*Originally published on [2015-04-20](https://6guts.wordpress.com/2015/04/20/this-week-digging-into-nfg-fixing-use-fatal-and-more/) by Jonathan Worthington.*

It’s time for this week’s grant report! What have I been up to?

### NFG

[Last time](https://6guts.wordpress.com/2015/04/12/this-week-unicode-normalization-many-rts/), I talked about normalization forms in Unicode, and how Rakudo on MoarVM now lets you move between them and examine them, using the **Uni** type and its subclasses. We considered an example involving 3 codepoints:

```` raku
my $codepoints = Uni.new(0x0044, 0x0323, 0x0307);
.say for $codepoints.list>>.uniname;
````

They are (as printed by the code above):

````
LATIN CAPITAL LETTER D
COMBINING DOT BELOW
COMBINING DOT ABOVE
````

We also noted that if we put them into NFC (Normal Form Composed – where we take codepoints sequences and identify where we can use precomposed codepoints), using this code:

```` raku
my $codepoints = Uni.new(0x0044, 0x0323, 0x0307);
.say for $codepoints.NFC.list>>.uniname;
````

Then we get this:

````
LATIN CAPITAL LETTER D WITH DOT BELOW
COMBINING DOT ABOVE
````

Now, if you actually render that, and presuming you have a co-operating browser, it comes out as Ḍ̇ (you should hopefully be seeing a D with a dot above and below). If I was to stop people on the street and ask them how many characters they see then I show them a “Ḍ̇”, they’re almost certainly all going to say “1”. Yet if we work at codepoint level, even having applied NFC, we’re going to consider those as 2 “thingies”. Worse, we could do a **substr** operation and chop off the combining dot above. This is actually the situation in most programming languages.

Enter NFG. While it’s not on for all strings by default yet, if you take any kind of `Uni` and coerce it to a `Str`, you have a string represented in Normal Form Grapheme. The first thing to note is that if we ask `.chars` of it, we get 1:

```` raku
my $codepoints = Uni.new(0x0044, 0x0323, 0x0307);
say $codepoints.Str.chars; # 1
````

How did it do this? To get Normal Form Grapheme, we first calculate NFC. Then, if we are left with combining characters (formally, anything with a non-zero value for Canonical_Combining_Class), we compute a synthetic codepoint and use it inside of the string. You’ll never actually see these. When we output the string, or turn it back into codepoints, the synthetics unravel. But when you’re working with a `Str`, you’re at grapheme level. Better still, operations like `.chars` and `.substr` are O(1).

Under the hood, synthetics are represented by negative integers. This gives a cheap and easy way to know if we’re looking at a synthetic codepoint or not. And because we intern the synthetics, things like string equality testing can be a cheap and fast memory compare operation. On a further implementation note, I went with a [partially lock-free trie](https://github.com/MoarVM/MoarVM/commit/fae0069445bbe69fd9caa454ebccb7ec64c8caa5) to do the interning, meaning that no locks are needed to do lookups, and we only acquire one if we have to register a new synthetic- giving thread safety with very little overhead for real-world use cases.

I’m gradually assembling [test cases for NFG](https://github.com/raku/roast/tree/master/S15-nfg). Some can be generated systematically from the Unicode NormalizationTests.txt file, though they are rather more involved since they have to be derived from the normalization test data by considering the canonical combining class. Others are being written by hand.

For now, the only way to get an NFG string is to call `.Str` on a `Uni`. After the 2015.04 release, I’ll move towards enabling it for all strings, along with dealing with some of the places where we still need to work on supporting NFG properly (such as in the `leg` operator, string bitwise operators, and LTM handling in the regex/grammar engine).

### use fatal

For a while, *Larry* has noted that a `$*FATAL` dynamic variable was the wrong way to handle `use fatal` – the pragma that makes [lazy exceptions](http://doc.raku.org/type/Failure) (produced by `fail`) act like `die`.  The `use fatal` pragma was specified to automatically apply inside of a `try` block or expression, but until this week a `Failure` could escape a `try`, with the sad consequence that things like:

```` raku
say try +'omg-not-anumber';
````

Would blow up with an exception saying you can’t sanely numify that. When I tried to make the existing implementation of `use fatal` apply inside of `try` blocks, it caused sufficient fireworks and action at a distance that it became very clear that not only was *Larry*’s call right, but we had to fix how `use fatal` works before we could enable it in `try` blocks. After some poking, I managed to get an answer that pointed me in the direction of doing it as an [AST re-write](https://github.com/rakudo/rakudo/blob/c4beed679ccbf82be733657ea653ab52df258f7b/src/Perl6/Actions.nqp#L1009) in the lexical scope that did **use fatal**. That worked out far better. I [applied it to try](https://github.com/rakudo/rakudo/blob/c4beed679ccbf82be733657ea653ab52df258f7b/src/Perl6/Grammar.nqp#L1850), and found myself with only one spectest file that needed attention (which had code explicitly relying on the old behavior). The fallout in the ecosystem seems to have been minimal, so we’re looking good on this. A couple of RTs were resolved thanks to this work, and it’s another bit of semantics cleaned up ahead of this year’s release.

### Smaller things

Finally, here are a handful of smaller things I’ve worked on:

- Fix and test for RT #77786 (poor error reporting on solitary backtrack control)
- Make `soft` and `MONKEY-TYPING` work lexically
- Fix and test for RT #124304 (interaction of `my \a = …` declarations with `EVAL`)
- Fix for RT #122914 (binding in REPL didn’t persist to the next line); also add tests and make REPL tests work on Win32

Have a good week!
