# Adding 'goto' to your Raku program
    
*Originally published on [8 January 2010](http://strangelyconsistent.org/blog/adding-goto-to-your-perl-6-program) by Carl Mäsak.*

Today I tested something that *jnthn*++ and I had discussed during a walk in the non-tourist parts of Riga after Baltic Perl Workshop.

```raku
$ cat test-goto
Q:PIR {
  line_10:
};
say "OH HAI!";
Q:PIR {
  goto line_10
}
$ raku test-goto
OH HAI!
OH HAI!
OH HAI!
OH HAI!
[...]
```

Oh. My. Wow.

The 1980's called; they want their infinitely looping toy BASIC idiom back.

I half-expected that not to work, but I'm glad it does. I can even imagine it being of actual, code-simplifying use in some applications. The reports of the harmfulness of GOTO have been greatly exaggerated, if you ask me. Like everything else, the `goto` keyword shouldn't be overused, but a well-placed `goto LABEL` can actually improve readability. Often these masquerade as `next LABEL` or `last LABEL` or `redo LABEL` in Perl loops. But those are `goto`s with a nicer accent, a briefcase, and a better salary.

Unfortunately, the trick doesn't take us very far. Since we're using PIR `goto`s, we can only jump around within the same sub. Not just the same Raku sub, that is, but the same PIR sub. Since every block in Raku corresponds to a sub in PIR, we can't jump outside of the block.

```raku
$ cat test-goto-loop
loop {
    say "OH HAI!";
    Q:PIR {
      goto line_10
    }
}
Q:PIR {
  line_10:
};
$ raku test-goto-loop
e_pbc_emit: no label offset defined for 'line_10'
in Main (file <unknown>, line <unknown>)
```

Well, that certainly makes it less useful. Shame.

Now, how about them PIR-based continuations...? ☺
