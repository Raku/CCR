# A Bunch of Rakudo News
    
*Originally published on [2013-01-10](https://6guts.wordpress.com/2013/01/10/a-bunch-of-rakudo-news/) by Jonathan Worthington.*

Seems it’s high time for some news here. It’s not that I didn’t do any blogging about Raku in December; it’s just that all of those posts were over on the [Raku advent calendar](https://raku-advent.blog/). Anyway, now it’s a new year, and I’m digging back into things after an enjoyable Christmas and New Year’s break in the UK with family and friends. Here’s a bunch of things that already happened but I didn’t get around to talking about here yet, and some things that will be coming up.

### Better Parse Errors In 2012.12

Ever had Rakudo tell you there’s a problem on line 1, when it’s really on line 50? Or wished that even in the common case where it gets the line right, it would tell you exactly where on the line things went wrong? Or how about the time it told you “Confused” because you got a closing paren too many?

Many of my contributions to the 2012.12 Rakudo release centered around improving its reporting of parse errors. STD, the standard Raku grammar, has had much better error reporting than Rakudo for a while. Therefore, I spent a bunch of time aligning our error reporting more closely with what STD does. Some of this is cosmetic: you get the colored output and the indication of the parse location. But while these cosmetic changes will be the most immediately visible thing, the changes go far deeper. Of note, a high water mark is kept so we can be a lot more accurate in reporting where things came unstuck, and we track what was expected so we can produce better errors. Just doing the cosmetic stuff without being able to give it a better location to report wouldn’t have helped so much. :-)

One other change is that we don’t bail out on the first thing that’s wrong when it’s possible to survive and continue parsing. When this is possible, up to 10 errors will be reported (since that’s typically a screen worth). Of course, some things just hose the parse and we can’t continue in any sensible way.

Hopefully, these improvements will make using Rakudo feel a lot nicer. Already on channel, I can feel the feedback we’re giving about parse errors when people use the evalbot is often a lot more pleasant and informative. Of course, there’ll be more improvements in the future too, but this is a big step forward.

### Faster Auto-Threading

The junction auto-threader could sometimes be insanely slow. As in, ridiculously so. After hearing a bunch of reports about this, I decided to dig in and work out why. A rewrite later, the little benchmark I was using with it ran almost 30 times faster. Not so bad… :-) This change also made it into the 2012.12 release.

### JVM Backend Preparations Underway

I’ve talked plenty about plans for NQP and Rakudo to run on things besides Parrot for a while now. Over the last year or two, we’ve laid a lot of the groundwork for this. What’s been especially pleasing is that it’s also made Rakudo a better quality Raku implementation on Parrot, thanks to the many architectural improvements. Of note, in many places we’ve closed semantic gaps between what Raku wants and the primitives we were building it out of; the new QAST (Q Abstract Syntax Tree) is a great example.

Anyway, with NQP now being written pretty much entirely in NQP, and many of the right abstractions in place, it felt like time to start slowly picking away at getting 6model ported to the JVM and work on turning QAST trees into Java bytecode. I quietly started on this in November, and mentioned the existence of the work on #raku in December. I was delighted to see *Coke*++ jump in and start working through the [Low Hanging Fruit](https://github.com/jnthn/nqp-jvm-prep/blob/master/docs/LHF.md) – a file where I’m putting tasks that should be relatively easy to pick off. I actually had to re-fill it, after the last round were depleted. ;-) By now, quite a few bits of QAST are supported and the 6model on JVM implementation is coming along nicely. Yes, this means it’s already capable of doing basic meta-programming stuff.

Note that this work isn’t at the stage where it’s of use for anything yet. You can’t even write a say(“hello world”) in NQP and have it run on the JVM yet, since all the work so far is just about turning QAST trees into JVM bytecode and building the runtime support it needs. That may seem like a curious way to work, but once you do enough compiler stuff you find yourself thinking quite naturally in trees. It meant I didn’t have to worry about creating some stripped-down NQP that could emit super-simple trees to be able to test really simple things. After all, the goal is to run NQP itself on the JVM, and then Rakudo, and only then will things be interesting to the everyday user.

To address a couple of immediate concerns that some may have…

- No, this is not a case of “stop running on Parrot, start running on JVM”. It’s adding an additional backend, much like *pmurias*++ has been working on adding a JavaScript backend for NQP. Of course, I expect resource allocation in the future to be driven by which backends users desire most. For some, the JVM is “that evil Oracle thing” and they don’t want to touch it. For others, the JVM is “the only thing our company will deploy on”. Thus I expect this work to matter more to some people than others. That’s fine.
- No, targeting multiple backends doesn’t mean performance-sucking abstractions everywhere. It’s a pretty typical thing for a compiler to do. As usual, it’s about picking the right abstractions. The debugger was implemented as an additional Rakudo frontend without a single addition to Rakudo or NQP or anything anywhere in the stack. That was possible because things were designed well. I’m sure the process of getting things running on the JVM will flag up a few places where things aren’t designed as well as they need to be, but already I’m seeing a lot of places where things are mapping over very nicely indeed.
- No, this doesn’t mean that all other Rakudo development will grind to a halt. I’ve been working on the JVM backend stuff in November and December; both months saw a huge amount of Rakudo progress too. Things will go on that way.

### Type System Improvements

Rakudo does a lot of things well when it comes to supporting the various kinds of types Raku offers, but there are some weak areas. Here are some of the things I plan to focus on:

- Getting the definedness constraint stuff working better (the `:D` and `:U` annotations). At the moment, they’re supported as a special case in multiple dispatch and the signature binder. In reality, they’re meant to be first class and work everywhere. You may not think you care about these much. Actually, you probably at least indirectly do, because once the optimizer is able to analyze them, it’ll be able to do a bunch more inlining of things than it can today. :-)
- Getting coercion types in place. Again, this is turning the special-cased “as” syntax into the much more general coercion type syntax (for example, `Int(Str)` is the type that accepts a `Str` and coerces it into an `Int`).
- Getting native types much better supported. At the moment, you can use them but…there are pitfalls. Having them available has been a huge win for us in the CORE setting, where we’ve used them in the built-ins. But they’re still a bit “handle with great care”. I want to change that.
- Implementing compact arrays.
- Improving our parametric type and type variable support. Many things work, but there are some fragile spots and some bugs that want some attention.

I intend to have some of these things in the January release, and a bunch more in the February one. We’ll see how I get along. :-)
