# Wrap and unwrap
    
*Originally published on [8 June 2009](https://use-perl.github.io/user/JonathanWorthington/journal/39100/) by Jonathan Worthington.*

A while back, I did a Rakudo day and didn't get around to writing a report (probably because I hacked until the point where all I wanted to do was sleep). The main thing I did on that day was implement `.wrap` and `.unwrap`, which I'm going to talk about in this post.

The `.wrap` method on a routine allows you to modify it in place, giving it some extra behaviors before (optionally) delegating or calling the original. This allows for pre-processing of arguments, post-processing of return values, logging and so forth.

Here is a simple example.

```` raku
sub do_some_work { say "doing stuff" }

do_some_work;
say "--";

my $handle = &do_some_work.wrap(sub () {
    say "About to do some work";
    `callsame`;
    say "Finished doing some work";
});
do_some_work;
say "--";

&do_some_work.unwrap($handle);
do_some_work;
````

So, first we take a sub and call it. The result is just as you would expect. Then we wrap it with another sub - an anonymous one. We could have used a closure or pointy block here too. This some uses `callsame` to call the original sub. If we had any arguments passed in, it would have passed the same arguments along. You can use `callwith` instead to supply a different set of arguments, if you had done some pre-processing on the arguments and wanted to pass along the modifications. Calling `.wrap` gives us back a handle. If we want to remove the wrapper that we installed, we simply call unwrap on the routine, passing the handle, and the wrapper is removed. So the output of this program is:

```` raku
doing stuff
--
About to do some work
doing stuff
Finished doing some work
--
doing stuff
````

Let's take a look at a second example.

```` raku
sub foo { say 1 }

foo;
say "--";

my $h1 = &foo.wrap({ say 2; nextsame; say "not here"; });
foo;
say "--";

my $h2 = &foo.wrap({ say 3; nextsame; say "nor here"; });
foo;
say "--";

&foo.unwrap($h1);
`foo`;
say "--";

&foo.unwrap($h2);
foo;
````

This time, we do a couple of things differently. We use the `nextsame` function instead of `callsame`. `nextsame` defers rather than calls, so after calling `nextsame` we are never inside the current routine again. Thus the "not here"/"nor here" say statements will never be executed. Secondly, we unwrap in a different order than we wrapped. This demonstrates the use of out-of-order unwrapping, meaning you can add and remove behaviors as you wish without having to worry where in the list of wrappers they are. The output of this program is:

```` raku
1
--
2
1
--
3
2
1
--
3
1
--
1
````

We also have tests passing where we wrap and unwrap in loops, applying the same closure as a wrapper many times, which also works.

Since doing the initial cut of wrapping on a Rakudo Day, I have further improved and refactored `.wrap` and `.unwrap` as a part of the changes in my current Hague Grant. While there's some more edge cases that need checking out and testing, we now pass just about all of the tests for wrapping (those we don't are related to the interaction between wrap and temp, and we don't have temp yet in Rakudo). So, looking pretty good.

Thanks to Vienna.pm for sponsoring the Rakudo Day that saw us get wrap support.
