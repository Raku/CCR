# IPv4 Partition

*Originally published on [18 May 2020](https://donaldh.wtf/2020/05/ipv4-partition/) by Donald Hunter.*

This is a solution to task #2 from the [61st Weekly Challenge](https://perlweeklychallenge.org/blog/perl-weekly-challenge-061/), written in Raku.

> You are given a string containing only digits (0..9). The string should have between 4 and 12
digits.

> Write a script to print every possible valid IPv4 address that can be made by partitioning the
input string.

> For the purpose of this challenge, a valid IPv4 address consists of four “octets” i.e. A, B, C
and D, separated by dots (.).

> Each octet must be between 0 and 255, and must not have any leading zeroes. (e.g., 0 is OK, but
01 is not.)

### Matching IP addresses

This challenge looks like it can be solved using regular expressions. Let's start by defining a
regex for valid IP addresses.

```` raku
my $regex = / ^ ( '25' <[0..5]>          # 25n - covers 250 to 255
                  | [
                      [ '2' <[0..4]>     # 2n. – covers 20n to 24n
                        | '1' <[0..9]>   # 1n. – covers 10n to 19n
                        | <[1..9]>       #  n. – covers  1n to  9n
                      ]?                 # ^^  – optional
                      <[0..9]> ]         #   n – last digit for 0 to 249
                ) ** 4 % '.' $ /;        # ^^^ x 4 separated by '.'

for <0.0.0.0 1.1.1.1 10.0.0.1 10.10.10.10 192.168.1.254 199.199.199.199 201.201.201.201
     249.249.249.249 250.250.250.250 255.255.255.255 1.1.1.1. 1.01.1.1 1.2.3.256
     256.1.1.1 1..3.4 1.2.3.4.5 1.1.1.01> -> $candidate {
    say "{$candidate} is {$candidate ~~ $regex ?? "an IP address" !! "not valid"}";
}
````

````
0.0.0.0 is an IP address
1.1.1.1 is an IP address
10.0.0.1 is an IP address
10.10.10.10 is an IP address
192.168.1.254 is an IP address
199.199.199.199 is an IP address
201.201.201.201 is an IP address
249.249.249.249 is an IP address
250.250.250.250 is an IP address
255.255.255.255 is an IP address
1.1.1.1. is not valid
1.01.1.1 is not valid
1.2.3.256 is not valid
256.1.1.1 is not valid
1..3.4 is not valid
1.2.3.4.5 is not valid
1.1.1.01 is not valid
````

This is the classic regex for matching valid octets, combined with the Raku quantifier separator `%` to match octets separated by `.`.

### A Simpler Regex

We should be able to simplify the regex by using a code block to validate the octet range, but sadly it's not quite strict enough so the code below allows leading zeros:

```` raku
my $regex = / ^ ( \d ** 1..3 <?{ $/.Int < 256 }> ) ** 4 % '.' $ /;

for <192.168.1.1 1.01.1.1 1.2.3.256> -> $candidate {
    say "{$candidate} is {$candidate ~~ $regex ?? "an IP address" !! "not valid"}";
}
````

````
192.168.1.1 is an IP address
1.01.1.1 is an IP address
1.2.3.256 is not valid
````

### A Working Regex

This next avoids matching leading zeros by ensuring that the leftmost digit in a 2 or 3 digit number will only match ~1..9~.

```` raku
my $regex = / ^ ( [ <[1..9]> \d? ]? \d <?{ $/.Int < 256 }> ) ** 4 % '.' $ /;

for <192.168.1.1 1.01.1.1 10.109.0.1 10.0.0.1> -> $candidate {
    say "{$candidate} is {$candidate ~~ $regex ?? "an IP address" !! "not valid"}";
}
````

````
192.168.1.1 is an IP address
1.01.1.1 is not valid
10.109.0.1 is an IP address
10.0.0.1 is an IP address
````

### The Challenge

Making use of this regex, I adapted it to the IPv4 partition problem by first dropping the `.` separator and then using the `:exhaustive` adverb to find all possible matches.

````
multi find-ips(Str $input where / \d ** 4..12 /) {
    gather {
        take .list.flat.join('.')
        for $input ~~ m:exhaustive
            / ^ ( <[1..9]> ** 0..2 \d <?{ $/.Int < 256 }> ) ** 4 $ /
    }
}
````

I added a `multi` variant to catch invalid input and a `MAIN` for running it.

```` raku
multi find-ips(Str $input) {
    note "Sorry: {$input} is not a valid input, it should be 4 to 12 digits.";
    exit 1
}

sub MAIN(Str $input) {
    CATCH { default { .say } }

    my @ips = find-ips($input);
    say "Found {+@ips} potential IP address{+@ips == 1 ?? '' !! 'es'} in {$input}:";
    say @ips.join("\n").indent(4);
}
````

````
./ipv4-partition.raku 25525511135
````

````
Found 2 potential IP addresses in 25525511135:
    255.255.111.35
    255.255.11.135
````


````
./ipv4-partition.raku 4444
````

````
Found 1 potential IP address in 4444:
    4.4.4.4
````

````
./ipv4-partition.raku 11
````

````
Sorry: 11 is not a valid input, it should be 4 to 12 digits.
````

````
./ipv4-partition.raku 19216812
````

````
Found 9 potential IP addresses in 19216812:
    192.168.1.2
    192.16.81.2
    192.16.8.12
    192.1.68.12
    19.216.81.2
    19.216.8.12
    19.21.68.12
    19.2.168.12
    1.92.168.12
````
