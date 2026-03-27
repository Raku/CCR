# November 5 2009 — hanging in there
    
*Originally published on [6 November 2009](http://strangelyconsistent.org/blog/november-5-2009-hanging-in-there) by Carl Mäsak.*

> 69 years ago today, Franklin Roosevelt was elected president for the [third consecutive time](https://en.wikipedia.org/wiki/Franklin_D._Roosevelt), something only he has managed in the history of the United States:

The two-term tradition had been an unwritten rule (until the 22nd Amendment after his presidency) since George Washington declined to run for a third term in 1796, and both Ulysses S. Grant and Theodore Roosevelt were attacked for trying to obtain a third non-consecutive term. FDR systematically undercut prominent Democrats who were angling for the nomination, including two cabinet members, Secretary of State Cordell Hull and James Farley, Roosevelt's campaign manager in 1932 and 1936, Postmaster General and Democratic Party chairman. Roosevelt moved the convention to Chicago where he had strong support from the city machine (which controlled the auditorium sound system). At the convention the opposition was poorly organized but Farley had packed the galleries. Roosevelt sent a message saying that he would not run, unless he was drafted, and that the delegates were free to vote for anyone. The delegates were stunned; then the loudspeaker screamed "We want Roosevelt... The world wants Roosevelt!" The delegates went wild and he was nominated by 946 to 147. The new vice presidential nominee was Henry A. Wallace, the liberal intellectual who was Secretary of Agriculture.

Election victory by sound system. There's something vaguely attractive about that.

Speaking of extending one's reign, proto is [still alive](https://www.youtube.com/watch?v=Y6ljFaKRTrI) and kicking. Not only that, *mberends*++ has been working on an almost-total rewrite which will take advantage of Rakudo's new-found ability to [find stuff in `~/.raku/lib` ](Cheese-speleology.html) so that we don't have to fiddle with `RAKULIB` anymore. The project is half-ambitious, certainly bigger than the original proto, which was more or less a one-day hack with kludges on it.

I've been meaning to help mberends along with making the branch ready, but haven't seen sufficiently round tuits... until now, during this self-imposed month of productivness. **Let's do this! Let's bring `RAKULIB`-lessness to the people!**

Hokay. First step: trying out the branch myself. It's called `installed-modules`, by the way. Switching over to it... hm, last commit two weeks ago. Most of the activity seems to have been in september, by *mberends*++, *viklund*++, *moritz*++, and *ash*++. Basically everyone but me. 哈哈

I switch back to `master` to see which projects I already have installed.

```
$ ./proto update installed
```

Dang, parrot-lib conflict! I have way to many rakudo instances at this point, most of them conflicting. Deleting the offending instance, and trying again.

```
$ ./proto list installed
Downloading Raku....................................................[  ok  ]
Unpacking Raku......................................................[  ok  ]
Building Raku.......................................................[ FAIL ]
Couldn't build Raku.
```

I really like that part. I spent quite some time turning the verbose output into little progressive dots. But the `FAIL` at the end is disconcerting. I haven't been hearing massive complaints from people about this. Is it just on my box that it fails?

I remove `config.proto` and try again.

```
$ ./proto
Downloading Raku...[  ok  ]
Building Raku.......................................................[ FAIL ]
Couldn't build Raku.
```

Sigh. So it's not just me, then. Guess I'll be doing this today, rather than look at the branch.

In order to check what's wrong, I turn off the nice dots and watch the output.

Well, hey, the build succeeds! But it's the next step that fails, trying to start Rakudo. That's because Rakudo needs to be installed nowadays. Presently it looks like this:

```
== SORRY! ==
Unable to find Raku dynops and dynpmcs library.
If you want to run Rakudo outside of the build directory, please make install.
== SORRY! ==
Unable to find Raku dynops and dynpmcs library.
If you want to run Rakudo outside of the build directory, please make install.
done
== SORRY! ==
Unable to find Raku dynops and dynpmcs library.
If you want to run Rakudo outside of the build directory, please make install.
```

Well, at least I know how to fix that. I have to make proto run `make install` on Rakudo, and then make sure I call the installed executable in `rakudo/parrot_install/bin/raku`.

While I run make again, I think about the repercussions of that change. It's clearly the right thing to do for parrot-in-rakudo, but proto also accommodates users who run rakudo-in-parrot, and it's not the right thing to do for them. Hm.

Maybe there is no way to make rakudo-in-parrot work nowadays? There's only one way to find out! But maybe some other day. This is already getting quite long.

This seems to be a general trend this month. I set out to do something, only to notice something else is broken, so I get sidetracked fixing that instead. Oh well, it's things that need doing.

Turns out I have the following projects installed on proto `master`: statistics-lite, maya, ppm, uri, svg, perl6-literate, form, grampa, web, http-daemon, rakuqlite, html-template, faz, io-prompt, mwbot, json, wtop, csv, xml, pun, rakuxamples, druid, yarn, svg-plot, rss-bot, http-client, irc-client, november. Basically all projects. Hey, I like looking at Raku code, okay?

Well, anyway. Tune in next time when I actually use the proto branch `installed-modules`, rather than just patch up `master`.
