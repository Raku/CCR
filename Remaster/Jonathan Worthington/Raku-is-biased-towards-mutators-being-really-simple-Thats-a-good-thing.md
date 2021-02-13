# Raku is biased towards mutators being really simple. That’s a good thing.
    
*Originally published on [2016-11-25](https://6guts.wordpress.com/2016/11/25/perl-6-is-biased-towards-mutators-being-really-simple-thats-a-good-thing/) by Jonathan Worthington.*

I’ve been meaning to write this post for a couple of years, but somehow never quite got around to it. Today, the topic of mutator methods came up again on the #raku IRC channel, and – at long last – coincided with me having the spare time to write this post. Finally!

At the heart of the matter is a seemingly simple question: why does Raku not have something like the [C# property syntax](https://msdn.microsoft.com/en-us/library/x9fsa0sw.aspx) for writing complex setters? First of all, here are some answers that are either wrong or sub-optimal:

- “We didn’t get around to it yet” – actually, it’s a concious choice. We’ve had plenty of time to ponder it over the years, and compared with many of the other language features we’ve put in, it would have been a soft feature.
- “Just use a `Proxy`” – that is, a kind of container that gives you callbacks on `FETCH` and `STORE`. This is sometimes a reasonable answer, but not the right answer in most cases.
- “We’re leaving it to module space to wrap `Proxy` more nicely” – this supposes `Proxy` is already a good starting point, when a bunch of the time it is not.

### Back to OO basics

The reason the question doesn’t have a one-sentence answer is because it hinges on the nature of object orientation itself. Operationally, objects consist of:

- A bunch of state (known as attributes in Raku, and fields in Java/C#)
- A mechanism for sending a message (consisting of a name and arguments) to an object, and having the object act upon it

If your eyes glazed over on the second bullet point, then I’m glad you’re reading. If I wasn’t trying to make a point, I’d have simply written “a mechanism for calling a method on an object”. So what *is* my point? Here’s a quote from Alan Kay, who coined the term “object oriented”:

> I’m sorry that I long ago coined the term “objects” for this topic because it gets many people to focus on the lesser idea. The big idea is “messaging”…”

For years, I designed OO systems primarily thinking about what objects I’d have. In class-based languages, this really meant what classes I’d have. How did I figure that out? Well, by thinking about what fields go in which objects. Last of all, I’d write the methods.

Funnily enough, this looks very much like procedural design. How do I build a C program? By modeling the state into various structs, and then writing functions work with with those structs. Seen this way, OO looks a lot like procedural. Furthermore, since OO is often taught as “the next step up” after procedural styles of programming, this way of thinking about objects is extremely widespread.

It’s little surprise, then, that a lot of OO code in the wild might as well have been procedural code in the first place. Many so-called OO codebases are full of DTOs (“Data Transfer Objects”), which are just bundles of state. These are passed to classes with names like `DogManager`. And a manager is? Something that meddles with stuff – in this case, probably the `Dog` DTO.

### Messaging thinking

This is a far cry from how OO was originally conceived: autonomous objects, with their own inner state, reacting to messages received from the outside world, and sending messages to other objects. This thinking can be found today. Of note, it’s alive and well in the actor model. These days, when people ask me how to get better at OO, one of my suggestions is that they take a look at actors.

Since I grasped that the *messages* are the important thing in OO, however, the way I design objects has changed dramatically. The first question I ask is: what are the behaviors? This in turn tells me what messages will be sent. I then consider the invariants – that is, rules that the behaviors must adhere to. Finally, by grouping invariants by the state they care about, I can identify the objects that will be involved, and thus classes. In this approach, *the methods come first, and the state comes last*, usually discovered as I TDD my way through implementing the methods.

### Accessors should carry a health warning

An accessor method is a means to access, or mutate, the state held within a particular attribute of an object. This is something I believe we should do far more hesitantly than is common. Objects are intended to hide state behind a set of interesting operations. The moment the underlying state model is revealed to the outside world, our ability to refactor is diminished. The world outside of our object couples to that view of it, and it becomes far too tempting to put operations that belong inside of the object on the outside. Note that a get-accessor is a unidirectional coupling, while a mutate-accessor implies a bidirectional (and so tighter) coupling.

But it’s not just refactoring that suffers. Mutable state is one of the things that makes programs difficult to understand and reason about. Functional programming suggests abstinence. OO suggests you just stick to a pint or two, so your side-effects will be at least somewhat less obnoxious. It does this by having objects present a nice message-y view to the outside world, and keeping mutation of state locked up inside of objects. Ideas such as value objects and immutable objects take things a step further. These have objects build new objects that incorporate changes, as opposed to mutating objects in place. Raku encourages these in various ways (notice how `clone` lets you tweak data in the resulting object, for example).

Furthermore, Raku supports concurrent and parallel programming. Value objects and immutable objects are a great fit for that. But what about objects that have to mutate their state? This is where state leakage will really, really, end up hurting. Using `OO::Monitors` or `OO::Actors`, turning an existing class into a monitor (method calls are synchronous but enforce mutual exclusion) or an actor (method calls are asynchronous and performed one at a time on a given object) is – in theory – easy. It’s only that easy, however, if the object does not leak its state, and if all complex operations on the object are expressed as a single method. Contrast:

```` raku
unless $seat.passenger {
    $seat.passenger = $passenger;
}
````

With:

```` raku
$seat.assign-to($passenger);
````

Where the method does:

```` raku
method assign-to($passenger) {
    die "Seat already taken!" if $!passenger;
    $!passenger = $passenger;
}
````

Making the class of which `$seat` is an instance into a `monitor` won’t do a jot of good in the accessor/mutator case; there’s still a gaping data race. With the second approach, we’d be safe.

### So if mutate accessors are so bad, why does Raku have them at all?

To me, the best use of `is rw` on attribute accessors is for *procedural* programming. They make it easy to create mutable record types. I’d also like to be absolutely clear that *there’s no shame in procedural programming*. Good OO design is hard. There’s a reason Raku has `sub` and `method`, rather than calling everything a `method` and then coining the term `static method`, because subroutine sounds procedural and “that was the past”. It’s OK to write procedural code. I’d choose to deal with well organized procedural code over sort-of-but-not-really-OO code any day. OO badly used tends to put the moving parts further from each other, rather than encapsulating them.

Put another way, `class` is there to serve more than one purpose. As in many languages, it doubles up as the thing used for doing real OO programming, and a way to define a record type.

### So what to do instead of a fancy mutator?

Write methods for semantically interesting operations that just happen to set an attribute among their various other side-effects. Give the methods appropriate and informative names so the consumer of the class knows what they will do. And *please* do not try to hide complex operations, potentially with side-effects like I/O, behind something that looks like an assignment. This:

```` raku
$analyzer.file = 'foo.csv';
````

Will lead most readers of the code to think they’re simply setting a property. The `=` is the *assignment* operator. In Raku, we make `+` always mean numeric addition, and pick `~` to always mean string concatenation. It’s a language design principle that operators should have predictable semantics, because in a dynamic language you don’t statically know the types of the operands. This kind of predictability is valuable. In a sense, languages that make it easy to provide custom mutator behavior are essentially making it easy to overload the assignment operator with additional behaviors. (And no, I’m not saying that’s always wrong, simply that it’s inconsistent with how we view operators in Raku.)

By the way, this is also the reason Raku allows definition of custom operators. It’s not because we thought building a mutable parser would be fun (I mean, it was, but in a pretty masochistic way). It’s to discourage operators from being overloaded with unrelated and surprising meanings.

### And when to use Proxy?

When you really do just want more control over something that behaves like an assignment. A language binding for a C library that has a bunch of `get`/`set` functions to work with various members of a struct would be a good example.

### In summary…

Language design is difficult, and involves making all manner of choices where there is no universally right or wrong answer, but just trade-offs. The aim is to make choices that form a consistent whole – which is far, far, easier said than done because there’s usually a dozen different ways to be consistent too. The choice to dehuffmanize (that is, make longer) the writing of complex mutators is because it:

- Helps keep `=` predictably assignment-like, just as all other operators are expected to have consistent semantics
- Helps mark out the distinction between procedural and object oriented design, by introducing some friction when the paradigms are confused
- Discourages object designs that will lead to logic leaks, feature envy, violation of the “tell, don’t ask” principle, and probably a bunch of other OO buzzwords I’m too tired to remember at 2am
- Helps encourage OO designs that will be far more easily refactorable into concurrent objects
