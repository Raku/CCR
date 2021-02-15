# Postal Words

*Originally published on [24 June 2019](https://donaldh.wtf/2019/06/postal-words/) by Donald Hunter.*

This is a solution to challenge #2 from the [Weekly Challenge #14](https://perlweeklychallenge.org/blog/perl-weekly-challenge-014/), written in Raku.

> Using only the official postal (2-letter) abbreviations for the 50 U.S. states, write a script to find the longest English word you can spell?

I copied the table of codes and abbreviations from the [wikipedia page](https://en.wikipedia.org/wiki/List_of_U.S._state_abbreviations). The [data](us-abbrevs.txt) is tab separated like this:

````
Alabama 	State	US-AL	AL	01	AL	AL	Ala.	Ala.
Alaska  	State	US-AK	AK	02	AK	AK	Alaska	Alaska	Alas.
Arizona 	State	US-AZ	AZ	04	AZ	AZ	Ariz.	Ariz.	Az.
Arkansas	State	US-AR	AR	05	AR	AR	Ark.	Ark.
California	State	US-CA	CA	06	CA	CF	Calif.	Calif.	Ca., Cal.
````

I read the data, split by tab, picked the name and postal-code columns (0 and 5) and put the data in a hash by postal-code:

```` raku
my %states = (.split(/\t/)[0,5] for 'us-abbrevs.txt'.IO.lines).flat.map: -> $a, $b { $b.lc => $a };
````

Produces:
````
{ak => Alaska, al => Alabama, ar => Arkansas, az => Arizona, ca => California, co => Colorado, ct => Connecticut, de => Delaware, fl => Florida, ga => Georgia, hi => Hawaii, ia => Iowa, id => Idaho, il => Illinois, in => Indiana, ks => Kansas, ky => Kentucky, la => Louisiana, ma => Massachusetts, md => Maryland, me => Maine, mi => Michigan, mn => Minnesota, mo => Missouri, ms => Mississippi, mt => Montana, nc => North Carolina, nd => North Dakota, ne => Nebraska, nh => New Hampshire, nj => New Jersey, nm => New Mexico, nv => Nevada, ny => New York, oh => Ohio, ok => Oklahoma, or => Oregon, pa => Pennsylvania, ri => Rhode Island, sc => South Carolina, sd => South Dakota, tn => Tennessee, tx => Texas, ut => Utah, va => Virginia, vt => Vermont, wa => Washington, wi => Wisconsin, wv => West Virginia, wy => Wyoming}
````

I decided to use ~/usr/share/dict/words~ as a corpus, which contains 235886 words on my Mac. We only need to consider words with an even number of characters:

```` raku
my @words = '/usr/share/dict/words'.IO.lines.grep: *.chars %% 2;
````

I solved the challenge by recursively picking candidate words that have a substring that exists as a key in `%states`, starting with `.substr(0,2)` and looking further right with each recursion:

```` raku
sub reduce(@words, Int $pos = 0) {
    my @candidates = @words.grep: { %states{.substr($pos, 2)}:exists };
    if +@candidates {
        reduce(@candidates, $pos + 2);
    } else {
        @words;
    }
}

my @longest = reduce(@words);
````

The last step was to format the result by using `.comb` to get pairs of chars and taking a slice of `%states`:

```` raku
say %states{.comb(/\w\w/)}.join(' '), ' -> ', .Str for @longest;
````

Here is the complete solution:

```` raku
my %states = (.split(/\t/)[0,5] for 'us-abbrevs.txt'.IO.lines).flat.map: -> $a, $b { $b.lc => $a };
my @words = '/usr/share/dict/words'.IO.lines.grep: *.chars %% 2;
say "Searching {+@words} words";

sub reduce(@words, Int $pos = 0) {
    my @candidates = @words.grep: { %states{.substr($pos, 2)}:exists };
    if +@candidates {
        reduce(@candidates, $pos + 2);
    } else {
        @words;
    }
}

my @longest = reduce(@words);
say %states{.comb(/\w\w/)}.join(' '), ' -> ', .Str, ' (', .chars, ')' for @longest;
````

````
Searching 118695 words
California Colorado Georgia Louisiana Connecticut Iowa -> cacogalactia (12)
````
