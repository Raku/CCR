# Raku: Seqs, Drugs, And Rock'n'Roll
    
*Originally published on [20 June 2017](https://perl6.party//post/Perl-6-Seqs-Drugs-and-Rock-n-Roll) by Zoffix Znet.*

I vividly recall my first steps in Raku were just a couple of months before the first stable release of the language in December 2015. Around that time, Larry Wall was making a presentation and showed a neat feature—the sequence operator—and it got me amazed about just how powerful the language is:

```` raku
# First 12 even numbers:
say (2, 4 … ∞)[^12];      # OUTPUT: (2 4 6 8 10 12 14 16 18 20 22 24)
# First 10 powers of 2:
say (2, 2², 2³ … ∞)[^10]; # OUTPUT: (2 4 8 16 32 64 128 256 512 1024)
# First 13 Fibonacci numbers:
say (1, 1, *+* … ∞)[^13]; # OUTPUT: (1 1 2 3 5 8 13 21 34 55 89 144 233)
````

The ellipsis (`…`) is the sequence operator and the stuff it makes is the [`Seq`](https://docs.raku.org/type/Seq) object. And now, a year and a half after Raku's first release, I hope to pass on my amazement to a new batch of future Raku programmers.

This is a 3-part series. In PART I of this article we'll talk about what [`Seq`](https://docs.raku.org/type/Seq) s are and how to make them without the sequence operator. In PART II, we'll look at the thing-behind-the-curtain of [`Seq`'s](https://docs.raku.org/type/Seq): the [`Iterator`](https://docs.raku.org/type/Iterator) type and how to make [`Seq`s](https://docs.raku.org/type/Seq) from our own [`Iterator`s](https://docs.raku.org/type/Iterator). Lastly, in PART III, we'll examine the sequence operator in all of its glory.

Note: I will be using all sorts of fancy Unicode operators and symbols in this article. If you don't like them, consult with the [Texas Equivalents page](https://docs.raku.org/language/unicode_texas) for the equivalent ASCII-only way to type those elements.

## PART I: What the `Seq` is all this about?

The [`Seq`](https://docs.raku.org/type/Seq) stands for *Sequence* and the [`Seq`](https://docs.raku.org/type/Seq) object provides a one-shot way to iterate over a sequence of stuff. New values can be generated on demand—in fact, it's perfectly possible to create infinite sequences—and already-generated values are discarded, never to be seen again, although, there's a way to cache them, as we'll see.

Sequences are driven by [`Iterator`](https://docs.raku.org/type/Iterator) objects that are responsible for generating values. However, in many cases you don't have to create [`Iterator`](https://docs.raku.org/type/Iterator)s directly or use their methods while iterating a [`Seq`](https://docs.raku.org/type/Seq). There are several ways to make a [`Seq`](https://docs.raku.org/type/Seq) and in this section, we'll talk about [`gather`](https://docs.raku.org/syntax/gather%20take)/[`take`](https://docs.raku.org/routine/take) construct.

## I `gather` you'll `take` us to...

The [`gather`](https://docs.raku.org/syntax/gather%20take) statement and [`take`](https://docs.raku.org/routine/take) routine are similar to "generators" and "yield" statement in some other languages:

```` raku
my $seq-full-of-sunshine := gather {
    say  'And nobody cries';
    say  'there’s only butterflies';
    take 'me away';
    say  'A secret place';
    say  'A sweet escape';
    take 'meee awaaay';
    say  'To better days'    ;
    take 'MEEE AWAAAAYYYY';
    say  'A hiding place';
}
````

Above, we have a code block with lines of [song lyrics](https://www.youtube.com/watch?v=0btXhLdAuAc), some of which we [`say`](https://docs.raku.org/routine/say) (print to the screen) and others we [`take`](https://docs.raku.org/routine/take) (to be [`gather`](https://docs.raku.org/syntax/gather%20take)ed). Just like, [`.say`](https://docs.raku.org/routine/say) can be used as either a method or a subroutine, so you can use [`.take`](https://docs.raku.org/routine/take) as a method or subroutine, there's no real difference; merely convenience.

Now, let's iterate over `$seq-full-of-sunshine` and watch the output:

```` raku
for $seq-full-of-sunshine {
    ENTER say '▬▬▶ Entering';
    LEAVE say '◀▬▬ Leaving';
    say "❚❚ $_";
}
# OUTPUT:
# And nobody cries
# there’s only butterflies
# ▬▬▶ Entering
# ❚❚ me away
# ◀▬▬ Leaving
# A secret place
# A sweet escape
# ▬▬▶ Entering
# ❚❚ meee awaaay
# ◀▬▬ Leaving
# To better days
# ▬▬▶ Entering
# ❚❚ MEEE AWAAAAYYYY
# ◀▬▬ Leaving
# A hiding place
````

Notice how the [`say`](https://docs.raku.org/routine/say) statements we had inside the [`gather`](https://docs.raku.org/syntax/gather%20take) statement didn't actualy get executed until we needed to iterate over a value that [`take`](https://docs.raku.org/routine/take) routines took after those particular [`say`](https://docs.raku.org/routine/say) lines. The block got stopped and then continued only when more values from the [`Seq`](https://docs.raku.org/type/Seq) were requested. The last [`say`](https://docs.raku.org/routine/say) call didn't have any more [`take`s](https://docs.raku.org/routine/take) after it, and it got executed when the iterator was asked for more values after the last [`take`](https://docs.raku.org/routine/take).

## That's exceptional!

The [`take`](https://docs.raku.org/routine/take) routine works by throwing a `CX::Take` [control exception](https://docs.raku.org/syntax/CONTROL) that will percolate up the call stack until something takes care of it. This means you can feed a [`gather`](https://docs.raku.org/syntax/gather%20take) not just from an immediate block, but from a bunch of different sources, such as routine calls:

```` raku
multi what's-that (42)                     { take 'The Answer'            }
multi what's-that (Int $ where *.is-prime) { take 'Tis a prime!'          }
multi what's-that (Numeric)                { take 'Some kind of a number' }
multi what's-that   { how-good-is $^it                   }
sub how-good-is ($) { take rand > ½ ?? 'Tis OK' !! 'Eww' }
my $seq := gather map &what's-that, 1, 31337, 42, 'meows';
.say for $seq;
# OUTPUT:
# Some kind of a number
# Tis a prime!
# The Answer
# Eww
````

Once again, we iterated over our new [`Seq`](https://docs.raku.org/type/Seq) with a [`for` loop](https://docs.raku.org/syntax/for), and you can see that [`take`](https://docs.raku.org/routine/take) called from different multies and even nested sub calls still delivered the value to our [`gather`](https://docs.raku.org/syntax/gather%20take) successfully:

The only limitation is you can't [`gather`](https://docs.raku.org/syntax/gather%20take) [`take`](https://docs.raku.org/routine/take)s done in another [`Promise`](https://docs.raku.org/type/Promise) or in code manually [cued](https://docs.raku.org/routine/cue) in the scheduler:

```` raku
gather await start take 42;
# OUTPUT:
# Tried to get the result of a broken Promise
#   in block <unit> at test.p6 line 2
#
# Original exception:
#     take without gather
gather $*SCHEDULER.cue: { take 42 }
await Promise.in: 2;
# OUTPUT: Unhandled exception: take without gather
````

However, nothing's stopping you from using a [`Channel`](https://docs.raku.org/type/Channel) to proxy your data to be [`take`](https://docs.raku.org/routine/take)n in a [`react` block](https://docs.raku.org/language/concurrency#index-entry-react).

```` raku
my Channel $chan .= new;
my $promise = start gather react whenever $chan { .take }
say "Sending stuff to Channel to gather...";
await start {
    $chan.send: $_ for <a b c>;
    $chan.close;
}
dd await $promise;
# OUTPUT:
# Sending stuff to Channel to gather...
# ("a", "b", "c").Seq
````

Or gathering [`take`s](https://docs.raku.org/routine/take) from within a [`Supply`](https://docs.raku.org/type/Supply):

```` raku
my $supply = supply {
    take 42;
    emit 'Took 42!';
}
my $x := gather react whenever $supply { .say }
say $x;
# OUTPUT: Took 42!
# (42)
````

## Stash into the `cache`

I mentioned earlier that [`Seq`s](https://docs.raku.org/type/Seq) are one-shot [`Iterables`](https://docs.raku.org/type/Iterable) that can be iterated only once. So what exactly happens when we try to iterate them the second time?

```` raku
my $seq := gather take 42;
.say for $seq;
.say for $seq;
# OUTPUT:
# 42
# This Seq has already been iterated, and its values consumed
# (you might solve this by adding .cache on usages of the Seq, or
# by assigning the Seq into an array)
````

A `X::Seq::Consumed` [exception](https://docs.raku.org/type/Exception) gets thrown. In fact, `Seqs` do not even [do](https://docs.raku.org/routine/does.html) the [`Positional`](https://docs.raku.org/type/Positional) role, which is why we didn't use the `@` [sigil](https://docs.raku.org/language/glossary#index-entry-Sigil) that type-checks for [`Positional`](https://docs.raku.org/type/Positional) on the variables we stored [`Seq`s](https://docs.raku.org/type/Seq) in.

The [`Seq`](https://docs.raku.org/type/Seq) is deemed consumed whenever something asks it for its [`Iterator`](https://docs.raku.org/type/Iterator) after another thing grabbed it, like the `for` loop would.  For example, even if in the first `for` loop above we would've iterated over just 1 item, we wouldn't be able to resume taking more items in the next `for` loop, as it'd try to ask for the [`Seq`'s](https://docs.raku.org/type/Seq) iterator that was already taken by the first `for` loop.

As you can imagine, having [`Seq`s](https://docs.raku.org/type/Seq) *always* be one-shot would be somewhat of a pain in the butt. A lot of times you can afford to keep the entire sequence around, which is the price for being able to access its values more than once, and that's precisely what the [`Seq.cache`method](https://docs.raku.org/type/Seq#%28PositionalBindFailover%29_method_cache) does:

```` raku
my $seq := gather { take 42; take 70 };
$seq.cache;
.say for $seq;
.say for $seq;
# OUTPUT:
# 42
# 70
# 42
# 70
````

As long as you call [`.cache`](https://docs.raku.org/routine/cache) before you fetch the first item of the [`Seq`](https://docs.raku.org/type/Seq), you're good to go iterating over it until the heat death of the Universe (or until its cache noms all of your RAM). However, often you do not even need to call [`.cache`](https://docs.raku.org/routine/cache) yourself.

Many methods will automatically [`.cache`](https://docs.raku.org/routine/cache) the [`Seq`](https://docs.raku.org/type/Seq) for you:

- [`.Str`](https://docs.raku.org/routine/Str), [`.Stringy`](https://docs.raku.org/routine/Stringy), [`.fmt`](https://docs.raku.org/routine/fmt), [`.gist`](https://docs.raku.org/routine/gist), [`.perl`](https://docs.raku.org/routine/perl) methods always
[`.cache`](https://docs.raku.org/routine/cache)
- [`.AT-POS`](https://docs.raku.org/routine/AT-POS) and [`.EXISTS-POS`](https://docs.raku.org/routine/EXISTS-POS) methods, or in other words, [`Positional`](https://docs.raku.org/type/Positional) indexing like `$seq[^10]`, always [`.cache`](https://docs.raku.org/routine/cache)
- [`.elems`](https://docs.raku.org/routine/elems), [`.Numeric`](https://docs.raku.org/routine/Numeric), and [`.Int`](https://docs.raku.org/routine/Int) will [`.cache`](https://docs.raku.org/routine/cache) the [`Seq`](https://docs.raku.org/type/Seq), unless the underlying [`Iterator`](https://docs.raku.org/type/Iterator) provides a [`.count-only`](https://docs.raku.org/routine/count-only) method (we'll get to those in PART II)
- [`.Bool`](https://docs.raku.org/routine/Bool) will [`.cache`](https://docs.raku.org/routine/cache) unless the underlying [`Iterator`](https://docs.raku.org/type/Iterator) provides
[`.bool-only`](https://docs.raku.org/routine/bool-only) or [`.count-only`](https://docs.raku.org/routine/count-only) methods

There's one more nicety with [`Seq`s](https://docs.raku.org/type/Seq) losing their one-shotness that you may see refered to as [`PositionalBindFailover`](https://docs.raku.org/type/PositionalBindFailover).  It's a [role](https://docs.raku.org/syntax/role) that indicates to the parameter binder that the type can still be converted into a [`Positional`](https://docs.raku.org/type/Positional), even when it doesn't do [`Positional`](https://docs.raku.org/type/Positional) role. In plain English, it means you can do this:

```` raku
sub foo (@pos) { say @pos[1, 3, 5] }
my $seq := 2, 4 … ∞;
foo $seq; # OUTPUT: (4 8 12)
````

We have a `sub` that expects a [`Positional`](https://docs.raku.org/type/Positional) argument and we give it a [`Seq`](https://docs.raku.org/type/Seq) which isn't [`Positional`](https://docs.raku.org/type/Positional), yet it all works out, because the binder [`.cache`](https://docs.raku.org/routine/cache)s our [`Seq`](https://docs.raku.org/type/Seq) and uses the `List` the [`.cache`](https://docs.raku.org/routine/cache) method returns to be the [`Positional`](https://docs.raku.org/type/Positional) to be used, thanks to it doing the [`PositionalBindFailover`](https://docs.raku.org/type/PositionalBindFailover) role.

Last, but not least, if you don't care about *all* of your [`Seq`'s](https://docs.raku.org/type/Seq) values being generated and cached right there and then, you can simply assign it to a `@` [sigiled](https://docs.raku.org/language/glossary#index-entry-Sigil) variable, which will [reify](https://docs.raku.org/language/glossary#index-entry-Reify) the [`Seq`](https://docs.raku.org/type/Seq) and store it as an [`Array`](https://docs.raku.org/type/Array):

```` raku
my @stuff = gather {
    take 42;
    say "meow";
    take 70;
}
say "Starting to iterate:";
.say for @stuff;
# OUTPUT:
# meow
# Starting to iterate:
# 42
# 70
````

From the output, we can see `say "meow"` was executed on assignment to `@stuff` and not when we actually iterated over the value in the `for` loop.

## Conclusion

In Raku, [`Seq`s](https://docs.raku.org/type/Seq) are one-shot [`Iterable`s](https://docs.raku.org/type/Iterable) that don't keep their values around, which makes them very useful for iterating over huge, or even infinite, sequences. However, it's perfectly possible to cache [`Seq`](https://docs.raku.org/type/Seq) values and re-use them, if that is needed. In fact, many of the [`Seq`'s](https://docs.raku.org/type/Seq) methods will automatically cache the [`Seq`](https://docs.raku.org/type/Seq) for you.

There are several ways to create [`Seq`s](https://docs.raku.org/type/Seq), one of which is to use the [`gather`](https://docs.raku.org/syntax/gather%20take) and [`take`](https://docs.raku.org/routine/take) where a [`gather`](https://docs.raku.org/syntax/gather%20take) block will stop its execution and continue it only when more values are needed.

In parts [II](/post/Perl-6-Seqs-Drugs-and-Rock-n-Roll--Part-2) and III, we'll look at other, more exciting, ways of creating [`Seq`s](https://docs.raku.org/type/Seq). Stay tuned!

-Ofun
