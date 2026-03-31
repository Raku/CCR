# A(nother) Reverse Polish Notation Calculator
    
*Originally published on [2 March 2009](https://use-perl.github.io/user/pmichaud/journal/38580/) by Patrick Michaud.*

In [a Reverse Polish Notation Calculator](https://blog.afoolishmanifesto.com/archives/341), fREW Schmidt takes the RPN calculator example from [Higher Order Perl](https://www.amazon.com/gp/product/1558607013) and converts it over to Raku.

Very cool.

But as usual, I visually look at the Raku version compared to the Perl version and think "Can't we do better?"  In this case, we can.  Here's my version of the same code:

```raku
my %op_dispatch_table = {
    '+'    => { .push(.pop + .pop) },
    '-'    => { my $s = .pop; .push(.pop - $s) },
    '*'    => { .push(.pop * .pop) },
    '/'    => { my $s = .pop; .push(.pop / $s) },
    'sqrt' => { .push(.pop.sqrt) },
};

sub evaluate (%odt, $expr) {
    my @stack;
    my @tokens = $expr.split(/\s+/);
    for @tokens {
        when /\d+/     { @stack.push($_); }
        when ?%odt{$_} { %odt{$_}(@stack); }
        default        { die "Unrecognized token '$_'; aborting"; }
    }
    @stack.pop;
}

say "Result: { evaluate(%op_dispatch_table, @*ARGS[0]) }";
```

The result:
```
$ ./raku calc.pl '5 6 +'
Result: 11
```

The major changes I made to fREW's code:

1.  Convert the explicit subs into simple closures, assuming that the stack is the implicit topic.
2.  Use 'when' statements instead of if/elsif/else in the body of the 'evaluate' sub.

And yes, as frew points out -- when we get the 'R' metaoperator in place we can get rid of the 'my $s = ...' parts of subtraction and division.  Maybe I'll implement meta-R now... :-)

Thanks fREW for the very interesting example!

**Update:**  I went ahead and implemented the R metaoperator.  For those who aren't familiar with meta-R, it reverses the order of the operands to an operator.  So, (5 R- 4)  is the same as (4 - 5), and (2 R/ 10) is the same as (10 / 2).  With this change, the RPN calculator becomes:

```raku
my %op_dispatch_table = {
    '+'    => { .push(.pop + .pop)  },
    '-'    => { .push(.pop R- .pop) },
    '*'    => { .push(.pop * .pop)  },
    '/'    => { .push(.pop R/ .pop) },
    'sqrt' => { .push(.pop.sqrt)    },
};

sub evaluate (%odt, $expr) {
    my @stack;
    my @tokens = $expr.split(/\s+/);
    for @tokens {
        when /\d+/     { @stack.push($_); }
        when ?%odt{$_} { %odt{$_}(@stack); }
        default        { die "Unrecognized token '$_'; aborting"; }
    }
    @stack.pop;
}

say "Result: { evaluate(%op_dispatch_table, @*ARGS[0]) }";
````
