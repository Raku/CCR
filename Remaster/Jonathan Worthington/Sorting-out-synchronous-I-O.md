# Sorting out synchronous I/O
    
*Originally published on [2017-06-07](https://6guts.wordpress.com/2017/06/08/sorting-out-synchronous-io/) by Jonathan Worthington.*

A few weeks back, I put out a [call for funding](https://6guts.wordpress.com/2017/05/12/looking-for-perl-6-rakudo-and-moarvm-development-funding/). So far, two generous individuals have stepped up to help, enabling me to spend much more time on Raku than would otherwise have been possible.

First in line was *Nick Logan* (ugexe), who is funding 60 hours to get a [longstanding I/O bug](https://github.com/MoarVM/MoarVM/issues/165) resolved. The problem, in short, has been that a synchronous socket (that is, an `IO::Socket::INET` instance) accepted or connected on one thread could not be read from or written to by another thread. The same has been true of synchronous file handles and processes.

The typical answer for the socket case has been to use `IO::Socket::Async` instead. While that’s the best answer from a scalability perspective, many people new to Raku will first reach for the more familiar synchronous socket API and, having heard about Raku’s concurrency support, will pass those off to a thread, probably using a `start` block. Having that fail to work is a bad early impression.

For processes, the situation has been similar; a `Proc` was bound to the thread it was created on, and the solution was to use `Proc::Async`. For situations where dealing with more than one of the input or output streams is desired, I’d argue that it’s actually *easier* to deal with it correctly using `Proc::Async`. However, `Proc` has also ended up with a few features that `Proc::Async` has not so far offered.

Finally, there are “file handles” – that is, instances of `IO::Handle`. Here, we typically would get away with passing handles of ordinary files around between threads, and due to an implementation detail could get away with it. The situation of an `IO::Handle` backed by a TTY or pipe was much less pleasing, however, which was especially unfortunate because it afflicted all of `$*IN`, `$*OUT`, and `$*ERR`. The upshot was that you could only read from `$*IN` from the main thread. While writing to `$*OUT` and `$*ERR` worked, it was skating on thin ice (and occasionally [falling through it](https://rt.perl.org/Public/Bug/Display.html?id=129787)).

### How did we get into this situation?

To understand the issue, we need to take a look at the history of MoarVM I/O. In its first year of its life, MoarVM was designed and built on a pretty extreme budget – that is to say, there *wasn’t* one. Building platform abstractions was certainly not a good use of limited time, so a library was brought in to handle this. Initially, MoarVM used the Apache Portable Library, which served us well.

As the concurrent and parallel language features of Raku came into focus, together with asynchronous I/O, it became clear that libuv – the library that provides I/O and platform abstractions for Node.js – was a good option for supporting this. Since the APR and libuv had substantially overlapping feature sets, we decided to move over to using libuv. In the months that followed, a bunch of the asynchronous features found in Raku today quickly fell in to place: `Proc::Async`, `IO::Socket::Async`, `IO::Notification`, asynchronous timers, and signal handlers. All seemed to be going well.

Alas, we’d made a problem for ourselves. libuv is centered around event loops. Working with an event loop is conceptually simple: we provide callbacks to be run when certain things happen (like data arriving over a socket, or a timer elapsing), and enter the event loop. The loop waits for some kind of event to happen, and then invokes the correct callback. Those callbacks may lead to other callbacks being set up (for example, the callback reacting to an incoming socket connection can set up a callback to be called whenever data arrives over that socket). This is a fine low-level programming model – and a good bit nicer than dealing with things like poll sets. However, a libuv event loop runs on a single thread. And handles are tied to the libuv event loop that they were created on.

For `IO::Socket::Async` and `Proc::Async`, this is not a problem. MoarVM internally runs a single event loop for all asynchronous I/O, timers, signals, and so forth. Whenever something happens, it pushes a callback into the queue of a scheduler (most typically that provided by `ThreadPoolScheduler`), where the worker threads lie in wait to handle the work. Since this event loop serves as a pure dispatcher, not running any user code or even such things as Unicode decoding, it’s not really limiting to have it only on a single thread.

When the synchronous I/O was ported from the APR, none of this was in place, however. Therefore, each thread got its own libuv event for handling the synchronous I/O. At the time, of course, there wasn’t really much in the way of threading support available in Rakudo on MoarVM. Therefore, at that point in time, that an event loop was tied to a thread was not problematic. It only came to be an issue as the concurrency support in Raku became mature enough that people started using it…and then running into the limitation.

### Seizing an opportunity

Having to deal with this was a chance to spend some quality time improving the lower level bits of I/O in the MoarVM/NQP/Rakudo stack, which have had very little love over the last couple of years. Recently, *Zoffix* did a bunch of great work on the higher level parts of I/O. Most helpfully for my endeavor, he also greatly improved the test coverage of I/O, meaning I could refactor the lower level bits with increased confidence.

A while back, I took the step of fully decoupling MoarVM’s asynchronous I/O from character encoding/decoding. For some months now, MoarVM has only provided support for asynchronous byte-level I/O. It also introduced a streaming decoder, which can turn bytes into characters for a bunch of common encodings (ASCII, UTF-8, and friends). This means that while the decoding hot paths are provided by the VM, the coordination is moved up to the Raku level.

With synchronous I/O, the two were still coupled, with the runtime directly offering both character level and byte level I/O. While this is in some ways convenient, it is also limiting. It blocks us from supporting user-provided encodings – at least, not in such a way that they can just be plugged in and used with a normal `IO::Handle`. That aside, there are also situations where one might like to access the services provided by a streaming decoder when not dealing with an I/O handle. (A streaming decoder is one you can feed bytes to incrementally and pull characters out, trusting that it will do the right thing with regard to multi-byte and multi-codepoint sequences.)

Whatever changes were going to have to happen to fix the thread limitations of synchronous I/O, it was quite clear that only having to deal with binary I/O there would make it easier. Therefore, a plan was hatched:

1. Re-work the synchronous I/O handles to use only binary I/O, and coordinate with the VM-backed decoder to handle char I/O.
1. Rip out the synchronous char I/O.
1. Re-implement the remaining synchronous binary I/O, so as not to be vulnerable to the threading limitations.

Making it possible to support user-defined encodings would be a future step, but the work done in these refactors would make it a small step – indeed, one that will only require work at a Raku level, not any further down the stack. While it may well end up being me that does this anyway, it’s at least now in reach for a bunch more members of the Raku development team.

### Sockets first

I decided to start out with sockets. From a technical perspective, this made sense because they were the most isolated; break `IO::Handle` and suddenly such things as `say` are busted, and both it and `Proc` are used in the pre-compilation management code too. Conveniently, sockets were also *Nick*’s primary interest, so it was nice to get the most important goal of the work delivered first.

The streaming decode API, while fully implemented on MoarVM, had only been partially implemented on the JVM. Therefore, to complete the work on sockets without busting them on the JVM, I had to implement the missing pieces of the VM-backed streaming decode API. This meant dealing with NIO (“New IO”), the less about which is said the better. I’m pretty sure the buffer API wasn’t designed to trip me up at every turn, but it seems to reliably manage to do so. Since file handles on the JVM would soon also come to depend on this code, it was nice to be able to get it at least straight enough to be passing all of the sockets tests, plus another set of lower-level tests that live in the NQP repository.

Refactoring the socket code itself gave a good opportunity for cleanups. The `IO::Socket::INET` class does the `IO::Socket` role, the idea being that at some point other implementations that provide things like domain sockets will also do that role, and just add the domain socket specific parts. In reviewing what methods were where, it became clear that some things that really belonged in the `IO::Socket` role were not, so I moved them there as part of the work. I also managed to eliminate all of the JVM-specific workarounds in the socket code along the way, which was also a happy outcome.

With that refactored, I could rip out the character I/O support from sockets in MoarVM. This left me with a relatively small body of code doing binary socket I/O using libuv, implementing synchronous socket I/O atop of its asynchronous event loop. When it comes to sockets, there are two APIs to worry about: the Berkeley/BSD/POSIX one, and Winsock. Happily, in my case, there was a lot of overlap and just a handful of places that I had to deal with divergence. The extra lines spent coping with the difference were more than paid back by not faking synchronous I/O in terms of an asynchronous event loop.

### File handles next

Buoyed by this success, it was time to dig into file handles. The internals of `IO::Handle` were poked into from outside of the class: a little in `IO::Path` and more so in `Proc`, which was actually setting up `IO::Pipe`, a subclass of `IO::Handle`. Thankfully, with a little refactoring, the encapsulation breakage could be resolved. Then it was a case of refactoring to use the streaming decode API rather than the character I/O. This went relatively smoothly, though it also uncovered a previously hidden bug in the JVM implementation of the streaming decoder, which I got fixed up.

So, now to rip the character file I/O out of MoarVM and refactor the libuv away in synchronous file handles too? Alas, not so fast. NQP was also using these operations. Worse, it didn’t even *have* an IO handle object! Everything was done in terms of `nqp::ops` instead. So, I introduced an NQP IO handle class, gave it many of the methods that its Raku big sister has, and refactored stuff to use it.

With that blocker out of the way, I could move on to sorting things out down in MoarVM. Once again, synchronous file I/O looks similar enough everywhere to not need all that much in the way of an abstraction layer. On Windows, it turned out to be important to put all of the handles into binary mode, however, since we do our own `\n` <-> `\r\n` mapping. (Also, yes, it is very much true that it’s only very similar on Windows if you use their POSIX API emulation. It’s possible there may be a performance win from not using that, but I can’t imagine it’ll be all that much.)

### Not entirely standard

So, all done? Well, not quite. For the standard handles, we only used the synchronous file code path when the handle was actually a regular file. This is not the common case; it’s often a pipe or a TTY. These used a completely different code path in libuv, using its streams API instead of the files API.

Thankfully, there isn’t much reason to retain this vast implementation difference. With a little work on EOF handling, and re-instating the faking of `tell`, it was possible to use the same code I had written to handle regular files. This worked out very easily on Linux. On Windows, however, a read operation would blow up if reading from the console.

Amazingly, the error string was “out of space”, which was a real head-scratcher given it was coming from a read operation! It turned out that the error string was a tad misleading; the error code is `#define`d as `ENOMEM`, so a better error string would have been “out of memory”. That still made little sense. So I went digging into the native console APIs on Windows, and discovered that reads from the console are allocated out of a 64KB buffer, which is also used for various other things. 64KB should be enough for anybody, I guess. Capping read requests to a console on Windows to 16KB was enough to alleviate this.

### Job done!

At least, for `IO::Socket::INET` and `IO::Handle`, which now are not tied to a thread on HEAD of MoarVM/NQP/Rakudo. The work on processes is ongoing, although due to be completed in the coming week. So, I’ll talk about that in my next post here.
