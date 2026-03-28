# November 14 2010 — around and about
    
*Originally published on [14 November 2010](http://strangelyconsistent.org/blog/november-14-2010-around-and-about) by Carl Mäsak.*

> 122 years ago today, reporter [Nellie Bly](https://en.wikipedia.org/wiki/Nellie_Bly) embarked on a journey around the world, attempting to turn the fictional *Around the World in Eighty Days* (published 15 years prior) into fact.

> On her travels around the world, she went through England, France (where she met Jules Verne in Amiens), Brindisi, the Suez Canal, Colombo (Ceylon), Hong Kong, the Straits Settlement of Penang and Singapore, and Japan. The development of efficient submarine cable networks and the electric telegraph allowed Bly to send short progress reports, though longer dispatches had to travel by regular post and were thus often delayed by several weeks.

I know "delayed by several weeks" must seem like an absurd concept for people growing up in the Age of the Tweet.

Anyway, she made it. [72 days](https://en.wikipedia.org/wiki/Around_the_World_in_Seventy-Two_Days). *Nellie*++.

As of today, it's possible to call closures in Yapsi. This thanks to the pioneering work done by *patrickas*++, the few gaps of which I helped fill in some hours into the night last night.

The work turned out to decompose into two steps:

- First we made the parser distinguish between [non-immediate and immediate blocks](https://github.com/masak/yapsi/commit/dd03f5893c29ac35b784ff7c6a76a301ba1f746d). We used to have only the latter kind; now we only consider statement-level blocks immediate.
- Then we added the ability to [call a closure](https://github.com/masak/yapsi/commit/706d5f6109e419aedae3e48f4cb9c5868a0efc92). Voilà!

This is good news, because this lays the groundwork for subroutines in Yapsi, a big milestone. In fact, I'm going to go attempt subroutines now.
