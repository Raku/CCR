# Str and Buf — I think I get it now
    
*Originally published on [6 July 2009](http://strangelyconsistent.org/blog/str-and-buf-i-think-i-get-it-now) by Carl Mäsak.*

So `Str` and `Buf` aren't merely there in Raku to separate out the two related concepts "sequence of characters" and "sequence of bytes", respectively. They're there to institute a [whorfian discipline](https://en.wikipedia.org/wiki/Linguistic_relativity) where **it won't even be possible to think the wrong thoughts,** about strings and sequences of bytes.

This is the natural consequence of working Joel Spolsky's ["There Ain't No Such Thing As Plain Text"](https://www.joelonsoftware.com/articles/Unicode.html) into the language design. By all means, treat real strings as `Str`, but make sure byte sequences can't cross that moat without being decoded somehow. Perl totally blurs the distinction, as [*moritz*++ explains](https://perlgeek.de/en/article/encodings-and-unicode). It is not alone among programming languages in that respect. In fact, I'd be interested to hear about some language that makes the same `Str`/`Buf` distinction as Raku.

It took me a while to reach this point, but now it seems perfectly obvious. I remember, only a few weeks ago, being shook by *TimToady*'s claim that `Str`s do not know their byte sequence in the general case. But I see it now. **A Raku string is not a sequence of bytes.** It's a sequence of characters, at least by default. Likewise, a `Buf` is not a sequence of characters, not even metaphorically. It's a sequence of integer values. And the difference isn't some picky play with words, but the encoding/decoding step itself.

This is the act of building knowledge into the class hierarchy of the language itself, so that people's thoughts will be channeled in the right direction. "Arrgh, why can't I get the number of bytes on this `Str` object? Oh look, the manual says I have to convert to `Buf` to do that. Oh look, I have to supply an `$encoding` parameter to do that. I don't see why, but fair enough — if that's the price for using all the other cool stuff in Raku."

The battle of encoding-aware programs is won, not necessarily through making the programmers aware of encodings, but through making the language provide primitives that Do The Right Thing.
