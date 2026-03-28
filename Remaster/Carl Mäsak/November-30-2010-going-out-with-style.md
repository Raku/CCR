# November 30 2010 — going out with style
    
*Originally published on [1 December 2010](http://strangelyconsistent.org/blog/november-30-2010-going-out-with-style) by Carl Mäsak.*

> 57 years ago today, the king of Buganda (a part of Uganda), [Major General Sir Edward Frederick William David Walugembe Mutebi Luwangula Mutesa II](https://en.wikipedia.org/wiki/Mutesa_II_of_Buganda) (Knight Commander of the Order of the British Empire), was exiled because he had a disagreement with the British Governor.

> In the early 1950s the British Government floated the idea of uniting British East Africa (Uganda, Kenya and Tanganyika) into a federation. Africans feared that this would lead to their coming under the control of Kenya's white settler community, as had happened in Rhodesia. The Baganda, fearing they would lose the limited autonomy they had under British rule, were particularly opposed. Mutesa opposed the proposal, and thus came into conflict with the British Governor, Sir Andrew Cohen. Cohen deposed and exiled the Kabaka in 1953, creating massive protests among the Baganda. After two years in exile Mutesa was allowed to return to the throne under a negotiated settlement which made him a constitutional monarch and gave the Baganda the right to elect representatives to the kingdom's parliament, the *Lukiiko*. Mutesa's standing up to the Governor greatly boosted his popularity in the kingdom.

Sir Edward Muteesa seems to have led an interesting life. He "is recorded to have fathered eleven sons and seven daughters". He died of alcohol poisoning in his flat, under somewhat mysterious circumstances.

Let's finish off with some statistical comparison between November-on-alpha (before we throw it on the trash heap of history) and November-on-ng.

Because I thought it might be interesting, I tried both of these with and without article caching. I ran each of the four possible setups 10 times under identical conditions. The data points are in seconds of wallclock time.

I should really make a cute graph for this, but I ran out of time. Maybe later.

## ng/cache

```
9.444
9.662
9.275
9.356
10.160
9.621
10.026
9.522
9.860
9.737
```

## ng/no cache

```
46.353
52.880
63.742
44.745
46.320
59.831
63.585
58.116
57.459
54.510
```

## alpha/cache

```
7.489
4.847
2.912
3.031
2.809
2.807
2.985
2.778
2.849
2.955
```

## alpha/no cache

```
9.735
10.185
8.558
6.288
7.101
6.070
6.170
6.132
6.234
6.064
```

## So.

In summary:

- November on ng with the cache turned on runs in about 10 seconds.
- Turn off the cache, and it slows down about five times.
- November on alpha used to run in about 3 seconds.
- With the cache turned off, it slowed down 2-3 times.
- November on alpha with the cache turned off ran faster than November on ng with the cache.

Summa summarum: over the past year, Rakudo has gotten 3-10 times slower.

I'd like that order of magnitude back before I think of deploying November on the web again. The caching was introduced to make November *juuust* bearable to use. Now it turns out that upgrading to ng eats up that speedup.

Of course, from many viewpoints *other* than speed, we're much further ahead now than a year ago. But that doesn't change the fact that November was developed on alpha and, even after porting it to ng, it still runs best on alpha.
