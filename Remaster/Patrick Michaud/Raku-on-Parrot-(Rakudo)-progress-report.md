# Raku on Parrot (Rakudo) progress report
    
*Originally published on [2 April 2008](https://use-perl.github.io/user/pmichaud/journal/36035/) by Patrick Michaud.*

This is a long-overdue report on the state of Raku on Parrot (now "Rakudo Perl") development. In late 2007 I had been writing progress reports on a regular basis as as part of a grant from the Mozilla Foundation (MF) and The Perl Foundation (TPF), but in early January I had to pause work on the grant and my reporting to take care of a family emergency. I'm very glad that things have now settled down and that I can focus energy back on Perl again.

In spite of my distractions, a lot of progress has been made on Rakudo since last the last major report I wrote in December 2007. The work performed in November and December of last year has opened the door for many others to participate in Raku and Parrot development, and as you'll see in this report, many have done so. I'm very pleased with the team of developers that has arisen and the quality of tools we've created for compiler development on Parrot. If anything, the hiatus has shown that our ability to advance isn't dependent on a single individual.

**Progress, December 2007 to March 2008**

An early draft of this report started by going into substantial detail about the progress that has been made in recent months, but I soon realized that so much has happened that the resulting report would be far too lengthy to be interesting or useful. Thus for this report I've decided to briefly highlight some of the events and milestones reached to give a good sense of the progress being made, and then write later articles that provide more detail. If I've overlooked an important contributor or event, please accept my apologies and let me know so I can highlight them appropriately.

* In January, the Raku on Parrot compiler was renamed to "Rakudo Perl", or "Rakudo" for short. "Rakudo" is short for "Rakuda-do", or "The Way of the Camel" in Japanese. ("Rakudo" also happens to mean "paradise" in Japanese, which is nice.)

* A tool created by chromatic and Jerry Gay (with contributions from Will Coleda, Bernhard Schmalhofer, Andy Lester, and Francois Perrad) makes it possible to build an executable "raku" binary. As a result, many people can now use Rakudo to execute Raku programs by simply typing "./raku script.pl".

* In December we substantially completed the implementations for the Parrot Compiler Toolkit (PCT) and Not Quite Perl (NQP). The end result is that many of Parrot's HLL compilers are now written using Raku source code instead of PIR.

* Jeff Horwitz continued to extend the implementation of mod_parrot to include scripting in Raku (Rakudo) and PHP (Plumhead).

* We've increased the quantity and quality of documentation on Parrot's compiler tools to make them more accessible to a wider range of programmers. As part of this, we also created a "make a new Parrot language shell" tool that populates a directory with a basic setup for implementing a new compiler in Parrot.

* As an unplanned demonstration of how well the tools work, in January Will Coleda and Simon Cozens used the new tools to create a working LOLCODE implementation ([https://lolcode.com](https://lolcode.com)) from scratch with just a few hours' effort. Simon [wrote about the experience](https://web.archive.org/web/20080229042235/http://blog.simon-cozens.org/post/view/1323) and LOLCODE has served as a great example for others who are interested in compiler development under Parrot.

* We developed and initiated a plan for reviewing and refactoring the Raku tests of the Pugs repository to become the "official" Raku test suite.

* Larry Wall and Jerry Gay designed and implemented tools to allow the official test suite to be easily used by multiple Raku implementations, including those that may be incomplete in the early stages of development.  Both Pugs and Rakudo are now using these tools ([fudge](https://github.com/Raku/roast/blob/master/fudge)/[fudgeall](https://github.com/Raku/roast/blob/master/fudgeall)).

* Jonathan Worthington added junctions, classes, objects, roles, given/when statements, and many other significant features to Rakudo. He presented his work at several conferences and workshops, and [wrote an article](https://web.archive.org/web/20080224235108/http://www.jnthn.net:80/cgi-bin/blog_read.pl?id=589) about his positive experience using the new tools to add features to Rakudo.

* Jerry Gay added support for radix conversions, command line argument handling, new test harnesses, many builtin functions and operators, and a rakudoc parser. He has also continued to serve as a mentor and advisor for other Rakudo developers.

* Recently Klaas-Jan Stol completed a [draft tutorial](https://web.archive.org/web/20080318234905/http://www.parrotblog.org/2008/03/targeting-parrot-vm.html) for building compilers using the various compiler tools in Parrot.

* We added a compiler overview that describes the architecture and layout of the components of the Rakudo Raku compiler.

* Since December at least twenty individuals contributed patches for new features to Rakudo Perl and the Parrot Compiler Toolkit. In addition, the Parrot subversion repository received a record number of commits in the months of December (1175) and January (1025).

**Where things are headed next**

The overarching goal for the next couple of weeks will be to again boost development momentum on Rakudo Perl and Parrot compilers to the levels we were seeing in December and early January. Because we now have many of the compiler tools and core code components in place, parallel development efforts for Rakudo are much more possible than they have been in the past. A key task for the next couple of weeks will be to recruit and support additional individuals who can help with the implementation effort.

Specific tasks for the upcoming weeks will include:

* Continue building and refining documentation for the compiler tools and Rakudo implementation
* Review code added to Rakudo in the past couple of months 
* Perform a refactor of Rakudo's base classes and namespace handling to better support junctions, classes, and objects in Raku.
* Add control exceptions
* Add more hash and list operations
* Continue improving and refactoring the official test suite
* Update test system to provide graphical views of passing/failing tests in Rakudo

Thanks for reading!
