# 'Et tu, bruteforce?'
    
*Originally published on [5 May 2009](http://strangelyconsistent.org/blog/et-tu-bruteforce) by Carl Mäsak.*

*(Alternative title: "My undying love for `.kv` on lists")*

Knuth's ['Facsicle 0a'](https://www-cs-faculty.stanford.edu/~knuth/taocp.html) starts with a kind of programmer's cliffhanger:

> Combinatorics is the study of the ways in which discrete objects can be arranged into various kinds of patterns. For example the objects might be *2n* numbers {1,1,2,2, ..., *n*, *n*}, and we might want to place them in a row so that exactly *k* numbers occur between the two appearances of each digit *k*. When *n* = 3 there is essentially only one way to arrange such "Langford pairs," namely 231213 (and its left-right reversal); similarly there's also a unique solution when *n* = 4.

He moves on to other things without divulging what the unique solution for *n* = 4 might be. Reading this (on a bus carrying me between cities in Sweden), I flung open a terminal window to write a one-liner to solve the problem. Don't know if Knuth intended to have that effect on the reader, but that's what happened when I read it.

My one-liners are infamously long. Here's what I arrived at:

```raku
# Generate all possible permutations of the list @a. The list @prefix
# assists in the recursion, adding its elements before the reordered
# elements of @a.
sub all-possible-orderings(@a, @prefix=[]) {
    return [@prefix] unless @a.elems;
    return gather for @a.kv -> $k, $v {
        my @others = @a[0..^$k, $k^..^*];
        take all-possible-orderings(@others, [@prefix, $v]);
    }
}
# Returns True if and only if the list @a satisfies the
# Langford property, i.e. each pair of numbers $n has
# exactly $n other numbers between them.
sub langford(@a) {
    for 1..@a/2 -> $n {
        for @a.kv -> $k1, $v1 {
            if $v1 == $n {
                for @a[$k1^..^*].kv -> $k2, $v2 {
                    return False if $v2 == $n != $k2;
                }
            }
        }
    }
    return True;
}
.join.say for all-possible-orderings([1,1,2,2,3,3]).grep({ langford($_) }).uniq;
```

This code worked well for *n* = 3, but for *n* = 4 it just sat there. Kind of fitting, since the remainder of the Facsicle was about the futility of brute force, more or less. Kind of drove the point home, my PDF reader in the foreground saying things like "A single good idea can reduce the amount of computation by many orders of magnitude", while the `raku` process in a window behind it chewed up all my cycles and all my memory.

So I gave it another go.

```raku
# Generates a list of all permutations of the list @candidates
# satisfying the Langford property.
sub langford(@candidates, @slots = [0 xx 2*@candidates]) {
    return [@slots] if all @slots;
    my @found;
    for @candidates -> $c {
        for @slots[0..@slots-$c-2].kv -> $k, $v {
            if !$v {
                if !@slots[$k+$c+1] {
                    my @new-slots = @slots;
                    @new-slots[$k, $k+$c+1] = $c, $c;
                    push @found, langford( (grep { $_ != $c }, @candidates),
                                           @new-slots );
                }
                last;
            }
        }
    }
    return @found;
}
.join.say for langford 1..4;
```

(*moritz*++ for the nice line `return [@slots] if all @slots;` where I had previously used a `grep`.)

Notice how this solution, besides being faster, is also shorter, simpler, and more fun at parties. It does the *n* = 4 case in a jiffy, and the *n* = 7 and *n* = 8 cases with some hesitation. It could probably easily go higher than that without blowing the stack, but time starts to become the limiting factor at this point.

Anyway, a fun afternoon experiment. It's 2009, and I'm solving combinatorics puzzles in Raku. Cool!

(Oh, and it's 23421314, in case you were wondering too.)
