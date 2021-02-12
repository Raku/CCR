# Rakudo: More bugs squished, over 7000 passing spectests
    
*Originally published on [25 February 2009](https://use-perl.github.io/user/JonathanWorthington/journal/38550/) by Jonathan Worthington.*

Today was Rakudo day, and I used it to get a bunch of fixes in place as well as applying some patches from other folks. Before digging in to the details, I'm happy to point out that we're now passing over 7,000 spectests - in fact, we got past that last night, before today's round of fixes, so we're well over it now.

- Fixed a bug involving the `===` operator and proto-objects; specifically, if you had an attribute `has Foo $!x` and in a method - without ever having changed `$!x` - did `$!x === Foo`, it wrongly gave False.
- Whatever wrongly inherited from Object rather than `Any`, as S02 says it should.  Changed this, which allowed me to resolve a ticket.
- Was happy to find an enums related bug report that had already been fixed - this time, by the type registry coming into existence last month. Added a couple of tests to make sure the bug didn't come back and closed the ticket.
- Got bare sigils in signatures working. This turned out to be quite easy, resolved an RT ticket and made ten or so tests that were skipped in assign.t pass too. So you can now do things like:

```` raku
my ($, $, $, $four) = 1..4;
my ($one, $two, *@) = 1..4;
````

To only assign some things. Note that *@ is just the slurpy array * - it's a signature (and in fact you would now be able to write *@ in a signature on a sub too).

- masak discovered that: `say "a".."c" Z "?", "a".."b"` Gave the wrong output and reported it. bacek sent in a patch. *Mortiz* wrote a test.  Which just left me to review and apply the patch and untodo the test. Teamwork for the win.
- Calling `.parse` on a grammar that is in a namespace did not work. I fixed it and added a test.
- Our multi-method dispatch has never been quite right, and has long been on my fix list. Now it's at least a lot more correct, in that if it finds no applicable candidates in the current class it now goes looking up the MRO.
- While I was in the multi-dispatcher, I realized that every time we got a cache miss, we leaked a little memory. Fixed the leak. Was glad that Rakudo only has a little bit of C...I'm too stupid to get manual memory management right.
- Did some tweaks to the way we construct subsets to make them act a bit more type-ish, and make sure that the type object works like a proto-object (that is, it's undefined). May need some more tweaks, but it fixes what `.defined` does and passes all the current spectests for this.
- Applied some documentation patches from *leto* and *Chris Dolan*. Easy work thanks to the github fork queue.

Additionally, I tracked down where the raku executable often crashes with a double free or got into an infinite loop on exit (it was a problem that only showed when using the executable, and not when using the bytecode file on Parrot - not because the problem wasn't there, but because Parrot didn't bother to reclaim the memory on exit so it never ran the cleanup code that exploded). I wrote a patch which sucked, but prevented the double frees. I showed it on #parrot, at which point *pmichaud* - now knowing where in Parrot the problem lay - churned out a much smaller patch that was more correct and more efficient. It's in, we bumped up the recommended Parrot version for Rakudo and I closed some tickets about segfaults.

So, thanks to Vienna.pm for sponsoring Rakudo Day this week. There won't be one next week, since I'll be taking some vacation. This weekend is the Belgian Perl Workshop, and the weekend after is the Ukrainian Perl Workshop, so I'm going to spend a bit of time in each of those countries between them, relaxing and enjoying the sights, the beer and the food. And of course, very much looking forward to seeing folks and talking about Raku and Rakudo at the workshops too!
