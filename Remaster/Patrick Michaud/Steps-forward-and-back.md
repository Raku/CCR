# Steps forward and back
    
*Originally published on [30 November 2007](https://use-perl.github.io/user/pmichaud/journal/35013/) by Patrick Michaud.*

Well, we take several steps forward and then one or two back.  Lots of good things happened today -- *particle*++ and *Tene*++ came up with some very helpful suggestions for inlining PIR directly into NQP blocks.  Of course, the trick to this is that whatever syntax we use needs to be parseable by Raku.

Raku's inlining mechanism is essentially `eval`, which also provides a :lang<whatever> adverb to indicate the code being executed.  But somehow that feels more like a runtime function to me (compile and execute the string), whereas in NQP we really want some way of embedding the code directly into a subroutine.

After much discussion we've decided on a 'PIR' function (or maybe 'pir') with an argument of a quoted string.  So, one would be able to write things like:
```
PIR <load_bytecode 'Module.pbc'>;     # insert a single PIR statement

PIR q:to:'END';
    load_bytecode 'PGE.pbc'
    say 'Module.pbc loaded successfully'
    $P0 = get_global '$foo'
    say $P0
END
```
To a normal Raku compiler, these would look like simple calls to a function named "PIR", so it's still valid Raku syntax, and might even do something useful in a real Raku compiler.  But for NQP we can just parse the above as specialized statements in the language, the same way that `make` is being handled as a specialized statement.

Of course, NQP doesn't support a true heredoc syntax yet -- that's a bit tricky to write and was the topic of much discussion today.  However, we don't need a full heredoc syntax -- we can just have the PIR "statement" recognize the q:to:... form directly and parse the subsequent lines as part of the statement.  Particle and I even hashed out a few regexes for it.  Handling inline PIR blocks this way is a bit of a cheat, yes, but that's partially what NQP is for.

The end result of this is that we could end up using NQP for nearly *all* of the compiler components -- including the builtins.  We just write normal Raku subs, and then embed PIR in those places where Raku isn't up to the task yet (e.g., when bootstrapping or for primitives).  For example, the definition of an `abs` function can initially be something like:
```
sub abs($x) {
    PIR q:to:'END';
        $P0 = find_lex '$x'
        $P0 = abs $P0
        .return ($P0)
    END
}
```
The other big improvement of the day was refactoring the Parrot Compiler Toolkit a bit to make it easier to load and to use only specific components of the toolkit.  Thanks to *particle*++, *barney*++, and *PerlJam*++ for suggesting this.  Most compilers can simply include the 'PCT.pbc' module; but compilers that just want PAST/POST without the grammar components can load 'PCT/PAST.pbc'.  Much cleaner.

Working on these also led to the delays of the day -- the big one was a segfault that was showing up in Parrot at odd times while I was moving things around in PCT.  I kept finding that I was unable to get 'make test' to run all the way through so I could confidently commit my changes -- lost a lot of time tracking it down to ccache, of all things.  Anyway, it's filed as RT#47970 and *chromatic*++ is looking at it.

The other delays come from Parrot needing some more improvements to its handling of lexical variables -- at the moment it doesn't know how to have a BEGIN sub with a nested lexical scope or methods inside of outer lexical scopes.  So, these are now posted as RT#47794 and RT#47956 so someone else can hack on them a bit.  In the meantime we have some temporary workarounds in PCT to keep this from stalling things completely.

Lastly, tonight I used the information gleaned from the day to class declarations in NQP to actually construct the class.  We don't have instance attributes yet or inheritance, but having NQP automatically create the classes means less for us to manually code in PIR.

Anyway, it's late again and I need some rest.  Tomorrow we'll probably work on inline PIR support in NQP, and then start to work on migrating raku to its new NQP-based implementation.  And we need to update more todo documents, status documents, and planning notions.
