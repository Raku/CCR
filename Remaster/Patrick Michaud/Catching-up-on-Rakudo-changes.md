# Catching up on Rakudo changes
    
*Originally published on [15 May 2008](https://use-perl.github.io/user/pmichaud/journal/36420/) by Patrick Michaud.*

Development of Rakudo Perl is continuing along quite nicely.  Jonathan has been doing outstanding work with his one-day-per-week grant from Vienna.pm, primarily looking at classes, grammars, objects, etc., but also the occasional other features here and there.

We've also had some outstanding contributions from Stephen Weeks (*Tene*++ on IRC), who provided an implementation of placeholder parameters in Rakudo.  In fact, Stephen's implementation works for both positional ($^a) and named ($:a) placeholder parameters, and even supports the @_ and %_ placeholders!  There are still a few items to be tidied up -- especially when dealing with placeholder variables in the body of loops -- but I'm sure those fixes will be made soon also.

Chromatic has also continued to find [small fixes to Parrot that dramatically improve performance](https://use-perl.github.io/user/chromatic/journal/36410).  For example, just yesterday he made a small tweak to Parrot's garbage collector that made a 15%-30% improvement in our "build rakudo" benchmark.  We're continuing to find a lot of low-hanging fruit for improvement Parrot's overall speed.

Since Friday I've been able to do a fair amount of useful hacking on Rakudo and Parrot.  I managed to close about fifteen or so tickets in the RT queue, which is nice.

In my last post I noted that the "fat arrow" syntax is now working, meaning that named arguments can be passed with:

    foo(x => 1, y => 'hello');

The trick to getting this work was to get the operator precedence parser to again recognize "stop levels", such that it only parses expressions above (tighter) than a given precedence level.  The code for this in the grammar looks something like

    token fatarrow {
        <key=ident> \h* '=>' <val=EXPR: 'i='>
        {*}
    }

The important part is the 'i=' parameter being passed to the <EXPR> subrule... it tells the operator precedence parser to only parse operators above "item assignment" precedence.  (Look for %item_assignment in STD.pm to see where the 'i=' comes from.) Yes, this approach doesn't exactly match the way STD.pm does it, but it's close enough until we get a more general expression parser into PGE's subrule calls.

Having the ability to control the range of expression parsing meant that I could also implement default values for parameters, as in:
```raku
sub foo($x = 3, $y = 'block') { ... }
```
Again, this involved getting the default_value rule to parse everything after an '=' up to a lower-precedence operator:
```raku
rule default_value {
    '=' <EXPR: 'i='>
}
```

Since PCT already had support for default values on parameters, it was a fairly small change to the actions.pm module to get this to work.

Over the weekend I also looked a bit more at the official test suite, and cleaned up some tests in t/spec/S02-literals/ .  In the process I found that Rakudo's Test.pm wasn't handling "todo" markers properly, and fixed that.  The fudge-based preprocessor for the spec tests works extremely well -- it makes it very easy to mark sections of tests to be avoided when running the tests.  A goal for May is to get the spectests and makefile targets updated enough such that "make spectest" in Rakudo tends to report relatively few errors.

As Stephen Weeks was performing his implementation of placeholder variables we also discovered a place where NQP (and PCT) run into problems trying to distinguish hash accesses from array accesses in various objects.  At its core, Parrot uses integer versus non-integer indexes to distinguish between array and hash accesses, but NQP and PCT didn't provide a good way for high-level languages to make that distinction.

There was a lot of discussion about this on IRC, but after thinking about it a bit, I decided it was time for PCT to evolve a bit to do a better job of register handling.  So, I spent the last 2-3 days doing just that, and we have some very good results -- about a 10% reduction in overall generated code size and substantially fewer gc-able objects created.  There are a lot more details to share on this, but since this post is focused more about Rakudo and is getting a bit long, I'll write up the PCT details in a separate article.

Overall, there's a growing of things I'm eager to work on in Rakudo, and it's difficult to decide "what to do next", as all are useful or important.  At this point I'm thinking that I may focus on updating protoobject and class handling next.  Currently we have two separate protoobject systems in place: one for PGE and the compiler tools and another for Rakudo.  On the surface they look fairly similar, but there are some minor differences and we really ought to be serving both needs from a single base.  Plus getting the classes in Rakudo and PCT straightened out should make it easier for others to participate, so that seems like a Big Win for now.

Plus, I need to make sure all of my presentations are ready for this summer's conferences.  Speaking of which, I have apparently neglected to provide links to materials for some of the talks I have already given this year, for those that are curious:
```
FOSDEM 2008 Presentation
  "Raku"
    <url:https://ftp.belnet.be/mirror/FOSDEM/video/2008/maintracks/FOSDEM2008-perl6.ogg> (video)
    <url:https://www.pmichaud.com/2008/pres/fosdem-perl6/slides/start.html>  (slides)

Texas Open Source Symposium Talks
  "An Introduction to Raku"
    <url:https://http://www.pmichaud.com/2008/pres/texasoss-perl6/slides/start.html>
  "Programming Parrot"
    <url:https://www.pmichaud.com/2008/pres/texasoss-parrot/>

DFW.pm April 2008 meeting
  "Rakudo Perl - Raku on Parrot"
    <url:https://www.pmichaud.com/2008/pres/dfwpm-rakudo/slides/start.html>
```

Finally, on Saturday we're planning to have a "Parrot Bug Day" -- I hope to be around early in the morning and later in the evening to work with others to track down bugs and otherwise prepare for next Tuesday's monthly release.
