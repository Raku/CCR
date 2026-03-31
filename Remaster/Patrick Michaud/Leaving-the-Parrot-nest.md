# Leaving the Parrot nest
    
*Originally published on [15 January 2009](https://use-perl.github.io/user/pmichaud/journal/38291/) by Patrick Michaud.*

As many of you will have gathered from discussions on other mailing
lists and IRC, it's time for Rakudo to "leave the Parrot nest" 
and move to its own repository.  I think we should also take this
opportunity to re-evaluate the entire Rakudo infrastructure
and decide what will be most productive for the community for
the upcoming year.  Indeed, as part of any move we need to
communicate the details of the changes to others, which brings
to the surface some of the shortcomings of what we have now.

By "infrastructure" I'm primarily referring to the following items:

- source code repositories (note: plural)
- web sites
- blog / news
- wiki
- issue tracking
- mailing lists

Currently these things are spread in many different locations with
different tools, and while I don't believe it's necessary for them
completely unified, we should at least aim to reduce the overall 
complexity of what we do have so that we can better serve those 
who are interested (or are yet to become interested) in Rakudo Perl.
In fact, it may be that in many cases we'll keep what we have now,
but at least it'll be a confirmed decision instead of simply going
along with what we've had in the past.

Also, I'm sure it will be easy and tempting to address
larger issues about Raku as a whole (as opposed to just
"Rakudo").  I'm not at all opposed to seeing that larger discussion
take place, but for my purposes I'll be tending to focus on Rakudo's 
immediate needs.

Here's my off-the-cuff inventory of where things are in Rakudo today
and where things might head.  It's entirely possible that my
description below misunderstands or misrepresents reality in
some areas -- but I'm dedicating this week to resolving that.
Indeed, that's the primary purpose of this message, to help us
all clear up confusion surrounding Rakudo (and Raku).

## Source code repository

This is the immediate issue at hand, because we need to move Rakudo
out of the Parrot repository so that it can cleanly move to its new
home at parrot.org.  Currently Rakudo Perl lives at
http://svn.raku.org/parrot/trunk/languages/raku/, while the 
spectest suite (on which development/testing depends) lives at
http://svn.pugscode.org/pugs/t/spec/.

Many people have strongly suggested that we switch to
using "git" as our version control system.  At the moment I'm
neither strongly in favor of nor strongly opposed to switching
version control systems, but we have to recognize that at least
two of Rakudo's "dependencies" (Parrot and the spectest suite) 
are using Subversion and are likely to remain that way for 
a while.  We don't want to require non-developers to install a 
lot of different source code control systems simply to run and 
test the latest incarnation of Rakudo.

I have a lot more comments on source code management for
Rakudo, but to keep to the "overview" nature of this post
I'll save the rest for a longer post.  Feel free to start
submitting your opinions, however!

## Web site / blog / wiki

Currently Rakudo really does not have a dedicated website
providing basic information about it.  There is the 
[Rakudo](https://rakudo.org) site, but it's currently more of a
blog than a true web site.  For example, someone visiting
rakudo.org would not be able to easily find out how to 
download and run Rakudo.

Here's what we *do* have at the moment (as best as I can recall):

- Rakudo.org is run by Andy Lester and currently provides a "blog" for Rakudo Perl.  Andy has mused about switching rakudo.org to Drupal instead of Movable Type, which could enable us to more easily have "introductory content" information instead of just blog-type entries.
- Of course, many of us regularly post to journals at http://use-perl.github.io/.  This is good for keeping in touch with the wider Perl community and provides a good blog-like interface, but again isn't useful at basic Rakudo information and orientation.
- The Perl Foundation hosts a "Raku wiki", and Rakudo has a few pages there.  Currently I find the wiki to be not very well organized, and it's difficult to find Rakudo out of the many other items that appear there.  Beyond that, I'm not impressed with the wiki engine the site uses, but if a sizable group of people think that's where Rakudo information should be centered then I can live with it.
- TPF also hosts the "Raku" website, but "Rakudo" isn't even mentioned there, and I don't even really know the correct procedure for getting updates or modifications to those pages.  My impression is that this site isn't really conducive to frequent updates or lots of contributors (but perhaps I'm incorrect about that).
- Planet Raku (approve links) is an excellent aggregator of Raku related posts, including those involving Rakudo.  

Also, for the record, I currently own the "rakudoperl.org"
and "rakudoperl.com" domains, so if we want to do something
somehow separate from any of the existing domains cited above, 
we can use those domains, and I may have (or be able to acquire)
additional server resources to support it.

## Issue tracking

Currently issue tracking for Rakudo is being done using RT
(the same RT instance that does Perl bug tracking).  In
the past I've stated that Rakudo bugs will
continue to use this tracker, and I'm still planning for that
to be the case, but in recent weeks I've encountered a
number of times were rt.raku.org was too slow/unreachable
to be an effective tool.  I'm not (yet?) advocating that we
switch to a different issue tracker, but since we're looking
at the whole of infrastructure items I did want to leave the
possibility open for discussion.

## Mailing list

Currently Rakudo's primary mailing list is perl6compiler@perl.org>.
I see no major reason to change anything here, as it works
well and is a good companion to the other "official"
Raku mailing lists.

----------

Throughout all of this, I'm looking at things from a very
practical perspective -- i.e., what can we achieve with the
resources currently at our disposal.  It's also important
to consider the needs of the various audiences -- not only
the Rakudo developers, but also people who want to experiment
with Rakudo and those who want to start building applications
for it.  So, we need to keep in mind the many perspectives on
the issue as we go through the discussion.

Also, I'm expecting that some of the decisions I eventually
make may disappoint some; apologies in advance, but such is
the nature of decisions.

With that background in place, I'll now (with great trepidation)
open the discussion for others to comment and/or make suggestions
of what they'd like to see changed about the way we currently
manage Rakudo.

Thanks in advance,
