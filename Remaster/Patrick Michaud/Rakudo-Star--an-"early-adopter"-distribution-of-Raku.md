# Rakudo Star - an "early adopter" distribution of Raku
    
*Originally published on [29 July 2010](https://use-perl.github.io/user/pmichaud/journal/40469/) by Patrick Michaud.*

On behalf of the Rakudo and Raku development teams, I'm happy to announce the July 2010 release of "Rakudo Star", a useful and usable distribution of Raku.  The tarball for the July 2010 release is {available](https://github.com/rakudo/star).

Rakudo Star is aimed at "early adopters" of Raku.  We know that it still has some bugs, it is far slower than it ought to be, and there are some advanced pieces of the Raku language specification that aren't implemented yet.  But Rakudo in its current form is also proving to be viable (and fun) for developing applications and exploring a great new language.  These "Star" releases are intended to make Raku more widely available to programmers, grow the Raku codebase, and gain additional end-user feedback about the Raku language and Rakudo's implementation of it.

In the Raku world, we make a distinction between the language ("Raku") and specific implementations of the language such as "Rakudo Perl".  "Rakudo Star" is a distribution that includes release #31 of the Rakudo compiler, version 2.6.0 of the Parrot Virtual Machine, and various modules, documentation, and other resources collected from the Raku community.  We plan to make Rakudo Star releases on a monthly schedule, with occasional special releases in response to important bugfixes or changes.

Some of the many cool Raku features that are available in this release of Rakudo Star:

- Raku grammars and regexes
- formal parameter lists and signatures
- metaoperators
- gradual typing
- a powerful object model, including roles and classes
- lazy list evaluation
- multiple dispatch
- smart matching
- junctions and autothreading
- operator overloading (limited forms for now)
- introspection
- currying
- a rich library of builtin operators, functions, and types
- an interactive read-evaluation-print loop
- Unicode at the codepoint level
- resumable exceptions

There are some key features of Raku that Rakudo Star does not yet handle appropriately, although they will appear in upcoming releases.  Thus, we do not consider Rakudo Star to be a "Raku.0.0" or "1.0" release.  Some of the not-quite-there features include:

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


In many places we've tried to make Rakudo smart enough to inform the programmer that a given feature isn't implemented, but there are many that we've missed.  Bug reports about missing and broken features are welcomed.

See [https://raku.org/](https://raku.org/) for links to much more information about Raku, including documentation, example code, tutorials, reference materials, specification documents, and other supporting resources.

Rakudo Star also bundles a number of modules; a partial list of the modules provided by this release include:

-  Blizkost - enables some Perl modules to be used from within Rakudo
-  MiniDBI - a simple database interface for Rakudo
-  Zavolaj - call C library functions from Rakudo
-  SVG and SVG::Plot - create scalable vector graphics
-  HTTP::Daemon - a simple HTTP server
-  XML::Writer - generate XML
-  YAML - dump Raku objects as YAML
-  Term::ANSIColor - color screen output using ANSI escape sequences
-  Test::Mock - create mock objects and check what methods were called
-  Math::Model - describe and run mathematical models
-  Config::INI - parse and write configuration files
-  File::Find - find files in a given directory
-  LWP::Simple - fetch resources from the web


These are not considered "core Raku modules", and as module development for Raku continues to mature, future releases of Rakudo Star will likely come bundled with a different set of modules. Deprecation policies for bundled modules will be created over time, and other Raku distributions may choose different sets of modules or policies.  More information about Raku modules can be found at [Raku land](https://raku.land).

Rakudo Star also contains a draft of a Raku book -- see "docs/UsingPerl6-draft.pdf" in the release tarball.

The development team thanks all of the contributors and sponsors for making Rakudo Star possible.  If you would like to contribute, join us on IRC #raku on libera.chat.

Rakudo Star releases are created on a monthly cycle or as needed in response to important bug fixes or improvements.  The next planned release of Rakudo Star will be on August 24, 2010.
