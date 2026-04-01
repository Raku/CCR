# Rakudo day: Rats, contextual variables, and %*ENV fixes
    
*Originally published on [5 September 2009](https://use-perl.github.io/user/pmichaud/journal/39585/) by Patrick Michaud.*

As I mentioned in my 
[previous post](Rakudo-Day--operator-overloading-faster-isa-better-build.),
I'm doing two Rakudo days per week for my Vienna.pm grant
to make up for some of the weeks I missed during conferences and
summer travel.  This week I focused on adding a rational (`Rat`)
data type, support for contextual variables, and fixing up the
handling of environment variables via `%*ENV`.

After the work that was done on operator overloading last week,
implementing a basic `Rat` data type ended up being surprisingly
easy.  In fact, I just wrote it as a straightforward Raku class
and added it to the setting -- you can see the easy-to-read results in
src/setting/Rat.pm.

I did just enough of the implementation to get the basics in place, 
at which point Solomon Foster, Moritz Lenz, and others started 
working out a lot of the other details such as conversions to and
from `Rat` and other MMD considerations.  As a result we have
quite a few clarifications and improvements to the specification,
a lot of new tests have been written, and Rakudo passes a lot more
tests in the test suite.

While adding `Rat` was relatively easy, adding contextual variables
to Rakudo was quite a bit more challenging.  Contextual variables
are similar to lexicals, except that searching for a contextual
variable involves looking at a block's callers instead of
the block's outer lexical scopes.  Contextuals have many 
similarities to the way that Unix environment variables work, but 
they also fill many of the niches that would have otherwise been 
handled by global or environment variables.


Contextual variables in Raku are denoted using the `*` twigil.
Here's a simple example that uses a contextual:

```raku
sub foo {
    say $*PHRASE;
}

sub bar {
    my $*PHRASE = 'world';
    foo;
}

my $*PHRASE = 'hello';
foo;
bar;
````

When run, this outputs "hello\nworld\n".  When `foo` needs to look up
the value of `$*PHRASE`, it does so by first checking its local 
lexpad, then checking its caller's lexpad, then its caller's caller's
lexpad, and so forth until it finds a declared `$*PHRASE`.  
Thus in the first call to ``foo`` above, `foo`'s caller is the mainline
and so `foo` finds the mainline's definition of `$*PHRASE` ("hello").
The call to `bar` declares a new contextual named `$*PHRASE`,
and thus the second call to `foo` sees `bar`'s value of
`$*PHRASE` ("world").

In other words, contextual variable lookups always use the (dynamic) 
caller chain instead of (static) lexical scoping.

This turns out to be incredibly useful in a number of situations where
we want to provide called functions with an idea of the dynamic
context in which they're being called.  One of the most common uses
for contextuals can be to override the default output for `print`,
`say`, and other builtin I/O functions.  The `print` and `say` 
builtins output to `$*OUT`, a contextual variable.  So, to change the
output destination for any calls to `say` or `print`, simply declare
a new contextual $*OUT:

```raku
say "Hello world on standard output";

{
    my $*OUT = open("outfile.txt", :w);
    say "This text is going to outfile.txt";
    say "Report follows:";
    `print_report`;
    $*OUT.close;
}

say "...and this also goes to standard output";
````

So, in the bare block in the above code, the declaration
of a new `$*OUT` contextual causes all of the calls to 
`say` and `print` executed inside of that block to 
send their output to *outfile.txt* instead of the
default standard output.  This behavior holds even for 
nested function calls such as ``print_report`` -- its calls
to `say` and `print` also get sent to *outfile.txt*.

This ability to establish a dynamic context value that 
can be quickly looked up from within nested function calls
is key to simplifying many compiler implementation details.
If you look at STD.pm 
you'll quickly see how much it relies on contextuals.  Indeed,
one of my next tasks will be to add contextuals to NQP and PGE
so that we can move even closer to the way STD.pm handles
parsing.

As I alluded above, contextual variables also fill some of the
niches held by global and environment variables.  If a search
for a contextual variable doesn't find it declared in any of
the callers' lexpads, we then fall back to looking in the `GLOBAL`
and `PROCESS` packages.  Thus a `$GLOBAL::foo` variable can
be quickly accessed using `$*foo` if no caller has
declared its own `$*foo`.  

In fact, most of the predefined contextuals such as 
`$*OUT`, `$*ERR`, `%*ENV`, `$*PID`, etc., are actually
defined in the `PROCESS` package.  This gives us a lot
of flexibility in deciding things:

```raku
$*OUT          # the standard output of my caller
$PROCESS::OUT  # the standard output for this process
````

The implementation for contextual variables in Rakudo required
creating new Parrot operations for finding variables in the 
dynamic caller chain instead of the static outer scope chain, 
creating a (`!find_contextual`) sub in Rakudo to handle the 
contextual lookups, refactoring the compiler to treat the `*`
twigil as a contextual instead of a global variable, and migrating 
the previous "contextual globals" we had into the `PROCESS` namespace.  
These later steps took the longest by far to accomplish.

Finally for this week's Rakudo days, there have been a number of RT 
tickets and requests for fixing up the handling of `%*ENV` --
previously it was based on Parrot's `Env` PMC and
some of the Parrot-isms leaked out (e.g. 
[RT #57400](https://github.com/Raku/old-issue-tracker/issues/203)).  
The implementation of contextual variables opened 
the door to cleaning up `%*ENV` to work more
appropriately, so I went ahead and did that.

Overall I'm very pleased by the progress made in this
week's pair of Rakudo days:  we got a good start on
rational datatypes and cleaning up the relationships
among the built-in scalar types, we now have a working
contextual model that we'll need for the next phases
of compiler development, and environment variables are
now working more like they are supposed to.

Many thanks to Vienna.pm for sponsoring this work.
