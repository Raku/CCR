# The new Rakudo signature binder has landed
    
*Originally published on [19 October 2009](https://use-perl.github.io/user/JonathanWorthington/journal/39772/) by Jonathan Worthington.*

Since I got back from my travels in Asia - actually, as soon as I'd got a good night's sleep after the long flight - I've been busily hacking away on my latest Hague Grant. In fact, I've done rather little else. After a couple of weeks of work - with many late nights debugging - I've finally reached the first major milestone of the grant: the new signature binder has landed.

So what is a signature binder anyway? It's the thing that takes the signature on a block (or some more interesting type of code object, such as a sub or a method) along with the arguments that it was invoked with and - if possible - binds them against the signature, such that the arguments passed end up in the correct variables. It sounds relatively simple, and in some senses it is. However, Raku signatures offer a lot of powerful features, making things rather less trivial.

If you've been using Rakudo before now, you'll probably have been writing things with signatures and passing arguments along to them quite happily, and be wondering, "why a new binder?" It's a fair enough question, and the simple answer is because we'd reached the point where the approach Rakudo had taken so far had gone as far as we could sensibly take it. We've often used the defaults provided by Parrot in the past to allow us to make progress on developing a useful compiler; we did so with multiple dispatch, method dispatch, objects, roles and so forth. The approach has paid off: people are writing cool stuff with Rakudo today (I played a board game online with *masak*++ earlier today; the game itself was implemented in Raku, used the Web.pm framework and was being served by a web server written in Raku too). In the meantime, we've been replacing those Parrot defaults with things that get the more subtle and/or powerful parts of the Raku specification correct, and usually that do so in a more efficient manner.

The main things that prompted development of a custom binder were:

- While Parrot could bind the arguments to registers, we then had to follow that up with code to put those into lexical variables. We then had to make a second pass over the arguments to do type checks and enforce context. This was inefficient - we had to do a lot of extra lookups as well as two passes over all of the arguments. It was really also quite bad if we were just binding the signature because we had a multi-dispatch candidate that needed a bindability check: we'd have already got a lot of the work done before we could figure out that actually, the first argument had a constraint on it that immediately ruled it out.
- Raku allows binding of named parameters to positional variables - that is, even positional variables can be passed as named parameters too. Parrot didn't support this, and was going to be really quite hard to layer onto the existing model we had. Doing it efficiently was fairly out of the question. Getting Parrot to support it was also an option, but bulking up the VM for a feature only one language really wants is not really optimal.
- If multi-dispatch had already decided that a candidate's types matched those of the arguments being passed, there wasn't a good way to avoid the argument type checks. At the same time, we had to be sure to enforce them if a multi candidate was somehow invoked without going through the multi-dispatcher.
- If multi-dispatch depended on a bindability check, we'd like to just keep the candidate around, and not re-bind everything. There wasn't an easy way to do that either.
- Nor was there a particularly easy way to implement nested signatures. These allow powerful functional-style matching as well as deep data structure unwrapping.
- Signature binding in Raku isn't just done when calling a routine. For example, you can use a signature to bind and unpack return arguments too. These return unpack signatures can be just as complex as those used when calling a routine. Heck, you can even have a signature literal and just smart-match against it to attempt binding. We needed something that was going to support these use cases too, which argued against having Parrot doing half the work and us patching it up later.

The new signature binder I have merged into master this evening either supports or is designed with later supporting all of these needs in mind. It handles binding named arguments to positionals right out of the box, for example. So now if you declare a sub:

```` raku
sub plot($x, $y) { }
````

Then you can call it as any of:

```` raku
plot(4,2);
plot(x => 4, y => 2);
plot(4, y => 2);
plot(2, x => 4);
plot(y => 2, x => 4);
````

Under the new signature binder, it was also trivial to add the code to avoid re-doing the type checks for a multi-dispatch candidate. While I didn't yet add the "don't re-bind when we did already passed a bindability check" improvement, that's mostly because it requires a slightly less trivial refactor to the multi-dispatcher - there's some stuff stubbed in to support it when I get that done though. And also there's a stub for nested signatures, which will be coming along later. Those are going to be way cool.

A couple of other things came up during the refactor that also led to some on-the-side bonus improvements. The most immediately useful one is that lexical variables declared outside of packages are now visible inside them - a source of much past frustration.

```` raku
my $dips = 0;

class Chip {
    method `dip` {
        $*dips*++;
    }
}

my @chips = Chip.new, Chip.new, Chip.new;
@chips>>.dip for 1..10;

say $dips; # 30
````

I also fixed the bug with junction auto-threading and for loops, so if the signature of your for loop declares a non-junctional type then you'll get the body run multiple times, once for each thingy in the junction. Also, signatures can now be written as literals, without getting weird errors.

Finally, I mentioned that one goal was getting better performance. I've not yet started to optimize the new binder - yes, it has some built-in by design performance improvements, but I didn't really dig in to the real effort of making it faster yet. Even so, the gains are notable. The figures below are the percentage of time it now takes to run some micro-benchmarks on specific language constructs compared to before I started working on the signature and binding improvements. So for example, 10,000 method dispatches now take about 26% of the time they used to.

```` raku
Startup: 76%
10,000 sub dispatches: 45%
10,000 multi dispatches: 35%
10,000 method dispatches: 26%
10,000 multi-method dispatches: 20%
10,000 operator dispatches: 33%
postfix:<++> 10,000 times: 57%
````

These figures sure don't mean that Rakudo is fast yet - we've a long way to go until I'd say that - but I think for the "we didn't start optimizing the new binder yet" phase, these are an encouraging start.

More as the grant progresses. In the meantime, enjoy the improvements. :-)
