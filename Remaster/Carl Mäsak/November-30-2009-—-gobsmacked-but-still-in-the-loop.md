# November 30 2009 — gobsmacked but still in the loop
    
*Originally published on [1 December 2009](http://strangelyconsistent.org/blog/november-30-2009-gobsmacked-but-still-in-the-loop) by Carl Mäsak.*

> 55 years ago today, a meteorite struck [a radio and then a woman](https://en.wikipedia.org/wiki/Sylacauga_(meteorite)).

The Sylacauga meteorite fell on November 30, 1954 at 2:46pm (18:46 U.T.) on the town of Sylacauga, Alabama.

It is often improperly called the Hodges Meteorite, which was a fragment of the meteorite. The Hodges Meteorite is the first documented extraterrestrial object to have injured a human being. It was a grapefruit-sized fragment of the Sylacauga meteorite which fell on November 30, 1954. It crashed through the roof of a frame house in Oak Grove, Alabama, bounced off a large wooden console radio, and hit Ann Elizabeth Hodges (1923-1972) who was napping on a couch. The 31 year old woman was badly bruised on one side of her body but able to walk. The event received worldwide publicity.

Whoa! Shame about the bruising, but... I don't know, there's something about being the only (documented) human having been injured by an extraterrestrial object that sounds both profoundly meaningful and slightly silly, without really being either. In a cosmos where the stars and the powers-that-be seem aloft and unconcerned, *one* piece of interstellar rock zones in on Alabama, Earth, *burning* as it rubs against the atmosphere...

The meteor made a fireball visible from three states as it streaked through the atmosphere, even though it fell early in the afternoon.

...crashing through the roof of a house, bouncing off a frackin' wooden *radio*, and finally colliding with aforementioned Ann Hodges. I mean, I... wow.

As if that wasn't enough, then there's the legal aftermath, and the obligatory greed.

The United States Air Force sent a helicopter to take the meteorite. Eugene Hodges, the husband of the woman who was struck, hired a lawyer to get it back. The Hodges' landlord, Bertie Guy, also claimed it, wanting to sell it to cover the damage to the house. There were offers of up to $5,000 for the meteorite. By the time it was returned to the Hodgeses, over a year later, public attention had diminished and they were unable to find a buyer willing to pay much money.

Ann Hodges was uncomfortable with the public attention and the stress of the dispute over ownership of the meteorite. Against her husband's wishes, she donated it to the Alabama Museum of Natural History where it is displayed at the University of Alabama in Tuscaloosa.

Good call.

```
<masak> last day of November blogging, and I have no idea what to do for the Raku part.
<mberends> masak, one question for you, are you still in a strange TDD loop on crack?
<masak> mberends: yes, but I haven't pushed any of the code yet.
<masak> mberends: much of GGE was developed with that TDD framework.
<masak> no wait; all of it, in fact.
<mberends> maybe blog about your progress there
<masak> hm, yes.
<masak> time is running out for actually _doing_ anything today anyway.
```

What *mberends*++ is referring to is [tote](Helpfully-addictive-tdd-on-crack.html). I already wrote a lengthy [second post](Some-thoughts-on-tote.html) on it, but it was so tl;dr, that even I didn't read it afterwards.

So I'll just summarize that post here, in a (hopefully) more digestible form.

- Yes, tote works. Frighteningly well. I've used it for over a month now.
- What makes it work is the voice. I have a Mac with a built-in synthesizer, and it says "back to coding" when I didn't pass more tests than last time, and "checkpoint! oh yay!" when I did. Those messages make me more diligent and irrationally happy, respectively. It's like the computer is sharing in my woes and joys of implementing stuff.
- The reason the voice is needed is something I found out after starting to use the framework. Running tests takes so much time that the mind (my mind, at least) starts to wander. Usually, I pull up the browser to read one of my many tabs. It breaks my whole initial idea of an immersive experience, but I'm not sure what to do about that, or even whether it's wrong. The voice pulls me back.
- I haven't released any Raku code yet, because the framework I'm using is (for no good reason, really) in Perl, and I plan to re-implement it 'the right way' in Raku, which has been pretty crippling so far. 'The right way' includes making a small testable core of the [workflow functionality](https://github.com/masak/tote/blob/master/diagram/tote-workflow.png), and having everything else be pluggable. Someone needs to get me started on that, and it's probably me.
