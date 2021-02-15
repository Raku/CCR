# Excel Columns

*Originally published on [16 May 2020](https://donaldh.wtf/2020/05/excel-columns/) by Donald Hunter.*

This is a solution to task #1 from the [60th Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-060/), written in Raku.

> Write a script that accepts a number and returns the Excel Column Name it represents and vice-versa.  Excel columns start at A and increase lexicographically using the 26 letters of the English alphabet, A..Z. After Z, the columns pick up an extra “digit”, going from AA, AB, etc., which could (in theory) continue to an arbitrary number of digits. In practice, Excel sheets are limited to 16,384 columns.

Converting an Excel column value to name is a base 26 conversion which Raku can do, e.g. `25.base(26)`, except that the symbols we want to use are `A..Z` not `0..P`. So we need to roll our own – just need to iteratively pick the character for `$value mod 26` and repeat with `$value div 26`.

```` raku
#| Convert column value to name where 1 <= value <= 16384
multi MAIN(Int $value is copy where 1 <= * <= 16384) {
    my @alphabet = 'A'..'Z';
    my @chars = gather {
        repeat {
            take @alphabet[$value mod 26 - 1];
            $value div= 26;
        } while $value > 0;
    }
    say @chars.reverse.join;
}
````

For the name to value conversion, first map each character to a value then reduce the list of values `$left * 26 + $right`.

```` raku
#| Convert column name to value
multi MAIN(Str $name where /^<[A..Z]>+$/) {
    my %map = flat 'A'..'Z' Z 1..26;
    say $name.comb.map(-> $c { %map{$c} }).reduce({ $^a * 26 + $^b });
}
````

Each conversion method is a `multi MAIN` with parameter validation. Pod comments on the multis gets included in the usage message:

````
./excel-columns.raku
````

````
Usage:
  ./excel-columns.raku <value> -- Convert column value to name where 1 <= value <= 16384
  ./excel-columns.raku <name> -- Convert column name to value
````

````
./excel-columns.raku 1
./excel-columns.raku 28
./excel-columns.raku 16384
./excel-columns.raku A
./excel-columns.raku AD
./excel-columns.raku XFD
````

````
: A
: AB
: XFD
: 1
: 30
: 16384
````

The code will only execute for valid input values, otherwise the usage is displayed:

````
./excel-columns.raku 16385
````

````
Usage:
  ./excel-columns.raku <value> -- Convert column value to name where 1 <= value <= 16384
  ./excel-columns.raku <name> -- Convert column name to value
````
