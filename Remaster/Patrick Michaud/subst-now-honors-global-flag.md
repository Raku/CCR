# .subst now honors :g(lobal) flag
    
*Originally published on [1 December 2008](https://use-perl.github.io/user/pmichaud/journal/37989/) by Patrick Michaud.*

Today I added in support for the :global/:g flag in the .subst method (S05); now we can do things like:
```
> my $i = 0; say "There's more than one way".subst(/e/, { ++$i }, :global);
Th1r2's mor3 than on4 way
```

Previously the .subst method would only work on the first match in a string.  Rakudo still doesn't recognize the case where the :global flag is part of the regex, but at least we now have at least one concise mechanism for performing global search/replace on a string.

Within the closure argument one can use $/, $0, $1, etc. to refer to the matched portions of the string in the replacement.  Getting that to work meant that we needed to fix the binding of $/ within closures -- it turns out the mechanism we were trying to use previously (!OUTER) can't really work in Parrot.  As a bonus, fixing this simplified actions.pm slightly, and removed several internal subroutine calls that were being performed at the start of each closure.

Of course, the pattern and replacement arguments to .subst can be simple strings, but any variable substitutions in the replacement string then refer to the outer environment and not the values from the matched string.

Now we just need to verify and add a few more tests for this.  :-)
