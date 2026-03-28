# Yapsi 2010.11 Released!
    
*Originally published on [2 November 2010](http://strangelyconsistent.org/blog/yapsi-201011-released) by Carl Mäsak.*

It is with a contagious joviality that I announce on behalf of
the Yapsi development team the October... hm... November 2010 release of
Yapsi, a Raku compiler written in Raku.

You can download it [here](https://github.com/downloads/masak/yapsi/yapsi-2010.11.tar.gz).

Yapsi is implemented in Raku. It thus requires a Raku implementation to
build and run. This release of Yapsi has been confirmed to work on all
releases of Rakudo Star to date.

Yapsi is an "official and complete" implementation of Raku. The fact that
it's official means that its author has claimed that it's official for over
half a year now, and not once been contradicted. Hence, it must be so.
The fact that it's complete means that
the code has the same volume (in cubic centimeters) as its packaging.

This month's release brings you mostly bug fixes... BUT it also comes with
compatibility for the long-awaited Tardis debugger (sold separately) which
allows ordinary mortals to jump backwards in time!

```raku
$ export RAKULIB=path/to/yapsi/lib:path/to/tardis/lib
$ bin/tardis -e 'my $a = 42; my $b; { $b = 5 }'
# Compiling...
# Running...
# Finished. Ticks: 0..3
> go 1
$a = 42
$b = `Any`
> go 3
$a = 42
$b = 5
> go 1
$a = 42
$b = `Any`
> ^C
```

For a complete list of changes, see [`doc/ChangeLog`](https://github.com/masak/yapsi/blob/master/doc/ChangeLog).

Quite a lot of features are within reach of people who are interested in
hacking on Yapsi. See the [`doc/LOLHALP`](https://github.com/masak/yapsi/blob/master/doc/LOLHALP) file for a list of 'em.

Yapsi consists of a compiler and a runtime. The compiler generates instruction
code which the runtime then interprets. (If this sounds tricky, think of an
assembly line where little toy soldiers are constructing tiny toy-soldier-sized
assembly lines, and so on all the way down to the scale of quantum foam. Now
THAT's tricky!) The format used to represent the instructions in Yapsi are
called SIC. Being of questionable merit from the beginning, SIC changes all
the time, except for the property that it changes all the time, which has
tended to be quite predictable. Even that, however, may change over time.
Anyway, don't expect the SIC of next month to look anything like the SIC of
this month. It might, but don't expect it.

An overarching goal for making a Raku compiler-and-runtime is to use it as
a server for various other projects, which hook in at different steps:

- A time-traveling debugger (tardis), which hooks into the runtime.
Already underway, see [Github](https://github.com/masak/tardis).
- A coverage tool (lid), which will also hook into the runtime.
- A syntax checker (sigmund), which will use output from the parser.

Another overarching goal is to optimize for fun while learning about parsers,
compilers, and runtimes. So far that goal is on track, and more.

Have the appropriate amount of fun!
