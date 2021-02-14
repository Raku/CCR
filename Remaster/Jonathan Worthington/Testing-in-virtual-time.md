# Testing in virtual time
    
*Originally published on [17 December 2016](https://perl6advent.wordpress.com/2016/12/17/testing-in-virtual-time/) by Jonathan Worthington.*

Over the last month, most of my work time has been spent building a proof of concept for a project that I’ll serve as architect for next year. When doing software design, I find spikes (time-boxed explorations of problems) and rapid prototyping really useful ways to gain knowledge of new problem spaces that I will need to work in. Finding myself with a month to do this before the “real” start of the project has been highly valuable. Thanks to being under NDA, I can’t say much about the problem domain itself. I can, however, say that it involves a reasonable amount of concurrency: juggling different tasks that overlap in time.

Perl’s “whipuptitude” – the ability to quickly put something together – is fairly well known. Figuring that Raku’s various built-in concurrency constructs would allow me to whip up *concurrent* things rapidly, I decided to build the proof of concept in Raku. I’m happy to report that the bet paid off pretty well, and by now the proof of concept has covered all of the areas I hoped to explore – and some further ones that turned out to matter but that weren’t obvious at the start.

To me, building rapid prototypes explicitly does *not* mean writing crappy code. For sure, simplifications and assumptions of things not critical to the problem space are important. But my prototype code was both well tested and well structured. Why? Because part of rapid prototyping is being able to *evolve* the prototype quickly. That means being able to refactor rapidly. Decent quality, well-structured, well-tested code is important to that. In the end, I had ~2,500 lines of code covered by ~3,500 lines of tests.

So, I’ve spent a lot of time testing concurrent code. That went pretty well, and I was able to make good use of [Test::Mock](https://github.com/jnthn/test-mock) in order to mock components that returned a `Promise` or `Supply` also. The fact that Raku has, from the initial language release, had ways to express asynchronous values (`Promise`) or asynchronous streams of values (`Supply`) is in itself a win for testing. Concurrent APIs expressed via these standard data structures are easy to fake, since you can put anything you want behind a `Promise` or a `Supply`.

My work project didn’t involve a huge amount of dealing with time, but in the odd place it did, and I realized that testing this code effectively would be a challenge. That gave me the idea of writing about testing time-based code for this year’s Raku advent, which in turn gave me the final nudge I needed to write a module that’s been on my todo list all year. Using it, testing things involving time can be a lot more pleasant.

### Today’s example: a failover mechanism

Timeouts are one of the most obvious and familiar places that time comes up in fairly “everyday” code. To that end, let’s build a simple failover mechanism. It should be used as follows:

```` raku
my $failover-source = failover($source-a, $source-b, $timeout);
````

Where:

- `$source-a` is a `Supply`
- `$source-b` is a `Supply`
- `$timeout` is a timeout in seconds (any `Real` number)
- The result, assigned to `$failover-source`, is also `Supply````

And it should function as follows:

- The `Supply` passed as `$source-a` is immediately tapped (which means it is requested to do whatever is needed to start producing values)
- If it produces its first value before `$timeout` seconds, then we simply emit every value it produces to the result `Supply` and ignore `$source-b````
- Otherwise, after `$timeout` seconds, we also tap `$source-b````
- Whichever source then produces a value first is the one that we “latch” on to; any results from the other should be discarded

Consider, for example, that `$source-a` and `$source-b` are supplies that, when tapped, will send the same query to two different servers, which will stream back results over time. Normally we expect the first result within a couple of seconds. However, if the server queried by `$source-a` is overloaded or has other issues, then we’d like to try using the other one, `$source-b`, to see if it can produce results faster. It’s a race, but where A gets a head start.

### Stubbing stuff in

So, in a Failover.pm6, let’s stub in the `failover` sub as follows:

```` raku
sub failover(Supply $source-a, Supply $source-b, Real $timeout --> Supply) is export {
    supply {
    }
}
````

A `t/failover.t` then starts off as:

```` raku
use Failover;
use Test;

# Tests will go here

done-testing;
````

And we’re ready to dig in to the fun stuff.

### The first test

The simplest possible case for `failover` is when `$source-a` produces its first value in time. In this case, `$source-b` should be ignored totally. Here’s a test case for that:

```` raku
subtest 'When first Supply produces a value in time, second not used', {
    my $test-source-a = supply {
        whenever Promise.in(1) {
            emit 'a 1';
        }
        whenever Promise.in(3) {
            emit 'a 2';
        }
    }
    my $test-source-b = supply {
        die "Should never be used";
    }
    my $failover-supply = failover($test-source-a, $test-source-b, 2);
    my $output = $failover-supply.Channel;

    is $output.receive, 'a 1', 'Received first value from source A';
    is $output.receive, 'a 2', 'Received second value from source A';
}
````

Here, we set up `$test-source-a` as a `Supply` that, when tapped, will emit `a 1` after 1 second, and `a 2` after 3 seconds. If `$test-source-b` is ever tapped it will die. We expect that if this wrongly happens, it will be at the 2 second mark, which is why `a 2` is set to be emitted after 3 seconds. We then obtain a `Channel` from the resulting `$failover-supply`, which we can use to pull values from at will and check we got the right things. (On coercing a `Supply` to a `Channel`, the `Supply` is tapped, starting the flow of values, and each result value is fed into the `Channel`. Both completion and errors are also conveyed.)

### Making it pass

There are a couple of ways that we might make this test pass. The absolute easiest one would be:

```` raku
sub failover(Supply $source-a, Supply $source-b, Real $timeout) is export {
    return $source-a;
}
````

Which feels like cheating, but in TDD the code that passes the first test case almost always does. (It sometimes feels pointless to write said tests. More than once, they’ve ended up saving me when – while making a hard thing work – I ended up breaking the trivial thing.)

An equivalent, more forward-looking solution would be:

```` raku
sub failover(Supply $source-a, Supply $source-b, Real $timeout) is export {
    supply {
        whenever $source-a {
            .emit;
        }
    }
}
````

Which is the identity operator on a `Supply` (just spit out everything you get). For those not familiar with supplies, it’s worth noting that this `supply` block does 3 useful things for you for free:

- Passes along errors from `$source-a````
- Passes along completion from `$source-a````
- Closes the tap on `$source-a` – thus freeing up resources – if the tap on the supply we’re defining here is closed

Subscription management and error management are two common places for errors in asynchronous code; the `supply`/`whenever` syntax tries to do the Right Thing for you on both fronts. It’s more than just a bit of tinsel on the Christmas callback.

### When the timeout…times out

So, time for a more interesting test case. This one covers the case where the `$source-a` fails to produce a value by the timeout. Then, `$source-b` produces a value within 1 second of being tapped – meaning its value should be relayed. We also want to ensure that even if `$test-source-a` were to emit a value a little later on, we’d disregard it. Here’s the test:

```` raku
subtest 'When timeout reached, second Supply is used instead if it produces value first', {
    my $test-source-a = supply {
        whenever Promise.in(4) {
            emit 'a 1';
        }
    }
    my $test-source-b = supply {
        whenever Promise.in(1) { # start time + 2 (timeout) + 1
            emit 'b 1';
        }
        whenever Promise.in(3) { # start time + 2 (timeout) + 3
            emit 'b 2';
        }
    }
    my $failover-supply = failover($test-source-a, $test-source-b, 2);
    my $output = $failover-supply.Channel;

    is $output.receive, 'b 1', 'Received first value from source B';
    is $output.receive, 'b 2', 'Received second value from source B';
}
````

We expect `a 1` to be ignored, because we chose `$source-b`. So, how can we make this pass? Here goes:

```` raku
sub failover(Supply $source-a, Supply $source-b, Real $timeout --> Supply) is export {
    supply {
        my $emitted-value = False;

        whenever $source-a {
            $emitted-value = True;
            .emit;
        }

        whenever Promise.in($timeout) {
            unless $emitted-value {
                whenever $source-b {
                    .emit;
                }
            }
        }
    }
}
````

Will this pass the test? Both subtests?

Think about it…

Well, no, it won’t. Why? Because it doesn’t do anything about disregarding `$source-a` after it has started spitting out values from `$source-b`. It needs to commit to one or the other. Didn’t spot that? Good job we have tests! So, here’s a more complete solution that makes both subests pass:

```` raku
sub failover(Supply $source-a, Supply $source-b, Real $timeout --> Supply) is export {
    supply {
        my enum Committed ;
        my $committed = None;

        whenever $source-a -> $value {
            given $committed {
                when None {
                    $committed = A;
                    emit $value;
                }
                when A {
                    emit $value;
                }
            }
        }

        whenever Promise.in($timeout) {
            if $committed == None {
                whenever $source-b -> $value {
                    $committed = B;
                    emit $value;
                }
            }
        }
    }
}
````

### So tired of waiting

You’d think I’d be happy with this progress. Two passing test cases. Surely the end is in sight! Alas, development is getting…tedious. Yes, after just two test cases. Why? Here’s why:

````
$ time raku -Ilib t/failover-bad.t
    ok 1 - Received first value from source A
    ok 2 - Received second value from source A
    1..2
ok 1 - When first Supply produces a value in time, second not used
    ok 1 - Received first value from source B
    ok 2 - Received second value from source B
    1..2
ok 2 - When timeout reached, second Supply is used instead if it produces value first
1..2

real    0m8.694s
user    0m0.600s
sys     0m0.072s
````

Every time I run my tests I’m waiting around **9 seconds**> now. And when I add more tests? Even longer! Now imagine I was going to write a whole suite of these failover and timeout routines, as a nice module. Or I was testing timeouts in a sizable app and would have dozens, even hundreds, of such tests.

Ouch.

Maybe, though, I could just make the timeouts smaller. Yes, that’ll do it! Here is how the second test looks now, for example:

```` raku
subtest 'When timeout reached, second Supply is used instead if it produces value first', {
    my $test-source-a = supply {
        whenever Promise.in(0.04) {
            emit 'a 1';
        }
    }
    my $test-source-b = supply {
        whenever Promise.in(0.01) { # start time + 2 (timeout) + 1
            emit 'b 1';
        }
        whenever Promise.in(0.03) { # start time + 2 (timeout) + 3
            emit 'b 2';
        }
    }
    my $failover-supply = failover($test-source-a, $test-source-b, 0.02);
    my $output = $failover-supply.Channel;

    is $output.receive, 'b 1', 'Received first value from source B';
    is $output.receive, 'b 2', 'Received second value from source B';
}
````

You want it faster? Divide by 100! Job done.

Of course, anybody who has actually done this knows precisely what comes next. The first 3 times I ran my tests after this change, all was well. But guess what happened on the forth time?

```` raku
ok 1 - When first Supply produces a value in time, second not used
    not ok 1 - Received first value from source B

    # Failed test 'Received first value from source B'
    # at t/failover-short.t line 41
    # expected: 'b 1'
    #      got: 'a 1'
    not ok 2 - Received second value from source B

    # Failed test 'Received second value from source B'
    # at t/failover-short.t line 42
    # expected: 'b 2'
    #      got: 'b 1'
    1..2
    # Looks like you failed 2 tests of 2
not ok 2 - When timeout reached, second Supply is used instead if it produces value first
````

Mysteriously…it failed. Why? Bad luck. My computer is a busy little machine. It can’t just give my test programs all the CPU all of the time. It needs to decode that music I’m listening to, check if I need to install the 10th set of security updates so far this month, and cope with my web browser wanting to do stuff because somebody tweeted something or emailed me. And so, once in a while, just after the clock hits 0.01 seconds and a thread grabs the `whenever` block to work on, that thread will be dragged off the CPU. Then, before it can get back on again, the one set to run at 0.04 seconds gets to go, and spits out its value first.

Sufficiently large times mean slow tests. Smaller values mean unreliable tests. Heck, suspend the computer in the middle of running the test suite and even a couple of seconds is too short for reliable tests.

### Stop! Virtual time!

This is why I wrote `Test::Scheduler`. It’s an implementation of the Raku `Scheduler` role that virtualizes time. Let’s go back to our test code and see if we can do better. First, I’ll import the module:

```` raku
use Test::Scheduler;
````

Here’s the first test, modified to use `Test::Scheduler`:

```` raku
subtest 'When first Supply produces a value in time, second not used', {
    my $*SCHEDULER = Test::Scheduler.new;

    my $test-source-a = supply {
        whenever Promise.in(1) {
            emit 'a 1';
        }
        whenever Promise.in(3) {
            emit 'a 2';
        }
    }
    my $test-source-b = supply {
        die "Should never be used";
    }
    my $failover-supply = failover($test-source-a, $test-source-b, 2);
    my $output = $failover-supply.Channel;

    $*SCHEDULER.advance-by(3);
    is $output.receive, 'a 1', 'Received first value from source A';
    is $output.receive, 'a 2', 'Received second value from source A';
}
````

Perhaps the most striking thing is how much *hasn’t* changed. The changes amount to two additions:

1. The creation of a `Test::Scheduler` instance and the assignment to the `$*SCHEDULER` variable. This dynamic variable is used to specify the current scheduler to use, and overriding it allows us to swap in a different one, much like you can declare a `$*OUT` to do stuff like capturing I/O.
1. A line to advance the test scheduler by 3 seconds prior to the two assertions.

The changes for the second test are very similar:

```` raku
subtest 'When timeout reached, second Supply is used instead if it produces value first', {
    my $*SCHEDULER = Test::Scheduler.new;

    my $test-source-a = supply {
        whenever Promise.in(4) {
            emit 'a 1';
        }
    }
    my $test-source-b = supply {
        whenever Promise.in(1) { # start time + 2 (timeout) + 1
            emit 'b 1';
        }
        whenever Promise.in(3) { # start time + 2 (timeout) + 3
            emit 'b 2';
        }
    }
    my $failover-supply = failover($test-source-a, $test-source-b, 2);
    my $output = $failover-supply.Channel;

    $*SCHEDULER.advance-by(6);
    is $output.receive, 'b 1', 'Received first value from source B';
    is $output.receive, 'b 2', 'Received second value from source B';
}
````

And what difference does this make to the runtime of my tests? Here we go:

````
$ time raku -Ilib t/failover-good.t
    ok 1 - Received first value from source A
    ok 2 - Received second value from source A
    1..2
ok 1 - When first Supply produces a value in time, second not used
    ok 1 - Received first value from source B
    ok 2 - Received second value from source B
    1..2
ok 2 - When timeout reached, second Supply is used instead if it produces value first
1..2

real    0m0.679s
user    0m0.628s
sys     0m0.060s
````

From 9 seconds to sub-second – and much of that will be fixed overhead rather than the time running the tests.

### One more test

Let’s deal with the final of the requirements, just to round off the test writing and get to a more complete solution to the original problem. The remaining test we need is for the case where the timeout is reached, and we tap `$source-b`. Then, before it can produce a value, `$source-a` emits its first value. Therefore, we should latch on to `$source-a`.

```` raku
subtest 'When timeout reached, and second Supply tapped, first value still wins', {
    my $*SCHEDULER = Test::Scheduler.new;

    my $test-source-a = supply {
        whenever Promise.in(3) {
            emit 'a 1';
        }
        whenever Promise.in(4) {
            emit 'a 2';
        }
    }
    my $test-source-b = supply {
        whenever Promise.in(2) { # start time + 2 (timeout) + 2
            emit 'b 1';
        }
    }
    my $failover-supply = failover($test-source-a, $test-source-b, 2);
    my $output = $failover-supply.Channel;

    $*SCHEDULER.advance-by(4);
    is $output.receive, 'a 1', 'Received first value from source A';
    is $output.receive, 'a 2', 'Received second value from source A';
}
````

This fails, because the latch logic wasn’t included inside of the `whenever` block that subscribes to `$source-b`. Here’s the easy fix for that:

```` raku
sub failover(Supply $source-a, Supply $source-b, Real $timeout --> Supply) is export {
    supply {
        my enum Committed ;
        my $committed = None;

        whenever $source-a -> $value {
            given $committed {
                when None {
                    $committed = A;
                    emit $value;
                }
                when A {
                    emit $value;
                }
            }
        }

        whenever Promise.in($timeout) {
            if $committed == None {
                whenever $source-b -> $value {
                    given $committed {
                        when None {
                            $committed = B;
                            emit $value;
                        }
                        when B {
                            emit $value;
                        }
                    }
                }
            }
        }
    }
}
````

The easy thing is just a little bit repetitive, however. It would be nice to factor out the commonality into a `sub`. Here goes:

```` raku
sub failover(Supply $source-a, Supply $source-b, Real $timeout --> Supply) is export {
    supply {
        my enum Committed ;
        my $committed = None;

        sub latch($onto) {
            given $committed {
                when None {
                    $committed = $onto;
                    True
                }
                when $onto {
                    True
                }
            }
        }

        whenever $source-a -> $value {
            emit $value if latch(A);
        }

        whenever Promise.in($timeout) {
            if $committed == None {
                whenever $source-b -> $value {
                    emit $value if latch(B);
                }
            }
        }
    }
}
````

And in under a second, the tests can now assure us that this was indeed a successful refactor. Note that this does not yet cancel a discarded request, perhaps saving duplicate work. I’ll leave that as an exercise for the reader.

### Safety and realism

One thing you might wonder about here is whether this code is really thread safe. The default Raku scheduler will schedule code across a bunch of threads. What if `$source-a` and `$source-b` emit their first value almost simultaneously?

The answer is that `supply` (and `react`) blocks promise Actor-like semantics, processing just one message at a time. So, if we’re inside of the `whenever` block for `$source-a`, and `$source-b` emits a message on another thread, then it will be queued up for processing afterwards.

One interesting question that follows on from this is whether the test scheduler somehow serializes everything onto the test thread in order to do its job. The answer is that no, it doesn’t do that. It wraps the default `ThreadPoolScheduler` and always delegates to it to actually run code. This means that, just as with the real scheduler, the code will run across multiple threads *and* on the thread pool. This helps to avoid a couple of problems. Firstly, it means that testing code that relies on having real threads (by doing stuff that really blocks a thread) is possible. Secondly, it means that `Test::Scheduler` is less likely to hide real data race bugs that may exist in the code under test.

Of course, it’s important to keep in mind that virtual time is still very much a *simulation* of real time. It doesn’t account for the fact that running code takes time; virtual time stands still while code runs. At the same time, it goes to some amount of effort to get the right sequencing when a time-based event triggered in virtual time leads to additional time-based events being scheduled. For example, imagine we schedule E1 in 2s and E2 in 4s, and then advance the virtual time by 4s. If the triggering of E1 schedules E3 in 1s (so, 3s relative to the start point), we need to have it happen before E2. To have this work means trying to identify when all the consequences of E1 have been shaken out before proceeding (which is easier said than done). Doing this will, however, prevent some possible overlaps that could take place in real time.

### In summary…

Unit tests for code involving time can easily end up being slow and/or unreliable. However, if we can virtualize time, it’s possible to write tests that are both fast and reliable – as good unit tests should be. The [Test::Scheduler](https://github.com/jnthn/p6-test-scheduler) module provides a way to do this in Raku. At the same time, virtual time is not a simulation of the real thing. The usual rules apply: a good unit test suite will get you far, but don’t forget to have some integration tests too!
