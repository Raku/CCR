# Rakudo day:  operators in setting and lots of RT bugfixes
    
*Originally published on [1 July 2009](https://use-perl.github.io/user/pmichaud/journal/39199/) by Patrick Michaud.*

At the beginning of June the Vienna.pm organization generously
committed to funding me for 1-day-per-week of Rakudo effort,
but because of the Rakudo release, Parrot Virtual Machine Workshop, 
YAPC::NA, and a short vacation, today is the first day that I
had available to really dedicate to the task.  In fact, to catch
things up a bit I plan to do another Rakudo day tomorrow or Thursday.

Here's what I accomplished for today's Vienna.pm-funded Rakudo day.

The biggest task I tackled for the Rakudo day was to be able to
write operators in the setting (Raku) instead of PIR (RT #66826).  
In fact, I had actually done most of this last week during the 
YAPC::NA hackathon day, but interruptions then and a few annoying 
Parrot bugs kept me from marking the task as completely accomplished 
then.  What this means is that we can now begin defining operators
directly in Raku code (perhaps with some inlined PIR), which
*moritz*++ has already been exercising for infix:<...>, infix:<eqv>,
and a few other operators.  Over the next few weeks I expect we'll
move even more operators out of PIR and into the setting.

The rest of today's Rakudo day was spent reviewing and cleaning up 
the RT queue; it had grown to over 400 tickets but by the end of
the day Jonathan and I have shrunk it back down to 387.  I think
we collectively closed about 16 tickets today, and I responded with
requests for clarification or updates on several more.  Here are 
some of the highlights:

RT #66060 noted a problem that the .uc method would fail on some 
strings where .lc worked.  I tracked this down to a Parrot issue 
in its handling of Unicode strings when ICU wasn't present, and
refactored the code to be a bit more robust there.

RT #66640 noted that the minmax operator wasn't implemented, so after
some discussion about what it should do I added it to the setting
(using the operator features mentioned above).

In RT #66624, the exception message coming back from
not finding a substring within a string was particularly misleading;
I adjusted .substr to provide a more useful error message.

For RT #66928 .WHAT would not work on some subs like &infix:<+>;
this was because some of the builtin operators are still using
Parrot's MultiSub PMC instead of the Perl6MultiSub PMC, and those
didn't have a mapping to the type object.  Eventually all of the 
operators will become Perl6MultiSub; in the meantime I set Parrot 
MultiSub PMCs to map to the `Multi` type objects in the same
manner that other Parrot PMC classes are mapped to Raku types.

RT #66818 noted a problem with unwanted flattening of `%*VM`
in a for statement; this was because the contents of `%*VM` were
incorrectly bound to the Hash directly instead of going through
a non-flattening reference (Perl6Scalar).  Eventually I expect
`%*VM` to be initialized in the setting, though, which will provide
a more robust and direct solution to this problem.

In RT #66840 it was discovered that precedence errors in the
ternary operator would cause Rakudo to issue an error message
and exit completely, instead of throwing a catchable exception.
I tracked this down to PGE's OPTable handling of the ternary
operator, it was actually using "exit" when the error occurred
(probably because it came from before Parrot's exception model
was firmly in place).  This was changed to throw an exception
instead; the actual exception message needs a bit of work but
I expect that will come from the much larger PGE refactoring
that will be done as part of the Hague grant.

Lastly, today I spent a good bit of time discussing Rakudo
and Parrot build/install issues with Allison, and I think we 
have basic agreement on the changes we'll be making in order to
get those working.  Hopefully we can get all of that done
in time for the July release.

So, that's my first Vienna.pm Rakudo day -- lots of little
pestering bug fixes, and a key bit of infrastructure to fully
enable writing the builtin operators in Raku.  Later this week I
plan to do a long-needed refactor of container handling in
Rakudo, and maybe to get a more complete implementation of BEGIN
blocks (which we massively cheat on at the moment).

Thanks again to Vienna.pm for sponsoring this work.
