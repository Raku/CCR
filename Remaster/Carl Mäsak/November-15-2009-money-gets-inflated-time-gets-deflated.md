# November 15 2009 — money gets inflated, time gets deflated
    
*Originally published on [16 November 2009](http://strangelyconsistent.org/blog/november-15-2009-money-gets-inflated-time-gets-deflated) by Carl Mäsak.*

> 86 years ago today, [the Rentenmark was introduced](https://en.wikipedia.org/wiki/German_Rentenmark) in Germany to replace the old, worthless currency:

> The Rentenmark replaced the Papiermark. Due to the economic crises in Germany after the Great War there was no gold available to back the currency. Therefore the Rentenbank, which issued the Rentenmark, mortgaged land and industrial goods worth 3.2 billion Rentenmark to back the new currency. The Rentenmark was introduced at a rate 1 Rentenmark = 1:10^12 Papiermark, establishing an exchange rate of 1 United States dollar = 4.2 RM.

Now, that's an impressive exchange rate. Hm, [hyperinflation](https://en.wikipedia.org/wiki/Hyperinflation). Now, that sounds like a possibly interesting Wikipedia article:

- By late 1923, the Weimar Republic of Germany was issuing two-trillion Mark banknotes and postage stamps with a face value of fifty billion Mark. The highest value banknote issued by the Weimar government's Reichsbank had a face value of 100 trillion Mark (100,000,000,000,000; 100 billion on the long scale). One of the firms printing these notes submitted an invoice for the work to the Reichsbank for 32,776,899,763,734,490,417.05 (3.28×10^19, or 33 quintillion) Marks.<li>The largest denomination banknote ever officially issued for circulation was in 1946 by the Hungarian National Bank for the amount of 100 quintillion pengő (100,000,000,000,000,000,000, or 10^20; 100 trillion on the long scale). image (There was even a banknote worth 10 times more, i.e. 10^21 pengő, printed, but not issued image.) The banknotes however didn't depict the numbers, "hundred million p.-pengő" ("hundred million billion pengő") and "one milliard p.-pengő" were spelled out instead. This makes the 100,000,000,000,000 Zimbabwean dollar banknotes the notes with the greatest number of zeros shown.<li>The Post-WWII hyperinflation of Hungary held the record for the most extreme monthly inflation rate ever — 41,900,000,000,000,000% (4.19 × 10^16%) for July, 1946, amounting to prices doubling every thirteen and half hours. By comparison, recent figures (as of 14 November 2008) estimate Zimbabwe's annual inflation rate at 89.7 sextillion (10^21) percent. which corresponds to a monthly rate of 5473%, and a half-life of about five days.

Yikes. About the only time you do not want to see lots of zeros on your banknotes is when everyone else has them, too.

Today I'm well-rested, but I wasted much of my allotted time writing other stuff. Since I don't have time to do anything big, I'll fix a small thing that has annoyed me in the last couple of days: after I [went and deleted the `Makefile.PL` from November](November-9-2009-stuff-comes-tumbling-down-yay.html), the nightly smokes have been coming out wrong. So I went looking for the error.

It wasn't a big error. The build script needed to stop try and run that `Makefile.PL`, and there was a local change in the `Makefile.PL` itself, which prevented git from automatically removing it. After fixing these two things, I again have green-and-clean test reports.

Now if I could only find the time to dig into *lichtkind*++'s bugs. That last one, [with the login problem](November-11-2009-nobody-said-it-was-going-to-be-easy.html), was kinda fun in retrospect.
