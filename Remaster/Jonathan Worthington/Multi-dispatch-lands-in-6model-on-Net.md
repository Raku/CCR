# Multi-dispatch lands in 6model on .Net
    
*Originally published on [2010-10-31](https://6guts.wordpress.com/2010/11/01/multi-dispatch-lands-in-6model-on-net/) by Jonathan Worthington.*

A couple of weekends ago, I wrote a post on the [difficulties I was having](https://6guts.wordpress.com/2010/10/17/wrestling-with-dispatch/) with the multiple dispatch specification as it stood then. Early this week, while I was visiting some good friends in the UK, *TimToady*++ made a [spec commit](http://github.com/raku/specs/commit/60aef3acd56f47b5a78721ca886b9fd3e22b366e) aimed at addressing the issues I raised. A first scan through it on my phone looked promising; a closer reading and a further conversation once I got back home left me feeling like we now had something very implementable indeed. And so I set this weekend aside for trying to get an implementation together in the .Net implementation of NQP.

On Friday evening, I warmed up for the weekend’s hacking with a couple of good beers, finishing return exceptions so that one could use the “return” keyword and getting closures basically working. Kinda fun way to spend an evening, and unblocked some other things.

Things started out well. After a tiny [preparatory commit](http://github.com/jnthn/6model/commit/e4552237bb94def23db09af61137523a61fd0e86) to let a routine potentially act as a dispatcher, I then worked to do the minimal [set of changes](http://github.com/jnthn/6model/commit/2ad10c2d03b518868ef03d9ad7101d368da68285) to get from the previous attempt I made at multi-dispatch (where I started to discover the spec problems) to something shaped much, much more like the model described in the updated specification. I lost 5 minutes trying to work out why my changes hadn’t built, only to find they had built, it was just that I’d managed to do the model switch without causing any test regressions at all, on the first attempt. Sometimes I’m almost competent…

From there, I was able to quickly get the case of a nested lexical scope having its own instantiation of the proto that presides over its candidate list [implemented](http://github.com/jnthn/6model/commit/aa4bd8523af9891702eb8989869184977102752c) and add support for the * syntax for indicating in the proto where to call the multi-dispatcher. At that point, the NQPSetting could [start to look a bit nicer](http://github.com/jnthn/6model/commit/413bae8e277e66468edc61f221c71040b10a0684).

As a stress test, I decided to see what happened if you wrote a proto that, instead of entering the multi-dispatch, returned a closure that would do so.

```` raku
proto wow($x) {
    say("in proto");
    return { say("in closure"); {*} }
}
multi wow($x) { say($x) }
my $c := wow("in multi");
say("back from proto");
$c;
````

Which, after fixing a really silly thinko, worked:

````
in proto
back from proto
in closure
in multi
````

I think that almost scores full marks for abuse of a proto (though somebody will probably find a way to do better… :-)). But most happily, it tested multiple dispatch, closures and return all in one go – which at that point I’d managed to get in place in the space of the previous 24 hours. I took a little Ukrainian vodka, relaxed for a bit and got some sleep.

Having got the multi-subs done, I figured I could try my hand at multi-methods. This presented me with the slight issue that I hadn’t actually got enough of NQP’s ClassHOW filled out yet to have a sufficiently advanced class implementation to even ponder this. After a couple of small commits to remove blockers, I want ahead and [did so](http://github.com/jnthn/6model/commit/3c4309f33be37dcd19d06f79bdcaafa572c6a87d) and…bingo. Inheritance, and attributes too. Whee. (Note from this patch, how I’m actually able to implement the semantics of NQPs classes by writing in…NQP. This code is actually what now runs and provides classes in NQP on .Net.)

Multi-methods turned out to be something that I could mostly implement just by adding to NQPClassHOW. First I implemented [the simple case](http://github.com/jnthn/6model/commit/6e2fb4124e9ca29438856c8af179493660bcc6d6) where the proto is in the class itself so we don’t have to go off looking through the MRO for it and can just start adding candidates. With that working, I implemented [the more complex case](http://github.com/jnthn/6model/commit/dc36346ac4a7ee60fbc1d44f435e8d003fe494de) where we go and find a proto and instantiate it. It used the exact same underlying runtime operation that the nested lexical scopes did – a unification I’d expected to be able to make and was comforted to trivially achieve.

The upshot of this weekend’s hacking is that I now have a running reference implementation that delivers the proto semantics in the current specification – or at least, the key ones such that they affect dispatch. I’m happy enough that I know how, in the future, to achieve wrapping and deferral within this model, and have most of the pieces in my head for how to handle proto inlining in the trivial onlystar-body case too (which will save having to create a callframe and so forth for most protos). Next steps for the multi-dispatch work will include porting all of this over to the Parrot implementation of NQP.

As an aside, I’m also extremely happy with the way NQP on .Net is coming together. What started out as a way for me to play around with how to factor the new meta-model is shaping up to be a great prototyping ground for other features. But more than that, I think it’s got real promise to grow up first into a fully bootstrapped NQP implementation – delivering NQP and the compiler toolkit to the .Net platform – and then to go on to form the foundation of a Rakudo backend for .Net too.
