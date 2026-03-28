# Speaking hypothetically in Raku
    
*Originally published on [2 July 2010](http://strangelyconsistent.org/blog/speaking-hypothetically-in-perl-6) by Carl Mäsak.*

So, arrays and hashes are considered central enough in Perl that they each have their own sigil, as well as a dedicated circumfix constructor:

```
Type    Sigil   Circumfix
====    =====   =========
Array   @       [ ]
Hash    %       { }
```

Apart from those, we consider scalars quite important, but they're really "containers of anything", including (references to) arrays and hashes. The `$` sigil simply means "untyped". Because of this, there's not really a circumfix constructor.

```
Type    Sigil   Circumfix
====    =====   =========
Scalar  $       N/A 
Array   @       [ ]
Hash    %       { }
```

But there's one more sigil; one which has had to fight a bit more for its place in the food chain... but this is the one that really makes the hackers over at "Lambda the Ultimate" smile. Introducing the `&` sigil:

```
Type    Sigil   Circumfix
====    =====   =========
Scalar  $       N/A
Array   @       [ ]
Hash    %       { }
Block   &       { } 
```

Ok, hold on a minute. `Block`? A block of what?

So here's the really neat thing. In many situations in perfectly normal, sane programming, we end up with wanting to execute some code, just *not right now*. Just as we'd reach for an array or a hash when we want to collect some structured data for later, we can reach for this block thingy when we want to collect some executable code for later.

If you haven't done this, I can see how it all sounds terribly esoteric, even pointless. You'd go "Just wait until later, and run the code at that point rather than passing around un-run code!", and if a `Block` was only what I've told you so far, I'd agree with you.

But it's more. A `Block` is automatically a *closure* — and this is where people who've grokked this normally use big words (like "it closes over its lexical environment!") and the eyes of people who are struggling to understand glaze over. So I'll go slow.

Take a look at the `Counter` class in [this blog post](Laziness-for-the-impatient.html). Hm, I'll reproduce it here for you:

```raku
class LazyIterator {
    has $!it;
    method `get` {
        $!`it`;
    }
}
class Counter is LazyIterator {
    method new(Int $start) {
        my $count = $start;
        self.bless(*, :it({ $*count*++ }));
    }
}
```

The `new` method contains code both to initialize and to increase `$count`, but only the initialization code (`my $count = $start;`) is run. The increasing code (`{ $*count*++ }`) is inside a `Block`, and thus protected from immediate execution. Instead, it's just stored away in the private attribute `$!it` (for "iterator").

When is `$counter` actually increased? Well, each time we call the `LazyIterator.get` method, it executes the `Block` stored in the `$!it`. This all seems perfectly obvious, until one starts to think about how magical it actually is. It increases... what, again? `$counter`? Which is... where, exactly? *In the lexical scope of the `Counter.new` method, which finished ages ago, and which by the way is in a subclass that wasn't even defined when we defined `LazyIterator.get`!!!*

For that to even have a chance at working, the `Block` in `$!it` must "save away" `$counter` from the lexical scope of the `Counter.new` method, enough for it to avoid being eaten by an evil garbage collector, etc. This is totally magical! It's as if you opened an empty bottle in orbit around Neptune to let some darkness in, and then whenever you opened the bottle again, *no matter where you were*, you'd get the same Neptune darkness from within the bottle.

Or like me coming to visit you, but instead of leaving my phone number, I activate one half of an entangled-pair portal in your living room and take the other half with me. Afterwards, I can just scribble whatever I want on my half, and you'd see it instantaneously appear in the other half in your living room. That's how insanely great closures are.

One of the very first blog posts I wrote here at use.perl.org was about [that magical ability of closures](Ill-call-you-back.html) to hold on to the environment in which they were created. Be sure to check out [the diagram](dependency-injection.png) that goes with it, which explains how closures can be used to decouple parts of a large object-oriented system.

In fact, closures — or [lambda expressions](https://en.wikipedia.org/wiki/Lambda_calculus), same thing — are so general that they have been shown to be *universal*. That is, anything that a computer algorithm can do, lambda expressions can do, too. (In fact, Alonzo Church developed lambda calculus and used it to prove the [Halting Problem](https://en.wikipedia.org/wiki/Halting_problem) undecidable in April 1936, only one month before Alan Turing showed the same with his *gedanken* state machine. In an addendum published that autumn, Turing shows that lambda calculus and his machine are equal in power.)

By the way, did you notice in the table at the start of the post that both hashes and blocks use the same circumfix constructor, `{ }`? How will you know when you've got a hash and when you've got a block of code?

[S04](https://github.com/Raku/old-design-docs/blob/master/S04-control.pod) explains and gives plenty of examples.

```raku
$hash = { };
$hash = { %stuff };
$hash = { "a" => 1 };
$hash = { "a" => 1, $b, $c, %stuff, @nonsense };
$code = { %_ };                            # use of %_
$code = { "a" => $_ };                     # use of $_
$code = { "a" => 1, $b, $c, %stuff, @_ };  # use of @_
$code = { ; };
$code = { @stuff };
$code = { "a", 1 };
$code = { "a" => 1, $b, $c ==> print };
```

Briefly, the code block will degenerate to a hash if it's empty or contains only a comma-separated list starting with either a pair or a `%`-sigil variable, and if it doesn't make use of any parameters. You can confirm that this covers all the cases above.

That might seem like a slightly arbitrary way of deciding, but it's actually the result of a fair bit of back-and-forth in the spec about when something is a closure and when it's a hash — and this spec iteration feels like a keeper. The previous ones led people into tricky situations where they supplied what they thought was a closure to a `map`, but it turned out to evaluate to a hash, and the multi dispatch to `map` failed. That doesn't seem to happen with the current spec, which is a good sign.

What are some common functions that accept blocks as arguments? I've already mentioned `map`, but even though the [ `map`/`grep`/`sort` triad](https://perl6advent.wordpress.com/2009/12/23/day-23-lazy-fruits-from-the-gather-of-eden/) has that slightly built-in feel, so they're not really a good example.

Here's one that's a good example:

```raku
$sentence = 'eye drops off shelf';
$newspaper-heading = $sentence.subst(/ \S+ /, { $/.ucfirst }, :global);
say $newspaper-heading; # Eye Drops Off Shelf
```

The vital part is the `{ $/.ucfirst }` block. Why do we need to put that part in a block? Because if we didn't, it'd get executed immediately, as in *before the `.subst` call was even made*. The `{ }` block constructor creates a protective shell of delayed action (same principle as with orally administered pills, really), and the `substr` method can then invoke the block when the time is right — i.e. after a match has been found. Newcomers on `#raku` often leave out the curlies, thinking that it'll magically work anyway.

If you're with me so far, you're ready for the next "look ma, no curlies!" stage.

We like closures so much (as language designers) that we want to build them into a lot of places. There are a number of places when we want to build them in so much that we even decide to lose the `{ }` circumfix! If that sounds crazy, just look at these perfectly harmless examples:

```raku
if !@food || **@food[0].lc eq 'marmite'** {
    say "You either have no food or just marmite!";
}
class VeryImportantObject {
    has $!creation-time = **`time`**;
}
 **.flip.say** for `lines`;
```

In all of the above cases, it's as if *invisible `{ }` curlies* have been inserted around the emboldened parts for us, and then evaluated only if/when the time was right. Closures without curlies are sometimes referred to as "thunks".

(Why don't we special-case the second argument of `Str.subst` in the same way? Well, we certainly could, but it'd be kind of unfair to all other user-defined methods which don't automatically get the same special treatment. Somehow it's more OK to thunk language constructs like the `infix:<||>` operator, or `has`, or statement-modifying `for`, than it is to thunk the second argument in some method somewhere. But it's a perfect gotcha for static analysis to catch.)

But Raku also gives you, the programmer, a way to omit the curlies if you just want to create a little one-off closure somewhere. It's provided through the ubiquitous "whatever" star, after which [Rakudo Star](https://www.pmichaud.com/2010/pres/yapcna-rakudo/) was named.

The whatever star represents a curious bit of spec development, kind of a little idea that seemed to get a life of its own after a while and spread everywhere, like gremlins. It all started when the old "index from the end" syntax from Perl was re-considered:

```raku
@a[ -1]    # getting the last element in Perl
@a[*-1]    # getting the last element in Raku
```

Why was this change made? [S09](https://github.com/Raku/old-design-docs/blob/master/S09-data.pod#Negative_and_differential_subscripts) sums it up:

> The Raku semantics avoids indexing discontinuities (a source of subtle runtime errors), and provides ordinal access in both directions at bot ends of the array.

When this feature was finally implemented in Rakudo, instead of treating the `* - 1` like a syntactic oddity that's only allowed to occur inside array indexings, they generalized the concept so that `* - 1` means `{ $_ - 1 }`. (Note the surrounding block curlies.) This was considered nifty and trickled back into the spec. So now you can use all of the following forms to mean the same thing:

```raku
      { $_ - 1 }     # means "something minus one"
-> $_ { $_ - 1 } # explicit lambda mention of $_
-> $a { $a - 1 } # change the name of the param
     { $^a - 1 }     # "self-declaring" param
         * - 1   # note the lack of curlies
```

I haven't mentioned the "self-declaring" type of parameter so far. They're very nice, especially in small blocks where an explicit signature would give the block too much of a front weight. The spectical name for those are "placeholder variables", because they make a space for themselves in the parameter list, I guess. The place they get is their rank in an ascending string sort, by the way. You can't have both an explicit signature and placeholder variables for the same block — it's an either-or thing.

(Also, the only form which isn't *exactly* identical in the list above, is the first one, which actually translates to `-> $_? { $_ - 1 }`. That is, the `$_` is optional, and you can call the block with 0 arguments. I don't remember the rationale for this, nor whether I've ever benefitted from it.)

A recent spec change generalized the whatever star so that if two or more occur in the same expression, they get assigned successive parameter slots. `* + *` translates into `{ $^a + $^b }`, for example. So they're really starting to look a bit like "anonymous placeholder variables".

Now for the actual impetus for this post: in August 2000, almost ten years ago, Damian Conway made an RFC which anticipated a lot of the features outlined in this post. And it does this while suggesting syntax which is consistently less mnemonic and less maintainable than what we eventually ended up with. (Not the fault of Damian-from-ten-years-ago, of course. I'm pretty sure he's been instrumental in guiding us to many of the solutions we have today.)

Here's a quick summary of the key points of the RFC, and the modern Raku responses:

- The RFC suggests that one common use case for the "higher-order functions" (as it calls the closures) is in case statements with comparison ops in them, such as `case ^_ < 10 { return 'milk' }`. Note that the whatever star nicely fills this niche: `when * < 10 { return 'milk' }`.
- Much of the rest of the RFC seems to be handled well today with either lambda signatures or placeholder variables (the `$^a` ones). `$check = ^cylinder_vol == ^radius**2 * ^height or die ^last_words;` could today be written `$check = -> $cylinder_vol, $radius, $height, $last_words { $radius ** 2 * $height or die $last_words };`. I hesitate to put that example in placeholder-variable form, because they're too many and the alphabetical mess would be too hard to maintain, even once.
- The model we ended up with doesn't do automatic currying, like in the RFC. We do, however, have the extremely nice method `.assuming` on all `Code` objects (including `Block`), which gives you back a new `Code` object with one or more parameters pre-set.
- Generally, the modern variants lean towards either explicit curlies or a whatever star to tell you that something mildly magical is going on. With the syntax proposed in the RFC, I suspect I'd be constantly less-than-certain about where implicit blocks ended.


In Apocalypse 6 the RFC was accepted with a "c" rating (that's for "major caveats"). I think that's accurate, because the spirit of the RFC definitely lives on, but the syntax of it all turned out much, much better. I guess that's the point of having the role of Language Designer centralized to one person.

Having exhausted the things I have to say about this topic, I'll stop here and see if I can get some closure myself. 哈哈
