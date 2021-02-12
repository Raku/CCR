# Rakudo Day: Fixes and features
    
*Originally published on [17 December 2008](https://use-perl.github.io/user/JonathanWorthington/journal/38113/) by Jonathan Worthington.*

So, here we are with the last Rakudo day before Christmas break. After a rather feature-filled last Rakudo day, I figured this week was time to take on some of the bugs in the RT queue.

*masak* found a bug in multiple dispatch, where it reported an ambiguity instead of no applicable candidates in cases where you had a bunch tied on constraints where none of the constraints matched. So, I fixed it. By the way, he was doing something pretty cool when he found the bug:

```` raku
multi foo(&c where { .arity == 1 }) { say "One." };
multi foo(&c where { .arity == 2 }) { say "Two." };
````

That is, multi-dispatching on the arity of the passed code block. (This worked, it was just when `foo({{$^a + $^b + $^c })` was called, with arity 3, it gave the wrong kind of error.) You can do some wonderful things in Raku. :-)

Another quirk found through playing around with this was that if you wrote a sub taking a parameter with the sigil `&`, we needed to check that it was something that you could invoke. In Raku, that's the `Callable` role. So I stubbed that in, got `Code` to do it, and added a small temporary workaround to make typechecking work out on it since we aren't re-blessing Parrot subs into Raku types just yet. And now if you were to call `foo(42)`, continuing the example above, you'll get a type-check failure. Happily, multi-dispatch based on the sigil type just worked from this chance without any additional tweaks, which is what I expected.

```` raku
multi bar($x) { 1 }
multi bar(&x) { 2 }
say bar(42) # 1
say bar({42}) # 2
````

Next up, I worked on adding a missing feature that had been requested: the `.clone` method. This in its most basic form, which I added first, lets you clone an object. The clone has its own state distinct from that of the original.

```` raku
class A { has $.x is rw };
my $a = A.new(x => 5);
my $a2 = $a.clone;
$a2.x = 42;
say $a.x; # 5 - original unaffected
say $a2.x; # 42
````

You can also change the values of attributes, such as in the S12 example:

```` raku
$newdog = $olddog.clone(:trick<RollOver>);
````

Which just goes to show that while you can't teach an old dog new tricks, you can always get him cloned and teach his clone a new one. Anyway, added various new tests for the clone stuff, as well as unfudging those already there.

Smart-matching against arrays and lists had been requested, so I set about getting us an implementation of that. It supports `*` wildcard too, which can stand for any element. So you can now do things like:

```` raku
say (1,2,3) ~~ (1,2,3); # 1
say (1,2,3) ~~ (1,2,3,4); # 0
say (1,2,3) ~~ (*,2,*); # 1 (like, does it contain a 2)
say (1,2,3) ~~ (1,*); # 1 (does it start with a 1)
say (1,2,3) ~~ (*,3); # 1 (does it end with a 3)
````

Some other fixes in brief.

- Fixed doing private method calls with an indirect name, e.g. `$obj!'foo'()`.
- Applied a patch and added a test from *Ronald Schmidt* to handle substr being invoked with a negative start and length (the patch should now give us the Perl behaviour on this).
- Applied a patch from *Chris Dolan* to fix some grammar and nested namespace issues, and added the example from his ticket as a spectest.
- Reviewed, commented on and in a couple of cases where the issue was dealt with closed various other tickets.

Thanks to Vienna.pm for funding this Rakudo Day!
