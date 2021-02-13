# Happy heapster!
    
*Originally published on [2016-03-27](https://6guts.wordpress.com/2016/03/27/happy-heapster/) by Jonathan Worthington.*

In last week’s report, I was working away at a heap snapshot mechanism for MoarVM. If you don’t know what that is, I suggest taking a look at [last week’s post](https://6guts.wordpress.com/2016/03/21/a-whole-heap-of-work/) for an explanation, and then this one will probably make a whole lot more sense. :-)

This week, I did the rest of the work needed to get heap snapshots being dumped. I’m not going to talk any more about that, since I discussed the ideas behind it last time, and I encountered nothing unexpected along the way.

Instead, I want to discuss my initial work on building a tool to analyze the heap snapshots and get useful data out of them. The snapshots themeselves are mostly just megabytes and megabytes worth of integers separated by commas and semicolons. Big data it ain’t, but it’s big enough that processing it needs at least a bit of thought if we’re going to do it fast enough and without using huge amounts of memory.

I decided early on that I wanted to write this analysis tool in Raku. Overall, I’m working on performance, memory use, and reliability. The results from analyzing heap snapshots will help cut down on memory use directly, and identify leaks. Building the analyzer in Raku means I’ll be able to identify and address the performance issues that I run into along the way, helping performance. Further, I could see various opportunities to do parallel processing, giving concurrency things a bit of a workout and maybe shaking some issues out there.

### The design

I decided to build a command line application, which would execute queries on the heap snapshot and display the results. Thinking a bit about that, I realized it would break nicely into two pieces: a **model** that held the snapshot data and provided various methods to interrogate it, and a **shell** that would parse the queries and nicely display the results. All the stuff that needed performance engineering would lie within the model. In the shell, I didn’t have to worry about that.

I also realized that there was a nice perceived speed trick I could pull. While waiting for the user to type a query, there’s no reason not to get to work on parsing the snapshot and building up a data model of it. In the best case, we’re done by the time they’ve typed their query and hit enter. Even if not, we’ve shaved some time off their wait.

### Looking at heap snapshots

A heap snapshot file is really a heap snapshot collection file, in that it can hold multiple snapshots. It starts with some common data that is shared among all the snapshots:

````
strings: ["Permanent Roots","VM Instance Roots", ...]
types: 18,19;21,22;25,26;27,28;30,31;33,33;30,34;...
static_frames: 10,11,1,12;63,64,13,65;10,67,1,65;...
````

The first, `strings`, is just a JSON array of all the strings we refer to anywhere else in the snapshot. The `types` data set can be seen as representing a table with two columns, both of them being indexes into the strings array. The first column is the name of the representation, and the second is type names (for example, a Raku `Rat` would have the P6opaque representation and the `Rat` type). This is so we can understand what the objects in the snapshot are. The `static_frames`data set does a similar thing for frames on the heap, so we can see the name, line number, and file of the sub, method, or block that was closed over.

These are followed by the snapshots, which look like this:

````
snapshot 0
collectables: 9,0,0,0,0,4;5,0,0,0,125030,165;...
references: 2,0,1;2,1,2;2,2,3;2,3,4;2,4,5;2,5,6;...
````

These describe a graph, rooted at the very first collectable. The collectables are the nodes, and the references the edges between them. The integers for a collectable describe what kind of node it is (object, frame, STable, etc.), its size, how many edges originate from it and where in the references table they are located (we take care to emit those in a contiguous way, meaning we can save on a from field in the references table). The references have a to field – which is actually the third integer – along with some data to describe the reference when we know something about it (for example, array indexes and attribute names in objects can be used to label the edges).

To give you an idea of the number of nodes and edges we might be considering, the snapshot I took to start understanding the `EVAL` memory leak has 501,684 nodes and 1,638,375 edges – and that is on a fairly well golfed down program. We can expect heap snapshots of real, interesting applications to be larger than this.

We could in theory represent every node and edge with an object. It’d “only” be 3 million objects and, if you strip away all the Raku machinery we’re still pretty bad at optimizing, MoarVM itself can chug through making those allocations and sticking them into a pre-sized array in about 0.6s on my box. Unfortunately, though, the memory locality we’ll get when looking through those objects will be pretty awful. The data we want will be spread out over the heap, with lots of object headers we don’t care about polluting the CPU caches. Even with well-optimized object creation, we’d still have a bad design.

### Native arrays to the rescue

Thankfully, Raku has compact native arrays. These are perfect for storing large numbers of integers in a space-efficient way, and tightly packed together to be cache-friendly. So, I decided that my objects would instead be about the **data sets** that we might query: types, static frames, and snapshots. Then, the code would be mostly focused around ploughing through integer arrays.

The [types data set](https://github.com/jnthn/p6-app-moarvm-heapanalyzer/blob/685c2747b6a4ca0739770f24dcd9ca51bc9b1ca7/lib/App/MoarVM/HeapAnalyzer/Model.pm6#L15) makes a fairly easy example. It has two `int` arrays of indexes into the strings array, meaning the data set will be stored in two contiguous blobs of memory. Also note the careful use of **binding** in the `BUILD` submethod. Raku’s array assignment semantics are *copying* in nature, which is great for avoiding action at a distance (a good default) but not quite what we want when passing around large volumes of data. The `type-name` and `repr-name` method just resolve indexes to strings. More interesting are the `all-with-type` and `all-with-repr` methods, which simply resolve the search string – if it exists – to an index, and then go through the native int array of type name string indexes to find what we’re after.

### Parallel, and background, processing

The [`BUILD` submethod](https://github.com/jnthn/p6-app-moarvm-heapanalyzer/blob/685c2747b6a4ca0739770f24dcd9ca51bc9b1ca7/lib/App/MoarVM/HeapAnalyzer/Model.pm6#L303) for the overall model starts out by picking the file apart, which is some simple line-based parsing. Given the heap snapshot format has very few lines (though they are very long), there’s nothing too performance sensitive in this code.

Then, at the end, it [sets off 3 bits of parallel work](https://github.com/jnthn/p6-app-moarvm-heapanalyzer/blob/685c2747b6a4ca0739770f24dcd9ca51bc9b1ca7/lib/App/MoarVM/HeapAnalyzer/Model.pm6#L351) to decode the JSON strings, and to parse the type and static frame tables. It’s worth noting that the `Types` dataset does also need to be constructed with the JSON strings; a simple `await` is used to [declare that dependency](https://github.com/jnthn/p6-app-moarvm-heapanalyzer/blob/685c2747b6a4ca0739770f24dcd9ca51bc9b1ca7/lib/App/MoarVM/HeapAnalyzer/Model.pm6#L366). With regard to the snapshots, there’s no point processing all of them. Often, the user will only care about the final one, or a handful of them. At the same time, some background processing is still desriable. Thus, the model has [arrays of unparsed snapshots and parsed snapshot promises](https://github.com/jnthn/p6-app-moarvm-heapanalyzer/blob/685c2747b6a4ca0739770f24dcd9ca51bc9b1ca7/lib/App/MoarVM/HeapAnalyzer/Model.pm6#L8). When the user indicates interest in a snapshot, we will start to [prepare it](https://github.com/jnthn/p6-app-moarvm-heapanalyzer/blob/685c2747b6a4ca0739770f24dcd9ca51bc9b1ca7/lib/App/MoarVM/HeapAnalyzer/Model.pm6#L396). At the point it’s actually needed, we then [await the Promise](https://github.com/jnthn/p6-app-moarvm-heapanalyzer/blob/685c2747b6a4ca0739770f24dcd9ca51bc9b1ca7/lib/App/MoarVM/HeapAnalyzer/Model.pm6#L415) for that snapshot.

Over in the shell, we [special-case having 1 snapshot](https://github.com/jnthn/p6-app-moarvm-heapanalyzer/blob/685c2747b6a4ca0739770f24dcd9ca51bc9b1ca7/lib/App/MoarVM/HeapAnalyzer/Shell.pm6#L22) in the collection by just selecting it right away, getting on with the processing of it immediately while the user types their query. We also [take a little care](https://github.com/jnthn/p6-app-moarvm-heapanalyzer/blob/685c2747b6a4ca0739770f24dcd9ca51bc9b1ca7/lib/App/MoarVM/HeapAnalyzer/Shell.pm6#L39) to let the user know when they performed an operation, but we’re not done with parsing the snapshot yet.

### Early results

The first things I implemented were getting a summary of the heap snapshot, along with queries to see the top frames and objects, both by space and count. Here’s how a session with it on a Rakudo heap snapshot starts out:

````
$ raku -Ilib bin\moar-ha rak-heap
Considering the snapshot...looks reasonable!

This file contains 1 heap snapshot. I've selected it for you.
Type `help` for available commands, or `exit` to exit.
````

I ask for a summary:

````
> summary
Wait a moment, while I finish loading the snapshot...

    Total heap size:              28,727,776 bytes

    Total objects:                372,884
    Total type objects:           2,248
    Total STables (type tables):  2,249
    Total frames:                 2,523
````

And then can ask about the kinds of objects taking up the most space:

````
> top objects
Name                                   Total Bytes
=====================================  ===============
NQPArray                               7,184,816 bytes
BOOTInt                                4,639,680 bytes
BOOTStaticFrame                        4,195,168 bytes
VMString                               2,804,344 bytes
BOOTCode                               1,486,872 bytes
<anon>                                 1,331,744 bytes
Parameter                              847,552 bytes
BOOTNum                                827,904 bytes
BOOTStr                                546,368 bytes
Perl6::Metamodel::ContainerDescriptor  367,848 bytes
BOOTArray                              344,056 bytes
QAST::Op                               262,656 bytes
<anon>                                 255,032 bytes
Method                                 238,792 bytes
Signature                              228,096 bytes
````

And by number of objects:

````
> top objects by count
Name                                   Count
=====================================  =======
BOOTInt                                144,990
NQPArray                               74,270
VMString                               34,440
BOOTNum                                25,872
BOOTCode                               20,651
BOOTStr                                17,074
BOOTStaticFrame                        16,916
Parameter                              6,232
Perl6::Metamodel::ContainerDescriptor  5,109
BOOTHash                               4,775
Signature                              3,168
<anon>                                 2,848
QAST::Op                               2,736
BOOTIntArray                           1,725
Method                                 1,571
````

Figuring out where those huge numbers of boxed integers come from, along with the arrays we might guess they’re being stored in, will no doubt be the subject of a future week’s post here. In fact, I can already see there’s going to be a lot of really valuable data to mine.

### But…that EVAL leak

This kind of analysis doesn’t help find leaks, however. That needs something else. I figured that if I did something like this:

````
C:\consulting\rakudo>raku --profile=heap -e "for ^20 { EVAL 'my class ABC { }' }"
Recording heap snapshot
Recording completed
Writing heap snapshot to heap-snapshot-1458770262.66355
````

I could then search for the type tables for the class ABC (which we could expect to be GC’d). That would confirm that they are staying around. So, I [implemented a find query](https://github.com/jnthn/p6-app-moarvm-heapanalyzer/commit/91c7b0c737851df348d42c2597ca62ec1be3b413), which gave me output like this:

````
> find stables type="ABC"
Object Id  Description
=========  ===========
42840      ABC
42845      ABC
45288      ABC
64994      ABC
71335      ABC
76824      ABC
78599      ABC
82535      ABC
86105      ABC
146765     ABC
404166     ABC
````

Those integers on the left are unique IDs for each object on the heap. So, given one of those, I then needed to calculate a path through the heap from the root to this object, to understand why it could not be collected and freed. This would be most useful if I could be told the *shortest* path. Thankfully, there exists a well-known algorithm that runs in O(Nodes + Edges) time that can annotate all graph nodes with data that lets you then determinte the shortest path to the root in O(maximum path length). (That gives an upper bound of O(Edges) in general, however unlikely that is in the real world. To see why, consider a heap snapshot that consists entirely of a linked list.)

The algorithm, if you didn’t guess yet, is the [breadth-first search](https://en.wikipedia.org/wiki/Breadth-first_search). The nice thing is that we only have to compute it once, and can then answer shortest path queries really quickly. [Here’s the patch that added it.](https://github.com/jnthn/p6-app-moarvm-heapanalyzer/commit/685c2747b6a4ca0739770f24dcd9ca51bc9b1ca7) And here’s what it found:

````
> path 42840
Root
    --[ Thread Roots ]-->
Thread Roots
    --[ Compiling serialization contexts ]-->
BOOTArray (Object)
    --[ Unknown ]-->
SCRef (Object)
    --[ Unknown ]-->
ABC (STable)
````

Bingo! We’re somehow, in an `EVAL`, leaving a reference to the serialization context in the “stuff we’re still compiling” array. (Serialization contexts being the things that hold objects we create at compile-time, but want to refer to at runtime, and so must serialize when pre-compiling.) This discovery quickly led to [an NQP patch](https://github.com/raku/nqp/commit/a5232c5e99086ecffcd888e23f22e01f31b91057). Which…helped, but we still leak, for a different reason. The good news, however, is that the heap snapshot analyzer could very quickly show that the fix had been successful, and identify the next thing to investigate. You can only imagine how much more frustrating it would be to not have tooling that can do this! Sadly, I didn’t have time this week to dig into the next problem.

In one final bit of heap snapshot analyzer news, Timo [forked it and added more features](https://github.com/timo/p6-app-moarvm-heapanalyzer/commits/master). I love it when I build something and others dig in to make it better. `\o/````

### So, how was Raku’s performance?

I discovered 3 things that basically killed performance. The first was `Str.Int` being horrid slow, and since reading in a heap snapshot is basically all about convering strings to integers that was a real killer. For example:

````
$ timecmd raku -e "my $a; for ^1000000 { $a = '100'.Int }"
command took 0:1:09.83 (69.83s total)
````

Awful! But, a [15-minute patch](https://github.com/rakudo/rakudo/commit/72ba5a17f9eab7ddd033a9ff1024df7235f96266) later, I had it down to:

````
$ timecmd raku -e "my $a; for ^1000000 { $a = '100'.Int }"
command took 0:0:1.87 (1.87s total)
````

A factor of 37 faster. Not super-fast, so I’ll return to it at some point, but tolerable for now. I guess this’ll help out plenty of other folk’s scripts, so it was very nice to fix it up a bit.

The second discovery was that a thread blocked on synchronous I/O could end up blocking garbage collection from taking place by any thread, which completely thwarted my plans to do the snapshot parsing in the background. This wasn’t a design problem in MoarVM, thankfully. It’s long had a way for a thread to mark itself as blocked, so another can steal its GC work. I just had to [call it on a couple of extra code paths](https://github.com/MoarVM/MoarVM/commit/df13f017026bd639b200fb0dc645b47ca82f676a).

There’s a third issue, which is that something in MoarVM’s line reading gets costly when you have really long (like, multi-megabyte) lines. Probably not a common thing to be doing, but still, I’ll make sure to fix it. Didn’t have time for it this week, though. Next time!
