# Yapsi 2010.06 Released!
    
*Originally published on [1 June 2010](http://strangelyconsistent.org/blog/yapsi-201006-released) by Carl Mäsak.*

It is with a mien of amusement that I want to announce, on behalf of the wholeYapsi development team, the June 2010 release of Yapsi, a Raku compiler written in Raku.

You can get it [here](https://github.com/downloads/masak/yapsi/yapsi-2010.06.tar.gz).

Yapsi is implemented in Raku. It thus requires a Raku implementation to build and run. We recommend the 'alpha' branch of Rakudo for this purpose.

Yapsi releases are 'official and complete', shown here by a circular argument: clearly an official thing like Yapsi must be complete, and Synopsis 1 states that anything complete is official. QED. Yapsi passes 100% of its test suite.

Instructions for getting Yapsi up and running:

- Make sure you have a built Rakudo alpha in your $PATH as 'alpha'.
- Download Yapsi from [github](https://github.com/masak/yapsi/downloads).
- ...
- Profit!

The third (optional) step consists of running 'make' in the Yapsi directory. This will precompile Yapsi, making startup times much more bearable.

The big news since last month is that Yapsi now has a logotype. It's a picture of a Möbius band, to symbolize self-loopiness, recursion and twisted ideas.

Yapsi consists of a compiler and a runtime. The program is compiled down into an instruction code called SIC, which doesn't stand for anything [sic]. All SIC listings start with a versioning line saying e.g. "This is SIC v2010.06". At this point during Yapsi development, we provide no guarantees about backwards compatibility whatsoever. Expect breakage between monthly releases.

An overarching goal for making a Raku compiler-and-runtime is to use it as a server for various other projects, which will hook in at different steps:

- A time-traveling debugger (tardis), which will hook into the runtime.
- A coverage tool (lid), which will also hook into the runtime.
- A syntax checker (sigmund), which will use output from the parser.

Another overarching goal is to optimize for fun while learning about parsers, compilers, and runtimes. We wish you the appropriate amount of fun!
