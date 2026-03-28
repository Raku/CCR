# November 19 2010 — I've got good news and bad news
    
*Originally published on [20 November 2010](http://strangelyconsistent.org/blog/november-19-2010-ive-got-good-news-and-bad-news) by Carl Mäsak.*

> 69 years ago today off the coast of western Australia, two ships engaged each other in battle &mdash; the German *Kormoran* one and the Australian HMAS *Sydney*. The final outcome of the battle was that [both ships were destroyed](https://en.wikipedia.org/wiki/Battle_between_HMAS_Sydney_and_German_auxiliary_cruiser_Kormoran).

> How and why *Sydney* was sunk by the weaker *Kormoran* has been the subject of speculation and controversy, with numerous books on the subject, along with government inquiries published in 1999 and 2009. According to the German accounts, which were accepted as truthful by their interrogators and most subsequent commentators, the cruiser sailed too close to the disguised merchant raider, negating the advantages of armour and superior gun range, and was destroyed by heavy fire and a torpedo strike after *Kormoran* revealed herself.

There's a lot of nifty details about the signaling before the battle, which I will not relay here. But here's one thing I didn't know before: you have to [flag that you're going into battle](https://en.wikipedia.org/wiki/Battle_ensign) according to international laws of war (and there is speculation whether the Germans really did this). To me as an outsider, it seems like a surprisingly honest thing to have to do in a battle situation.

Seeking to patch up `.trans` to handle regexes today, I failed in unexpected and interesting ways.

Having distracted myself during `$dayjob` with thoughts of how to go about implementing regexes in `.trans`, I finally dug into the task in the evening. This is what I had concluded while just thinking about it:

- Need to store the regexes in a data structure just like a store the constant strings to be replaced.
- But I can't hash the regexes, since we can only have `Str` as hash keys right now in Rakudo. No worries, an array works in this case.
- There will be some special logic in the main loop that determines whether to do a constant string replacement or a regex replacement.


This is what I learned by implementing it:

- Huh, need to store three pieces of information for each regex: the regex, its substitution, and the position of the next match. (Since this is how my new `.trans` algorithm operates: it [keeps all the "next match" positions up to date](November-7-2010-man-we-suck-at-this.html) for all things it's matching on.) Ended up with an array of pairs, the keys of which were also pairs. Hello, `cadr`.
- Since the constant strings and the regexes were in different data structures, a fair amount of code was needed to bring out the first matching position for each of them, and then compare them to determine whether to do a string or regex substitution.
- Even that's an oversimplification. What happens if there are two or more regexes matching on the same position? The answer is that the longest regex should win. If they still tie, I guess the earliest one should win. Huh. Good thing I stored them in an array.
- Need to go in positionally and update the first-match position information for the regex array. Which means I have to *find* the element for the corresponding regex. Oh man, this is primitive!
- Wait, what happens if a constant string ties with a regex match? We need to compare their lengths. And if they still tie? Uuurgh...

The last guttural sound there was me giving up due to an exceptional amount of minutia that I hadn't anticipated in the design phase. ☺

*TimToady*++ on the channel understood immediately what the trouble might be.

```
<masak> today, I've tried to patch .trans for handling regexes.
        giving up for the day -- it was more complicated than I
        imagined it would.
<masak> time to blog about the unexpected overwhelm fail. :)
<*TimToady*> masak: that will be very difficult unless you know how to
           hook into the LTM implied by .trans
<masak> *TimToady*: yeah.
<*TimToady*> espcially since rakudo doesn't really do LTM yet
<masak> *TimToady*: the current .trans impl does it right for constant
        strings.
<jnthn> The current Rakudo does LTM right in some cases for constant
        strings. :)
<masak> *TimToady*: but... I found I had to special-case regexes, and
        then there were a lot of "interesting" corner cases across
        the boundary.
<masak> I think I'd be better off attacking the problem after hiding
        some of that complexity first.
<masak> essentially runtime-polymorphing on constant strings and regexes.
```

And that, in a nutshell, is what I intend to do if-and-when I attack this problem again. Need to build a little LTM engine that hides the complexity of handling both constant strings and regexes in the key position of the pairs sent in to `.trans`.

That should take care of another problem I had with the code: it wasn't fun to read. Putting an LTM engine as an API between the `.trans` code and the complexity should help.
