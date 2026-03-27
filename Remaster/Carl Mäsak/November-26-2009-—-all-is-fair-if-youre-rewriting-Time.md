# November 26 2009 — all is fair if you're rewriting Time
    
*Originally published on [26 November 2009](http://strangelyconsistent.org/blog/november-26-2009-all-is-fair-if-youre-rewriting-time) by Carl Mäsak.*

> 70 years ago today, as far as we can tell through the mists of history, the Soviet Union, looking for a fight with Finland, [shelled one of its own villages](https://en.wikipedia.org/wiki/Shelling_of_Mainila) near the Finnish border:

The Soviet Union had signed international and mutual nonaggression treaties with Finland: the Treaty of Tartu of 1920, the Non-aggression Pact between Finland and the Soviet Union signed in 1932 and again in 1934, and further the Charter of the League of Nations. The Soviet government attempted to adhere to a tradition of legalism, and a *casus belli* was required for war. [...]

Seven shots were fired, and their fall was detected by three Finnish observation posts. These witnesses estimated that the shells detonated approximately 800 meters inside Soviet territory. Finland proposed a neutral investigation of the incident, but the Soviet Union refused and broke diplomatic relations with Finland on November 29.

In the days following the shelling, the Soviet propaganda machine generated much noise about other fictitious acts of Finnish aggression. The Soviet Union then renounced the non-aggression pact with Finland, and on November 30, 1939 launched the first offensives of the Winter War.

Does the maxim 'all is fair in love and war' apply even if the war is orchestrated by your country's propaganda machine? (My office-mate claims it never applied universally to begin with.)

Today, as I [predicted](November-24-2009-a-sort-of-leap-of-faith.html) earlier this week, is Themporal Thursday! And, fittingly, today I [got leap years working](https://github.com/masak/rakudo/commit/2b43fb151c32df5fb2babd24af1d868412c0bc00). Yay!

There are plenty of off-by-one mismatches occurring naturally when handling dates. I decided that I like my months and days to start with 1, but I also like my arrays to start indexing at 0. So there's some addition and subtraction of 1 going on in places where I convert between months and indices. But I think that's preferrable to the alternatives.

I made a lot of false starts. In what probably constitutes a valuable lesson, I didn't get day-and-month calculation right until I actually paused for a while and thought about what I wanted, wrote a comment to explain to myself what I was doing, and finally wrote the code. It worked!

I also started in on the [time parsing](https://github.com/masak/rakudo/commit/5c4c821dd2f9583841e26f128f847f7a9d20e786). Still need to figure out how I will get hold of today's date; probably need to calculate it the hard way, from ``time``.

Once again, the tests were an invaluable help, *sine qua non*. Thank you, tests!

The month is nearing its end, and I feel about halfway done with the Temporal Flux project. More concretely, I've done a few sessions during November, and I'll probably need two more sessions to get the time parsing right, one or two sessions to make sure things fit together, and then one session to write it all up, make a *coup d'etat* and check everything in, and write to `p6l` about it. I hope I'll find the requisite hours to do that during December.
