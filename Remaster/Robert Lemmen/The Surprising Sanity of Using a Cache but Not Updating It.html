The Surprising Sanity of Using a Cache but Not Updating It
==========================================================

A while ago we added some client side caching to a biggish application at work,
as you do. This led to an interesting observation I would like to share:

We clever monkeys realised that we have a handful of different call arcs that go
through this cache, and that not all of them are similar in terms of
functionality. For
example some of them can handle the inconsistencies introduced by the cache,
other cannot and were therefore modified to bypass the cache. So we end up with
different code paths that return pretty much the same data, "just" one cached
and one not. Urgh, not very nice. But probably the price one has to pay for 
having this cool cache that will make everything blazingly fast, right? 

We dutifully monitored everything, including cache hit rates. And we did see
really high hit rates, as expected for this cache, and the expected cache
warming patterns when the system boots up. How nice when things go as expected!

Except that now and then something weird happens: it looks almost as if the
cache randomly goes back into a mostly-cold state and then goes
through the warming pattern again! How can that be? Unfortunately I don't have a
quality screenshot from our monitoring system (too much noise to be usable
here), but the following graph shows the same behaviour from a Monte-Carlo
simulation built to experiment with this behaviour:


![weirdness1](weirdness1.svg)

The simulation takes a simple LRU cache with a maximum size of 1000 entries.
Access is following a Poisson distribution with 50% of all hits going into the
first 300 cache entries, and a total of 10000 things that could be cached. The
simulation makes 100 calls per time unit, and is run 100 times to get averages
and deviation. The simulation code can be found at https://github.com/robertlemmen/cache-weirdness/blob/master/cache-sim1
You can clearly see the cache starting cold with a low hit rate, 
then warming up and reaching something resembling steady-state around 30 of 
whatever that time-unit is. All matching what one would expect.

Halfway through the run the cache is hit with a different access pattern, a
linear scan through all items. In our system this was a housekeeping task, not
so uncommon to have. This linear scan of course (in hindsight) destroys the LRU
property of the cache, now the entries are pretty much random ones (funny how
sequential and random can sometimes be the same thing), rather than the ones
most likely to be used again soon. And with this, the return to a 10% cold state 
suddenly and sadly makes perfect sense!

In our case we ended up still using the cache, but in this call arc we do not update it when
there is a cache miss, a capability I promptly added to the
Cache::Async library (https://github.com/lizmat/Cache-Async). But I 
guess the benefits of using the cache for this access type are not that great and just 
bypassing the cache entirely would have been fine as well.

More interesting than the code-level fixes are the design consequences though:
Having different code paths for access to the same data, just with different
correctness guarantees, seems unfortunate but perhaps acceptable. But different
code paths for access patterns that return the exact same data with the same
guarantees, but with a different probability what will be called next? That
seems insane! This entirely destroys the idea of domain driven design and
pushing technicalities like caching into a transparent infrastructure layer.
Even worse: the code we added the cache to is a service, the client making the
calls with that access pattern is somewhere else. So we need to expose this
nastiness in the API and can't hide it under the carpet. And us adding the cache
required changes to that client code, exposing unexpected far coupling.

So, caches: making your design shitty in unexpected ways!
