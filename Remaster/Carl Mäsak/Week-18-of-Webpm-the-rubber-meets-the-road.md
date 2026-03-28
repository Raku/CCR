# Week 18 of Web.pm — the rubber meets the road
    
*Originally published on [24 October 2009](http://strangelyconsistent.org/blog/week-18-of-webpm-the-rubber-meets-the-road) by Carl Mäsak.*

> *"Moses in teh r00lz sez we sposed to kill her dead wif rox. Whutchu fink?" srsly, dey dont care whut Jebus sez, tho, dis is a trap to maek Jebus luk bad. Jebus din say nuffin to dem and wroted sumfink in da durt. Dose d00dz din STFU, askin till Jebus sez, "d00ds, if yur so gud, n haz no invisivle error, u can haz rox for teh throwin." an Jebus pwned dos fairseez an whent bak to His writin. teh fairzeez sez, "hez got us der" n left, sos Jebus wuz lone wif the woman. Jebus luked up an sez "WTF? Where dem d00ds go? nobuddi wans rox?" she sez "No." An Jebus sez, "me neever. Go way an be gud kitteh."* — John 8:5-11

This week:

- I did the last bit of config-ing to get Druid to run as a web app on feather. It's still non-trivial to set up a thing like that, mainly because of `RAKULIB`. A bit tellingly, I didn't use proto to ease the pain, even though I created it. In fact, proto is currently bad at setting `RAKULIB` correctly for projects with dependencies. This will all get better as the `installed-modules` branch lands, though.
- I also needed to tweak `Web::Handler::HTTPDaemon` slightly to [allow for the hostname to be passed](https://github.com/masak/web/commit/e24dabb7e5af79e446e4dc4107eb4a389313925f).
- After that, we had Druid running on feather for a few minutes! \o/ You can see my exuberant joy on the #raku channel. *jnthn*++ joined in and we played a couple of moves.
- As we played for a couple of minutes, we had about three connection drops due to segmentation faults. All this code that Druid and Web.pm pull in to make Rakudo do their bidding, it seems to be pushing the limits. Probably a Parrot memory management bug to be discovered there or something. Anyway, it goes without saying that things need to get much more stable (and faster) before one can even think of using Web.pm for anything serious.
- Having the Druid web app exposed to daylight in that way made me see more clearly what the next steps for it would be. I put that into [the README file](https://github.com/masak/druid/blob/master/README) of Druid.
- The rest of the week I was lost and kinda directionless, so I finally started in on writing the [Core spec](https://github.com/masak/web/blob/master/spec/Core.pod). Not done yet, but it feels like a good start. Still need to document all the methods of `Web::Request` and `Web::Response`.

I wish to thank The Perl Foundation for sponsoring the Web.pm effort.
