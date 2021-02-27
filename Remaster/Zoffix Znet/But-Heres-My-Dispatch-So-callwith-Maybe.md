# But Here's My Dispatch, So callwith Maybe
    
*Originally published on [28 March 2017](https://perl6.party//post/Perl6-But-Heres-My-Dispatch-So-Callwith-Maybe) by Zoffix Znet.*

One of the great features of Raku is multi-dispatch. It lets you use the same name for your functions, methods, or [Grammar](https://docs.raku.org/language/grammars) tokens and let type of data they're dealing with to determine which version gets executed. Here's a [factorial](https://en.wikipedia.org/wiki/Factorial) postfix operator, implemented using two multies:

```` raku
multi postfix:<!> (0) { 1 }
multi postfix:<!> (UInt \n) { n × samewith n − 1 }
say 5!
# OUTPUT: 120
````

While the subject of multi-dispatch is broad and [there are some docs on it](https://docs.raku.org/language/functions#Multi-dispatch), there are 7 special routines I'd like to talk about that let you navigate the dispatch maze. They're
`nextwith`, `nextsame`, `samewith`, `callwith`, `callsame`, `nextcallee`, and `lastcall`.

## Setup The Lab

Multies get sorted from narrowest to widest candidate and when a multi is called, the binder tries to find a match and calls the first matching candidate. Sometimes, you may wish to call or simply move to the next matching candidate in the chain, optionally using different arguments. To observe effects of such operations, we'll use the following setup: 

```` raku
class Wide             { }
class Middle is Wide   { }
class Narrow is Middle { }
multi foo (Narrow $v) { say 'Narrow ', $v; 'from Narrow' }
multi foo (Middle $v) { say 'Middle ', $v; 'from Middle' }
multi foo (Wide   $v) { say 'Wide   ', $v; 'from Wide'   }
foo Narrow; # OUTPUT: Narrow (Narrow)
foo Middle; # OUTPUT: Middle (Middle)
foo Wide;   # OUTPUT: Wide   (Wide)
````

We have three classes, each inheriting from the previous one, so that way our `Narrow` class can fit into both `Middle` and `Wide` multi candidates; `rakuMiddle` can also fit into `Wide`, but not into `Narrow`; and `Wide` fits neither into `Middle` nor into `Narrow`. Remember that all classes in Raku are of type [`Any`](https://docs.raku.org/type/Any) as well, and so will fit into any candidate that accepts an [`Any`](https://docs.raku.org/type/Any).

For our [Callables](https://docs.raku.org/type/Callable.html), we use three multi candidates for routine `foo`: one for each of the classes.  In their bodies, we print what type of multi we called, along with the value that was passed as the argument. For their return value, we just use a string that tells us which multi the return value came from; we'll use these a bit later.

Finally, we make three calls to routine `foo`, using three type objects with our custom classes. From the output, we can see each of the three candidates got called as expected.

This is all plain and boring. However, we can spice it up! While inside of these routines we can call `nextwith`, `nextsame`, `samewith`, `rakucallwith`, or `callsame` to call another candidate with either the same or different arguments. But first, let's figure out which one does what...

## The Subject

The naming of the first five routines we'll examine follows this convention:

- `call____` — **call** next matching candidate in the chain and come back here
- `next____` — just go to **next** matching candidate in the chain and *don't* come back
- `____same` — use the **same** arguments as were used for current candidate
- `____with` — make the operation **with** these new arguments provided
- `samewith` — make the **same** call from scratch, following a new dispatch chain, **with** these new arguments, and come back

The `samesame` is not a thing, as that case is best replaced by a regular loop.  The main takeaway is "call" means you call the candidate and come back and use its return value or do more things; "next" means to just proceed to the next candidate and use its return value as the return value of the current candidate; while `same` and `with` at the end simply control whether you want to use the same args as were used for current candidate or provide a new set.

Let's play with these!

## It's all called the same...

The first routine we'll try out is `callsame`. It **call**s the next matching candidate with the **same** arguments that were used for the current candidate and returns that candidate's return value.

Let's modify our `Middle` candidate to call `callsame` and then print out its return value:

```` raku
class Wide             { }
class Middle is Wide   { }
class Narrow is Middle { }
multi foo (Narrow $v) { say 'Narrow ', $v; 'from Narrow' }
multi foo (Middle $v) {
    say 'Middle ', $v;
    my $result = callsame;
    say "We're back! The return value is $result";
    'from Middle'
}
multi foo (Wide   $v) { say 'Wide   ', $v; 'from Wide'   }
foo Middle;
# OUTPUT:
# Middle (Middle)
# Wide   (Middle)
# We're back! The return value is from Wide
````

We can now see that our single `foo` invocation resulted in two calls. First to `Middle`, since it's the type object we gave to our `foo` call. Then, to `Wide`, as that is the next candidate that can take a `Middle` type; in the output we can see that `Wide` was still called with our original `Middle` type object. Lastly, we returned back to our `Middle` candidate, with the `$result` variable set to `Wide` candidate's return value.

So far so clear, let's try modifying the arguments!

## Have you tried to call them with...

As we've learned, the `__with` variants let us use different args. We'll use the same code as in the previous example, except now we'll execute `callwith`, using the `Narrow` type object as the new argument:

```` raku
class Wide             { }
class Middle is Wide   { }
class Narrow is Middle { }
multi foo (Narrow $v) { say 'Narrow ', $v; 'from Narrow' }
multi foo (Middle $v) {
    say 'Middle ', $v;
    my $result = callwith Narrow;
    say "We're back! The return value is $result";
    'from Middle'
}
multi foo (Wide   $v) { say 'Wide   ', $v; 'from Wide'   }
foo Middle;
# OUTPUT:
# Middle (Middle)
# Wide   (Narrow)
# We're back! The return value is from Wide
````

The first portion of the output is clear: we still call `foo` with `Middle` and hit the `Middle` candidate first. However, something's odd with the next line. We used `Narrow` in `callwith`, so how come the `Wide` candidate got called with it and not the `Narrow` candidate?

The reason is that `call____` and `next____` routines use *the same dispatch chain* the original call followed. Since the `Narrow` candidate is narrower than `Middle` candidate, it was rejected and won't be considered in the current chain. The next candidate `callwith` will call will be the next candidate that matches **`Middle`**—and that's not a typo: `Middle` is the argument we used to initiate the dispatch and so the next candidate will be the one that can still take the arguments of that original call. Once it is found, the **new** arguments that were given to `callwith` will be bound to it, and it's your job to ensure they can be.

Let's see that in action with a bit more elaborate example.

## Kicking It Up a Notch

We'll expand our original base example with a few more multies and types:

```` raku
class Wide             { }
class Middle is Wide   { }
class Narrow is Middle { }
subset    Prime where     .?is-prime;
subset NotPrime where not .?is-prime;
multi foo (Narrow   $v) { say 'Narrow    ', $v; 'from Narrow'   }
multi foo (Middle   $v) { say 'Middle    ', $v; 'from Middle'   }
multi foo (Wide     $v) { say 'Wide      ', $v; 'from Wide'     }
multi foo (Prime    $v) { say 'Prime     ', $v; 'from Prime'    }
multi foo (NotPrime $v) { say 'Non-Prime ', $v; 'from NotPrime' }
foo Narrow; # OUTPUT: Narrow    (Narrow)
foo Middle; # OUTPUT: Middle    (Middle)
foo Wide;   # OUTPUT: Wide      (Wide)
foo 42;     # OUTPUT: Non-Prime 42
foo 31337;  # OUTPUT: Prime     31337
````

All three of our original classes are of type [`Any`](https://docs.raku.org/type/Any) and we also created two [`subset`](https://raku.party/post/Perl-6-Types--Made-for-Humans)s of [`Any`](https://docs.raku.org/type/Any): `Prime` and `NotPrime`. The `Prime` type-matches with numbers that are prime and `NotPrime` type-matches with numbers that are not prime or with types that don't have an [`.is-prime`](https://docs.raku.org/routine/is-prime) method. Since our three custom classes don't have it, they all type-match with `NotPrime`.

If we recreate the previous example in this new setup, we'll get the same output as before:

```` raku
class Wide             { }
class Middle is Wide   { }
class Narrow is Middle { }
subset    Prime where     .?is-prime;
subset NotPrime where not .?is-prime;
multi foo (Narrow   $v) { say 'Narrow    ', $v; 'from Narrow'   }
multi foo (Middle   $v) {
    say 'Middle    ', $v;
    my $result = callwith Narrow;
    say "We're back! The return value is $result";
    'from Middle'
}
multi foo (Wide     $v) { say 'Wide      ', $v; 'from Wide'     }
multi foo (Prime    $v) { say 'Prime     ', $v; 'from Prime'    }
multi foo (NotPrime $v) { say 'Non-Prime ', $v; 'from NotPrime' }
foo Middle;
# OUTPUT:
# Middle    (Middle)
# Wide      (Narrow)
# We're back! The return value is from Wide
````

The original call goes to `Middle` candidate, it `callwith` into `Wide```` candidate with the `Narrow` type object.

Now, let's mix it up a bit and `callwith` with `42` instead of `Narrow`. We *do* have a `NotPrime` candidate. Both `42` and the original `Middle` can fit into that candidate. And it's wider than the original `Middle` candidate, and so is still up in the dispatch chain. What could possibly go wrong!

```` raku
class Wide             { }
class Middle is Wide   { }
class Narrow is Middle { }
subset    Prime where     .?is-prime;
subset NotPrime where not .?is-prime;
multi foo (Narrow   $v) { say 'Narrow    ', $v; 'from Narrow'   }
multi foo (Middle   $v) {
    say 'Middle    ', $v;
    my $result = callwith 42;
    say "We're back! The return value is $result";
    'from Middle'
}
multi foo (Wide     $v) { say 'Wide      ', $v; 'from Wide'     }
multi foo (Prime    $v) { say 'Prime     ', $v; 'from Prime'    }
multi foo (NotPrime $v) { say 'Non-Prime ', $v; 'from NotPrime' }
foo Middle;
# OUTPUT:
# Middle    (Middle)
# Type check failed in binding to $v; expected Wide but got Int (42)
#   in sub foo at z2.p6 line 15
#   in sub foo at z2.p6 line 11
#   in block <unit> at z2.p6 line 19
````

Oh, right, that! The new arguments we gave to `callwith` *do not affect the dispatch,* so despite there being a candidate that can handle our new arg further up the chain, it's not the **next** candidate that can handle **the original args**, which is what `callwith` calls. The result is throwage due to failed binding of our new args to the... next callee...

## Who's Next?

The handy little routine that lets us grab the next matching candidate up the dispatch chain is `nextcallee`. Not only it returns the `Callable` for that candidate, it shifts it off the chain, so that the next `next____` and `call____` will go the next-next candidate, and the next `nextcallee` call will shift-off and return the next-next candidate.  So... let's go back to our previous example and cheat a bit!

```` raku
class Wide             { }
class Middle is Wide   { }
class Narrow is Middle { }
subset    Prime where     .?is-prime;
subset NotPrime where not .?is-prime;
multi foo (Narrow   $v) { say 'Narrow    ', $v; 'from Narrow'   }
multi foo (Middle   $v) {
    say 'Middle    ', $v;
    nextcallee;
    my $result = callwith 42;
    say "We're back! The return value is $result";
    'from Middle'
}
multi foo (Wide     $v) { say 'Wide      ', $v; 'from Wide'     }
multi foo (Prime    $v) { say 'Prime     ', $v; 'from Prime'    }
multi foo (NotPrime $v) { say 'Non-Prime ', $v; 'from NotPrime' }
foo Middle;
# OUTPUT:
# Middle    (Middle)
# Non-Prime 42
# We're back! The return value is from NotPrime
````

Aha! It works! The code is almost entirely the same. The only change is we popped `nextcallee` call right before our `callwith` call. It shifted off the `Wide` candidate that couldn't handle the new `42` arg, and so, as can be seen from the output, our call went into `NotPrime` candidate.

The `nexcallee` is finicky and so looping with it is a challenge, since it'd use the loop's or thunk's dispatcher to look for callees in. So the most common and saner way to use it is to just get the... next callee. You'd primarily need to do that if you need to pass the next callee around, e.g. in:

```` raku
multi pick-winner (Int \s) {
    my &nextone = nextcallee;
    Promise.in(π²).then: { nextone s }
}
multi pick-winner { say "Woot! $^w won" }
with pick-winner ^5 .pick -> \result {
    say "And the winner is...";
    await result;
}
# OUTPUT:
# And the winner is...
# Woot! 3 won
````

The `Int` candidate takes the `nextcallee` and then fires up a [`Promise`](https://docs.raku.org/language/concurrency) to be executed in parallel, after some timeout, and then returns. We can't use `nextsame` here, because it'd be trying to `nextsame` the Promise's block instead of our original routine, and so, the `nextcallee` saves the day.

I think we've reached the summit of convoluted examples now and I can hear cries in the audience. "What's this stuff's good for, anyway? Just make more subs instead of messing with multies!" So, let's take a look at more real-worldish examples as well as meet the `nextsame` and `nextwith`!

## Next one in line, please

Let's make a class! A class that does Things!

```` raku
role Things {
    multi method do-it ($place) {
        say "I am {<eating  sleeping  coding  weeping>.pick} at $place"
    }
}
class Doer does Things { }
Doer.do-it: 'home' # OUTPUT: I am coding at home
````

We can't touch the [`role`](https://docs.raku.org/language/objects#Roles), since someone else made it for us and they like it the way it is. However, we want our class to do more! For some `$place`s, we want it to tell us something more specific. In addition, if the place is ```` raku'my new place'` we want to tell which of our places we consider new. Here's the code:

```` raku
role Things {
    multi method do-it ($place) {
        say "I am {<eating  sleeping  coding  weeping>.pick} at $place"
    }
}
class Doer does Things {
    multi method do-it ($place where .contains: 'home' ) {
        nextsame if $place.contains: 'large';
        nextwith "home with $<color> roof"
            if $place ~~ /$<color>=[red | green | blue]/;
        samewith 'my new place';
    }
    multi method do-it ('my new place') {
        nextwith 'red home'
    }
}
Doer.do-it: 'the bus';       # OUTPUT: I am eating at the bus
Doer.do-it: 'home';          # OUTPUT: I am sleeping at red home
Doer.do-it: 'large home';    # OUTPUT: I am sleeping at large home
Doer.do-it: 'red home';      # OUTPUT: I am eating at home with red roof
Doer.do-it: 'some new home'; # OUTPUT: I am eating at red home
Doer.do-it: 'my new place';  # OUTPUT: I am coding at red home
````

With a little bit of extra code and without making a single change in the role that provides the method, we added a whole bunch of new functionality.  Let's examine the three new dispatch-altering routines we've used.

The `nextsame` and `nextwith` function very similar to their `callsame` and `callwith` counterparts, except **they don't come back** to where they were called and their return value will be used as the return value of the current routine. So using `nextsame` is like using `return callsame`, but with less typing and with the compiler being able to do more optimizations.

Our first multi method we added to the class gets dispatched to when the `$place` [`.contains`](https://docs.raku.org/routine/contains) word `home`.  In the method's body, if `$place` also [`.contains`](https://docs.raku.org/routine/contains) word `large`, we use `nextsame`—that is, call the *next* matching candidate with the same argument as the current method. This is the key here. We can't just call our method all over again, since it'd enter an infinite loop redispatching to itself. However, since `nextsame` uses the next candidate in the same dispatch chain, no loop occurs, and we get to the candidate in `role Things` just fine.

Further down in the code, we also take `nextwith` for a spin. We use it when `$place` mentions one of three colours. Similar to `nextsame`, it goes to the next candidate, except we give it a new argument to use.

Lastly, we come to `samewith`. Unlike the routines we've used earlier, this one **restarts** the dispatch from scratch, so it's basically like calling the method again, except you don't have to know or use the actual name of it.  We call `samewith` with a new set of arguments to use, and from the output we can see the new dispatch path took it via the second multi we added to our class, instead of continuing from the role's multi as our `next____` versions did.

## Last Call!

The last method in the bag of tricks is `lastcall`. Calling it truncates the current dispatch chain, so that `next____` and `call____` routines won't have anything else to go to. Here's an example:

```` raku
multi foo (Int $_) {
    say "Int: $_";
    lastcall   when *.is-prime;
    nextsame   when *  %% 2;
    samewith 6 when * !%% 2;
}
multi foo (Any $x) { say "Any $x" }
foo 6; say '----';
foo 2; say '----';
foo 1;
# OUTPUT:
# Int: 6
# Any 6
# ----
# Int: 2
# ----
# Int: 1
# Int: 6
# Any 6
````

All of our invocations to `foo` go to the `Int` candidate first. When the number [`.is-prime`](https://docs.raku.org/routine/is-prime), we invoke `lastcall`; when it's an even number, we invoke `nextsame`; and when it's an odd number, we invoke `samewith```` using `6` as the argument.

The first number we call `foo` with is `6`, which isn't prime, so `lastcall` is never called. It is an even number, so we invoke `nextsame` and from the output we see that we've reached the [`Any`](https://docs.raku.org/type/Any) candidate.

Next, when we invoke `foo` with `2`, which is both a prime and an even number, we call `lastcall` and `nextcall`. However, *because* `lastcall` was called and truncated the dispatch chain, `nextcall` never sees the [`Any`](https://docs.raku.org/type/Any) candidate and so we only have the call to [`Int`](https://docs.raku.org/type/Int) candidate in the output.

In the last example, we again use a prime number, so `lastcall` gets called once more. However, the number is an odd number, so we use `samewith` instead of `nextwith`. Since `samewith` re-dispatches from scratch, it doesn't care that we truncated the previous chain with `lastcall`. And so, the output shows we go through [`Int`](https://docs.raku.org/type/Int) candidate twice, with the second call using `nextsame```` to reach the [`Any`](https://docs.raku.org/type/Any) candidate, since the number we used with `samewith` is not a prime and is even.

## Wrapping It Up

To wrap up this article, we'll examine another area where the routines
we've learned about can come in handy: the wrapping of stuff! Here's the code:

```` raku
use soft;
sub meower (\ッ, |c) {
    nextwith "🐱 says {ッ}", |c when ッ.gist.contains: 'meow';
    nextsame
}
&say.wrap: &meower;
say 'chirp';
say 'moo';
say 'meows!';
# OUTPUT:
# chirp
# moo
# 🐱 says meows!
````

We use the `soft` pragma to disable inlining so our wrapping is sane. We have a `meower` sub that modifies the first argument with `nextwith` if it [`.contains`](https://docs.raku.org/routine/contains) word `meow`, passing along the rest of the arguments, if any, unmodified via a [`Capture`](https://docs.raku.org/type/Capture) (that's the `|c` bit). All the rest of the calls are passed as is, using `nextsame`. We [`.wrap`](https://docs.raku.org/routine/wrap) the `meower` onto the [`say`](https://docs.raku.org/routine/say) routine and, as we can see from the output, everything works as advertised.

Here's the key feature of this code: the `meower` **has no idea what sub it's being wrapped onto!** However, it still manages to call it without problems.

Here, we wrap it around [`put`](https://docs.raku.org/routine/put) routine instead, and it works just fine without any changes:

```` raku
use soft;
sub meower (\ッ, |c) {
    nextwith "🐱 says {ッ}", |c when ッ.gist.contains: 'meow';
    nextsame
}
&put.wrap: &meower;
put 'chirp';
put 'moo';
put 'meows!';
# OUTPUT:
# chirp
# moo
# 🐱 says meows!
````

## Conclusion

Today, we've learned about powerful routines that let you re-use existing multi candidates from within other candidates. The `callsame` and `callwith` let you call the next matching candidate in the current dispatch chain, either using the same arguments or a new set. The `nextsame` and `nextwith` accomplish the same, without returning back to the callsite.

The `samewith` sub lets you restart the dispatch chain from the start, without having to know the name of the current routine. While `lastcall` and `nextcallee` let you manipulate the current dispatch chain by truncating it, or shifting and manipulating the next callee.

Put them to good use!

-Ofun
