# Long Live Perl!
    
*Originally published on [19 January 2018](https://perl6.party//post/Long-Live-Perl-5) by Zoffix Znet.*

You probably have read a recent [Open Letter to the Perl Community](https://www.perl.com/article/an-open-letter-to-the-perl-community/). The letter has generated a lot of response ([173 reddit comments](https://www.reddit.com/r/perl/comments/7r1b33/an_open_letter_to_the_perl_community/) as I write this). Unfortunately, a lot of the responses are quite negative and do not match my understanding of the letter.

I figured I share my interpretation of the words and if that interpretation does not match the author's intent, I hope my interpretation captures the mood of the community on the matter.

## A Radical Idea

The first thing the letter talks about is what it calls a "radical idea". The suggestion is for Perl compiler to upgrade its backend. Instead of the current Perl VM the `perl` compiler uses, it would be ported to [NQP compiler toolkit](https://github.com/raku/nqp/) and will support all of the backends NQP supports, which currently is [MoarVM](https://github.com/MoarVM/MoarVM/), as the leading option, with JVM and JavaScript backends at various stages of completion as alternatives.

*Perl the language would remain as is,* but the new backend would allow the compiler to make use of modern features such as JIT compilation and good threading support. So to clarify, this wasn't a suggestion to port Perl to Perl 6, but merely to swap the backend Perl compiler uses.

[Perl Porters view this radical idea as a non-starter](https://www.nntp.perl.org/group/perl.perl5.porters/2018/01/msg248863.html) at the moment, so I think we can safely bury it and move on to the second idea the letter talks about

## Porting Modules

As I write this, the Perl 6 ecosystem [is 8 modules short of 1000 modules total](http://modules.raku.org/search/?q=). A lot of the needed features are currently missing native Perl 6 implementation and many users choose to use [Perl's CPAN ecosystem](https://metacpan.org/) via [`Inline::Perl5`](https://github.com/niner/Inline-Perl5#title) module.

While `Inline::Perl5` works rather well, it's not an ideal option for many developers. Thus, the Letter's author proposed an incentive for people to port much-needed Perl modules to Perl 6 in the form of a leaderboard and potential support from sponsors who would donate to [Perl 6 Core development fund](http://www.perlfoundation.org/perl_6_core_development_fund) in exchange for ported modules.

So to clarify, the goal behind the porting of modules is merely to beef up Perl 6's ecosystem and is not an implication that Perl users have to or even might want to move to any other language.

## The Elephant in The Room

While not mentioned in the original Letter, a frequent theme [in the comments](https://www.reddit.com/r/perl/comments/7r1b33/an_open_letter_to_the_perl_community/) was that Perl 6 should be renamed, as the name is inaccurate or is damaging.

This is the topic on which I wrote [more](https://rakudo.party/post/The-Hot-New-Language-Named-Perl 6do) than [once](https://rakudo.party/post/6lang-The-Naming-Discussion-Update) and those who have been following closely know that, yes, many (but by no means all) in the Perl 6 community acknowledge the name is detrimental to both Perl 6 and Perl projects.

This is why with [a nod of approval from Larry](https://www.youtube.com/watch?time_continue=4885&v=E5t8qaAGw9w) we're [moving to](https://github.com/raku/6.d-prep/tree/master/TODO#language-extended-naming) create an *alias* to Perl 6 name during [6.d language release](https://github.com/raku/6.d-prep), to be available for marketing in areas where "Perl 6" is not a desirable name.

While some may feel an alias—as opposed to a full rename—is not quite what they desired, I believe if the alternate name is as beneficial as the proponents of the rename believe it to be, the alias will naturally be able to overtake "Perl 6" name in usage and become the primary name through sheer amount of use. Thus, the alias can be seen as the chance for the rename crowd to prove their claims.

## Long Live Perl!

Perl 6 isn't a desirable language for many Perl users, for various reasons. That's perfectly valid and is understandable. Perl 6 is quite different from its sister language and the choice to switch to it isn't much different than choosing whether to switch to Ruby, Go, Rust, or any other of the multitude of languages available.

Since Perl is actively maintained, its users should not feel compelled to migrate to anything else, and should continue using what works for them, regardless of what opinions members of other programming communities might hold.

## Conclusion

The Letter suggested a radical idea that the `perl` compiler's backend be ported from Perl VM to NQP that supports multiple modern VMs. Based on the response to the proposal, it does not appear to be viable at the current time. The more prominent suggestion in the Letter is the call to port Perl modules to Perl 6, to help Perl 6 users get native-Perl 6 access to valuable Perl modules.

While there are Perl 6 users who believe Perl 6 is superior to Perl, it does not mean Perl users should feel compelled to upgrade to anything but the [latest stable version of Perl](https://www.perl.org/get.html).

I hope that regardless of which flavour of Perl we choose to use and call our favourite, we can unite and exist together as [The Perl Community](https://www.youtube.com/watch?v=E5t8qaAGw9w&feature=youtu.be&t=1h22m9s).
