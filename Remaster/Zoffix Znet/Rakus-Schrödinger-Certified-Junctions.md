# Raku's Schrödinger-Certified Junctions
    
*Originally published on [5 September 2016](https://perl6.party//post/Perl-6-Schrodinger-Certified-Junctions) by Zoffix Znet.*

[Erwin Schrödinger](https://en.wikipedia.org/wiki/Erwin_Schr%C3%B6dinger) would have loved Raku, because the famous [cat gedanken](https://en.wikipedia.org/wiki/Schr%C3%B6dinger%27s_cat) can be expressed in a Raku [Junction](https://docs.raku.org/type/Junction):

```` raku
my $cat = 'dead' | 'alive';
say "cat is both dead and alive" if $cat eq 'dead' and $cat eq 'alive';
# OUTPUT:
# cat is both dead and alive
````

What's happening here? I'll tell ya all about it!

## Anyone game?

At their simplest, Junctions let you treat a bunch of values as a single one.  For example, you can use an `any` Junction to test if a variable equals to any of the given values:

```` raku
say 'it matches!' if 'foo' eq 'foo' | 'bar' | 'ber';
say 'single-digit prime' if 5 == any ^9 .grep: *.is-prime;
my @values = ^100;
say ’it's in 'ere!‘ if 42 == @values.any;
# OUTPUT:
# it matches!
# single-digit prime
# it's in 'ere!
````

To create an `any` Junction from a bunch of values, you can use the `|` infix operator, call the `any` function, or use the `.any` method. The conditionals above will return True if `any` of the values in a Junction match the given one. In fact, nothing's stopping you from using a Junction on both ends:

```` raku
my @one = 1..10;
my @two = 5..15;
say ’there's overlap!‘ if @one.any == @two.any;
# OUTPUT:
# there's overlap!
````

The operator will return True if `.any` of the values in `@one` numerically equal to `.any` of the values in `@two`. Pretty sweet, but we can do more.

## All for One and Any for None

The `any` Junction isn't the only one available. You have a choice of `all`, `any`, `one`, and `none`.  When collapsing into Boolean context, their meaning is as follows; function/method names to construct the Junction are the same as the name of the Junction itself and the infix operators to construct the Junction are listed below as well:

- `all`—*all* values evaluate to True (use infix `&`)
- `any`—*at least one* of the values evaluate to True (use infix `|`)
- `one`—*exactly one* of the values evaluate to True (use infix `^`)
- `none`—*none* of the values evaluate to True (no infix available)

Take special care when using the `all` Junction:

```` raku
my @values = 2, 3, 5;
say 'all primes' if @values.all ~~ *.is-prime;
my @moar-values;
say 'also all primes' if @moar-values.all ~~ *.is-prime;
````

It will return `True` even when it has no values, which may not be what you intended. In those cases, you can use:

```` raku
my @moar-values;
say 'also all primes' if @moar-values and @moar-values.all ~~ *.is-prime;
````

## Call Me, Baby

You can use Junctions as arguments to Routines that don't expect them. What happens then? The Routine will be called with each Junctioned value, and the return will be a Junction:

```` raku
sub calculate-things ($n) {
    say "$n is a prime"        if $n.is-prime;
    say "$n is an even number" if $n %% 2;
    say "$n is pretty big"     if $n > 1e6;
    $n²;
}
my @values = 1, 5, 42, 1e10.Int;
say 'EXACTLY ONE square is larger than 1e10'
    if 1e10 < calculate-things @values.one;
# OUTPUT:
# 5 is a prime
# 42 is an even number
# 10000000000 is an even number
# 10000000000 is pretty big
# EXACTLY ONE square is larger than 1e10
````

Exploiting side-effects might be a bit too magical and not something you'd want to see in production code, but using a subroutine to alter the original Junctioned value is quite acceptable. How about performing a database lookup to obtain the "actual" value and then evaluating the conditional:

```` raku
use v6;
use DBIish;
my $dbh = DBIish.connect: 'SQLite', :database<test.db>;
sub lookup ($id) {
    given $dbh.prepare: 'SELECT id, text FROM stuff WHERE id = ?' {
        .execute: $id;
        .allrows[0][1] // '';
    }
}
my @ids = 3, 5, 10;
say 'yeah, it got it, bruh' if 'meow' eq lookup @ids.any;
# OUTPUT (the database has a row with id = 5 and text = 'meow'):
# yeah, it got it, bruh
````

## We've been expecting you. Please, have a seat.

The game changes when your Routine explicitly expects a Junction

```` raku
sub do-stuff (Junction $n) {
    say 'value is even'  if $n %% 2;
    say 'value is prime' if $n.is-prime;
    say 'value is large' if $n > 1e10;
}
do-stuff (2, 3, 1e11.Int).one;
say '---';
do-stuff (2, 3, 1e11.Int).any;
# OUTPUT:
# value is large
# ---
# value is even
# value is prime
# value is large
````

When we provide a `one` Junction, only the conditions that satisfy exactly *one* of the given values trigger. When we provide an `any` Junction, they trigger when any of the given values satisfy the condition.

But! You don't have to wait for the world to hand out Junctions for you.  How about you make one yourself, and save up on code when testing the conditions:

```` raku
sub do-stuff (*@v) {
    my $n = @v.one;
    say "$n is even"  if $n %% 2;
    say "$n is prime" if $n.is-prime;
    say "$n is large" if $n > 1e10;
}
do-stuff 2, 3, 1e11.Int;
say '---';
do-stuff 42;
# OUTPUT:
# one(2, 3, 100000000000) is large
# ---
# one(42) is even
````

## Won't Someone Think of The Future?

Here's a little secret: Junctions are designed to be [auto-threaded](https://en.wikipedia.org/wiki/Automatic_parallelization). Even though at the time of this writing they will use just one thread, you should not rely on them being executed in any predictable order. The auto-threading will be implemented by some time in 2018, so stay tuned... your complex Junctioned operations that deserve it might get much faster in a couple of years without you doing anything.

## Conclusion

Raku Junctions are superpositions of values that let you test multiple values as if they were one. Apart from offering fantastically short and readable syntax for doing so, Junctions also pack a punch by letting you use Routines to transform the superimposed values or make use of the side effects.

You can also make routines that explicitly operate on Junctions or transform the multiple provided values *into* Junctions to simplify your code.

Lastly, Junctions are designed to use all of the available power your computer offers and will be made autothreaded in the short future.

Junctions are awesome! Use them. And have fun!
