# Rakudo Raku development release #17 ("Stockholm")
    
*Originally published on [21 May 2009](https://use-perl.github.io/user/pmichaud/journal/39014/) by Patrick Michaud.*

On behalf of the Rakudo development team, I'm pleased to announce
the May 2009 development release of Rakudo #17 "Stockholm".

Rakudo is an implementation of Raku on the Parrot Virtual Machine.
The tarball for the May 2009 release is available.

Due to the continued rapid pace of Rakudo development and the
frequent addition of new Raku features and bugfixes, we continue
to recommend that people wanting to use or work with Rakudo obtain
the latest source directly from the main repository at github.
More details are available at [https://rakudo.org/downloads](https://rakudo.org/downloads).

Rakudo follows a monthly release cycle, with each release code named
after a Perl Mongers group.  This release is named "Stockholm";
Stockholm Perl Mongers will be holding a Raku hackathon on May 29.
Raku developer Carl M&auml;sak is a member of Stockholm Perl Mongers and
a main author of November, Druid, proto, and other
Raku-based packages.  Carl also contributes patches to Rakudo,
and has been stress-testing Rakudo over the past year, submitting
nearly 400 bug reports.

In this release of Rakudo Perl, we've made the following major changes
and improvements:

- Rakudo is now passing 11,342 spectests, an increase of 875 passing tests since the April 2009 release.  With this release Rakudo is now passing 68% of the available spectest suite.
- We now have an updated docs/ROADMAP .
- Errors and stack traces now report the file name and line number in the original source code.
- Some custom operators can be defined, and it's possible to refer to operators using &infix:<op> syntax.
- We can start to load libraries written in other Parrot languages.
- Regexes now produce a Regex sub.
- More builtin functions and methods have been rewritten in Raku and placed as part of the setting.
- There are many additional improvements and features in this release, see docs/ChangeLog for a more complete list.

The development team thanks all of our contributors and sponsors for
making Rakudo Perl possible.  If you would like to contribute,
ask on IRC #raku on libera.chat..

The next release of Rakudo (#18) is scheduled for June 18, 2009.
A list of the other planned release dates and codenames for 2009 is
available in the "docs/release_guide.pod" file.  In general, Rakudo
development releases are scheduled to occur two days after each
Parrot monthly release.  Parrot releases the third Tuesday of each month.

Have fun!
