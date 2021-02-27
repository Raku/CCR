# Newcomer Guide to Contributing to Core Raku
    
*Originally published on [2 August 2018](https://perl6.party//post/Newcomer-Guide-to-Contributing-to-Core-Perl-6) by Zoffix Znet.*

So, you want to contribute to an awesome open source project like the Rakudo Raku compiler, but didn't know where to start? Good news! This guide is for you.

## Finding What to Fix

The [Issues in the repository](https://github.com/rakudo/rakudo/issues) have labels on them. Newcomers should look for Issues labeled with [`good first issue`](https://github.com/rakudo/rakudo/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) and [`easy to resolve` Issues](https://github.com/rakudo/rakudo/issues?q=is%3Aissue+is%3Aopen+label%3A%22easy+to+resolve%22).  The two labels are largely synonyms, though slightly harder than trivial Issues might be marked with `easy to resolve` label only.

Once you have a few bug corpses behind you, you may wish to give [`medium difficulty` Issues](https://github.com/rakudo/rakudo/issues?q=is%3Aissue+is%3Aopen+label%3A%22medium+difficulty%22) a go.

Some of these labels are assigned based only on a *guess* about what the problem is, so keep in mind a labelled Issue might turn out to be harder than it first looked like.

---

If you found the easy Issues too hard, you may have some luck writing tests for already-fixed bugs instead. Such Issues are marked with [`testneeded` labels instead](https://github.com/rakudo/rakudo/issues?q=is%3Aopen+is%3Aissue+label%3Atestneeded)

## Ask Questions

The main point of these labeled Issues isn't that any passer-by should be able to fix them, but that any passer-by can asks questions about fixing those issues and a core dev will be willing to walk you through fixing them, so that you can learn about fixing bugs in core.

So, be sure you ask questions if you're stuck with some Issue. You can ask by commenting directly on the Issue or join our [dev chat room](https://raku.org/irc-dev) (but keep in mind that due to timezones, at times you may find no one around. Just ask your question and eventually someone will turn up and answer it).

## Building Stuff

The system involves 4 repos: [Rakudo](https://github.com/rakudo/rakudo/) compiler, which uses [NQP](https://github.com/raku/nqp/), which in turn uses [MoarVM](https://github.com/MoarVM/MoarVM/). All work requires passing the [roast](https://github.com/raku/roast/).

There are many ways to set all these repos up, but I'll tell you just the one way that I use: [Z-Script](https://github.com/zoffixznet/z). It's a helper script that simplifies a lot of the building instructions to a single command.  The rest of the guide will assume you're using Z-Script.

For initial setup, follow [Z-Script's installation instructions](https://github.com/zoffixznet/z#z-script). Once installed, you can run `z --help` for a list of supported commands (the list in README is outdated). It will check out the 3 code repos inside your setup directory and the roast will be checked out inside `rakudo/t/spec` directory.

You need to build different stuff, depending on what repos you modified:

- If you made changes in MoarVM, run `z m` to rebuild MoarVM
- If you made changes in NQP, run `z n` to rebuild NQP and Rakudo on top of it
- If you made changes in Rakudo, run `z` to rebuild Rakudo

In some cases, such as when modifying `Makefile`-related stuff or list of build files, you'll need to go through the full build cycle for a particular repo. In those cases, run `z build moar`, `z build nqp`, `z build rakudo```` to from-scratch rebuild MoarVM, NQP, and Rakudo respectively.

## Testing Stuff

Any change you wish to contribute must pass the "spectest". Simply run `z s` to run the test. On a typical computer, it'll take about 5-10 minutes to run. If you have a lot of CPU cores, you may choose to run "stresstest" *instead,* by running `z ss`, which takes about 160 seconds on a 24-core box.

Note that a couple of test files are known to fail (to "flop") on occasion.  You can re-run a particular test file by running `z t t/spec/The/Test-file.t`.  This command is also handy when you're adding new tests to roast and wish
to check they run OK.

To find a place where to put your new test, a rule of thumb is to `tree -f | grep -i ThingYou'reTesting` the [roast](https://github.com/raku/roast/) files to find any files for the feature you're testing. If that finds nothing, `grep -FIRn ThingYou'reTesting` can sometimes be helpful. If that fails too, you can either ask the core devs for a good place or just find some file.

Keep in mind, roast is the language specification that applies to all compilers, not just Rakudo. If you have a very specific test (like text content of error messages), it may be best to place that test into Rakudo's test suite, into `t/` (e.g. `t/05-messages/03-errors.t`).

Don't over-agonize about the location of the test. The spec gets reviewed before language release, so even if you place the test into the wrong place, it'll likely be relocated later.

## Submitting Stuff

Simply submit your work as a Pull Request on GitHub. If you already have a commit bit to a particular repository, feel free to commit directly if you're confident in your work and it isn't something controvercial. Otherwise, still submit a Pull Request.

## Tips and Stuff

Some tips for excellent bug fixing: write tests to cover the bug firsts. They should all fail and when they all pass you know you fixed the bug. And even if you fail to fix the bug, the tests can still be submitted to roast.

Think about the code you're fixing. Do similar routines have similar bug?  Is the bug present with other types of input? Often what's reported in the bug report covers just a part of the problem.

---

And again, if you need help, [just ask us](https://raku.org/irc-dev).
