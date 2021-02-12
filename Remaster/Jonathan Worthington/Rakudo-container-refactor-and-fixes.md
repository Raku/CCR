# Rakudo container refactor and fixes
    
*Originally published on [9 November 2008](https://use-perl.github.io/user/JonathanWorthington/journal/37834/) by Jonathan Worthington.*

With some Rakudo days to catch up on post-vacation, and knowing *Patrick* was keen to get some container changes rolling, I made a second Rakudo day this week on Thursday. While waiting for *Patrick* to show up (we're quite a few timezones apart), I hit the RT queue.

- I got an easy start to the day - finding a ticket that covered an issue *pmichaud*++ had resolved already and closing it. The issue in question was to do with making objects stringify to something rather than giving an error - this now happens. Further, you can write an Str method on a class that returns a string now to override this behavior.
- Here's teamwork. Last night, *Carl Masak* reported a bug when you wanted to inherit from a namespaced class. I said I'd look at it today. In the meantime, *Moritz* got some unit tests written. I went to the ticket in RT today to find that *Chris Dolan* had already sent in a patch to resolve the issue, leaving me to review it, test it and apply it.
- Spent quite a while trying to get if blocks that take a lambda to work (the idea is that you can capture the expression that was evaluated as the conditional). Got close, but something was messed up in the code generation. Then put it aside to work out the container changes.

Once *Patrick* appeared, we dug into the refactoring, in a branch. The aim was to fix up various container semantics, and do various things correctly that we weren't doing before. As a side-effect, it would also aid memory usage. I started doing the big changes and got us down to failing under 2% of the regression tests that we passed before starting the refactor in just a few hours, and had various "unexpected successes" too (where TODO tests start to pass). I then worked with *Patrick* to track down some of the others, before finishing up my talk for the weekend's Twin City Perl Workshop and getting some sleep in before that. When I checked in on the IRC channel the next day, *Patrick* had finished and merged the branch. Over the coming days we'll probably find some more tests that we can now un-skip as a result of these fixes.

Thanks go to Vienna.pm for funding Thursday's work, and being a big part of making Twin City Perl Workshop a really good one.
