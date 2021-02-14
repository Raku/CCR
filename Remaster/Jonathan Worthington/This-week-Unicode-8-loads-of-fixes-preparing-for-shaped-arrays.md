# This week: Unicode 8, loads of fixes, preparing for shaped arrays
    
*Originally published on [2015-06-26](https://6guts.wordpress.com/2015/06/26/this-week-unicode-8-loads-of-fixes-preparing-for-shaped-arrays/) by Jonathan Worthington.*

It’s been another week of getting lots of small things done – but also gearing up to working on various array related things, including fixed size and shaped arrays. I expect to have some progress to report on that next week; in the meantime, here’s what I got up to in this week.

### Update to Unicode 8.0

I got MoarVM’s Unicode database upgraded to the recently released Unicode 8. Part of the work was reading the changes list to see if there were any code changes needed. After establishing that there were not, the actual upgrade was very easy, since we have a script that takes the Unicode database, extracts the bits we need, and packs it into various compact data structures. The final step was looking into 3 test failures in one of the specification test files for Raku. It turned out the tests in question were written in a way that made them vulnerable to Unicode adding additional ideographs; I fixed the tests so we should not run into this problem with them in future Unicode upgrades. And with that, Rakudo on MoarVM has Unicode 8 support. Make the SIGN OF THE HORNS, and grab a HOTDOG.

### Improving error reporting

We work pretty hard to report the programmer’s mistakes in a good and understandable way. Of course, sometimes we fall short, and people file tickets to let us know. I’m keen to fix various of these; many of them are not that hard to fix, but can make quite a big difference to user experience. Here are the ones I’ve just recently fixed:

- Fix RT #125228 (bad error reporting when ‘is’ trait argument referenced undeclared symbol)
- Fix RT #125259 (bad error reporting when parameterizing a type in an illegal way)
- Fix RT #125427 (Rakudo silently accepted trying to overload special-compiler-form operators, which will never work)
- Fix RT #125339 (no location information for unhandled control exceptions)
- Fix RT #125441 (bad error reporting when trying to declare a class with the same name as an existing enum element)

### Parsing issues

For a while, there’s been a tricky issue in RT regarding parsing of parameters with both where clauses and defaults:

```` raku
sub bar($percent where { 1 <= $_ <= 100 } = 100) {
    ...
}
````

This did actually parse. Unfortunately, it parsed as something like:

```` raku
sub bar($percent where ({ 1 <= $_ <= 100 } = 100)) {
    ...
}
````

That is, trying to assign 100 to a block. This, of course, explodes when we try to evaluate the constraint. Clearly it was a precedence issue – but oddly, the precedence limit set on parsing the constraint matched what the standard grammar did exactly. I dug a bit deeper – and found a discrepancy in how we interpreted the precedence limit (exclusive vs. inclusive). That was a one line change – but fixing it caused quite a lot of fallout in the specification tests. In all, three or four separate issues had cropped up.

One of them was easy and rewarding: I removed a hack that was working around the precedence limit handling bug. That left the remaining ones, involving adverbs getting attached to the wrong bits of the AST and chained assignments parsing wrongly. Again, I looked for a place where we were out of line with the standard grammar – and failed. I couldn’t see how STD could come out with a different result than Rakudo was. Of course, since STD only parses, we could easily have not noticed it was broken. I didn’t have a build of STD to hand; thankfully, someone on channel did and could quickly paste me the ASTs it produced. And…they were wrong. So, I’d uncovered a bug in the standard grammar that had gone without being noticed for years. Anyway, I worked out some kind of solution, and left Larry to think up a neater one if possible. Since then he’s given me another suggestion, which I’ll try out. Anyway, the bug is gone.

The others were thankfully simpler. In one case, a program that ended in an invocant colon, for indirect object syntax, would report a syntax error; this was just a case of failing to look for end of source code as a valid thing to have after it.

Finally, I looked into some oddities around item and list precedence analysis for assignment. This one also ended up with me discovering a discrepancy with the standard grammar. However, even after fixing that, others found the rules still a little surprising. I looked deeper, and found a good way to explain the current semantics. Later, Larry read the discussion and committed a further tweak. So, we’re ahead of the standard grammar in another place now.

### Down in MoarVM

I spent some work doing various fixes down at the VM level. I jumped on a couple of segmentation faults (RT #125376), which I like to get on top of since they can, in the worst case, be security issues. I also reviewed a set of patches resulting from running the clang static analyzer over the codebase, and also looked through some tickets and pull requests.

The most significant work, however, was adding a “free at next safepoint” mechanism to the fixed size allocator. A common problem in concurrent systems, when you have memory not managed by the GC, is making sure that when you free it, no other thread can possibly be reading it. For things the garbage collector manages, this isn’t an issue; it already is considering every live reference to an object when it does GC no matter what thread has the reference. But in some places, we do want to employ concurrent algorithms, but not have the GC manage the memory. Generally, these are situations where we’re producing a new “version” of the data structure, putting it in place, and freeing the old one. It’s fine if another thread obtained the previous version and is looking at it – but that won’t end well if another thread frees it right away.

Thankfully, there’s an easy solution also inspired by how the GC works: add the memory to a list of things what we should free at the next “safe point”. A safe point is one where we know the state of each thread is such that it could not possibly still be in code looking at the memory in question. It turns out GC runs are natural safe points, so for now it just postpones the freeing until the next GC run. However, the API will let us consider some smarter option in the future if needed.

I immediately used this for the NFG synthetics table (a concurrent data structure that can safely be read from without ever taking a lock, and locking is only used to establish an ordering on additions). I’ll also use it to fix an issue with memory safety of dynamic arrays.

### Too many spectests for Windows

Recently, “make spectest” stopped working on Windows. I suspected somebody had done some kind of platform unaware change to the testing related bits – but a quick glance at the git log ruled out that hypothesis. Finally, I figured it out: on Windows, there is a 16-bit string length field on the process launch data structure, so you can’t send along a command line longer than 32KB. We were invoking the fudge tool with all of the spectests, and had reached the number of tests where we had too long a command line for Windows. Thankfully, I could get it to fudge in batches.

### Loads of other small fixes

I also chewed my way through a number of other tickets, and fixed up a few more things that I spotted along the way.

- Verify RT #125365 fixed and add test coverage
- Fix RT #109322 (bare blocks didn’t take a closure properly, causing reentrancy issues)
- Review and remove/update tests mentioned as needing review in RT #125016 and RT #125018
- Fix RT #125015, which complains about HOW(…) sub not existing
- Fix RT #113950 (optimizer could sometimes cause LEAVE phaser to not execute)
- Fix an issue where submethods with a role mixed in would not be considered submethods; add a test case
- Fix RT #125445 (.can and .^can broken on enum values)
- Fix RT #125402 (cannot assign non-Str to substr-rw; fixed by making it DWIM and coerce)
- Fix RT #125455 (variable phasers applied to variables directly in package/class bodies didn’t work properly)
