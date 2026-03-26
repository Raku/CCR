# November 27, 2008 — it's just a fleshwound
    
*Originally published on [28 November 2008](http://strangelyconsistent.org/blog/november-27-2008-its-just-a-fleshwound) by Carl Mäsak.*

74 years ago today, Lester Joseph Gillis aka [Baby Face Nelson](https://en.wikipedia.org/wiki/Baby_Face_Nelson) had a little running machine gun shootout with the FBI, and died from 17 bullets. [Wikipedia](https://en.wikipedia.org/wiki/Baby_Face_Nelson#The_Battle_of_Barrington):

> The battle began when Nelson, Helen Gillis, and John Paul Chase were driving down a road and saw a police car driving the opposite direction. Nelson hated police and federal agents and used a list of license plates he had compiled to actively hunt them at every opportunity. He apparently recognized the car and decided to chase them. Once they both stopped, the shootout started. Nelson's wife and Chase used their car for cover. Nelson, however, simply walked towards the agents, reportedly shouting, "I'm gonna kill you sons of bitches!". After the fight was over, Nelson nearly collapsed on the ground from his wounds; he'd been shot 17 times. Gillis and Chase helped Nelson into the car of the two FBI agents, and with Nelson giving directions, Chase drove away from the scene.

> The next morning, another team of FBI agents was dispatched to the scene to investigate the situation. They found the bodies of the two agents who had been killed in the skirmish the day before. The new team scouted the area for any possible signs of Nelson. Following an anonymous telephone tip, Nelson's body was discovered in a ditch, wrapped in a blanket. The ditch was in front of St. Peter Catholic Cemetery in Skokie, which still exists today. His wife later stated that he had died of his wounds at exactly 8 p.m. She had placed the blanket around his body because, as she said, "Lester always hated to be cold..."

I fixed the first of the two remaining errors from yesterday, namely `is_deeply` in `Test.pm`. Turns out the failures were actually very reasonable, and had either always been there, or were the consequence of improvements to Rakudo.

Two of the failures concerned hashes and arrays (respectively) of unequal size. The `is_deeply` sub traversed these using [the `Z` operator](https://github.com/Raku/old-design-docs/blob/master/S03-operators.pod#line_1555), and as we all know, the `Z` operator goes no further than the shortest list when zipping things together.

Actually, "as we all know" is likely a great exaggeration. I, for one, had to ask on #raku:

```
<masak> so the correct behaviour of @a Z @b is to stop as soon as one of the arrays run out, yah?
<wayland76> masak: re: @a Z @b -- yes, documented in S29
<wayland76> (as "zip")
```

The third failure happened because two `undef`s tested as unequal to each other. This is actually not that unreasonable in some situations, but for now I made them test equal instead. Partly because I think that's what's expected in this particular situation; partly because the test said so.

All tests now pass in the master branch. Yay!
