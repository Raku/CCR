# Bit Rot Thursday
    
*Originally published on [27 January 2016](https://perl6.party//post/Bit-Rot-Thursday) by Zoffix Znet.*

## Part 1: There is a Problem

I don't think I'd have to look for long for someone who'd agree that writing new code is much more fun that fixing bugs in old one. A cool new idea gets written up, while older code is still lacking tests. A new module gets shipped, while there's still that API improvement proposal from 6 months ago in the other. And while you're drafting a design document for the Next Awesome Thing, the rest of your code is being slowly consumed by [bit rot](https://en.wikipedia.org/wiki/Software_rot).

Having written [250-300 Perl modules](http://backpan.perl.org/authors/id/Z/ZO/ZOFFIX/) and now [32 Raku modules and other ideas](https://github.com/search?utf8=%E2%9C%93&q=user%3Azoffixznet+raku&type=Repositories&ref=searchresults), I'm more than aware of what it feels like to be leaving a decaying pile of code in your wake. The problems I notice are these:

- Unfixed bugs
- Lack of compresensive tests
- Lack of documentation
- Bad documentation (too wordy; incorrect; partial)
- Unimplemented new features, even if the proposal for them was approved
- Partial implementation (an FTP client that can only download, for example)

I can think of several reasons why it might be hard to find motivation to take care of bit rot, **all** of which are perfectly valid:

- **You're "too busy."** You spent 8 hours at work, hacking on arcane code, and when you come home you want to relax and [play Warframe](http://warframe.com/) and not spend 3 more hours hacking on arcane code. Your next *Killer App* is more important than this module you wrote 5 years ago because you were bored. Your interests changed: you no longer do web development with Perl and instead are hacking on Artificial Intelligence software with Raku. And maybe you just have too many projects in the first place.
- **You don't know what needs to be done.** Sure, CPAN Testers send you emails when something's broken, but it's easy to put off until the mythical "tomorrow." Your documentation is missing and users want new features, but you forgot that was brought up a few months ago. And what about Issues that go stale without any plan of action?
- **It's too hard.** You set out to do a task and you implemented A, B, and C. Now, someone came up to you and said your thing is lacking X. Problem is, you don't have adequate knowledge and experience to implement X. And learning it requires both time and interest. Another example: users are reporting a nasty bug, but you can rarely reproduce it, and when you do, you still have no idea why it occurs.

And while entropy is a tough foe to conquer, I think at least acknowledging there is a problem is a good stepping stone to finding a workable solution.

## Part 2: There is a Solution

I toyed with the idea of dedicating a special day to deal with just these sort of problems for a while. Today, I decided to commit myself to it, and I invite anyone willing, to do so themselves and address bit rot in their own software. The plan is simple:

Every Thursday is a "Bit Rot Thursday." You find some time to address bit rot and just do it. Why Thursday? I figure Friday, Saturday, and Sunday are all about relaxing; Monday, Tuesday, Wednesday are a beginning of the week people tend to "hate"; and Thursday is in the sweet spot: do work just before the weekend and feel good about yourself when the weekend comes. Since monotony is boring, you get one Thursday every month that you can "legally" skip and do nothing. Keep in mind, Bit Rot Thursday is not only about dealing with current bit rot, but doing preventative care as well. Let's see how we can accomplish those goals:

### Toss It in the Bin

Before you rush off to fix a bug in your `lolcat_phrase_generator_5000.pl`, ask yourself: is this script or module still needed? You may feel attached to this "web framework" you wrote 8 years ago, but nobody—even you any more—uses it, so implementing HTTP/2 in it is likely a waste of time.

The modules you delete off CPAN will still be available on [BackPAN](http://backpan.perl.org/), so don't be shy. You only have this much time in a day, and it's necessary to regularly throw clutter out. This is quite equivalent to accumulating useless trinkets in your garage, in case you'll need them some day. Just toss it in the bin.

### Give It Away

If you don't think your software deserves such a harsh fate as being wiped from the face of Earth, consider putting it up for adoption. You can use blogs, social media, and <abbr style="border-bottom: 1px dotted #666" title="Internet Relay Chat">IRC</abbr> to advertise that you're looking for a new maintainer who'd be interested in fixing issues. On CPAN, you can transfer the module to user [ADOPTME](https://metacpan.org/author/ADOPTME), to enlist your module as adoptable by interested parties. Raku has its own version of the idea: place the META file into the [SHELTER](https://github.com/raku/mu/tree/master/misc/SHELTER) and then remove your module from the Ecosystem.

### Delegate

Instead of parting with your goods completely, delegate. The [Mojolicious project](http://mojolicious.org/) is a good example of how to seek out volunteers: [Issue labels](https://github.com/kraih/mojo/issues?utf8=%E2%9C%93&q=is%3Aissue+label%3Afuture+) `future` and `help wanted` are used to indicate work to be done and [social media is used](https://twitter.com/kraih/status/671414334346665986) to advertise and find volunteers willing to do the required work.

Did someone submit a report for a bug? Ask the submitter whether they'd be able to fix it. Did someone request a new feature? Suggest you'd accept a patch. Include details on what you think might be causing the bug and outline the details of how a feature can be implemented. Even if that person is unable to help, you'll have a plan of action already in writing.

### Find and Review Reports

Go through RT tickets, GitHub Issues, your notes and reminders. When you log in to [RT](https://rt.cpan.org/), the `Bugs in My Distributions` panel is third on the left. On GitHub, click the `Issues` link in top, center of the page and then change `author:` to `user:` in the search box. This will show you all open Issues in your code. You can use `user:` more than once, if you wish to also include issues from GitHub organizations you belong to. As an example, [here's a search query](https://github.com/issues?utf8=%E2%9C%93&q=is%3Aopen+is%3Aissue+user%3Azoffixznet+user%3Araku+) that shows both Issues in my code and in Raku organization: `is:open is:issue user:zoffixznet user:raku````

Get a MetaCPAN account and try out the Dashboard MetaCPAN Lab to [see the number of open issues and test failures](http://i.imgur.com/PerlWBJWE.png) in all your modules: [https://metacpan.org/lab/dashboard](https://metacpan.org/lab/dashboard).

Categorize the issues using tags and labels. Merge duplicates. Close anything that's irrelevant, can't or won't be fixed. If the conversation died out, just close the ticket with a request to reopen it if anyone has the same issue. There's no reason for tickets to be left open for years.

### Evaluate Unreported Things

Go to [CPAN Testers](http://www.cpantesters.org/) and browse by Author to your Author page (middle of page, third section). You can then use the Preferences panel on the left to generate a link to show failures only. Bookmark it. Examine any failures and see if you can fix them. When you upload new modules, if their tests are failing, you should be getting an email from CPAN Testers informing you there is a problem. If you're not getting those, check [your settings](https://prefs.cpantesters.org/cgi-bin/pages.cgi?act=user-login) and your spam folder.

Use [Devel::Cover](https://metacpan.org/pod/Devel::Cover) to evaluate how well your tests cover your code. If you use [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla), there's [Dist::Zilla::App::Command::cover](https://metacpan.org/pod/Dist::Zilla::App::Command::cover) that adds `cover` command to `dzil`.

To ensure your documentation is complete, add [Pod::Coverage](https://metacpan.org/pod/Pod::Coverage) to your author tests (that is, place it in `xt/` directory rather than `t/` so it doesn't run during user's installation). Completeness is one thing, but quality is another. Examine your extant documentation. Try to reduce the amount of words in it, while still retaining information. Use examples! A good, clear example can shave off a whole paragraph of dense technical text. There's nothing wrong with actively inquiring your users about the quality of the documentation. Do people frequently ask a particular question? Creating a FAQ is one way to go, but it's often an indicator your actual documentation can be improved in that area.

In Raku, [Test::META](http://modules.raku.org/dist/Test::META) lets you find problems in your META file and [Pod::Coverage distribution](http://modules.raku.org/dist/Pod::Coverage) includes `Test::Coverage` module to check completeness of your docs.

### Prevent Bit Rot

So far, our Bit Rot Thursday sounds mundane and boring, dealing with tedious problems. However, you can actively work against those problems appearing in the first place.

When you start a new project, do you write down a clear definition of the problem you're attempting to solve? A sure-fire way to waste time is to spend several days adding a ton of configuration options and features that you don't have any use for, simply because you never defined a concrete problem to solve. Worse: you continue to support and maintain all those features for years to come!

When you lay down the first line of code, do you have some form of a "spec" that details the bits and pieces of your project and how they're supposed to interact with each other? I'll leave it to [other sources](http://www.amazon.com/Code-Complete-Practical-Handbook-Construction/dp/0735619670/) to argue for cost savings of such an approach, but I can tell you that when you realize JSON and not PDF is better suited for the output of your program, rewriting two paragraphs of text in the spec is much simpler than rewriting several subroutines, methods, and tests.

A design spec also makes it much easier to create both tests and user documentation for your project. The test suite is the spec translated into a computer language. The docs are the spec with internal details removed and code examples added.

Speaking of tests, it's often handy to [write them first](https://en.wikipedia.org/wiki/Test-driven_development), before your actual module or script. The tests define the problem you're attempting to solve. Failing tests indicate what bits you haven't solved yet. You can also very easily track your progress, as you can see how many tests still fail. Since this approach generates a lot of output on each test run, you may find [Test::Most's `DIE_ON_FAIL`](https://metacpan.org/pod/Test::Most#DIE-OR-BAIL-ON-FAIL) useful. You can include it in code or use `DIE_ON_FAIL=1` environmental variable and this will cause the test suite to stop at the first failure.

So spend your Bit Rot Thursday making templates for specs and tests and outlining plans for what sort of documents need to be prepared for the types of projects you create. It's also a good idea to draft up guidelines for contributors, to make it clearer what sort of contributions you're looking for. You'll spend less time explaining your standards in pull requests!

### Growing Yourself

Who is more likely to produce a wall that'll crumble in a year: an experienced bricklayer or a novice? Writing code certainly gives you practice, but you need theory too, as well as to keep yourself up to date with the world. You can write a million lines of code that uses CGI.pm and memorize every word in its documentation, but in 2016 you'll still be unemployable in the field of Web Development if that's all you can do. Technologies change. Standards change. Practices change. We should change too.

And so, it's possible to spend the Bit Rot Thursday away from the keyboard. On a train, plane, bus, or boat, with your phone or tablet, reading programming blogs and articles. At a bar with your fellow programmers, exchanging ideas. In a park, on a sunny day, with a programming book in your hand.

And as you get better, so will your code...
