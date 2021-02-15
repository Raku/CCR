# Van Eck by'eck

*Originally published on [24 June 2019](https://donaldh.wtf/2019/06/van-eck-byeck/) by Donald Hunter.*

This is a solution to challenge #1 from the [Weekly Challenge #14](https://perlweeklychallenge.org/blog/perl-weekly-challenge-014/).

> Write a script to generate Van Eck’s sequence starts with 0.

I thought it would be fun to try and solve this using the `...` sequence operator. This first solution is very naive; it retains all generated values internally and uses `grep` to find previous occurrences.

```` raku
my $van-eck := 0, -> $a {
    state @items.push($a);
    my ($m, $n) = @items.grep($a, :k).tail(2);
    $n.defined ?? $n - $m !! 0
} ... *;

say $van-eck[^30].join(', ');
say "Took " ~ (now - ENTER now) ~ " seconds";

say $van-eck[5000..^5030].join(', ');
say "Took " ~ (now - ENTER now) ~ " seconds";
````

````
0, 0, 1, 0, 2, 0, 2, 2, 1, 6, 0, 5, 0, 2, 6, 5, 4, 0, 5, 3, 0, 3, 2, 9, 0, 4, 9, 3, 6, 14
Took 0.01310128 seconds
0, 5, 33, 776, 0, 4, 28, 447, 0, 4, 4, 1, 20, 60, 185, 340, 350, 1473, 0, 10, 35, 411, 910, 0, 5, 23, 232, 2110, 0, 5
Took 15.4696878 seconds
````

It is fine for a short sequence, but performance drops quite dramatically. A better solution is to retain the last seen index of each generated value, which vastly reduces the computation cost.

```` raku
my $van-eck := 0, -> $a {
    state $index++;
    state %last-seen; LEAVE %last-seen{$a} = $index;
    %last-seen{$a}:exists ?? $index - %last-seen{$a} !! 0
} ... *;

say $van-eck[^30].join(', ');
say "Took " ~ (now - ENTER now) ~ " seconds";

say $van-eck[5000..^5030].join(', ');
say "Took " ~ (now - ENTER now) ~ " seconds";
````

````
0, 0, 1, 0, 2, 0, 2, 2, 1, 6, 0, 5, 0, 2, 6, 5, 4, 0, 5, 3, 0, 3, 2, 9, 0, 4, 9, 3, 6, 14
Took 0.0081188 seconds
0, 5, 33, 776, 0, 4, 28, 447, 0, 4, 4, 1, 20, 60, 185, 340, 350, 1473, 0, 10, 35, 411, 910, 0, 5, 23, 232, 2110, 0, 5
Took 0.1163919 seconds
````

I didn't expect sequences to be this much fun ;-)
