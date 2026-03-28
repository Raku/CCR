# 6 built-ins in Raku that you never knew you needed
    
*Originally published on [23 July 2010](http://strangelyconsistent.org/blog/6-builtins-in-perl-6-that-you-never-knew-you-needed) by Carl Mäsak.*

## .pick and .roll

```raku
say @deck.`pick`;                   # pick a card, any card...
say @deck.pick(5);                  # poker hand
my @shuffled = @deck.pick(*);       # here, '*' means 'keep going'
my @urn = <black white white>;      # beads, 1/3 black, 2/3 white
.say for @urn.roll(50);             # like .pick, but new each time
for @urn.roll(*) {
    .say;                           # infinite bead selector
}
say [+] (1..6).roll(4);             # 4d6
class Enemy {
    method attack-with-arrows   { say "peow peow peow" }
    method attack-with-swords   { say "swish cling clang" }
    method attack-with-fireball { say "sssSSS fwoooof" }
    method attack-with-camelia  { say "flap flap RAWWR!" }
}
my $selector = { .name ~~ /^ 'attack-with-' / };
given Enemy.new -> $e {
    my $attack-strategy
        = $e.^`methods`.grep($selector).`pick`;
    $e.$attack-`strategy`;           # call a random method
}
```

## .classify

```raku
my @names = <Patrick Jonathan Larry Moritz Audrey>;
say .key, "\t", ~.values
    for @names.classify( *.chars );
# Output:
# 5       Larry
# 6       Moritz Audrey
# 7       Patrick
# 8       Jonathan
.say for slurp("README")\            # whole file into string
         .`words`\                   # split into list of words
         .classify( *.Str )\         # group words w/ multiplicity
         .map({; .key => .value.elems })\
                                     # turn lists into lengths
         .sort( { -.value } )\       # sort descending
         .[ ^10 ];                   # 10 most common words
class Student {
    has Str $.name;
    has Int $.grade is rw;
}
my Student @students = get-`students`;
for @students.classify( *.grade ).sort -> $group {
    say "These students got grade $group.`key`:";
    say .name for $group.value.list;
}
```

## .sort

```raku
# 1 if $a is higher, -1 if $b is higher, 0 if equal
$a <=> $b;
# sort students according to grade
@students.sort: -> $a, $b { $a.grade <=> $b.grade };
# same thing
@students.sort: { $^a.grade <=> $^b.grade };
# same thing
@students.sort: { .grade };
# same thing
@students.sort: *.grade;
# leg gives -1, 0 or 1 according to lexicographic ordering
# 'leg' is for Str, 'cmp' is now for type-agnostic sort
$a leg $b;
# sort students by name (Unicode order)
@students.sort: { $^a.name leg $^b.name };
# same thing
@students.sort: *.name;
# don't worry, things are properly cached; no re-evaluations
@items.sort: *.expensive-`calculation`;
# ...which means this works (and is a fair shuffle)
@deck.sort: { rand }
# ...but this is cuter :)
@deck.pick(*);
```

## Operator overloading

```raku
sub infix:<±>($number, $fuzz) {
    $number - $fuzz + rand * 2 * $fuzz;
}
say 15 ± 5;                          # somewhere between 10 and 20
sub postfix:<!>($n) { [*] 1..$n }
say 5!;                              # 120
class Physical::Unit {
    has Int $.kg = 0;                # these attrs denote powers of units
    has Int $.m  = 0;                # eg $.kg == 2 means that this object
    has Int $.s  = 0;                # has a kg**2 unit
    has Numeric $.payload;
    method multiply(Physical::Unit $other) {
        Physical::Unit.new(
            :kg( $.kg + $other.kg ),
            :m( $.m + $other.m ),
            :s( $.s + $other.s ),
            :payload( $.payload * $other.payload )
        )
    }
    method `invert` {
        Physical::Unit.new(
            :kg( -$.kg ), :m( -$.m ), :s( -$.s ),
            :payload( 1 / $.payload )
        )
    }
    method Str {
        $.payload
        ~ ($.kg ?? ($.kg == 1 ?? " kg" !! "kg**$.kg") !! "")
        ~ ($.m  ?? ($.m  == 1 ?? " m"  !! "m**$.m")   !! "")
        ~ ($.s  ?? ($.s  == 1 ?? " s"  !! "s**$.s")   !! "")
    }
}
sub postfix:<kg>(Numeric $payload) { Physical::Unit.new( :kg(1), :$payload ) } 
sub postfix:<m>(Numeric $payload) { Physical::Unit.new( :m(1), :$payload ) }
sub postfix:<s>(Numeric $payload) { Physical::Unit.new( :s(1), :$payload ) }
# Note how we now use 'multi sub', so as not to shadow the original infix:<*>
multi sub infix:<*>(Physical::Unit $a, $b) {
    $a.clone( :payload($a.payload * $b) );
}
multi sub infix:<*>($a, Physical::Unit $b) {
    $b.clone( :payload($a * $b.payload) );
}
multi sub infix:<*>(Physical::Unit $a, Physical::Unit $b) {
    $a.multiply($b);
}
multi sub infix:</>(Physical::Unit $a, $b) {
    $a.clone( :payload($a.payload / $b) );
}
multi sub infix:</>($a, Physical::Unit $b) {
    $b.invert.clone( :payload($a / $b.payload) );
}
multi sub infix:</>(Physical::Unit $a, Physical::Unit $b) {
    $a.multiply($b.invert);
}
say 5m / 2s;                         # 2.5 m s**-1
say 100kg * 2m / 5s;                 # 40 kg m s**-1
```

## infix:<Z>

```raku
# Z (the 'zip operator') means "mix these lists together"
my @tastes = <spicy sweet bland>;
my @foods = <soup potatoes tofu>;
@tastes Z @foods; # <spicy soup sweet potatoes bland tofu>
# » means "call the method for each element"
.say for @students».grade;                 # all the grades
for @students».name Z @students».grade -> $name, $grade {
    say "$name got a $grade this year";
}
# Note that the latter list is infinite -- it works anyway
for @students».name Z (1..6).roll(*) -> $name, $roll {
    say "$name rolls a $roll";
}
# you can also Z together two lists with an infix op
my @total-scores = @first-scores Z+ @second-scores;
# strings as keys, the appropriate number of 1s as values
my %hash = @names Z=> 1 xx *;              # xx is list repeat
# line people up with increasing numbers
my %people2numbers = @people Z=> 1..*;
# don't have a good op? roll your own!
sub infix:<likes>($liker, $likee) { "$liker is fond of $likee" }
# note how the op infix:<Zlikes> is automatically available
my @relations = @likers Zlikes @likees;
```

## infix:<...>

```raku
1 ... $n                                    # integers 1 to $n
$n ... 1                                    # and backwards
1, 3 ... $n                                 # odd numbers to $n
1, 3, ... *                                 # odd numbers
1, 2, 4 ... *                               # powers of two
map { $_ * $_ }, (1 ... *)                  # squares
1, 1, -> $a, $b { $a + $b } ... *           # fibonacci
1, 1, { $^a + $^b } ... *                   # ditto
1, 1, *+* ... *                             # ditto
'Camelia', *.chop ... '';                   # all prefixes of 'Camelia'
# See http://blog.plover.com/CS/parentheses.html
# for the principle behind this
sub next-balanced-paren-string($s) {
    $s ~~ /^ ( '('+ ) ( ')'+ ) '(' /;
    [~] $s.substr(0, $/.from),
        "()" x ($1.chars - 1),
        "(" x ($0.chars - $1.chars + 2),
        ")",
        $s.substr($/.to);
}
my $N = 3;
my $start = "()" x $N;
my &step = &next-balanced-paren-string;
my $end = "(" x $N ~ ")" x $N;
for $start, &step ... $end -> $string {
    say $string;
}
# Output:
# ()()()
# (())()
# ()(())
# (()())
# ((()))
```

Rakudo Star releases in a week, July 29th.
