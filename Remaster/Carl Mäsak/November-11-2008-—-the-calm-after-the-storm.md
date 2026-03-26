# November 11, 2008 — the calm after the storm
    
*Originally published on [11 November 2008](http://strangelyconsistent.org/blog/november-11-2008-the-calm-after-the-storm) by Carl Mäsak.*

90 years ago today, at eleven in the morning, World War I ended. [Wikipedia](https://en.wikipedia.org/wiki/World_War_I#End_of_war):

> Following the outbreak of the German Revolution, a republic was proclaimed on 9 November. The Kaiser fled to the Netherlands. On 11 November an armistice with Germany was signed in a railroad carriage at Compiègne. At 11 a.m. on 11 November 1918 — the eleventh hour of the eleventh day of the eleventh month — a ceasefire came into effect. Opposing armies on the Western Front began to withdraw from their positions. Canadian George Lawrence Price is traditionally regarded as the last soldier killed in the Great War: he was shot by a German sniper and died at 10:58.

Started actually implementing the MediaWiki markup parser today. Fun work.

Almost immediately I ran into [a strange bug](https://github.com/Raku/old-issue-tracker/issues/405) in Rakudo. Apparently, strings lose their Rakudohood when passed through PGE — for example by a call to `.split`.

I should do this more often. Write actual code, I mean. Even when I run into bugs, it feels like I'm accomplishing something.

Will be back tomorrow, hopefully with an adequate workaround.
