# Features of Perl 6.d
    
*Originally published on [22 December 2017](https://perl6advent.wordpress.com/2017/12/22/day-22-features-of-perl-6-d/) by Elizabeth Mattijsen.*

So there we are.  Two years after the first official release of Raku.  Or **6.c** to be more precise.  Since *Matt Oates* already touched on the [performance improvements](https://rakuadvent.wordpress.com/2017/12/16/) since then, Santa thought to counterpoint this with a description of the new features for **6.d** that have been implemented since then.  Because there have been many, Santa had to make a selection.

## Tweaking objects at creation

Any class that you create can now have a [`TWEAK`](https://docs.raku.org/language/objects#Object_Construction) method.  This method will be called **after** all other initializations of a new instance of the class have been done, just before it is being returned by `.new`.  A simple, bit contrived example in which a class `A` has one attribute, of which the default value is `42`, but which should change the value if the default is specified at object creation:

```` raku
class A {
    has $.value = 42;
    method TWEAK(:$value = 0) { # default prevents warning
        # change the attribute if the default value is specified
        $!value = 666 if $value == $!value;
    }
}
# no value specified, it gets the default attribute value
dd A.new;              # A.new(value => 42)

# value specified, but it is not the default
dd A.new(value => 77); # A.new(value => 77)

# value specified, and it is the default 
dd A.new(value => 42); # A.new(value => 666)
````

## Concurrency Improvements

The concurrency features of Rakudo Raku saw many improvements under the hood.  Some of these were exposed as new features.  Most prominent are [`Lock::Async`](https://docs.raku.org/type/Lock::Async) (a non-blocking lock that returns a [`Promis`](https://docs.raku.org/routine/Promise)) and [atomic operators](https://docs.raku.org/type/atomicint).

In most cases, you will not need to use these directly, but it is probably good that you know about atomic operators if you’re engaged in writing programs that use concurrency features.  An often occurring logic error, especially if you’ve been using threads in Pumpking Perl, is that there is **no** implicit locking on shared variables in Raku.  For example:

```` raku
my int $a;
await (^5).map: {
   start { ++$a for ^100000 }
}
say $a; # something like 419318`
````

So why doesn’t that show `500000`?  The reason for this is that we had 5 threads that were incrementing the same variable at the same time.  And since incrementing consists of a read step, an increment step and write step, it became very easy for one thread to do the read step at the same time as another thread.  And thus losing an increment.  Before we had atomic operators, the correct way of doing the above code would be:

```` raku
my int $a;
my $l = Lock.new;
await (^5).map: {
    start {
        for ^100000 {
            $l.protect( { ++$a } )
        }
    }
}
say $a; # 500000`
````

This would give you the correct answer, but would be at least 20x as slow.

Now that we have atomic variables, the above code becomes:

```` raku
my atomicint $a;
await (^5).map: {
    start { ++⚛$a for ^100000 }
}
say $a; # 500000`
````

Which is very much like the original (incorrect) code.  And this is at least 6x as fast as the correct code using `Lock.protect`.

## Unicode goodies

So many, so many.  For instance, you can now use `≤`, `≥`, `≠` as Unicode versions of `<=`, `>=` and `!=` ([complete list](https://docs.raku.org/language/unicode_ascii)).

You can now also create a grapheme by specifying the Unicode name of the grapheme, e.g.:


```` raku
say "BUTTERFLY".parse-names; # 🦋
````

or create the Unicode name string at runtime:

```` raku
my $t = "THUMBS UP SIGN, EMOJI MODIFIER FITZPATRICK TYPE";
print "$t-$_".parse-names for 3..6; # 👍🏼👍🏽👍🏾👍🏿
````

Or [`collate`](https://docs.raku.org/language/experimental#index-entry-collate-collate) instead of just `sort`:

```` raku
# sort by codepoint value
say <ä a o ö>.sort; # (a o ä ö)
# sort using Unicode Collation Algorithm
say <ä a o ö>.collate; # (a ä o ö)
````

Or use `unicmp` instead of `cmp`:

```` raku
say "a" cmp "Z"; # More
say "a" unicmp "Z"; # Less
````

Or that you can now use **any** Unicode digits `Match` variables (`$١` for `$1`), negative numbers (`-١` for `-1`), and radix bases (`:۳("22")` for `:3("22")`).

It’s not for nothing that Santa considers Raku to have the best Unicode support of any programming language in the world!

## Skipping values

You can now call [`skip`](https://docs.raku.org/routine/skip) on [`Seq`](https://docs.raku.org/type/Seq) and [`Supply`](https://docs.raku.org/type/Supply) to skip a number of values that were being produced.  Together with [`head`](https://docs.raku.org/routine/head) and [`tail`](https://docs.raku.org/routine/tail) this gives you ample manipulexity with [`Iterable`s](https://docs.raku.org/type/Iterable) and Supplies.

By the way, `.head` now also takes a `WhateverCode` so you can indicate you want all values except the last `N` (e.g. `.head(*-3)` would give you all values **except** the last three).  The same goes for `.tail` (e.g. `.tail(*-3)` would give you all values **except** the first three). 

Some additions to the [`Iterator`](https://docs.raku.org/type/Iterator role make it possible for iterators to support the `.skip` functionality even better.  If an iterator can be more efficient in skipping a value than to actually produce it, it should implement the [`skip-one`](https://docs.raku.org/type/Iterator#method_skip-one) method.  Derived from this are the [`skip-at-least`](https://docs.raku.org/type/Iterator#method_skip-at-least) and [`skip-at-least-pull-one`](https://docs.raku.org/type/Iterator#method_skip-at-least-pull-one) methods that can be provided by an iterator.

An example of the usage of `.skip` to find out the 1000th prime number:


```` raku
say (^Inf).grep(*.is-prime)[999]; # 7919
````

Versus:

```` raku
say (^Inf).grep(*.is-prime).skip(999).head; # 7919
````

The latter is slightly more CPU efficient, but more importantly much more memory efficient, as it doesn’t need to keep the first 999 prime numbers in memory.

## Of Bufs and Blobs

[`Buf`](https://docs.raku.org/type/Buf) has become much more like an `Array`, as it now supports `.push`, `.append`, `.pop`, `.unshift`, `.prepend`, `.shift` and `.splice`.  It also has become more like `Str` with the addition of a [`subbuf-rw`](https://docs.raku.org/routine/subbuf-rw) (analogous with [`substr-rw`](https://docs.raku.org/routine/substr-rw)), e.g.:

```` raku
my $b = Buf.new(100..105);
$b.subbuf-rw(2,3) = Blob.new(^5);
say $b.perl; # Buf.new(100,101,0,1,2,3,4,105)
````

You can now also `.allocate` a `Buf` or `Blob` with a given number of elements and a pattern.  Or change the size of a `Buf` with `.reallocate`:

```` raku
my $b = Buf.allocate(10,(1,2,3));
say $b.perl; # Buf.new(1,2,3,1,2,3,1,2,3,1)
$b.reallocate(5);
say $b.perl; # Buf.new(1,2,3,1,2)
````

## Testing, Testing, Testing!

The `plan` subroutine of `Test.pm` now also takes an optional `:skip-all` parameter to indicate that all tests in the file [should be skipped](https://docs.raku.org/language/testing#Skipping_tests).  Or you can call `bail-out` to abort the test run marking it as failed.  Or set the `RAKU_TEST_DIE_ON_FAIL` environment variable to a true value to indicate you want the test to end as soon as the first test has failed.

## What’s Going On

You can now introspect the number of CPU cores in your computer by calling [`Kernel.cpu-cores`](https://docs.raku.org/routine/cpu-cores).  The amount of CPU used since the start of the program is available in [`Kernel.cpu-usage`](https://docs.raku.org/routine/cpu-usage), while you can easily check the name of the Operating System with [`VM.osname`](https://docs.raku.org/routine/osname).

And as if that is not enough, there is a new [`Telemetry`](https://docs.raku.org/type/Telemetry) module which you need to load when needed, just like the `Test` module.  The `Telemetry` module provides a number of primitives that you can use directly, such as:

```` raku
use Telemetry;
say T<wallclock cpu max-rss>; # (138771 280670 82360)`
````

This shows the number of microseconds since the start of the program, the number of microseconds of CPU used, and the number of Kilobytes of memory that were in use at the time of call.

If you want get to a report of what has been going on in your program, you can use [`snap`](https://docs.raku.org/routine/snap] and have a report appear when your program is done.  For instance:

````
use Telemetry;
snap;
Nil for ^10000000;  # something that takes a bit of time
````

The result will appear on STDERR:

```` raku
Telemetry Report of Process #60076
Number of Snapshots: 2
Initial/Final Size: 82596 / 83832 Kbytes
Total Time:           0.55 seconds
Total CPU Usage:      0.56 seconds
No supervisor thread has been running

wallclock  util%  max-rss
   549639  12.72     1236
--------- ------ --------
   549639  12.72     1236

Legend:
wallclock  Number of microseconds elapsed
    util%  Percentage of CPU utilization (0..100%)
  max-rss  Maximum resident set size (in Kbytes)
````

If you want a state of your program every .1 of a second, you can use the `snapper`:

```` raku
use Telemetry;
snapper;
Nil for ^10000000;  # something that takes a bit of time
````

The result:

````
Telemetry Report of Process #60722
Number of Snapshots: 7
Initial/Final Size: 87324 / 87484 Kbytes
Total Time:           0.56 seconds
Total CPU Usage:      0.57 seconds
No supervisor thread has been running

wallclock  util%  max-rss
   103969  13.21      152
   101175  12.48
   101155  12.48
   104097  12.51
   105242  12.51
    44225  12.51        8
--------- ------ --------
   559863  12.63      160

Legend:
wallclock  Number of microseconds elapsed
    util%  Percentage of CPU utilization (0..100%)
  max-rss  Maximum resident set size (in Kbytes)
````

And many more options are available here, such as getting the output in `.csv` format.

## The MAIN thing

You can now modify the way [`MAIN`](https://docs.raku.org/language/functions#index-entry-MAIN) parameters are handled by setting options in [%*SUB-MAIN-OPTS](https://docs.raku.org/language/functions#%*SUB-MAIN-OPTS).  The default `USAGE` message is now available inside the `MAIN` as the [`$*USAGE`](https://docs.raku.org/language/functions#index-entry-%24%2AUSAGE) dynamic variable, so you can change it if you want to.

## Embedding Raku

Two new features make embedding Rakudo Raku easier to handle:
the `&*EXIT` dynamic variable now can be set to specify the action to be taken when `exit` is called.

Setting the environment variable `RAKUDO_EXCEPTIONS_HANDLER` to "JSON" will throw Exceptions in JSON, rather than text, e.g.:

```` raku
$ RAKUDO_EXCEPTIONS_HANDLER=JSON raku -e '42 = 666'
{
  "X::Assignment::RO" : {
    "value" : 42,
    "message" : "Cannot modify an immutable Int (42)"
  }
}
````

## Bottom of the Gift Bag

While rummaging through the still quite full gift bag, Santa found the following smaller prezzies:

- Native string arrays are now implemented (`my str @a`)
- [`IO::CatHandle`](https://docs.raku.org/type/IO::CatHandle) allows you to abstract multiple data sources into a single virtual `IO::Handle`
- [`parse-base`](https://docs.raku.org/routine/parse-base) performs the opposite action of [`base`](https://docs.raku.org/routine/base)

## Time to catch a Sleigh

Santa would like to stay around to tell you more about what’s been added, but there simply is not enough time to do that.  If you really want to keep up-to-date on new features, you should check out the `Additions` sections in the [ChangeLog](https://github.com/rakudo/rakudo/blob/master/docs/ChangeLog) that is updated with each Rakudo compiler release.

So, catch you again next year!

Best wishes from
# 🎅🏾

