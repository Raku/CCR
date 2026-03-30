# Raku, Perl 1, PHP, Python, mod_parrot, Parrot
    
*Originally published on [11 December 2007](https://use-perl.github.io/user/pmichaud/journal/35084/) by Patrick Michaud.*

More and more interesting things are happening in the Parrot world -- it's hard to keep up.  Here's a laundry list of things that have happened since my last journal post.

* In raku, Jerry Gay and I have re-enabled arrays, try blocks, testing for defined values, if/unless statement modifiers, booleans, ranges, and a whole lot more.  More details about raku in an upcoming post.

* Last week I had to go out of town on business for a day, but while I was on the planes I was able to convert the fledgling Python on Parrot compiler ("pynie") to use NQP and the compiler toolkit.  This reduces the compiler to using only 473 lines of PIR, including comments -- the rest is all written in Raku (809 lines).

* Bernhard Schmalhofer has been updating the PHP on Parrot implementation ("Plumhead") to use PCT, and then he and Jeff Horwitz surprised us all with [PHP running in mod_parrot](https://web.archive.org/web/20080209143551/http://www.smashing.org/jeff/node/24) !

* Jerry Gay is also making great progress in updating the Perl 1 compiler ("punie") to be written in NQP+PCT instead of PIR... in fact, as I write this he has just merged his development branch back into the trunk ( languages/punie/ ).  Yay!  Punie is also passing some TODO tests that weren't passing in the previous version.  Yay again!

* There have been a lot of minor improvements to the compiler toolkit, especially in the area of error reporting and the overall API.  More will undoubtedly come as we continue to explore the compiler space.

For any interested C programmers out there, I think that a patch for [RT#47992](http://rt.raku.org/rt3/Ticket/Display.html?id=47992) would be very appreciated.  I wouldn't think this would require a lot of knowledge of parrot internals -- just some changes to Parrot's command-line argument handling.

For Perl (5) hackers, the language implementors on Parrot could really use some improvements to the test harness(es).  Right now several languages (raku, punie, pynie, pheme) are able to implement their own 'make test' target, but we don't have a good way to incorporate those into Parrot's top-level 'make languages-test' or 'make languages-smoke' targets.  It has to do with the fact that the test files for each language aren't written in Perl (the harness is, but not the individual tests).  In October Colin Kuskie and a few others were working on this issue under the "unified-testing" branch, but that seems to have stalled.  With compiler and language development accelerating it would be really good to see that effort picked up again.

Finally, a brief note that every Tuesday at 18:30 UTC the Parrot committers hold an online status meeting on 



[#parrotsketch](https://irclogs.raku.org/parrotsketch).  Observers are welcome to attend, and the logs of the meetings are [archived](https://web.archive.org/web/20090419195038/http://www.parrotcode.org/misc/parrotsketch-logs).
