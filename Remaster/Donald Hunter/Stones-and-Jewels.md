# Stones and Jewels

*Originally published on [18 September 2019]()https://donaldh.wtf/2019/09/stones-and-jewels/ by Donald Hunter.*

This is a solution to task #1 from the 26th Weekly Challenge, written in Raku.

> Create a script that accepts two strings, let us call it, “stones” and “jewels”. It should print the count of “alphabet” from the string “stones” found in the string “jewels”. For example, if your stones is “chancellor” and “jewels” is “chocolate”, then the script should print “8”. To keep it simple, only A-Z,a-z characters are acceptable. Also make the comparison case sensitive.

The problem can be solved with a one-liner:

```` raku
[+] 'chancellor'.comb.Bag{'chocolate'.comb(/<[A..Z a..z]>/).Bag.keys}
````

returns:

````
8
````

Let's break that up a bit and describe the details:

```` raku
[+]                            # reduce to the sum of values
  'chancellor'
    .comb                      # Literally 'comb' out the characters
    .Bag                       # into a bag counting the characters
                               #   Bag(a, c(2), e, h, l(2), n, o, r)
   {                           # Take a slice of the stones bag
     'chocolate'
       .comb(/<[A..Z a..z]>/)  # 'comb' out the accepted characters from jewels
       .Bag                    # into a bag
       .keys                   # giving a set of unique characters
                               #   (o a t l e h c)
   }                           # Slice returns the count of stone characters
                               #   for each jewel character (2 0 1 1 1 2 1)
````

Note that there's no need to filter the stones for valid characters since we only pick jewels which are already known to be valid.

To complete the task, we need to turn the one-liner into a usable script.

```` raku
#!/usr/bin/env raku

sub MAIN(Str $stones, Str $jewels) {
    my $found = [+] $stones.comb.Bag{ $jewels.comb(/<[A..Z a..z]>/).Bag.keys };
    say "There are {$found} jewels to be found";
}
````

For example:

````
./stones-and-jewels.p6
````

````
Usage:
  ./stones-and-jewels.p6 <stones> <jewels>
````

````
./stones-and-jewels.p6 chancellor chocolate
````

````
There are 8 jewels to be found
````

````
./stones-and-jewels.p6 'Chancellor Bing' 'chocolate boy'
````

````
There are 7 jewels to be found
````
