# It's sort of like...
    
*Originally published on [12 December 2008](https://use-perl.github.io/user/pmichaud/journal/38080/) by Patrick Michaud.*

Earlier in the week, fw wrote a journal post about his [First Raku program](https://use-perl.github.io/user/fw/journal/38055).  I was quite excited to see this, but then read a comment from educated_foo that pointed out that the Perl version is actually shorter to write.

That didn't sit too well with me, because we really ought to make common things simpler, not harder.  What really bugged me (about Raku, not about fw's post) was the following for sorting a hash by values:

```raku
for %words.pairs.sort: { $^b.value <=> $^a.value } -> $pair {
    say $pair
}
```

Sorting hashes by value is a common operation, and although I can shorten the above a little bit

```raku
.say for %words.sort: { $^b.value <=> $^a.value };
```

it's still a bit long for my taste.  That `{ $^b.value <=> $^a.value }` just bugs me.

Then Moritz Lenz made a comment on #raku that perhaps sort should do something different with arity-1 blocks, and I then had an epiphany that led to the following pattern for sorting hashes by value:

```raku
%hash.sort: { .value }
```

I like this so much, I've gone ahead and implemented it in Rakudo, even though it's not officially part of the spec.  (I'm hoping it'll be adopted as such.)  So now in Rakudo we have the following:

```
> my %hash = { c=>5, b=>7, a=>-4, e=>9, d=>0 };
> .say for %hash.sort: { .value }
a       -4
d       0
c       5
b       7
e       9

> .say for %hash.sort: { .key }
a       -4
b       7
c       5
d       0
e       9
```

That seems much nicer.  The general principal is that if the comparison argument to "sort" takes less than two arguments, then it's used to generate the *values* to be compared instead of the result of a comparison.

Of course, we aren't limited to just keys or values -- any operation we want to perform on the items being sorted will work.  To sort by the *magnitude* of the values of the hash:

```
> .say for %hash.sort: { .value.abs }
d       0
a       -4
c       5
b       7
e       9
````

And of course this generalizes to more than just hashes; if `@dogs` contains a list of Dog objects we want to sort:

```raku
@dogs.sort: { .name }      # sort dogs by name
@dogs.sort: { .age }       # sort dogs by age
````

This works because the ".name" and ".age" methods are invoked on each of the objects in the list to determine the value to use for that object in the sort.

Or for a simplistic case-insensitive sort:
```
> my @a = <Fruit CHERRY danish Apple berry BaNaNa apricot>;
> .say for @a.sort: { .lc }
Apple
apricot
BaNaNa
berry
CHERRY
danish
Fruit
````

Besides clarity, another big advantage of

```raku
@a.sort: { .lc }
````

over

```raku
@a.sort: { $^a.lc leg $^b.lc }
````

is that in the first version we compute .lc on each element only once for the entire sort, whereas in the second version it's computed once for each comparison.  And since we're typically doing O(n^2) comparisons, the first version can save a lot of method or function calls.

So, that was my fun for the morning.  Implementing this behavior turned out to be really easy -- in fact, I wrote the algorithm first as Raku before translating it into PIR:
```raku
multi method sort(@values: &by) {
    ...
    if &by.arity < 2 {
        my @v     = @values.map(&by);
        my @slice = (0..^@v).sort: { @v[$^a] cmp @v[$^b] };
        return @values[ @slice ];
    }
    ...
}
````

The code just uses &by to compute the values (@v) to be used in the sort, does a sort on the indexes based on a comparison of those values, and uses the resulting sorted index list to return the (sorted) slice of the original list.  Note that the items in the result list are themselves unchanged from the original list -- they simply have a new sequence according to the &by criteria.

Since then *PerlJam*++ has suggested that we should do similar things for `min` and `max`:

```` raku
my $longest_string = @strings.max( { .chars } );
````

This would use .chars as the criteria for determining the longest string but returns the longest string itself.

Raku is very cool.

P.S.:  By the way, this means that the solution to the problem in fw's original post becomes:

```raku
my %words;
$*IN.slurp.comb.map: { %words{$_}++ };
.say for reverse %words.sort: { .values };
````

Not all of the above works in Rakudo yet (I think `.comb` is not yet implemented), but at least it's getting closer to what we'd really like to see here.
