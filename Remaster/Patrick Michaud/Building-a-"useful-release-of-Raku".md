# Building a "useful release of Raku"
    
*Originally published on [5 August 2009](https://use-perl.github.io/user/pmichaud/journal/39411/) by Patrick Michaud.*

The most common question I get from people who aren't generally
involved with Raku development is:

> *"When will Raku be finished?"*

In some ways the wording of this question bugs me a bit, 
because the word "finished" implies there's a point at which
we all say "We're done" and development ceases (or at least 
moves to some other phase).  But there really isn't a "finish
line" for Raku, there are just stages of development at which
more and more people are able to make use of whatever is currently
available.

So, once we eliminate the notion of "finished", the wording is
often changed to try to make it more tractable, often by asking
when there will be a "stable release", or when the specification
will be frozen so an implementation can be completed, or many other
variations on the theme.  I understand the assumptions behind 
questions like these, but at the same time part of me thinks 
"Huh?  Those questions don't really fit with the way things 
really happen in language development..."  

The truth is that language design is an evolutionary process,
with the design and implementation efforts serving to influence
and guide further progress in the other.  (See "whirlpool model".)

But there's another important input to the process: "real-world"
application programs.  We need to know how Raku is actually
being used in order to finish parts of the specification and 
implementation.  Indeed, there are parts of Raku (e.g., 
concurrency) where the specification is incomplete or
underspecified precisely because we need input from people
writing Raku applications.

But this poses a problem of sorts, because if programmers are
waiting for Raku to "finish" before they start using it
to write programs, and if Raku is blocking on feedback from
applications and implementations before it can progress, then
we have a deadlock of sorts.

So, we need a way to break the deadlock.  To me, one good answer
is to start making releases of Raku that may not implement
the entire Raku specification, but that application writers
will feel comfortable enough to start using in their projects.
I've started to call these "useful releases" or "usable releases".
While it might not have every feature described in the Raku
synopses, enough features will be present that can make it a
reasonable choice for application programs.

In doing this, I'd like to also refocus conversations to avoid
words like "finished" and "stable", because they have such
varied and strong meanings in this context.

So, here's what the Rakudo project is going to do:

> We will make an "official", intermediate, *useful* and *usable* release of Raku (an appropriate subset) by Spring 2010.

Of course, we have to decide what will will be included (and
*excluded*) in this intermediate "official release".  At
the Rakudo BOF on Monday we held a lively discussion about 
what the release could look like, what needed to be present,
and how it could be packaged.  During the hackathons and days
following YAPC::EU we'll be drafting and publishing the more 
detailed blueprint for the release.  But one of our guiding 
principles will be to "under-promise and over-deliver", 
to make it clear what *can* be done with the release, 
and to make it very clear which parts of Raku are not yet
supported in the release.

A short list of things we *know* will be in the release (that
Rakudo doesn't already have):  use of the STD.pm grammar for parsing, 
laziness, better support for modules, fewer bugs, better error 
messages, better speed.  Again, our goal is to make something that 
is reasonable for people to start using, even if it doesn't
meet all of the requirements for Raku.0.0.

We've also had discussions about what to call the intermediate
release.  We've considered tagging it as "Rakudo 1.0", but some
of us think that the "1.0" name might tend towards "overpromise".
We also considered things like "0.5" or "0.9", but these come with
the message of "not ready for use", and that's not what the impression
we want to make either.

So, yesterday morning I finally got around to thinking about it
as "Rakudo 'whatever'".  In Raku the `*` term is used to signify
"whatever", so that leads to a working name of "Rakudo *"  (or
"Rakudo Star").

So, the focus of the Rakudo project is to release "Rakudo Star" 
in Spring 2010 as a *useful* (but incomplete) implementation 
of Raku.  More details about the features, milestones, and roadmap
for this release will be forthcoming over the next few days.

P.S.:  Several of our "down-under" community members have pointed out that "Spring 2010" can be a bit ambiguous.  I'm using a season (instead of a month) to leave a month or two of wiggle room, but my intention is April 2010.  As we get a bit more detail into the plan, we'll identify a specific month.
