# The compiler formerly known as 'raku'
    
*Originally published on [16 January 2008](https://use-perl.github.io/user/pmichaud/journal/35400/) by Patrick Michaud.*

We've finally come up with a name for the Raku on Parrot compiler, it's now "Rakudo Perl", or just "Rakudo" for short.  This name was suggested by Damian -- he writes:
```
Some years ago, Con Wei Sensei introduced a new martial art: "The Way
Of The Camel". Or, in Japanese: "Rakuda-do". This name quickly became
abbreviated to "Rakudo", which happens to mean "paradise" in Japanese.
```

Perhaps "rakudo" would suit, since:

* "Of The Camel" clearly connotes Perl
* Perl on Parrot is definitely the Way
* The name meets Hugo's Obscurity-for-Search criterion (at least for non-Japanese-language searches)
* It's nevertheless a real word (in one language)
* It may help us steal back mindshare from Ruby in its home market

For the time being Rakudo will continue to live in the languages/raku/ subdirectory of the Parrot repository, and we'll continue to build the bytecode and executable as "raku.pbc" and "raku(.exe)".  My current expectation is that someday Rakudo will live in its own repository separate from Parrot, and we can decide then if any file renaming needs to take place.

So, we're now at the point where we can say that the term "Raku" strictly refers to a language specification, while terms such as "Pugs", "Rakudo", and "kp6" refer to implementations of Raku.  Hopefully this will reduce some confusion.

Several people have also inquired about a release numbering scheme for Rakudo.  My current position on this topic is to postpone any decision until we start making releases that are separate from Parrot releases.  I think a postponement here is especially appropriate since we're still in the "rapid expansion phase" of the implementation.  In the meantime, whenever we need to reference a specific version of Rakudo we can use either a specific date or a subversion revision number from the Parrot repository.
