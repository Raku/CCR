# A VM for 6model
    
*Originally published on [31 May 2013](http://strangelyconsistent.org/blog/a-vm-for-6model) by Carl Mäsak.*

Here's what I wrote in [another post](Raku-is-now-half-as-old-as-perl.html) earlier this year:
  
> [...] what makes me the most optimistic about the Raku effort: after a few years of watching things evolve, I've noticed that while Raku is being developed top-down on the outermost scale, it's actually a series of bottom-up projects that drive Raku forwards.

Over the years, Raku users have seen a descending sequence of components being replaced and improved, each one furthering our reach. It reads almost like [a nursery rhyme](https://en.wikipedia.org/wiki/For_want_of_a_nail), though with a positive spin:

- When we had junctions, we got ourselves a method dispatch that served them better.
- When we had method dispatch, we got ourselves an object system that served it better.
- When we had an object system, we got ourselves 6model that served it better.

And people have been *talking* about taking the obvious next step with this: building a runtime, or retrofitting an existing runtime, that would serve 6model better.

Today [MoarVM](https://github.com/moarvm/moarvm) is revealed. It's a VM for 6model.

Imagine taking all the lessons learned about Raku and VMs, and factoring them into a project like this. [jnthn's article](https://6guts.wordpress.com/2013/05/31/moarvm-a-virtual-machine-for-nqp-and-rakudo/) goes on to list all the things that MoarVM does:

- lightweight and focused
- quick and easy build
- JIT compilation (to be explored in the future)

The really nice aspects of this can be read between the lines: MoarVM is lightweight, so it starts up faster than the JVM, and even before the real optimization and JIT work begins, its runtime performance already shows some promise.

There's no historical baggage, and there's not a sense that the project is fighting technical debt when moving forward. Since MoarVM is designed for nqp from day one &mdash; in a very real sense, MoarVM *is* an nqp backend &mdash; we're guaranteed both a nice direct focus on Rakudo, as well as the ability to support other higher-level languages long-term. Things are factored in a way that we can build Raku on. Hard-earned VM lessons from 2001 up until today are coded into the foundation.

In other words, MoarVM reboots the whole VM idea for Perl, based on experience with Parrot, without many of the flaws of Parrot.

Of course, work is still very much ongoing on other backends as well. With nqp bootstrapped on the JVM, about to be bootstrapped on MoarVM, and likely running on JavaScript soon, we're looking at a *very* interesting 2013.
