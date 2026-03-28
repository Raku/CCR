# November 10 2010 — why don't you bottom-up?
    
*Originally published on [11 November 2010](http://strangelyconsistent.org/blog/november-10-2010-why-dont-you-bottom-up) by Carl Mäsak.*

> 3 years ago today at the Ibero-American Summit, the Spanish king told the Venezuelan president to [shut up](https://en.wikipedia.org/wiki/%C2%BFPor_qu%C3%A9_no_te_callas%3F). Ok, this takes some explaining.

> At the meeting on 10 November 2007, Chávez repeatedly interrupted the speech of the Spanish Prime Minister, José Luis Rodríguez Zapatero, to call the Prime Minister's predecessor, José María Aznar, a "fascist" and "less human than snakes," [...] Although organizers switched off Chávez's microphone, he continued to interrupt as Zapatero defended the former Spanish Prime Minister. King Juan Carlos I leaned forward, turned towards Chávez, and said "¿Por qué no te callas?" ("Why don't you shut up?")

Of course, it's almost a diplomatic incident when one head of state asks another, in front of cameras and everything, to shut up. Even if the one getting rebuked is acting like a spoiled brat.

> It was noted that he addressed Chávez using the familiar form of "you," which in Spanish is usually reserved either for close friends, family, or children--and that Juan Carlos I was addressing his fellow head of state Chávez as if he were an insolent child.

As a phrase, "¿Por qué no te callas?" gained a bit of a following.

> The phrase became an overnight sensation, gaining cult status as a mobile-phone ringtone, spawning a domain name, a contest, T-shirt sales, and YouTube videos. [...] Entrepreneurs in Florida and Texas put the slogan on T-shirts, and marketed them on eBay and elsewhere; the phrase has become a greeting among Venezuelan expats in Miami and Spain and a slogan for Chávez opponents. In Spain an estimated 500,000 people have downloaded the phrase as a ringtone, generating €1.5 million (US$2 million) in sales.

Here's a video of [the event itself](https://www.youtube.com/watch?v=X3Kzbo7tNLg). Here's [BBC News' take on it](https://news.bbc.co.uk/2/hi/americas/7089131.stm). And here's Know Your Meme's.

Today I meant to dig into [the book](https://github.com/Raku/book) and give it a good read-through, taking notes. I had it open in one of my browsers, and everything. Everything was just right. [Conditions were perfect.](https://www.youtube.com/watch?v=WGOohBytKTU)

But then I managed to distract myself. *patrickas*++ showed up with an enthralling [piece of SIC](https://gist.github.com/patrickas/671554) that he had hand-translated from a short piece of Raku I had mentioned the other week. The Raku is an example of closures, something that Yapsi doesn't implement fully yet.

We both tried running the SIC code (bypassing the compiler). It worked! I guess this surprised us both. That means Yapsi has the requisite support for basic closures, it's just that the compiler can't generate the SIC that the runtime already runs fine.

So why not just add the functionality to the compiler? Ah, but there's the rub. And that's where the rest of my time tonight went.

Yapsi has gone through one rewrite already. The first version of the compiler used multimethod dispatch to traverse the parse tree top-down and generate the SIC. Result: lots of small methods, all unaware of each other.

The rewrite went in the other direction: it separates the traversal logic into subs (`traverse-top-down` and `traverse-bottom-up`), and then does all the specific SIC generation in callbacks to those subs. Result: one big callback with a long `if ... elsif ... else` comb.

The new code *looks* scarier and messier than the old code, but it's also more expressive and, in a way, more self-aware. It brought Yapsi further than the old code would. That said, I don't much like the way it looks, and I hope that the compactness and obscurity it currently embodies is a passing phase.

Anyway &mdash; and this is why it's not trivial to add closures &mdash; there are recursive traversal calls inside the big callback, and those calls carry a `@skip` argument, telling the traversal logic which nodes to ignore. Among those nodes are `block` nodes (probably because nested blocks would otherwise end up in each other's generated code). But this blanket ignoring is unfortunate when we start wanting to pay attention to closures in the code.

...something like that. It's not all clear to me yet. I'm hoping that by cramming all of the gory details into my head and then going to sleep, I might wake up tomorrow with a nice solution in my head. Preferably neatly indented.
