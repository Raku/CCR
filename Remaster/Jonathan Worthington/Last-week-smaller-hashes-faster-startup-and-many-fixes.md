# Last week: smaller hashes, faster startup, and many fixes
    
*Originally published on [2015-05-15](https://6guts.wordpress.com/2015/05/15/last-week-smaller-hashes-faster-startup-and-many-fixes/) by Jonathan Worthington.*

I’m a little behind with writing up these weekly-ish reports, mostly thanks to attending [OSDC.no](http://act.osdc.no/osdc2015no/) and giving about 5 hours worth of talks/tutorials. That, along with spending time with the various other Raku folks who were in town, turned out to be quite exhausting. Anyway, I’m gradually catching up on sleep. I’ll write up what I did in the first week of May in this post, and I’ll do one in a couple of days for the second week of May.

### Shrinking hashes

In MoarVM, we’ve been using the UT Hash library since the earliest days of the VM. There was no point spending time re-implementing a common data structure for what, at the time, was decidedly an experimental project, especially when there was an option with an appropriate license and all contained in a single header file. While we started out with it fairly “vanilla”, we’ve already tweaked it in various ways (for example, caching the hash code in the MVMString objects). UT Hash does one thing we didn’t really need nor want for Raku: retain the insertion order. Naturally, we paid for this: to the tune of a pointer per hash, plus two pointers per hash item (for a doubly linked list). I ripped these out (which involved re-writing a few things that depended on them), as well as gutting the library of other functionality we don’t need. This means hashes on MoarVM on 64-bit builds are now 8 bytes smaller per hash, and 16 bytes smaller per hash item. Since we use hashes for plenty of things, this is a welcome saving; it even produces a measurable decrease to Rakudo’s base memory. This also paves the way for further improvements to hashes and string storage. (For what it’s worth, the time savings as a result of these changes were tiny compared to the memory savings: measurable under callgrind, but a drop in the ocean. Turns out a doubly linked list is a rather cheap thing to maintain.)

### Decreasing startup time

I did a number of things to improve Rakudo’s startup time on MoarVM. One of them was changing the way we store string literals in the bytecode file. Previously, they were all stored as UTF-8. Now, those that are in the Latin-1 range are stored as Latin-1. Since this doesn’t need any kind of decoding or normalization, it is far cheaper to process them. This gave a 10% decrease in instructions executed at startup. Related to this, I aligned the serialization blob string heap with the bytecode file one, meaning that we don’t have to store a bunch of mappings between the two (another 2% startup win, and a decrease in bytecode file size, probably 100KB over all the bytecode files we load into memory as part of Rakudo).

2% more fell off when I realized that some careful use of static inlines and a slightly better design would lower the cost of temporary root handling (used to maintain the “GC knows where everything is” invariant). This took 2% off startup – but also will be an improvement in a lot of other code too.

Another small win was noticing that we built the backend configuration data hash every time we were asked for it, rather than building it once and caching it. This was an easy win, and saved building it 7 times over during Rakudo’s startup (adding up more things to GC each time, of course). Finally, I did a little optimization of bounds checking when validating bytecode. These two improvements were both below the 1% threshold, though together added up to about that.

### The revenge of NFG

Shortly after landing NFG, somebody reported a fairly odd output related bug. After a while, it was isolated to UTF-8 encoding, and when I looked I saw…a comment saying the encoder code would need updating post-NFG. D’oh. So, I took care of that, saving us some memory along the way. I also noticed some mess with NULL-terminated string handling (MoarVM ones aren’t, of course, but we do have to deal with the C world now and then), which I took the opportunity to get cleaned up.

### Digging into concurrency bugs

Far too much of the concurrency work I did in Rakudo and the rest of the stack was conducted under a good amount of time pressure. Largely, I focused in getting things sufficiently in place that we could play with them and explore semantics. This *has* served us well; there was a chance to show running examples to the community at conferences and workshops and gather feedback, and for `Larry` and others to work on the API and language level of things. The result is that we’ve got a fairly nice bunch of concurrency features in the language now, but anybody who has tried to use them much will have noticed they behave in a rather flaky way in a number of circumstances. With NFG largely taken care of, I’m now going to be turning more of my attention to these issues.

Here are some of the early things I’ve done to start making things better:

- Fixing a couple of bugs so the t/concurrency set of tests in NQP work much better on MoarVM
- Hunting down and resolving an [ABA problem](http://en.wikipedia.org/wiki/ABA_problem) in the MoarVM fixed size allocator free list handling, which occurred rarely but could cause fairly nasty memory corruption when it did (RT #123883)
- Eliminating a bad assumption in the `ThreadPoolScheduler` which caused some oddities in `Promise` execution order (RT #123520)
- Adding missing concurrency control to the multi-dispatch cache. While it was designed carefully to permit reads (concurrent with both other other reads and additions), so you never need to lock when doing a multi-dispatch cache lookup, the additions need to be done one at a time (something forseen when it was designed, but not handled). These additions are now serialized with a lock.

### Other assorted bits

Here are a few other small things I did, worth a quick mention.

- Fix and tests for RT #123641 and #114966 (cases where we got a block, but should have got an anonymous hash)
- Fix RT #77616 (`/a ~ (c) (b)/` reverted positional capture order)
- Review and reject RTs #116525 and #117109 (out of line with decided flattening semantics)
- Add test for and resolve RT #118785 (`use fatal` semantics were already fixed, but good to have an explicit test case)
- Tests for RT #122756 and #114668 (an already fixed mixins bugs)
