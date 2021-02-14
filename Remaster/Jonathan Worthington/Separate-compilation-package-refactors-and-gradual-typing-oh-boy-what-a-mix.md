# Separate compilation, package refactors and gradual typing: oh boy, what a mix!
    
*Originally published on [2011-04-25](https://6guts.wordpress.com/2011/04/25/separate-compilation-package-refactors-and-gradual-typing-oh-boy-what-a-mix/) by Jonathan Worthington.*

First of all, I’m sorry that it’s been so long since I posted here. I’m happy to say that my NQP and Raku involvement has been much higher than my post rate here. In fact, I managed to make it to the ever-wonderful Netherlands Perl Workshop and, excitingly, also made my first visit to OSDC.TW. I gave a few talks, of course; if you like the things I post here, they’ll probably be of interest.

- **[Rakud’oh: Making Our Compiler Smarter](http://www.jnthn.net/papers/2011-nlpw-rakudo.pdf)** covered many of the current things my work is focusing on – essentially, work to make Rakudo a faster and more helpful Raku implementation
- **[Implementing Classes in 15 Minutes](http://www.jnthn.net/papers/2011-nlpw-classes.pdf)** is a crash-course on how to write a meta-object
- **[Inside A Compiler](http://www.jnthn.net/papers/2011-osdc.tw-compiler.pdf)** walks you through building a compiler using NQP and PCT. It touched on 6model too, as well as my goals for the future of these tools. I also published the [code from the talk](http://www.jnthn.net/papers/2011-osdc.tw-compiler-code.zip).

I also enjoyed a hackathon arranged my *mberends*++ after the NLPW. It was wonderful to meet *tadzik* for the first time, and *masak* came along also. And yes, there was beer. Good beer. :-)

So, what have I been hacking on? Last time I wrote here, I was digging into a set of thorny issues surrounding gradual typing, and grappling with the relationship between compile time and runtime. As I did so, a few other things came into the picture. It turns out that the issues I mentioned with regard to compilation unit purity were only scratching the surface. Following things along further, I realized that I was going to have to deal with the issue of separate compilation, and that this would require the package refactor that I’d once hoped could be done independently of the metamodel one.

Let me unpack these a little bit. The notion of separate compilation is that every time you start compiling a module, it gets a “clean slate”. No matter what other things the code that is loading the module has done – be it grammar tweaks or loading other modules – the module we’re compiling now should be isolated from it. This is critical if we intend to pre-compile modules. Obviously, this means that you kind of need to have parallel realities: the module’s view of `GLOBAL` is decidedly not going to contain whatever happens to be in `GLOBAL` by whatever does the `use` statement to load the module. Of course, they must be reconciled at some point, but not until that module’s compilation is completed.

In some languages, this may be relatively easy. For example, if you have completely distinct compile time and runtime phases and no custom meta-programming capabilities that the compiler may need to interact with, then you can maintain a symbol table in the compiler, do your code generation and be done. This is basically where Rakudo – and NQP – started out. We’ve come a long way with that approach, but getting to the next level needs a different approach.

To date, in NQP and Rakudo we’ve only had the capability to have one runtime reality. When I came to start bringing compile time and runtime into a much closer relationship, I quickly discovered that this was going to be deeply problematic. In fact, in NQP I had the acid test for these issues: a bootstrapping compiler. When a program is compiling itself, then there is *100% overlap* between the symbols in the running program, and the program we’re compiling. Recall that the compilation may need to do a bit of runtime too; whenever you load a module, that module’s mainline is executed, for example. And if we’re going to be dealing with meta-object construction at compile time, then we’re actually going to have the compiler running code that’s part of the program that it is compiling. This doesn’t even factor in things Rakudo has to deal with that NQP does not, such as `BEGIN` blocks.

So, I’ve spent much of the time since I last wrote here working on these issues. Since this involved re-working packages, I’ve also dealt with a lot of the issues there. We can now have support for lexically scoped packages, for example.

```` raku
my module Secret {
    our class Beer {
        method drink { say("mmm...pivo!") }
    }
}
Secret::Beer.drink;
````

Here, the class `Beer` is decidedly installed in the package `Secret`, but the `Secret` package it is installed into is lexical. This means that while we can see that package inside the current lexical scope (say, the main lexical scope of our module), that package will not be visible outside of the module at all – unless you explicitly export it.

This is just one small example of things that were once scary hard features to try and implement, but are now relatively straightforward. I’ve also done a bunch of work on the concept of static lexpads, so we can get a bunch more symbol installation stuff correct.  This will also make things that were once hard much easier to support.

The really critical thing, however, is that the notion of separate compilation is now strongly supported. NQP can bootstrap itself, and it knows the difference between the HLL.pm it’s loaded and is currently running and the HLL.pm that it’s currently compiling. It also locates its current meta-object set via the lexical setting, importing them from it, so we get the correct incarnations of the meta-objects too, and can start making instances of them during the compile. In fact, a bunch of meta-object operations are now switched to being invoked at compile-time, and the rest will be coming along soon.

What does this mean? It means that the door is open to a whole bunch more compile-time cleverness. It means the compiler will work with the real meta-object, not just some simulation of it that it builds to try and catch some errors.  Oh, and I realized that it also means that I’ve opened the door to writing your own custom class meta-object in a module and then – on using that module – have it replace what the class keyword means by default.

Overall, this has been a more challenging piece of work than I had expected to face, but coming out of it, it feels like it’s been decidedly worth it. I’m aware that it looks like I’m spending a lot of time in NQP land and one might wonder how long it’ll take to get Rakudo using all of this stuff. Really, the bulk of the time has gone on solving hard problems and building solutions that will directly apply to Rakudo. All of this work – separate compilation, improved package handling, compile time meta-object handling and the starting point for lots of optimizations – will solve real issues Rakudo users are running into today, and also provide a framework to solve many more of them into the future.

My plan from here is to tie up the remaining work in the area of compile time meta-objects – there are a couple of hard problems remaining, but they’re at least quite isolated in scope – then return to the nom branch in Rakudo.
