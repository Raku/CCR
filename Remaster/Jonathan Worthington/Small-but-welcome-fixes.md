# Small, but welcome, fixes
    
*Originally published on [2016-04-05](https://6guts.wordpress.com/2016/04/05/small-but-welcome-fixes/) by Jonathan Worthington.*

Last week wasn’t one of my most productive on Raku, thanks to a mix of Easter holiday, a little more work than expected on another project, and feeling a tad under the weather for a day or so. In the time I did find, though, I managed to pick off some worthwhile bits and pieces that needed doing.

### Heap snapshot issues triage

It’s generally very clean and pleasant that our meta-objects are, so far as the VM is concerned, just objects. This means the answer to “can types be GC’d” is easy: sure they can, so long as nothing is using them any more. The downside is that the VM has very little insight into this huge pile of objects, which is why we have various “protocols” where the MOP can provide some hints. A lot of performance wins come from this. When I was working on heap snapshots, I found it would also be rather useful if there was a way to let the VM know about a “debug name” for a type. A name that isn’t used for any kind of resolution, but that can be included in things like heap snapshots. It’ll no doubt also be useful for debugging. So, I added an op for that, nqp::setdebugtypename, and used it in a branch of NQP, meaning I got more useful heap snapshots. This week, I also added this op to the JVM backend, meaning that I could merge the branch that uses it. This means that you can now do a normal build of Rakudo/NQP/Moar and get useful typenames in the MoarVM heap snapshots.

Last time, I mentioned that the heap snapshot viewer took an age to start up because we were super slow at reading files with really long lines. This week, I fixed this performance bug with [two](https://github.com/MoarVM/MoarVM/commit/5f76d030d723c00d0ecd6c2c8a876cbeb72b92fe) [patches](https://github.com/MoarVM/MoarVM/commit/7d59b005a4f034049c89bc10f169b09dce6e4022). Now, the heap snapshot analyzer picks apart a 25MB snapshot file into its various big pieces (just looking at how each line starts) and reaches its prompt in under a second on my box. That’s a rather large improvement from before, when it took well over a minute.

I also looked at a C-level profile of where MoarVM spends time doing the detailed parsing of a heap snapshot, which happens in the background while the user types their first command, and then blocks execution of that command if it’s not completed. The processing uses a few threads. The profile showed up a couple of areas in need of improvement: we have a lot of contention on the fixed size allocator, and the GC’s world-stopping logic seems to have room for improvement too. So, those will be on my todo list for the future.

### Fixing a couple of crashes

SIGSEGV is one of the least inspiring ways to crash and burn, so I’m fairly keen to hunt down cases where that happens and fix them. This week I fixed two. The first was a [bug in the UTF8 Clean 8-bit encoding](https://github.com/MoarVM/MoarVM/commit/4afd7b624255eeb0d9d28166212243c7de443fde), which turned out to be one of those “duh, what was I thinking” off-by-ones. The second was a little more fun to track down, but turned out to be memory corruption thanks to [missing GC rooting](https://github.com/rakudo/rakudo/commit/ecb7f700d0f1caf647f89136d05d3a3b26b23f4d).

### And…that’s it!

But, this week I’m set to have a good bit more time, so hope to have some more interesting things to talk about in the next report. :-)
