# November 6, 2008 — making waves
    
*Originally published on [7 November 2008](http://strangelyconsistent.org/blog/november-6-2008-making-waves) by Carl Mäsak.*

73 years ago today, electrical engineer slash inventor Edwin Armstrong presents his paper "A Method of Reducing Disturbances in Radio Signaling by a System of Frequency Modulation" to the New York section of the Institute of Radio Engineers. The impact of this man's work is perhaps best explained by this quote from InventorSpot:

> Because of his [Armstrong's] work, FM radio is the preferred format for broadcast music, while the AM band has largely been relegated to the realm of news and talk. Because of pioneering work performed by Armstrong we also have access to other commonly used technologies like television, radar, and cellular telephony.

Not bad.

Today I added the `.fmt` method to S29, the comprehensive-to-be listing of all the built-in functions in Raku. S29 is partly incomplete and outdated, and would benefit from much attention from people with spare tuits.

The problem is that adding stuff to S29 requires hard-won knowledge. That's why S29 exists, to summarize info about functions which might not be found elsewhere. For example, *moritz*++ pointed me to [t/spec/S02-names*and*variables/fmt.t] which tests various aspects of `.fmt`. After I'd made my commit, I noticed that those tests actually assume that the second argument can be omitted in the `Array::fmt` variant. That detail wasn't to be found anywhere in the Specs (I looked), but since I think it's a good idea, I'll make a change to reflect this in S29.

The difficulty thus consists not in realizing what needs to be done, but in collecting and assessing all the minute details about every function, and figuring out what is hard fact and what is opinion, what is outdated or deprecated. Luckily, the #raku gang very often provides in cases like this, making the whole experience much easier. Or at least being there for you when it isn't.

```
<jnthn> masak: Having the various roles like Positional and stuff in there would be good too.
<masak> jnthn: I'll put it on my list which I just made.
<moritz_> masak: and when you are at it... many methods now actually live in Any, not in Str|List|Complex|$Whatever...
<masak> moritz_: yes, that's true. that goes on the list too.
<moritz_> masak.list.*elems*++ ;-)
```

Oh my. I think I just made myself S29 wrangler, too.
