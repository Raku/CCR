# Slides, and a few words on representation polymorphism
    
*Originally published on [2010-10-15](https://6guts.wordpress.com/2010/10/15/slides-and-a-few-words-on-representation-polymorphism/) by Jonathan Worthington.*

Last weekend I was at OSDC.fr. Amongst the nice food, free Hoegaarden (thanks GitHub!) and meeting people, I gave a couple of talks. One was the tried and tested [Raku Signatures](http://www.jnthn.net/papers/2010-osdc.fr-signatures.pdf) talk, which was well received. The second was new, and mostly about 6model.

The [slides from the 6model talk](http://www.jnthn.net/papers/2010-osdc.fr-rakudo.pdf) stand alone quite well in most places, and are perhaps the best overview you can get of 6model so far. However I want to take a moment to elaborate on a couple of them, because while they were good enough visual aids for what I was saying, they don’t quite tell the whole story. I’d also like to fill out some details I skipped over.

I talked a bit about the concept of representation polymorphism. I gave the example of a class representing color information:

```` raku
class Color::RGB is repr(*) {
    has uint8 $.red;
    has uint8 $.green;
    has uint8 $.blue;
}
````

This is a case where your use case for the class may motivate alternative approaches to storing the data. If you’re going to store hundreds of thousands of these in an array of some kind, you’ll probably wish for a bit-packed representation in order to minimize memory consumption. On the other hand, you may be passing it outside of your program to a C library and want it to match the memory layout of a C struct so the cost of marshaling is low.

The ability to use a single class definition with different memory layouts is called representation polymorphism. It’s something that’s in the Raku spec (see S12). It’s also something I chose to ignore in he earlier days of Rakudo – there were so many more important things to focus on in order to build an interesting subset of Raku for folks to play with. Now we have that, though, and I’m seeking to design a model that will give us all we need to get to 6.0.

So how does 6model handle this? I took all of the various things you may want to do involving an object, and divided them up into two camps: those things that are tied to the representation, and those that aren’t. From there, I derived two APIs: a REPR API (which contains all the things that relate to in-memory representation) and a HOW API (all other aspects of the higher order workings of an object). The REPR API cares about:

- Object allocation/deallocation
- Attribute storage/lookup
- Boxing/unboxing to native types (note, this is not about coercion – for it to work, you have to have something that can unbox to that type)
- Whether the object likes to be referenced or behave value-ish (for example, if we allocate an array of them, should it be an array of references or an array of bits of space for the object)
- GC interaction, where needed

Everything else is in the `HOW` API. That includes the obvious things, like declaration, method dispatch and introspection. It’s worth mentioning that `add_attribute` (the thing we call when we spot an attribute declaration in a package declaration) is in the `HOW` API, not the `REPR` API. This is because possession of an attribute is decoupled from storage strategy for it (getting the separation of concerns for attribute-y bits right is key to getting representation polymorphism right).

Therefore, each object has a couple of things that define its semantics: something that implements the `HOW` API and something that implements the `REPR` API. For various other reasons, we also want to independently reference the type object and keep a v-table pointer around outside of the meta-object (there’s a couple of design decisions that need their own blog posts here – bear with me).

We’d really like objects to be fairly lightweight, however. And since for most classes there will only ever be one REPR that they use, having pointers to both in every single object is rather wasteful – not to mention the extra stuff I mentioned wanting to have to hand. So, where do we stick it?

As the *David Wheeler* quote goes, “any problem in computer science can be solved with another level of indirection”. So I added one: an object points to a “shared table”, known from here-on-in as an S-Table. We have one S-Table per (`HOW`,`REPR`) pair that is in use. S-Tables are not objects, they’re just a little glue between others.  (The less often quoted follow-up line to the Wheeler quote is, “but that usually will create another problem”. In this case, we’re just making a trade-off: a pointer dereference for saving memory – but read on for why that may not matter too much).

Armed with this, you can now understand the diagram on slide 82. I’d just like to add one clarifying note – the meta-object (implementing the HOW API – top right) is just a plain old object. It doesn’t have a special memory layout that is a set of method pointers; it too just references an S-Table and its memory layout is controlled by some REPR. I did the diagram that way because I wanted to emphasize the methods that object supported, and later realized that it could be confusing – sorry.

Finally, I’d like to throw out a couple of thoughts on the REPRs, just as bullet points rather than in full detail.

- In my current design, REPRs are not first class objects. In fact, how they look is one of the things I define as specific to a given compiler backend. Some people may disagree with this choice, and I’m fully open to disagreeing with myself over it at some point in the future too. :-) The motivation is that how we go about allocating storage, GC interaction, indexing into memory to get attributes, etc will differ somewhat between backends, and so we’d have a hard time sharing them anyway. Even if we could introduce an abstraction layer, we’d be doing so on a critical path from a performance perspective. Also, while I see a lot of potential use cases for custom implementations (or derivations of implementations) of the `HOW` API – which is implemented by first class objects – I see far fewer use cases for doing similar in REPR-space. Also, I don’t think that I’m boxing myself in by not making them first class; it’s easier to expose something in the future than it is to try and stuff an exposed genie back into his lamp. So cost/benefit tells me that – for the time being – REPRs stay low-level and gutsy.
- In the case of a fully statically typed language, you may also happen to statically know the representation of an object (this, of course, depends on how your type system is designed). There are cases in Raku where we can do this, though it likely depends on closing/sealing classes being enabled. In these cases, since the REPR in use can be statically known, the various “methods” it implements are available for inlining (I use the word in quotes because they’re not really methods in the first-class sense under the current design). I’ve not worked this all through yet but I expect that it’s possible to use this model and still get attribute accesses optimizable to the same thing you’d get them down to in a typical JVM or CLR implementation, in the case where you statically have all the information to know its safe to do so. Put another way, the design lends itself to providing representation polymorphism when needed but in a way that can be largely optimized away for languages that don’t care.
