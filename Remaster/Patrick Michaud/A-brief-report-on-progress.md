# A brief report on progress
    
*Originally published on [3 November 2009](https://use-perl.github.io/user/pmichaud/journal/39834/) by Patrick Michaud.*

It's been two weeks since I last did a blog post; and in that couple of weeks there's been an incredible flurry of activity and development.  In fact, so productive that I barely have had time to write about it, although that will happen soon.

As a simple indication of the speed in which things are moving, I thought I would just post a copy of my report to today's #parrotsketch meeting.  This represents things that have been achieved since October 27, and what we expect to be doing this upcoming week.

```
# parrotsketch report for 2009-11-03:
What I did:
* NQP stuff:
** Added contextual variables, named arguments, modules, class
   declarations, private class attributes, methods, 'make' statement,
   pir::op access to PIR opcodes, grammars, tokens, rules, regexes,
   INIT blocks, unified <noun> with <term>, lexical subroutines,
   parameterized regexes, :my declarations in regexes, codeblocks
   in regexes, code assertions in regexes, \x and \o escapes in
   regexes and double-quoted strings, variable interpolation in 
   double-quoted strings, a 'make install' target, a --parsetrace 
   option, pod comments, warnings for unsupported or NYI features
** ... and made the nqp parser and compiler self-hosting.

* Rakudo stuff:
** Started the new implementation of Rakudo based on the nqp-rx
   engine, that is going very well.
** Have a new implementation of Lists, Lists and Arrays,
   all of which can now have lazy semantics.
** Fixed constants and containers handling, Rakudo no longer
   allows assignment to constant values.
** Implemented "real" assignment metaoperator parsing (e.g., &infix:<+=>);
   Rakudo-ng now builds assignment metaoperators only when needed.
** Changed subroutines to be stored with the & sigil.
** Changed Rakudo operators to be "&infix:<+>" instead of "infix:+".
** Have many of the sanity tests running again; Test.pm compiles
   but doesn't run completely yet

* Plumage:
** Updated Plumage Configure and code to work with nqp-rx, passes
   Plumage's test suite.

What I'm doing this week:
* Continuing to work on Rakudo-ng, get us running spectests again 
  and compiling setting (now called "CORE")
* More minor nqp-rx updates, error message improvements and better
  syntax checking
* Profiling the regex engine to find some speed improvements

What I'm blocking on:
* Useful programming time
```
As you can see, things are happening quickly, and we're all pleased with the progress.  Together with Jonathan's work on dispatch, we appear to have overcome the two major hurdles identified for Rakudo Star.  From here on out it's basically just fleshing out the rest of the implementation and adding feature coverage according to the ROADMAP.

I'll write more details soon; I have to get back to a few other tasks right now.  Hope you enjoy reading the above list as much as I enjoyed writing it.
