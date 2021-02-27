# Introducing: Newcomer Guide to Contributing to Core Raku
    
*Originally published on [2 August 2018](https://perl6.party//post/Introducing-Newcomer-Guide-to-Contributing-to-Core-Perl-6) by Zoffix Znet.*

An important part of a project is to keep a steady flow of new volunteers coming on board to help you out (that's *Hug 1: Gift a Shovel* in the [Hole Digging Metaphor](/post/On-Troll-Hugging-Hole-Digging-and-Improving-Open-Source-Communities)). Starting out can be difficult: you barely know the people who you're working with and you're not familiar with the codebase or the build toolchain. A bug that will take a regular coredeveloper a minute to fix, test, and ship, might be insurmountable for someone who doesn't know where to start.

Raku can especially benefit from newcomer help, as core development is very easy to get into: a lot of bugs involve pure Raku code, mixed with some NQP subroutine calls that aren't much different than using subroutines from an ecosystem module.

For some time now, the Raku devs labeled easy Issues with particular labels.  However, that still leaves some challenges for new volunteers in place: knowing what the labels really mean, knowing how to build the project with the fix applied, and knowing how to run the tests.

## The Newcomer Guide

To address those issues, I drafted a [Newcomer Guide to Contributing to Core Raku](Newcomer-Guide-to-Contributing-to-Core-Raku.md) that will be linked to on specially labeled Issues. It's still an early version and will likely see several revisions based on the type of questions new volunteers ask.

It's meant to be a quick guide a programmer can read to get into contributing to Rakudo Raku. It's not meant to be exhaustive, so for example things like how to submit a Pull Request or make a commit with `git` are outside of its scope.

The Z-Script the guide uses haven't seen much battle testing by people without a commit bit to all the repos, so I suspect that will need some improvement as well, as people start to use it.

## To The Core Devs

Be sure to label easy issues with the labels mentioned in the guide. Encourage people to fix bugs. The person reporting the bug can be given a few tips on how to fix the very problem they're reporting and asked whether they wish to submit a fix. You never know when a one-off contributor will become a regular core developer.

The Guide promises the core devs will answer questions and help walk the interested volunteers through the fixes of specially labeled Issues, so keep an eye open for such questions and help people out. Also, when filing the Issues for newcomers, add a few tips and suggestions on how the Issue can likely be fixed.

## That's It

There isn't much else to say, other than [check out the Guide itself](Newcomer-Guide-to-Contributing-to-Core-Raku.md) and help make Raku better! :)
