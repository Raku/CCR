# Behind the scenes of the Chicago Release
    
*Originally published on [26 July 2009](https://use-perl.github.io/user/pmichaud/journal/39352/) by Patrick Michaud.*

This week I learned just how well Rakudo development is able to
continue even when I'm preoccupied with things not directly
related to making commits to the Rakudo repository.  

As you probably know, I spent this past week in San Jose at 
OSCON, 
which was as usual was a fantastic conference.  
I was able to give some presentations about Rakudo and Parrot 
(recruiting!), meet lots of new people, visit and make plans 
with others working on Raku, and otherwise just have a good time.

Prior to coming to San Jose I had been planning that I would have
some time in the evenings to work directly on Rakudo and prepare
for its #19 release on Thursday (Jul 23).  
In past years at OSCON I've been able to get a fair amount of
hacking done in the evenings... but that didn't happen this year.

First of all, I found myself having far more hallway discussions
and other sorts of meetings with folks than I have in past OSCONs.  
Then, on Tuesday night I decided that I really wanted to do
a significant refactor of the "Hacking Rakudo"
talk that I
would be giving on Wednesday.  I knew this would take away from
my tuits for preparing the Thursday Rakudo release, but I felt
the benefit of having a better talk (which I will also be giving
at YAPC::EU in Lisbon) 
was worth the risk of having
trouble getting the release out on Thursday.

Fortunately I never had to run that risk.  A couple of weeks ago
I posted an article about [Seeking-future-Rakudo-release-managers.html](getting release managers for Rakudo).
On Tuesday (while I was busy at OSCON), Moritz Lenz was able to use
the [https://github.com/rakudo/rakudo/blob/master/docs/release_guide.pod](release guide) to produce a "practice release" as
described in the article.

As a result, on early Wednesday morning I was able to see that Moritz
had produced a practice release, and knowing that I wanted to focus
on my presentation I immediately asked him if he would like to do
the official release on Thursday.  (I also asked Jonathan if he
could work on eliminating a Null PMC error that was showing up
in backtraces and didn't look good for the release, which he 
of course took care of very quickly.)

Moritz accepted the release task, and I am *extremely* pleased 
with how everything turned out.  First of course is the release 
itself, which is equal or better to anything I would've produced.  
Moritz, along with help from others on IRC #raku, assembled the 
ChangeLog, drafted the release announcement (adding a new section
for deprecations), and as far as I can tell executed the release
flawlessly.  As it turns out, my role in the release consisted only
of reviewing the release announcement on Wednesday night, adding
a couple of statistics to the announcement, and telling Moritz 
that he could issue the release whenever he felt it was ready.
I didn't have any further involvement after that -- the next
I heard about it was someone coming up to me at OSCON on 
Thursday afternoon to congratulate me on the Chicago release.

This past week saw more than just the release; during the course of
the week several people added new features and bugfixes to Rakudo
(with Moritz and others applying contributed patches).  Rakudo's
passing spectest count increased by over 100 during the course of
the week.

So, my thanks go out to Moritz, Jonathan, Carl, Kyle, Scott, and 
everyone else who worked on the release and Rakudo this week.
You all did a fantastic job, and tremendously simplified my 
life while I was at OSCON.

Of equal importance, we've now demonstrated that others besides
myself can do Rakudo releases (although I had little doubt of this).
As a result, I'm now issuing an *official* "call for release
managers" for the remaining Rakudo releases in 2009.  Ideally 
I'd like to see that the release responsibility is regularly 
rotated across multiple managers (as Parrot does), so that no 
single person ends up being burdened with producing releases.  
I'm also planning that I personally won't do any more Rakudo 
releases myself in 2009, unless we're completely unable to 
find release managers.

If you're interested in becoming a Rakudo release manager --
take a look at the [release guide](httpis://github.com/rakudo/rakudo/blob/master/docs/release_guide.pod), make sure you've filed a
[https://perlfoundation.org/legal](Contributor License Agreement), 
and we'll put together a schedule for the 2009 releases.
