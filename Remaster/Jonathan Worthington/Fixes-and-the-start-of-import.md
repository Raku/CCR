# Fixes and the start of import
    
*Originally published on [25 March 2009](https://use-perl.github.io/user/JonathanWorthington/journal/38700/) by Jonathan Worthington.*

This is a report for my Rakudo day last week, which finished up pretty late and thus I didn't get around to writing up and posting a report. Much of the day saw me headachey and not really feeling up to working on big stuff, so I did small stuff instead - mostly bug fixes. Those were:

- Fixing a regression that was introduced by recent work to make outer lexicals visible inside of eval, and adding a test to make sure we don't regress on it in the future. (I got this patch in before the month's Rakudo release, so the regression wasn't present in that).
- Doing a use of one module from within another could end up in the non-precompiled case with the module ending up nested inside the namespace of the one that used it, due to re-entrancy issues. A similar re-entrancy fix dealt with another bug where we should have flagged something up as an error, but failed to do so due to lingering state.
- `prompt` could be a little bit too lazy. If you call it in void context and never assigned its return value, then it would never actually prompt the user for input! Well, glad we caught it now rather than it living on as an unintended feature. :-)
- Implemented renaming of named parameters, so you can expose an external name for it and then store it in a variable of a different name. For example: `sub foo(:t($temperature)) { ... }` expects to be passed a named parameter `t`, but stores it in the scalar `$temperature`.
- Fixed `$*IN`, `$*OUT` and `$*ERR` as part of some work to generally improve interaction with things from outside of Rakudo in Parrot.

I also during the day started moving bits of Rakudo's I/O into the Raku setting. There are some bits of embedded PIR, but very little, since the handle we store is a Parrot I/O object which we are able to call methods on anyway. I'm hopeful that we can have all of I/O moved into the setting and written mostly in Raku in the near future.

Finally, in the evening and once my headache had gone, I worked out a very first cut of importing. It only imported things set to be exported by default, and didn't have handling of multis quite right, but it laid the foundations for further work in the area.

Thanks to Vienna.pm for sponsoring this work.
