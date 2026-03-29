# -n and -p
    
*Originally published on [28 August 2011](http://strangelyconsistent.org/blog/dash-n-and-dash-p) by Carl Mäsak.*

*(This blog post is part one of a series; there's also a [part two](n-and-p-part-two) and a [part three](n-and-p-part-three.html).)*

With `-n` on the command line in Perl, you can create an implicit loop for lines of input:

```
$ cat > input
1 big cup of tea
2 cookies
5 pages of a good book
^D
$ perl -nE '$sum += $_; END { say $sum }' input
8
```

Pretty neat.

Oh, and it works in Raku, too.

```
$ raku -n -e 'our $sum += $_; END { say $sum }' input
8
```

Yay!

There's a `-p` flag that also does the loop thing, but it prints `$_` at the end of each loop iteration:

```
$ perl -pE '$_ = uc' input 
1 BIG CUP OF TEA
2 COOKIES
5 PAGES OF A GOOD BOOK
$ raku -p -e '.=uc' input
1 BIG CUP OF TEA
2 COOKIES
5 PAGES OF A GOOD BOOK
```

Now, let's look at the *implementations* of these flags in Perl and in Rakudo.

Perl, has a file `perl.c`, let's look there:

```raku
PL_minus_n      = FALSE;
PL_minus_p      = FALSE;
/* meanwhile, much later */
case 'n':
    PL_minus_n = TRUE;
    *s*++;
    return s;
case 'p':
    PL_minus_p = TRUE;
    *s*++;
    return s;
```

Ok, um. So that clearly wasn't it. That's just the code to *prepare* for applying the flags. Let's keep looking.

Oh, here's a file, `toke.c`. But that's the lexer for Perl, clearly the code for handling the flags can't be in there, can it?

```
if (!PL_in_eval && PL_minus_p) {
    sv_catpvs(linestr,
        /*{*/";}continue{print or die qq(-p destination: $!\\n);}");
    PL_minus_n = PL_minus_p = 0;
} else if (!PL_in_eval && PL_minus_n) {
    sv_catpvs(linestr, /*{*/";}");
    PL_minus_n = 0;
} else
    sv_catpvs(linestr, ";");
/* much, much later */
if (PL_minus_n || PL_minus_p) {
    sv_catpvs(PL_linestr, "LINE: while (<>) {"/*}*/);
    /* handling of -l, -a, and -F */
```

Oh wow. `sv_catpvs`. That's some kind of string concatenation. So when `perldoc perlrun` says that the `-n` and `-p` flags cause Perl to "assume a loop around your program", it actually means something more like "stick a loop right into your program".

I won't toke &mdash; sorry, poke &mdash; too much fun of the Perl solution. After all, I've used it many times, and I really like it. I bet it's fast to do it with strings like that. And elegant. No wait, the other thing.

Let's look at Rakudo's implementation of the same flags. In Rakudo, we find the code in `src/Perl6/Actions.pm`, a code-oriented companion to `src/Perl6/Grammar.pm`:

```raku
if %*COMPILING<%?OPTIONS><p> { # also covers the -np case, like Perl
    $mainline := wrap_option_p_code($mainline);
}
elsif %*COMPILING<%?OPTIONS><n> {
    $mainline := wrap_option_n_code($mainline);
}
# meanwhile, earlier
# Turn $code into "for `lines` { $code }"
sub wrap_option_n_code($code) {
    return PAST::Op.new(:name<&eager>,
        PAST::Op.new(:pasttype<callmethod>, :name<map>,
            PAST::Op.new( :name<&flat>,
                PAST::Op.new(:name<&flat>,
                    PAST::Op.new(
                        :name<&lines>,
                        :pasttype<call>
                    )
                )
            ),
            make_block_from(
                Perl6::Compiler::Signature.new(
                    Perl6::Compiler::Parameter.new(
                        :var_name('$_'), :is_copy(1)
                    )
                ),
                $code
            )
        )
    );
}
# Turn $code into "for `lines` { $code; say $_ }"
# &wrap_option_n_code already does the C<for> loop, so we just add the
# C<say> call here
sub wrap_option_p_code($code) {
    return wrap_option_n_code(
        PAST::Stmts.new(
            $code,
            PAST::Op.new(:name<&say>, :pasttype<call>,
                PAST::Var.new(:name<$_>)
            )
        )
    );
}
```

Don't get bogged down by detail. There's a bit more code, but the big difference is that Rakudo operates on the *syntax tree* of the code, whereas Perl operates on the *text* of the code.

In particular, this means that Rakudo parses the program code *first*, and *then* adds the `-n` and `-p` code.

Which means that the [eskimo operator](https://www.mail-archive.com/fwp@perl.org/msg03431.html) doesn't work in Rakudo:

```
$ perl -nE '$sum += $_ }{ say $sum' input
8
$ raku -n -e 'our $sum += $_ }{ say $sum' input
===SORRY!===
Confused at line 1, near "}{ say $su"
```

Call me conservative, but I think this is a good thing.
