# A wholly inadequate reply to an Anonymous Monk
    
*Originally published on [22 April 2010](https://use-perl.github.io/user/pmichaud/journal/40322/) by Patrick Michaud.*

[Reposted from [Perl Monks](https://www.rakumonks.org/?node_id=836349).  Normally I wouldn't repost but I'd like it to appear in my normal Raku journal and rss feeds as well as on PerlMonks.  --Pm]

An Anonymous Monk on perlmonks.org recently started a discussion on
"[The current state of Raku](https://www.rakumonks.org/?node_id=835419)" in which he (she? they?) offers his
views on various aspects of Raku development.  Personally, I 
find nearly all of Anonymous Monk's comments in the thread to be
so devoid of logic and so far removed from reality/facts that it's
hard to imagine providing an adequate reply to them.

Beyond that, I have other priorities in my life right now.
Uppermost is that my family is going through a very difficult
period at present -- I need to take care of them first.  Rakudo and
Raku come in at a somewhat distant second to that.  Responding to
garbage being spouted by anonymous person(s) probably ought
to not even be anywhere on my radar.

But at least one post in the thread bugs me sufficiently that 
I'd like to respond, even if it's an inadequate response.
And I don't want my response buried in a thread somewhere, so it
gets its own post.

Anonymous Monk [writes](https://www.rakumonks.org/?node_id=835737):

> * Oh I'll tell you how you do that [write a grammar engine capable of supporting Raku]. It's very simple. You get people skilled for this exact task ! Those skills are acquired in universities(preferably good ones) where professors teach courses like "Formal Languages and Automata" or "Compiler theory". If you have a bunch of people who are open-source contributors but don't have the knowledge or haven't studied the right things ... **[t]hey don't know it in theory and they're trying to put it in practice!** (emphasis in original)

Who does Anonymous Monk think is working on Raku?  Personally, I
have a Ph.D. in Computer Science and taught university language 
courses for nearly 14 years.  Damian Conway certainly also
has a fairly strong university background (Monash University) and 
understands the theory and practice of language and compiler design.  
Jonathan Worthington has a degree from the University of Cambridge, 
where he specialized in compiler construction and formal languages.  
Larry Wall has a degree in Natural and Artificial Languages 
with two years of graduate work in Linguistics at U.C. Berkeley.  
Many of our other key contributors also have degrees and backgrounds 
in language theory and practice.  I'd be willing to compare the
academic credentials of this group against any other dynamic 
language team Anonymous Monk might care to postulate.

> *If you can't get **real** compiler people to use Raku and help with it, the average open-source rookie won't be able to deal with this.

Somehow I have trouble classifying Larry, Damian, Allison, etc. as
being "not real compiler people".  And they along with many other
Raku contributors have a lot of experience in nurturing open
source developers and projects.  If you feel Larry et al. are 
indeed unqualified to be working in the field of programming
language design and implementation, you probably don't want to 
be using Perl at all, much less Raku.

People like Anonymous Monk spew lots of opinions about how long
they think Raku development should take, and then speculate on
the reasons why it has taken longer than they estimate it should
be taking.  The speculations that crop up most often are things
like "the people involved are clueless about language
design/implementation" (see above), "the design process itself
is flawed", "they're building on an inadequate toolset like Parrot",
etc.  For such people it's easy to toss out random thoughts about
"the problems with Raku" without bothering to look at
the obvious evidence to the contrary, as Anonymous Monk
does above.  Indeed, I'm often amused when people suggest that
we should be doing things *that we're already doing*.

Returning to the topic of developing a grammar engine, which
Anonymous Monk claims above as "very simple" and just needing
"people skilled for this exact task", it's interesting to contrast
his opinions with the actual development of the Raku standard grammar
(STD.pm6).
I think STD.pm6 is also indicative of the challenges confronting all
Raku implementors.  Consider:

- Larry is the primary implementor for the standard grammar.
- The standard grammar doesn't need a frozen specification to be implemented, because its implementation is considered part of the spec.
- The implementation is built entirely on top of Perl -- there are no "unproven virtual machines" involved or holding things back.

I think one could consider this to be an almost perfect situation
for developing a new language implementation -- an experienced language
designer/implementor working without significant external
restrictions on top of an advanced programming platform like
Perl.  Yet it's been three years since Larry started working
on this implementation of the standard grammar and parser, and
while STD.pm6 is very powerful, it's also certainly not "finished",
and has been through a number of significant refactors in its
development.  This says to me that the amount of time and effort
involved is more likely due to the sheer audacity and ambition of what
Raku seeks to accomplish.

(Some will undoubtedly look at the above and knee-jerk respond
with something like "If it's taken three years just to create
the parser, then finishing a compiler will take far longer still
and therefore Raku will never see the light of day."
This argument ignores the fact that other pieces
are being implemented in parallel with Larry's work, that
software development is not a strictly sequential process, and
the obvious fact that there are already "working" Raku
implementations available.)

Anyone who thinks that Raku is fundamentally based on
traditional compiler construction techniques taught in
universities frankly has no clue as to what a fundamental
paradigm shift Raku represents to language design and
implementation.  It's this fundamental change that ultimately
gives Raku its power, but it's also why Raku development
is not a trivial exercise that can be done by a few
dedicated undergraduates.  As
[*TimToady* on #raku says](https://irclogs.raku.org/perl6/2010-04-22.html#18:41-0001),
"We already have lots of those kinds of languages." 

Personally, I'm impressed and honored to be associated with
the people who are working on Rakudo and Raku.  I understand
that people are frustrated (and even feel burned by) the long
wait for something as cool as Raku; I share the frustration
and like to think that I'm doing something constructive about it.
But I also find the vast majority of suggestions, comments, and 
conclusions coming from Raku's anonymous detractors to be
(1) things we've already done or are doing, (2) ungrounded in
reality, (3) in direct contradiction to reasonably observable 
facts, or (4) attempts to discredit a product they have little
interest in ever using themselves.  And far too many of the
comments, like the ones I've highlighted in this post, are
so easily refuted with just a little bit of fact digging and
common sense, it's often hard to believe anyone can be seriously
making them in the first place.  Yet there they are.

Returning to my original theme, I think my response here is
inadequate because it leaves so many other of Anonymous Monk's
claims in the thread unrefuted.  I could undoubtedly spend many
more hours analyzing and responding to the many fallacies and untruths
in the thread, but frankly I don't believe that's the best use of
my time.  People such as Moritz Lenz, chromatic, Michael Schwern,
and others are 
also writing extremely well-reasoned posts refuting the garbage, for
which I'm grateful, but it's far easier for Anonymous Monk and his like
to spin garbage than it is for a small number of us to clean up after
it.  And it does need to be cleaned up, otherwise it festers and
results in even more public garbage [that someone has to clean up](https://arstechnica.com/information-technology/2010/04/perl-5-development-resumes-version-512-released/?comments=1&comments-page=1#comments)

I hope that this post will at least encourage more people in the
Perl community to critically examine the things they hear and
read regarding Raku, especially when coming from sources with
no apparent standing or reputation within the community.  And
maybe a few more people will even assist in publicly refuting
the garbage ("many hands make light work"), so that the sloppy
thinking, analysis, and dialogue that people like Anonymous Monk
post doesn't spread to infect all of Perl.

P.S.: Some may reasonably conclude from what I've written
above that Raku is somehow "aiming too high", that our goals 
should be scaled back to make something ready "right now".
I have two responses to this: (1) we *are* making things
ready 'right now', just grab any of the available packages and
start working and reporting bugs, and (2) there are already 
'scaled back' versions of Raku appearing and being used,
such as NQP or even the components that execute the standard
grammar.  Some of these other projects, like NQP, are being
used for "real" programs and applications today; they're not
simply theoretical exercises or research projects.

Others often claim that all this effort on Raku would be
better spent on improving Perl.  In my experience, those of us
working on Raku have absolutely no qualms with seeing Perl
improve and continue to grow -- we welcome it.  Indeed,
many of the features appearing in Perl today come directly
from ideas and things first attempted in Raku, and we're
genuinely happy to see that.  But just because Raku developers
also like Perl doesn't mean that doing Perl core development is
interesting to us, or that (in my case at least) we'd even be
qualified to do Perl core changes.  We aren't commodity programmers
that are interested in simply being unplugged from one project and
into some other project that others think is more worthwhile.
Personally, I'd prefer to see people who are really into Perl
improvements continue to work to make them happen, and that
the surrounding ecosystem continue to evolve to enable that
to happen more easily for more people.  Indeed, this is my wish
for all open-source projects, even the ones I don't find
interesting or otherwise disagree with.
