# Raku Core Hacking: Wrong Address; Return To Sender
    
*Originally published on [14 September 2016](https://perl6.party//post/Perl-6-Core-Hacking-Wrong-Address-Return-To-Sender) by Zoffix Znet.*

Just as a Christmas present you mailed someone can get misplaced or misdelivered, so can the arguments be re-dispatched to the wrong method or lost entirely. Let's fix a couple of [Raku compiler](http://rakudo.org/) bugs involving just that. It's fun!

## Bug 1: Lost In Transit

The [first one](https://rt.perl.org/Public/Bug/Display.html?id=129242) involves the `.split` method and the different results produced, depending on whether it was called on a [`Str`](https://docs.raku.org/type/Str) object or on an [`Int`](https://docs.raku.org/type/Int):

```` raku
dd 123456.split("", :skip-empty)
# ("", "1", "2", "3", "4", "5", "6", "")
dd "123456".split("", :skip-empty)
# ("1", "2", "3", "4", "5", "6")
````

Even though we asked the .split to `:skip-empty` elements, it didn't do that for the `Int`. Let's see what piece of code gets called for each variant.

For that, you can use my [`CoreHackers::Sourcery` module](http://modules.raku.org/dist/CoreHackers::Sourcery) that I detailed [elsewhere](/post/Perl-6-Core-Hacking-Wheres-Da-Sauce-Boss), and that's also available for use via the `SourceBaby` IRC bot in [`#rakuev`](https://webchat.freenode.net/?channels=#raku-dev):
  
> **<Zoffix>** s: '123456', 'split', ("", :skip-empty)

> <SourceBaby> ** Zoffix, Sauce is at [https://github.com/rakudo/rakudo/blob/20ed9e2/src/core/Str.pm#L863](https://github.com/rakudo/rakudo/blob/20ed9e2/src/core/Str.pm#L863)

> **<Zoffix>** s: 123456, 'split', ("", :skip-empty)

> <SourceBaby>** Zoffix, Sauce is at [https://github.com/rakudo/rakudo/blob/20ed9e2/src/core/Cool.pm#L180](https://github.com/rakudo/rakudo/blob/20ed9e2/src/core/Cool.pm#L180)

The bot is triggered with the `s:` trigger and takes the arguments to give to the [`sourcery` subroutine](https://github.com/zoffixznet/rakuoreHackers-Sourcery#sourcery-1). In this case, the first argument is the object of interest, second is a string with the method name we want to call, and third argument is a [`Capture`](https://docs.raku.org/type/Capture) with arguments for that method.

The bot gave different places for each variant, so let's take a look at the sauce. First, the [working `Str` version](https://github.com/rakudo/rakudo/blob/20ed9e2/src/core/Str.pm#L863):

```` raku
multi method split(Str:D: Str(Cool) $match;;
    :$v is copy, :$k, :$kv, :$p, :$skip-empty) {
    ...
````

All good, the sub takes things and a bunch of named parameters that include the `:skip-empty` we are attempting to use. How does that compare to the [broken `Int` version](https://github.com/rakudo/rakudo/blob/20ed9e2/src/core/Cool.pm#L180):

```` raku
multi method split(Cool: Regex:D $pat, $limit = Inf;; :$all) {
    self.Stringy.split($pat, $limit, :$all);
}
multi method split(Cool: Cool:D $pat, $limit = Inf;; :$all) {
    self.Stringy.split($pat.Stringy, $limit, :$all);
}
````

Well, there's your problem! Calling `.split` on `Int` uses the [`Cool` candidate](https://docs.raku.org/type/Cool) that stringifies the invocant then calls its `.split` with the arguments it received... but it does a very poor job of it.

It's not taking our `:skip-empty` named argument—in fact, it takes none of the named args `Str.split` accepts—and a keen eye can also spot that there's no candidate to replicate [`Str.split` that takes a list of delimiters](https://github.com/rakudo/rakudo/blob/20ed9e2/src/core/Str.pm#L1083)

#### Fix It!

A naïve fix would be to replicate all of the `Str.split` candidates in `Cool`, but such duplication is exactly why this bug occured in the first place. If the job of the method is to simply make the invocant [`Stringy`](https://docs.raku.org/type/Stringy), that's all it should be doing.

We can stop caring what arguments we have if we use a [`Capture`](https://docs.raku.org/type/Capture), and so we'll replace all of the `Cool.split` candidates with just a single method:

```` raku
method split(Cool: |c) { self.Stringy.split(|c) }
````

The `|c` in the [`Signature`](https://docs.raku.org/type/Signature) creates a `Capture`. We then coerce the invocant to `Stringy` and call the `.split` method on the result, [slipping](https://docs.raku.org/type/Slip) that `Capture` in, which results in all of the arguments we received being sent to the `Str.split` as-is.

#### Test It!

No bug fix comes without a test for it, so we'll grab the [roast repo](https://github.com/raku/roast/) (it'll auto-clone to `t/spec/`if you run `make spectest`) and use `grep -R split .` to find where to put our tests into.

In this case, [`S32-str/split.t`](https://github.com/raku/roast/blob/25168ae7cfd822c8dc7ffdda7a7095a0de09abaa/S32-str/split.t) looks like the perfect fit. Pop the file open, increase the [`plan` number of planned tests to run](https://github.com/raku/roast/blob/25168ae7cfd822c8dc7ffdda7a7095a0de09abaa/S32-str/split.t#L7) by one, then at the end of the file add a [`subtest`](https://docs.raku.org/language/testing#index-entry-subtest-subtest%28%26subtests%2C_%24description%3F%29).  Subtests count as one test and function as a mini-test suite with their own plans.

Since now we know that all of the named arguments and even some positonals did not work on `Cool`, we need to test all of them. We'll make use of the [`is-deeply`](https://docs.raku.org/language/testing#index-entry-is-deeply-is-deeply%28%24value%2C_%24expected%2C_%24description%3F%29) test routine to which we'll give the result of our split and the expected list of elements we wish to receive, along with the test's description:

```` raku
# RT #129242
subtest '.split works on Cool same as it works on Str' => {
    plan 11;
    my $m = Match.new(
        ast => Any,    list => (), hash => Map.new(()),
        orig => "123", to => 2,    from => 1,
    );
    is-deeply 123.split('2', :v),  ('1', '2',      '3'), ':v; Cool';
    is-deeply 123.split(/2/, :v),  ('1', $m,       '3'), ':v; Regex';
    is-deeply 123.split('2', :kv), ('1', 0, '2',   '3'), ':kv; Cool';
    is-deeply 123.split(/2/, :kv), ('1', 0, $m,    '3'), ':kv; Regex';
    is-deeply 123.split('2', :p),  ('1', 0 => '2', '3'), ':p; Cool';
    is-deeply 123.split(/2/, :p),  ('1', 0 => $m,  '3'), ':p; Regex';
    is-deeply 123.split('2', :k),  ('1', 0,        '3'), ':k; Cool';
    is-deeply 123.split(/2/, :k),  ('1', 0,        '3'), ':k; Regex';
    is-deeply 4.split('',      :skip-empty), ('4',),     ':skip-empty; Cool';
    is-deeply 4.split(/<<|>>/, :skip-empty), ('4',),     ':skip-empty; Regex';
    is-deeply 12345.split(('2', /4/)), ("1", "3", "5"),  '@needles form';
}
````

Ensure our new test passes:

```` raku
make t/spec/S32-str/split.t
# ... lots of output ...
All PASS!
````

And now we need to ensure our fix did not break any of the other tests. Run the full spectest:

```` raku
TEST_JOBS=8 make spectest
# ... looooots of output ...
All PASS!
````

Wonderful. Both the test and the fix are ready to ship.

## Bug 2: Wrong Address; Return To Sender

Another [bugglet of the same category](https://rt.perl.org/Public/Bug/Display.html?id=129256) involves the creation of a `CArray` when using [NativeCall module](https://docs.raku.org/language/nativecall) included with Rakudo.  NativeCall lets you use C libraries directly in Raku, without requiring a C compiler, and `CArray` is a [representation of a C array](https://docs.raku.org/language/nativecall#Arrays).

The bug involves an edge case where an empty [`Positional`](https://docs.raku.org/type/Positional) passed as a source of values for the `CArray` ended up creating an infinite loop:

```` raku
use NativeCall;
CArray[uint8].new(())  # hangs
````

The author of the report was kind enough to include a small untested patch:

```` raku
--- a/lib/NativeCall/Types.pm6
+++ b/lib/NativeCall/Types.pm6
@@ -162,7 +162,7 @@ our class CArray is repr('CArray') is array_type(Pointer) {
     multi method `new` { nqp::create(self) }
     multi method new(*@values) { self.new(@values) }
     multi method new(@values) {
-        nextsame unless @values;
+        nextsame unless @values && @values.elems > 0;
         my $result := self.`new`;
         my int $n = @values.elems;
         my int $i;
````

While the suggested fix itself is a no-op—because an empty array is falsy, so explicitly checking its `.elems` doesn't add anything—it tells us the location of where the problematic code likely is, so let's pop [that file](https://github.com/rakudo/rakudo/blob/a9ed671/lib/NativeCall/Types.pm6#L164) open and locate the culprit:

```` raku
multi method `new` { nqp::create(self) }
multi method new(*@values) { self.new(@values) }
multi method new(@values) {
    nextsame unless @values;
    my $result := self.`new`;
    my int $n = @values.elems;
    my int $i;
    $result.ASSIGN-POS($n - 1, @values.AT-POS($n - 1));
    while $i < $n {
        $result.ASSIGN-POS($i, @values.AT-POS($i));
        $i = $i + 1;
    }
    $result;
}
````

We have three multi candidates:

- Candidate for no arguments
- Candidate for any number of arguments
- Candidate for one [`Positional`](https://docs.raku.org/type/Positional) argument

Our problematic case fits into the last candidate, which gets called with an empty `Positional` as `@values`. Right away, we detect that `@values` is empty and call [`nextsame`](https://docs.raku.org/language/functions#index-entry-nextsame-nextsame), which redispatches to the next candidate, using...  **the same arguments...**

While the idea was to end up calling the candidate that takes no arguments, we end up calling the second candidate with a slurpy `*@values`, which then obliges to make a call to a candidate with a single `Positional`, so we're back at square 1, with an empty `Positional` on our hands, ready to `nextsame` it again, to continue the infinite loop our bug is all about.

#### Fix It!

One way to fix this is to use [`nextwith`](https://docs.raku.org/language/functions#index-entry-nextwith-nextwith) with no arguments to land at the correct dispatch. However, since the slurpy candidate matches all the cases, my original approach involved getting rid of the re-dispatch maze entirely and just having a single method:

```` raku
method new(*@values) {
    return nqp::create(self) unless @values;
    my $result := self.`new`;
    my int $n = @values.elems;
    my int $i;
    $result.ASSIGN-POS($n - 1, @values.AT-POS($n - 1));
    while $i < $n {
        $result.ASSIGN-POS($i, @values.AT-POS($i));
        $i = $i + 1;
    }
    $result;
}
````

The slurpy takes any arguments. If none were given, it creates an empty array, otherwise proceeds to create one with the given elements. Since we made the change in a *module,* we don't need to recompile Rakudo, but simply need to explicitly tell Rakudo to look for that module in `lib/` directory with the `-I` switch.  Test the fix:

```` raku
$ ./raku -Ilib -MNativeCall -e 'CArray[uint8].new(()).elems.say'
0
````

Simple and brilliant... or is it?

Shortly after my commit went in, our resident optimization expert *Elizabeth Mattijsen* [pointed out](http://irclog.perlgeek.de/perl6-dev/2016-09-14#i_13208241) my version made things 600% slower for 1-positional-arg case, whereas having an explict candidate that shuttles the values has only a 16% overhead.

So she put the multies back in for performance and along the way also added a few extra optimizations by reducing the the number of  calls to `.elems` by saving the value (into `$n`) after the check, as well as using some [NQP ops](https://github.com/raku/nqp/blob/master/docs/ops.markdown) instead of pure Raku. Instead of redispatching the empty-Positional case, we simply call `nqp::create(self)` directly, just as we do it in the no-arg case:

```` raku
multi method `new` { nqp::create(self) }
multi method new(*@values) { self.new(@values) }
multi method new(@values) {
    if @values.elems -> $n {
        my int $elems = $n - 1;
        my $result   := nqp::create(self);  # XXX setelems would be nice
        $result.ASSIGN-POS($elems,@values.AT-POS($elems)); # fake setelems
        my int $i = -1;
        nqp::while(
          nqp::islt_i(($i = nqp::add_i($i,1)),$elems),
          $result.ASSIGN-POS($i,@values.AT-POS($i)),
        );
        $result
    }
    else {
        nqp::create(self)
    }
}
````

Bug fix AND perfomance improvement. Awesome!

#### Test It!

Once again, we need tests for the bug. Since NativeCall is not part of the Raku *language* specification, but a module included with Rakudo compiler, the test doesn't go into the [roast](https://github.com/raku/roast/), but into Rakudo's test suite.

The suite is part of the Rakudo's repo code and all the files live in `t/` (except for `t/spec`, which is where the roast gets cloned into during spectests). The NativeCall tests live in `t/04-nativecall/` and we are interested in [`t/04-nativecall/05-arrays.t`](https://github.com/rakudo/rakudo/blob/nom/t/04-nativecall/05-arrays.t) specifically.

Once again, bump [the planned number of tests](https://github.com/rakudo/rakudo/blob/43b4f3d02faff225ec0930f7a9fc3f31b3677986/t/04-nativecall/05-arrays.t#L8), then scroll to the bottom. Since we messed around with candidates, it's worth adding a test for each case to ensure the dispatch is still fine, along with no hanging happening any more:

```` raku
# RT #129256
{
    is CArray[uint8].new.elems, 0, 'creating CArray with no arguments works';
    is CArray[uint8].new(()).elems, 0,
        'creating CArray with () as argument does not hang';
    is-deeply CArray[uint8].new(1, 2, 3)[^3], (1, 2, 3),
        'creating CArray with several positionals works';
    my @arg = 1..3;
    is-deeply CArray[uint8].new(@arg)[^3], (1, 2, 3),
        'creating CArray with one Positional positional works';
}
````

We use the [`is` testing routine](https://docs.raku.org/language/testing#index-entry-is_testing) to check the element counts for argless and empty-arg case that used to hang and the [`is-deeply` routine](https://docs.raku.org/language/testing#index-entry-is-deeply-is-deeply%28%24value%2C_%24expected%2C_%24description%3F%29) to check the versions with arguments get created correctly.

Check the new test passes:

```` raku
make t/04-nativecall/05-arrays.t
# ... lots of output ...
All PASS!
````

And that all the other tests are still fine:

```` raku
make test
# ... looooots of output ...
All PASS!
TEST_JOBS=8 make spectest
# ... loooooooooots of output ...
All PASS!
````

And this finishes off another bug for the day. Job well done!

## Conclusion

Bugs that appear only with a specific crop of arguments or a specific type of an invocant may be due to incorrect dispatch. Ensure the correct candidates get called by examining the code and using [`CoreHackers::Sourcery` module](http://modules.raku.org/dist/CoreHackers::Sourcery)/SourceBaby robot to locate the called code.

When shuttling arguments, make use of [Captures](https://docs.raku.org/type/Capture) rather than duplicating individual arguments, but also keep in mind that a well-placed multi candidate can offer decent performance benefits.

Be sure to check out the [Raku's bug queue](http://rakudo.org/rt/open-all) for game to hunt. Happy fixing!

-Ofun
