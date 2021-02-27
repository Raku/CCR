# Raku .polymod: Break Up a Number Into Denominations
    
*Originally published on [18 May 2016](https://perl6.party//post/Perl6-.polymod-break-up-a-number-into-denominations) by Zoffix Znet.*

Back in the day, I wrote Perl module [Number::Denominal](https://metacpan.org/pod/Number::Denominal) that breaks up a number into "units," say, 3661 becomes '1 hour, 1 minute, and 1 second'. I felt it was the pinnacle of achievement and awesome to boot.  Later, I ported that module to Raku, and recently I found out that Raku actually has [`.polymod` method](http://docs.raku.org/routine/polymod) built in, which makes half of my cool module entirely useless.

Today, we'll examine what `.polymod` does and how to use it. And then I'll talk a bit about my reinvented wheel as well.

## Denominated

The `.polymod` method takes a number of divisors and breaks up its invocant into pieces:

```` raku
my $seconds = 1 * 60*60*24 # days
            + 3 * 60*60    # hours
            + 4 * 60       # minutes
            + 5;           # seconds
say $seconds.polymod: 60, 60;
say $seconds.polymod: 60, 60, 24;
# OUTPUT:
# (5 4 27)
# (5 4 3 1)
````

The divisors we pass as arguments in this case are time related: 60 (seconds per minute), 60 (minutes per hour), and 24 (hours in a day).  From the smallest unit, we're progressing to the largest one, with the numbers being how many of the unit in question fit into the next larger unit.

Matching up the output to the expression we assigned to `$seconds` we can see that output also progresses—same as input divisors—from smallest unit to largest: 5 seconds, 4 minutes, 3 hours, and 1 day.

Notice how in the first call, we did not specify a divisor for hours-in-a-day, and so we got our days expressed as hours (24 hours for one day, plus the 3 hours we had originally). So this form of `.polymod` simply uses up all the divisors and the number of returned items is one more than the number of given divisors.

## Handmade

Another code example useful to understanding of `.polymod` is one showing the previous calculation done with a loop instead, without involving `.polymod`:

```` raku
my $seconds = 2 * 60*60*24 # days
            + 3 * 60*60    # hours
            + 4 * 60       # minutes
            + 5;           # seconds
my @pieces;
for 60, 60, 24 -> $divisor {
    @pieces.push: $seconds mod $divisor;
    $seconds div= $divisor
}
@pieces.push: $seconds;
say @pieces;
# OUTPUT:
# [5 4 3 2]
````

For each of the divisors, we take the remainder of integer division of `$seconds` and the divisor being processed and then change the `$seconds` to the integer divison between `$seconds` and that divisor.

## To Infinity and Beyond!

Raku is advanced enough to have infinite things in it without blowing up and that's accomplished with lazy lists. When the divisors given to `.polymod` method are in a lazy list, it'll run until the remainder is zero and not through the whole list:

```` raku
say 120.polymod:      10¹, 10², 10³, 10⁴, 10⁵;
say 120.polymod: lazy 10¹, 10², 10³, 10⁴, 10⁵;
say 120.polymod:      10¹, 10², 10³ … ∞;
# OUTPUT:
# (0 12 0 0 0 0)
# (0 12)
# (0 12)
````

In the first call, we have a series of numbers increasing by a power of 10.  The output of that call includes 4 trailing zeros, because `.polymod` evaluated each divisor. In the second call, we explicitly create a lazy list using `lazy` keyword and now we have just two items in the returned list.

The first divisor (`10`) results in zero remainder, which is our first item in the returned list, and integer division changes our 120 to just 12 for the next divisor. The remainder of division of 12 by 100 is 12, which is our second item in the returned list. Now, integer division of 12 by 100 is zero, which stops the execution of `.polymod` and gives us our two-item result.

In the last call, we use an ellipsis, which is [the sequence operator](http://docs.raku.org/language/operators#infix_...), to create the same series of numbers increasing by a power of 10, except this time that series is infinite. Since it's lazy, the result is, once again, just two elements.

## Zip It, Lock It, Put It In The Pocket

Numbers alone are great and all, but aren't too descriptive about the units they represent. Let's use [a Zip meta operator](http://docs.raku.org/language/operators#Zip_Operators), to fix that issue:

```` raku
my @units  = <ng μg mg g kg>;
my @pieces = 42_666_555_444_333.polymod: 10³ xx ∞;
say @pieces Z~ @units;
# OUTPUT:
# (333ng 444μg 555mg 666g 42kg)
````

For the purposes of our calculation, I'll be breaking up forty two trillion, six hundred sixty six billion, five hundred fifty five million, four hundred forty four thousand, three hundred and thirty three (😸) nanograms into several larger units.

We store unit names in the array `@units`. Then, we call `.polymod` on our huge number and give it an infinite list with number 1000 for each divisor and store what it gives us in `@pieces`.

The Zip meta operator one-by-one takes elements from lists on the left and right hand sides and applies to them the operator given to it. In this case, we're using the string concatenation operator (`~`), and thus our final result is a list of strings with numbers and units.

## That Denominated Quickly

You're not limited to just [Ints](http://docs.raku.org/type/Int) for both the invocant and the divisors, but can use others too. In this mode, regular division and not integer one will be used with the divisors and the remainder of the division will be simply subtracted. Note that this mode is triggered by the invocant not being an `Int`, so if it is, simply coerce it into a [Rat](http://docs.raku.org/type/Rat), a [Num](http://docs.raku.org/type/Num), or anything else that `does` the [Real role](http://docs.raku.org/type/Real):

```` raku
say ⅔.polymod: ⅓;
say 5.Rat.polymod: .3, .2;
say 3.Rat.polymod: ⅔, ⅓;
# OUTPUT:
# (0 2)
# (0.2 0 80)
# (0.333333 0 12)
````

In the first call, our invocant is already a `Rat`, so we can just call `.polymod` and be done with it. In the second and third, we start off with Ints, so we coerce them into Rats. The reason I didn't use a Num here is because it adds [floating point math noise](http://stackoverflow.com/questions/21895756/why-are-floating-point-numbers-inaccurate) into the results, which Rats can often avoid:

```` raku
say 5.Num.polymod: .3, .2;
say 3.Num.polymod: ⅔, ⅓;
# OUTPUT:
# (0.2 0.199999999999999 79)
# (0.333333333333333 2.22044604925031e-16 12)
````

This imprecision of floating point math is also something to be very careful about when using lazy list mode of `.polymod`, since it may never reach exact zero (at least [at the time of this writing](https://rt.perl.org/Ticket/Display.html?id=128175)). For example, on my machine this is a nearly infinite loop as the numbers fluctuate wildly. Change `put` to `say` to print the first hundred numbers:

```` raku
put 4343434343.Num.polymod: ⅓ xx ∞
````

## Making it Human

All we've seen so far is nice and useful, but Less Than Awesome when we want to present the results to squishy humans. Even if we use the Zip meta operator to add the units, we're still not handling the differences between singular and plural names for units, for example. Luckily, some crazy guy wrote a module to help us: [Number::Denominate](http://modules.raku.org/repo/Number::Denominate).

```` raku
use Number::Denominate;
my $seconds = 1 * 60*60*24 # days
            + 3 * 60*60    # hours
            + 4 * 60       # minutes
            + 5;           # seconds
say denominate $seconds;
say denominate $seconds, :set<weight>;
# OUTPUT:
# 1 day, 3 hours, 4 minutes, and 5 seconds
# 97 kilograms and 445 grams
````

By default, the module uses time units and the first call to `denominate` gives us a nice, pretty string. Several [sets of units](https://github.com/zoffixznet/rakuumber-Denominate#set) are pre-defined and in the second call we use the weight unit set.

You can even define your own units:

```` raku
say denominate 449, :units( foo => 3, <bar boors> => 32, 'ber' );
# OUTPUT:
# 4 foos, 2 boors, and 1 ber
````

The module offers precision control and a couple of other options, and I encourage you to check out [the docs](https://github.com/raku-community-modules/Number-Denominate#synopsis) if denominating things is what you commonly do.

## Conclusion

Raku's built-in `.polymod` method is a powerful tool for breaking up numbers into denominations. You can use it on Ints or other types of numbers, with latter allowing for use of non-integer divisors. You can alter the mode of its operation by providing the divisors as an infinite list. Lastly, module `Number::Denominate` can assist with presenting your denominated number in a human-friendly fashion.

Enjoy!
