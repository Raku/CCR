# Week 3 of Web.pm — Creating a minimal Web framework, cont'd
    
*Originally published on [24 March 2009](http://strangelyconsistent.org/blog/week-3-of-webpm-creating-a-minimal-web-framework-contd) by Carl Mäsak.*

> *Fine, u go to teh Macdonaldz and u can has feel-lay (lol) O feesh sandy-wich. Eeew, y u want shrimp basketz? It r BLECH, trust me. It r serously DO NOT WANT.*— Leviticus 11:10-12

Continuing last week's efforts to port Rack's `Utils`, `Request` and `Response` classes, I figured a nice showcase would be to get Rack's [lobster](https://github.com/chneukirchen/rack/blob/master/lib/rack/lobster.rb) (their 'hello world' app) working on Web.pm. The summary of this week is that I've *practically* gotten this working, so much so that I hope to make a small post later in the week when I actually get a working lobster in Raku.

Part of showing the lobster would of course be to have a small web server implemented in Raku, so that we don't need to go the way of Apache or similar. I asked mberends on #raku if he thought it would be worth the trouble to write a HTTP server within the Web.pm project, and his reply was ["Been there, done that"](steve-yegge.blogspot.com/2008/06/done-and-gets-things-smart.html). He gave me instructions to try his `HTTP::Server`.

```
<masak> mberends: wouldn't you know, the server works on the first attempt!
<masak> it's slow, but it works.
<mberends> \o/
<jnthn> Rakudo can haz web server?! :-)
<jnthn> You folks scare me. :-)
```

On top of that, Parrot and Rakudo might get sockets *very soon* by what I've understood from recent IRC discussions. This means that some of the solutions in `HTTP::Server` can be made a bit simpler, and possibly faster. Things are definitely in motion.

I'm happy to see ihrd's progress on `Forest`, and Tene's `Tags` module. Before we know it, we'll have something that people can actually write web apps with.

The ideas I had last week about `unpack($str, 'H2')` turned out to need the help from the Parrot people. I got a good answer from *fperrad*++, but I have yet to turn it into a Rakudo commit. A few other Rakudo commits from me made it into the public repo, however.

Other ideas I've had during the week, but which will have to sit on the backburner for some time yet, include porting Hpricot to Raku, and making something like Genshi stylesheets work, first as Raku code, and then as a standalone PCT language which compiles down to really efficient PIR. The reason these ideas will be on the backburner is that I want to stay on schedule.

There's been a lot of discussion on #november-wiki and #raku this week. I've received good help from #rack, with the questions I had about Ruby, and parrot-dev@lists.parrot.org with those I had about Parrot strings.

I wish to thank The Perl Foundation for sponsoring the Web.pm effort.
