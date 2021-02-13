# Assorted fixes
    
*Originally published on [2016-07-23](https://6guts.wordpress.com/2016/07/23/assorted-fixes/) by Jonathan Worthington.*

I’ve had a post in the works for a while about my work to make return faster (as well as routines that don’t return), as well as some notable multi-dispatch performance improvements. While I get over my writer’s block on that, here’s a shorter post on a number of small fixes I did on Thursday this week.

I’m actually a little bit “between things” at the moment. After some recent performance work, my next focus will be on concurrency stability fixes and improvements, especially to `hyper` and `race`. However, a little down on sleep thanks to the darned warm summer weather, I figured I’d spend a day picking a bunch of slightly less demanding bugs off from the RT queue. Some days, it’s about knowing what you shouldn’t work on…

### A nasty string bug

MoarVM is somewhat lazy about a number of string operations. If you ask it to concatenate two simple strings, it will produce a string consisting of a strand list, with two strands pointing to the two strings. Similarly, a substring operation will produce a string with one strand and an offset into the original, and a repetition (using the `x` operator) will just produce a string with one strand pointing to the original string and having a repetition count. Note that it doesn’t currently go so far as allowing trees of strand strings, but it’s enough to prevent a bunch of copying – or at least delay it until a bunch of it can be done together and more cheaply.

The reason not to implement such cleverness is because it’s of course a whole lot more complex than simple immutable strings. And both RT #123602 and RT #127782 were about a sequence of actions that could trigger a bug. The precise sequence of actions were a repeat, followed by a concatenation, followed by a substring with certain offsets. It was caused by an off-by-one involving the repetition optimization, which was a little tedious to find but [easy to fix](https://github.com/MoarVM/MoarVM/commit/c01472d7c539a8eea55b8443dc99e494437b7fdc).

### Constant folding Seqs is naughty

RT #127749 stumbled across a case where an operation in a loop would work fine if its input was variable (like `^$n X ^$n`), but fail if it were constant (such as `^5 X ^5`). The `X` operator returns a `Seq`, which is an iterator that produces values once, throwing them away. Thus iterating it a second time won’t go well. The constant folding optimization is used so that things like `2 + 2` will be compiled into `4` (silly in this case, but more valuable if you’re doing things with `constant`s). However, given the 1-shot nature of a `Seq`, it’s not suitable for constant folding. So, now it’s [disallowed](https://github.com/rakudo/rakudo/commit/b519088f9d91b5bff8dbbc4acf65a6cbbad94cbd).

### We are anonymous

RT #127540 complained that an `anon sub` whose name happened to match that of an existing named sub in the same scope would trigger a bogus redeclaration error. Wait, you ask. Anonymous sub…*whose name?!* Well, it turns out that what `anon` really means is that we don’t install it anywhere. It can have a name that it knows itself by, however, which is useful should it show up in a backtrace, for example. The [bogus error](https://github.com/rakudo/rakudo/commit/5af32b88d347f82f24eec32eba2b7d826930f648) was easily fixed up.

### Charset, :ignoremark, :global, boom

Yes, it’s the obligatory “dive into the regex compiler” that all bug fixing days seem to come with. RT #128270 mentioned that that `"a" ~~ m:g:ignoremark/<[á]>/` would whine about `chr` being fed a negative codepoint. Digging into the MoarVM bytecode this compiled into was pretty easy, as `chr` only showed up one time, so the culprit had to be close to that. It turned out to be a [failure to cope with end of string](https://github.com/raku/nqp/commit/8094c3d7482e89450049ab79467b75c9061cee30), and as regex bugs go wasn’t so hard to fix.

### Hang, crash, wallop

This is one of those no impact on real code, but sorta embarrassing bugs. A `(;)` would cause an infinite loop of errors, and `(;;)` and `[0;]` would emit similar errors also. The hang was caused by a loop that did `next` but failed to consider that the iteration variable needed updating [in the optimizer](https://github.com/rakudo/rakudo/commit/0d491be25bad7c8b8bef06d1892f282627cfcc5). The second was because of constructing [bad AST](https://github.com/rakudo/rakudo/commit/59b7e51b34057ae1cae87950b5d0a009aee6dbbf) with integers hanging around in it rather than AST nodes, which confused all kinds of things. And that was RT #127473.

### Improving an underwhelming error

RT #128581 pointed out that `my Array[Numerix] $x` spat out an error that fell rather short of the standards we aim for in Raku. Of course, the error should complain that `Numerix` isn’t known and suggest that maybe you wanted `Numeric`. Instead, it spat out this:

```` raku
===SORRY!=== Error while compiling ./x.pl6
An exception occurred while parameterizing Array
at ./x.pl6:1
Exception details:
  ===SORRY!=== Error while compiling
  Cannot invoke this object (REPR: Null; VMNull)
  at :
````

Which is ugly. The line number was at least correct, but still… Anyway, a [small tweak](https://github.com/rakudo/rakudo/commit/dfc53aae1a94dbaa4d5f6505a246f6e8818f3d22) later, it produced the much better:

```` raku
$ ./raku -e 'my Array[Numerix] $x;'
===SORRY!=== Error while compiling -e
Undeclared name:
    Numerix used at line 1. Did you mean 'Numeric'?
````

### Problems mixing unit sub MAIN with where constraints

RT #127785 observed that using a `unit sub MAIN` – which takes the entire program body as the contents of the `MAIN `subroutine – seemed to run into trouble if the signature contained a `where` clause:

```` raku
% raku -e 'unit sub MAIN ($x where { $^x > 1 } );  say "big"'  4
===SORRY!===
Expression needs parens to avoid gobbling block
at -e:1
------> unit sub MAIN ($x where { $^x > 1 }⏏ );  say "big"
Missing block (apparently claimed by expression)
at -e:1
------> unit sub MAIN ($x where { $^x > 1 } );⏏  say "big"
````

The error here is clearly bogus. Finding a way to get rid of it wasn’t too hard, and it’s [what I ended up committing](https://github.com/rakudo/rakudo/commit/86843a3fdb3a75a7aaf23eb51b2bfa0c3bbacddf). I’ll admit that I’m not sure why the check involved was put there in the first place, however. After some playing around with other situations that it might have aided, I failed to find any. There were also no spectests that depended on it. So, off it went.

### $?MODULE

The author of RT #128552 noticed that the docs talked about `$?MODULE` (“what module am I currently in”), to go with `$?PACKAGE` and `$?CLASS`. However, trying it out let to an undeclared variable error. It seems to have been simply overlooked. It was [easy to add](https://github.com/rakudo/rakudo/commit/7427d3fe7b4b25493390507720b35cde76f75156), so that’s what I did. I also found some old, provisional tests and brought them up to date in order to cover it.

### Subtypes, definedness types, and parameters

The submitter of RT #127394 was creative enough to try `-> SomeSubtype:D $x { }`. That is, take a subset type and stick a `:D `on it, which adds the additional constraint that the value must be defined. This didn’t go too well, resulting in some rather strange errors. It turns out that, while picking the type apart so we can code-gen the parameter binding, we failed to consider such interesting cases. Thankfully, a [small refactor made the fix easy](https://github.com/rakudo/rakudo/commit/68afa3f1e77862e4b61f9946103047103fff3c2c) once I’d figured out what was happening.

### 1 day, 10 RTs

Not bad going. Nothing earth-shatteringly exciting, but all things that somebody had run into – and so others would surely run into again in the future. And, while I’ll be getting back to the bigger, hairier things soon, spending a day making Raku a little nicer in 10 different ways was pretty fun.
