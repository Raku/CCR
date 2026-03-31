# Infix: now works on Ranges in Rakudo
    
*Originally published on [28 November 2008](https://use-perl.github.io/user/pmichaud/journal/37967/) by Patrick Michaud.*

Moritz found a bug in the infix:<Z> operator -- it wouldn't properly zip over a range:
```
09:04 <moritz_> rakudo: say (<a b c> Z 1..10).raku
09:05 <p6eval> rakudo 33300: OUTPUT[`elements` not implemented in class 'Range'␤current
               instr.: 'infix:Z' pc 4039 (src/gen_builtins.pir:2555)␤]
```
Normally we would expect this to return a list of lists:
```raku
(("a", 1), ("b", 2), ("c", 3))
```
The problem here was that infix:<Z> was trying to determine the size of each of its elements by using the 'elements' opcode and then get the individual elements by using a subscript.  This failed for two reasons:  (1)  Ranges don't support postcircumfix:<[ ]>, and (2) Rakudo's implementation of Range didn't work for the 'elements' opcode.

The real approach, as with most things dealing with lists, is to use iterators.  I changed the algorithm that it creates an iterator for each argument to `infix:<Z>`, and then walks those iterators in parallel to build the elements of the final result list.  When any of the argument iterators is empty, we're done building the list for `infix:<Z>`.

As a general rule, I suspect most list operators and builtin functions should not be counting the number of elements or using subscripts to access individual elements of a List.  There are likely a few more functions like this in Rakudo that we should be replacing.
