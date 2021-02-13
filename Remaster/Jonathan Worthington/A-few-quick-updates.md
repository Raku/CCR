# A few quick updates
    
*Originally published on [2013-12-06](https://6guts.wordpress.com/2013/12/07/a-few-quick-updates/) by Jonathan Worthington.*

I’ve been rather snowed under with work in November, thus the absence of posts here. Sorry about that. It turns out the sales folks at $dayjob did their job a little *too* well, and besides my own heavy teaching load I had to step in to rescue a few other things. Anyway, that’s done now, and I’m back to having a bit more time. (It’s not that I had absolutely no time at all since the last post. It was just more important to spend the bits I had clearing blockers in the way of others rather than writing blog posts. :-)) So, some quick bits of news.

### Concurrency

At the Austrian Perl Workshop, I worked with *lizmat* on getting the Raku concurrency spec aligned with the things I’d been working on for Rakudo on JVM. Happily, this had some good consequences. Firstly, *Larry* did a load of work on it, vastly improving naming of things and giving some syntactic relief in various areas where I’d just done simple function and method APIs. Secondly, both *lizmat* and *timotimo* dug in to bring the implementation in line with these spec changes, doing some other improvements to boot. So, now the bus number on the Rakudo concurrency support has increased. You can find the latest spec [here](http://design.raku.org/syn/S17.html). Also, you can see my Nordic Perl Workshop [slides](http://jnthn.net/papers/2013-npw-conc.pdf) about it.

### Rakudo on MoarVM progress

Last time I wrote here, we had NQP support for MoarVM pretty much complete, and were ready to dig into working on getting Rakudo running on MoarVM. The first step was to get the core of the compiler itself building. This wasn’t a terrible amount of work, since the majority of it is just NQP code. There’s more of it than is found in the NQP compiler, but that aside it doesn’t do too much that’s new. Next came the Raku MOP, which is written in NQP. Things went very smoothly with that. Beyond there, things got more interesting.

The next big piece to make work was the BOOTSTRAP. This uses the MOP to start piecing together the key types at the heart of Raku, doing enough so we can write the rest of the built-ins in Raku itself. Most of it is one huge `BEGIN` block. Here there were various unimplemented things, plus some of the VM-specific bits of Rakudo needed porting. And beyond that lay…the setting. When I did the JVM port, we had around 14,000 lines of built-ins there. These days it’s closer to 17,000 – and that’s excluding the concurrency stuff. Since compiling the setting actually involves running little bits of Raku code, thanks to traits and `BEGIN` blocks, getting through it means making quite a lot of things work. We got there a week or so back.

That still didn’t give us “Hello, world”, however. The setting does various bits of initialization work as it loads, which naturally hit more things that didn’t yet work. Finally, yesterday, we reached the point where setting loading worked and we could do “Hello, world”. Actually, once the setting loaded, this worked right off.

Of course, there’s still lots to do from here. The next step will be to work on the sanity tests. There’s a couple of large and complex features that will need some porting work; of note, gather/take will need doing. Also there are a couple of stability and algorithmic things that need taking care of in MoarVM itself. Building CORE.setting is easily the biggest workout it’s had so far, and naturally it highlighted a couple of issues. And, of course, beyond the sanity tests like the spectests…

### Better use of invokedynamic, and other optimization

I’ve got a talk at [Build Stuff](http://www.buildstuff.lt/) next week on `invokedynamic`, the instruction added to the JVM in JDK7 to support those implementing languages of a more dynamic nature So, in the last week I spent some time tweaking our usage of it to get some further wins in various areas, and to make sure I was nicely familiar with it again in time for my talk. That work got merged into the mainline development branches today. I did some other optimizations along the way that are a win for all backends, too; *lizmat* noted a 12.5% decrease in spectest time. Not Bad.
