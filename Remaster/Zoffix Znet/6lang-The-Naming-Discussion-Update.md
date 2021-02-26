# 6lang: The Naming Discussion Update
    
*Originally published on [28 September 2017](https://perl6.party//post/6lang-The-Naming-Discussion-Update) by Zoffix Znet.*

When a couple months ago [I rekindled the naming debate](https://perl6.party/post/The-Hot-New-Language-Named-Rakudo)—the discussion on whether "Perl 6" should be renamed—I didn't expect anything more than a collective groan. That wasn't the case and today, I figured, I'd post a progress report and list the salient happenings, all the way to my currently being the proud owner of [6lang.party](https://6lang.party) domain name.

## The "Rakudo" Language

The "new" name I mentioned in my original post was *Rakudo*. As many quickly pointed out, it wasn't the greatest of names because it was the name of *an* implementation. Yes, I agree, but originally I thought few, if any, would be on board with a new name, or extended name, and *Rakudo* was basically the only name people *already* were using, so it stood out as something that could be "hijacked."

## The Blog Post Fallout

There was quite a bit of discussion on [r/perl](https://www.reddit.com/r/perl/comments/6lstqu/the_hot_new_language_named_rakudo/), [r/raku](https://www.reddit.com/r/raku/comments/6lstq3/the_hot_new_language_named_rakudo/), and [blogs.perl.org](http://blogs.perl.org/users/zoffix_znet/2017/07/the-hot-new-language-named-rakudo.html#comments). The general mood among the Perl community members who aren't avid 6lang users was that the entirely new name was a good idea. However, the 6lang users, and especially core devs, overall, argued "Perl 6" still had some recognition benefits and should not be removed entirely.

The middle ground was aimed at then: *extend* the language name. The "official" name would be among the lines of "*Blah* Perl 6" and users opposed to the 4-letter swear word would just use the name extension on its own, while those who feel the original name has benefits can still reap them.

The decision on the naming extension was placed [on the 6.d language release agenda](https://github.com/raku/6.d-prep/tree/master/TODO#language-extended-naming), with the final call on whether and with what the name should to be extended to be done by *Larry*, when we cut the 6.d language release.

## The 6lang

Fast-forward two months. A kind soul (thank you, by the way!) asked *Larry*
what he thought about the naming debate during the last Perl Conference:

[*Larry*'s thoughts on the naming debate](https://www.youtube.com/embed/E5t8qaAGw9w?start=4885)

*Larry* opined that we could have other terms by which Perl versions or Perl distributions are marketed as. So that gives us an option to pick an alternative name to be the second name with any "official" standing.  Personally, I really like this idea; even more than name extension, because should there indeed be more benefit to the name without "Perl" in it, the alternative name will naturally become the most-used one.

Another core dev, *AlexDaniel*++, coined an alternative name: spelt **6lang**; can be pronounced as **slang**, if you want to be fancy.  I really liked the name, so I jumped in and registered [6lang.party](https://6lang.party)

> <AlexDaniel> *Zoffix*++ for making me recognize the need for alternative name. For a long time I was against and honestly, I can start using something like 6lang right away. "Rakudo Perl 6" is infringing on language/compiler distinction so I'm feeling reluctant

> <Zoffix> OK, I'll too start using 6lang. *Zoffix* is now a proud owner of 6lang.party :D

> <timotimo> wow>

> <AlexDaniel> that was quick

And a couple of hours later, our Marketing Department churned out a [new poster](https://github.com/raku/marketing/tree/master/TablePosters/6lang-Concise):

![6lang](6lang.png)

The drawback is that the name can't be used as an identifier… and *Larry* doesn't think it's a terribly sexy name.

> *TimToady* notes that 6lang isn't gonna work anywhere an identifier needs a leading alpha

> <TimToady> it's also not a terribly sexy name

> <TimToady> I could go for something more like psix, 'where the p is silent if you want it to be' :)

Although, on the plus side, the name has the benefit that alphabetically it sorts earlier than pretty much any other language.
  
> <AlexDaniel> If we see "6lang" as a more marketable alternative, then the fact that some things may not parse it as an identifier practically does not matter. However, this little bit is quite useful:

> <AlexDaniel> m: <perl5 golang c# 6lang ruby>.sort.say

> <camelia> rakudo-moar 39a4b7: OUTPUT: «(6lang c# golang perl5 ruby)␤»

> <AlexDaniel> :)

> <AlexDaniel> .oO( AAAlang - batteries included )

## To 6.d Release And Beyond

So that's where things progressed to so far. No official decisions have been made yet, but we're thinking about it and playing with the idea. The decision on the naming debate is to be made during 6.d release.

Having learned a painful lesson from *The Christmas* release, we're reluctant to put down any dates for 6.d release, but I suspect it'll be somewhere between the upcoming New Year's and It's-Ready-When-It's-Ready.

See you then \o
