# Recollections from the Raku Core Summit
    
*Originally published on [18 June 2023](https://6guts.wordpress.com/2023/06/18/recollections-from-the-raku-core-summit/) by Jonathan Worthington.*

The first Raku Core Summit, a gathering of folks who work on “core” Raku things, was held on the first weekend of June, and I was one of those invited to attend. It’s certainly the case that I’ve been a lot less active in Raku things over the last 18 months, and I hesitated for a moment over whether to go. However, even if I’m not so involved day to day in Raku things at the moment, I’m still keen to see the language and its ecosystem move forward, and – having implemented no small amount of the compiler and runtime since getting involved in 2007 – I figured I’d find something useful to do there!




The area I was especially keen to help with is RakuAST, something I started, and that I’m glad I managed to bring far enough that others could see the potential and were excited enough to pick it up and run with it.




One tricky aspect of implementing Raku is the whole notion of BEGIN time (of course, this is also one of the things that makes Raku powerful and thus is widely used). In short, BEGIN time is about running code during the compile time, and in Raku there’s no separate meta-language; anything you can do at runtime, you can (in principle) do at compile time too. The problem at hand was what to do about references from code running at compile time to lexically scoped symbols in the surrounding scope. Of note, that lexical scope is still being compiled, so doesn’t really exist yet so far as the runtime is concerned. The current compiler deals with this by building up an entire flattened table of everything that is visible, and installing it as a fake outer scope while running the BEGIN-time code. This is rather costly, and the hope in RakuAST was to avoid this kind of approach in general.




A better solution seemed to be at hand by spotting such references during compilation, resolving them, and fixating them – that is, they get compiled as if they were lookups into a constant table. (This copies the suggested approach for quasiquoted code that references symbols in the lexical scope of where the quasiquoted code appears.) This seemed promising, but there’s a problem:




```raku
`my $x = BEGIN %*ENV<DEBUG> ?? -> $x { note "Got $x"; foo($x) } !! -> $x { foo($x) };`
```




It’s fine to post-declare subs, and so there’s no value to fixate. Thankfully, the generalized dispatch mechanism can ride to the rescue; we can:





- Create a placeholder object with an attribute to hold the resolution



- Compile the lookup into a use of a dispatcher that reads this attribute and indicates that this is a constant result of the dispatch (so it is stored in the inline cache, and after specialization will be just as cheap as any other sub call). If the attribute is not set, that means we tried to run the code before declaring the sub, and the object can carry a bit of extra metadata in order to give a good error message.



- Keep track of this object in the compiler, and – upon declaration of the sub – install it into the placeholder object.



- Give an error if we reach the end of the compilation unit with an unfilled placeholder.






When compiling Raku code, timing is everything. I knew this and tried to account for it in the RakuAST design from the start, but a couple of things in particular turned out a bit awkward.





- Every node wanting to do something at BEGIN time would implement RakuAST::BeginTime, and in doing so would have its method to perform a BEGIN-time action called at the appropriate point. So far so good, for most program elements. However, it turns out that some larger program elements want to do things at compile time both at the point they start *and* at the point they end. I’d added a “I want my BEGIN time before my children” mechanism, but that didn’t help program elements that wanted action at both points. Thus, I started a branch that introduces parse time. For “leaf” elements that is the same as BEGIN time, but for things like packages and routines, which have a bunch of stuff on the inside, it happens before we go parsing their inner scope.



- The RakuAST tree is an object graph where every node knows its children, but nodes do not reference their parents. However, some program elements need to find out about their enclosing context, for example a method wants to know about the class it is being declared in. Thus I came up with a notion of attach targets (things that child nodes want to discover) and attaching nodes (the children that want to “attach” to a parent – I’m not sure I got the naming right here, in hindsight). I guess with my IDE work it also appealed that one might be able to introspect these kinds of relationships for tooling purposes – although in reality the attaching work was highly imperative anyway. But with parse and begin time clarified, it also seemed that attachment work could happen in either (or do different work in both), but also it was hazy exactly when attachment happened, and it could end up happening multiple times, which was fragile. Thus, while the notion of attachment targets should survive – probably with a better name – the need for a RakuAST::Attaching went away. My branch also took on its elimination.






I got a decent way into this restructuring work during the core summit, and hope to find time soon to get it a bit further along (I’ve been a mix of busy, tired, and had an eye infection to boot since getting back from the summit, so thus far there’s not been time for it).




I also took part in various other discussions and helped with some other things; those that are probably most worth mentioning are:





- There was quite a bit of talk about Raku Doc (formerly Pod6) and tidying up some aspects of its design and implementation. I’m pleased to see it is getting a rather cleaner implementation in the RakuAST-based compiler frontend. (Story illustrating why: when developing the Comma IDE I built a small and very specialized Raku grammar to Java lexer/parser compiler, in order to nail the Raku language’s syntactic structure, and I followed what Rakudo’s grammar did relatively closely in all but two places: operator parsing – because it just needed to be different for the IntelliJ platform’s tree builder engine – and Pod6, because it was easier to read the spec and implement it afresh than it was to decipher Rakudo’s implementation of it!)



- There was a long-standing problem that looked like the regex engine massively leaked memory in certain cases, but nobody could pin down the leak. The reason was that it wasn’t actually leaking, it was just creating sufficient backtracking state to go quadratic in the size of the input string. MoarVM only stores an array header in the nursery (the region of memory it allocates in, and whose fullness is the trigger for doing a GC run); the array body is allocated using a standard allocator. There are good things about this, but a less good thing is that if you allocate loads of large arrays in quick succession, you’ll allocate lots of memory, but not eat much of the nursery, and so it won’t be cleaned up very soon. The regex in question was doing exactly that: since it captured into an inner cursor, and cursors are in principle immutable, then it ended up cloning the array at every backtracking step, and doing so in a fairly tight loop. Closer examination revealed that the cloning of the backtrack stack was, however, overly defensive; eliminating that copying led to a huge memory and time improvement. Still, it remains to make such large array allocations pressure the GC more (we already do a similar kind of thing for big integers).



- I provided a few MoarVM hints that helped leont get support for asynchronous UNIX domain sockets implemented. Apparently that unblocks having an asynchronous Postgres driver, which would be most welcome for use in Cro applications, where the request handling is asynchronous but the database queries end up growing the thread pool by really blocking threads.






Thanks goes to Liz for organizing the summit, to Wendy for keeping everyone so well fed and watered, to the rest of attendees for many interesting discussions over the three days, to TPRF and Rootprompt for sponsoring the event, and to Edument for supporting my attendance.
