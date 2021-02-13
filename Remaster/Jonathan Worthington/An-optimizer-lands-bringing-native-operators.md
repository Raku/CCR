# An optimizer lands, bringing native operators
    
*Originally published on [2011-10-15](https://6guts.wordpress.com/2011/10/15/an-optimizer-lands-bringing-native-operators/) by Jonathan Worthington.*

For some weeks now, I’ve been working on adding an optimizer pass to Rakudo and implementing an initial set of optimizations. The work has been taking place in a branch, which I’m happy to have just merged into our main development branch. This means that the optimizer will be included in the October release! :-) In this post, I want to talk a little about what the optimizer can do so far.

### When Optimization Happens

When you feed a Raku program to Rakudo, it munches its way through your code, simultaneously parsing it and building an AST for the executable bits, and a bunch of objects that represent the declarative bits. These are in various kinds of relationship; a code object knows about the bit of as-yet uncompiled AST that corresponds to its body (which it needs to go and compile just in time should it get called at `BEGIN` time), and the AST has references to declarative objects (types, subs, constants). Normally, the next step is to turn this AST into intermediate code for the target VM (so for Parrot, that’s PIR). The optimizer nudges its way in between the two: it gets to see the fully constructed AST for the compilation unit, as well as all of the declarative objects. It can twiddle with either before we go ahead and finish the compilation process. This means that the optimizer gets to consider anything that took place at `BEGIN` and `CHECK` time also.

### Using The Optimizer

The optimizer has three levels. The default level is 2. This is “optimizations we’re pretty comfortable with having on by default”. It’s possible to pass –optimize=3, in which case we’ll throw everything we’ve got at your program. If it breaks as a result, please tell us by filing an RT ticket; this is the pool of candidate optimizations to make it into group 2. After an optimization has had a while at level 2, combined with a happy and trouble-free history, we’ll promote it into level 1. Using –optimize=1 at the moment gets you pretty much nothing – the analysis but no transformations. In the long run, it should get you just the optimizations we feel are really safe, so you won’t lose everything if you need to switch down from –optimize=2 for some reason. Our goal is that you should never have to do that, of course. However, it’s good to provide options. My thanks go to *pmichaud*++ for suggesting this scheme.

### Compile Time Type Checking of Sub Arguments

One thing the optimizer can do is consider the arguments that will be passed to a subroutine. If it has sufficient type information about those arguments, it may be able to determine that the call will always be successful. In this case, it can flag to the binder that it need never do the type checks at run time. This one can actually help untyped programs too. Since the default argument type is `Any`, if you pass a parameter of one subroutine as an argument to another, it can know that this would never be a junction, so it never has to do the junction fail-over checks.

### Compile Time Multiple Dispatch Resolution

While the multiple dispatch cache current Rakudo has is by some margin the best it has ever had in terms of lookup performance, it still implies work at run time. Given enough information about the types of the arguments is present, the optimizer is able to resolve some multiple dispatches at compile time, by working out cases where the dispatch must always lead to a certain candidate getting invoked. Of course, how well it can do this depends on the type information it has to hand and the nature of the candidates. This is a double saving: we don’t have to do the multiple dispatch, and we don’t have to do the type checks in the binding of the chosen candidate either.

### Basic Inlining

In some (currently very constrained) cases, if we know what code is going to be called at compile time, and we know that the types of arguments being passed are all OK, we can avoid making the call altogether and just inline the body of the subroutine right into the caller. Of course, this is only beneficial in the case where the work the subroutine does is dominated by the overhead of calling it, and there are some cases where inlining is impossible to do without causing semantic differences. For now, the focus has been on doing enough to be able to inline various of the setting built-ins, but it’s in no way restricted to just doing that. With time, the inline analysis will be made much smarter and more capable.

### Native Operators

