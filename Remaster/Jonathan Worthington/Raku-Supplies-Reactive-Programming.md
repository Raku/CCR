# Raku Supplies Reactive Programming
    
*Originally published on [19 December 2013](https://perl6advent.wordpress.com/2013/12/19/perl-6-supplies-reactive-programming/) by Jonathan Worthington.*

Several days back, we took a look at [promises and channels](https://rakuadvent.wordpress.com/2013/12/14/asynchronous-programming-promises-and-channels/). Promises provided a synchronization mechanisms for asynchronous things that produced a single result, while channels were ideal for setting up producer/consumer style workflows, with producers and consumers able to work in parallel. Today we’ll take a look at a third mechanism aimed at introducing asynchrony and coping with concurrency: supplies!

### Synchronous = Pull, Asynchronous = Push

One of the most important features of promises is the `then` method. It enables one or more things to be run whenever the asynchronous work the promise represents is completed. In a sense, it’s like a publish/subscribe mechanism: you call `then` to subscribe, and when the work is done then the notification is published. This happens asynchronously. You don’t sit around waiting for the promise to complete, but instead just say what to do when this takes place. Thinking about the way data flows, values are *pushed* along to the next step of the process.

This is rather different to things like sub and method calls. There, we make the call, then we block until it has completed. Iterating over a lazy list is the same: you can’t progress with the iteration until the next value is available. Thus, iteration is really about *pulling* stuff from a source. So, if a promise can be thought of as something that can push a single values out as it becomes available, do we have something that can push a whole stream of values outwards, as they are produced over time?

### Supplies! We do!

A while back, it was realized that the observer pattern is the mathematical dual of the iterator pattern. Why is this exciting? Quite simply, because it means that all the things you can sensibly do with something you can iterate (map, grep, zip, etc.), you can also sensibly do with something you can observe. Out of this was born reactive programming, and the Rx (Reactive Extensions) library, which has now been ported to many platforms. In Raku, we’re providing support for this in core.

### The basics

Let’s start out simple. First, we create a new `Supply`:

```` raku
my $measurements = Supply.new;
````

We can then `tap` the supply, passing a closure that should be called whenever a value is made available:

```` raku
$measurements.tap(-> $value {
    say "Measured: $value";
});
````

Finally, we produce some values:

```` raku
$measurements.more(1.5);
$measurements.more(2.3);
$measurements.more(4.6);
````

On each of these calls, the closure we tapped the supply with is invoked. Just as we can call `then` many times, so we can `tap` many times too:

```` raku
$measurements.tap(-> $value {
    say "Also measured: $value";
});
````

Now, when we produce a value:

```` raku
$measurements.more(2.8);
````

Both of the closures tapping the supply will be called. Note that `tap` returns an object which can be used to express you’re no longer interested in the supply, essentially turning that tap off.

Note that we didn’t introduce any asynchrony so far. However, supplies are built for it. You can safely have multiple threads supplying values. By default, the supplying thread is used to execute the taps.

### Enter the combinators!

Since supplies are essentially a thread-safe observer implementation, we can define many of the same things on them as we’re used to having on lists. For example, imagine we just wanted to tap high measurements. Well, we just re-use knowledge from how we’d filter a list: using `grep`!

```` raku
$measurements.grep(* > 4).tap(-> $value {
    say "HIGH: $value";
});
````

Calling `grep` on a supply produces another supply, just as calling `grep` on a list gives another list. We could, if we wished, store it in a variable and `tap` this derived supply many times, `grep` it again, `map` it, etc.

### Supply factories

There are ways to get supplies besides simply creating them directly. The `Supply` class has various factory methods that create various interesting kinds of supply, while introducing asynchrony. For example, `interval` gives a supply that, when tapped, will produce an ascending integer once per time interval.

```` raku
my $secs = Supply.interval(1);
$secs.tap(-> $s { say "Started $s seconds ago" });
sleep 10;
````

Factories can also help map between paradigms. The `Supply.for` method produces a supply that, when tapped, will iterate the specified (potentially lazy) list and push the values out to the tapper. It does the iteration asynchronously. While it’s not implemented yet, we’ll be able to define a similar mechanism for taking a `Channel` and tapping each value that is received.

### Crossing the streams

Some of the most powerful – and tricky to implement – combinators are those that involve multiple supplies. For example, `merge` gives a single supply whose values are those of the two other supplies it tapped, and `zip` pairs together values from two different supplies. These are tricky to implement because it’s entirely possible that two different threads will be supplying values. Thankfully, though, we just need to manage this once inside of the supplies implementation, and save those using them from worrying about the problem! In a sense, combinators on lists factor out flow control, while combinators on supplies factor out both flow control and synchronization. Both let us program in a more declarative style, getting the imperative clutter out of our code.

Let’s bring all of this together with an example from one of my recent presentations. We simulate a situation where we have two sets of readings coming in: first, measurements from a belt, arriving in batches of 100, which we need to calculate the mean of, and second another simpler value arriving once every 5 seconds. We want to label them, and get a single supply merging these two streams of readings together. Here’s how it can be done:

```` raku
my $belt_raw = Supply.interval(1).map({ rand xx 100 });
my $belt_avg = $belt_raw.map(sub (@values) {
    ([+] @values) / @values
});
my $belt_labeled = $belt_avg.map({ "Belt: $_" });
my $samples = Supply.interval(5).map({ rand });
my $samples_labeled = $samples.map({ "Sample: $_" });
my $merged = $belt_labeled.merge($samples_labeled);
$merged.tap(&say);
sleep 20;
````

Notice how it’s not actually that much harder than code that maps and greps lists we already had – and yet we’re managing to deal with both time and concurrently arriving data.

### The future

Supplies are one of the most recently implemented things in Rakudo, and what’s done so far works on Rakudo on the JVM. With time, we’ll flesh out the range of combinators and factories, keep growing our test coverage, and deliver this functionality on Rakudo on MoarVM too, for those who don’t want to use the JVM.
