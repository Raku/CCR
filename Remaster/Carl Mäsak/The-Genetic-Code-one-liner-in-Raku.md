# The Genetic Code one-liner in Raku
    
*Originally published on [6 July 2009](http://strangelyconsistent.org/blog/the-genetic-code-oneliner-in-perl-6) by Carl Mäsak.*

Today on #raku:

```
<masak> rakudo: subset DNA of Str where { all(.uc.comb) eq any <A C G T> }; my DNA $dna = "gattaca"; say $dna;
<p6eval> rakudo 0e8a86: OUTPUT«gattaca␤»
<jnthn> rakudo: subset DNA of Str where { all(.uc.comb) eq any <A C G T>}; my DNA $dna = "lolnotdna"; say $dna;
<p6eval> rakudo 0e8a86: OUTPUT«Assignment type check failed [...]
<jnthn> (just checking :-))
<*TimToady*> course, where not /<-[ACGTactg]>/ might beat all those
<moritz_> but it involves no junction, so it can't be any good :-)
<*TimToady*> ttaggg &
<masak> halp, *TimToady* is speaking in DNA bases!
<masak> is my hunch right, and that actually means something as amino acids?
* masak checks
<pyrimidine> yes
<masak> *TimToady*++
<masak> rakudo: my $dna = "ttaagg"; sub translate($dna) { "FFLLSSSSYY!!CC!WLLLLPPPPHHQQRRRRIIIMTTTTNNKKSSRRVVVVAAAADDEEGGGG".comb[map { :4($_) }, $dna.trans("tcag" => "0123").comb(/.../)] }; say translate($dna)
<p6eval> rakudo 0e8a86: OUTPUT«LR␤»
<masak> that's what I got too.
<pyrimidine> masak: nice!
<masak> I know! :)
<masak> I should blog about it.
<masak> "The <a href='https://en.wikipedia.org/wiki/Genetic_code'>Genetic Code</a> one-liner in Raku"
```

A hyper-short summary of what that one-liner does:

- Convert each base into an integer. `$dna.trans("tcag" => "0123")` 
- Break up the DNA numbers in triplets. `.comb(/.../)` 
- Interpret each three-digit number as a [quaternary](https://en.wikipedia.org/wiki/Quaternary_numeral_system) integer between 0 and 63. `map { :4($_) }` 
- Use these numbers as indexes into an array of 64 one-character strings, each with the character of one amino acid.

Raku feels more like a power tool every day.
