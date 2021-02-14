# Rakudo JVM News: More tests, plus Thread and Promise prototypes
    
*Originally published on [2013-07-15](https://6guts.wordpress.com/2013/07/15/rakudo-jvm-news-more-tests-plus-thread-and-promise-prototypes/) by Jonathan Worthington.*

Last time I wrote, the Rakudo on JVM port was passing around 92% of the specification tests that Rakudo on Parrot can. In the last couple of weeks, we’ve continued hunting down and fixing failures. I’m happy to report that we have already passed the 98% mark – well beyond the 95% I was aiming for by the July release! I’m optimistic that we may be able to push that up to 99% in the coming days. Either way, we’re closing in on the goal spectest wise, meaning the focus should soon move to getting tools like Panda working, followed by the module ecosystem. Happily, *arnsholt*++ has already started working on the NativeCall support that many modules depend on.

One of the reasons for adding a JVM backend is to unblock work on Rakudo’s support for asynchronous, parallel and concurrent programming. With a YAPC::EU talk on these topics looming, and hating to take to the stage without anything to demonstrate, I’ve started working on this area. It’s early days yet, but here is a quick look at what’s already possible.

There is some basic support for doing stuff in threads.

```` raku
say "Creating a couple of threads...";

my $t1 = Thread.start({ sleep 1; say "Thread 1 done"; });
my $t2 = Thread.start({ sleep 2; say "Thread 2 done"; });

say "Waiting for joins...";
.join for $t1, $t2;
say "Joined!";
````

This does what you’d naturally expect. However, threads are kind of like the assembly language of parallel programming: occasionally you want to work at that level, but usually it’s much better to work in terms of higher level constructs. Thus, while you can do the above, I don’t suggest it. So what’s available at a higher level? Well, so far, promises are.

```` raku
say "Creating two promises...";

my $a = start { sleep 2; say "omg slept 2"; 27 }
my $b = start { sleep 1; say "omg slept 1"; 15 }

say "Scheduler has $*SCHEDULER.`outstanding` tasks";
say "Waiting for results...";
say $a.result + $b.result;
````

The `start` construct evaluates to a `Promise` object (name subject to change; Future or Task are other options we could steal from other languages). A `Promise` is an object that represents a piece of ongoing work. It is not backed by a thread of its own; instead, it is scheduled onto a pool of threads that are spun up on demand, up to a limit. Alternatively, a `Promise` could be backed by some kind of asynchronous I/O. The point is that it doesn’t much matter what the exact nature of the work is, just that there’s a common way to talk about concurrent work and write combinators over them.

When you ask for the result of a `Promise` and it is not available, you will block until it is available. If the inside of the `start` block died, then the exception will be thrown at the point the `result` method is called. There is also a method `then` for chaining on extra work to be done once the promise is either completed or fails due to an exception:

```` raku
my $a2 = $a.then(-> $res { say "Got $res.`result` from promise a" });
````

This returns another `Promise`, thus allowing chaining. There is also a sub `await` that for now just calls the result method for you, on a whole list of promises if you pass them. Here’s an example:

```` raku
say [+] await dir('docs/announce').map({
    start { .IO.lines.elems }
});
````

This creates a `Promise` per file in the directory that will count the number of lines in the file. Then, await will wait for each of the promises to give a result, handing them back as they come in to the reduction. Note that in the future, this could probably just be:

```` raku
say [+] hyper dir('docs/announce').map(*.IO.lines.elems)
````

But we didn’t implement that yet, and when it does happen then it will most likely not work in terms of simply creating a promise per element.

Remember that promises are much lighter than threads! We’re not spinning up dozens of threads to do the work above, just spreading the load over various threads. And yes, the parallel version does run faster on my dual core laptop than the one that isn’t using start/await.

Future plans for promises include combinators to wait for any or all of them, an API for backing them with things other than work in the thread pool, and making await a bit smarter so that it can suspend an ongoing piece of work in the thread pool when it blocks on another promise, thus freeing up that thread for other work.

Of course, all of this is early and experimental; any/all of the above can change yet, and it’s a long, long way from being exercised to the degree that many other parts of Rakudo have been. Expect changes, and expect many more things to land in the coming months; on my list I have asynchronous I/O and an actors module, and I know *pmichaud*++ has been thinking a bit about how to evolve the list model to support both race and hyper.

Anyway, that’s the latest news. Next time, hopefully there will be yet more spectest progress and some nice sugar for *sorear*++’s ground work on Java interop, which is what I used to build the threads/promises implementation.
