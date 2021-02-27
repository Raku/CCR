# Hacking on The Rakudo Raku Compiler: Mix Your Fix
    
*Originally published on [1 August 2016](https://perl6.party//post/Hacking-on-Rakudo-Perl-6-Compiler-Mix-Your-Fix) by Zoffix Znet.*

While testing a fix for one of the Less Than Awesome behaviours in standalone [`Signature`](https://docs.raku.org/type/Signature) objects, I came across a bugglet. Smartmatching two Signatures throws, while spilling a bit of the guts:
  
> <Zoffix> m: my $m = method ($a: $b) { }; say $m.signature ~~ :($a, $b);
>  <camelia> rakudo-moar 46838d: OUTPUT«Method 'type' not found for invocant of class 'Any'␤  in block <unit> at <tmp> line 1␤␤»

So I figured I'll write about fixing it, 'cause hacking on internals is lots of fun. Let's roll!

## Golf It Down

The less code there is to reproduces the bug, the fewer places there are for that bug to hide. We have a detached method and then we smartmatch its signature against something else. Let's try to golf it down a bit and smartmatch two Signatures, without involving a method:
  
> <Zoffix> m: :($a, $b) ~~ :($a, $b);
>  <camelia> rakudo-moar 46838d: ( no output )

The bug disappeared, so perhaps our `Signature` on the left doesn't contain the stuff that triggers the bug. Let's dump the signature of the method to see what we should match against:
  
> <Zoffix> m: my $m = method ($a: $b) { }; say $m.signature
>   <camelia> rakudo-moar 46838d: OUTPUT«`($a: $b, *%_)␤`»

Aha! It has a slurpy hash: `*%_`. Let's try matching a Signature with a slurpy in it:
  
> <Zoffix> m: `:(*%) ~~ :();`
>   <camelia> rakudo-moar 46838d: OUTPUT«Method 'type' not found for invocant of class 'Any'␤  in block <unit> at <tmp> line 1␤␤»

And there we go: hole in three. Let's proceed.

## Roast It

There's [an official Raku test suite](https://github.com/raku/roast) that Rakudo must pass to be called a Raku compiler. Since we got a bug on our hands, we should add a test for it to the test suite to ensure it doesn't rear its ugly head again.

The copy of the repo gets automatically cloned into `t/spec` when you run `make spectest` in [Rakudo's checkout](https://github.com/rakudo/rakudo).  If you don't have a commit bit, you can just change the remote/branch of that checkout to your fork:

```` raku
cd t/spec
git remote rm origin
git remote add origin https://github.com/YOURUSERNAME/roast
git checkout your-branch
cd ../..
````

It may be tricky to figure out which file to put the test in, if you're new.  You can always ask the good folks on [irc.freenode.net/#raku](irc://irc.freenode.net/#raku) for advice. In this case, I'll place the test into `S06-signature/outside-subroutine.t`

While not required, I find it helpful to open a ticket for the bug. This way I can reference it in my fix in the compiler repo, I can reference it in the commit to the test repo, and people get a place where to tell me why I'm being stupid when I am. I opened this bug as [RT#128795](https://rt.perl.org/Ticket/Display.html?id=128795).

Now, for the code of the test itself.  I'll adjust the `plan` at the top of the file to include however many tests I'm writing—in this case one. I'll use the [`lives-ok`](https://docs.raku.org/language/testing#index-entry-lives-ok-lives-ok%28%24code%2C_%24description%3F%29) test sub and stick our buggy golfed code into it. Here's the `diff` of the changes to the file; note the reference to the ticket number in the comment before the test:

```` raku
@@ -1,7 +1,7 @@
  use v6;
  use Test;
 -plan 3;
 +plan 4;
  # RT #82946
  subtest 'signature binding outside of routine calls' => {
 @@ -25,4 +25,7 @@ subtest 'smartmatch on signatures with literal strings' => {
  # RT #128783
  lives-ok { EVAL ’:($:)‘ }, ’signature marker is allowed in bare signature‘;
 +# RT #128795
 +lives-ok { :(*%)~~ :() }, 'smartmatch with no slurpy on right side';
 +
  # vim: ft=raku
````

Run the file now to ensure the test fails. Hint: some files have fudging; explaining it is out of the scope of this article, but if you notice failures you're not expecting, look it up.

```` raku
$ make t/spec/S06-signature/outside-subroutine.t
...
Test Summary Report
-------------------
t/spec/S06-signature/outside-subroutine.t (Wstat: 256 Tests: 4 Failed: 1)
  Failed test:  4
  Non-zero exit status: 1
````

With the test in place, it's time to look at some source code. Let the bug hunt begin!

## Make it Saucy

Our bug involves a Smartmatch operator, which aliases the left side to the topic variable `$_` and calls `.ACCEPTS` method on the right side with it. Both of our sides are `Signature` objects, so let's pop open Rakudo's sauce code for that class.

In [the Rakudo's repo](https://github.com/rakudo/rakudo), directory `src/core.c/` contains most of the built in types in separate files named after those types, so we'll just pop open [`src/core.c/Signature.pm6`](https://github.com/rakudo/rakudo/blob/nom/src/core.c/Signature.pm6) in the editor and locate the definition of method `ACCEPTS`.

There are actually four multis for `ACCEPTS`. Here's the full code. Don't try to understand all of it, just note its size.

```` raku
multi method ACCEPTS(Signature:D: Capture $topic) {
    nqp::p6bool(nqp::p6isbindable(self, nqp::decont($topic)));
}
multi method ACCEPTS(Signature:D: @topic) {
    self.ACCEPTS(@topic.Capture)
}
multi method ACCEPTS(Signature:D: %topic) {
    self.ACCEPTS(%topic.Capture)
}
multi method ACCEPTS(Signature:D: Signature:D $topic) {
    my $sclass = self.params.classify({.named});
    my $tclass = $topic.params.classify({.named});
    my @spos := $sclass{False} // ();
    my @tpos := $tclass{False} // ();
    while @spos {
        my $s;
        my $t;
        last unless @tpos && ($t = @tpos.shift);
        $s=@spos.shift;
        if $s.slurpy or $s.capture {
            @spos=();
            @tpos=();
            last;
        }
        if $t.slurpy or $t.capture {
            return False unless any(@spos) ~~ {.slurpy or .capture};
            @spos=();
            @tpos=();
            last;
        }
        if not $s.optional {
            return False if $t.optional
        }
        return False unless $t ~~ $s;
    }
    return False if @tpos;
    if @spos {
        return False unless @spos[0].optional or @spos[0].slurpy or @spos[0].capture;
    }
    for flat ($sclass{True} // ()).grep({!.optional and !.slurpy}) -> $this {
        my $other;
        return False unless $other=($tclass{True} // ()).grep(
            {!.optional and $_ ~~ $this });
        return False unless +$other == 1;
    }
    my $here=($sclass{True}:v).SetHash;
    my $hasslurpy=($sclass{True} // ()).grep({.slurpy});
    $here{@$hasslurpy} :delete;
    $hasslurpy .= Bool;
    for flat @($tclass{True} // ()) -> $other {
        my $this;
        if $other.slurpy {
            return False if any($here.keys) ~~ -> Any $_ { !(.type =:= Mu) };
            return $hasslurpy;
        }
        if $this=$here.keys.grep( -> $t { $other ~~ $t }) {
            $here{$this[0]} :delete;
        }
        else {
            return False unless $hasslurpy;
        }
    }
    return False unless self.returns =:= $topic.returns;
    True;
}
````

The error we get from the bug mentions `.type` method call and there is one such method call in the code above (close to the end of it). In this case, there's quite a bit of code to sort through. It would be nice to be able to play around with it, stick a couple of `dd` or `say` calls to dump out variables, right?

That approach, however, is somewhat annoying because after each change we have to recompile the entire Rakudo. On the meatiest box I got, it takes about 60 seconds. Not the end of the world, but there's a way to make things lightning fast!

## Mix Your Fix

We need to fix a bug in a method of a class. Another way to think of it is: we need to *replace* a broken method with a working one. `Signature` class is just like any other class, so if we want to replace one of its methods, we can just mix in a role!

The broken `ACCEPTS` will continue to live in the compiler, and we'll pop open a separate playground file and define a role—let's calls it `FixedSignature`—in it.  To get our new-and-improved `ACCEPTS` method in standalone signature objects, we'll use the `but` operator to mix the `FixedSignature` in.

Here's the role, the mixing in, and the code that triggers the bug. I'll leave out method bodies for brieviety, but there's they are the same as in the code above.

```` raku
role FixedSignature {
    multi method ACCEPTS(Signature:D: Capture $topic)     { #`(redacted for brevity) }
    multi method ACCEPTS(Signature:D: @topic)             { #`(redacted for brevity) }
    multi method ACCEPTS(Signature:D: %topic)             { #`(redacted for brevity) }
    multi method ACCEPTS(Signature:D: Signature:D $topic) { #`(redacted for brevity) }
}
my $a = :(*%) but FixedSignature;
my $b = :()   but FixedSignature;
say $a ~~ $b;
````

There are two more things we need to do for our role to work properly.  First, we're dealing with multis and right now the multis in our role are creating ambiguities with the multis in the original `Signature` class.  To avoid that, we'll define a proto:

```` raku
proto method ACCEPTS (|) { * }
````

Since the code is using some NQP, we also need to bring in those features into our playground file with the role. Just add the appropriate pragma at the top of the file:

```` raku
use MONKEY-GUTS;
````

With these modifications, our final test file becomes the following:

```` raku
use MONKEY-GUTS;
role FixedSignature {
    proto method ACCEPTS (|) { * }
    multi method ACCEPTS(Signature:D: Capture $topic)     { #`(redacted for brevity) }
    multi method ACCEPTS(Signature:D: @topic)             { #`(redacted for brevity) }
    multi method ACCEPTS(Signature:D: %topic)             { #`(redacted for brevity) }
    multi method ACCEPTS(Signature:D: Signature:D $topic) { #`(redacted for brevity) }
}
my $a = :(*%) but FixedSignature;
my $b = :()   but FixedSignature;
say $a ~~ $b;
````

And with this trick in place, we now have a rapid-fire weapon to hunt down the bug with—the changes we make compile instantly.

## Pull The Trigger

Now, we can debug the code just like any other. I prefer applying liberal amounts of `dd` (or `say`) calls and dumping out the variables to ensure their contents match expectations.

The `.type` method call our error message mentions is in this line:

```` raku
return False if any($here.keys) ~~ -> Any $_ { !(.type =:= Mu) };
````

It calls it on the keys of `$here`, so let's dump the `$here` before that
statement:

```` raku
...
dd $here
return False if any($here.keys) ~~ -> Any $_ { !(.type =:= Mu) };
...
# OUTPUT:
# SetHash $here = SetHash.new(Any)
````

Here's our offending `Any`, let's go up a bit and dump the `$here` right where it's defined:

```` raku
...
my $here=$sclass{True}.SetHash;
dd $here;
...
# OUTPUT:
# SetHash $here = SetHash.new(Any)
````

It's still there, and for a good reason. If we trace the creation of `$sclass`, we'll see it's this:

```` raku
my $sclass = self.params.classify({.named});
````

The params of the Signature on the right of the smartmatch get classified based on whether they are named or not. The named parameters will be inside a list under the `True` key of `$sclass`. Since we do *not* have any named params, there won't be such a key, and we can verify that with this bit of code:

```` raku
:().params.classify(*.named).say
# OUTPUT:
# {}
````

When we go to define `$here`, we get an `Any` from `$sclass{True}`, since that key doesn't exist, and when we call `.SetHash` on it, we get our problematic `Sethash` object with an `Any` in it. And so, we have our fix for the bug: ensure the `True` key in `$sclass` is actually there before creating a `SetHash` out of its value:

```` raku
my $here=($sclass{True}:v).SetHash;
````

Add that to our playground file with the `FixedSignature` role in it, run it, and verify the fix works. Now, simply transplant the fix back into [`src/core.c/Signature.pm6`](https://github.com/rakudo/rakudo/blob/nom/src/core.c/Signature.pm6) and then compile the compiler.

```` raku
perl Configure.pl --gen-moar --gen-nqp --backends=moar
make
make test
make install
````

Verify our fix worked before we proceed onto the final stages:

```` raku
$ make t/spec/S06-signature/outside-subroutine.t
...
All tests successful.
Files=1, Tests=4,  1 wallclock secs ( 0.03 usr  0.00 sys +  0.32 cusr  0.02 csys =  0.37 CPU)
Result: PASS
````

## A Clean Kill

So far, all we know is the bug we found was fixed and the tests we wrote for it pass. However, before we ship our fix, we must ensure we didn't break anything else. There are other devs working from the same repo and you'll be interfering with their work if you break stuff.

Run the full Roast test suite with `make spectest` command.  You can use the `TEST_JOBS` environmental variable to specify the number of simultaneous tests. Generally a value slightly higher than the available cores works the fastest... and cores make all the difference. On my 24-core VM I cut releases on, the spectest completes in about 1 minute and 15 seconds. On my 2-core web server, it takes about 25 minutes. You get the idea.

```` raku
TEST_JOBS=28 make spectest
...
All tests successful.
Files=1111, Tests=52510, 82 wallclock secs (13.09 usr 2.44 sys + 1517.34 cusr 97.67 csys = 1630.54 CPU)
Result: PASS
````

Once the spectest completes and we have the clean bill of health, we're ready to ship our fix. Commit the Rakudo fix, then go into `t/spec` and commit the Roast fix:

````
git commit -m 'Fix Smartmatch with two signatures, only one of which has slurpy hash' \
           -m 'Fixes RT#128795' src/core/Signature.pm
git push
cd t/spec
git commit -m 'smartmatch on signature with no slurpy on right side does not crash' \
           -m 'RT#128795' S06-signature/outside-subroutine.t
git push
````

If you're pushing to your fork of these projects, you have to go the extra step and submit a Pull Request (just go to your fork and GitHub should display a button just for that).

And we're done! Celebrate with the appropriate amount of fun.

## Conclusion

Rakudo bugs can be easy to fix, requiring not much more than knowledge of Raku. To fix them, you don't need to re-compile the entire compiler, but can instead define a small role with a method you're trying to fix and modify and recompile just that.

It's important to add tests for the bug into the official test suite and it's also important to run the full spectest after you fix the bug. But most important of all, is to have fun fixing it.

-Ofun
