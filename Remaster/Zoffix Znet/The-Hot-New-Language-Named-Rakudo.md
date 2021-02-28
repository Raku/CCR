# The Hot New Language Named Rakudo
    
*Originally published on [7 July 2017](https://perl6.party//post/The-Hot-New-Language-Named-Rakudo) by Zoffix Znet.*

*This article represents my own thoughts on the matter alone and is not an official statement on behalf of the Rakudo team or, perhaps, is not even representative of the majority opinion.*

---

When I came to Perl 6 around its first stable Christmas 2015 release, "The Name Issue" was in hot debate. Put simply: Perl 6 is not a replacement to Perl; Perl 6 is not the "next" Perl; Perl 6 is a very different language to Perl; so why does it still have 'Perl' in its name?

From what I understand, the debate raged on for years prior to my arrival, so the topic always felt taboo to talk about, because it always ended up in a heated discussion, without a solution at end.  However, we *do* need that solution.

The major argument I heard (and often peddled myself) for why Perl 6 had 'Perl' in the name was because of brand recognition. The hypothesis was that fewer people would bother to use an unknown language "Foo" than a recognizable language "Perl". Now, two years later, we can examine whether that hypothesis was true and beneficial and act accordingly.

## Fo6.d for Thought

The Perl 6 language—to which I shall refer to as Rakudo language, for the rest of the article—is versioned separately from its implementations and is defined by [the specification](https://github.com/raku/roast). The current version is 6.c "Christmas" and the upcoming version is 6.d "Diwali"

As some know, despite slinging a lot of code in my spare time, I earn my bread under the banner of *Multi-Media Designer*. While one of the "media" I work with is Web and so I do get to write some code once in a while, my office for the past 8-ish years has been located squarely in the *Marketing* Department, not "Information Technology" (I.T.).

As the Rakudo core team was recently penning down the dates for 6.d release, I got excited to have the opportunity to do some design and marketing for something quite different than products at my job. However, I very quickly hit a roadblock. The name "Perl 6" isn't quite marketable.

Ignoring trolls and people whose knowledge of Perl ends with the line-noise quips, Perl is the Grandfather of Web, the Queen of Backwards Compatibility, and Gluest language of all the Glues. Perl is installed by default on many systems, and if you're worthy enough to wield its arcane magic, it's quite damn performant.

Rakudo language, on the other hand, is *none* of those things. It's a young and hip teenager who doesn't mind breaking long held status quo. Rakudo is the King of Unicode and Queen of Concurrency. It's a "4th generation" language, and if you take the time to learn its many features, it's quite damn concise.

Trying to market Rakudo language as a "Perl 6" language is like holding a great [Poker](https://en.wikipedia.org/wiki/Poker) hand while playing [Blackjack](https://en.wikipedia.org/wiki/Blackjack)—even with a *Royal Flush*, you still lost the game that's actually being played. The truly distinguishing features of Rakudo don't get any attention, while at the same time people get disappointed when a "Perl" language [no longer does](https://irclog.perlgeek.de/raku/2017-06-29#i_14804470) things Perl used to do.

So did the hypothesis about Perl brand name recognition hold true? Yes, but Rakudo language has very different strengths than those that brand represents.  Which leads to a lot of [confusion](https://www.reddit.com/r/programming/comments/6jzpyd/perl_6_seqs_drugs_and_rocknroll_part_2/dji747p/), [disappointment](https://www.reddit.com/r/raku/comments/6hagwm/performance_concern_with_respect_to_gnu_yes/), and [annoyance](https://irclog.perlgeek.de/mojo/2017-06-04#i_14684821).

As the 6.d language release nears, and with it the ability to make large changes, I think it would benefit us to reflect on the issues of the past two years and improve.

## "Just Rename It"

Even if the entire Rakudo community would decide a different name is good, there's a teenie-tiny problem of existing infrastructure. Need documentation?  You go to [raku.org](https://raku.org), not [rakudo.org](http://rakudo.org).  Need a live, squishy human to help you out? You go to [#raku](https://webchat.freenode.net/?channels=#raku) IRC channel, not [#rakudo](https://webchat.freenode.net/?channels=#rakudo).  Need a Rakudo book? Why, then go to [rakubook.com](https://rakubook.com/) and pick any of the books with "Perl 6" in their titles.

This is one of the major things that derailed my thinking on the subject in the past: people saying "just rename it," when clearly it's no easy task.  Domain names, email addresses, bug trackers, Reddit subreddits, Facebook groups, Twitter feeds, GitHub orgs, IRC channels, presentations, books, blog posts, videos, hell, even names of some variables (`$*PERL`) and env vars (`PERL6TEST_DIE_ON_FAIL`) would all need to change for a thorough rename job.

Not only would all those things need a rename, the old versions in many cases would need to be able to redirect to the new name. "Just renaming" [raku.party](https://raku.party) website and its contents will take me some effort and already incurred a minor expense for a new domain name. The effort required to do the same everywhere would be monumental and in the end we'd still go to The *Perl* Conference and get sponsored by grants from The *Perl* Foundation.

I think the ship for "just renaming" it has sailed a few years before first stable language release. However, we don't have to be at the mercy of all-or-nothing tactics, when there are clear benefits to reap from a name tweak.

## Rakudo Perl 6

Rakudo is the name of a mature—and to date, the only one that's usable—implementation of the language. If [Wikipedia](https://en.wikipedia.org/wiki/Rakudo_Perl_6) is to be believed, the name means "The Way of The Camel" or "Paradise."

It's also the name that's ripe for the picking to be the name of the language: those who use the language already have heard the name, so it's familiar; the compiler's repo is [`rakudo/rakudo`](https://github.com/rakudo/rakudo), not `raku/rakudo`; newcomers are told to install "Rakudo Star," not "Perl 6 Star"; and having an already [bikesheded](http://bikeshed.org/) name can cut down on irrelevant discussions when the need for change itself is controversial.

While it's true that re-using the compiler's name for the language creates an ambiguity, it can be resolved by using all-lowercase letters for the compiler and title case for the language—Perl has been doing that for years. In addition, if the executable were to be renamed from `raku` to `rakudo`, there'd be fewer accidents of running Rakudo scripts with `perl` command, which is currently is actually actively fought against by the recommendation to put `use v6` in all of the programs.

The "Rakudo Perl 6" name for the language was suggested by *lizmat*++, so I assume there's at least one other core team member who's open to the language name tweak. And I do precicely mean *tweak*, not *change.* While change would be more preferable, it stands opposed by existing infrastructure naming and, of course, those who believe Perl 6 is a fine name and should be kept unchanged. So by tweaking the language name to be "Rakudo Perl 6," we get the benefit of marketing a new release of a hot new language "Rakudo 6.d" instead of a new release of same-name-but-totally-not-Perl-5 "Perl 6.d". We get to keep using "raku" ticket queue on RT, without raising too many confused eyebrows; we get to publish Rakudo blog posts that don't get knee-jerk reactions form non-Perl users; we get to attend The *Perl* Conference without feeling we don't belong; we get to mention how awesome Rakudo is to our peers without fearing yet-another pointless "Perl is dead" discussion; we save the trees by not reprinting all of the existing "Perl 6" books; yet we get to... start anew.

## It's The Beginning, Not The End

Humans are funny creatures. We don't like to change our minds, lest we appear to not have a clue. We cling to past decisions and things said because abandoning them is admitting you were wrong. However, looking at the past two years, it's very clear to me the name of "Perl 6" has been detrimental to the language. I'm not afraid to admit I was wrong in defending the "Perl 6" name.

It's an indicator that something's wrong, when you spent days writing an amazing technical post but have anxiety posting it to [r/programming](https://www.reddit.com/r/programming/) because it'll inevitably end up with quips and jokes about Perl being late to the party. It's an indicator that something's wrong, when you're apprehensive joining a tech discussion to mention how easy the task is to do in "Perl 6," because even well-meaning people have a hard time realizing Perl 6 is an entirely new language.

I'm under no delusion that merely changing the name would instantly make everyone love the language. There are still performance problems to tackle.  More bugs to fix. More documentation and tests to write. All these things need humans to work on them and humans care about *perception.* The assumption that many humans will start using Rakudo just because it's a better product simply does not match reality.

It would be beneficial to change the perception of the Rakudo language.  Ignoring the problem won't do that. Including boiler plate text about Perl 6 being new language that's totally different from Perl at the start of every conversation won't do it.  Tweaking the language name to be unique will. It doesn't have to be a dramatic event, but...

## I can't do it alone

Last night I registered [rakudo.party](https://rakudo.party) and changed [my Twitter](https://twitter.com/zoffix) bio to no longer refer to the language as "Perl." In the coming days, I'll update all mentions of "Perl 6" on [rakudo.party](https://rakudo.party) to read "Rakudo" or "Rakudo language" where it's ambiguous with the rakudo compiler. My IRC hostmask and module descriptions on GitHub will follow suit.  My conversations, Twitter hashtags, Facebook posts... all will refer to Rakudo instead of Perl 6, just as I've been doing in this post.

However, that is about the end of my unilateral control of the whole thing.  I can't change [docs.raku.org](https://docs.raku.org) or the next blog post *you'll* write, which is why I strongly encourage those who care about *The Name Issue* and especially those who care about success of the Rakudo language to do the same active language name tweak I'm doing.

Acknowledge that language's full name is "Rakudo Perl 6". Yes, there's a compiler with a similar name, but it's the next best thing after nothing.  Shorten the full name of the language to just "Rakudo," to differentiate it from THE Perl; you don't even have to [worry about spacing issues](https://github.com/raku/doc/commit/ffca24bd1248cfcab98a91e0ffbbc1fe96dfe18f) if you do! Tell people about Rakudo's unique features, not about how it's trying to catch up to the things Perl 5 does well.

Rakudo has many strengths but they get muted when we call it "Perl 6". Perl is a brand name for a product with different strengths and attempting to pretend Rakudo has the same strengths for the past 2 years proved to be a failed strategy. I believe a name tweak can help these issues and start us on a path with a more solid footing. A path that invites newcomers, not scares them with knee-jerk reactions and fear of using an outmoded product.

I may be wrong about it. I may be the only fucking idiot on the planet with a "#Rakudo" hashtag in their Twitter bio. But... I think I'm right about it, and I hope you'll join me and use the tweaked language name.

-Ofun
