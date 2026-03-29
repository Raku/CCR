# After the #masakism workshop
    
*Originally published on [5 May 2013](http://strangelyconsistent.org/blog/after-the-masakism-workshop) by Carl Mäsak.*

On May 1st I learned what happens if you tell a bunch of people on the
Internet, not all of whom you've met before, that you're going to teach Perl (5
and 6) for free on an IRC channel for four hours.

It worked well. Actually, it worked well beyond my expectations.

## Successes

- **Prepare.**

I had written a bunch of material; short-ish texts mixed with
exercises. I didn't hear any feedback about the texts, but people threw
themselves on the exercises. Which was lucky, because I basically didn't
have time to interact much with people. Everyone did their own thing.

- **Map.**

The week before the workshop, I was taking a walk, and it occurred
to me that the topics for the workshop should be laid out on a *subway map*.
That turned out to work unexpectedly well. People followed the structure,
I think. The material was pretty clear that they were free to skip/jump
around if they wanted, so some did that.

- **Github.**

People suggested fixes and improvements to the material during
the workshop. I handled the easy ones, and delegated what could be delegated.
If anything about the workshop felt 2013-futuristic, it was the fact that
participants were hacking on the workshop *in real time*, as it was being
played out. Github was totally right for this.

- *tadzik*++ did an exercise and got a solution that I didn't expect.

We agreed that a test was missing to force people to do the right thing,
so he went ahead and added it.

- *LlamaRider*++ added hyperlinks between all the files.
- *grtodd*++ made the subway map clickable.
- *choroba*++ added hyperlinks to a file that I added later.

## Things learned

- **Newbies.**

This was never a workshop for total beginners. Still, we got
a number of those. I'm not sure how many. If there's a next time, I'll
want to add a track for the people who haven't done Perli or Raku before.

- **Exercises.**

Based on the tasks that people [actually
solved](https://gist.github.com/masak/5496294), I got a
lot of feedback on what worked and what didn't. Which exercises served the
overall message of the course, and which ones didn't.

- **Message.**

After the workshop, I know much better what I *wanted* the
whole thing to be about. I think I can go back and make that even more
clear. I'm still surprised at how well it worked already the first time
around... but some bits in there can certainly be improved.

## Message

So... what was the real message of the workshop? What is "masakism"?

Two things:

- **Testing gets you far.**

- My pain threshold for writing things without tests is half a screen of
code. If I have more than that, there's probably something I should
be writing tests for.

- That said, there's no need to be a fundamentalist about anything. I'm
just saying that tests are good, and still somewhat undervalued
sometimes. But it's always a question on spending time testing the
stuff that matters. Of course.

- Even with tests, there's no substitute for knowing what you're doing
and where you're going. Tests help a lot, but they don't write the
program for you.

- **Keep it small and simple.**

- "Inside every big interesting problem is a small interesting problem,
struggling to get out."

- The realization that you can write objects that focus *entirely* on
your core problem, is a strong one.

- People tend to bring in persistence too early, "polluting" their core
classes with database code. Hindering testability. This is backwards.

- Your program should be like an onion, with the most precious stuff
in the middle, and layers around that. Outer layers should point to
inner layers, but not vice versa.

## Once more?

So, should we do another `#masakism` workshop?

Yes, maybe we should. People seemed to like this first one. I'm open to finding
a datetime for another one.

If you have any suggestions, get in touch.
