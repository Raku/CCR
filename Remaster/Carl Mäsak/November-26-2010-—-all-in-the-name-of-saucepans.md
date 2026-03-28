# November 26 2010 — all in the name of saucepans
    
*Originally published on [26 November 2010](http://strangelyconsistent.org/blog/november-26-2010-all-in-the-name-of-saucepans) by Carl Mäsak.*

> 66 years ago today, [the largest civillian loss of life](https://en.wikipedia.org/wiki/Woolworths_Group_plc#Disasters) due to direct enemy fire in Britain during WWII occurred.

> Many branches of Woolworths suffered severe bomb damage and even destruction during the Luftwaffe attacks in the early part of the Second World War. However it was towards the end of the war that [...] a German V-2 rocket fell on a packed Woolworths store in New Cross Road, killing 168 people (including 15 children), injuring 122 others and razing the building to the ground. The neighbouring London Co-operative Society store was also demolished in the attack.

There was a reason so many had gathered in and outside the Woolworths on that day.

> The store was especially busy as news of a delivery of hard-to-obtain saucepans generated huge crowds, many of whom were queueing outside the store at the time of the rocket's impact.

Ok, so the `.trans` bug that I couldn't explain yesterday turned out to be due to me having too old an installed Rakudo. My path to realizing this [is recorded in the IRC backlog](https://irclogs.raku.org/perl6/2010-11-26.html#09:51). All through this, the chapter ["8. Positive Bias"](https://www.fanfiction.net/s/5782108/8/Harry_Potter_and_the_Methods_of_Rationality) from the excellent fanfic "Harry Potter and the Methods of Rationality" kept ringing in my ears. Even when you know about positive bias, it's hard to shake off your assumptions.

So, basically I was cheated out of fixing this thing once again. Not that I'm complaining or anything.

Now November mostly works. I see some problem with list generation, but that shouldn't be a biggie. I'll handle that some other day.

Instead, I turned to Web.pm, since I plan to give that some serious attention in the weekend, so I can close up the Web.pm grant. (Finally!)

Web.pm is in a better state that I feared. Here it is, in short:

- All modules compile (under alpha).
- The tests are in a state that I'd describe charitably as "fixable". Some modules fare better than others in this regard.
- The tutorial is pretty, but not finished yet. It's 6 pages now; I expect it to be 20 or so. Do [have a look](https://github.com/masak/web/raw/master/tutorial/win.pdf), and let me know what you think.

Also, since the beginning of October (thanks to the hackathon at *mberends*++' home in Vught), there's already an up-to-date [README](https://github.com/masak/web), that better reflects the current Web.pm, as opposed to the Web.pm from a year or so ago.

So, all set to get to work for the weekend. Yes, this didn't turn out to be an action-filled blog post. I'd like to see you do better when bugs annoyingly melt away before your eyes. 哈哈