As part of getting the optimizer in place, *moritz*++ and I have also worked on native operators (that is, operators that operate on native types). This boils down to extra multiple dispatch candidates for various operators, in order to handle the natively typed case. However, something really nice happens here: because you always have to explicitly declare when you are using native types, we always have enough type information to inline them. Put another way, the native operator multis we’ve declared in the setting will always be inlined.

We’ve some way to go on this yet. However, this does already mean that there are some nice performance wins to be had by using native types in your program (int and num) where it makes sense to do so.

As an example, with –optimize=3 (the maximum optimization level, not the default one), we can compare:

```` raku
my $i = 0; while $i < 10000000 { $i = $i + 1 }; say $i
````

Against:

```` raku
my int $i = 0; while $i < 10000000 { $i = $i + 1 }; say $i
````

On my box, the latter typed version completes in 4.17 seconds, as opposed to the untyped version, which crawls in at 33.13 (so, a factor of 8 performance gain). If you’re curious how this leaves us stacking up against Perl, on my box it does:

```` raku
my $i = 0; while ($i < 10000000) { $i = $i + 1 }; say $i
````

In 0.746 seconds. This means that, with type information provided and **for this one benchmark**, Rakudo can get within a factor of six of Perl – and the optimizer still has some way to go yet on this benchmark. (Do **not** read any more into this. This performance factor is certainly not generally true of Rakudo at the moment.)

We’ll be continuing to work on native operators in the weeks and months ahead.

### Immediate Block Inlining

We’ve had this in NQP for a while, but now Rakudo has it too. Where appropriate, we can now flatten simple immediate blocks (such as the bodies of while loops) into the containing block. This happens when they don’t require a new lexical scope (that is, when they don’t declare any lexicals).

### That Could Never Work!

There’s another nice fallout of the analysis that the optimizer does: as well as proving dispatches that will always work out at compile time, it can also identify some that could never possibly work. The simplest case is calling an undeclared routine, something that STD has detected for a while. However, Rakudo goes a bit further. For example, suppose you have this program:

```` raku
sub foo($x) { say $x }
`foo`
````

This will now fail at compile time:

````
CHECK FAILED:
Calling 'foo' will never work with no arguments (line 2)
    Expected: :(Any $x)
````

It can also catch some simple cases of type errors. For example:

```` raku
sub foo(Str $s) { say $s }
foo(42)
````

Will also fail at compile time:

````
CHECK FAILED:
Calling 'foo' will never work with argument types (int) (line 2)
    Expected: :(Str $s)
````

It can handle some basic cases of this with multiple dispatch too.

### Propagating Type Information

If we know what routine we’re calling at compile time, we can take the declared return type of it and use it in further analysis. To give an example of how this aids failure analysis, consider the program:

```` raku
sub foo returns Int { 42 }
sub bar(Str $s) { say $s }
bar(foo)
````

This inevitable failure is detected at compile time now:

````
CHECK FAILED:
Calling 'bar' will never work with argument types (Int) (line 3)
    Expected: :(Str $s)
````

The real purpose of this is for inlining and compile time multi-dispatch resolution though; otherwise, we could never fully inline complex expressions like $x + $y * $z.

### Optimizing The Setting

Since we have loads of tests for the core setting (many of the spectests cover it), we compile it with –optimize=3. This means that a bunch of the built-ins will now perform better. We’ll doubtless be taking advantage of native types and other optimizations to further improve the built-ins.

### Gradual Typing

Many of these optimizations are a consequence of Raku being a gradually typed language. You don’t have to use types, but when you do, we make use of them to generate better code and catch more errors for you at compile time. After quite a while just talking about these possible wins, it’s nice to actually have some of them implemented. :-)

### The Future

Of course, this is just the start of the work – over the coming weeks and months, we should gain plenty of other optimizations. Some will focus on type-driven optimizations, others will not depend on this. And we’ll probably catch more of thsoe inevitable run time failures at compile time too. In the meantime, enjoy what we have so far. :-)
