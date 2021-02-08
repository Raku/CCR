How subroutine signatures work in Raku
======================================

*Originally published on [12 September 2018](https://opensource.com/article/18/9/signatures-perl-6) by Elizabeth Mattijsen.*

In the [first article](Migrating-Perl-code-to-Raku.md) in this series comparing Perl to Raku, we looked into some of the issues you might encounter when migrating code into Raku. In the [second article](Garbage-Collection-in-Raku.md), we examined how garbage collection works in Raku, and in the [third article](Containers-in-Raku.md), we looked at how containers replaced references in Raku. Here in the fourth article, we will focus on (subroutine) signatures in Raku and how they differ from those in Perl.

Experimental signatures in Perl
-------------------------------

If you're migrating from Perl code to Raku, you're probably not using the [experimental signature feature](https://metacpan.org/pod/distribution/perl/pod/perlsub.pod#Signatures) that became available in Perl.20 or any of the older CPAN modules like [signatures](https://metacpan.org/pod/signatures), [Function::Parameters](https://metacpan.org/pod/Function::Parameters), or any of the other Perl modules on CPAN with ["signature" in their name](https://metacpan.org/search?q=signature).
  
Also, in my experience, [prototypes](https://metacpan.org/pod/perlsub#Prototypes) haven't been used very often in the Perl programs out in the world (e.g., the [DarkPAN](http://modernperlbooks.com/mt/2009/02/the-darkpan-dependency-management-and-support-problem.html)).

For these reasons, I will compare Raku functionality only with the most common use of "classic" Perl argument passing.

Argument passing in Perl
------------------------

All arguments you pass to a Perl subroutine are flattened and put into the automatically defined `@_` array variable inside. That is basically all Perl does with passing arguments to subroutines. Nothing more, nothing less. There are, however, several idioms in Perl that take it from there. The most common (I would say "standard") idiom in my experience is:

```` perl
# Perl
sub do_something {
    my ($foo, $bar) = @_;
    # actually do something with $foo and $bar
}
````

This idiom performs a list assignment (copy) to two (new) lexical variables. This way of accessing the arguments to a subroutine is also supported in Raku, but it's intended just as a way to make migrations easier.

If you expect a fixed number of arguments followed by a variable number of arguments, the following idiom is typically used:

```` perl
# Perl
sub do_something {
    my $foo = shift;
    my $bar = shift;
    for (@_) {
        # do something for each element in @_
    }
````

This idiom depends on the magic behavior of [shift](https://perldoc.perl.org/functions/shift.html), which shifts from `@_` in this context. If the subroutine is intended to be called as a method, something like this is usually seen:

```` perl
# Perl
sub do_something {
    my $self = shift;
    # do something with $self
}
````

as the first argument passed is the [invocant](https://docs.raku.org/routine/invocant) in Perl.

By the way, this idiom can also be written in the first idiom:

```` perl
# Perl
sub do_something {
    my ($foo, $bar, @rest) = @_;
    for (@rest) {
        # do something for each element in @rest
    }
}
````

But that would be less efficient, as it would involve copying a potentially long list of values.

The third idiom revolves on directly accessing the `@_` array.

```` perl
# Perl
sub sum_two {
    return $_[0] + $_[1];  # return the sum of the two parameters
}
````

This idiom is typically used for small, one-line subroutines, as it is one of the most efficient ways of handling arguments because no copying takes place.

This idiom is also used if you want to change any variable that is passed as a parameter. Since the elements in `@_` are aliases to any variables specified (in Raku you would say: "are bound to the variables"), it is possible to change the contents:

```` perl
# Perl
sub make42 {
    $_[0] = 42;
}
my $a = 666;
make42($a);
say $a;      # 42
````

Named arguments in Perl
-----------------------

Named arguments (as such) *don't exist* in Perl. But there is an often-used idiom that effectively mimics named arguments:

```` perl
# Perl
sub do_something {
    my %named = @_;
    if (exists $named{bar}) {
        # do stuff if named variable "bar" exists
    }
}
````

This initializes the hash `%named` by alternately taking a key and a value from the `@_` array. If you call a subroutine with arguments using the fat-comma syntax:

```` perl
# Perl
frobnicate( bar => 42 );
````

it will pass two values, `"foo"` and `42`, which will be placed into the `%named` hash as the value `42` associated with key `"foo"`. But the same thing would have happened if you had specified:

```` perl
# Perl
frobnicate( "bar", 42 );
````

The `=>` is syntactic sugar for automatically quoting the left side. Otherwise, it functions just like a comma (hence the name "fat comma").

If a subroutine is called as a method with named arguments, this idiom is combined with the standard idiom:

```` perl
# Perl
sub do_something {
    my ($self, %named) = @_;
    # do something with $self and %named
}
````

alternatively:

```` perl
# Perl
sub do_something {
    my $self  = shift;
    my %named = @_;
    # do something with $self and %named
}
````

Argument passing in Raku
------------------------

In their simplest form, subroutine signatures in Raku are very much like the "standard" idiom of Perl. But instead of being part of the code, they are part of the definition of the subroutine, and you don't need to do the assignment:

```` raku
# Raku
sub do-something($foo, $bar) {
    # actually do something with $foo and $bar
}
````

versus:

```` perl
# Perl
sub do_something {
    my ($foo, $bar) = @_;
    # actually do something with $foo and $bar
}
````

In Raku, the `($foo, $bar)` part is called the *signature* of the subroutine.

Since Raku has an actual `method` keyword, it is not necessary to take the invocant into account, as that is automatically available with the `self` term:

```` raku
# Raku
class Foo {
    method do-something-else($foo, $bar) {
        # do something else with self, $foo and $bar
    }
}
````

Such parameters are called *positional parameters* in Raku. Unless indicated otherwise, positional parameters *must* be specified when calling the subroutine.

If you need the aliasing behavior of using `$_[0]` directly in Perl, you can mark the parameter as writable by specifying the `is rw` trait:

```` raku
# Raku
sub make42($foo is rw) {
    $foo = 42;
}
my $a = 666;
make42($a);
say $a;      # 42
````

When you pass an array as an argument to a subroutine, it doesn't get flattened in Raku. You only need to accept an array as an array in the signature:

```` raku
# Raku
sub handle-array(@a) {
    # do something with @a
}
my @foo = "a" .. "z";
handle-array(@foo);
````

You can pass any number of arrays:

```` raku
# Raku
sub handle-two-arrays(@a, @b) {
    # do something with @a and @b
}
my @bar = 1..26;
handle-two-arrays(@foo, @bar);
````

If you want the ([variadic](https://en.wikipedia.org/wiki/Variadic_function)) flattening semantics of Perl, you can indicate this with a so-called "slurpy array" by prefixing the array with an asterisk in the signature:

```` raku
# Raku
sub slurp-an-array(*@values) {
    # do something with @values
}
slurp-an-array("foo", 42, "baz");
````

A slurpy array can occur only as the last positional parameter in a signature.

If you prefer to use the Perl way of specifying parameters in Raku, you can do this by specifying a slurpy array `*@_` in the signature:

```` raku
# Raku
sub do-like-5(*@_) {
    my ($foo, $bar) = @_;
}
````

Named arguments in Raku
-----------------------

On the calling side, named arguments in Raku can be expressed very similarly to how they are expressed in Perl:

```` perl
# Perl and Raku
frobnicate( bar => 42 );
````

However, on the definition side of the subroutine, things are very different:

```` raku
# Raku
sub frobnicate(:$bar) {
    # do something with $bar
}
````

The difference between an ordinary (positional) parameter and a named parameter is the colon, which precedes the <a href="https://www.perl.com/article/on-sigils/" style="outline: 1px dotted; outline-offset: 0px;">sigil</a><span style="color:#e74c3c;"> </span>and the variable name in the definition:

```` raku
# Raku
$foo      # positional parameter, receives in $foo
:$bar     # named parameter "bar", receives in $bar
````

Unless otherwise specified, named parameters are *optional*. If a named argument is not specified, the associated variable will contain the default value, which usually is the type object `Any`.

If you want to catch *any* (other) named arguments, you can use a so-called "slurpy hash." Just like the slurpy array, it is indicated with an asterisk before a hash:

```` raku
# Raku
sub slurp-nameds(*%nameds) {
    say "Received: " ~ join ", ", sort keys %nameds;
}
slurp-nameds(foo => 42, bar => 666); # Received: bar, foo
````

As with the slurpy array, there can be only one slurpy hash in a signature, and it must be specified after any other named parameters.

Often you want to pass a named argument to a subroutine from a variable with the same name. In Perl this looks like: `do_something(bar => $bar)`. In Raku, you can specify this in the same way: `do-something(bar => $bar)`. But you can also use a shortcut: `do-something(:$bar)`. This means less typing–and less chance of typos.

Default values in Raku
----------------------

Perl has the following idiom for making parameters optional with a default value:

```` perl
# Perl
sub dosomething_with_defaults {
    my $foo = @_ ? shift : 42;
    my $bar = @_ ? shift : 666;
    # actually do something with $foo and $bar
}
````

In Raku, you can specify default values as part of the signature by specifying an equal sign and an expression:

```` raku
# Raku
sub dosomething-with-defaults($foo = 42, :$bar = 666) {
    # actually do something with $foo and $bar
}
````

Positional parameters become optional if a default value is specified for them. Named parameters stay optional regardless of any default value.

Summary

Raku has a way of describing how arguments to a subroutine should be captured into parameters of that subroutine. Positional parameters are indicated by their name and the appropriate sigil (e.g., `$foo`). Named parameters are prefixed with a colon (e.g. `:$bar`). Positional parameters can be marked as `is rw` to allow changing variables in the caller's scope.

Positional arguments can be flattened in a slurpy array, which is prefixed by an asterisk (e.g., `*@values`). Unexpected named arguments can be collected using a slurpy hash, which is also prefixed with an asterisk (e.g., `*%nameds`).

Default values can be specified inside the signature by adding an expression after an equal sign (e.g., `$foo = 42`), which makes that parameter optional.

Signatures in Raku have many other interesting features, aside from the ones summarized here; if you want to know more about them, check out the Raku [signature object documentation](https://docs.raku.org/type/Signature).
