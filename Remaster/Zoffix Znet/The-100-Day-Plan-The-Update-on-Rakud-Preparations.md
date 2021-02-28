# The 100 Day Plan: The Update on Raku.d Preparations
    
*Originally published on [9 August 2018](https://perl6.party//post/The-100-Day-Plan-The-6-d-Update) by Zoffix Znet.*

Today's is a milestone of sorts: it's 100 days before the first scheduled Rakudo Raku compiler release that will occur after this year's [festival of Diwali](https://en.wikipedia.org/wiki/Diwali). As some know, *Diwali* is also the code name for the next major release of the Raku language, version 6.d, which means there's a high chance that in about 100 days you'll be able to install and use that.

I figured, I'd write a update on the subject.

## When?

The oft-asked questions is when is 6.d going to be released. The plan is to have the 6.d specification good and ready to release on this year's Diwali, which is November 6-7.

About 10 days later the Rakudo compiler will be released (compiler-only, not the Rakudo Star), with 6.d language enabled by default. That is, you'll no longer need to use `use v6.d.PREVIEW` pragma to get 6.d features, and if you wish to get old, 6.c behaviour you'll need to use an explicit `use v6.c` pragma.

However, there's a ton of work to do and the work is largely done by volunteers, so we have no compunction about delaying the release of any of the deliverables indefinitely, if the need arises.

## What?

The 6.d major version of the Raku programming language includes over 3,400 new commits in its specification. The vast majority of these are [**clarifications to 6.c spec**](https://rakudo.party/post/Perl6-On-Specs-Versioning-Changes-And-Breakage). In other words, most of these define previously undefined behaviour, rather than specify entirely new features.

Many of the clarifications and new features do not conflict with the 6.c specification. If you're using the Rakudo compiler, you are likely already reaping some of the benefits of the 6.d language, as such things do not require explicit `use v6.d.PREVIEW` pragma.

Those who've seen the [6.d Teasers](https://marketing.raku.org/) frequently ask for the full list of 6.d changes. That list does not yet exist, as the spec is still in the process of being reviewed. The changelog will be available some time in October. You may have seen the 6.d prep repo, but that just contains guiding info for coredevs and isn't descriptive of the actual 6.d content.

The aforementioned ton of work includes:

- Still have to review about 2,100 spec commits
- Still have ~95% of ChangeLog to write
- Still have to implement 7 TODO features, costing 110 hours
- Still have 0.3 policies to write (a draft already exists, but needs polishing)
- Review and spec of any new features that were implemented in Rakudo but were not specced in the language
- Marketing stuff regarding creation of marketing name alias for the language

## The Future

Going forward for future language releases, I foresee us doing a point release every 6 months, and 6.e being released 2 or 3 years after 6.d. The [previously 6.d-blocking Issue R#1289](https://github.com/rakudo/rakudo/issues/1289) still blocks a number of language changes, and all the 6.d changes blocked by that Issue were pushed to later language versions. So, if that Issue is resolved, that will likely be a reason to cut a language release soon thereafter.

## Conclusion

The prep work for next major release of the Raku Programming Language version 6.d (Diwali) is in a high gear. There's lots of work to do. Will likely release spec on November 7th, with compiler release following step and being released about 2 weeks after that. The list of changes will be ready in October and does not currently exist in any user-consumable form.

Let the hype begin \o/

-Ofun
