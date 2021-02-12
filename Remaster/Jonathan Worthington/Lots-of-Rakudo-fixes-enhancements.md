# Lots of Rakudo fixes/enhancements
    
*Originally published on [9 August 2008](https://use-perl.github.io/user/JonathanWorthington/journal/37140/) by Jonathan Worthington.*

So, I'm on my way to YAPC::Europe! I'm writing this for posting next time I have net access, from Bratislava airport, which is busier than I've seen it before. Even so, I arrived an hour and a quarter before my flight was due to leave and found only two people in the queue to check in, then found a seat in departures to wait for boarding. I'm flying to Sweden, and will take a few days of holiday and seeing Swedish friends before heading over to Copenhagen to join the pre-conference hackathon on Tuesday.

Thursday was this week's Rakudo day. I planned to start on lazy lists, but didn't get to it. I did do many fixes, however, that will make a lot of things that you expect to Just Work actually, well, work.

Maybe the biggest thing is that the anonymous hash composer `{ ... }` now works. It's a tad subtle because of course this syntax could be a block too. The heuristics used to determine it's a hash are as follows:

- It's empty, e.g. {}
- It contains just a single pair, e.g. `{ x => 42 }` or `{ :x<42> }`
- It contains a list, and that list starts with a pair OR a hash, e.g. `{ x => 42, y => 99 } or { %h, foo => 'bar' }`

If it matches one of these, you get an anonymous hash. Otherwise, you get a block. Of course, any keyword introducing a routine, or the lambda syntax, means that you always get a block.

There are numerous other fixes and enhancements too:

- `unlink` is implemented, to allow deleting of files
- `$!foo` syntax for accessing an attribute works in nested scopes in a method now, not just the outermost one (fixing this involved implementing a missing but spec'd bit of PCT, so this should help others implementing OO bits in PCT)
- Attributes with the `@` and `%` sigils are now properly initialized to an `Array` and a `Hash` respectively, so work as expected
- Adding two `Int`s would, before now, always lead to a `Num` instead. This was also the case for many other operators. This is now fixed, but took some care to do, in order to upgrade to a `Num` on divisions, say. This also fixes the bug where trying to write something like factorial with an `Int` type constraint now works, 'cus you get `Int`s back, as expected.
- Classes with namespaces now work, so you can now write class `Foo::Bar { ... }`
- The `does` and `but` operators could run into issues when you mixed in multiple roles to one object one at a time; this is now resolved and has a spectest
- There was a regression in the `handles` trait adverb when used with a pair. I fixed it and made sure we have tests for the `handles` trait verb so it doesn't get broken again
- Fudged and added a few more spectests to cover things that weren't being tested properly before, and un-fudged stuff we could now to, so we're passing tens of extra spectests now

Thanks for Vienna.pm for funding this work.
