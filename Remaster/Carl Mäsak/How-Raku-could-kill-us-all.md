# How Raku could kill us all!
    
*Originally published on [18 November 2009](http://strangelyconsistent.org/blog/how-perl-6-could-kill-us-all) by Carl Mäsak.*

People's minds weave stories. Stories weave people's minds.

My mind is pretty tied to the Raku story nowadays, and I haven't minded thePerl story much. Until this week, that is. Last Sunday, I backlogged over a discussion of someone coming in from #perl asking people on #raku why Raku claimed to be Perl [when it clearly isn't](http://strangelyconsistent.org/blog/the-perl-6-is-not-perl-meme). My resulting blog post basically asked the #perl people to stop telling outsiders biased things.

A few days later, *mst*++ [grabbed me on IRC](November-12-2009-some-serious-history-awareness.html) and informed me in what ways the blog post I'd written was biased by *my* views. In particular, these two statements from my post are less-than-objective:

- Surely no-one in the Perl community wants to confuse newcomers. Yet
that is clearly what happened here.
- Whatever replies emma got, she did not get the balanced views that the
#raku folks gave.

As mst pointed out, the post comes from the assumption that *my* views are balanced. It does — I bet there's a psychology term for that kind of phenomenon, where people [unconsciously assume that their own assumptions are correct](https://en.wikipedia.org/wiki/Bias_blind_spot).

A more useful view to take is perhaps that there's a Perl story and a Raku story. Had emma got the Raku story from #raku before she got the Perl story from #perl, she probably wouldn't have become annoyed at the people on #raku the way she did. But that doesn't mean that the #perl people were spreading untruths or badmouthing Raku. It could be as simple as emma asking "Is Raku different from Perl?", and getting a "yes". (Well, it is different.) According to mst, that's pretty much what happened.

Then I learned a bunch of interesting things about the Perl story, things which I would probably have figured out by myself sooner, had I not been so influenced by the Raku story already. Here I make a partly vain attempt to summarize the Perl take on Raku:

- There's Perl, and it's pretty awesome. It's fast, well-tested, and has the CPAN, which rocks. People who weave the Perl story are generally not sitting around waiting for Raku, nor are they particularly interested in making it arrive sooner.
- From the outside, and generalizing, Raku looks like a big failure. It hasn't "arrived" yet, and in the process it has generated massive amounts of bad PR for itself and for Perl in general. Parts of the bad PR come from not arriving yet, parts of it come from the version thing.
- The version thing, in essence, is this: 6 is larger than 5. *Everyone* knows what this means; releases with bigger version numbers (especially major ones) are better than, and are meant to replace, releases with smaller version numbers. Perl replaced Perl 4, which replaced Perl 3, etc. Raku lambdacamels don't think much about this, but Perl folks fielding questions from outsiders about Raku sure do.
- To make matters worse, those Raku people are actually *encouraging* the delusion that Raku is replacing Perl. They have early alpha releases out, and they're making statements about Raku being the "next version of Perl", as if they were standing there with the finished product already.
- When people try what the Raku people have, the find it slow, buggy, and in almost total lack of libraries. If these people are outsiders, they might well associate those bad things with "Perl", and never get to trying out Perl, the "real" Perl.

After putting the pieces together, I understand a little better where the, um, strong dislike may be coming from.

But it's worse than that. This is a conflict that, assuming us Raku people are really onto something, will only get worse. Raku was conceived at a time when Perl was at a slump, but Perl is not at a slump anymore. It's alive and kicking, and stronger than ever. Large parts of its community do *not* consider Raku the hot next version. They consider Raku a threat, more or less. If and when Raku takes off, it will be a bigger threat. A threat made worse by the Raku story, as it was once woven: that Raku is the obvious successor to Perl.

I think it's time to try and mitigate the conflict now. I understand the best we can do from the perspective of the Perl story is to change the name "Raku" to something else. I don't see that happening, and [neither does Larry](https://irclogs.raku.org/perl6/2009-11-13.html#15:55-0002). But what we *can* change, and right away, is the dissipation of the idea that Raku is the next major version of Perl. We should be focusing on consistently telling another story; something like this:

Perl and Raku are two languages **in the Perl family, but of different lineages.**

It won't entirely remove the damage that the "6 > 5" phenomenon causes the Perl crowd, but it will at least mitigate it. Also it shows some serious good will from the Raku side.

What we do *not* want is a conflict, where the Perl community feels the need to assert itself against the impostor Raku, which threatens it simply by being Raku. "Rewrite" does not mean "overwrite". Perl isn't going away anytime soon. This is actually something we say on the channel a lot, but it hasn't been evident in our PR.

The Raku community is taking steps to rectify that. Where the [raku.org](http://raku.org/) page used to say "Raku, the next major version of the Perl programming language", it now says "Raku, the spunky little sister of Perl. Like her world-famous big sister, Raku intends to carry forward the high ideals of the Perl community." With this re-wording, things are suddenly much more on equal grounds.

While I'm posting this, [*mst*++ has made a blog post](https://archive.shadowcat.co.uk/blog/matt-s-trout/f_ck-perl-6/) in his inimitable style over at his blog, where he defends the Raku story to his peers. I've read it, and while it does contain the usual amount of four-letter words, it also makes points very similar to this post's, but in a sort of mirror-like Perl universe. Understanding needs to flow in from both sides in this matter. [You should read it, too.](https://www.shadowcat.co.uk/blog/matt-s-trout/f_ck-perl-6/)

In an ideal world, we will have Perl and a mature Raku existing side by side, not feeling threatened by each other, and competing on cool tech. The Perl and Raku communities could recognize each other's Perl version as Perl, go to the same conferences (as we do already), and feel confident about the other group's assertions of superiority, because they're so clearly misguided, while still perfectly fine individuals, of course.

Let's try to steer in that direction, and not towards mutual assured destruction. That's just mad.
