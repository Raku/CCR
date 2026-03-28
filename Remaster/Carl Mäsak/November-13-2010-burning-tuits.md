# November 13 2010 — burning tuits
    
*Originally published on [14 November 2010](http://strangelyconsistent.org/blog/november-13-2010-burning-tuits) by Carl Mäsak.*

> 35 years ago today, the steamship [*Yarmouth Castle*](https://en.wikipedia.org/wiki/SS_Yarmouth_Castle), on a pleasure cruise from Miami to the Bahamas, caught fire and sank.

> Shortly before 1:00 a.m. on November 13, a mattress stored too close to a lighting circuit in a storage room, Room 610, caught fire. The room was filled with mattresses and paint cans, which fed the flames.

The ship was made of wood, and was freshly painted, so the fire spread quickly.

> More problems ensued. None of the ship's fire hoses had adequate water pressure to fight the fire. One of the hoses had even been cut. Crewmen also had difficulty launching the lifeboats. The ropes used to lower the boats had been covered in thick coats of paint, causing them to jam in the winches. Even the boats that were successfully lowered had no oarlocks, and had to be paddled like canoes. By the end, only six of the 13 lifeboats were launched.

87 people went down with the ship, and three later died while treated at hospitals. The disaster brought on changes in the international [Safety of Life at Sea](https://en.wikipedia.org/wiki/International_Convention_for_the_Safety_of_Life_at_Sea) law. One of the changes was "do not build passenger ships out of wood".

I've been here and there today, nibbling at stuff. Did a little more work on pls, cleared out my queue of pending rakudobugs, and [patched](https://github.com/rakudo/rakudo/commit/015d77b6bee35955d66a35f9e45e16c15c91b7b0) an LTA error message in Rakudo.

But the chunk of "actual" November work today was restoring Shrdlu to the living. The [commit](https://github.com/masak/shrdlu/commit/ad72e6fe90a6567e7d4c32023ce1b63b0eb0c471) summarizes what needed doing:

- Can't assign to a variable that contains `*`. (I submitted this as [[perl #79166]](https://github.com/Raku/old-issue-tracker/issues/2256), because I think it's ridiculous that the prior content of a variable would determine whether the assignment "succeeds".)
- Some `rule`s really wanted to be `token`s. (Grammars are hard. Someone should give a course or something. I've learned a bit since I wrote that code.)
- Nowadays (as per spec), `>>~~<<` needs parens around lhs and rhs. (Generally, hyperops have "transparent" precedence, i.e. the same as the operator they're meta-ing. Since `~~` would require parens, so does `>>~~<<`.)

Shrdlu is a really nice project that I will tell you all about some day. Also, I'll start actually hacking on it some day... after I've grokked what that Terry Winograd was doing.
