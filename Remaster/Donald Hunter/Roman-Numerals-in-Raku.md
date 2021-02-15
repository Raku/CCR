# Roman Numerals in Raku

*Originally published on [29 May 2019](https://donaldh.wtf/2019/05/roman-numerals-in-perl-6/) by Donald Hunter.*

My first shot at the [Weekly Challenge](https://perlweeklychallenge.org/) with a Roman numeral encoder in Raku

I have been watching the [Weekly Challenge](https://perlweeklychallenge.org/) with interest since it was first announced, but without the time to actually participate. [This week](https://perlweeklychallenge.org/blog/perl-weekly-challenge-010/) there are three challenges, the first of which is to write an encoder for Roman numerals:

> Write a script to encode/decode Roman numerals. For example, given Roman numeral CCXLVI, it should return 246. Similarly, for decimal number 39, it should return XXXIX. Checkout wikipedia page for more information.

### Roman to Decimal

A Roman numeral can be decoded by splitting it into symbols, converting each to a decimal then
adding the decimals to give a result. 'One-before' numerals such as `IX` can be handled as a single symbol,
giving this list of symbols:

```` raku
my %r2i =
'I' => 1, 'IV' => 4, 'V' => 5, 'IX' => 9,
'X' => 10, 'XL' => 40, 'L' => 50, 'XC' => 90,
'C' => 100, 'D' => 500, 'CM' => 900, 'M' => 1000;
````

The decode algorithm can be implemented by matching all the symbols, taking a slice of the conversion
map and then reducing the slice to its sum.

```` raku
my $roman = 'CCXLVI';
say [+] %r2i{ $roman.match(/ ( <{%r2i.keys}> )* /).flat>>.Str }
````

````
./roman-decode.raku
246
````

That works fine but is surprisingly slow, more so for long numerals. Instead of using a regex
match, we can use `split` and keep the delimiter values with `:v` – though we do need to filter out
all the zero length strings between the delimiters.

```` raku
say [+] %r2i{ $roman.split(%r2i.keys, :v).grep(*.Bool) }
````

[Try it Online!](https://tio.run/##Nc6xCsIwFIXh3ae4i7TVEFKxgkodjEuhWUtAHByKFCMNiQpFfPaYm8Tty7n/EN0btXGPCeZmNUA9A8iaDOoDlMSrC1x7RlU4ysAtwTa6ZH6XbYzRkVWYecxZ6Hnq8XJKEZqLVOFD/CO2d/Y6wXl5Cd/7gFUvo6nVanjmuNB7P1kCu3dBb6bX@YIex1EV8HVOcNFKKZvuBw)

`Str.split` uses the longest delimiter matches, filtering out the matches that are wholly contained within a longer match – though this does not appear to be documented in the [`split` documentation](https://docs.perl6.org/routine/split).

It would be nice if there was a version of `Str.match` that took a list of literal strings to match.

### Decimal to Roman

The encode algorithm can be implemented by using integer arithmetic to find how many of each symbol is required, starting with the numerically largest symbol `M` and then concatenating the symbols together.

```` raku
say [~] gather {
    for %i2r.keys.sort: -* -> $radix {
        take %i2r{$radix} x $number / $radix;
        $number %= $radix;
    }
}
````

````
./roman.raku encode 39
XXXIX
````

[Try it Online!](https://tio.run/##VY7PC4IwFIDv/hXvoAilpmGRiV3sEtQ1guiwaNXol2wKiti/bnvbCtrp2/s@9lZQfp/2jwYcPmaQWQDuyoVsAZEnaaswlqhpgsOdwsTDVnMUyvlurWNkjRM1znUeqj43PZqliZDzjanwsvlGYWrhz9iYQ6Y@GJBnyQrCuFDGflaPI0U5FPeKF2kvSAP79wEupLxK0cqdAOcXV48EN9qIQLx4OQd/AP4CbE5OrDYZnpLcqGpbrTqof1tGJk9/9dc42Z/qrK7vo2QWfwA)

It's kinda nice using `gather` / `take` here but I'd prefer a functional solution over this
explicit iterative solution. Enough time spent already so that will be for another day.

### The Resulting Program

```` raku
my %r2i =
'I' => 1, 'IV' => 4, 'V' => 5, 'IX' => 9,
'X' => 10, 'XL' => 40, 'L' => 50, 'XC' => 90,
'C' => 100, 'D' => 500, 'CM' => 900, 'M' => 1000;

multi MAIN('decode', Str $roman) {
    say [+] %r2i{ $roman.split(%r2i.keys, :v).grep(*.Bool) }
}

my %i2r = %r2i.antipairs;

multi MAIN('encode', Int $number is copy where 0 <= $number <= 3999) {
    say [~] gather {
        for %i2r.keys.sort: -* -> $radix {
            take %i2r{$radix} x $number / $radix;
            $number %= $radix;
        }
    }
}
````

````
./roman.raku decode MMXIX
2019

./roman.raku decode MCMLXXXIV
1984

./roman.raku encode 2019
MMXIX

./roman.raku encode 1984
MCMLXXXIV
````
