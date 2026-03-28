# November 3 2010 — reform and improvement
    
*Originally published on [3 November 2010](http://strangelyconsistent.org/blog/november-3-2010-reform-and-improvement) by Carl Mäsak.*

> 75 years ago today, the Nationalist government in the Republic of China instituted a [fiat currency](https://en.wikipedia.org/wiki/Fiat_currency) reform, immediately stabilizing prices and also raising revenues for the government.

> Great strides also were made in education and, in an effort to help unify Chinese society, in a program to popularize the Standard Mandarin language and overcome other Spoken Chinese variations. Newspapers, magazines, and book publishing flourished, and the widespread establishment of communications facilities further encouraged a sense of unity and pride among the people.

And then the [war against Japan](https://en.wikipedia.org/wiki/Sino-Japanese_War_(1937-1945)) happened, unfortunately. And then the [Civil war](https://en.wikipedia.org/wiki/Chinese_Civil_War), which by the way [never officially ended](https://en.wikipedia.org/wiki/Cross-Strait_relations). So here we are, half a century later, unsure just how many Chinas there are.

I'm in Austria, severely distracted by the beauty of the Vienna. For those of you who have been following my relationship with Austria over the years, I'll just add that I'm not here in capacity of author of `proto`, I'm here because we're attending the premiere of a documentary in which my mother figures as one of the key characters. Way to go, mom!

Today I toyed around with the idea of making `psyde` more efficient. I'll step back a few steps to explain what this means.

`syde` is the name of the application that generates static HTML for my blog. Right now, *all* it can do is generate my blog; when I'm done generalizing it, it's supposed to be capable of generating any static web page one tells it to.

Also &mdash; and this will probably sound a bit insane &mdash; every time I run `psyde`, it nukes my current local copy of the static web site, and generates a brand new one. That takes on the order of seven minutes. Now, most pages won't change from one such run to the next. `psyde` currently doesn't care; it just nukes it all and generates it from scratch. Not good.

So what would be a better option? Well, something akin to the ways `Makefile`s work would be neat. And in fact, this is exactly the problem Hakyll solves, the piece of software `psyde` is based on. Hakyll uses Kleisli arrows (a data structure similar to monads) to keep track of dependencies and what needs to be updated. I meant to do something similar in `psyde`, I just haven't gotten around to it yet.

But today I've toyed a bit with the idea, locally. Maybe tomorrow I'll even have enough working code to attempt to put it in `psyde` itself. It'll be interesting to see how much the run time goes down.
