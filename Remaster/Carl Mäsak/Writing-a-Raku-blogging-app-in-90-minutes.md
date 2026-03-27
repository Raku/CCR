# Writing a Raku blogging app in 90 minutes
    
*Originally published on [10 May 2009](http://strangelyconsistent.org/blog/writing-a-perl-6-blogging-app-in-90-minutes) by Carl Mäsak.*

It all started yesterday with mberends' challenge.

```
<mberends> It's time for Web.pm to power a blogging site. Volunteers?
```

I figured it'd be interesting to see how far the tools already built into Web.pm would take me, so I set a moderately challenging time limit: 90 minutes to build a blogging app.

Long story short: it didn't take 90 minutes. After 90 minutes I still hadn't gotten the posting mechanism to work. And I'd already had to do something like five or six tradeoffs because of inadequacies in Web.pm, HTTP::Daemon, and Rakudo.

I did have a working blog after 130 minutes, though. One might favorably compare that time against the time it took to develop a basic wiki in Raku: one summer.

So things are definitely improving, no doubt.

It'd be interesting to list the things that contributed to the ease and speed in developing the blog app, and the things that could be improved to make the task even more painless. That'll have to wait until another day, though.

*mberends*++ has promised to start blogging with the new blogging app, and likely to keep developing it, blogging about *that* as he goes along. Sounds like the epitome of dogfooding; hopefully it'll positively affect some aspects of Web.pm as well.

Oh, and it's called [Yarn](https://github.com/masak/yarn) — a single-threaded app for weaving Web.pm.
