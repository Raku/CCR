# Rakudo Star 2010.08 released
    
*Originally published on [1 September 2010](https://use-perl.github.io/user/pmichaud/journal/40518/) by Patrick Michaud.*

[This announcement was made last week on rakudo.org -- I'm reposting to use-perl.github.io so it will show up in the various Perl aggregators. --Pm]

On behalf of the Rakudo and Raku development teams, I'm happy to announce the August 2010 release of "Rakudo Star", a useful and usable distribution of Raku. The tarball for the August 2010 release is [available](https://github.com/rakudo/star/downloads).

Rakudo Star is aimed at "early adopters" of Raku. We know that it still has some bugs, it is far slower than it ought to be, and there are some advanced pieces of the Raku language specification that aren't implemented yet. But Rakudo in its current form is also proving to be viable (and fun) for developing applications and exploring a great new language. These "Star" releases are intended to make Raku more widely available to programmers, grow the Raku codebase, and gain additional end-user feedback about the Raku language and Rakudo's implementation of it.

In the Raku world, we make a distinction between the language ("Raku") and specific implementations of the language such as "Rakudo Perl". The August 2010 Star release includes release #32 of the Rakudo compiler, version 2.7.0 of the Parrot Virtual Machine, and various modules, documentation, and other resources collected from the Raku community.

This release of Rakudo Star adds the following features over the previous Star release:
- Nil is now undefined
- Many regex modifiers are now recognized on the outside of regexes
- Mathematic and range operations are now faster (they're still slow, but they're significantly faster than they were in the previous release)
- Initial implementations of .pack and .unpack
- MAIN can parse short arguments
- Removed a significant memory leak for loops and other repeated blocks

This release (temporarily?) omits the Config::INI module that was included in the 2010.07 release, as it no longer builds with the shipped version of Rakudo. We hope to see Config::INI return soon.

There are some key features of Raku that Rakudo Star does not yet handle appropriately, although they will appear in upcoming releases. Thus, we do not consider Rakudo Star to be a "Raku.0.0" or "1.0" release. Some of the not-quite-there features include:
- nested package definitions
- binary objects, native types, pack and unpack
- typed arrays
- macros
- state variables
- threads and concurrency
- Unicode strings at levels other than codepoints
- pre and post constraints, and some other phasers
- interactive readline that understands Unicode
- backslash escapes in regex <[...]> character classes
- non-blocking I/O
- most of Synopsis 9
- rakudoc or pod manipulation tools

In many places we've tried to make Rakudo smart enough to inform the programmer that a given feature isn't implemented, but there are many that we've missed. Bug reports about missing and broken features are welcomed.

See [https://raku.org](https://raku.org) for links to much more information about Raku, including documentation, example code, tutorials, reference materials, specification documents, and other supporting resources. An updated draft of a Raku book is available as "docs/UsingPerl6-draft.pdf" in the release tarball.

The development team thanks all of the contributors and sponsors for making Rakudo Star possible. If you would like to contribute, see <url:http://rakudo.org/how-to-help>, ask on the rakuompiler@perl.org mailing list, or join us on IRC channel #raku on freenode.

Rakudo Star releases are created on a monthly cycle or as needed in response to important bug fixes or improvements. The next planned release of Rakudo Star will be on September 28, 2010.
