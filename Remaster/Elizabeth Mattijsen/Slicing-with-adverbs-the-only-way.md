# Slicing with adverbs, the only way!
    
*Originally published on [12 December 2013](https://perl6advent.wordpress.com/2013/12/12/day-12-slicing-with-adverbs-the-only-way/) by Elizabeth Mattijsen.*

My involvement with adverbs in Raku began very innocently. I had the idea to creating a small, lightning talk size presentation about how the Perl fat arrow corresponds to Raku’s fatarrow and adverbs. And how they relate to hash / array slices. And then had to find out you couldn’t combine them on hash / array slices. Nor could you pass values to them.

And so started my first bigger project on Rakudo Raku. Making adverbs work as specced on hashes and arrays, and on the way, expand the spec as well. So, do they now work? Well, all spectests pass. But while preparing this blog post, I happened to find [a bug](https://github.com/Raku/old-issue-tracker/issues/3290) which is now waiting for my further attention. There’s always one more bug.

What are the adverbs you can use with hash and array slices?

| name    | description                                   |
| :------ | :-------------------------------------------- |
| :exists | whether element(s) exist(ed)                  |
| :delete | remove element(s), return value (if any)      |
| :kv     | return key(s) and value(s) as separate values |
| :p      | return key(s) and value(s) as `Pair`s         |
| :k      | return key(s) only                            |
| :v      | return existing value(s) only                 |

## :exists

This adverb replaces the now deprecated `.exists` method.  Adverbs provide a generic interface to hashes and arrays, regardless of number of elements requested.  The `.exists` method only ever allowed checking for a single key.

Examples speak louder than words.  To check whether a single key exists:

```` raku
$ raku -e 'my %h = a=>1, b=>2; say %h<a>:exists’
True
````

If we expand this to a slice, we get a `List` of boolean values:

```` raku
$ raku -e 'my %h = a=>1, b=>2; say %h<a b c>:exists'
True True False
````

Note that if we ask for a single key, we get a boolean value back, not a `List` with one Bool in it.

```` raku
$ raku -e 'my %h = a=>1, b=>2; say (%h<a>:exists).WHAT’
(Bool)
````

If it is clear that we ask for multiple keys, or not clear at compile time that we are only checking for one key, we get back a `List`:

```` raku
$ raku -e 'my %h = a=>1, b=>2; say (%h<a b c>:exists).WHAT’
(List)
$ raku -e 'my @a="a"; my %h = a=>1, b=>2; say (%h{@a}:exists).WHAT'
(List)
````

Sometimes it is handier to know if something does **not** exist.  You can easily do this by negating the adverb by prefixing it with **!**: they’re really just like named parameters anyway!

```` raku
$ raku -e 'my %h = a=>1, b=>2; say %h<c>:!exists'
True
````

## :delete

This is the only adverb that actually can make changes to the hash or array it is (indirectly) applied to.  It replaces the now deprecated *.delete* method.

```` raku
$ raku -e 'my %h = a=>1, b=>2; say %h<a>:delete; say %h.raku'
1
{"b" => 2}
````

Of course, you can also delete slices:

```` raku
$ raku -e 'my %h = a=>1, b=>2; say %h<a b c>:delete; say %h.raku'
1 2 (Any)
{}
````

Note that the **(Any)** is the value returned for the non-existing key.  If you happened to have given the hash a *default* value, it would have looked like this:

```` raku
$ raku -e 'my %h is default(42) = a=>1, b=>2; say %h<a b c>:delete; say %h.raku'
1 2 42
{}
````

But the behaviour of the *is default* maybe warrants a blog post of itself, so I won’t go into it now.

Like with `:exists`, you can negate the :delete adverb.  But there wouldn’t be much point, as you might have well not specified it at all.  However, since adverbs are basically just named parameters, you **can** make the :delete attribute conditional:

```` raku
$ raku -e 'my $really = True; my %h = a=>1, b=>2; say %h<a b c>:delete($really); say %h.raku'
1 2 (Any)
{}
````

Because the value passed to the adverb was true, the deletion actually took place.  However, if we pass a false value:

```` raku
$ raku -e ‘my $really; my %h = a=>1, b=>2; say %h<a b c>:delete($really); say %h.raku'
1 2 (Any)
{"a" => 1, "b" => 2}
````

It doesn’t.  Note that the return value did not change: the deletion was simply **not** performed.  This can e.g. be very handy if you have a subroutine or method doing some kind of custom slice, and you want to have an optional parameter indicating whether the slice should be deleted as well: simply pass that parameter as the adverb’s value!

## :kv, :p, :k, :v

These 4 attributes modify the returned values from any hash / array slice.  The **:kv** attribute returns a `List` with keys and values interspersed.  The **:p** attribute returns a `List` of Pairs.  The **:k** and **:v** attributes return the key only, or the value only.

```` raku
$ raku
> my %h = a => 1, b => 2;
{"a" => 1, "b" => 2}
> %h<a>:kv
a 1
> %h<a>:p
"a" => 1
> %h<a>:k
a
> %h<a>:v
1
````

Apart from modifying the return value, these attributes **also** act as a filter for existing keys only.  Please note the difference in return values:

```` raku
> %h<a b c>
1 2 (Any)
> %h<a b c>:v
1 2
````

Because the *:v* attribute acts as a filter, there is no *(Any)*.  But sometimes, you want to not have this behaviour.  To achieve this, you can negate the attribute:

```` raku
> %h<a b c>:k
a b
> %h<a b c>:!k
a b c
````

## Combining adverbs

You can also combine adverbs on hash / array slices.  The most useful combinations are with one or two of `:exists` and `:delete`, with zero or one of `:kv, :p, :k, :v`.  Some examples, like putting a slice out of one hash into a new hash:

```` raku
$ raku -e 'my %h = a=>1, b=>2; my %i = (%h<a c>:delete:p).list; say %h.raku; say %i.raku'
{"b" => 2}
{"a" => 1}
````

Or the keys that were actually deleted:

```` raku
$ raku -e 'my %h = a=>1, b=>2; say %h<a b c>:delete:k’
a b
````

We actually [have a spec](http://design.raku.org/syn/S02.html#Combining_subscript_adverbs) that describes which combinations are valid, and what they should return.

## Arrays are not Hashes

Apart from hashes using {} for slices, and arrays [] for slices, the adverbial syntax for hash and array slices are the same. But there are some subtle differences.  First of all, the "key" of an element in an array, is its **index**.  So, to show the indexes of elements in an array that have a defined value, one can use the `:k` adverb:

```` raku
$ raku -e 'my @a; @a[3] = 1; say @a[]:k'
3
````

Or, to create a `List` with all elements in an array:

```` raku
$ raku -e 'my @a; @a[3] = 1; say @a[]:!k’
0 1 2 3
````

However, deleting an element from an array, is similar to assigning **Nil** to it, so it will return its default value (usually (Any)):

```` raku
$ raku -e 'my @a = ^10; @a[3]:delete; say @a[2,3,4]; say @a[2,3,4]:exists'
2 (Any) 4
True False True
````

If we have specified a default value for the array, the result is slightly different:

```` raku
$ raku -e 'my @a is default(42) = ^10; @a[3]:delete; say @a[2,3,4]; say @a[2,3,4]:exists'
2 42 4
True False True
````

So, even though the element "does not exist", it can return a defined value!  As said earlier, that may become a blog post for another day!

## Conclusion

Slices with adverbs are a powerful way of handling your data structures, be they hashes or arrays.  It will take a while to get used to all of the combinations of adverbs that can be specified.  But once you’re used to them, they provide you with a concise way of dicing and slicing your data that would previously have involved more elaborate structures with loops and conditionals.  Of course, if you want to, you can still do that: it’s not illegal to program Perl in Raku :-)

