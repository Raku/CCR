# November 11 2010 — avAST!
    
*Originally published on [12 November 2010](http://strangelyconsistent.org/blog/november-11-2010-avast) by Carl Mäsak.*

> 2 years ago today, the Royal navy [engaged a bunch of Somalian pirates](https://en.wikipedia.org/wiki/November_11,_2008_incident_off_Somalia).

> The Times has described the incident as "the first time the Royal Navy had been engaged in a fatal shoot-out on the high seas in living memory."

It is only now that I truly realize what an impact [Johnny Depp](https://en.wikipedia.org/wiki/Jack_Sparrow) has had on my view of pirates. And the concept "piracy" is hopelessly hijacked by the likes of RIAA. ☹

Further discussions with *patrickas*++ today. I'm not getting any code written, but feeling productive nonetheless.

I started by going through all the traversals that the compiler makes. Just explaining it exposed a number of potentially weak spots in the design. The problem with closures that we're having is an interesting one; expressions are traversed bottom-up, but the knowledge about which blocks should be immediate needs to trickle top-down. We're still mulling over that one.

Also, we've made initial plans to create an abstract syntax tree format for Yapsi. Maybe it'll help us solve the current problem we're having with closures; then again, maybe not. There are other potential benefits with having a format sitting between the parse tree and SIC, too. Most of these will become evident as we progress with Yapsi design. The syntax tree format hasn't been nailed down yet, but patrickas and I have decided to name it FUTURE, for reasons which I hope are obvious.

Originally not much more than an April Fool's joke, Yapsi seems to be doing quite well.
