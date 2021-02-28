# The Missing Contributors of Raku
    
*Originally published on [4 July 2018](https://perl6.party//post/The-Missing-Contributors-of-Perl6) by Zoffix Znet.*

Today, I came across a reddit post from a couple months back, from a rather irate person claiming themselves to be possibly the only person to never receive any credit for their work on Raku.

I was aware that person committed at least one commit and knowing the contributors list is generated automagically with a script, I thought to myself "Well, that's clear and provable bullshit." And I went to prove it.

## Moar No More

I looked up the commit I knew about, looked at the release announcement for the release it went into and… that person was indeed missing! It was the 2017.02 release, which I released. So what was going on? Did I have an alter-ego that shamelessly erased random people from the contrib list without my having any memory of it?!

First, a brief intro on how the contrib script works: it uses `git` to look up commits in checkouts of 5 repos: Rakudo, NQP, MoarVM, Docs, and Roast.  Until [December 2016](https://github.com/rakudo/rakudo/commit/27761645c59446090d895e50e5cd7a1ab3a93ab7#diff-508f29ffdf70323e02c5be76f4f30364) the script just used the day of the release as last release, which was later switched to using the timestamp on the Rakudo's tag. The script gathers all the contributors from commits, crunches the names through the names map in CREDITS files in the repos, and it spits out the names ordered by the number of commits made, largest first.

I set out to figure out why a person was missing from the release announcement.  After digging through commits, CREDITS files, and tracing the code in [the contributor generating script](https://github.com/rakudo/rakudo/blob/master/tools/contributors.p6), I found out that in September 2016, I [introduced a bug](https://github.com/rakudo/rakudo/commit/bd3d430210d6d8c6f601718dd4b290c3c9753206) into the contributors script. After some refactoring I accidentally left out [MoarVM repository](https://github.com/MoarVM/MoarVM) from the list of repos the script searches, so all the contributors to the MoarVM since September 2016 were missing! Since many of them also contribute to the other 4 repos, it was harder to spot that something was wrong.

I filed the problem as [R#2024](https://github.com/rakudo/rakudo/issues/2024) and left it at that for the time being.

## Missing More

I started working on the problem and implemented a new feature in the contributors script that lets you look up contributors for past releases.  Neat! So let's try it out for some release before my bug was made, shall we?

I ran the contrib script for 2016.08 relase and then ran another script that diffed the names from that output against what is on the release announcement.  The output was:

```` raku
Announcement has these extra names: David Warring
Contrib script has these extra names: Arne Skjærholt, Bart Wiegmans
````

The announcement had an extra name and was missing two. The way the contrib script figures out when one release ends and another starts is iffy, especially so in the past. There's a gap of about a day where contributors can slip through: e.g. release manager runs the release at 2PM, someone commits at 3PM, and that commit didn't make it into this release and will be included in the next, or might even be missed entirely.

So that was one problem I noticed. Is that where the difference for 2016.08 release names list comes from? Let's try the earliest post-The-Christmas release: 2016.01-RC1

```` raku
Announcement has these extra names: Andy Weidenbaum, Lloyd Fournier, skids
Contrib script has these extra names: A. Sinan Unur, Aleks-Daniel Jakimenko-Aleksejev,
Brad Gilbert, Brian S. Julin, Brock Wilcox, Bruce Gray, Carl Masak,
Christian Bartolomäus, Christopher Bottoms, Claudio Ramirez, Dale Evans,
Dave Olszewski, David Brunton, Fritz Zaucker, Jake Russo, James ( Jeremy )
Carman, Jeffrey Goff, Jim Davis, John Gabriele, LLFourn, Marcel Timmerman,
Martin Dørum Nygaard, Neil Shadrach, Salvador Ortiz, Shlomi Fish, Siavash
Askari Nasr, Stéphane Payrard, Sylvain Colinet, Wenzel P. P. Peppmeyer,
Zoffix Znet, fireartist, sylvarant, vinc17fr
````

That's huge! One name stood out to me in that list—and it isn't my own—it was that same person from reddit who was complaining that they don't get credit.  They got left out twice: in 2016.01 and again in 2017.02. No wonder they're pissed off, but I wish they would've said something in 2016.01, so we'd've fixed the Missing Persons issues back then instead of now.

The 2016.02 release has a bunch of missing names as well. I can surmise the cause of the issue is a [previously fixed](https://github.com/rakudo/rakudo/commit/05133931a9b6b2dd48e4001889bf7dbe37d5b8a4#diff-508f29ffdf70323e02c5be76f4f30364) mis-implementation of the contributors script where it'd be quiet if some of the repo checkouts were missing. Neither I (until that point), nor earlier release managers had all of at the right locations the script was expecting, so it's possible that's how some repos were missed.

At the time, I assumed only the docs repo was missing and [we credited missing Docs contributors](https://github.com/rakudo/rakudo/blob/master/docs/announce/2016.08.md) in the 2016.08 announcement. However, now I realize that other release managers likely had different directory setups and thus missed different sets of people.

## The Future

Thus, we have identified four issues with the way contributor's script is or has been generating the list of contributors:

- Relying on the time when the release manager runs the contributor script, potentially creating a gap of unrecorded contributions between the time the script is run and the time the next run of contrib script considers as "last release"
- Relying on release manager's setup of directories/repos. Even after a [previous fix](https://github.com/rakudo/rakudo/commit/05133931a9b6b2dd48e4001889bf7dbe37d5b8a4#diff-508f29ffdf70323e02c5be76f4f30364) in this area, we're still relying on the release manager to have up-to-date checkouts of repos
- Missing contributors from entire repositories due to unnoticed bug in the code
- What happens with commits made at the time of past release in a branch that is merged at the time of the next release? Do they get lost?

I'm taking the lazy way out and leaving it to the current release managers to resolve these problems. I filed [R#2028](https://github.com/rakudo/rakudo/issues/2028) with the list of issues and have full trust the solution that will be implemented will be suitable :)

## The Found

And now, of course, the list of previously unsung heros who made Raku better in the past two and a half years, in alphabetical order. I've also [added them to our past release announcements](https://github.com/rakudo/rakudo/commit/ade83c861484f5f4e4184a88d9dae79a2cdf110c).

It's possible this list includes the missing-found from [2016.08](https://github.com/rakudo/rakudo/blob/master/docs/announce/2016.08.md) announcement as well as people who were not logged in the CREDITS file in the past but are now, but I figure it's better to list them twice than none at all.

If you still believe we're missing someone, [let us know](https://github.com/rakudo/rakudo/issues/new) so the problem can be fixed.

#### 2016.01/2016.01-RC1

A. Sinan Unur, Aleks-Daniel Jakimenko-Aleksejev, Brad Gilbert, Brian S. Julin, Brock Wilcox, Bruce Gray, Carl Masak, Christian Bartolomäus, Christopher Bottoms, Claudio Ramirez, Dale Evans, Daniel Perrett, Dave Olszewski, David Brunton, Fritz Zaucker, Jake Russo, James ( Jeremy ) Carman, Jeffrey Goff, Jim Davis, John Gabriele, LLFourn, Marcel Timmerman, Martin Dørum Nygaard, Neil Shadrach, Salvador Ortiz, Shlomi Fish, Siavash Askari Nasr, Stéphane Payrard, Sylvain Colinet, Wenzel P. P. Peppmeyer, Zoffix Znet, fireartist, raiph, sylvarant, vinc17fr

#### 2016.02

Bart Wiegmans, Brian S. Julin, Brock Wilcox, Daniel Perrett, David Brunton, Eric de Hont, Fritz Zaucker, Marcel Timmerman, Nat, Pepe Schwarz, Robert Newbould, Shlomi Fish, Simon Ruderich, Steve Mynott, Wenzel P. P. Peppmeyer, gotoexit, raiph, sylvarant

#### 2016.03

Ahmad M. Zawawi, Aleks-Daniel Jakimenko-Aleksejev, Bahtiar `kalkin-` Gadimov, Bart Wiegmans, Brian S. Julin, Brock Wilcox, Claudio Ramirez, Emeric54, Eric de Hont, Jake Russo, John Gabriele, LLFourn, Mathieu Gagnon, Paul Cochrane, Siavash Askari Nasr, Zoffix Znet, jjatria, okaoka, sylvarant

#### 2016.04

Brian S. Julin, Brock Wilcox, Christopher Bottoms, David H. Adler, Donald Hunter, Emeric54, Itsuki Toyota, Jan-Olof Hendig, John Gabriele, Mathieu Gagnon, Nick Logan, Simon Ruderich, Tom Browder, Wenzel P. P. Peppmeyer, Zoffix Znet

#### 2016.05

Aleks-Daniel Jakimenko-Aleksejev, Brian Duggan, Brian S. Julin, Brock Wilcox, Christopher Bottoms, Clifton Wood, Coleoid, Dabrien 'Dabe' Murphy, Itsuki Toyota, Jan-Olof Hendig, Jason Cole, John Gabriele, Mathieu Gagnon, Philippe Bruhat (BooK), Siavash Askari Nasr, Sterling Hanenkamp, Steve Mynott, Tadeusz "tadzik" Sośnierz, VZ, Wenzel P. P. Peppmeyer, Will Coleda

#### 2016.06

*(contrib script missing repos issue is fixed around this point, so the
number of missing persons drops. Remaining ones are likely the ones that fell into the gap between releases; particularly MoarVM and docs contributors)*

Itsuki Toyota, Matthew Wilson, Will Coleda, parabolize

#### 2016.07

Bart Wiegmans, Brian S. Julin, Daniel Perrett, David Warring, Dominique Dumont, Itsuki Toyota, thundergnat

#### 2016.08

Arne Skjærholt, Bart Wiegmans

#### 2016.09

*(missing MoarVM bug is introed at this point; we start to see the missing
MoarVM devs who mostly work on MoarVM and not other repos. Also a bunch of docs people who likely fell into the gap between releases)*

Alexey Melezhik, Bart Wiegmans, Paul Cochrane

#### 2016.10

Brent Laabs, Jimmy Zhuo, Steve Mynott

#### 2016.11

Bart Wiegmans, Itsuki Toyota, Jimmy Zhuo, Mark Rushing

#### 2016.12

Bart Wiegmans, Jimmy Zhuo, LemonBoy, Nic Q, Reini Urban, Tobias Leich, ab5tract

#### 2017.01

Antonio Quinonez, Jimmy Zhuo, M. Faiz Zakwan Zamzuri

#### 2017.02

A. Sinan Unur, Bart Wiegmans, Benny Siegert, Jeff Linahan, Jimmy Zhuo, Lucas Buchala, M. Faiz Zakwan Zamzuri

#### 2017.03

Jonathan Scott Duff, Lucas Buchala, Moritz Lenz

#### 2017.04

Bart Wiegmans, eater

#### 2017.05

Bart Wiegmans, Paweł Murias

#### 2017.06

Bart Wiegmans, Jimmy Zhuo, Oleksii Varianyk, Paweł Murias, Robert Lemmen, gerd

#### 2017.07

Bart Wiegmans, Douglas Schrag, Gerd Pokorra, Lucas Buchala, Paweł Murias, gerd

#### 2017.08

Bart Wiegmans, Dagfinn Ilmari Mannsåker, Douglas L. Schrag, Jimmy Zhuo, Mario, Mark Montague, Nadim Khemir, Paul Smith, Paweł Murias, Philippe Bruhat (BooK), Ronald Schmidt, Steve Mynott, Sylvain Colinet, rafaelschipiura, ven

#### 2017.09

Bart Wiegmans, Dan Zwell, Itsuki Toyota, Jan-Olof Hendig, Jimmy Zhuo, Mario, Paweł Murias, Rafael Schipiura, Skarsnik, Will Coleda, smls

#### 2017.10

Bart Wiegmans, Jimmy Zhuo, Joel, Julien Simonet, Justin DeVuyst, M, Mario, Martin Ryan, Moritz Lenz, Patrick Sebastian Zimmermann, Paweł Murias, bitrauser, coypoop, eater, mryan, smls

#### 2017.11

Bart Wiegmans, Jimmy Zhuo, Martin Barth, Patrick Zimmermann, Paweł Murias

#### 2017.12

Bart Wiegmans, Paweł Murias, Stefan Seifert, brian d foy

#### 2018.01

Bart Wiegmans, Daniel Dehennin, Paweł Murias, Stefan Seifert, Will Coleda

#### 2018.02

Bart Wiegmans, Daniel Green, Paweł Murias, cygx, wukgdu

#### 2018.03

Bart Wiegmans

#### 2018.04

Bart Wiegmans, Paweł Murias, cc, gerd

#### 2018.05

Antonio, Bart Wiegmans, elenamerelo

#### 2018.06

Bart Wiegmans, JJ Merelo

## Conclusion

So this was quite a fun investigation and hopefully all the missing people have been found and this is the last missing-found persons list we compile.

The most important lesson, however, is: report problems as soon as you find them. We could've fixed this at the start of 2016, and those who knew they were left out could've saved two years of being upset about it.

-Ofun
