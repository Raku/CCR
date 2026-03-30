# Status of raku on Parrot, 2007-12-04
    
*Originally published on [5 December 2007](https://use-perl.github.io/user/pmichaud/journal/35049/) by Patrick Michaud.*

This is an update on the status of Raku on Parrot development
as of December 4, 2007.

Progress in November 2007
-------------------------
The last report was published in November as a "road map"
for continued development of the Raku on Parrot compiler (raku).
Since then we've basically been following the steps outlined
on the road map and we are seeing significant progress on the
compiler.

The big news for this month is that we are now using a
lightweight Raku translator ("NQP") to implement the
translation components of the raku compiler.  Making this
transition means we are currently failing quite a few tests
in the test suite, but Jerry Gay and I are rapidly cleaning
those up.  This is also a good place for others to join in if
you're interested -- see "How to hack and contribute" below.

So, as mentioned in the previous status report, the raku compiler
has four major components:  the parse grammar, specialized parsing
routines, the ast transformation, and the runtime support.  Now
that we're using NQP for the ast transformation, this means that
the bulk of the compiler--the parse grammar and the ast
transformation--are written using Raku syntax.  If you want to
take a quick peek at these without downloading Parrot, they're
currently available at:

We're also looking into the possibility of rewriting much of
the runtime support as Raku.  One of the significant things
we added this past week is the ability to embed PIR code directly
inside subroutines compiled using NQP.  This has turned out to be
extremely useful for development -- we use Raku syntax for most
things, but can drop in and out of PIR whenever we (temporarily)
need it.

Another major item completed yesterday is a new set of routines
for parsing and transforming Raku's quote syntax.  Of course, the
primary reference for this is the STD.pm grammar, and if
you take a look you'll see that it's a fairly complex component
because of the many options, interpolation forms, and extensions
that are available.  It will likely be a while before we have all
of the pieces to implement quotes exactly as STD.pm has them,
so in the meantime I've written up a couple of parse subroutines
(in PIR) that handle most of the quoting forms and options we're
likely to encounter, including interpolation.  The only major
forms not available at present are the ÃÂ«...ÃÂ» and heredocs, and
the ÃÂ«...ÃÂ» form is waiting only on some Unicode fixes in PGE
and Parrot (RT#48108).

While I'm on the topic of STD.pm and parsing:  I do need to
compliment Larry, Damian, and others who have been building
STD.pm and the language specification for the improvements
made in the language syntax over the past year or so, such
as in quoting.  The version of Raku we have now is *much*
easier to parse--by both humans and machines--than what we
had a year ago.

Where things are headed next
----------------------------

There are two major items we will be focusing on for the
next couple of weeks.  The first will be continued development
of the raku compiler -- getting it back to passing the tests
it was previously passing, as well as adding new features and
tests.  Progress on this is already being made and should
accelerate nicely.

The other area of focus will be in writing a lot of prose --
documents that will help new developers figure out where
things are and how it's all put together.  For instance, we
really need a "getting started" document for raku that
describes how to build the compiler, how to invoke it,
and how/where to report bugs and patches.  Much of this
information is currently in the ROADMAP, but would probably
be better placed in a getting started document.  We also want
a developer's roadmap of some sort.

I'm also planning to publish a "developer's glossary" somewhere
to identify many of the various terms that get thrown around
in development (PCT, PGE, NQP, STD.pm, regex, PAST, etc.).

Also on the horizon we will start looking at reviewing and
possibly restructuring the Raku test suite, and coming
up with a mechanism to quickly update/publish the status
of various language features in the compiler (hopefully with
references back to the language spec).

How to hack and contribute
--------------------------

If you're interested in hacking on the compiler, this is
a unique time to start getting involved.  There are a lot
of relatively easy features to be tested and added, and
the discussions are about the basics of the compiler and
how it's put together.

As mentioned above, we need a good "getting started" document,
but for now here's a quick overview.  First, you'll want to
download and build Parrot -- instructions for this are at
<url:http://www.parrotcode.org/>.  Once you have Parrot built,
you can change to the languages/raku/ directory and type
'make' to build the raku compiler.  Then use the command
```
$ parrot raku.pbc hello.pl
```
to run a hello.pl program (written in Raku).

To learn more about how compilers are being structured
in Parrot in general, I recommend looking at languages/abc/.
This is an implementation of the bc(1) language using the
same tools we're using to implement raku, with the advantage
of being a lot simpler language than Raku.  We've also tried
to put a lot of comments into the source files for abc that
explain what each component is doing.

After that, you can look at raku's source code files and
running some tests (either from the suite or files that
you build).  If you want to see raku's intermediate compilation
results, use --target=parse, --target=past, or --target=pir
immediately after the "raku.pbc" part.

In the next couple of weeks we'll be writing up the documents
that describe the details of the compiler implementation, but
in the meantime please ask us questions!  We'll use the questions
to help author the documents.  The raku and Parrot developers
tend to hang out on irc.raku.org/#parrot, and questions are
welcome on the rakuompiler mailing list.

If you find a bug or have a suggested patch, send it to
rakuug@perl.org.  Please use the moniker [PATCH], [BUG],
or [TODO] \(including the brackets) at the start of the subject
so that RT can appropriately tag the item.

Thanks for reading!
