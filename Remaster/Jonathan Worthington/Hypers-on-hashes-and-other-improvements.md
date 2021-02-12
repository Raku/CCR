# Hypers on hashes and other improvements
    
*Originally published on [10 May 2009](https://use-perl.github.io/user/JonathanWorthington/journal/38949/) by Jonathan Worthington.*

Rakudo day was a little but non-day-ish this week, and instead ended up spread over a couple of days. This was mostly as a result of me accidentally scheduling it on a national holiday, then being unable to resist the temptation of going and enjoying some nice food and beer, sat outside enjoying the evening warmth. Anyway, between the work yesterday and today, we've some new stuff. :-)

We've had hyper-operators for a while on lists/arrays, but now I've implemented the extra bit of the hyper operator specification that makes them work on hashes too. The dwim-ness relates to the keys of the hashes; the fat end pointing at a hash means "I want its keys". However, the operations are performed on the values. Thus if you had a hash mapping names of candidates to the number of votes they got, and wanted to total the votes of two groups (or use this to make a running total over many hashes) you could write:

```` raku
my %total_votes = %group_a_votes >>+<< %group_b_votes;
````

Which gives you the set union of the two keys, so if one group didn't vote for a certain candidate at all we still get their votes included. You could also use it to combine the data from, say, two different monitoring stations, but ignore readings that both of them didn't supply a value for.

```` raku
my %max_readings = %station_a <<max>> %station_b;
````

The asymmetric cases work too. I didn't find any tests for the hash hyper operator cases, so I wrote a bunch of them to exercise it.

In other matters, I did a refactor to handle roles made up of other roles and bring us more in line with the Raku specification. It states that the composition of a role made up of other roles is not evaluated until the point we compose it into a class, and we were being a bit too eager about that. The upshot was that if you ended up with a diamond hierarchy of role compositions and tried to compose the bottom of the diamond into a class, Rakudo would complain about a composition conflict. I fixed this, and expected it would fix another issue that I was quite sure was due to the same underlying bug. It didn't; some hunting later I found that actually Parrot had a bug when you tried to inherit from two anonymous classes. A one-line Parrot patch later, that bug was fixed too. Both already had test cases that I could unfudge.

I also did a couple of other small tasks.

- For a while, the spec said that default parameter type of a block was always `Any`. In a change a little while back, this was changed for pointy blocks and closures (but not routines) to Object. This means that such blocks will not auto-thread. The upshot is that you can now iterate over an array of junctions without the loop boddy getting evaluated for every element in the junction (you could before by writing an explicit type in the signature). Since auto-threading is meant to avoid junctions giving surprising non-local effects, and such blocks are normally much more local in nature, the change should make things less surprising (I've seen folks caught out by the old behavior). And of course, your methods and subs will still auto-thread. I unfudged some tests related to this too.
- I added some basic support for detecting re-defined subs (not methods yet). It's quite simplistic, but handles some common cases and was enough to pass some more tests.
- *jhorwitz*++ reported that there was a built-in we defined twice, and it was causing him some issues. I removed one of the copies of it.

Thanks to Vienna.pm for funding this Rakudo Day.
