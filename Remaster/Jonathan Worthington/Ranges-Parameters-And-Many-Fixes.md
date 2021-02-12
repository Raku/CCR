# Ranges, Parameters And Many Fixes
    
*Originally published on [5 June 2008](https://use-perl.github.io/user/JonathanWorthington/journal/36600/) by Jonathan Worthington.*

After taking last week off for workshops, this week I got back to having my weekly Rakudo day. There were various things that were just about ready, and I've spent much of today getting those in place. The result is some new features, some fixes and some work on getting the semantics correct in places that we didn't before.

One of the big changes is that the range operator, `..`, will now create a `Range` object, which is a lazy iterator. I'd done some of the initial work in writing the `Range` class before now, but using it blocked on some other list refactoring that was needed. That has now been done (thanks to *Patrick* for this), and today I was able to switch `..` over to creating the `Range` object rather than just a flat list. It still will be eager in a lot of places, because we haven't got a full lazy lists implementation just yet. However:

```` raku
for 1..1000000 -> $x {
    say $x;
}
````

Will now not create an array of a million elements. In fact, it will run in constant space. I also implemented smart-matching against Range objects. This means that you can do things like:

```` raku
if $x ~~ 1..100 { say "valid percentage" }
````

Again, this will not create a list 100 elements long, but instead just one `Range` object that knows its endpoints. There are still various things to do with ranges, including the operators for constructing ranges that are exclusive of their endpoints (and `Range` objects need some work for this themselves too). Also, we need to implement the `:by` adverb, but we can't parse adverbs on operators just yet. Oh, and then there's the fun of infinite ranges, but I'm hoping they will just fall out naturally with little to no changes to `Range` once the `Inf` type is in place.

I've been mumbling for a while about a bunch of work under the title of mutables. It has very much been an under-the-hood thing that was needed to make other things possible. Today I got us fully switched over to this model for scalars with no additional tests failing. And I also started taking of advantage of it to get a few more things in place.

Before, parameters were passed and were modifiable. However, unless you used `is rw` this should not have been so; they are meant to be readonly by default. Now we have the correct semantics, and `is rw`, `is copy` and `is readonly` work too (but writing `is readonly` is a waste of time here, since it's the default anyway; I haven't bothered in the example below).

```` raku
sub foo($x) { $x = 42; say $x; }
my $a = 100; foo($a); say $a; # Cannot assign to readonly variable
sub foo($x is rw) { $x = 42; say $x; }
my $a = 100; foo($a); say $a; # 42\n42\n
sub foo($x is copy) { $x = 42; say $x; }
my $a = 100; foo($a); say $a; # 42\n100\n
````

I also got the `VAR($x)` and `$x.VAR` macros in place (they are actually compiler macros, not sub or method calls), which let you get at the underlying implementation type - in this case the default `Scalar` object. In the end, this will let you work with traits and tied containers, though we are some way off being able to implement those yet (quite a few dependencies). For now you can do things like `$x.VAR.readonly` to find out if a variable is readonly, for example.

I've also started doing some preparations for the Next Big Thing I intend to do some work on during my Rakudo day next week: roles. We already have some basic composition support. I fixed using roles as type constraints on a variable. However, what we have so far isn't even scratching the surface of what we need to fully do roles. Attributes surely aren't done right, for example. I've spent some time reading the appropriate bits of S12, trying to get into my head what it means. I also got to discuss some bits of it with *Larry* (especially the type parameterization bits), and it seems I'm along the right lines. So, some work coming on roles next week, all being well.

I also fixed a range of smaller bugs.

- The prefix `+` and `-` operators were not preserving integer type when performed on an integer.
- The `truncate` method was not returning an `Int`, as its signature said it should.
- Parrot's String Array PMCs were missing the get_iter vtable method to get an iterator for them; applied a patch from chromatic to add them and wrote a test.
- Made `subset ... of ... where` syntax without a block work (you can just mention something there that is an expression to smartmatch against, which can be a load neater for some use cases)
- Worked out what was wrong with my previous patch written over the weekend for a Parrot GC bug, and applied a corrected one, resulting in one less spectest failure and improved stability in interactive mode. Plus this helps everyone else using Parrot.
- `my Foo $x` already correctly put a `Foo` protoobject in `$x` if `Foo` was a class, but did the wrong thing for roles and constraints. Now it does the right thing - sticks a `Failure` object in there.

So, a pretty productive day, if a bit all over the place. Thanks to Vienna.pm for funding this work, and for introducing me to a nice place to eat curry in Vienna after their Monday tech meet, which I popped along to. :-)
