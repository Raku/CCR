# Speed up by a factor of 6 million
    
*Originally published on [22 April 2012](http://strangelyconsistent.org/blog/speed-up-by-a-factor-of-6-million) by Carl Mäsak.*

By the end of March, I received an email saying this:

```
$ time perl t4.pl
total: 4783154184978
real    0m0.185s
user    0m0.176s
sys     0m0.004s
(requires a perl with 64bit integers)
```

There was a `t4.pl` file attached.

You may recognize the total that the program prints out is the total number of t4 configurations, the same number that it took my C program [two weeks to calculate](Counting-t4-configurations.html) on a decent box. So somehow, Salvador Fandino, perl.org blogger and occasional reader of my blog, managed to find way to arrive at the answer [6 million times as fast](https://www.wolframalpha.com/input/?i=two+weeks+divided+by+0.185+seconds).

Well, that's interesting. To say the least.

Maybe I should be super-embarrassed. Maybe my cheeks should cycle through previously un-attained shades of crimson as I ponder the fact that my program was 6 million times as slow as someone else's. Ouch! But, I dunno. I don't really see it that way. I got to write about something I care about. *Salvador*++ cared enough to improve on my methods. The world is a better place. Blogging is cool &mdash; I learn stuff. Prestige doesn't much enter into it &mdash; the next time I'll have a better tool in my toolbox.

So, let's investigate this new tool, and how it's better.

First off, to get a factor-6e6 speedup, you don't apply some simple optimization somewhere; you use a different method. Salvador's code doesn't try to *enumerate* all the configurations, it just gets at the number. Which makes a lot of sense in retrospect, since we're not using the individual configurations for anything. My program arrives at each individual configuration, but then just throws it away immediately. Wasteful.

Salvador's blog post is [as brief as his email](https://blogs.perl.org/users/salvador_fandino/2012/03/solving-carl-masaks-counting-t4-configurations-problem-in-pure-perl-5.html). But let's copy the code over here and talk about it a bit:

```
#!/usr/bin/perl
use strict;
use warnings;
my $tab = <<EOT;
-----xxx
------xx
x-----xx
x------x
xx-----x
xx------
xxx-----
EOT
my $vertical = index $tab, "\n";
my $diagonal = $vertical + 1;
my $acu = { $tab => 1 };
for my $ix (0 .. length($tab) - 1) {
    my %next;
    while (my ($k, $c) = each %$acu) {
        my $s = substr($k, 0, 1, '');
        $next{$k} += $c;
        if ($s eq '-') {
            my $k1 = $k;
            if ($k1 =~ s/^-/x/) { # horizontal xx
                $next{$k1} += $c;
                if ($k1 =~ s/^x-/xx/) { # horizontal xxx
                    $next{$k1} += $c;
                }
            }
            $k1 = $k;
            if ($k1 =~ s/^(.{$vertical})-/${1}x/os) { # vertical xx
                $next{$k1} += $c;
                if ($k1 =~ s/^(.{$vertical}x.{$vertical})-/${1}x/os) {  # vertical xxx
                    $next{$k1} += $c;
                }
            }
            $k1 = $k;
            if ($k1 =~  s/^(.{$diagonal})-/${1}x/os) { # diagonal xx
                $next{$k1} += $c;
                if ($k1 =~ s/^(.{$diagonal}x.{$diagonal})-/${1}x/os) {  # diagonal xxx
                    $next{$k1} += $c;
                }
            }
        }
    }
    $acu = \%next;
}
my ($k, $c) = each %$acu;
print "total: $c\n";
```

The code is wonderfully idiomatic and to-the-point. Here are a few highlights, as I see them:

- The board is a string.

It's one-dimensional, but it plays a 2D array on TV. Some cute regexes then do matches on it according to this 2D representation.

- We've "compressed" the hexagonal aspect of the board into a rectangular view.

You know brick walls? On every other level the bricks are "between" those on the levels above/below. It's like they have half-valued x coordinates. This board representation removes the halves and just puts the bricks right on top of each other. It's bad for building walls, but useful for memory layout. It does mean that one of the diagonals on the hex layout becomes a vertical in the rectangular layout.

- The script "munches" through the board, eating it one character at a time.

In a very real way, this program solves the problem by eating it.

- At each point it finds an empty location, it tries to put all kinds of 2-pieces and 3-pieces at that location.

It *diverges* into all alternatives, keeping track for each alternative what locations it's used up.

- The alternatives will then *converge* naturally as the same half-munched board shows up in various alternative paths.

The script just needs to keep track of multiplicity of each alternative.

- By the time we've muched the whole board down to an empty string

Everything will have converged, so the multiplicity of the empty board will magically equal all possible ways to munch up the original one.

The program does far too much destructive updating for my tastes. I realize when I look at it that I no longer "think" in terms of these destructive updates. But it does it so *successfully* and idiomatically, that I find it difficult to list it as a disadvantage. Maybe it's a Perl thing. Constructs like `s///` are terribly convenient, and their default is to mutate things. (Even though Perl.14 [adds `/r` for non-destructive substitution](https://perldoc.perl.org/perl5140delta.html#Regular-Expressions)).

I was curious how this script would look (and perform) in Raku, so I wrote a straight port of it, trying to stick to the original as closely as possible:

```
my $tab = join "\n", <
    -----xxx
    ------xx
    x-----xx
    x------x
    xx-----x
    xx------
    xxx-----
>;
my $vertical = index $tab, "\n";
my $diagonal = $vertical + 1;
my %acu = $tab => 1;
my $vertical_xx = eval("/^ (. ** $vertical) '-'/");
my $vertical_xxx = eval("/^ (. ** $vertical 'x' . ** $vertical) '-'/");
my $diagonal_xx = eval("/^ (. ** $diagonal) '-'/");
my $diagonal_xxx = eval("/^ (. ** $diagonal 'x' . ** $diagonal) '-'/");
for ^$tab.chars {
    my %next;
    for %acu.kv -> $k, $c {
        my $s = $k.substr(0, 1);
        my $k0 = $k.substr(1);
        %next{$k0} += $c;
        next unless $s eq '-';
        my $k1 = $k0;
        if $k1.=subst(/^ '-'/, 'x') ne $k0 { # horizontal xx
            %next{$k1} += $c;
            my $k2 = $k1;
            if $k2.=subst(/^ 'x-'/, 'xx') ne $k1 { # horizontal xxx
                %next{$k2} += $c;
            }
        }
        $k1 = $k0;
        if $k1.=subst($vertical_xx,
                      -> $/ { $0 ~ 'x' }) ne $k0 { # vertical xx
            %next{$k1} += $c;
            my $k2 = $k1;
            if $k2.=subst($vertical_xxx,
                          -> $/ { $0 ~ 'x' }) ne $k1 { # vertical xxx
                %next{$k2} += $c;
            }
        }
        $k1 = $k0;
        if $k1.=subst($diagonal_xx,
                      -> $/ { $0 ~ 'x' }) ne $k0 { # diagonal xx
            %next{$k1} += $c;
            my $k2 = $k1;
            if $k2.=subst($diagonal_xxx,
                          -> $/ { $0 ~ 'x' }) ne $k1 { # diagonal xxx
                %next{$k2} += $c;
            }
        }
    }
    %acu := %next;
}
say "total: %acu.`values`";
```

Ugh! This script is longer than the Perl version, and it looks messier, too. A few factors contribute to that. First, you can't just do `s///` in Rakudo in an `if` statement. (You can in Niecza, though.) Second, there are problems with `<atom> ** $repeats`, and I got to submit [two](https://rt.perl.org/rt3/Ticket/Display.html?id=112450) [tickets](https://rt.perl.org/rt3/Ticket/Display.html?id=112454) about that, and then do a workaround with the `eval`s you see above. (Aah. Feels like the old days.)

Furthermore, *jnthn*++ could put this program into the profiler, and get [two](https://github.com/rakudo/rakudo/commit/f524138d1d29c99fa9963c7463afd34eda69c133) [optimizations](https://github.com/rakudo/rakudo/commit/d6cd1e2bd19e03a81132a23b2025920577f84e37) out of it. It went from 40s on my machine, to 37s.

But in the end, I felt that my straight-port version suffers from not playing off Raku's strengths. So I wrote a version that leans more towards immutability and closures.

```raku
my $tab = join "\n", <
    -----xxx
    ------xx
    x-----xx
    x------x
    xx-----x
    xx------
    xxx-----
>;
my $vertical = index $tab, "\n";
my $diagonal = $vertical + 1;
my %acu = $tab => 1;
sub make_substituter($rx) {
    return sub ($tab) {
        my $newtab = $tab;
        return $newtab
            if $newtab.=subst($rx, -> $/ { $0 ~ 'x' }) ne $tab;
    };
}
sub make_2x_substituter($rx) {
    return sub ($tab) {
        my $newtab = $tab;
        return $newtab
            if $newtab.=subst($rx, -> $/ { [~] $0, 'x', $1, 'x' }) ne $tab;
    };
}
my @pieces = 
    make_substituter(rx/^ ('') '-'/),
    make_substituter(eval("/^ ({'.' x $vertical}) '-'/")),
    make_substituter(eval("/^ ({'.' x $diagonal}) '-'/")),
    make_2x_substituter(rx/^ ('') '-' ('') '-'/),
    make_2x_substituter(eval("/^ ({'.' x $vertical}) '-' ({'.' x $vertical}) '-'/")),
    make_2x_substituter(eval("/^ ({'.' x $diagonal}) '-' ({'.' x $diagonal}) '-'/"));
for ^$tab.chars {
    my %next;
    for %acu.kv -> $k, $c {
        my $s = $k.substr(0, 1);
        my $k0 = $k.substr(1);
        %next{$k0} += $c;
        next unless $s eq '-';
        for @pieces -> &piece {
            if &piece($k0) -> $newtab {
                %next{$newtab} += $c;
            }
        }
    }
    %acu := %next;
}
say "total: %acu.`values`";
```

Hmm. The loop is shorter now, but at the cost of some abstractions in other places. It's an improvement on my first version, but I don't really feel I got close to the succinctness of Salvador's Perl version here either. (And this version runs slower, predictably. Something like 52s on my machine.)

I'm pretty sure it's possible to make even more idiomatic versions. This is a large enough problem to make things interesting. I encourage others to try.
