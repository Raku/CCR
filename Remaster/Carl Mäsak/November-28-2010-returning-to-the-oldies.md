# November 28 2010 — returning to the oldies
    
*Originally published on [29 November 2010](http://strangelyconsistent.org/blog/november-28-2010-returning-to-the-oldies) by Carl Mäsak.*

> 199 years ago today, the first performance of Ludwig van Beethoven's last piano concerto &mdash; No. 5 in E-flat major, but popularly known as the ["Emperor Concerto"](https://en.wikipedia.org/wiki/Piano_Concerto_No._5_(Beethoven)) &mdash; premiered.

> As music's Classical era gave way to its Romantic era, composers began experimenting with the manner in which one or more solo instruments introduced music. Beethoven had already explored such possibilities in his Piano Concerto No. 4, but the monumental piano introduction in Piano Concerto No. 5 - it lasts for nearly two minutes - foreshadowed future concerti such as Mendelssohn's Violin Concerto or Tchaikovsky's Piano Concerto in B-flat minor.

I'm listening to the piano concerto now, as I write this. The music is familiar, yet very enjoyable.

I don't know what I like more, the delightful play with harmonies in the performance, or the posh (but entirely correct) usage of the plural form *concerti* in the Wikipedia article. I have a weak spot for musician lingo.

Today I tackled the Hitomi tests. In all honesty, it doesn't appear like they've ever been tackled that way before. Which is odd, because there's a lot of them.

I did one first pass over the test files making sure they at least compiled. The I did another pass `todo`ing and `skip`ping things. Now the whole `t/hitomi` folder [shows PASS](https://github.com/masak/web/commit/886dde7be88162711ec271cd222725c0495316a1) for, I think, the first time ever.

In retrospect, I'm not sure why I spent so much time porting test files and then didn't make sure that they ran properly. That doesn't square at all with my current TDD practices. On the other hand, `t/hitomi/05-input.t` gave the impression of being TDD'd on at least up until test 13. Still, it's odd by my current standards.

Routes, Astaire and Squerl would benefit from similar treatment. I think those will be easier than Hitomi.
