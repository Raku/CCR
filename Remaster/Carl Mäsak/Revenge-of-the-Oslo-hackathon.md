# Revenge of the Oslo hackathon
    
*Originally published on [22 April 2012](http://strangelyconsistent.org/blog/revenge-of-the-oslo-hackathon) by Carl Mäsak.*

A month of blog silence. Ouch. Looking back, the three reasons I can see for my
absence from blogging are work, work, and work.

So I saw
[moritz](https://perlgeek.de/blog-en/perl-6/2012-oslo-hackathon-report.html),
[jnthn](https://6guts.wordpress.com/2012/04/21/hackathoning-in-oslo/), and
[pmichaud](https://pmthium.com/2012/04/22/oslo-perl-6-patterns-hackathon-days-1-2/)
blog about the weekend, and I must've been too shell-shocked to think to do the
same. *sjn*++ woke me up from my reverie by asking me outright.

So, here goes.

Oslo. We had a hackathon there.

This is the second time. The first time was in 2009, and was quite possible the
best hackathon *ever*, in the history of Raku hackathons. (Or, let's say,
certainly among the top 5.)

I haven't fully processed this one, but it's not too early to say this: this
one beat the last one.

My weekend, in brief:

- jnthn and I arrived Oslo on the Thursday, and watched Damian Conway giving
an awesome presentation in a bar. No-one combines geek jokes, almost-accurate
physics, and Perl programming like Damian.

- On the Saturday, I spent about an hour introducing a group of newcomers to
Raku, language and culture. Fun!

- *infosophy*++ (Geir Amdal) liked my [tote](Helpfully-addictive-tdd-on-crack.html) script so much that he did something I never got around to doing

he [published it as a module](https://github.com/gam/test-junkie/). As part of
this, he [added back a bunch of IO
methods](https://github.com/rakudo/rakudo/commit/edf2e0d5d7e9ea7c3417717f163698113692e165)
that got lost in the ng→nom transition, and also [added spectests for
them](https://github.com/raku/roast/commit/a45e1b21d8529fe2a3dd3d3940a2941fa5869d43).
As part of this, he became the 100th developer in the raku organization.

- *sergot*++ (Filip Sergot) and I built a presentation framework.

It's called
[Sambal](https://github.com/masak/sambal), and it [turns a DSL into a
PDF](https://gist.github.com/masak/2173720). I'm happy and proud of how far we
managed to get with only two days of work.

- *sergot*++ and I also spit out a [`Text::Markdown`](https://github.com/masak/markdown) module.

It's in early
stages yet, but it already services Sambal in its slide generation. It's an
easy addition to have its objects model serialize to HTML, too.

- I asked whether `BEGIN` should trigger immediately inside a `quasi`, or
whether it should trigger only after macro application.

People around the
hackathon table suggested that we should have a `QBEGIN` that did the latter.
I felt it was a singularly bad idea, so I asked *TimToady*. He suggested the
same. [I exploded](https://irclogs.raku.org/perl6/2012-04-21.html#13:49).

Then I decided not to listen to anyone, and just implement it in the way that
turned out to be natural and convenient. pmichaud joked that he should have
adopted that approach long ago with respect to implementing Raku.
- 
(But seriously. If you want to execute a BEGIN block at macro-parse time,
put it outside of the quasi. If you want to execute it at macro-apply time,
put it inside of it. We don't need a [Q\*bert `BEGIN`](https://en.wikipedia.org/wiki/Q*bert).)

- We discussed what `s///` should evaluate to. No real consensus. `:-(```

- On the Sunday, we tried a coding dojo (hosted by *infosophy*++)

Implementing a roman numerals `Int -> Str` converter in Raku. It led to
interesting discussions, and many of us had useful insights in collaborative
coding and small-step iterative development.

- *frettled*++ [took some nice
pictures](https://howcaniexplainthis.blogspot.se/2012/04/oslopm-patterns-hackathon-pictures.html).

- *jnthn*++ and *pmichaud*++ evolved a plan for the new QAST redesign

Which will enable [the next
step](Macros-progress-report-d1-merged.html)
in the macros grant. *jnthn*++ invited me to write some tests on this for great
success. It looks doable; I'll dig into this during the next week. As I do
this, I can also write tests for my new `QAST::Unquasi` node type.

If Oslo.pm ever hosts a third hackathon, my expectations will found be in
geostationary orbit. No chance in the world I'd miss it.
