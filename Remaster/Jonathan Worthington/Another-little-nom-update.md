# Another little nom update
    
*Originally published on [2011-06-28](https://6guts.wordpress.com/2011/06/28/another-little-nom-update/) by Jonathan Worthington.*

I was gearing up to blog a bit about the progress we’re making on the nom branch of Rakudo, when *pmichaud*++ swooped in with a [great post about that](http://pmthium.com/2011/06/27/lots-of-rakudo-nom-progress-starts-to-run-spectests/). It nicely captures how much we’re getting done putting Rakudo back together on top of 6model. Along the way, we’re also dealing with various other deeper issues, which will let us close a bunch of tickets in RT when the branch lands. Overall, the code base is now a lot more pleasant to work with, and the factoring of the OO features is far superior to what we had in master. Another really nice thing is that lexical symbol installation is far, far neater; it sounds like a small thing, but it’s made hacking on Rakudo far more pleasant.

It’s also exciting that we’ve started to get native types in place now. I’ll warn you up front: don’t expect a speed win from them yet. We’re building towards that, but it’s non-trivial and not a priority for the nom branch; it’ll come later. On the other hand, if it’s memory savings you’re after then having tens of thousands of objects having attributes that are native ints will be way cheaper than if they had been boxed ones. That said, the boxed ones consume about a third of the memory they do in master, not to mention being three times less work for the GC. So you’ll win plenty over master even without using the natives, or any type annotations at all.

The nom branch will deliver direct performance improvements as well as lay the foundations for writing a much-needed optimizer. Even without that optimizer in place, we’re getting some nice wins. In *pmichaud*’s post he talked about for loops being 80% faster. Here’s a couple more little micro-benchmarks. The program:

```` raku
my $i = 0;
while $i < 1000000 {
    $i = $i + 1; 
}
say $i
````

Runs in about 25% of the time that master takes (thus 4 times faster). And we do way better on a floating point version of this due to far better handling of numeric literals. This:

```` raku
my $i = 0;
my $a = 0.0e1;
while $i < 1000000 {
    $i = $i + 1;
    $a = $a + 0.25e1
}
say $i;
say $a;
````

Runs in 4.5% of the time master does it in, or over 20 times faster.

Now, these improvements themselves aren’t that impressive, but they are just the ones that fall out of using the new object model, better handling of literals, various block and variable setup improvements and so forth. The exciting part will be when we start using the extra information we now have available at compile time in order to do things like compile-time resolution of multi candidates, inlining and type inference. Glancing the profiles to see where we spend time, I expect these will give us another order of magnitude improvement.

That’s all for now – time for me to get some rest. Tomorrow I’ll be flying to Beijing, to give some talks at the Beijing Perl Workshop and no doubt take in many of the wonderful attractions the Chinese capital has to offer, not least the awesome food. I have so many fond memories of when I spent a month backpacking around China, and I didn’t leave much time for Beijing then, so it’ll be nice to see the many things I didn’t have time for. And no, I won’t be vanishing from Rakudo hacking for a week; keen to look around as I’ll be, I suspect the cold-weather-loving me will probably also be keen to sit inside and hack a bit when the temperatures hit 35C or so. :-)
