# Yapsi 2010.04 Released!
    
*Originally published on [1 April 2010](http://strangelyconsistent.org/blog/yapsi-201004-released) by Carl Mäsak.*

It is with a certain degree of amusement that I want to announce, on behalf ofthe Yapsi development team, the April 2010 release of Yapsi, a Raku compiler written in Raku.

You can get it [here](https://github.com/downloads/masak/yapsi/yapsi-2010.04.tar.gz).

How does one compile and run a Raku compiler, you might ask? One way would be to use it on itself, but this has been known to cause some immediate dependency/bootstrapping issues. It's often a great deal easier to use an existing compiler to get off the ground. Yapsi runs fine under the 'alpha' branch of Rakudo.

This is an "official" release of Raku, to the extent that we, the Yapsi development team, have authority to make official Raku releases, which admittedly isn't a very large extent. It's also a "complete" implementation, in frankly not very many ways at all.

Here's an example of what Yapsi can do:

```raku
$ ./yapsi -e ''
```

...that's right, it runs the null program. And with correct semantics, and all.

But that's not everything. We also do assignments:

```raku
$ ./yapsi -e 'my $a = 42'
```

Note that here, too, the semantics are completely on the spot. 42 gets assigned to $a, and nothing is output.

For those of you who cry foul at this point, just watch:

```raku
$ ./yapsi -e 'my $a = my $b = my $c = 5; say $a'
5
```

Ta-daa!

Yapsi consists of a compiler and a runtime. The program is compiled down into a kind of instruction code called SIC [*sic*]. This code can then be executed very quickly inside the provided runtime, where the definition of "very quickly" depends on the runtime you're bootstrapping off, etc.

An overarching goal for making a Raku compiler-and-runtime is to use it as a server for various other projects, which will hook in at different steps:

- A time-traveling debugger (tardis), which will hook into the runtime.
- A coverage tool (lid), which will also hook into the runtime.
- A syntax checker (sigmund), which will use output from the parser.

Another overarching goal is to optimize for fun while learning about parsers, compilers, and runtimes. We wish you the appropriate amount of fun!
