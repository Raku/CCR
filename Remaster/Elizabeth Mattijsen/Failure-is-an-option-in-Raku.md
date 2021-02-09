# Failure is an option in Raku

*Originally published on [22 November 2018](https://opensource.com/article/18/11/failure-option-perl-6) by Elizabeth Mattijsen.*

  
This is the eighth in a series of articles about migrating code from Perl to Raku. This article looks at the differences in creating and handling exceptions between Perl and Raku.

The first part of this article describes working with exceptions in Raku, and the second part explains how you can create your own exceptions and how failure *is* an option in Raku.

## Exception-handling phasers

In Perl, you can use [eval](https://perldoc.perl.org/functions/eval.html) to catch exceptions in a piece of code. In Raku, this functionality is covered by [`try`](https://docs.raku.org/language/exceptions#index-entry-try_blocks):

```` perl
# Perl
eval {
    die "Goodbye cruel world";
};
say $@;           # Goodbye cruel world at ...
say "Alive again!"
````

```` raku
# Raku
try {
    die "Goodbye cruel world";
}
say $!;           # Goodbye cruel world␤  in block ...
say "Alive again!"
````

In Perl, you can also use the return value of `eval` in an expression:

```` perl
# Perl
my $foo = eval { ... };  # undef if exception was thrown
````

This works the same way in Raku for `try`:

```` raku
# Raku
my $foo = try { 42 / $something };   # Nil if $something is 0
````

and it doesn't even have to be a block:

```` raku
# Raku
my $foo = try 42 / $something;       # Nil if $something is 0
````

In Perl, if you need finer control over what to do when an exception occurs, you can use special [signal handlers](https://perldoc.pl/variables/%25SIG) `$SIG{__DIE__}` and `$SIG{__WARN__}`.

In Raku, these are replaced by two exception-handling phasers, which due to their scoping behaviour *must* always be specified with curly braces. These exception-handling phasers (in the following table) are applicable only to the surrounding block, and you can have only *one* of each type in a block.

| Name    | Description                           |
| :------ | :------------------------------------ |
| CATCH   | Run when an exception is thrown       |
| CONTROL | Run for any (other) control exception |

The `$SIG{__DIE__}` pseudo-signal handler in Perl is no longer recommended. There are several competing CPAN modules that provide `try/catch` mechanisms (such as: [Try::Tiny](https://metacpan.org/pod/Try::Tiny) and [Syntax::Keyword::Try](https://metacpan.org/pod/Syntax::Keyword::Try)). Even though these modules differ completely in implementation, they provide very similar syntax with only very minor semantic differences, so they're a good way to compare Raku and Perl features.

In Perl, you can catch an exception only in conjunction with a `try` block:

```` perl
# Perl
use Try::Tiny;               # or Syntax::Keyword::Try
try {
    die "foo";
}
catch {
    warn "caught error: $_"; # $@ when using Syntax::Keyword::Try
}
````

Raku doesn't require a `try` block. The code inside a [`CATCH`](https://docs.raku.org/language/phasers#CATCH) phaser will be called whenever an exception is thrown in the *immediately surrounding* lexical scope:

```` raku
# Raku
{                        # surrounding scope, added for clarity
    CATCH {
        say "aw, died";
        .resume;         # $_, AKA the topic, contains the exception
    }
    die "goodbye cruel world";
    say "alive again";
}
# aw, died
# alive again
````

Again, you do *not* need a `try` statement to catch exceptions in Raku. You *can* use a `try` block on its own, if you want, but it's just a convenient way to disregard any exceptions thrown inside that block.

Also, note that `$_` will be set to the `Exception` object inside the `CATCH` block. In this example, execution will continue with the statement after the one that caused the `Exception` to be thrown. This is achieved by calling the `resume` method on the `Exception` object. If the exception is not resumed, it will be thrown again and possibly caught by an outer `CATCH` block (if there is one). And if there are no outer `CATCH` blocks, the exception will result in program termination.

The [`when`](https://docs.raku.org/language/control#default_and_when) statement makes it easy to check for a specific exception:

```` raku
# Raku
{
    CATCH {
        when X::NYI {       # Not Yet Implemented exception thrown
            say "aw, too early in history";
            .resume;
        }
        default {
            say "WAT?";
            .rethrow;       # throw the exception again
        }
    }
    X::NYI.new(feature => "Frobnicator").throw;  # caught, resumed
    now / 0;                                     # caught, rethrown
    say "back to the future";
}
# aw, too early in history
# WAT?
# Attempt to divide 1234.5678 by zero using /
````

In this example, only `X::NYI` exceptions will resume; all the others will be thrown to any outer `CATCH` block and will probably result in program termination. And we'll never go back to the future.

## Catching warnings

If you do *not* want any warnings to emanate when a piece of code executes, you can use the `no warnings` pragma in Perl:

```` perl
# Perl
use warnings;     # need to enable warnings explicitely
{
    no warnings;
    my $foo;
    say $foo;     # no visible warning
}
my $bar;
print $bar;
# Use of uninitialized value $bar in print...
````

In Raku, you can use a `quietly` block:

```` raku
# Raku
                  # warnings are enabled by default
quietly {
    my $foo;
    say $foo;     # no visible warning
}
my $bar;
print $bar;
# Use of uninitialized value of type Any in string context...
````

The `quietly` block will catch *any* warnings that emanate from that block and disregard them.

If you want finer control on which warnings you want to see, you can select the <a href="https://perldoc.pl/warnings#Category-Hierarchy">warning categories</a> you want enabled or disabled with `use warnings` or `no warnings`, respectively, in Perl. For example:

```` perl
# Perl
use warnings;
{
    no warnings 'uninitialized';
    my $bar;
    print $bar;    # no visible warning
}
````

If you want to have finer control in Raku, you will need a `CONTROL` phaser.

## CONTROL

The `CONTROL` phaser is very much like the `CATCH` phaser, but it handles a special type of exception called the "control exception." A control exception is thrown whenever a warning is generated in Raku, which you can catch with the `CONTROL` phaser. This example will *not* show warnings for using uninitialized values in expressions:

```` raku
# Raku
{
    CONTROL {
        when CX::Warn {  # Control eXception type for Warnings
            note .message
              unless .message.starts-with('Use of uninitialized value');
        }
    }
    my $bar;
    print $bar;          # no visible warning
}
````

There are currently no warning categories defined in Raku, but they are being discussed for future development. In the meantime, you will have to check for the actual `message` of the control exception `CX::Warn` type, as shown above.

The control exception mechanism is used for quite a lot of other functionality in addition to warnings. The following statements (in alphabetical order) also create control exceptions:

- [emit](https://docs.raku.org/language/control#supply/emit)
- [fail](https://docs.raku.org/language/control#fail)
- [last](https://docs.raku.org/language/control#last)
- [next](https://docs.raku.org/language/control#next)
- [proceed](https://docs.raku.org/language/control#proceed)
- [redo](https://docs.raku.org/language/control#redo)
- [return](https://docs.raku.org/language/control#return)
- [return-rw](https://docs.raku.org/language/control#return-rw)
- [succeed](https://docs.raku.org/language/control#succeed)
- [take](https://docs.raku.org/language/control#gather/take)

Control exceptions generated by these statements will also show up in any `CONTROL` phaser. Luckily, if you don't do anything with the given control exception, it will be rethrown when the `CONTROL` phaser is finished and ensure its intended action is performed.

## Failure is an option

In Perl, you need to prepare for a possible exception by using `eval` or some version of `try` when using a CPAN module. In Raku, you can do the same with `try` (as seen before).

But Raku also has another option: [`Failure`](https://docs.raku.org/type/Failure), which is a special class for wrapping an [`Exception`](https://docs.raku.org/type/Exception). Whenever a `Failure` object is used in an unanticipated way, it will throw the `Exception` it is wrapping. Here is a simple example:

```` raku
# Raku
my $handle = open "non-existing file";
say "we tried to open the file";
say $handle.get;  # unanticipated use of $handle, throws exception
say "this will never be shown";
# we tried to open the handle
# Failed to open file non-existing file: No such file or directory
````

The [`open`](https://docs.raku.org/routine/open#(IO)_sub_open) function in Raku returns an [`IO::Handle`](https://docs.raku.org/type/IO::Handle) if it successfully opens the requested file. If it fails, it returns a `Failure`. This, however, is *not* what throws the exception — if we actually try to *use* the `Failure` in an unanticipated way, *then* the `Exception` will be thrown.

There are only *two* ways of preventing the `Exception` inside a `Failure` to be thrown (i.e., anticipating a potential failure):

- Call the `.defined` method on the Failure
- Call the `.Bool` method on the Failure

In either case, these methods will return `False` (even though technically the `Failure` object *is* instantiated). Apart from that, they will *also* mark the `Failure` as "handled," meaning that if the `Failure` is later used in an unanticipated way, it will *not* throw the `Exception` but simply return `False`.

Calling `.defined` or `.Bool` on most other instantiated objects will always return `True`. This gives you an easy way to find out if something you expected to return a "real" instantiated object returned something you can really use.

However, it does seem like a lot of work. Fortunately, you don't have to explicitly call these methods (unless you really want to). Let's rephrase the above code to more gently handle not being able to open the file:

```` raku
# Raku
my $handle = open "non-existing file";
say "tried to open the file";
if $handle {                    # "if" calls .Bool, True on an IO::Handle
    say "we opened the file";
    .say for $handle.lines;     # read/show all lines one by one
}
else {                          # opening the file failed
    say "could not open file";
}
say "but still in business";
# tried to open the file
# could not open file
# but still in business
````

## Throwing exceptions

As in Perl, the simplest way to create an exception and throw it is to use the [`die`](https://docs.raku.org/routine/die) function. In Raku, this is a shortcut to creating an [`X::AdHoc`](https://docs.raku.org/type/X::AdHoc) `Exception` and throwing it:

```` perl
# Perl
sub alas {
    die "Goodbye cruel world";
    say "this will not be shown";
}
alas;
# Goodbye cruel world at ...
````

```` raku
# Raku
sub alas {
    die "Goodbye cruel world";
    say "this will not be shown";
}
# Goodbye cruel world
#   in sub alas at ...
#   in ...
````

There are some subtle differences between `die` in Perl and Raku, but semantically they are the same: they immediately stop an execution.

## Returning with a failure

Raku has added the [`fail`](https://docs.raku.org/syntax/%20fail) function. This will immediately return from the surrounding subroutine/method with the given `Exception`: if a string is supplied to the `fail` function (rather than an `Exception` object), then an `X::AdHoc` exception will be created.

Suppose you have a subroutine taking one parameter, a value that is checked for truthiness:

```` raku
# Raku
sub maybe-alas($expected) {
    fail "Not what was expected" unless $expected;
    return 42;
}
my $a = maybe-alas(666);
my $b = maybe-alas("");
say "values gathered";
say $a;                   # ok
say $b;                   # will throw, because it has a Failure
say "still in business";  # will not be shown
# values gathered
# 42
# Not what was expected
#   in sub maybe-alas at ...
````

Note that you do not have to provide `try` or `CATCH`: the `Failure` will be returned from the subroutine/method in question as if all is normal. Only if the `Failure` is used in an unanticipated way will the `Exception` embedded in it be thrown. An alternative way of handling this would be:

```` raku
# Raku
sub maybe-alas($expected) {
    fail "Not what was expected" unless $expected;
    return 42;
}
my $a = maybe-alas(666);
my $b = maybe-alas("");
say "values gathered";
say $a ?? "got $a for a" !! "no valid value returned for a";
say $b ?? "got $b for b" !! "no valid value returned for b";
say "still in business";
# values gathered
# got 42 for a
# no valid value returned for b
# still in business
````

Note that the ternary operator `?? !!` calls `.Bool` on the condition, so it effectively disarms the `Failure` that was returned by `fail`.

You can think of `fail` as syntactic sugar for returning a `Failure` object:

```` raku
# Raku
fail "Not what was expected";
````

```` raku
# Raku
return Failure.new("Not what was expected");  # semantically the same
````

## Creating your own exceptions

Raku makes it very easy to create your own (typed) `Exception` classes. You just need to inherit from the `Exception` class and provide a `message` method. It is customary to make custom classes in the `X::` namespace. For example:

```` raku
# Raku
class X::Frobnication::Failed is Exception {
    has $.reason;  # public attribute
    method message() {
        "Frobnication failed because of $.reason"
    }
}
````

You can then use that exception in your code in any `die` or `fail` statement:

```` raku
# Raku
die X::Frobnication::Failed.new( reason => "too much interference" );
````

```` raku
# Raku
fail X::Frobnication::Failed.new( reason => "too much interference" );
````

which you can check for inside a `CATCH` block and introspect if necessary:

```` raku
# Raku
CATCH {
    when X::Frobnicate::Failed {
        if .reason eq 'too much interference' {
            .resume     # too much interference is ok
        }
    }
}                       # all others will re-throw
````

You are completely free in how you set up your `Exception` classes; the only thing the class needs to provide a method called 'message' that should return a string. How that string is created is entirely up to you, as long as the `method` 'message' returns a string. If you prefer working with error codes, you can:

```` raku
# Raku
my @texts =
  "unknown error",
  "too much interference",
;
my constant TOO_MUCH_INTERFERENCE = 1;
class X::Frobnication::Failed is Exception {
    has Int $.reason = 0;
    method message() {
        "Frobnication failed because of @texts[$.reason]"
    }
}
````

As you can see, this quickly becomes more elaborate, so your mileage may vary.

## Summary

Catching exceptions and warnings are handled by phasers in Raku, not by `eval` or signal handlers, as in Perl. `Exception`s are first-class objects in Raku.

Raku also introduces the concept of a `Failure` object, which embeds an `Exception` object. If the `Failure` object is used in an unanticipated way, the embedded `Exception` will be thrown.

You can easily check for a `Failure` with `if`, `?? !!` (which checks for truthiness by calling the `.Bool` method) and `with` (which checks for definedness by calling the `.defined` method).

You can also create `Exception` classes very easily by inheriting from the `Exception` class and providing a `message` method.
