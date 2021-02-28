# Perl 6: On Specs, Versioning, Changes, and… Breakage
    
*Originally published on [20 February 2018](https://perl6.party//post/Perl6-On-Specs-Versioning-Changes-And-Breakage) by Zoffix Znet.*

Recently, I came across a [somewhat-frantic comment](https://stackoverflow.com/questions/48488381/rakuomparison-operator#comment83973425_48489204) on StackOverflow that describes a 2017.01 change to the type of return value of [`.sort`](https://docs.raku.org/routine/sort):
  
> *"you just can't be sure what `~~` returns"* Ouch. […] `.list` the result of a `sort` is presumably an appropriate work around. But, still, ouch. I don't know of a blog post or whatever that explains how Perl 6 approaches changes to the language; and to roast; and to Rakudo. Perhaps someone will write one that also explains how this aspect of 2017.01 was conceived, considered and applied; what was right about the change; what was wrong; etc.

Today, I decided to answer that call to write a blog post and reply to all of the questions posed in the comment, as well as explain how it's possible that such an "ouch" change made it in.

## On Versioning

The '6' in Perl 6 is just part of the name. The language version itself is encoded by a sequential letter, which is also the starting letter of a codename for that release. For example, the current stable language version is `6.c "Christmas"`. The next language release will be `6.d` with one of the proposed codenames being `"Diwali"`. The version after that will be `6.e`, then `6.f`, and so on.

If you've used Perl 6 sometime between 2015 and 2018, you likely used the "Rakudo" compiler, which is often packaged as "Rakudo Star" distribution and is versioned with the year and the month of the release, e.g. release `2017.01`.

In some languages, like Perl 6's sister language Perl, what the compiler does *is* what the language itself is. Bugs aside, if the latest (2017.09) Perl compiler gives 4 for 2+2, then that's the definition of what 2+2 is in the Perl language.

In Perl 6, however, how a compiler (e.g. "Rakudo") behaves or what it implements does **not** define the Perl 6 language. The [Perl 6 language specification](https://github.com/raku/roast/) does. The specification consists of a test suite of about 155,000 tests and anything that passes that test suite can call itself a "Perl 6 compiler".

It's to *this* specification version `6.c "Christmas"` refers. It was released on December 25, 2015 and at the time of this writing, it's the first and only release of a stable language spec. Aside from a few error corrections, there were *no changes to that specification*… The latest version of Rakudo still passes every single test—it's a release requirement.

## On Changes

Ardent Perl 6 users would likely recall that there *have* been many changes in the Rakudo compiler since Christmas 2015. Including the "ouch" change referenced by that StackOverflow comment. If the specification did not change and core devs are not allowed to make changes that break 6.c specification, how is it possible that the return type of [`.sort`](https://docs.raku.org/routine/sort) could have changed?

The reason is—and I hope the other core devs will forgive me for my choice of imagery—the specification is full of holes!

![full of holes](cheese1.jpg)

It doesn't (yet) cover every imaginable use and combination of features.  What happens when you try to [`print`](https://docs.raku.org/routine/print) a [`Junction`](https://docs.raku.org/type/Junction) of strings? As far as 6.c version of Perl 6 language is concerned, that's undefined behaviour. What object do you get if you call [`.Numeric`](https://docs.raku.org/routine/Numeric) on an [`Rat`](https://docs.raku.org/type/Rat) *type object* rather than an instance?  Undefined behaviour. What about the return value of [`.sort`](https://docs.raku.org/routine/sort)? You'll get sorted values in an [`Iterable`](https://docs.raku.org/type/Iterable) type, but whether that type is a [`Seq`](https://docs.raku.org/type/Seq) or a [`List`](https://docs.raku.org/type/List) is not specified by the 6.c specification.

This is how 2017.01 version of Rakudo managed to change the return type of [`.sort`](https://docs.raku.org/routine/sort), despite being a compliant implementation of the 6.c language—the spec was not precise about what [`Iterable`](https://docs.raku.org/type/Iterable) type [`.sort`](https://docs.raku.org/routine/sort) must return; both [`Seq`](https://docs.raku.org/type/Seq) and [`List`](https://docs.raku.org/type/List) are [`Iterable`](https://docs.raku.org/type/Iterable), thus both conform to the spec. (It's worth noting that since 2017.01 we implemented [an extended testing framework](https://rakudo.party/post/Perl-6-Release-Quality-Assurance-Full-Ecosystem-Toaster) that also guides our decisions on whether we actually allow changes that don't violate the spec).

In my personal opinion, the 6.c spec is overly sparse in places, which is why we saw a number of large changes in 2016 and early 2017, including the "ouch" change the commenter on StackOverlow referred to. But… it won't stay that way forever.

## The Future of the Spec

At the time of this writing, there have been 3,129 commits to the spec, since 6.c language release. These are the proposals for the 6.d language specification. While some of these commits address new features, a lot of them close those holes the 6.c spec contains.  The main goal is not to write a "whole new spec" but to refine and clarify the previous version.

Thus, when 6.d is released, it'll look something like this:

![fewer holes](cheese2.jpg)

A few more slices of new features, but largely the same thing. Still some holes (undefined behaviour) in it, but a lot less than in 6.c language. It now defines that [`print`](https://docs.raku.org/routine/print)ing a [`Junction`](https://docs.raku.org/type/Junction) will thread it; that calling [`.Numeric`](https://docs.raku.org/routine/Numeric) on a [`Numeric`](https://docs.raku.org/type/Numeric) type object gives a numeric equivalent of zero of that type and a warning; and that the [`.sort`](https://docs.raku.org/routine/sort)'s [`Iterable`](https://docs.raku.org/type/Iterable) return type is a [`Seq`](https://docs.raku.org/type/Seq), not a [`List`](https://docs.raku.org/type/List).

As more uses of combinations original designers haven't thought of come around, even more holes will be covered in future language versions.

## Breaking Things

The cheese metaphor covers refinements to the specification, but there's another set of changes the core developers sometimes have to make: changes that violate previous versions of the specification. For 6.d language, the list of such changes is available in [our 6.d-prep repository](https://github.com/raku/6.d-prep/blob/master/TODO/FEATURES.md) (some of the listed changes don't violate 6.c spec, but still have significant impact so we pushed them to the next language version).  
This may seem to be a contradiction: didn't I say earlier that passing 6.c specification is part of the compiler's release requirements? The key to resolving that contradiction lies in ability to request different language versions in
different comp units (e.g. in different modules) that are used **by the same** program.

A single compiler can support multiple language versions.  Specifying `use v6.c` pragma loads 6.c language. Specifying `use v6.d` (currently available as `use v6.d.PREVIEW`) loads 6.d language. Not specifying anything loads the newest version the compiler supports.

One of the changes between 6.c and 6.d languages is that `await` no longer blocks the thread in 6.d. We can observe this change using a single small script that loads two modules. The code between the two modules is the same, except they request different language versions:

```` raku
# file ./C.pm6
use v6.c;
sub await-c is export {
    await ^10 .map: {
        start await ^5 .map: { start await Promise.in: 1 }
    }
    say "6.c version took $(now - ENTER now) secs";
}
# file ./D.pm6
use v6.d.PREVIEW;
sub await-d is export {
    await ^10 .map: {
        start await ^5 .map: { start await Promise.in: 1 }
    }
    say "6.d version took $(now - ENTER now) secs";
}
# $ raku -I. -MC -MD -e 'await-c; await-d'
# 6.c version took 2.05268528 secs
# 6.d version took 1.038609 secs
````

When we run the program, we see that no-longer blocked threads let 6.d version complete a lot faster (in fact, if you bump the loop numbers by a factor, 6.d would still complete, while 6.c would deadlock).

So this is the Perl 6 mechanism that lets the core developers make breaking changes without breaking user's programs. There are some limitations to it (e.g. methods on classes)—so for some things there still will be standard deprecation procedures. We also try to limit the number of such spec-breaking changes, to reduce the maintenance burden and impact on users who don't want to lock their code down to some older version. Thus, don't worry about getting some weird new language on the next language release—the differences will be minimal.

## Who Decides?

This all brings us to one of the questions posed by that StackOverflow user: how do language changes get conceived, considered, and applied—in short: who decides what the behaviour is to be like? What is the process?

As far as conception goes, many of the current ideas are based on seeing what our users need. Some proposals [come directly from users](https://github.com/rakudo/rakudo/issues/1245); others [get inspired](https://github.com/rakudo/rakudo/issues/1546) as more elegant solutions to problems users showed they were trying to solve.  [Some](https://github.com/raku/6.d-prep/blob/master/TODO/FEATURES.md#make-start-blocks-in-sink-context-attach-an-error-handler) of the [changes](https://github.com/raku/6.d-prep/blob/master/TODO/FEATURES.md#make-argfiles--in-or-ioargfilesnewin-inside-main) proposed for 6.d language were informed by problematic areas of currently-implemented features that weren't foreseen during original implementation.

When it comes to implementation, the scope of the feature and core developer's expertise with the given area of the codebase generally drive the process.  With the "ouch" change, the expert in the area of [`Iterable`](https://docs.raku.org/type/Iterable)s deemed [`Seq`](https://docs.raku.org/type/Seq) to  be a superior type for [`.sort`](https://docs.raku.org/routine/sort) to return, due to its non-caching behaviour as well as its ease of degenerating into a caching [`List`](https://docs.raku.org/type/List).

Some changes [get opened as an Issue on the bugtracker](https://github.com/rakudo/rakudo/issues/1546) first, to notify other devs of the impending change. Large changes usually get [a proposed design](https://github.com/rakudo/rakudo/blob/master/docs/archive/constants-type-constraints-proposal-2018-02-10.md) written down first. The proposal is shared with the core devs and feedback is gathered before the proposal is actually implemented.  The implementation of significant things is also merged far away from the date of the next release, to let the bleeding-edge users find any potential problems in the work.

[*Geth*](https://github.com/raku/geth), our IRC bot, [announces](https://irclog.perlgeek.de/rakuev/2018-02-20#i_15838016) all commits in our [development IRC channel](https://webchat.freenode.net/?channels=#rakuev). Most of the core devs backlog that channel, so any of the potentially problematic commits—even if one of the devs goes ahead and commits the change—get discussed and at times reverted.

The Perl 6 [pumpking](https://perldoc.perl.org/perlhist.html#THE-KEEPERS-OF-THE-PUMPKIN) (Jonathan Worthington) and the [BDFL](https://en.wikipedia.org/wiki/Benevolent_dictator_for_life) (Larry Wall) are available to provide feedback on controversial, questionable, or large changes being proposed. They also have the veto power on any changes. Our messaging bot helps us request feedback from them, even if they're currently not in the chat.

When it comes to errata to previous specifications, unless the test to be changed is "obviously wrong", the decision on whether the errata can be applied is delegated to the Release Manager (AlexDaniel), and informed by the pumpking/BDFL, if required.

## The Future

The current process is a bit loose in places. A test that's "obviously wrong" to one person might have some valid reasons behind it to someone else. This is why the TODO for 6.d release lists [several documents](https://github.com/raku/6.d-prep/tree/master/TODO#define-more-concrete-spec-errata-rules) to be written that will refine the procedures for various types of changes.

It won't be on the scale of [PEP](https://www.python.org/dev/peps/pep-0001/), but simply something more concrete for the core devs to refer to, when performing changes that have some impact on the users. It's a balancing act between organization and procedure and letting through a consistent flow of contributions.

And if breaking changes have to be made, an alert will be pushed to the the [Perl 6lert service](https://rakudo.party/post/Announcing-Perl 6lert-Perl-6-Alerts-Directly-From-Core-Developers) for users of Perl 6 to get informed of them in advance.

## Conclusion

Today, we gleaned an insight into how Perl 6 core devs introduce changes to the compiler and the language.

The language specification and the compiler's behaviour are separate entities. The 6.c language specification has places of unspecified behaviour, which is how changes that have large impact on the users slipped through in the past.

The extended testing framework as well as specification clarifications offered by 6.d language proposal tests that refine the specification and close the holes with undefined behaviour reduce unforeseen impact on the users.

The core dev team informs their decisions based on user's feedback and the way the language is used by the community. Large changes get written up as proposals and the pumking/BDFL offer advise on anything controversial.

In the future, more refined practices for how changes are made will be defined, as we work on making upgrade experience more predictable and non-breaking for our users. The [Perl 6lert service](https://rakudo.party/post/Announcing-Perl 6lert-Perl-6-Alerts-Directly-From-Core-Developers) helps that goal and is already available today.

Hope this answers all the questions :)
