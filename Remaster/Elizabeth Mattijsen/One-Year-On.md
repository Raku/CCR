# One Year On
    
*Originally published on [24 December 2016](https://perl6advent.wordpress.com/2016/12/24/day-24-one-year-on/) by Elizabeth Mattijsen.*

This time of year invites one to look back on things that have been, things that are and things that will be.

## Have Been

I was reminded of things that have been when I got my new notebook a few weeks ago.  Looking for a good first sticker to put on it, I came across an old ActiveState sticker:
> If you don’t know Perl
> you don’t know Dick

A sticker from 2000!  It struck me that that sticker was as old as Raku.  Only very few people now remember that a guy called [Dick Hardt](https://en.wikipedia.org/wiki/Dick_Hardt) was actually the CEO of ActiveState at the time.  So even though the pun may be lost on most due to the mists of time, the premise still rings true to me: that Perl is more about a state of mind, then about versions.  There will always be another version of Perl.  Those who don’t know Perl are doomed to re-implement it, poorly.  Which, to me, is why so many ideas were borrowed from Perl.  And [still](https://docs.python.org/3.6/whatsnew/3.6.html#whatsnew36-pep498) [are](https://docs.python.org/3.6/whatsnew/3.6.html#whatsnew36-pep515)!

## Are

Where are we now?  Is it the moment we know, We know, we know?  I don’t think we are at twenty thousand people using Raku just yet.  But we’re keeping our fingers crossed.  Just in case.

We are now 12 compiler releases after the initial Christmas release of Raku.  In this year, many, many areas of Rakudo Raku and MoarVM have dramatically improved in speed and stability.  Our [canary-in-the-coalmine test](http://tux.nl/Talks/CSV6/speed4.html) has dropped from around 14 seconds a year ago to around 5.5 seconds today.  A complete spectest run is now about 3 minutes, whereas it was about 4.5 minutes at the beginning of the year, while about 4000 tests were added (from about 50K to 54K).  And we now have [757 modules](http://modules.raku.org) in the Raku ecosystem (aka temporary CPAN for Raku modules), with a few more added every week.

The [#raku IRC channel](https://colabti.org/irclogger/irclogger_log/raku) has been too busy for me to follow consistently.  But if you have a question related to Raku and you want a quick answer, the #raku channel is the place to be.  You don’t even have to install an IRC client: you can also use a [browser to chat](https://webchat.freenode.net), or just follow “live” what is being said.

There are also quite a few useful bots on that channel: they e.g. take care of running a piece of Raku code for you.  Or find out at which commit the behaviour of a specific piece of code changed.  These are very helpful for the developers of Raku, who usually also hang out on the [#raku-dev IRC channel](https://colabti.org/irclogger/irclogger_log/raku-dev).  Which could be **you**!  The past year, at least one contributor was added to the [CREDITS](https://github.com/rakudo/rakudo/blob/nom/CREDITS) every month!

## Will Be

The coming year will see **at least three** Raku books being published.  First one will be [Think Raku – How To Think Like A Computer Scientist](https://www.reddit.com/r/perl/comments/557m4k/any_new_perl_6_books/d8aokjq/?st=ivsjiblm&sh=88f426e4) by *Laurent Rosenfeld*.  It is an introduction to programming using Raku.  But even for those of you with programming experience, it will be a good book to start learning Raku.  And I can know.  Because I’ve already read it :-)

Second one will be [Learning Raku](https://www.kickstarter.com/projects/1422827986/learning-perl-6) by veteran Perl developer and writer *brian d foy*.  It will have the advantage of being written by a seasoned writer going through the newbie experience that most people will have when coming from Perl.

The third one will be [Raku By Example](https://perlgeek.de/blog-en/perl-6/2016-book.html) by *Moritz Lenz*, which will, as the title already gives away, introduce Raku topics by example.

There’ll be at least two (larger) Perl Conferences apart from many smaller Perl workshops: the [The Perl Conference NA](http://news.perlfoundation.org/2016/11/the-perl-conference-save-date-2017.html) on 18-23 June, and the [The Perl Conference in Amsterdam](http://yapc.amsterdam) on 9-11 August.  Where you will meet all sorts of nice people!

And for the rest?  Expect a faster, leaner, Raku and MoarVM compiler release on the 3rd Saturday every month.  And an update of weekly events in the [Rakudo Weekly](https://rakudoweekly.blog/blog-feed/) on every Monday evening/Tuesday morning (depending on where you live).

