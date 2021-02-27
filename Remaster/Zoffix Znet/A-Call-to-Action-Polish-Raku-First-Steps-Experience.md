# A Call to Action: Polish Raku First Steps Experience
    
*Originally published on [13 June 2018](https://perl6.party//post/A-Call-To-Action--Polish-Perl-6-First-Steps-Experience) by Zoffix Znet.*

If you follow the [updates on KickStarter](https://www.kickstarter.com/projects/1422827986/learning-perl-6?ref=user_menu), you may know the [*Learning Raku* book](https://www.learningraku.com/book/) is nearing completion, with the author planning to submit final manuscript to O'Reilly on June 18th.

What this means is the July's Rakudo Star release will possibly be the release the first crop of readers of that book will be using (the next release after that is in October). I've seen several people say they're waiting for this book to get published before they give Raku a try. Coupled with the marketing the author and O'Reilly will be doing for the book, I expect to see an influx of new users.

For that reason, I'm making a call to action, for everyone to polish the experience of the first steps those users will make in Raku.

## How to Help?

There are several things you can help with, depending on your skillset. And before anyone protests, don't worry, there's one thing *everyone* is able to do…

### Install Raku

The easiest thing you can do is grab a clean box and try to install Raku to it. This is especially useful if you've never done it before and have no idea what you're doing, as it'll be very easy for you to see things that need to be improved.

Are you having trouble finding or choosing what to install? Getting installation errors? Having trouble finding support channels? Report it!

Unless you can think of a better place, you can always report these things in our [*User Experience* repo](https://github.com/raku/user-experience/issues) by filing a [new Issue](https://github.com/raku/user-experience/issues/new).

### Learn/Use Raku

This, again, is the area where the less experience with Raku you have, the better. Is there something you find difficult to use or hard to find? [Let us know](https://github.com/raku/user-experience/issues).

Code editors, books, documentation, modules, tutorials, excercises, contests, language news, support channels. If you were looking for any of those things and had a hard time finding them, the process will likely need to be addressed.

### Rakudo on Windows

This is the area where I hope we'll make a lot of progress before the next Rakudo Star release (it'll be in July, based on Rakudo compiler release scheduled for July 21st). Few, if any of the core devs use Windows as their development environment, so the state of Rakudo on Windows is slightly lagging behind.

While [6.d-proposals roast](https://github.com/raku/roast/) stresstest is clean on Linux and MacOS, on Windows, [there's a bunch of test failures](https://github.com/raku/roast/issues/320#issuecomment-379595368). Several of them are likely problematic tests themselves (e.g. those that shell out and expect `rakucmd.exe` to handle Unicode out of the box). When I last looked at the failing tests, some of them were failing due to how [`&run` escapes arguments](https://rt.perl.org/Ticket/Display.html?id=132258#ticket-history); since `raku` is launched with a batch file on Windows, using `$*EXECUTABLE` with `&run` would require using `cmd.exe`-style escapes of command line arguments, which `&run` doesn't use. There's some discussion for this issue on [R#1325](https://github.com/rakudo/rakudo/issues/1325), [RT#132258](https://rt.perl.org/Ticket/Display.html?id=132258#ticket-history), and self-rejected RFC [R#1306](https://github.com/rakudo/rakudo/issues/1306).

If you'd like to look into these problems, you can [install Rakudo from source](https://rakudo.org/files/rakudo/source) on Windows and then run `gmake stresstest` (or whatever `make` equivalent you have) to clone all the spectests into `t/spec` directory and run them, so you'll be able to see what's failing. You can run individual tests with `t/fudgeandrun t/spec/42-foobar/the-test-file.t````

There's also a second item of lesser importance: Rakudo Star build on 32-bit Windows. The latest build we have for that system is 2016.01, which is quite outdated. On occasion people do ask for 32-bit builds and currently we can only suggests to [build from source](https://rakudo.org/files/rakudo/source).

It'd be nice to have a more recent build created. I'm unfamiliar with what's involved. If you're interested in helping, join our [IRC chat](https://docs.raku.org/webchat.html) and try to speak to *stmuk* or *FROGGS*

## Help Resolve Issues

Help us resolve open Issues. In the context of this call to action, the most pertinent repos would likely be [User Experience](https://github.com/raku/user-experience/issues), [Perl6.org website](https://github.com/raku/raku.org/issues), [Modules.Perl6.org website](https://github.com/raku/modules.raku.org/issues), as well as [Docs](https://github.com/raku/doc/issues), [Rakudo Star](https://github.com/rakudo/star/issues), [Rakudo itself](https://github.com/rakudo/rakudo/issues), and [Roast Test Suite](https://github.com/raku/roast/issues/).

For core hacking resources, there are some tutorials with "Core Hacking" in their titles on [Rakudo.Party](https://rakudo.party/) website, the [NQP/Rakudo Internals Course](https://github.com/edumentab/rakudo-and-nqp-internals-course) and [6guts blog](https://6guts.wordpress.com/). I also like to use [Z-Script](https://github.com/zoffixznet/z) rakudo dev
helper script.

## Conclusion

The Learning Raku book is about to hit the shelves and will likely bring a crop of new Raku users. We can improve the perception of the language by polishing the experience of those users. Let's see if there are any problems with obtaining the compiler or any resources a begginer would need to get started with the language.

There are also some issues on Windows that need to be addressed, such as
failing stresstests and 32-bit Rakudo Star builds.

If you can give a hand with any of that, it'd be greatly appreciated. File
[a new Issue](https://github.com/raku/user-experience/issues/new) in our User Experience repo or just [chat with us on IRC](https://docs.raku.org/webchat.html).

-Ofun
