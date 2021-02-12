# Raku Hacking At GPW
    
*Originally published on [15 February 2008](https://use-perl.github.io/user/JonathanWorthington/journal/35664/) by Jonathan Worthington.*

I've been at the German Perl Workshop for the last few days. While I was sat in a bunch of talks being presented in a language I don't understand, I had some free time to hack on Rakudo. That means there's been a few fixes and some new features.

First, I set about doing some re-factoring to the objects work I had done so far. It had wound up with a lot of inline PIR in actions.pm, and that in turn fixed us to one class system, which was fine for a first-cut implementation to get a few things working, but far from what S12 calls for. Now all the inline PIR I added is gone, replaced by calls to methods written in PIR.

With the refactoring done, it was then far easier to add what is needed to have methods in classes resolving conflicts and taking precedence during role composition. Of course, exactly how well the roles implementation matches S12 is yet to be seen, and that calls for lots of tests. I'll be drawing on the Moose ones for that.

With some basic OO support in and ready for people to play with, I moved on to looking at the regex support. There was already some there, but I've put in a bit more. `$/` (the match variable) wasn't being passed into inner scopes, so if you did a pattern match in the condition of an if block then `$/` would not be set inside the block. That is now fixed. Additionally, I implemented `$0`, `$1`, `$2`, etc numbered captures, as well as `$<foo>` and `$<bar>` named captures. There is also the `regex` keyword for introducing named regexes, so you can say stuff like:

```` raku
regex Year {\d\d\d\d};
regex Location {German|French|Italian|London|Dutch|Ukrainian};
regex PerlConference {<Location>\sPerl\sWorkshop[\s<Year>]?};
````

I've got rule and token parsing, but they don't pass along the `:ratchet` and `:sigspace` modifiers yet. I hope to have that resolved soon.

A natural fall-out of adding support for `$<foo>` is that `%hash<key>` is now also supported for using constant hash keys. It's not much, but it's another small bit done.

It's been something of a mixed bag being at the GPW. While many people are interested and supportive of the work that is being done on Raku, others seem to prefer to use me as their latest target for snipey comments about how it will never be completed. And one person, after making a series of comments about code and papers he'd never read, decided to make an uncomplimentary comment about what I do with my wife in bed (by the way, I'm single). While I can put up with people being ignorant, I find personal attacks completely unacceptable, and not what I've experienced anywhere else in the Perl community. And now I'm left wondering whether I really want to spend any more of my time - which it costs me to take away from $DAYJOB - coming to GPW again.
