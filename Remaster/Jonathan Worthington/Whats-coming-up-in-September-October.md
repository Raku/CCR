# What’s coming up in September/October
    
*Originally published on [2011-09-12](https://6guts.wordpress.com/2011/09/13/whats-coming-up-in-septemberoctober/) by Jonathan Worthington.*

So, YAPC has come, been great, gone and been recovered from, I’m done with my summer visiting, the $dayjob speaking trip has taken place, I’ve shaken off the obligatory start of autumn cold and it’s time to get back to hacking on stuff. Actually, I’ve no more workshops or other trips until November and I’ve got Raku time marked in my schedule, so all being well there should be plenty of time to Get Stuff Done. :-) So what have I got planned for the next couple of months?

### Ship a “nom”-based Release

This is the current priority. Day by day, we’re fixing up test files we lost in the refactor. This weekend I got most of the missing bits of parametric role support back in place (and I’m overall happy with the resulting factoring; it’s a massive amount better than what we had before). Our biggest remaining holes are in the regex and grammar handling, which *pmichaud*++ is on with (I’m quite excited about what’s coming here). Other than that, it’s little bits here and there. We’re getting there. :-)

### A Basic Rakudo Optimizer

I’ve started playing with this a bit, in a branch. Nothing interesting to see yet, other than an optimizer that only knows one optimization, makes a few things a little faster and regresses a couple of spectests (so, some weird bug in the analysis or transform somewhere). The good news is that it does successfully make it through applying that optimization to CORE.setting. This is an important part of developing the optimizer: if we’re going to write our built-ins in Raku, we really want an optimizer to go over them too. My aim is to teach this a couple more things and have it in the October release.

### A Basic NQP Optimizer

NQP is the subset of Raku that we write most of the compiler in. We also implement the various built-in meta-objects in it (so we want it to be fast here, and of course we want faster compiles!) It currently has no optimizer, a situation I plan to change. NQP has many restrictions that full-blown Raku does not have, and as a result we’ll be able to do some more aggressive optimizations, or be able to apply them with far simpler analysis. My goal is to have some form of basic optimizer in NQP by the October release. Of course, since NQP is bootstrapped, NQP’s optimizer can be used to optimize NQP itself (yes, it can optimize the optimizer…) “So we just keep running NQP on itself until it runs crazy fast?” Er, no, sorry, it doesn’t work like that. :-)

### Bounded Serialization

Currently, as we compile programs, we build up a complete “model” of the runtime environment (for example, we build `Signature` / `Parameter` objects, meta-objects to represent classes, and so forth). If we’re going to just run the program, we carry these objects over to runtime and use them. If we’re in compilation mode, like we are with the setting, then we generate a bunch of “deserialization code”. This gets run first of all when we load the setting/module in question. This introduces a couple of problems.

- It’s a lot of code to generate. In fact, it accounts for a whopping 60% of the lines of PIR in CORE.setting! This probably means that about 60% of the PAST nodes we generate and then have to process into POST and then PIR are also related to this. Assuming we could replace this process with something much faster, we’re looking at cutting compilation time in half for the setting. Note that this only really affects pre-compilation time, not “run immediately” mode.
- We have to run it all at load time. Now, having it all in one huge blob is decidedly more efficient than the thousands of little loadinit subs we had everywhere in previous generations of Rakudo. But we still have to do it, and it means that loading the setting – something we have to do every time we start Rakudo to compile or run code – pays that cost. We need better startup time.
- We have to make sure that every single change that gets made gets recorded. We cheat a bit here. This gets in the way of many things, including various optimizations and proper `BEGIN` time support in pre-compiled modules (note that we don’t re-run `BEGIN`, but we should maintain effects of it).

The solution is to find a way to efficiently serialize everything we create, and then be able to deserialize it efficiently at load time and do the few needed fixups. While in theory it’s “easy” (keeping iterating over a worklist until you’ve serialized everything, basically), there’s a bunch of really tricky things that also come up (especially any closures that got taken at compile time). I hope to dig into this before the end of the month, and my target is to have it for the November release (October one is a bit ambitious, unless it goes crazily well; in reality, I’d like to land it late October, so we have a couple of weeks before the November release to get it in shape).

### Revive the CLR Backend

Running NQP on the CLR got a long, long way. At the time I last touched it, the majority of the non-regex tests in the NQP test suite were passing, and *diakopter*++ was making progress on the regex ones too. It’s been dormant for a while, but it’s time to get back to work on it. Getting NQP, and then Rakudo, to run on the CLR is now a vastly more tractable task to back then, since:

- Back then, I was in the process of designing 6model *and* doing an NQP port *and* working out what NQP on 6model would look like. Now I only have to worry about one of those things, not all three at the same time.
- NQP itself is 6model based now. Thus there won’t be a need for the “JnthnNQP” fork (NQP itself ended up looking much more like JnthnNQP anyway, which was the idea). If I do need tweaks that I can’t immediately reconcile with NQP on Parrot, they can be done just by subclassing `NQP::Actions` or so and overriding the things in question. Either way, it’ll be the same – or a slightly twiddled – version of NQP, not a vastly different one.
- Rakudo itself is now mostly written in NQP and Raku. We used to have a bunch of PIR builtins, but they’re long gone (along with various ugly issues they caused, like not having proper Raku signatures and so forth). I’d guesstimate that about 5% – at most 10% – of the Rakudo code is backend specific. Some of it will be tricky, but a lot of it is – at least if you’re familiar with it – pretty mundane.

Of course, some problems I chose to ignore will need to be dealt with (like, how to best harness the way to CLR thinks of types in order to implement 6model representations more efficiently, and how to support `gather` / `take`). It’ll need generating IL rather than C#. And…plenty more. I’m not going to set any targets for this just yet; I’ll just dig in, have fun, and we’ll see where things land up in a month or two. I found it great fun to work on this last time – the CLR is a nice VM and well tuned – so it shouldn’t be hard to get a round tuit. :-)

### Other Bits

Of course, there’s still bits of the Raku spec that needs implementing, and things in module space. Amongst things I’d like to hack on soon are big integer support (so we can do `Int` right), natively typed operators and teaching `NativeCall` to handle structures.

### Other 6model Bits

I want to vastly improve the state of 6model’s documentation. Taking a moment to look further ahead than the next couple of months, once the updated CLR implementation of it comes together, and when some other language’s object systems have been shown to be buildable on 6model, I also want to think about declaring a “6model API v1” or so. This is so that if/when Parrot integrates 6model, or others implementations show up that I won’t have a close hand in, there’s a clear idea of what it’s expected to look like from the outside, and what are implementation details (and thus can be done in whatever way is appropriate). I also expect further extensions, refinements, and so forth, and I think it’d be best to give folks who implement 6model – myself included! – some coarser grained way of saying “we support this set of things” than just listing off implemented features. This is some way off, though I do already have a slowly forming picture of what I’d like to tackle in the area of meta-model design in the future.

So, that’s what I’ve got in mind. Oh, and I should be sure to blog as I work on this stuff! Feel free to prod me if I forget. :-)
