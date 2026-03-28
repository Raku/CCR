# Week 3 of GSoC work on Buf — talk like a Parrot day
    
*Originally published on [14 June 2010](http://strangelyconsistent.org/blog/week-3-of-gsoc-work-on-buf-talk-like-a-parrot-day) by Carl Mäsak.*

Remember that long-term solution for conversions between strings and arrays of bytes that I mentioned [last week](Week-2-of-gsoc-work-on-buf-the-power-of-swedish-beer.html) that the Parrot people were discussing?

No? Well, anyway, *NotFound*++ wrote one, and he suggested I try it for my Str⇄Buf conversions. It worked!

I thought I would get more than that done this week, but I didn't. Oh well. For next week, there are still a few low-hanging branches of fruit to persue.

- I want to add `postfix:<[ ]>` indexing to the Buf class, so it feels a bit more Positional.
- There's a lot of bounds-checking that needs to be made, both in the constructor and in decoding.
- I have UTF-8 down pat; need to find a way to convince Parrot to do other encodings, such as ISO-8859-1.
- There's one test that talks about [NFD](https://metacpan.org/release/SADAHIRO/Unicode-Normalize-1.06-withoutworldwriteables/view/Normalize.pm). Haven't even started looking at that yet.


It's interesting to see where all the effort goes. I've spent most of my time so far on the `Str.encode` and `Buf.decode` methods, and almost everything else is trivial in comparison. Feels like some sort of 90%-10% rule at work.
