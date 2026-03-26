# November 17, 2008 — it's a small step for a robotic dog...
    
*Originally published on [18 November 2008](http://strangelyconsistent.org/blog/november-17-2008-its-a-small-step-for-a-robotic-dog) by Carl Mäsak.*

38 years ago today, the Soviet Union put the first remote-controlled robot on another world. The other world was the Moon, and the robot, 13 years before Michael Jackson's dance, was called [Lunokhod](https://en.wikipedia.org/wiki/Lunokhod_1) (Луноход), *moon walker*.

It looks a bit like a [robot dog](https://en.wikipedia.org/wiki/K-9_(Doctor_Who)) from a budget-impaired sci-fi series; the Russians seem to have had a thing for [sending dogs into space](http://en.wikipedia.org/wiki/Laika).

Beyond its looks, I find nothing extraordinary about the robot itself, but I like other parts of the [Lunokhod programme](https://en.wikipedia.org/wiki/Lunokhod_programme):

> In summer 1968, at the KIP-10(КИП-10) in the secret village of Shkolnoye, near Simferopol, a lunodrom (moondrome) was built. It covered an area of one hectare (120 meters by 70 meters) and was very similar to some parts of the lunar surface. It was constructed using more than 3,000 cubic meters of soil, and included 54 craters up to 16 m in diameter and around about 160 rocks of various sizes. The whole area was covered with bricks, painted in gray and black. It was used to analyze problems with the Lunokhod chassis.

Sounds like a nice place for a vacation. I like that word: "lunodrom".

Hokay, so today I implemented the rest of the heading parsing, the one with the mixed headings and ordinary text. I discovered a Rakudo bug along the way, which I [reported](https://github.com/Raku/old-issue-tracker/issues/413). For some reasons, I keep finding bugs which aren't really bugs but turn out to be things I missed or overlooked. It's no big deal, just a bit annoying.

I'm kind of pleased with the way the [MediaWiki.pm](https://github.com/viklund/november/tree/76e0339f4865e32140b7f0c29fc061c9740f8f48/p6w/Text/Markup/Wiki/MediaWiki.pm) code turned out as a result of today's hacking. Yesterday, it was one lumpy method that did all the work, but today, things naturally fell out into their own methods. It wasn't even a question of refactoring, they just... did. The code looks much lighter now, with the main action taking place in a method called `format_line`. That's to be expected, since in the end the MediaWiki markup is line-based.

(I know that today is Monday, and that Mondays were supposed to be Skin Mondays, and that this third Monday I've still only begun on my first skin. I might remind the readers who are very upset about this fact that this blog has a money-back guarantee. I'll start looking for another day in the week to make skins; Mondays turned out to be really unsuitable for that kind of deep-concentration work.)

That's all. Now go out and look at the [Leonids](https://en.wikipedia.org/wiki/Leonids), all of you.
