# June 8 2011: Parts of strings
    
*Originally published on [8 June 2011](http://strangelyconsistent.org/blog/june-8-2011-parts-of-strings) by Carl Mäsak.*

Our job today is simple: learning how to pick strings apart.

```raku
say "supercalifragilisticexpialidocious".substr(9, 4);  # "frag"
say substr("supercalifragilisticexpialidocious", 9, 4); # also "frag"


The 9 says "where to start" (with the first position being number 0), and the 4 says "how much to take". So we take four characters from position 9 and onwards.

As you see, there are two ways to go about this. Either we start from a string value and take the `substr` of that, or we start by saying `substr` and then which string value we want the substring of.

The first form is called a *method call*, and the second form a *subroutine call*. There are lots of methods, and the more common things (like `substr` and `say`) also exist as subroutines. It's a matter of taste and convenience which one we pick.

```rakusubstr` has a few more tricks up its sleeve. We often like to take things from the end, and then we can "subtract" from the end:

```raku
say "supercalifragilisticexpialidocious".substr(27, 4)  # "doci"
say "supercalifragilisticexpialidocious".substr(*-7, 4) # also "doci"
```

For the purposes of `substr`, think of the asterisk as meaning "the end of the string" or "the length of the string".

And, finally, if we know that we're going to want the rest of the string anyway, we can just leave out the second number, and it'll take the rest for us.

```raku
say "supercalifragilisticexpialidocious".substr(20)   # "expialidocious"
say "supercalifragilisticexpialidocious".substr(*-14) # same thing
```

Tomorrow we'll have a look at how we can avoid massive `if`/`elsif`/`elsif` chains.
