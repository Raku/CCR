# The Failure Point of a Release
    
*Originally published on [23 April 2017](https://perl6.party//post/The-Failure-Point-of-a-Release) by Zoffix Znet.*

If you've been awaiting April 2017's Rakudo release, you may have noticed something not quite right. Instead of a single release, there've been 4 already, and the 4th one is still not quite perfect. In this post, I'll explain what the hell's going on, for those who've not been following along for the past week, as well as share some ideas on how these issues can be avoided in the future.

## The Past

#### Standard Release

The standard release happens on 3rd Saturday of the month, after the MoarVM team makes their release. Aside from logging of all the commits to the changelog and checking for any release-blocker tickets, the entire release process is automated and [is done by a bot](https://irclog.perlgeek.de/rakuev/2017-03-18#i_14286422). The bot doesn't (yet) know how to do point releases, which caused one of the issues with April's release.

#### IO, Delay, Rakudo Star, Staging Repo, And `uncurse` Branch

The April's Rakudo release was a bit specialer than normal releases, because Rakudo Star—the release of Raku for end users—was supposed to be cut from it.  Rakudo Star gets released only every 3 months, so there was some pressure to push big changes to be part of the release, just so that users wouldn't have to wait another 3 months to get them.

The two groups of changes were IO Grant work and `uncurse` branch. The former [had some big and at-times breaking changes to IO routines](http://blogs.perl.org/users/zoffix_znet/2017/04/perl-6-io-tpf-grant-monthly-report-april-2017.html), while the latter is about merging `Cursor` and `Match` types into one, which will allow us to improve performance, among other things, in future work.

To bring as many IO changes as possible into this release, I (Zoffix) decided to delay the release by 2 days and cut it on Monday. During that period, it was also decided that we should merge `uncurse` branch work, so that it's makes it into the Rakudo Star release. In addition, a bunch of fixes to Staging repo went in that allowed to easily create Linux packages.

**Points to note:**

- We rushed some work, due to lengthy Rakudo Star release cycles


#### The Cut and Recut

Most of IO work got completed. The `uncurse` branch got merged. And on
Monday, April 17, 6:11pm EST [I cut the
2017.04 release](https://irclog.perlgeek.de/rakuev/2017-04-17#i_14442193) and
called it a day.

Tuesday, April 18th, around 4am EST, my notification bot pinged me, and I
learned the release had a left over debug statement. Whenever the
```` rakumethod Type: $arg` calling form was used, the
compiler dumped the AST onto the screen. This wasn't caught by our suite of
140,000+ tests, because most of them check values rather than full STDOUT and
STDERR output for every feature of the compiler.

The commit fixing the issued already went in, so I went ahead and cut the
2017.04.1 point release. Since the bot doesn't know how to do point releases,
I did the release by hand. And since the issue was only in Rakudo itself,
no NQP or MoarVM releases were done. Just Rakudo.

**Points to note:**

- Tests don't cover every possible thing in existence
- Some issues can be quickly found by users, even if uncaught by tests


#### The Precomp Strikes

While the release cut was a smooth going, I did it a bit too fast, as
[merely three minutes
later](https://irclog.perlgeek.de/rakuev/2017-04-18#i_14444573) it was
discovered there was an issue with installation of
[Digest::SHA1::Native](https://modules.raku.org/repo/Digest::SHA1::Native)
due to the Staging repo work that went in shortly before the original release.

The issue was fixed later in the day and I cut the 2017.04.2 release. Just
as with the previous point release, the issue was in Rakudo only and did not
require NQP or MoarVM point releases.

**Points to note:**

- Rakudo needs more coverage for `CompUnit::*` types
- Releases need to include installation and testing of a selection of Raku
modules


#### The REPL History

The next day, another issue cropped up. The combination required for its
manifestation was: Rakudo's REPL + installed Linenoise or Readline module
+ OSX (or whatever it's called these days). Originally, it was thought the
issue prevented users from using the REPL entirely, and talk of yet another
point release followed. However, it was then found to affect only the saving of
REPL history between separate invocations, and not the REPL itself, so it
was left alone, without any point releases.

The cause of the issue was the IO Grant changes to `&mkdir`. It used to return
an empty list on failure, but was now changed to behave the same way as
```` rakuIO::Path.mkdir` does, and return a `Failure` object, which explodes when sunk.
The REPL history file code was written using the assumption of empty list
return value and
that `mkdir` cannot create non-existent parent directories, so for a
```` raku/foo/bar.hist` file, it was attempting to create directories `/` and `/foo`.
It turns out that on Linux, `mkdir("/")` silently succeeds, while on OSX it
fails, which caused this bug to appear only on a specific OS.

**Points to note:**

- We need to test installation and use of ecosystem modules on multiple OSes


#### The Curse of `uncurse````

Two days later, on April 21st, an issue due to the merged `uncurse` branch
[was reported](https://rt.perl.org/Public/Bug/Display.html?id=131187). If
Grammar action method exists for a token that uses `)>` capture marker, the
Match of the token ends up including the stuff outside the marker. This
issue caused failure in [File::Ignore](https://modules.raku.org/repo/File::Ignore) module.

The issue was found in NQP and was fixed later in the day. At this point,
making yet another point release felt a bit embarrassing and I proposed
declaring 2017.04 a lemon and basing Rakudo Star off 2017.05 instead.

**Points to note:**

- We rushed some work, due to lengthy Rakudo Star release cycles
- Releases need to include installation and testing of a selection of Raku
modules


#### The CaSe-InSeNsItIvE Regex Bug

At this point we already realized we needed more thorough testing of ecosystem
modules to be coupled with Rakudo's releases, so some of the core devs started
going through all the 800+ modules and trying to fix their issues. The splatter
from squashed uncurse bug barely dried out, when the module testing showed
us another bug. This time involving case-insensitive regex matching:

```` raku
say 'abcdefz' ~~ m:i/za/ # OUTPUT: «｢z｣»
````


Under some circumstances the match would succeed even when it shouldn't. This
bug was actually introduced in 2017.03 release, and so wasn't a regression of
2017.04 releases, but it gave more weight to the idea of us doing the
2017.04.3 point release.

The bug was found to be in MoarVM, and so after MoarVM and NQP bumps, it was
fixed on Rakudo's nom HEAD, while I was sleeping.

**Points to note:**

- Tests don't cover every possible thing in existence
- Releases need to include installation and testing of a selection of Raku
modules


#### The Missing Releases

On Sunday morning, April 23rd, with the regex and uncurse bugs squashed
on HEAD,
but still present in latest Rakudo releases, I decided to cut yet another
point release, the 2017.04.3.

Having just done two point releases, earlier in the week, cutting the release
was second nature to me. However, with the bot doing all the releases for the
past 8 months and the previous 2017.04 point releases needing only a Rakudo
point release, my second nature totally forgot that *this* point release
also needed releases of MoarVM and NQP, since that's where the fixes for
regex and uncurse were!

About an hour after I released 2017.04.3, the Rakudo Star release manager
asked whether NQP 2017.04.1 release was in the works. It wasn't. Moreover,
to do it right, it would need a MoarVM 2017.04.1 release too, which is released
by another team.

**Points to note:**

- We need to expect exceptional circumstances

## The Present

So here's where we are right now:

- [Latest Rakudo release](http://rakudo.org/downloads/rakudo/) is 2017.04.3
- It has no horrible bugs, other than [the usual ~1,500 tickets](https://raku.fail/)
- However, it references a non-release NQP commit, namely `2017.04-24-g87501f7b````
- It is unknown whether this issue impacts Rakudo Star
- It likely doesn't, and if it does, we might base Rakudo Star off 2017.05 release instead
- There's clearly a lot of room for improvement and testing of Rakudo releases and commits

With the next Rakudo compiler release just 4 weeks away, I would hope there's no need to cut yet another point release of all three projects.

## The Future

Looking at points of note above, we can figure out how we can avoid this type of issues in the future. The points are:

- We rushed some work, due to lengthy Rakudo Star release cycles
- Tests don't cover every possible thing in existence
- Some issues can be quickly found by users, even if uncaught by tests
- Rakudo needs more coverage for `CompUnit::*` types
- Releases need to include installation and testing of a selection of Raku
modules
- We need to test installation and use of ecosystem modules on multiple OSes
- We need to expect exceptional circumstances

So I think this is how we can avoid some of the release problems:

#### Release Often-ner

Some of the issues were due to cramming work into a release, simply because the next user-facing release is far in the future. The [Raku VIP](https://raku.vip/) distribution aims to be released monthly, and while its offers are a bit different from those of Rakudo Star, it will be a distribution meant for users, so core devs will have fewer reasons to cram all their work into a release.

#### Expect the Unexpected

While point releases are rare, cutting them is error-prone due to lack of explicit "Point Release Release Guide" or a bot that knows how to do them.

I plan to teach the release bot to be able to know how to cut a point release as well as add a guide for point releases to go along with the regular release guide.

#### Test More

The current test coverage needs to be improved. This month we saw resurrection of the tool that reports [Rakudo's coverage](https://raku.wtf/) as well as created a tool for [MoarVM's coverage](https://moarvm.github.io/coverage/), so the work in this area has already started.

In addition, I plan to make a bot that daily tests the full build, runs stresstest, and installs a large selection of modules, reporting any of the new failures. This way, we'll spot problematic commits that affect ecosystem modules sooner.

Lastly, more OSes will be used to test the release on. I will teach the release bot to automatically spin up VMs with different OSes and test on each of them, so there's no extra human labour added to the release process.

#### Freeze The Release

One possible way to reduce release issues is to freeze the release branch, say, a week before actual release. Nothing but critical bug fixes get committed to it, so when the release date comes around, we'll have all the code with at least a week of usage.

What makes this a bit problematic is dependence on NQP and MoarVM projects: a version bump in them brings all the previous commits in and MoarVM is even released by a different team. Keeping three release branches around while doing acrobatics with version bumps is less than ideal. Moreover, there's a 4th player in this all: the Roast repo. Any new tests added to it would fail on the frozen release branch, so there might be a need to make a "for release" branch of Roast as well.

## Conclusion

So that's the story of 3 point releases we made in April. There's plenty of work to be done to make the release process more robust and less likely to introduce issues. While all of it won't be done by the next release, we'll be sure to address all of the existing issues.
