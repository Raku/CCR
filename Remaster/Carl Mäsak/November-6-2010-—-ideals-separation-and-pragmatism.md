# November 6 2010 — ideals, separation, and pragmatism
    
*Originally published on [6 November 2010](http://strangelyconsistent.org/blog/november-6-2010-ideals-separation-and-pragmatism) by Carl Mäsak.*

> 38 years ago today, the UN passed [a resolution](https://en.wikipedia.org/wiki/United_Nations_General_Assembly_Resolution_1761) to condemn apartheid and to call for a break-off of trade and diplomatic relations in South Africa.

The Wikipedia article about [South Africa apartheid](https://en.wikipedia.org/wiki/South_Africa_under_apartheid) is hard to summarize. I chose this paragraph as an example:

> Under the [Reservation of Separate Amenities Act](https://en.wikipedia.org/wiki/Reservation_of_Separate_Amenities_Act) of 1953, municipal grounds could be reserved for a particular race, creating, among other things, separate beaches, buses, hospitals, schools and universities. Signboards such as "whites only" applied to public areas, even including park benches. Black people were provided with services greatly inferior to those of whites, and, to a lesser extent, to those of Indian and coloured people. An act of 1956 formalised racial discrimination in employment.

The full text of the resolution is available [on Wikisource](https://en.wikisource.org/wiki/UN_General_Assembly_Resolution_1761). Its language is formal and dry, but seeing the italicized action words (first participles, then present-tense verbs) at least gives a sense that somewhere in an unjust world, there's a dedicated group of people proposing ways to attenuate the injustice.

So. With the build time down to about 4 minutes &mdash; 4m16s when I ran it a while ago &mdash; I already felt a lot better than when it was about 8 minutes. But there was still a lingering, nagging suspicion. It shouldn't take that long; not even for Rakudo. Something was taking a whole lot of time.

Yesterday's post was about pleasing the eye with your code. Today's post is about abandoning your high ideals if it turns out they weigh you down.

Here's today's offending piece of code:

```raku
sub html_escape {
    # RAKUDO: Need this unnecessary prefix:<~> to make it work
    return (~$^original).trans:
           ['&',     '<',    '>'   ]
        => ['&amp;', '&lt;', '&gt;']
    ;
}
```

I say "offending", although there is really nothing wrong with the code as such. In fact, it's brilliant as far as fitness-for-purpose is concerned. If you've ever tried to do the above as a series of regex substitutions, or even (*shudder*) as a loop doing `.substr` twiddling, you know what I'm talking about. It's easy to get wrong, especially since the character `&` sits on both sides of the conversion arrow, so it's possible to accidentally replace already-replaced parts of a string. (An excellent argument *against* doing such things in-place.) `.trans` just sweeps these difficulties under the (right sort of) carpet, and gets the job done.

I'm also not referring to the `# RAKUDO:` comment there, although that one is annoying, in much the same way as flies are annoying. (I just realized I hadn't filed a rakudobug for that one, [so I did](https://github.com/Raku/old-issue-tracker/issues/2246).)

No, the problem with this subroutine is, unfortunately, that it's written in Raku. ☹ At least, that's a problem with current Rakudo. At least, that's what I suspected.

To test this hypothesis, I replaced the `html_escape` subroutine with a simple shell-out to `sed`:

```raku
sed 's!&!\&amp;!g;
     s!<!\&lt;!g;
     s!>!\&gt;!g'
```

Note that this is an exact translation of `html_escape`, but now we're using regexes. It's important to do the `&amp;` translation first, for the reason stated above.

Ran it again. 1m22s.

`o.O`

Wh... I mean. Wha...

I went to look at the source code for `Str.trans`. It is [here](https://github.com/rakudo/rakudo/blob/142d22098d51583985476981c9d6f23055d2e510/src/core/Cool-str.pm). Now I understand a little better why it is so slow. I think making it faster would be an interesting small task for someone, and making it *really* efficient would make for an interesting medium-sized task.

I love Raku. I want to see it succeed. But I've gotten used to pacing myself in various ways. This whole new blog is the result of a paring-down of expectations: it's too early to build ambitious servware applications on top of Rakudo, but it's just the right time to start building static web sites. It's easier to achieve your goals if you make the goals realistic in the first place.

Same thing with `html_escape`. One day, I'll be able to write the clear, short Raku version and have it run reasonably fast. But that day is not today. Today I'm shelling out to `sed`, and I'm not too bothered by that. It saves me three minutes with every build run.

Pragmatism trumps purity.
