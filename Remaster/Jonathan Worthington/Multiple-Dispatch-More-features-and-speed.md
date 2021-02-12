# Multiple Dispatch: More features and speed
    
*Originally published on [22 November 2008](https://use-perl.github.io/user/JonathanWorthington/journal/37924/) by Jonathan Worthington.*

I'm working hard at the moment on getting my long-overdue MMD grant from DeepText finished up. I've got some various bits of progress to report.

First, I cleared up the subset type code. The first cut I did of it a while back had a Subset class, which shouldn't really have existed. Now a subset is (under the hood - **not** conceptually) an anonymous subclass of the thing it is refining which overrides `ACCEPTS` and keeps the block around. The Subset type is gone. Also, importantly, it's easy to now find out what the real, non-subset type at the "root" of it all is. And with that in place, I could get subsets and their interaction with nominal types correct in the multiple dispatch algorithm. So, that should now work just fine.

I also got the `default` trait in place. This means that if you have two candidates that could be ambiguous, you can mark one of them as the default. A (useless) example is:

```` raku
multi `foo` { say 1 }
multi `foo` is default { say 2 }
`foo`;
````

Which will always output 2. As I said, useless here, but if you have a bunch of maybe-not-quite-mutually-exclusive-always subset types and want to mark one as the default if you know there's a potential overlap this is a way to do so. And with this in place, we now have all of the ways that a dispatch is decided implemented. To the best of my knowledge, it's correct.

I'm generally not into performance work at this stage of the game, but MMD is heavily used in Raku. In the not too distant future we will have a prelude written in Raku, and then all of the operator dispatches will happen through the Raku dispatch algorithm. Further, Parrot's MMD for ops had recently got more costly as it got unified with the MMD for subs (good in that we no longer have two different multiple dispatch algorithms in the Parrot core). Thus I set out to write a basic MMD cache that would aid both of these.

I didn't optimize the heck out of the cache, I just did it quickly with what was easily to hand. The same caching system can be used by both Perl6MultiSub and Parrot ops, and in the future the Parrot MultiSub PMCs too (which the compiler users, so we may get a small performance gain there, but it won't be much). I got Perl6MultiSub using it and, after fixing a bug involving arguments instantiated from anonymous classes, all tests passed with the cache. The performance was an improvement. I ran as a benchmark:

```` raku
multi sub foo(Int $x) { 1 }
multi sub foo(Num $x) { 2 }
loop (my $i = 1; $i < 25000; $*i*++) {
    foo(4);
    foo(4.2);
}
````

Without the cache, it takes 20.25s on my box; with the cache it runs in 6.953s. Note that only part of the time in the execution is spent in the dispatcher, and it takes well over 3 times improvement in dispatch time itself to make the whole program run in less than a third of the time. So, that's a satisfying improvement (though looking at the times, we're still only making 3500 calls to a multi sub per second here...then, this is an unoptimized Parrot build and the Parrot calling conventions that actually do the args passing are a known area in need of optimizing, plus we're waiting on GC improvements too, so I'm optimistic that once the other factors improve we'll be doing better).

So how does the cache actually work? We cache on the types of the arguments. This involves collecting their type identifiers and, for now, building a hash key out of them. In the future we may be able to do something smarter. But it means that if you have the operator infix:+ and it has been overloaded plenty, and you're calling it repeatedly with a type it hasn't been overloaded for, you'll now just hit the cache each time after the first call, rather than having to run through a bunch of type-narrower candidates that come before the more general candidate.

Note that, due to a few Parrot test fails we're tracking down in the use of the cache with MMD'd Parrot ops (not directly a problem in the cache itself, but providing the right info to the cache), it's currently in a branch. All Rakudo's tests and the same bunch of spectests are passing with the cache, however, so Rakudo is ready to run with it. We'll get it merged soon - maybe even later today or tomorrow.

Things coming very soon: making multi methods work as well as multi subs with the new dispatch algorithm and supporting the double semicolon to specify some parameters are not part of the long name and should not be dispatched on. Thanks to [DeepText](http://www.deeptext.ru/) for funding this MMD work.
