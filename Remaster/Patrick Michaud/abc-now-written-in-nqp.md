# 'abc' now written in nqp
    
*Originally published on [27 November 2007](https://use-perl.github.io/user/pmichaud/journal/34985/) by Patrick Michaud.*

Well, after a long and very fruitful day of hacking, the 'abc' compiler in Parrot is now written mostly in PGE and NQP, with all tests passing.

'abc' is an implementation of a basic calculator (like the unix bc(1) command) for Parrot.  While abc does support a lot of bc features, the primary purpose of abc is to serve as a simple example and tutorial of using the various Parrot toolkits to build compilers for Parrot.

Previously abc was written using a mixture of tools using a variety of languages.  After today's efforts abc is now written with only
* a Raku grammar (src/grammar.pg), 
* some NQP code to build an ast from the parse tree (src/grammar-actions.pg)
* the Parrot Compiler Toolkit library (PCT)
* and some PIR for setup and builtin functions (abc.pir, src/builtins.pir)

In other words, the bulk of the code for the abc compiler is written in Raku.

With this we've been able to basically prove the workability of NQP and the Parrot Compiler Toolkit, and the next step is to start redesigning the raku compiler to use the same approach.

I also need to add a lot of documentation to the abc source files, to make it clearer as to what is happening at each step.  But I think that will have to wait for me to get some sleep first.
