# A quick JVM backend update
    
*Originally published on [2013-01-18](https://6guts.wordpress.com/2013/01/18/a-quick-jvm-backend-update/) by Jonathan Worthington.*

Things have been moving along quite rapidly on the JVM backend since my last post. Sadly, I’m too sick to hack on anything much this evening (hopefully, this turns out to be a very temporary affliction…) but I can at least just about write English, so I figured I’d provide a little update. :-)

Last time I blogged here, I was able to compile various QAST trees down to JVM bytecode and had a growing test suite for this. My hope was that, by some inductive handwaving, being able to compile a bunch of QAST nodes and operations correctly would mean that programs made up of a whole range of them would also compile correctly. In the last week or so, that has come to pass.

Having reached the point of having coverage of quite a lot of QAST, I decided to look into getting an NQP frontend plugged into my QAST to JVM backend. In the process, I found that NQP lacked the odd VM abstraction here and there in the common prelude that it includes with every QAST tree it produces. Thankfully, this was easily rectified. Even better, I got rid of a couple of old hacks that were no longer required. With those things out of the way, I found that this common prelude depended on a couple of operations that I’d not got around to implementing in the JVM backend. These were also simple to add. And…here endeth the integration story. Yup, that was it: I now had a fledgling NQP cross-compiler. An NQP compiler running on Parrot, but producing output for the JVM.

This result is rather exciting, because…

- It’s using exactly the same parse and action stages as when we’re targeting Parrot. No hacks, no fork. The QAST tree we get from the NQP source code that goes in is exactly the one we get when targeting Parrot. Everything that happens differently happens is beyond that stage, in the backend. This is an extremely positive sign, architecturally.
- With a couple of small additions to handle the prelude, I was immediately able to cross-compile simple NQP programs and run them on the JVM. There’s no setting or MOP yet, but the basics (variables, loops, subroutines with parameters, even closures) Just Worked.
- The program I wrote to glue the JVM backend work and the existing NQP frontend together was about 30 lines of NQP code.
- This whole integration process was about an afternoon’s worth of work.

Since I got that working, my focus has been on getting nqp-mo (the NQP meta-objects) to cross-compile. This is where classes and roles are implemented, and thus is a prerequisite for cross-compiling the NQP setting, which is in turn a prerequisite for being able to start cross-compiling and running the NQP test suite. The NQP MOP is about 1500 lines of NQP code, and at this point I’ve got about 1400 of them to cross-compile. So I’m almost there with it? Well, not quite. Turns out that the next thing I need to port is the bounded serialization stuff. That’s a rather hairy chunk of work.

Anyway, things are moving along nicely. The immediate roadmap is to get the bounded serialization to the point where it’s enough for the NQP MOP, then move on to getting a minimal setting cross compiling. Beyond that, it’ll be working through the test suite, porting the regex compilation and seeing what else is needed to cross-compile the rest of NQP.
