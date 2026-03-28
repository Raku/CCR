# Plain old assignment, and freaky binding
    
*Originally published on [16 March 2010](http://strangelyconsistent.org/blog/plain-old-assignment-and-freaky-binding) by Carl Mäsak.*

What happens when we do assignment? When we do `$a = 42;`, for example.

Intuitively, in almost every language, what happens is at least something like this: the *symbol* `$a` becomes associated with the *value* `42`. In pseudo instruction code, it might look something like this:

```raku
my $a; $a = 42;
$0 = 42
store '$a', $0`
```

(Feel free to read `$0` et al. as "some register in the VM". And to fantasize liberally about the opcodes.)

From this model, we expect variables to be independent, even when we've assigned from one to the other. So in this piece of code...

```raku
my $a = 42; my $b = $a; $a = 5;
$0 = 42
store '$a', $0
$1 = fetch '$a'
store '$b', $1
$2 = 5
store '$a', $2`
```

...we expect `$b` to still be associated with the value `42`, and not to have suffered some freaky action-at-a-distance which causes it to be changed when `$a` is assigned to `5`.

"Well, obviously `$b` won't do that", you interject. "It can't, if we believe in the model in which there are only symbols and their associated values. No freaky action-at-a-distance can occur." And that's right, as far as that goes.

But it turns out that Raku allows a middle abstraction layer between symbols and values. The entities occupying this middle layer are usually referred to as "containers", but that's a terribly overloaded term. I'll call them "buckets" in this post, hoping I won't throw some hash expert into a fit. 哈哈

To explain the behavior of (and need for) buckets, let's take an almost identical example as the one above:

```raku
my $a = 42; my $b := $a; $a = 5;
$0 = 42
store '$a', $0
bind '$b', '$a'
$1 = 5
store '$a', $1`
```

(Note the two surface differences from the earlier example: `:=` rather than `=`, and `bind` rather than `assign`.)

The state at the end of this new program *is* a case of freaky action-at-a-distance. When the value of `$a` is changed to `5` in the last statement, the value of `$b` will also be changed to `5`.

The reason for this is simple: the `:=` (and the `bind`) causes the symbol `$b` not to have a bucket all of its own, but to acquire `$a`'s bucket. When `5` is subsequently stored in that bucket, both `$a` and `$b` are simultaneously affected, since the two symbols share one and the same bucket.

Now as a language feature, freaky action-at-a-distance may at first seem to be situated somewhere on a spectrum between "useless" and "dangerous". But it is the feature that makes pass-by-reference parameter passing work:

```raku
my $a = 42;
foo($a); # freaky!
say $a;  # 5
sub foo($b is rw) {
    $b = 5;
}
```

Note how that's practically the same example as the above with binding, except that it's now mediated through a layer of parameter passing. But `$a` and `$b` still share one single bucket, as before.

I only have two more things to say about this. First, *jnthn*++ explained in Copenhagen that the difference between scalar bucket and an array/hash bucket is that the former always forwards method calls to the value it contains. I don't grok that yet, so I may have got it wrong.

Second, there's still a way to circumvent buckets, assigning values directly to symbols:

```raku
my $a := 42;
$0 = 42
bind '$a', $0`
```

What this means is simply that the variable `$a` is bound directly to a value, and has no buckets to which one can assign new values. It's a bit like a read-only value, except that `$a` can still be rebound to something else.

These are the kinds of thoughts one gets when starting to write a time-travelling debugger.
