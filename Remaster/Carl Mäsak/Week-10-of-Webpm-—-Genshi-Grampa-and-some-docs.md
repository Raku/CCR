# Week 10 of Web.pm — Genshi, Grampa and some docs
    
*Originally published on [3 July 2009](http://strangelyconsistent.org/blog/week-10-of-webpm-genshi-grampa-and-some-docs) by Carl Mäsak.*

-  *Happy Cat sez, "I gots a plan. Momz wantz booze, she getz booze. Fill teh bukkitz with waterz." And teh doodz fillded dem full.* 
-  *He sed to teh doodz, "Teyk som waters to teh party dood." Tehy didz it. Teh party dood was liek, "Tihs iz teh booze! I lieks tihs booze! Where didz tihs come?" (Teh doodz who broughted teh booze knowd.) Teh party dood wentz to teh pplz gettin hitchded and sed, "WTF!? Most doodz gives teh gud booze first, and tehn crappy booze when pplz iz too drunk to care. But tihs booze pwns!"* 
-  *Happy Cat didded this, teh first of hiz signz, in Cana inz Galilee, and revealded hiz Pwnage; and Happy Cat's doodz beleved in him.* — John 2:7-11

Today I've had some fairly good progress with Hitomi, the XML templater. Using the draft grammar *moritz*++ helped me build, I created a class that takes an XML document and translates it to a stream of events. This makes about half of the tests that I ported from Genshi [last time](http://strangelyconsistent.org/blog/week-9-of-webpm-encodings-and-a-deep-dive-into-genshi) pass; the other half of that test file concern tag soup input — I think I'll punt that one for now, and go for the lower hanging fruit: the classes `Template` and `MarkupTemplate`. With those, it should be possible to actually, you know, do some templating.

I'm getting more and more familiar with the original Python code, and starting to have some significant respect for the Genshi code base. It's simply a very well-thought-out piece of software. I can see why people like it. The project doesn't seem terribly active, unfortunately, so sometimes questions from me and others go unanswered on the `#python-genshi` IRC channel.

Is Hitomi a good name? *jnthn*++ pointed out today that it sounded very similar to "hit on me", and I find myself constantly writing either "Hitmo" or "Himoti". Then again, I kinda like that it means (or so I've read) "doubly beautiful", and I don't have a better suggestion at the moment.

Another thing that has been going on in the past week is that *viklund*++ said, almost in passing, that it'd be nice to have an XPath engine for `Match` objects. I thought it was a great idea, and incubated the project ["Grampa"](https://github.com/masak/grampa) (short for "grammar paths") on github. I've since made some good progress on it, and it's already slightly useful. Not to mention that I've learned a few new things about XPath and EBNF that I didn't know before. *pmichaud*++ helped me with some questions on the latter.

How does that tie into Web.pm? Well, it turns out that at least two of the subprojects of Web.pm would benefit from XPath searches: Hitomi, and Happle (our Hpricot clone). This suggests that Grampa should really be a `Match` front-end to an XPath query back-end, so that the back-end can then be reused in other projects. I've been implementing Grampa with this in mind.

Finally, since it's nearing the end of my original part of the grant, I've taken a fresh look at [doc/PLAN](https://github.com/masak/web/blob/master/doc/PLAN) and refined it a little. No major course corrections were needed, which feels comforting. I'll probably write some more about the status of the subprojects in next week's blog post.

Another thing I plan to do in the coming week is start on my Web.pm talk for YAPC::EU. I thought I'd write the talk in Raku Pod, and then do various conversions to end up with a PDF. Since most of the toolchain for doing that doesn't exist yet, I thought I'd better start now. 哈哈

I wish to thank The Perl Foundation for sponsoring the Web.pm effort.
