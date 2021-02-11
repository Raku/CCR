# Act with great Responsibility
    
*Originally published on [5 December 2014](https://perl6advent.wordpress.com/2014/12/05/act-with-great-responsibility/) by Elizabeth Mattijsen.*

The past year in Rakudo-land has been very exciting. It has brought us a new, full-fledged backend in the form of MoarVM. And with that came extended support for asynchronous execution of code. This means you can now more easily try out all these asynchronous features, without having to suffer from the long startup time of the JVM backend.

The `Supply` is still the main mechanism to use the Reactive Programming paradigm. Here is a simple (silly) example of using a Supply:

```` raku
1: my $s = Supply.new;
2: $s.act: { print " Fizz" if $_ %% 3 }
3: $s.act: { print " Buzz" if $_ %% 5 }
4: $s.act: { print " $_" unless $_ %% 3 || $_ %% 5 }
5: $s.emit($_) for 1..20;
======================
1 2 Fizz 4 Buzz Fizz 7 8 Fizz Buzz 11 Fizz 13 14 Fizz Buzz 16 17 Fizz 19 Buzz
````

Let’s take this example apart. Line 1 just creates a new Supply. By itself, it doesn’t do anything at all, except for creating the object, of course. Lines 2, 3 and 4 set up code (closures) to be executed every time a new value arrives in the Supply $s.

Line 5 sends 20 consecutive values to the Supply. This in turn causes the closures to be executed (in turn for each value emitted). The result is a nice FizzBuzz.

### But but…

Careful watchers of this code may wonder about two things. First of all: what’s `emit`? Is that something new? No, it is not (really). It used to be called *more*. At the Austrian Perl Workshop last October it was decided to rename this method to `emit` (as nobody was really happy with any *more*). So what happens if you have code that uses *more*? Well, it will still work, but you will get a deprecation warning **after** your process finishes:

```` raku
Saw 1 call to deprecated code during execution.
===============================================
Method more (from Supply) called at:
t/spec/integration/advent2014-day05.t, line 13
Deprecated since v2014.10, will be removed with release v2015.10!
Please use emit instead.
-----------------------------------------------
````

Note that even though the same method was called 20 times, it is only mentioned once. And that’s because all the calls happened at the same location in the code. If you have seen deprecation messages before, you might notice that it now also mentions **when** it was deprecated, and when the feature will most likely be removed.

The second thing that a careful watcher might wonder about is: why the use of `act`? Is that a also a rename (from `tap`)?  No, it is not.  The `act` method was added last April. It ensures that your closure will be the **only one** running on that Supply, even if the emits are coming from different threads.  That is a much safer default than `tap`, where multiple threads can be executing the closure you provided **at the same time**.

### Sharing everything comes with great power and great responsibility

So why is this important? This is important because all variables visible in a specific scope, are readable **and** changeable by all threads simultaneously. Reading a variable from different threads at the same time, is not an issue in Raku (apart from some minor known issues to be resolved after the Great List Refactor). Changing a variable from multiple threads simultaneously, **is** an issue that may cause data loss, memory corruption and segfaults. To give an example:

```` raku
1: my $times = 100000;
2: my $a = 0;
3: $*SCHEDULER.cue: { $*a*++ } for ^$times; # this may segfault because of unguarded changes
4: sleep 5; # poor man’s way to wait for all code to finish
5: say "Missed {$times - $a} updates";
===================================
Missed 9 updates
````

Line 1 sets up the number of iterations we’re going to do. Line 2 initializes the variable that’s going to be incremented. Although `++` is magic, we initialize the variable explicitly, so that each increment will follow the same internal code path. Line 3 cues the increment to be executed that many times (in a very low level way using the underlying scheduler). Line 4 waits for the execution to be finished. And line 5 shows the result (if we didn’t segfault, which we might).

So please use `act` rather than `tap`, unless you are **sure** that closures will not be updating any shared variables simultaneously. Which could be hard to tell if you’re using external modules inside the closure.

### FizzBuzzing some more

Coming back to the first example: should we have used *act* there, or could we have used *tap*? We could have used *tap* there, because print is threadsafe. It becomes a different story if we would have used a (shared) array instead of print:

```` raku
1: my @seen;
2: my $s = Supply.new;
3: $s.act: { @seen.push: "Fizz" if $_ %% 3 }
4: $s.act: { @seen.push: "Buzz" if $_ %% 5 }
5: $s.act: { @seen.push: $_ unless $_%%3 || $_%%5 }
6: await do for 1..20 {
7:     start { rand.sleep; $s.emit($_) }
8: }
9: say @seen;
==========
11 14 4 Fizz 17 19 Fizz Buzz 16 13 Buzz Fizz Buzz 7 Fizz 8 2 Buzz 1 Fizz Fizz
````
Hmmm… that has the right number of Fizz’s and Buzz’s, but clearly the order is wrong. But because we have used `act` rather than `tap`, we are at least sure that no `push` was executed simultaneously on the `@seen` array. So we didn’t lose any values, nor did we segfault.

You might ask: what are that lines 6-8 about? Well, that’s making sure the `emit`’s are done in a random order, spread out in time (because the 0 to 1 second random sleep from `rand.sleep`, and the `start` making it run in a separate thread).

So, how could you make this work in a parallel way? Well generally, if you have some kind of identifier for each value emitted, then you can use that to store the result in a shared data-structure. In this case, `$_` is exactly that. So with a slight modification:

```` raku
1: my @seen;
2: my $s = Supply.new;
3: $s.act: { @seen[$_] = "Fizz" if $_ %% 3 }
4: $s.act: { @seen[$_] ~= "Buzz" if $_ %% 5 }
5: $s.act: { @seen[$_] //= $_ }
6: await do for 1..20 {start{rand.sleep;$s.emit($_)}}
7: say @seen[1..20];
=================
1 2 Fizz 4 Buzz Fizz 7 8 Fizz Buzz 11 Fizz 13 14 FizzBuzz 16 17 Fizz 19 Buzz
````

By assigning directly to an element in the array (lines 3, 4, 5), we automatically put the information in the right place. And because we are (implicitely) guaranteed that `act`s on the same item are always executed in the order they were created, we can simplify the non-FizzBuzz case in line 5.

### Conclusion

When using Supplies, please use `act` on the Supply if you’re not sure whether the closure is going to change shared variables. Only use `tap* if you’re really 100% sure.

### Further reading

Last year saw 2 async execution related posts, the latter showing uses of `tap*. Please read up on them if the above was not telling you all you needed to know:

- [Day 14 - Asynchronous Programming: Promises and Channels](https://rakuadvent.wordpress.com/2013/12/14/asynchronous-programming-promises-and-channels/)
- [Day 19 - Raku Supplies Reactive Programming](https://rakuadvent.wordpress.com/2013/12/19/perl-6-supplies-reactive-programming/)

### Tests

The above code can also be found in roast at [t/spec/integration/advent2014-day05.t](https://github.com/raku/roast/blob/master/integration/advent2014-day05.t)
