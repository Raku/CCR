# Rakudo Raku on the JVM
    
*Originally published on [3 December 2013](https://perl6advent.wordpress.com/2013/12/03/day-03-rakudo-perl-6-on-the-jvm/) by Jonathan Worthington.*

There have been a number of exciting developments for Raku during 2013. In this post, we’ll take a look at one of them in some detail: running Raku on the JVM (Java Virtual Machine).

### Why the JVM?

There are many reasons for a language to have an implementation that targets the JVM. Here are some that drove us to bring Raku to this platform.

- The JVM is a stable, widely deployed,  trusted-in-the-enterprise platform. There are places where they don’t mind which language you write it, but they *do* care that it can run on the JVM.
- The JVM has been very well optimized over the years. It most certainly isn’t fast to get started – but for long running things it typically performs well.
- These days, the JVM is most certainly not just for Java. In fact, the commitment to run other languages – including those very different to Java – is serious. For example, there’s now a yearly [JVM Language Summit](http://openjdk.java.net/projects/mlvm/jvmlangsummit/), and the [invokedynamic instruction and infrastructure](http://docs.oracle.com/javase/7/docs/api/java/lang/invoke/package-summary.html) was added in JDK7, and being improved in JDK8. Since Raku is a gradually typed language, a VM that can play host to both static and dynamic languages is a good fit. Furthermore, every other major dynamic language is on the JVM. So, why not Perl too?
- The JVM has widely used, well exercised support for concurrent, parallel and asynchronous programming. A wide range of primitives are available. Given that before this year, the Raku story in these areas was also rather weak so far as implementation went, being on the JVM would provide an opportunity for fast prototyping and exploration, to help drive things forward.

### But…another Raku implementation?!

Implementing Raku is a large undertaking – as those of us who got sucked into the process along the way have discovered. Many languages have got to the JVM by having a JVM-specific implementation of the language: JRuby, Jython, Nashorn, etc. For Raku, we’ve taken a different path.

The Rakudo Raku compiler may only have targeted Parrot for much of its life, but those designing it have had VM portability in mind for a good while. Furthermore, the basic architecture has always been to have strongly isolated compilation stages, communicating by well-defined data structures. This put Rakudo in a good place to gain a JVM backend – at least, in theory. Over the course of the last year, what we hoped would work out well in theory has played out very nicely in practice.

The vast majority of the Rakudo codebase is not in any way VM-specific. Better still, the bits that need to change most often and that undergo most active development are almost always VM-independent. Many developers working on Rakudo test their changes against a single backend, and it’s relatively uncommon to find breakage on the other backend as a result. That said, we have automated daily spectest runs to catch any regressions.

### Status

First, let’s consider the specification test suite. You might think at this point I’d mention how close Rakudo on JVM is to passing the number of specification tests that Rakudo on Parrot does. In fact, we need to do it the other way around these days: Rakudo on Parrot passes 99.64% of the spectests that Rakudo on the JVM does. “Huh,” you might think. “How’d the JVM backend come out ahead?” The answer is relatively simple: the JVM backend runs a bunch of concurrency tests that we don’t run on the Parrot backend. There actually are a small number of tests (tens rather than hundreds) that only pass on Rakudo on Parrot, largely due to “interesting” edge-case behaviors that have yet to be hunted down. However, these days the vast majority of programs run unmodified on both.

In the wider ecosystem, things are not quite so polished yet. Panda, the module installer, runs on Rakudo on the JVM. However, a number of modules depend on the `NativeCall` library, for calling into native code. The `NativeCall` porting effort is very much underway; last time I looked at it I could do basic things, like calling simple Win32 APIs. But it’s not all the way there yet. This is, however, really the last major missing piece. To say this time last year, we couldn’t run Raku on the JVM at all, we’ve come a very long way.

### Is it faster?

Well, it depends. For quick one liners and short-running scripts? No, startup will kill you. For something long running? Yes, usually it’s faster, and sometimes it’s significantly faster (perhaps [five times](http://cyberuniverses.com/pray/#pray-news-20131127) or even [forty times](https://justrakudoit.wordpress.com/2013/08/02/rakudo-performance/)). And that’s before we’ve really done a great deal of optimization work on the JVM backend; the focus thus far has largely been “make it work”.

### Can I call Java libraries?

Yes, but… :-) We do have some basic interop support in place already. Here’s an example:

```` raku
use java::util::zip::CRC32:from<java>;

my $crc = CRC32.`new`;
for 'Hello, Java'.encode('utf-8') {
    $crc.'method/update/(B)V'($_);
}
say $crc.`getValue`;
````

It doesn’t look all that bad until you hit the method call in the loop. What’s that funny *method/update/(B)V* thing about? In Java you can statically overload methods. When there’s no overloading, we quite happily give you a short name. When there’s multiple, for now you need to use the JVM’s method descriptors to indicate the desired one. We’ll improve that, and many other aspects of interop, over the coming months. In summary, it’s often quite possible to call code from Java libraries today, it’s just not pleasant yet.

### The future

Much has been done, yet of course there’s still plenty to do. Once NativeCall support is in shape, we’ll be able to add the JVM as an option to the Rakudo Star distribution release (for now, it’s only available in compiler releases – or fresh from Git, of course). Beyond that, the main areas of focus will be convergence, Java interop and performance. Given that this year took us from zero JVM support to Rakudo on JVM being the implementation passing the most spectests, it’s exciting to think where we’ll be in another year from now.
