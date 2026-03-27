# Week 13 of Web.pm — abstracting away the webserver, live!
    
*Originally published on [16 August 2009](http://strangelyconsistent.org/blog/week-13-of-webpm-abstracting-away-the-webserver-live) by Carl Mäsak.*

> *Jebus gotted a baff wif evribodi els. Hovr Cat turnded into a pijn and landid on Jebus. And a voiss from the ceiling sed "U iz mai kittn. I lieks u an I iz happi wif u."* — Luke 3:21-22

When I feel there are too many steps to get to what I want to acheive — a feeling that occurs often enough within the Web.pm effort — I like to get down to basics. What's [the simplest thing that could possibly work](https://c2.com/xp/DoTheSimplestThingThatCouldPossiblyWork.html)?

Usually, there's a frustrating buildup until I hit that point, and click over to simplest-thing mode. Usually, once I do, I thank myself for it, and marvel at the time I spent trying to cautiously nose around the problem in other ways, as if looking for some weak point.

## A live coding session from first principles

Like what I'm doing now, for example. (Today I'm writing the blog post and wrapping up this week of development at the same time.) I'm writing a `Handler` for *mberends*++' `HTTP::Daemon`. This is a step towards making Web.pm webserver-agnostic by putting all the webserver-specific code in `Handler` classes.

So, in order to understand what makes the `HTTP::Daemon` module tick, I nosed around aimlessly, reading the module code over and over again. Then — click — I decided to do what `make run` does, since it obviously sets up a functioning local web server.

Turns out `make run` simply calls a `bin/httpd` script. I scavenged that script, and ended up with a "server one-liner" for Raku:

```raku
$ raku -e 'use HTTP::Daemon; my HTTP::Daemon $d .= new; while my $c = $d.accept and my HTTP::Request $r = $c.get_request { say $r.method; $c.send_response("OH HAI") }'
```

After starting this script, I can hit `http://127.0.0.1:8888/` in my web browser, and the browser will say "OH HAI", and the one-liner will say "GET". It doesn't get much simpler than that.

Next step: something like this (perhaps familiar for those who saw my talk at YAPC) should be made to work:

```raku
Web::Handler::HTTPDaemon.run( sub ($env) { [200, { 'Content-Type' => 'text/plain' }, ['Hello World!']] } )
```

Turns out this code (mostly a modularization of the one-liner above), did the trick:

```raku
use v6;
use HTTP::Daemon;
class Web::Handler::HTTPDaemon {
    method run(Callable &app, :$port = 8888) {
        my HTTP::Daemon $d .= new(LocalPort => $port);
        while my $c = $d.accept and my HTTP::Request $r = $c.get_request {
            my %env = {};
            $c.send_response(&app(%env)[2].Str)
        }
    }
}
```

(**Update 2009-08-19:** *flip*++ informs me on IRC that the `&app(%env)[2].Str` would insert a space between each element. It should really be `[~] &app(%env)[2].list` — thanks!) 

And it works! The browser says "Hello world!" when I hit `http://localhost:8888/`.

Now, a toy example such as this is nice and all, but the *prototypical* toy example — the Nibbler — should be made to work, or it somehow doesn't count.

So, I rewrite `bin/run-nibbler` to this:

```raku
#!/usr/local/bin/raku
use Web::Nibbler;
use Web::Handler::HTTPDaemon;
my $port = 8888;
say "Try out the Nibbler on http://127.0.0.1:$port/";
Web::Handler::HTTPDaemon.run( Web::Nibbler.new );
```

(That's much less code than [before](https://github.com/masak/web/blob/36025de9bf9247c3b239c3e7594ea6dddf7390ef/bin/run-nibbler), and webserver-independent at that. Yay orthogonality!)

I'd like to be able to say that this worked on the first try, but actually I had to tweak two things in the `Web::Nibbler` module itself for it to be compatible with this new scheme. First, due to some excellent on-demand hacking by *jnthn*++ during YAPC::EU, we can now start renaming our `call` methods into `postcircumfix:<( )>` — and in this case, we kinda have to. Second, `run` expects a `Callable`, so we'll have to declare that `Web::Nibbler does Callable`.

After that, it works! Except nothing happens when I click the "flip" link on the Nibbler, because I'm a cheating bastard who doesn't send it a proper `%env` argument. Time to fix that.

...and it turns out that this little detail was easy too. I just salvage two lines from the old `bin/run-nibbler`, and it works:

```raku
my $qs = $r.url.path ~~ / '?' (.*) $/ ?? $0 !! '';
my %env = { "QUERY_STRING" => $qs };
```

Only this time, these two lines end up in `Web::Handler::HTTPDaemon`, where they should be.

Yay! That sure felt good.

One thing I want to start habitually doing in the Web.pm posts is having a "Try it out yourself" section, where people can get interactive if they want. I've come to realize that this is something people want out of blog posts, and I certainly wouldn't mind having more hands and eyes on Web.pm. So here goes:

## Try it out yourself!

See if *you* can get the latest Web.pm to run this piece of code:

```raku
Web::Handler::HTTPDaemon.run( sub ($env) { [200, { 'Content-Type' => 'text/plain' }, ['Hello World!']] } )
```

Then expand it into something cool, and go brag on #raku about it.

(**Update 2009-08-19:** Recall that Web.pm nowadays has `HTTP::Daemon` as an external dependency, so make sure you have it and that it's in your `RAKULIB` path, along with Web.pm. *PerlJam*++ for pointing out that this wasn't obvious.)

## Other interesting goings-on

- There was this YAPC::EU conference, and it was amazing. Mostly, it was amazing because Raku and Rakudo stole the show, and pulled down the biggest ovation of the whole conference: Rakudo is entering a new phase in April, called Rakudo Star, and it'll be awesome. My goal is to make Web.pm, if not awesome, then at least perfectly usable until then.
- Last month, I got an email from Arthur Wolf, a (by his own description) programmer "very impatient to write mvc apps". He wrote to say that he was slightly dismayed that he couldn't do this yet, and asked "Is there anything I can do to help ?". I emailed back a "yes!" and a few suggestions. Arthur decided to have a go at Astaire, our minimal dispatcher DSL-y thingy. He's made head-spinning progress since then. My role in this is mainly to stand back, amazed, as this man churns out code. I also sometimes throw him a workaround or two. arthur-*_*++
- I've gotten partway in writing a spec for Web.pm Core. Nothing commitworthy yet, but hopefully next week.
- I would still appreciate some help with the [problem from last week](Week-12-of-webpm-a-spec-and-smartlinks.html) of having our spectests (and their pass/fail status) being woven into the HTML generated from our Web.pm spec. I'll look at it a bit more myself, but I'm afraid my brain might be too small for the code that's been written to solve this for Pugs once upon a time.
- There are some serious encoding problems still lurking our there with Rakudo, which we'll *have* to solve before April. Right now, for example, the `HTTP::Daemon` stack crashes when the browser is trying to load the pre-packaged favicon. Why? Essentially because `&slurp` doesn't have a `:bin` parameter yet, and it won't realistically have that until we have a more mature `Buf` type. I got some work done on `Buf` during the Rakudo post-YAPC::EU hackathon, but more such work is needed to get there.
- Taking stock of the current interest for Web.pm, it feels we're on track. People seem to generally know what it is, and seem to generally be thinking "hm, Raku and web apps, then I should probably take a look at Web.pm". That's good, and that target group is probably the right one to keep in mind.

I wish to thank The Perl Foundation for sponsoring the Web.pm effort.
