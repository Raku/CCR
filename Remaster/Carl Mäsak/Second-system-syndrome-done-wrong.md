# Second system syndrome done wrong
    
*Originally published on [29 October 2010](http://strangelyconsistent.org/blog/second-system-syndrome-done-wrong) by Carl Mäsak.*

I'm mostly happy about the Raku specification. Not all of you may
know what it is, so here's a short summary: it consists of several numbered
synopses, each of which describes a certain part of Raku. Some of the
synopses sprang into existence as summaries of correspondingly-numbered
"apocalypses" &mdash; those are the original Raku design documents written by
Larry Wall as a summary of the conclusions of reading through the RFCs. The
apocalypses are way out-of-date nowadays; they're littered with updates that
alert the reader to how syntax and other things are nowadays, but many of these
updates are also out of date. The real specification sits in the synopses;
that's where the language is defined.

That's the specification. Several synopses, each of them about some
topic. Sometimes `STD.pm6` is thrown in as being part of the specification,
too, especially as it still contains ideas that haven't made it into the
synopses yet.

## Whirlpool

As different implementations (mostly Rakudo nowadays) catch up with the
specification and actually implement it, we become increasingly confident
that it actually works as specified. That's code for "we go in and change it
a lot until the specification agrees with the implementation". This is a
beneficial process, and it's part of why I really like Raku: we're not
afraid to adjust our dreams to conform with reality.

This back-and-forth between implementations and specification is of course
what the in-house term "whirlpool development" is all about. It's a sort of
antithetical stance to "waterfall development", this notion that work should
proceed in discrete stages, from analysis via design to implementation and
then testing. The whirlpool model maintains that later stages (like
implementation and testing) affect earlier stages (like analysis and design).
And boy, is that ever true!

In fact, this has sunk so deep into our mental model of the project, that we
don't really trust a synopsis until it's been implemented. The synopses are
the [rough consensus](https://en.wikipedia.org/wiki/Rough_consensus) that we've
all agreed upon so far, but until there's running code too, the synopsis is
assumed to come with a big grain of NaCl.

## Slushy

The terminology that seems to emerge for this is that a synopsis becomes
increasingly **frozen** over time, but before it reaches that point through
actual empirical implementing, it's **slushy** or even **liquid**. Today,
we have a few frozen bits of spec, lots of slushy bits, and a few liquid bits.
Slushy is good; it means that we have some backing from implementations, but
the spec and the implementations don't quite agree yet. I like that part, and
since I'm an early adopter by temperament, I'm fully prepared to work under
such conditions.

Concrete example: Larry made some changes to [multi
semantics](https://github.com/raku/specs/commit/9e98d528793095ae3c6e47837a1bf7dd8aea091a);
Jonathan got visibly worried, but couldn't quite put his finger on
why. Recently he put his worries [into
words](http://6guts.wordpress.com/2010/10/17/wrestling-with-dispatch/), which
unsurprisingly were backed up by implementation concerns. Larry obliged and
[refined the
semantics](https://github.com/raku/specs/commit/60aef3acd56f47b5a78721ca886b9fd3e22b366e)
to address those concerns. The implementations drive the specification.

That last example is also a suitable instance of another metaphor: various
parts of the spec seem to undergo some kind of stochastic hill-climbing in a
hypothetical space. Along the way, it might reach several local maxima, in
which some of the concerns have been addressed, but there is still gnashing
of teeth over others. Usually, when we reach a global maximum, everybody just
knows: this is it. (Well, at least to the extent that hill-climbing guarantees
that the maximum really is global.)

All this is emphasized in the Raku motto "Second System Syndrome Done Right".
Redesigning things on the basis of empirical feedback. And it's pretty good.

## Liquid

There are also a couple of pieces of spec where I think we haven't found the
global maximum yet, or even a local one. That's what I really set out to write
about today. I feel a bit like [MJD](https://blog.plover.com/) now; what you
read so far was only an introduction of sorts.

Let's split things into two parts: **slight unease** and **abstraction
astronautism**. The former are parts where I believe we're on the right track
but not quite there yet. The latter are parts that I believe were too
ambitiously designed from the beginning, and that are probably better thrown
out wholesale. The former requires out-of-the-box thinking; the latter would
need something more like out-of-the-box courage.

## Slight unease

- The angle brackets `<foo bar baz>` provide the new, shorter `qw` syntax in Raku: the example gives you the list `('foo', 'bar', 'baz')`. But people keep using this construct, essentially a string quoting mechanism, expecting to get numbers out when they write a number. Due to this, the spec contains special concessions for any items in the list that look like numbers; each such item will be stored as "an object with both a string and a numeric nature". This unnerves me; I'd be happier if the construct always returned pure strings, that I'd then have to convert manually. I cannot quite put my finger on why I think this is bad and could create problems down the road; I just do.
- A related, but almost the opposite kind of problem: if I create a `MAIN` sub with an `Int` parameter, there's no command-line argument that would match that, since all the arguments coming in from the command line are, by definition, strings. I really like that we use signatures and multi subs to match command-line arguments; that just feels so right. But it feels like a waste to never be able to match an `Int` like that. Whereas I consider the previous situation to have too much magic in it, here I feel there's too little. I'm not at all sure that "an object with both a string and numeric nature" would be a good solution here either; I'd prefer something less icky that still solves the problem.
- I *used* to be slightly uneasy about the way the empty list `()` worked.  Now, after some [spec changes](https://github.com/raku/specs/commit/2f561420223fe5a44a5185e7fb7e9e8be536298e), I'm mostly relieved. Now *sorear*++ is uneasy instead, for (he says) reasons having to do with optimization.
- Most of [synopsis 5](https://github.com/Raku/old-design-docs/blob/master/S05-regex.pod) (about regexes and rules) is really frozen by now, thanks to some excellent implementations.  (The really slushy phase was sometime in 2006, if I recall correctly.) But last time we talked about the `<?after ...>` assertion, it seemed to me that there were more questions about it than there were answers in the synopsis. "Lookbehind" assertions, according to S05, work by "reversing the syntax tree and looking for things in the opposite order going to the left".  Of course, that only works for syntax trees without captures and other side effects, so the spec also says "It is illegal to do lookbehind on a pattern that cannot be reversed." Or, in other words, we haven't reached the point yet where we need to do lookbehind with those more tricky syntax trees. Fair enough.

## Abstraction astronautism

- Let's start with a sunshine story: the `Temporal spec`. It used to be really
bad, but after work that [I started](Its-about-time.html) and `*Kodi*++` and `*supernovus*++` finished, we now have a sane spec *and* a full Rakudo implementation. The secret sauce? Throw everything out and just copy someone else. In this case, we mostly copied the successful `DateTime` CPAN module, with some helpful experience-based tweaks suggested by `*autarch*++`, its original author. Essential to this type of wholesale rewrite is that it be done by one or at most two people. The many-cooks syndrome is usually what got us into trouble in the first place.
- The [`IO` spec](https://github.com/Raku/old-design-docs/blob/master/S16-io.pod) is a mess. Most of it is completely unimplemented. Some parts of it, if I recall correctly, are unimplementable, or would be a big mistake to implement as spec'd. It's my hope that this synopsis will follow the example of the `Temporal` one, and that someone would pick it up and just rewrite it from scratch. As an example of the atrocities perpetrated in this area, someone once set out to design a `Tree` core data type that would encompass such diverse structures as file system hierarchies and XML DOM structures. This, in my view, epitomizes abstraction astronautism. The effort with the `Tree``` specification seems to have fallen on its own absurdity.
- Sometimes I question whether Raku should really [embrace and extend Unix command-line options](https://github.com/Raku/old-design-docs/blob/master/S19-commandline.pod) in the way S19 says it should. What really seems over-the-top to me is the way one can specify namespaced options by means of a special type of "parenthesizing" flag &mdash; think SGML tags.  This kvetch could easily have fallen under the "slight unease" section, but I sincerely believe that some of the more ambitious parts of S19 should just go away. Having it conform better with the `MAIN` spec would be nice, on the other hand.

A third category would be "areas where I wish there were more spec, period".
But searching for those is the objective of being all over the place with
Rakudo, writing different application code, trying new and exciting things.
Such discussion takes place all the time on IRC, over pieces of code, or on
the p6l list. So I don't have a pent-up need to blog about those.
