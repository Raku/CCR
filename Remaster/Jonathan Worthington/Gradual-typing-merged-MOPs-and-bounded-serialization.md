# Gradual typing, merged MOPs and bounded serialization
    
*Originally published on [2010-09-20](https://6guts.wordpress.com/2010/09/20/gradual-typing-merged-mops-and-bounded-serialization/) by Jonathan Worthington.*

I know that, as well as wanting a faster, more complete Rakudo, many people watching my work on Raku are keen to understand and learn about the areas that I’m currently hacking on. Therefore, during my current grant, I’m going to write a various blog posts to try and explain what a lot of the terminology I throw around really means. This is the first of them, and I’m going to start by talking about three topics which are very closely connected to each other, even if they may not seem so at first. Namely, they are:

- Gradual typing
- Merging compile-time and runtime meta-object protocols
- Bounded serialization and linkage

### Gradual Typing

Raku is neither statically nor dynamically typed, rather it is gradually typed. For example, consider the following program:

```` raku
sub get_cat_from_rescue_center($type, $owner) {
    my Cat $rescued = cat_search($type);
    $rescued.owner = $owner;
    return $rescued;
}
my $kitteh = get_cat_from_rescue_center('tabby', 'Anna');
````

Putting aside any type inference that we may be able to do in the future, what do we actually know about the types of the variables in this program?

- `$type` and `$owner` must be of type `Any` or a narrower type, because that is the default type of parameters. If they were not, we couldn’t have called the sub.
- `$rescued` must be of type `Cat` or a narrower type, because it is declared as such. Were it not, the assignment would fail.
- `$kitteh` does not have a declared type and a scalar can hold anything, including junctions. Thus the most we can say is that it’s the top type, `Mu`, or narrower.

So is this information of any use if we want to make our programs run faster? The answer is a resounding “yes”. For any given concrete type, which may have some parents, we can – at compile time – compute a v-table. A v-table is simply an array of code objects. Along with that, we make a mapping of method names to slots. Now, when we compile a method call on an object, if we know its type and its slot mapping, we can look up the method in this mapping and emit a call based on an array index lookup.

“Well,” you may be thinking, “that’s all very well for the programs where I declare types, but I never do that, so I win nothing, right?” Wrong. Take a look at the methods in `Mu` and `Any`, for example. Methods like new, `ACCEPTS`, `Str`, `grep`, `map`, `list` – in other words, methods that are either called a lot for you when you use various Raku features, or that you will often use yourself. You will get a win every time you call `.new` to create a new instance of an object, every time you do a smart-match, etc.

Of course, you can get further wins by providing more type information. And, of course, the various internal bits of Raku – which we implement in Raku and NQP – can benefit from gradual typing too. In general, the rule is “the more type information you provide, the more information you give to the compiler in order to generate better code and maybe catch errors”.

This is, of the three things I mentioned at the start of this post, the “goal”. So now let’s look at how to make it happen.

### Merging compile-time and runtime meta-object protocols

What is a class? What is a role? What is a grammar? In Raku, these things don’t just magically have the semantics that we associate with them. Instead, they all have associated meta-types that define what they mean. These tend to be named, by convention, with “HOW”, short for “Higher Order Workings” but also nicely mnemonic: “Just HOW the heck does this type of thingy work?” When a class, or a role, or a grammar is created, we grab the appropriate meta-object and then call a sequence of methods on it to define the package. Let’s look at a quick example.

```` raku
class Band {
    has $!name;
    has $!genre;
    method `describe` {
        say "$!name play $!genre music";
    }
}
````

When we see a declaration like this, it really boils down to to something along the lines of:

```` raku
::Band := ClassHOW.`new_type`;
Band.^add_attribute(Attribute.new(name => '$!name'));
Band.^add_attribute(Attribute.new(name => '$!genre'));
Band.^add_method('describe', method () { ... });
Band.^`compose`;
````

Here, `ClassHOW` is the meta-object that describes how default Raku classes work. The set of methods that we can call on this object – or an instance of it, since `ClassHOW` is really a type object – is called a meta-object protocol. Put another way, the meta-object protocol (from now on, I’m just going to say MOP) is just the API that our meta-objects all implement. You add a method to a role, or a grammar, or a class, or whatever else, by calling an add_method method and passing along a name and an object representing the code.

The interesting question is when we do all of these method calls. Today in Rakudo we:

- Generate code to make them at runtime
- Keep all of the information needed to do so in a separate compile-time object (in fact, generating the code is handled by this object too)

Essentially, this means we have two MOPs – one used at compile time and one used at runtime. Representing types differently at runtime and compile time is not unusual in compilers, not least because many do type erasure as part of the compilation process. It’s served us reasonably well so far in Rakudo too. However, it has some disadvantages. Of note:

- It means that people who want to write their own meta-objects also need to write compile-time MOP implementations in order to get the power that the built-in ones do.
- It repeats a lot of work at compile time and runtime. This is going to get worse, too. For example, to generate better code as part of gradual typing, we need to compute a v-table. We need this table at compile time and we need it at runtime. So we’d need to build it twice, or find some way to persist it between the phases. We’d also need duplicate infrastructure for doing compile-time and runtime type checks. As another example, today we don’t really detect role composition conflicts at `BEGIN` or `CHECK` time, but rather at `INIT` time because there’s not an implementation of the composition algorithm in the compile time MOP. The list goes on.
- Going with the duplicated work is also duplicated code, of course
- If there’s two different versions of the same(ish) information, it’s easy to get it out sync, leading to subtle bugs

Thus for both performance reasons (duplicated work is bad) and the fact that we’re at the point where we do want to implement optimizations and more compile-time checks (which means more duplicated information), I think it’s important that we drop having separate MOPs at compile time and runtime, and instead have one unified MOP.

This means that when we parse the opening curly of your class declaration, we really do at that point create the very same type object and meta-object that will exist at runtime. We really do a trait dispatch to `trait_mod:<is>` at compile time to add the parent class – the type-object for which we’ll already have to hand. We really do call add_method on the meta-object after parsing and making the AST for a method (though it’ll be passed a code object that still needs to be filled in with the compiled code later on – we can’t actually invoke the method until runtime). And at the closing curly of the type, we really do call the compose method on the meta-object (conjectural: we may actually need to defer this until `CHECK` time, when we’ve parsed and made AST for the whole compilation unit; the point is that it’s somewhere at compile time).

So if it’s so wonderful, why wasn’t it done like this in the first place? Of the various reasons, the biggest is that it requires a significant change to the overall compilation architecture, and the implementation of something that we’re completely missing today.  Put another way, we couldn’t have done this before without it severely impacting other goals that, at the time, were more important in getting Rakudo to be useful and usable. So what’s the secret sauce?

### Bounded serialization and linkage

If objects are going to survive between compile time and runtime, in a situation where we can actually compile code and save the stored code somewhere, we’re going to need to be able to serialize them (or, in other terms, freeze them) and then later deserialize them (also known as thawing).

The difficult problem here is not so much serializing an individual object. It’s that we need to bound that serialization to things in the current compilation unit, and be able to reference objects that have come from other compilation units. For example, a meta-object for class `Lolcat` may need to refer to the type-object of its parent class `Cat` and a role `Lol`, which may both be from different (perhaps pre-compiled) modules.

Developing this kind of thing is non-trivial, and it doesn’t exist today in Parrot. However, I think at this point, having this kind of support is essential to the future of Rakudo. Thus, it’s going to be something I’ll dig into seriously in a week or two. There’s a lot of questions about how to achieve it, and various decisions I’ll have to take.

### To write anew or to beat into shape?

One notable question is whether I try and upgrade Parrot’s freeze/thaw support to support this, or if I just build something from scratch, as I am with the rest of the object model implementation. There are advantages either way, and of course disadvantages.

If I try to build on the existing Parrot implementation of freeze/thaw, I make this functionality trivially available to other language developers on Parrot. I also have part of what’s needed already in place, however the bounding and linkage bit (e.g. the hard part) is missing. Of note, it works for Parrot’s hash and array PMCs, which I am using, so I guess I save a little work there, but I’d still need to implement the serialization of the Raku objects. A downside is that I’m not too optimistic about the freeze/thaw subsystem being in great shape, so I may have my work cut out for me to extend it (e.g. it will possibly need some refactoring first). I will have to change the bytecode format to support this, I will have to make various other changes, and I may well run into the Parrot deprecation policy. The deprecation policy is a well-intentioned attempt to create stability for language developers, but the upshot is that it sometimes prevents needed changes and improvements. The situation if that did happen for this work could be icky.

If I build something from scratch, then I have the freedom to make it look how I want, and don’t have to worry about refactoring an existing code base nor the deprecation policy. I can make it look similar to an implementation of the same thing on other backends, which would mean I could prototype it first in 6model if I wanted to and then easily port it, just as I have been doing with the rest of the object model implementation. However, it would not fit in so neatly with the rest of Parrot, particularly objects from other languages that made it into the object graph and needed serializing. That is, unless they decided to build on top of the same object support in nqp-rx that Rakudo will – not an unrealistic option, since I expect the meta-model implementation I’m working on will make it easier to implement object systems as other languages want them than the current Parrot OO support does. Not to mention that the same model will become available on other backends in the future.

At the moment I could go either way on this; I suspect the first step will be taking a deeper look at what the current state of Parrot’s freeze/thaw subsystem is, and perhaps doing a first cut of it in 6model (because it’ll be informative whichever way I go).

Anyways, I hope this post has been informative, and helped you get a better grasp of the three areas I’ve covered. I’ll be writing on more topics – including expanding on some things I’ve referred to in this post – but feel free to suggest topics in my grant work that you’d particularly like me to elaborate on by leaving a comment. In the meantime, it’s on with the hacking (and there’ll be a status report at some milestone point in the next week or two, all being well).
