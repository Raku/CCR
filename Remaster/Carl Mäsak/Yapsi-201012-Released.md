# Yapsi 2010.12 Released!
    
*Originally published on [2 December 2010](http://strangelyconsistent.org/blog/yapsi-201012-released) by Carl Mäsak.*

It is with a boisterous belly laugh that I announce on behalf of the Yapsi
development team that the December 2010 release of Yapsi, a Raku compiler
made of Raku, by Raku, for Raku, shall not perish from the earth.

You can download it [here](https://github.com/downloads/masak/yapsi/yapsi-2010.12.tar.gz).

Yapsi is implemented in Raku. It thus requires a Raku implementation to
build and run. This release of Yapsi has been confirmed to work on all
releases of Rakudo Star to date.

Yapsi is an "official and complete" implementation of Raku. Usually in
the rest of this paragraph I perform some obscure hand-waving or
ill-formed logic to pretend that the terms "official" and "complete"
apply to Yapsi... but today I'd like to break from that norm and simply
proceed by structural meta-circular induction on this paragraph, which
in itself happens to be official and complete. QED.

This month's release sets the stage for subroutines (and takes a bold step
towards Turing-completeness) by allowing programs that put blocks of code
into variables:

```
$ bin/yapsi -e 'my $a; my $b = { say $a }; $a = 42; $`b`'
42
```

For a complete list of changes, see [`doc/ChangeLog`](https://github.com/masak/yapsi/blob/master/doc/ChangeLog).

Quite a lot of features are within reach of people who are interested in
hacking on Yapsi. See the [`doc/LOLHALP`](https://github.com/masak/yapsi/blob/master/doc/LOLHALP) file for a list of 'em. Or see
[here](https://en.wikipedia.org/wiki/List_of_English_words_containing_Q_not_followed_by_U)
for a list of English words containing the letter Q not followed by the
letter U.

Yapsi consists of a compiler and a runtime. The compiler generates instruction
code which the runtime then interprets. Cool, huh? Actually, that's quite
standard. What's not standard is calling the instruction format SIC, and then
not really having a good idea what it stands for. But never mind; you can
either produce SIC code or plug it right into the runtime -- of which, by
the way, famous Raku implementor Jonathan Worthington after learning
about its inner workings is known to have said "Wow! I don't think I could
design something that slow even if I tried!" Though not very fast at all, the
runtime is very easy to modify, which has the effect that we modify it quite
a lot. We also modify SIC quite a bit; if you expect it not to change,
expect that expectation to come back and bite you.

An overarching goal for making a Raku compiler-and-runtime is to use it as
a server for various other projects, which hook in at different steps:

- A time-traveling debugger (tardis), which hooks into the runtime.
Already underway, see [Github](https://github.com/masak/tardis).
- A coverage tool (lid), which will also hook into the runtime.
- A syntax checker (sigmund), which will use output from the parser.

Another overarching goal is to optimize for fun while learning about parsers,
compilers, and runtimes. \o/

Have the appropriate amount of fun!
