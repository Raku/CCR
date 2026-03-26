# November 5, 2008 — remember, remember
    
*Originally published on [5 November 2008](http://strangelyconsistent.org/blog/november-5-2008-remember-remember) by Carl Mäsak.*

```
Remember, remember the Fifth of November,
The Gunpowder Treason and Plot,
I can think of no reason<
Why the Gunpowder Treason
Should ever be forgot.
```

403 years ago today, Guido "Guy" Fawkes was arrested for attempting to blow up Parliament. The so-called [Gunpowder Plot](http://en.wikipedia.org/wiki/Gunpowder_Plot) failed and Guy Fawkes was killed, but they are still celebrated in Britain and New Zealand.

Wikipedia on the memetic heritage of [Guy Fawkes](http://en.wikipedia.org/wiki/Guy_Fawkes):

> The Fawkes story continued to be celebrated in poetry. The Latin verse In Quintum Novembris was written c. 1626. John Milton’s Satan in book six of Paradise Lost was inspired by Fawkes — the Devil invents gunpowder to try to match God's thunderbolts. Post-Reformation and anti–Catholic literature often personified Fawkes as the Devil in this way. From Puritan polemics to popular literature, all sought to associate Fawkes with the demonic. However, his reputation has since undergone a rehabilitation, and today he is often toasted as, "The last man to enter Parliament with honourable intentions."

Instead of blowing things up today, I've been attempting to put them back together. Since (*jonathan*++)++ unlocked the bugs [#59104](http://rt.perl.org/rt3/Ticket/Display.html?id=59104) and [#59928](http://rt.perl.org/rt3/Ticket/Display.html?id=59928), a few things could be un-uglified in November.

Doing so resulted in [two](https://github.com/Raku/old-issue-tracker/issues/388) [new](https://github.com/Raku/old-issue-tracker/issues/389) tickets. Jonathan guesses that these two problems will be easy and a tad deeper, respectively. I can't stress enough how nice it is to have someone addressing the problems in the background as we uncover them in our shaky, real-world app.

Anyway, the improvements mean that we're fast again! :)

```
$ time ./test_wiki.sh
real    0m30.919s
user    0m28.955s
sys    0m0.759s
$ make
$ time ./test_wiki.sh
real    0m8.811s
user    0m8.025s
sys    0m0.264s
```

Not as impressive as the 1.3 seconds we had in August, but we're more ambitious nowadays, and our `Main_Page` is much bigger. Still, a 70% speedup is not too bad.

This also means that we'll soon be ready for a server upgrade, pushing out all the new stuff we've been working on for the last three months. It would be nice to have at least one decent skin ready before the server upgrade, though. So I guess that's what I'll be working on in the coming days.
