# String Interpolation and the Zen Slice
    
*Originally published on [13 December 2014](https://perl6advent.wordpress.com/2014/12/13/day-13-string-interpolation-and-the-zen-slice/) by Elizabeth Mattijsen.*

So you think you know all about string interpolation in Raku?

Well, especially coming from Perl, you may find some things that do not work exactly as you’re used to.  The simple examples all work, as it seems:

```` raku
my $a = 42;
say 'value = $a';   # value = $a
say "value = $a";   # value = 42

my @a = ^10;
say 'value = @a';   # value = @a
say "value = @a";   # value = @a    HUH??
````

In earlier versions of Perl 5 (or was it Perl 4?), this gave the same result.  At one point, it was decided that arrays would be interpolated in double quoted strings as well.  However, this caused quite a few problems with double quoted texts with email addresses in them: you would need to escape each **@** (if you were using *strict*, which you of course should have).  And if you forgot, and there was an array that just happened to have the same name as the user part of an email address, you would be in for a surprise.  Or if you didn’t use *strict*, you would suddenly have the text **without** the email address.  But then again, you got what you asked for.

So how can we make this work in Raku?

### Introducing the Zen slice

The Zen slice on an object, returns the object.  It’s like you specify nothing, and get everything.  So what does that look like?

```` raku
my @a = ^10;
say "value = @a[]";   # value = 0 1 2 3 4 5 6 7 8 9
````

You will have to make sure that you use the right indexers for the type of variable that you’re interpolating.

```` raku
my %h = a => 42, b => 666;
say "value = %h{}";   # value = a 42 b 666
````

Note that the Zen slice on a hash returns both keys and values, whereas the Zen slice on an array only returns the values.  This seems inconsistent, until you realize that you can think of a hash as a list of Pairs.

The Zen slice only really exists at compile time.  So you will not get everything if your slice specification is an empty list at runtime:

```` raku
my @a;
my %h = a => 42, b => 666;
# a slice, but not a Zen slice:
say "value = %h{@a}";   # value =
````

So the only way you can specify a Zen slice, is if there is nothing (but whitespace) between the slice delimiters.

### The Whatever slice

The **\*** ( *Whatever* ) slice is different.  The Whatever will just fill in all *keys* that exist in the object, and thus only return the values of a hash.

```` raku
my %h = a => 42, b => 666;
say "value = %h{*}";   # value = 42 666
````

For arrays, there isn’t really any difference at the moment (although that may change in the future when multi-dimensional arrays are fleshed out more).

### Interpolating results from subs and methods

In double quoted strings, you can also interpolate subroutine calls, as long as they start with an ‘*&*‘ and have a set of parentheses (even if you don’t want to pass any arguments):

```` raku
sub a { 42 }
say "value = &`a`";   # value = 42
````

But it doesn’t stop at calling subs: you can also call a method on a variable as long as they have parentheses at the end:

```` raku
  my %h = a => 42, b => 666;
  say "value = %h.`keys`";  # value = b a
````

And it doesn’t stay limited to a single method call: you can have as many as you want, provided the last one has parentheses:

```` raku
my %h = a => 42, b => 666;
say "value = %h.perl.EVAL.perl.EVAL.`perl`";  # value = ("b" => 666, "a" => 42).hash
````

### Interpolating expressions

If you want to interpolate an expression in a double quoted string, you can also do that by providing an executable block inside the string:

```` raku
say "6 * 7 = { 6 * 7 }";   # 6 * 7 = 42
````

The result of the execution of the block, is what will be interpolated in the string.  Well, what really is interpolated in a string, is the result of calling the *.Str* method on the value.  This is different from just *say*ing a value, in which case the *.gist* method is called.  Suppose we have our own class with its own .gist and .Str methods:

```` raku
class A {
    method Str { "foo" }
    method gist { "bar" }
}
say "value = { A }"; # value = foo
say "value = ", A;   # value = bar
````

### Conclusion

String interpolation in Raku is very powerful.  As you can see, the Zen slice makes it easy to interpolate whole arrays and hashes in a string.

In this post I have only scratched the surface of string interpolation.  Please check out [Quoting on Steroids](Quoting-on-Steroids.md ) in a few days for more about quoting constructs.

