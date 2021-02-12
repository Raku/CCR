# Raku importing, and soon sockets
    
*Originally published on [25 March 2009](https://use-perl.github.io/user/JonathanWorthington/journal/38701/) by Jonathan Worthington.*

For a while now there's been a kind of longing for socket I/O in Rakudo. The ever-creative users of Rakudo have even managed to get a HTTP server running in Rakudo without them anyway, using netcat! However, a few days back I started trying to make sockets happen. I'm really not a network I/O guy, so I've been very happy that all I've had to do so far is encourage *bacek*++ to work on getting socket I/O sorted out in Parrot, take his (large - *bacek*++ again) patch, write the Win32 port of it and apply it. This was the first bit of my Rakudo day, and while it was essentially Parrot work, it's already allowed *mberends*++ to start building Raku's socket support on top of it. It's being written directly in the setting, mostly in Raku and with a few little bits of embedded PIR to interface with Parrot's I/O subsystem. Thanks also go to *Infinoind*++ and *NotFound*++ for helping to sort out a few other little bits in Parrot's socket implementation. Teamwork for the win. :-)

Away from that, I got various other bits of stuff done too. Having got state variables to work last week, this week it took a fairly small patch to build on top of the same infrastructure and get `START { ... }` blocks in place. These are blocks that run once per clone of a subroutine. There was already a good bunch of tests for it, and my first attempt past the majority of them. Another four will be relatively easy to make pass in the future (using `START { ... }` as an expression rather than as a statement) and one of them fails because of a perhaps unrelated bug elsewhere in Rakudo.

We've supported the `.assuming` method for currying for a while. Today I spotted a test file in the spectests for `.assuming` and multi subs, and wondered if we shouldn't be able to run that already. It turned out not, but the commit to fix that up was tiny. So, that's another test file we now run and pass all of.

After this, I returned to working on importing. I fixed up the issues with importing multis, and then got tags working. Tags let you group symbols that you want to export under names, and then you can use those names to pull in the groups you want at import time. For example, suppose I have a module:

```` raku
module Pub;
sub drink_beer($pints) is export(:drinking, :DEFAULT) { ... }
sub drink_vodka($shots) is export(:drinking) { ... }
sub `play_pool` is export(:games) { ... }
sub `play_darts` is export(:games) { ... }
sub `pay_bill` is export (:MANDATORY) { ... }
````

And then import symbols from it like this:

```` raku
use Pub; # Imports drink_beer and pay_bill
use Pub :drinking; # Imports drink_beer, drink_vodka and pay_bill
use Pub :drinking, :games # The above plus play_pool and play_darts
````

Note that pay_bill is tagged MANDATORY, meaning any use of the module will import that symbol. If you didn't know all of the tags but knew you wanted everything, you could just have written:

```` raku
use Pub :ALL;
````

And got everything that was exported. Note that if you write `is export` without naming a tag, then it gets an implicit tag of `:DEFAULT`.

I also did some thinking over dinner that led to me realizing what I think should be a relatively easy way to get lexical subs and multi subs in place. However, I ran out of time to implement it today, so I'll have that for Next Time. Thanks to Vienna.pm, as always, for sponsoring Rakudo day.
