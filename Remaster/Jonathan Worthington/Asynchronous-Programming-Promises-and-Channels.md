# Asynchronous Programming: Promises and Channels
    
*Originally published on [14 December 2013](https://perl6advent.wordpress.com/2013/12/14/asynchronous-programming-promises-and-channels/) by Jonathan Worthington.*

Some of the most exciting progress in Raku over the last year has been in the area of asynchronous, concurrent and parallel programming. In this post, we’ll take a look at two of the language features that relate to this: promises and channels. But first…

### A Little Design Philosophy

Threads and locks are the assembly language of parallel programming. In the spirit of “make the hard things possible”, Raku does let you spawn a thread and provide you with a Lock primitive. But these are absolutely aimed at those doing the hard things. I’ve written, code-reviewed and taught parallel programming in languages where these were the primary primitives for a while. Doing code reviews was often a fairly depressing affair. It’s not just that there were bugs, it’s that often it felt like the approach taken by the code’s author was, “just throw locks all over the place and all will be well”.

In this post, I’ll focus on the things we have in Raku to help make the easy things easy. They are designed around a number of principles:

- The paradigms we provide should have a strong focus on being composable, to make it easy to extend, re-use and refactor code
- Furthermore, it should be easy to compose the various paradigms together, as well as having ways to move between the synchronous and asynchronous worlds where needed
- Both asynchrony and synchronization should be explicit, happen at clearly defined boundaries, and be done at a fairly high level

In general, the Raku approach is that you achieve concurrency by decomposing a problem into many pieces, communicating through the provided synchronization mechanisms (those in the language, and no doubt a bunch of extra ones that will be provided by the module ecosystem over time). The approach is *not* about mutating shared memory. That’s decidedly in the “hard things possible” category. The fact that it’s really hard to get right is the main problem, but from a performance perspective, lots of threads competing to write to the same bit of memory is the worst case for CPU caches – which really matter these days.

### Promises

A promise is a synchronization primitive for a piece of asynchronous work that will produce a single result at some point in the future, or fail to do so because something went wrong. Different languages have evolved different terms for this idea, or use the terms with different nuances. Both “future” and “task” are often used.

The easiest way to create a promise is:

```` raku
my $p10000 = start {
    (1..Inf).grep(*.is-prime)[9999]
}
````

This schedules the work in the block to be done. By default, this means it will be scheduled to run on a pool of threads. Thus, start introduces asynchrony into a program. We continue by executing the next line of code, and the work we specified will be done on another thread. If it runs to completion and produces a result, we say that the promise was **kept**. If, by contrast, it dies by throwing an exception, then we say the promise was **broken**.

So, what can you do with a promise? Well, you can ask it for the result:

```` raku
say $p10000.result;
````

This blocks until the promise is kept or broken. If it is kept, the value it produced is returned. If it’s broken, the exception is thrown. There’s a neater way to write this:

```` raku
say await $p10000;
````

This may take many promises, and so you can do things like:

```` raku
my @quotes = await @currency_exchanges.map(-> $ex { start { $ex.get_quote($val) } });
````

Although this will throw an exception if any of them fail. Thus, we may wish to wait on all of them, then just extract those that produced a result:

```` raku
my @getting = @currency_exchanges.map(-> $ex { start { $ex.get_quote($val) } });
await Promise.allof(@getting);
my @quotes = @getting.grep(*.status == Kept).map(*.result);
````

There’s something a little interesting in there: `allof`. This is an example of a promise combinator: something that takes one or more promises as its arguments and creates some kind of composite promise that relates to them. And this brings us to the next interesting and important thing: a promise need not be backed by a piece of asynchronously executing code! For example, we can create a promise that will be kept after a certain amount of time has elapsed:

```` raku
my $kept_in_10 = Promise.in(10);
````

Thus, we might provide a basic timeout mechanism, making sure any exchange that doesn’t give us a result in 5 seconds doesn’t get blocked on:

```` raku
my @getting = @currency_exchanges.map(-> $ex { start { $ex.get_quote($val) } });
await Promise.anyof(Promise.allof(@getting), Promise.in(5));
my @quotes = @getting.grep(*.status == Kept).map(*.result);
````

Of course, sitting around and waiting for results is just one thing we can do with a promise. We can also provide things that should be done upon the promise being completed. These will also be scheduled and run asynchronously. For example:

```` raku
my $p10000 = start {
    (1..Inf).grep(*.is-prime)[9999]
}
my $base16 = $p10000.then(sub ($res) {
    $res.result.base(16)
});
my $pwrite = $base16.then(sub ($res) {
    spurt 'p10000.txt', $res.result;
    return 'p10000.txt';
});
````

Here, we use then in order to specify something that should be done after the promise is kept or broken. This also returns a promise, meaning you can chain another operation into the process. And you can call then multiple times on one promise too, giving a kind of one-off publish/subscribe mechanism (see a future article on supplies for a much richer way to do this kind of thing, however). Note that promise takes care internally to make sure races work out OK (for example, the work being done in the promise is already completed by the time we call then).

You can also create your own promises, keeping or breaking them as you desire. This is as simple as:

```` raku
# Create the promise.
my $p = Promise.new;

# Take the "vow" object, used to keep/break it.
my $v = $p.vow;

# Later, one of...
$v.keep($result);
$v.break($exception_or_message);
````

Thus, you can write your own promise factories and combinators too.

### Channels

A promise is OK for conveying a single result, but what about producer/consumer scenarios where the producer will produce many values over time, and the consumer will process them as they are available? This is where a channel can come in useful.

Let’s say we want to read in a bunch of INI configuration files, parse each one using a grammar, and then flatten the configuration results into a single hash. There are three distinct steps here, in a producer/consumer relationship, which we can do in parallel. While the final result is a single value, and so a promise feels suitable, there are many files to read and parse. This is where channels come in. Let’s explore them using this example.

First, here is the top level of the program:

```` raku
sub MAIN {
    loop {
        my @files = prompt('Files: ').words;
        read_all(@files);
    }
}
````

This prompts the user for a bunch of filenames, then calls `read_all`. This is a little more interesting:

```` raku
sub read_all(@files) {
    my $read = Channel.new;
    my $parsed = Channel.new;
    read_worker(@files, $read);
    parse_worker($read, $parsed) for 1..2;
    my %all_config = await config_combiner($parsed);
    say %all_config.perl;
}
````

This creates two channels, `$read` and `$parsed`. The `$read` channel will be used by `read_worker` in order to send the contents of each of the files it reads in along to the `parse_worker`. Here is `read_worker`:

```` raku
sub read_worker(@files, $dest) {
    start {
        for @files -> $file {
            $dest.send(slurp($file));
        }
        $dest.`close`;
        CATCH { $dest.fail($_) }
    }
}
````

It uses the `send` method in order to send along the contents of each file it slurps. After slurping them all, it calls `last` on the channel to indicate there will be no more. The `CATCH` block calls `fail` on the channel to indicate that the producer failed. This will, when reached, throw an exception in the consumer. A channel that has had `last` or `fail` called on it can no longer be used to send values. Finally, the whole thing is wrapped in a `start` block so it is done on a thread in the thread pool.

The `parse_worker` is a little more interesting:

```` raku
sub parse_worker($source, $dest) {
    my grammar INIFile {
        token TOP {
            ^
            <entries>
            <section>+
            $
        }

        token section {
            '[' ~ ']' <key> \n
            <entries>
        }

        token entries {
            [
            | <entry> \n
            | \n
            ]*
        }

        rule entry { <key> '=' <value> }

        token key   { \w+ }
        token value { \N+ }

        token ws { \h* }
    }

    my class INIFileActions {
        method TOP($/) {
            my %result;
            %result<_> = $<entries>.ast;
            for @<section> -> $sec {
                %result{$sec<key>} = $sec<entries>.ast;
            }
            make %result;
        }

        method entries($/) {
            my %entries;
            for @<entry> -> $e {
                %entries{$e<key>} = ~$e<value>;
            }
            make %entries;
        }
    }

    start {
        loop {
            winner $source {
                more $source {
                    if INIFile.parse($_, :actions(INIFileActions)) -> $parsed {
                        $dest.send($parsed.ast);
                    }
                    else {
                        $dest.fail("Could not parse INI file");
                        last;
                    }
                }
                done $source { last }
            }
        }
        $dest.`close`;
        CATCH { $dest.fail($_) }
    }
}
````

It starts off with a grammar and actions class for INI files. We then sit in a loop, watching the `$source` channel, which is the one that `read_worker` is placing results in. If a channel has one *more* value available, then the more block will be called. Inside it, `$_` will contain the slurped contents of an INI file. We then parse it, and provided this worked out send along the hash of hashes representing the INI file’s content (sections at the top level, then key/value pairs). Again, we take care to call `fail` and `last` appropriately.

Finally, config_combiner takes each of those hash of hashes, and does the work to combine them into a single hash. It uses a promise to convey the final, single, result.

```` raku
sub config_combiner($source) {
    my $p = Promise.new;
    my $v = $p.vow;
    start {
        my %result;
        loop {
            winner $source {
                more $source {
                    for %^content.kv -> $sec, %kvs {
                        for %kvs.kv -> $k, $v {
                            %result{$sec}{$k} = $v;
                        }
                    }
                }
                done $source { last }
            }
        }
        $v.keep(%result);
        CATCH { $v.break($_) }
    }
    return $p;
}
````

And there we have it: a program using promises and channels happily together, in a producer/consumer, map/reduce style.
