# Rakudo Raku development release #18 ("Pittsburgh")
    
*Originally published on [19 June 2009](https://use-perl.github.io/user/pmichaud/journal/39149/) by Patrick Michaud.*

On behalf of the Rakudo development team, I'm pleased to announce
the June 2009 development release of Rakudo #18 "Pittsburgh".
Rakudo is an implementation of Raku on the Parrot Virtual Machine.
The tarball for the June 2009 release is available.

Due to the continued rapid pace of Rakudo development and the
frequent addition of new Raku features and bugfixes, we continue
to recommend that people wanting to use or work with Rakudo obtain
the latest source directly from the main repository at github.
More details are available.

Rakudo follows a monthly release cycle, with each release code named
after a Perl Mongers group.  This release is named "Pittsburgh", which
is the host for YAPC|10 and the Parrot Virtual Machine Workshop.  Pittsburgh.pm has also sponsored hackathons for Rakudo 
as part of the 2008 Pittsburgh Perl Workshop.

In this release of Rakudo, we've focused our efforts on refactoring
many of Rakudo's internals; these refactors improve performance, 
bring us closer to the Raku specification, operate more cleanly
with Parrot, and provide a stronger foundation for features to be
implemented in the near future.  Some of the specific major changes
and improvements in this release include:

- Rakudo is now passing 11,536 spectests, an increase of 194 passing tests since the May 2009 release.  With this release Rakudo is now passing 68% of the available spectest suite.
- Method dispatch has been substantially refactored; the new dispatcher is significantly faster and follows the Raku specification more closely.
- Object initialization via the BUILD and CREATE (sub)methods is substantially improved.
- All return values are now type checked (previously only explicit 'return' statements would perform type checking).
- String handling is significantly improved: fewer Unicode-related bugs exist, and parsing speed is greatly improved for some programs containing characters in the Latin-1 set.
- The IO .lines and .get methods now follow the specification more closely.
- User-defined operators now also receive some of their associated meta variants.
- The 'is export' trait has been improved; more builtin functions and methods can be written in Raku instead of PIR.
- Many Parrot changes have improved performance and reduced overall memory leaks (although there's still much more improvement needed).

The development team thanks all of our contributors and sponsors for
making Rakudo possible.  If you would like to contribute
ask on IRC #raku on libera.chat.

The next release of Rakudo (#19) is scheduled for July 23, 2009.
A list of the other planned release dates and codenames for 2009 is
available in the "docs/release_guide.pod" file.  In general, Rakudo
development releases are scheduled to occur two days after each
Parrot monthly release.  Parrot releases the third Tuesday of each month.

Have fun!
