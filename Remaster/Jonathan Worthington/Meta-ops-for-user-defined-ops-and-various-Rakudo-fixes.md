# Meta-ops for user defined ops, and various Rakudo fixes
    
*Originally published on [20 May 2009](https://use-perl.github.io/user/JonathanWorthington/journal/39011/) by Jonathan Worthington.*

I scheduled this week's Rakudo day to take place just before this month's release, and used most of it for fixing bugs. Before I dug into that, I spent some time looking over the change log and adding a few things that it was missing. As in April, we're going to have a really quite impressive release this month with lots of new features and improvements. It's great to be part of such a productive team, and I'm quite proud of what we're achieving together.

My first fix was to typed attributes. They worked for the scalar case, but not for the array and hash cases (just about all the pieces were there, just the very final bit to apply the constraint to the attribute was missing). *moritz*++ had already written a bunch of tests, so after the fix I was able to unfudge them, giving us another 19 passing tests and resolving an RT ticket. Not a bad start to the day's bug fixing.

Next up, I wanted to sort out attribute initializers. If you write:

```` raku
class Foo { has $.r = rand }
````

Then you should (probably ;-)) get a different value per instantiation, since the rand is meant to be called per instantiation. We were getting this wrong in Rakudo to date, so I fixed that. In the process of changing things, I also did the fixes required so you can now write things like:

```` raku
class Foo { has $.a = 1; has $.b = 2; has $.c = $.a + $.b;}
> say Foo.new.c # output 3
````

That is, initializing one attribute based upon the already initialized values of those that appear before it.

The Rakudo multi-dispatcher is pretty stable, but there have been a couple of issues that have come up where it doesn't get things right. Today I dug into solving a couple of bug reports that turned out to boil down to the same fix in the end, which affected multi-variants that had a slurpy positional parameter and named parameters.

There were a couple of tickets about attributes declared with the & sigil not working as expected. These have now been fixed, so you can declare attributes with this sigil and expect them to work, or mostly work anyway.

As I mentioned last time around, *pmichaud*++ has got operator overloading and user-defined operators in place. This is great, but we weren't generating the various meta-operator forms (so you couldn't use your user-defined operators in a reduction, assignment, hyper, cross or reverse meta-operator). After some hacking tonight, you now can. Thus, taking a pointless but easy to understand example operator, we now can do things like this:

```` raku
sub infix:<wtf>($a, $b) { $a ~ "WTF" ~ $b }

say 'OMG' wtf 'BBQ'; # OMGWTFBBQ - this already worked

my $a = 'OMG';
$a wtf= 'BBQ';
say $a; # OMGWTFBBQ

say [wtf] <OMG BBQ PONIES>; # OMGWTFBBQWTFPONIES

say 'BBQ' Rwtf 'OMG'; # OMGWTFBBQ

say ~('OMG','BBQ' Xwtf 'OMG','BBQ'); # OMGWTFOMG OMGWTFBBQ BBQWTFOMG BBQWTFBBQ
````

Finding a better use for this new power is left as an exercise for the reader. :-) Thanks to Vienna.pm for funding this Rakudo Day, and enjoy the release, which will no doubt be with us within the next 24 hours.
