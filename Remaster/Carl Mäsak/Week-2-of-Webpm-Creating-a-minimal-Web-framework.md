# Week 2 of Web.pm — Creating a minimal Web framework
    
*Originally published on [16 March 2009](http://strangelyconsistent.org/blog/week-2-of-webpm-creating-a-minimal-web-framework) by Carl Mäsak.*

> *All jordan base are belong to teh Gilead kittehs, so dey go to to Efraim; wen Efraim kitty not pwned want cross an say, "i can crosez ovar?" Gilead den ask, "yuo = efraim?" den he say, "NO, DUH" den has test, "ok den, say shibboleth. " but he sai "sibboleth" cuz hez stupid and cant sai rite, so dey aggrod him. 42000 efraim kitteh got aggrod cuz dey ALL stupid like dat.* — Judges 12:5-6

Two things of note have happened this week.

First, lively discussion on dispatching continued. It took place mostly on [#november-wiki](https://irclogs.raku.org/november-wiki/) and november-wiki@googlegroups.com. (We've decided to use these as our platform for Web.pm discussion. Anyone interested is encouraged to join in.) ihrd, moritz and ruoso contributed most of the discussion.

There are a lot of possible ways to do dispatch. We want a good, reasonable default way in Web.pm. What eventually emerged was the idea of building the URL dispatch on top of the [MMD (multi-method dispatch)](https://github.com/Raku/old-design-docs/blob/master/S12-objects.pod#Multisubs_and_Multimethods) already built into Raku. After that, the discussion focused mainly on exactly how to do this. I look forward to seeing a working example of this really soon.

Second, I started porting Rack. In doing this, I realised, on a slightly deeper level than I had before, that Rack embodies many things that Web.pm wants to be. Peruse [this presentation](https://chneukirchen.org/talks/#introducingrack) by chneukirchen, and you might start to see what I mean.

The obvious first targets to port are Rack::Request and Rack::Response, both of which depended on Rack::Utils, so I started with that. [Porting Ruby code](https://github.com/masak/web/blob/8bf8c15674b675497a87091df27fa621a2979806/lib/Web/Utils.pm) was exhilirating. Not only that, there's a feel about Rack that it's very stable, thoroughly used and tested code. None of the short-term hacks November is currently built on.

I also broke our decision to target the latest Rakudo developer release, by writing code that used `unpack($str, 'H2')` and its inverse. Since I don't want to be the one to introduce broken code into the repository, I've decided to spend parts of tomorrow patching Rakudo's `unpack` to handle this case. The next developer release of Rakudo ('Rakudo Oslo') is on Thursday.

All in all, it feels like I'm on track. I've been increasingly asking myself "What will November need to start using Web.pm in a few weeks?". The answer to that question — which seems to be "requests and responses, templating, sessions" — is what I'll be concentrating my efforts on in the next few weeks. I can already tell that cleaning up those parts of November and moving them over to Web.pm is something I will enjoy very much.

I wish to thank The Perl Foundation for sponsoring the Web.pm effort.
