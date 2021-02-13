# Hackathoning in Oslo
    
*Originally published on [2012-04-21](https://6guts.wordpress.com/2012/04/21/hackathoning-in-oslo/) by Jonathan Worthington.*

I’m in Oslo with a bunch of Raku folks. It’s great to see old friends and meet some new ones – and we’re having a highly productive time. After a wonderful evening of tasty food and lovely beer (amongst others, a delicious imperial stout) yesterday, today has been solidly focused on Getting Stuff Done.

I’m a little tired now, so here’s just a quick rundown of some of what I’ve been up to.

- Since bounded serialization landed, we’ve had a few issues with pre-compilation of MiniDBI, the database access module. I’ve now tracked down all of the remaining issues there, fixed them. and happily *moritz*++ has been hacking lots on improving the module in other ways too. The MySQL and Postgres drivers now pass all the tests we have for them, which is some nice progress.
- I’ve been answering a few questions for *arnsholt*++, who has picked up the `Zavolaj` (native calling) module where I left off, adding support for passing/returning arrays of structs, structs pointing to arrays and various other permutations. This will greatly improve the range of C libraries that can be used with it.
- I had a design session with *pmichaud*++ on QAST, the successor to our current AST. The new nodes will integrate far better with 6model and bounded serialization, give us better native type handling and be much more memory efficient due to being able to use natively typed attributes in them. This is also a key part of our work towards getting Rakudo up and running on an extra back end.
- After that, I got the nodes fleshed out somewhat, and have started a little work on `QAST::Compiler` too. It’s underway!
- I also spent some time in the ticket queue and fixed a bunch of Rakudo bugs: constant initializers containing blocks now work out, state declarations together with list assignment work, $.foo/@.foo/%.foo now contextualize as they should, and `:i` now also applies to interpolated variables.

So, lots of stuff – and that’s just the things I’ve been directly involved with.  It’s nice to be a part of this hive of activity…and tomorrow there’s another day of this! Catch you then. :-)
