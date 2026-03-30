# NQP news
    
*Originally published on [26 November 2007](https://use-perl.github.io/user/pmichaud/journal/34974/) by Patrick Michaud.*

Over the weekend I've been able to get a lot of new features implemented in NQP, so this is a status and update for NQP.

"What is NQP?"  

Well, NQP stands for "Not Quite Perl (6)", and it's one of the language tools being developed for Parrot.  It's intended to be a lightweight and quick way to write Parrot subroutines and methods using Raku syntax.  In particular, I expect that it will get used for writing other compilers in Parrot, including bootstrapping raku.

Of course, this begs the question of "why not just use Raku for this?"  

Well, of course, one answer is that we don't have enough of a Raku implementation for this yet.  But even when we do, the full Raku implementation will likely need a substantial runtime library with it, and sometimes people targeting Parrot will want to develop code that doesn't require the entire Raku runtime behind it.  

Also, Raku will have its own idea of classes and objects, and sometimes we want to write code that uses the Parrot core types, or even a different class hierarchy.  

So, NQP is intended to fill this niche of being able to write code for Parrot using a Perl-like syntax, but staying fairly close to the capabilities, structure, and limitations of the Parrot VM.

----

Things that have been added to NQP this weekend:

* access symbols in other namespaces
* named argument passing
* method definitions
* module/class declarations ('class' doesn't create the class yet... it just defines the namespace for enclosed methods/subs)
* the 'make' function for result objects in matches (see S05 to find out what this is)

The next step for NQP will be to use it to re-implement "abc" for Parrot, as a proof-of-concept.  "abc" is a bc-clone that has been added to Parrot to illustrate Parrot's compiler tools.  Currently abc is written in a mix of PGE, PIR, and TGE -- but I'm thinking that soon we'll be able to make it almost entirely NQP-based.

After that is working fairly well, the next step will be to migrate the raku implementation to also be NQP based.  Stay tuned!
