# The Vigenère Cipher

*Originally published on [4 July 2019](https://donaldh.wtf/2019/07/the-vigenère-cipher/) by Donald Hunter.*

This is a solution to task #2 from the [Weekly Challenge #15](https://perlweeklychallenge.org/blog/perl-weekly-challenge-015/), written in Raku.

> Write a script to implement Vigenère cipher. The script should be able encode and decode.

The [Vigenère Cipher](https://en.wikipedia.org/wiki/Vigen%C3%A8re_cipher) is a method of encryption that uses a series of Caesar ciphers chosen using the letters of a repeating key.

Two solution approaches spring to mind:

- Use a Vigenère square as a lookup table
- Compute the rotations directly

I have chosen to compute the rotations directly. As an aside, here is a one-liner to construct a Vigenère square:

```` raku
my @vigenère-square[26;26] = (^26).map: -> $n { ('A'..'Z').List.rotate($n) }
````

The encode and decode operations can be implemented with exactly the same algorithm, with the only difference being whether to add or subtract the key offset.

Here is my solution in full:

```` raku
enum Operation <encode decode>;

#| Apply the Vigenère Cipher to text from STDIN, using the provided key.
sub MAIN(
    Operation $operation, #= encode or decode
    Str $key)             #= Key to use
{
    my @key-values = $key.uc.comb(/<[A..Z]>/).map(*.ord - 'A'.ord);

    slurp.uc.comb(/<[A..Z]>/).map(*.ord - 'A'.ord)
    .map(-> $n {
                LEAVE @key-values .= rotate(1);
                given $operation {
                    when encode {
                        ($n + @key-values[0]) % 26;
                    }
                    when decode {
                        ($n + 26 - @key-values[0]) % 26;
                    }
                }
            })
    .map(* + 'A'.ord).rotor(60, :partial).map(*.chrs.join.say);
}
````

The encode/decode transforms are performed in `0..25` number space.  The input data is normalized to uppercase and only the letters `A..Z` are processed. The solution ignores all other characters both in the source text and the key.

I have also added `POD` comments to the `MAIN` sub and to its parameters. This produces some nice friendly command-line usage. It is worth noting that source layout matters when using `POD` comments to generate usage. The parameter comments need to be attached to the parameters so each parameter is on its own line.

````
% ./Vigenère.raku
Usage:
  ./Vigenère.raku <operation> <key> -- Apply the Vigenère Cipher to text from STDIN, using the provided key.

    <operation>    encode or decode
    <key>          Key to use
````

Here is the example from the [Wikipedia page](https://en.wikipedia.org/wiki/Vigen%C3%A8re_cipher):

````
% echo 'ATTACKATDAWN' | ./Vigenère.raku encode 'LEMON'
LXFOPVEFRNHR
% echo 'Attack at dawn!' | ./Vigenère.raku encode 'lemon'
LXFOPVEFRNHR
% echo 'LXFOPVEFRNHR' | ./Vigenère.raku decode 'Lemon'
ATTACKATDAWN
````

Here is an example with a longer source text:

````
% fortune | ./Vigenère.raku encode fortune
XKVKPRQJHYXJNXMHFFSSMCSUIOETTGVBMYENRNBNUMWCEKUVPXKYXLRSSAPL
IHPNGXKIBZJRKHLHRTJVKOAWTIEWYQKTFXXMGLWCLZBGLJFZYFRHMSRKNFSK
AFNHGENBJNHQIWHFKLRRYGSXXFYSSIKCAKQMZKOFLHOGMUVRFVRUGBFDRZVE
````

As an added bonus, the solution uses `.rotor` to wrap the output text to 60 columns, regardless
of the input format.
