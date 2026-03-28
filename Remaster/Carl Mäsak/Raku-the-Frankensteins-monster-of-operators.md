# Raku: the Frankenstein's monster of operators
    
*Originally published on [2 May 2010](http://strangelyconsistent.org/blog/perl-6-the-frankensteins-monster-of-operators) by Carl Mäsak.*

By this point, a stray comment on an [earlier blog post](GSoC-contextuals-and-intolerance-three-posts-in-one.html) of mine has snowballed into a real discussion, so let's hoist it up here for everyone to see. It's a friendly discussion full of smilies, between two people with different viewpoints. Get the popcorn; I'll provide the quotes.

The commentator, nilsonsfj, is a Perl programmer who 'just didn't bother following up on Raku anymore after the Unicode ops and the whole "periodic table of operators" thing.' I guess that description applies to quite a few Perl programmers out there; Raku just isn't relevant to them in its present state.

I reply:

> You should take a look at the [new table](https://www.ozonehouse.com/mark/periodic/) from last year, if you haven't yet. It's gorgeous. Also — and I bet you know this — neither Perl or Raku is meant to be taken in all at once, and the periodic table sort of goes against that and says "Boo! Operators!" and scares everyone giddy with all the horrible richness. Perl isn't a first language, it's more of a last language. ☺

Also, after you've recovered from the Unicode thing, you'll be pleased to know that all of the ops in that table are all quite ASCII-friendly. Wreaking havoc with Unicode operators is left as an exercise for module authors. ☺</div>

nilsonsfj goes ahead and looks, and comes back replying:

> Well, I just looked at the new periodic table and if by "gorgeous" you meant "scary", I agree with you. ☺

(Boo! Operators!)

I reply with:

> In the interests of mutual understanding, I tried to look at the periodic table, and tried to instill a measure of fear in myself. The closest I got was "huh, that's quite a lot of them, isn't it?".

I think one of the big dividing points between the Perl languages on the one hand and other programming languages on the other, is that Perl embraces complexity — often quite fearlessly. Language designers are known to talk about minimalism and orthogonality. Perl, in contrast, seems to take as a starting point that the world, including the programming world, is complex and messy and non-orthogonal and full of redundancy and can be seen in different ways by different people.

Perl has quite a lot of operators. I haven't counted them, and wouldn't really know where to start if I were to try. I'm sure Raku has more, maybe even twice as many. (Again, by some half-defined measure.) I think I don't think "scary" when I look at the table because most of these operators are familiar to me now, and I see the rationale for them. (Yes, duh.) Also, many of them I don't normally consider operators, either because they're too infrastructural (like the comma or the different dotty method calls) or too abstract (like 'does' or most of the alphabetic list operators) to be real operators.

With the rest of them, they're either new (which one would expect from a new language or even an upgrade), or they're instances of one Perl operator that has exploded into a couple of Raku operators because Raku often takes a more strict view to keeping different things distinct and relies less on value context than does Perl. The shift/and/or/negate operators prefixed by plus or tilde or question mark are an example of this; I briefly give the rationale for why I like this change in blog post from a while back. I should add that I don't use those particular operators on a day-to-day basis, because of their quite specific and close-to-the-metal nature. (That's also a dimension not visible in the Table; some operators are uncommon in practice.)

Much of the complexity is actually hidden and folded in by the presence of the metaoperators. Of course, the mere concept of a metaoperator and the sudden ability to create a fitting operator on the spot (along with the parser technology required to make that work) are, by rights, scary in an objective sense. But it's one of the things that grows on you. And I haven't seen people abuse it either; just because there are metaoperators available, people don't suddenly go crazy and produce unmaintainable code. Rather, it helps turn a for loop here and there into a one-liner.

I came in at around 2004, and I've seen many of these operators mature and take shape. So I guess I'm biased by having seen the rationale for most changes, from Perl through the Apocalypses and Synopses up until today. I agree with most of them. I still don't quite understand how we ended up with eight flip-flop operators, but I haven't really used them yet, so I'll reserve judgment on that point. Maybe they'll be handy in a raku -ne context or something.</div>

Raku is an 'operator-oriented' language. In fact, operators are described in the spec as being subroutines and methods with funny syntax. (I'm paraphrasing here.) In that sense, the whole discussion dissolves into a larger discussion on which subroutines and methods we want to keep in the Raku core, and which one of those should manifest as operators.

Perl and Raku tend to favor a good operator in many cases where other languages would reach for a subroutine or method. That's fine. If you don't like it that way, we won't tell you to take your umbrella and go somewhere else, we'll tell you to show us how *you* would have it look, and your solution can even get its own life as a module or a spec change or a community best practice. It's happened many times before, and it'll happen many more times. As a result, we end up with a language covering one enormous sweet spot, looking like Frankenstein's monster and being quite proud of it. Because, as someone once said, [it's the magic that counts](https://dl.acm.org/doi/book/10.5555/572875).
