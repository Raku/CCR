# Bounded serialization, better regexes and better errors
    
*Originally published on [2012-02-10](https://6guts.wordpress.com/2012/02/10/bounded-serialization-better-regexes-and-better-errors/) by Jonathan Worthington.*

Here’s a quick roundup of some of the things that have been going on in Rakudo since the January release.

### Bounded Serialization

This is where I’ve been focusing the majority of my efforts. At the moment, when we pre-compile Raku code – such as the CORE setting with all the built-ins – we also build up a bunch of code that reconstructs the various objects that are made as a result of compile time declarations. This is done by recording an “event” for each thing that happens at compile time, then replaying them when the module/setting is loaded.

We’ve done things this way throughout every generation of Rakudo to date, but as I worked on the “nom” development branch and 6model, I built things so that we could later switch over to a different model; one where all of the objects created as a result of compile-time declarations are serialized. Then, when we need to load the module, we deserialize this blob of data back into the required objects, rather than doing all of the method calls and data shuffling to build them up again.

I’ve been working on this since we got the last release out. So far I’ve got the serialization and deserialization engine to a reasonably capable state; it can happily handle references between compilation units, has no problems with circular references between objects, and today I got basic support for serializing closures in place also. At this point, I’ve just got it being exercised by a bunch of tests; the next step will be to integrate it into NQP’s compilation process. I’m hoping I can get through that at the weekend, and after that it’ll be time to try and get Rakudo using it. Whether I get this landed for the February release or if we have to wait until the March one, I’m not yet sure. I know for sure I don’t want a half-baked version of it going out, so I’ll hold it for the March release if I can’t get it working as reliably as I want for the February one.

Why am I working on this? Here’s some of the things that I’m aiming at as a result of this work.

- Improved startup time (the deserialization should be less work than rebuilding everything up from scratch)
- Reduced memory during pre-compilation of modules. Most notably, I’m hoping to make a notable reduction in the memory (and time) required to build CORE.setting, which will most certainly be welcomed by anyone trying to build in a lower memory environment. The faster build will also be helpful for Rakudo developers, and enable us to be more productive.
- The restrictions on the “constant” declarator can be lifted, enabling use of non-literal values.
- Phasers as r-values can be implemented.
- We can implement constant folding much, much more easily, as well as build other immutables at compile time.
- Other nice things, no doubt. :-)

Completing this will also be one prerequisite down for much better inlining optimization support.

### More Regex Bits

We now support the use of <x> in a regex to also call any predeclared lexical regex “x”. The <Foo::Bar::baz> syntax for calling a rule from another grammar is also now supported. A nasty bug that caused <!> not to work has been fixed. Finally, <prior> – which matches the same string that the last successful match did – is now implemented.

### Better Errors and Exceptions

*moritz*++ has continued this typed exception work. We’ve also been improving various bits of error reporting to be more informative, and catching a few more things at compile time. *moritz*++ has also ported STD’s `$*HAS_SELF` handling, which gives us better handling of knowing when operations needing an invocant can take place. We currently have this work in a branch (it depends on some other work I was doing to align us with changes to how STD parses initializers, and there’s one last bug that prevents us merging it just yet; it’ll be sorted out in the coming days, I’m sure).

### Pod Bits

*tadzik*++ dropped by with a couple of patches, one a bug fix, the other pretty cute: it makes the auto-generated usage message for `MAIN` subs include the declarator documentation.

### Other

Thanks to *moritz*++, we now support copy and rename functions. There’s also been the usual range of bug fixes that we get into every release, steadily chipping away at making Rakudo better.
