# Rakudo on 6model gets underway!
    
*Originally published on [2011-05-09](https://6guts.wordpress.com/2011/05/10/rakudo-on-6model-gets-underway/) by Jonathan Worthington.*

Recently I finished up the long-running compile time meta-object branch in NQP, and got the final installation issues sorted out (there were issues having it and nqp-rx installed, which are now resolved). Many thanks go to *moritz*++ for various contributions to NQP over the recent month’s development, and to others for testing and feedback. This doesn’t mean I don’t intend to do much more with NQP – I do, and I’ll return to it in a month or two. However, now Rakudo is taking center stage.

So far, I’ve mostly just broken everything and then started putting it back together again. :-) At this point, anyone who was around when we did the alpha => ng transition (the last big Rakudo internals upgrade) will probably be thinking, “oh no, not again!” While this is a serious upgrade in some ways, it is also one that is somewhat less user facing. Yes, there will be fallout. But…

- The grammar is largely staying the same in terms of what it parses; we started over with that in the alpha => ng transition.
- The list implementation is largely staying the same – at least, semantically. Various details of how the implementation is factored will inevitably change, but in terms of semantics it shouldn’t be a user-facing change.
- A lot of the setting is written in Raku, and so won’t be greatly affected in the process.
- The meta-object API will be implemented totally differently underneath, but many aspects of the API will remain the same.

Some things will change drastically:

- Most immediately user facing, multiple dispatch is being massively overhauled to bring it in line with the latest specification. Much of the design work for that has been done already in NQP implementation of it. You may actually not notice the fallout from this in many cases, apart from if you were using proto subs or proto methods, in which case you’re in for some changes. Thankfully, this is relatively unusual. Multi-method semantics will also be different, but the amount of code affected in actuality will probably be relatively small.
- Separate compilation is another big deal, but most cases I’ve hit so far boil down to “add a missing use statement”.
- Many things that the compiler used to generate code to build or do will actually be built or done by the compiler at compile time. This includes meta-objects, code objects, constants and packages. Traits will be called during compile time. This is a massive advance that will allow us to implement a wide range of optimizations (v-table method calls, offset-based attribute access, compile-time multi selection, sub inlining) and do a bunch of static analysis. It only really affects you if you’re writing traits (unlikely) or meta-objects (so nobody yet).
- Package handling is changing a lot, but mostly this will just enable things that never worked before. It’ll be a bit stricter in some ways too. That bit me somewhat in NQP, but Rakudo has already been stricter than NQP, so again it’s probably not a big issue.

So, drastic under-the-hood changes that will deal with some long-standing issues and enable better code analysis and – critically – optimizations, as well as our building blocks being a bunch more optimal both in terms of runtime and memory. But I’m aiming to keep regressions low.

Nice goals, but what’s actually done so far? One big change is to the build procedure. Previously we did this:

1. Compile various bits (grammar, actions, other bits of the compiler) down to PIR.
1. Bundle those along with some PIR-based built-ins into a “stage 1” compiler.
1. Use the stage 1 compiler to compile the setting to PIR.
1. Re-build what we did in step 2 but with the setting included this time.
1. Bundle it all into a single raku executable.

Now the process is as follows:

1. Build the various bits of the compiler (grammar, actions, symbol table handling, module loader, other such bits) into various bytecode files (via PIR). These are all written in NQP and handled by the NQP compiler. At most, there may be some embedded blocks of PIR here and there, but they’re rare and on the chopping block.
1. Compile a rather small raku.p6 file, which is NQP, into the raku executable (via PIR and PBC). It has “use” statements that load the various other bits (which are pre-compiled to bytecode). End result: the Raku executable is just a little frontend, without any setting or meta-objects in there.
1. Compile the meta-objects library. This is written in NQP.
1. Compile the setting, written in Raku, using the raku executable with –setting=NULL. It gets compiled into CORE.setting.pbc, which is what the raku executable goes looking for if you don’t use –setting=… to tell it you want otherwise. The first thing it does is “use Perl6::Metamodel”, to pull in the meta-objects.

And that’s it. No re-building the Raku executable just for a change in the setting. Another result of this is that we can probably make it so Raku programs compiled to bytecode will just load the setting, and it will only load the compiler if you actually need it (that is, if you do an eval). So, more efficient for development, more modular and more what you’d expect a Perl program to look like (that is, no magic PIR-driven bundling of stuff together, but instead use statements).

Symbol handling is being extensively refactored at the moment. I’m a lot of the way with that because it’s largely copy-paste-twiddle from NQP. Many of the meta-objects are fleshed out. Using custom meta-objects for built-in package declarators are supported, for the most part because there’s no built-in defaults any more (Perl6::Metamodel supplies a mapping, and the default setting just imports it). I’ve started on the bootstrap of the class hierarchy. I’ve got meta-objects being created and composed at compile time, but there’s no way to add attributes/methods yet. I’ve got initial native type bits in so we can do natively typed attributes (really soon) and other bits (later). You can’t actually *do* anything with it just yet, but things so far have come together fast.

The next big steps will be getting the new multiple dispatch in place, along with refactors to code objects. After that it’ll be trait handlers, methods and attributes. I suspect I’ll need a bit of scalar container refactoring along the way too.

After that, it’ll largely be “just” a process of gradually bringing the setting back into being, and writing meta-objects for stuff like roles, subsets, enumerations and so forth. No small task, but I think things will go much faster once I get to the point where it’s easy for people to jump in and help.

More soon – though I’ll soon also have the nice distraction of YAPC::Russia and then several days vacation after it. :-)
