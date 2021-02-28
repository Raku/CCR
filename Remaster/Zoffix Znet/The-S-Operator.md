# The S/// Operator
    
*Originally published on [28 April 2016](https://perl6.party//post/Perl-6-S---Substitution-Operator) by Zoffix Znet.*

Coming from a Perl background, my first experience with Raku's non-destructive substitution operator `S///` looked something like this:
![*(artist's impression)*](20160428-Substitutions.gif)

You'll fare better, I'm sure. Not only have the error messages improved, but I'll also explain everything right here and now.

## The Smartmatch

The reason I had issues is because, seeing familiar-looking operators, I simply translated Perl's *binding* operator (`=~`) to Raku's *smartmatch* operator (`~~`) and expected things to work. The `S///` was not documented and, combined with the confusing (at the time) warning message, this was the source of my pain:

```` raku
my $orig = 'meowmix';
my $new = $orig ~~ S/me/c/;
say $new;
# OUTPUT warning:
# Smartmatch with S/// can never succeed
````

The old warning suggests the `~~` operator is the wrong choice here and it is.  The `~~` isn't the equivalent of Perl's `=~`. It aliases the left hand side to `$_`, evaluates the right hand side, and then calls `.ACCEPTS($_)` on it. That is all there is to its magic.

So what's actually happening in the example above:

- By the time we get to `S///`, `$orig` is aliased to `$_````
- The `S///` non-destructively executes substitution on `$_` and <strong>returns the resulting string</strong>. This is what the smartmatch will operate on
- The smartmatch, following the [rules](http://docs.raku.org/routine/~~) for match of `Str` against `Str`, will give `True` or `False` depending on whether substitution happened (`True`, confusingly, meaning it didn't)

At the end of it all, we aren't getting what we actually want: the version of the string with substitution applied.

## With The Given

Now that we know that `S///` always works on `$_` and returns the result, it's easy to come up with *a whole bunch* of ways that set `$_` to our original string and gather back the return value of `S///`, but let's look at just a couple of them:

```` raku
my $orig = 'meowmix';
my $new = S/me/c/ given $orig;
say $orig;
say $new;
my @orig = <meow cow sow vow>;
my @new = do for @orig { S/\w+ <?before 'ow'>/w/ };
say @orig;
say @new;
# OUTPUT:
# meowmix
# cowmix
# [meow cow sow vow]
# [wow wow wow wow]
````

The first one operates on a single value. We use the postfix form of the `given` block, which lets us avoid the curlies (you can use `with` in place of `given` with the same results). From the output, you can see the original string remained intact.

The second example operates on a whole bunch of strings from an `Array` and we use the `do` keyword to execute a regular `for` loop (that aliases to `$_` in this case) and assign the result to the `@new` array. Again, the output shows the originals were not touched.

## Adverbs

The `S///` operator—just like `s///` and some methods—lets you use regex adverbs:

```` raku
given 'Lörem Ipsum Dolor Sit Amet' {
    say S:g      /m/g/;  # Löreg Ipsug Dolor Sit Aget
    say S:i      /l/b/;  # börem Ipsum Dolor Sit Amet
    say S:ii     /l/b/;  # Börem Ipsum Dolor Sit Amet
    say S:mm     /o/u/;  # Lürem Ipsum Dolor Sit Amet
    say S:nth(2) /m /g/; # Lörem Ipsug Dolor Sit Amet
    say S:x(2)   /m /g/; # Löreg Ipsug Dolor Sit Amet
    say S:ss/Ipsum Dolor/Gipsum\nColor/; # Lörem Gipsum Color Sit Amet
    say S:g:ii:nth(2) /m/g/; # Lörem Ipsug Dolor Sit Amet
}
````

As you can see, they are in the form of `:foo` that is added after the `S` part of the operator. You can use whitespace liberally and several adverbs can be used at the same time. Here are their meanings:

- `:g`—(long alternative: `:global`) global match: replace all occurances
- `:i`—case insentive match
- `:ii`—(long alternative: `:samecase`) preserve case: regardless of the case of letter used as a substitute, the original case of the letter being replaced will be used
- `:mm`—(long alternative: `:samemark`) preserve mark: in the example above, the diaeresis that was on letter `o` was preserved and applied to the replacement letter `u````
- `:nth(n)`—replace only `nth` occurance
- `:x(n)`—replace at most `n` occurances (mnemonic: "x as in times")
- `:ss`—(long alternative: `:samespace`) preserve space type: the type of whitespace character is preserved, regardless of whitespace characters used in the replacement string. In the example above, we replaced with a new line, but the original space was kept

## Method Form

Operator `S///` is nice, but using it is somewhat awkward at times. Don't fear, Raku provides `.subst` method for all your substitution needs and delightful `.subst`/`.substr` confusion. Here's what its use looks like:

```` raku
say 'meowmix'.subst: 'me', 'c';
say 'meowmix'.subst: /m./, 'c';
# OUTPUT:
# cowmix
# cowmix
````

The method takes either a regex or a plain string as the first positional argument, which is the thing it'll look for in its invocant. The second argument is the replacement string.

You can use the adverbs as well, by simply listing them as named `Bool` arguments, with a slight caveat. In `S///` form, adverbs `:ss` and `:ii` imply the presence of `:s` (make whitepsace significant) and `:i` (case-insensitive match) adverbs respectively.  In method form, you have to apply those to the regex itself:

```` raku
given 'Lorem Ipsum Dolor Sit Amet' {
    say .subst: /:i l/, 'b', :ii;
    say .subst: /:s Ipsum Dolor/, "Gipsum\nColor", :ss;
}
# OUTPUT:
# Borem Ipsum Dolor Sit Amet
# Lorem Gipsum Color Sit Amet
````

## Method Form Captures

Captures aren't alien to substitution operations, so let's try one out with the method call form of substitution:

```` raku
say 'meowmix'.subst: /me (.+)/, "c$0";
# OUTPUT:
# Use of Nil in string context  in block <unit> at test.p6 line 1
# c
````

Not quite what we were looking for. Our replacement string is constructed even before it reaches the `.subst` method and the `$0` variable inside of it actually refers to whatever it is before the method call, not the capture in the `.subst` regex. So how do we fix this?

The second argument to `.subst` can also take a [`Callable`](http://docs.raku.org/type/Callable). Inside of it, you can use the `$0, $1, ... $n` variables the way they were meant to and get correct values from captures:

```` raku
say 'meowmix'.subst: /me (.+)/, -> { "c$0" };
# OUTPUT:
# cowmix
````

Here, we've used a pointy block for our Callable, but WhateverCode and subs will work too. They will be called for each substitution, with the [`Match`](http://docs.raku.org/type/Match) object passed as the first positional argument, if you need to access it.

## Conclusion

The `S///` operator in Raku is the brother of `s///` operator that instead of modifying the original string, copies it, modifies, and returns the modified version. The way to use this operator differs from the way non-destructive substitution operator works in Perl. As an alternative, a method version `.subst` is available as well. Both method and operator form of substitution can take a number of adverbs that modify the behaviour of it, to suit your needs.
