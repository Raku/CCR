# Raku Colonpairoscopy
    
*Originally published on [18 June 2018](https://perl6.party//post/Perl-6-Colonpairoscopy) by Zoffix Znet.*

If I were to pick the most ubiquitous construct in the Raku programming language, it'd most definitely be the **colonpair**. Hash constructors, named arguments and parameters, adverbs, and regex modifiers—all involve the colonpair. It's not surprising that with such breadth there would be many shortcuts when it comes to constructing colonpairs.

Today, we'll learn about all of those! Doing so will have us looking at the simplest as well as some of the more advanced language constructs, so if parts of this article make you scratch your head, don't worry—you don't have to learn all of it at once!

## PART I: Creation

### Colonwhaaaa?

The colonpair gets its name from (usually) being a [`Pair`](https://docs.raku.org/type/Pair) object constructor and (usually) having a colon in it. Here are some examples of colonpairs:

```` raku
:foo,
:$bar,
:meow<moo>,
heh => hah
````

The last one doesn't have a colon in it, but since it's basically the same thing as other colonpairs, I personally consider it a colonpair as well.

We can see the colonpairs make [`Pair`](https://docs.raku.org/type/Pair) objects by dumping their [`.^name`](https://docs.raku.org/routine/name#(Metamodel::Naming)_method_name):

```` raku
say :foo.^name; # OUTPUT: «Pair␤»
````

However, when used in argument lists, the colonpairs are specially handled to represent named arguments. We'll get to that part later in the article.

### The Shortcuts

Here's a mostly-complete list of available ways to write a colonpair you can glance over before we dive in. I know, it looks like a huge list, but that's why we're reading this article—to learn the general patterns that make up all of these permutations.

```` raku
# Standard, take-any-type, non-shortcut form
:nd(2).say;             # OUTPUT: «nd => 2␤»
:foo('foo', 'bar').say; # OUTPUT: «foo => (foo bar)␤»
:foo( %(:42a, :foo<a b c>) ).say;
# OUTPUT: «foo => {a => 42, foo => (a b c)}␤»
# Can use fat-arrow notation too:
# (parentheses around them are here just for the .say call)
(nd => 2).say; # OUTPUT: «nd => 2␤»
(foo => ('foo', 'bar') ).say; # OUTPUT: «foo => (foo bar)␤»
(foo => %(:42a, :foo<a b c>) ).say;
# OUTPUT: «foo => {a => 42, foo => (a b c)}␤»
# Booleans
:foo .say; # OUTPUT: «foo => True␤»
:!foo.say; # OUTPUT: «foo => False␤»
# Unsigned integers:
:2nd   .say; # OUTPUT: «nd => 2␤»
:1000th.say; # OUTPUT: «th => 1000␤»
# Strings and Allomorphs (stings that look like numbers are Str + numeric type)
:foo<bar>      .say; # OUTPUT: «foo => bar␤»
:bar<42.5>     .say; # OUTPUT: «bar => 42.5␤»
:bar<42.5>.perl.say; # OUTPUT: «:bar(RatStr.new(42.5, "42.5"))␤»
# Positionals
:foo['foo', 42.5] .say; # A mutable Array:   OUTPUT: «foo => [foo 42.5]␤»
:foo<foo bar 42.5>.say; # An immutable List: OUTPUT: «foo => (foo bar 42.5)␤»
# angled brackets give you allomorphs!
# Callables
:foo{ say "Hello, World!" }.say;
# OUTPUT: «foo => -> ;; $_? is raw { #`(Block|82978224) ... }␤»
# Hashes; keep 'em simple so it doesn't get parsed as a Callable
:foo{ :42a, :foo<a b c> }.say; # OUTPUT: «foo => {a => 42, foo => (a b c)}␤»
# Name and value from variable
:$foo;  # same as :foo($foo)
:$*foo; # same as :foo($*foo)
:$?foo; # same as :foo($?foo)
:$.foo; # same as :foo($.foo)
:$!foo; # same as :foo($!foo)
:@foo;  # same as :foo(@foo)
:@*foo; # same as :foo(@*foo)
:@?foo; # same as :foo(@?foo)
:@.foo; # same as :foo(@.foo)
:@!foo; # same as :foo(@!foo)
:%foo;  # same as :foo(%foo)
:%*foo; # same as :foo(%*foo)
:%?foo; # same as :foo(%?foo)
:%.foo; # same as :foo(%.foo)
:%!foo; # same as :foo(%!foo)
:&foo;  # same as :foo(&foo)
:&*foo; # same as :foo(&*foo)
:&?foo; # same as :foo(&?foo)
:&.foo; # same as :foo(&.foo)
:&!foo; # same as :foo(&!foo)
````

Let's break these up and take a closer look!

#### Standard, Take-any-Type, Non-Shortcut Form

The "standard" form of the colonpair consists of a colon (`:`), a valid term that functions as the [`.key`](https://docs.raku.org/routine/key) of the created [`Pair`](https://docs.raku.org/type/Pair) object, and then a set of parentheses inside of which is the expression with the [`.value`](https://docs.raku.org/routine/value) for the [`Pair`](https://docs.raku.org/type/Pair):

```` raku
:nd(2).say;                       # OUTPUT: «nd => 2␤»
:foo('foo', 'bar').say;           # OUTPUT: «foo => (foo bar)␤»
:foo( %(:42a, :foo<a b c>) ).say;
# OUTPUT: «foo => {a => 42, foo => (a b c)}␤»
````

As long as the key is a valid identifier, all other forms of colonpairs can be written using this way. And for non-valid identifiers, you can simply use the `.new` method—`Pair.new('the key','value')`—or the "fat arrow" syntax.

#### Fat Arrow Syntax

If you ever used Perl, you need no introductions to this syntax: you write the key—which will get auto-quoted if it's a valid identifier, so in those cases you can omit the quotes—then you write `=>` and then you write the value.  The quotes around the key are required if the key is not a valid identifier and the fat arrow is the only operator-involved syntax that will let you construct [`Pair`](https://docs.raku.org/type/Pair)s with such keys:

```` raku
# (outer parentheses are here just for the .say call)
(nd => 2).say; # OUTPUT: «nd => 2␤»
(foo => ('foo', 'bar') ).say; # OUTPUT: «foo => (foo bar)␤»
(foo => %(:42a, :foo<a b c>) ).say;
# OUTPUT: «foo => {a => 42, foo => (a b c)}␤»
("the key" => "the value").say; # OUTPUT: «the key => the value␤»
````

There are some extra rules with how this form behaves in argument lists as well as sigilless variables and constants, which we'll see later in the article.

#### Boolean Shortcut

Now we start getting into shortcuts! What would the most common use of named parameters be? Probably, to specify boolean flags.

It'd be pretty annoying to always have to write those as `:foo(True)`, so there's a shortcut: simply omit the value entirely, and if you want `:foo(False)`, omit the value and put the [negation operator](/language/operators#index-entry-!_(negation_metaoperator)) right after the colon:

```` raku
# Booleans
:foo .say; # OUTPUT: «foo => True␤»
:!foo.say; # OUTPUT: «foo => False␤»
# Equivalent calls:
some-sub :foo :!bar :ber;
some-sub foo => True, bar => False, ber => True;
````

The shortcut form is a lot shorter. This is also the form you may see in adverbs and regex syntax, such as the `:g` adverb on the `m//` quoter and `:s`/`:!s` significant whitespace modifier inside the regex:

```` raku
say "a b c def g h i" ~~ m:g/:s \S \S [:!s \S \s+ \S]/;
# OUTPUT: «(｢a b c d｣ ｢f g h i｣)␤»
````

Here's also another trick from my personal bag: since [`Bool`](https://docs.raku.org/type/Bool) type is an [`Int`](https://docs.raku.org/type/Int), you can use boolean shortcuts to specify [`Int`](https://docs.raku.org/type/Int) values `1` and `0`:

```` raku
# set `batch` to `1`:
^4 .race(:batch).map: { sleep 1 };
say now - ENTER now; # OUTPUT: «1.144883␤»
````

However, for clarity you may wish to use unsigned integer colonpair shortcut instead, which isn't much longer.

#### Unsigned Integer Shortcut

The Raku programming language lets you grab an nth match when you're matching stuff with a regex:

```` raku
say "first second third" ~~ m:3rd/\S+/;
# OUTPUT: «｢third｣␤»
````

As you can probably surmise by now, the `:3rd` after the `m` in `m//` quoter is the adverb, written as a colonpair in unsigned integer shortcut. This form consist of a colon and the name of the key with unquoted unsigned integer value placed between them. No signs, no decimal dots, and not even underscore separators between digits are permitted.

The primary use of this shortcut is for things with ordinal suffixes like `:1st`, `:2nd`, `:9th`, etc. It offers great readability there, but personally I have no reservations about using this syntax for *all* unsigned integer values, regardless of what the name of the key is. It feels slightly offcolour when you first encounter such syntax, but it quickly grows on you:

```` raku
some-sub :1st :2nd :3rd :42foo :100bar;
^4 .race(:1batch).map: { sleep 1 };
````

#### Hash/Array/Callable Shortcuts

Using standard colonpair format you may notice some forms are too parentheses-heavy:

```` raku
:foo(<42>)                 # value is an IntStr allomorph
:foo(<a b c>)              # value is a List
:foo([<a b c>])            # value is an Array
:foo({:42foo, :100bar})    # value is a Hash
:foo({.contains: 'meows'}) # the value is a Callable
````

In these form, you can simply omit the outer parentheses and let the inner brackets and curlies do their job:

```` raku
:foo<42>                   # value is an IntStr allomorph
:foo<a b c>                # value is a List
:foo[<a b c>]              # value is an Array
:foo{:42foo, :100bar}      # value is a Hash
:foo{.contains: 'meows'}   # the value is a Callable
````

It looks a lot cleaner and is simpler to write. Both the [`Hash`](https://docs.raku.org/type/Hash) and [`Callable`](https://docs.raku.org/type/Callable) use the same set of curlies and the same simple rules as used by the `{…}` construct elsewhere in the language: if the content is empty, or contains a single list that starts with a [`Pair`](https://docs.raku.org/type/Pair) literal or `%`-sigiled variable, and the `$_` variable or placeholder parameters are not used, a [`Hash`](https://docs.raku.org/type/Hash) is created; otherwise a [`Block`](https://docs.raku.org/type/Block) ([`Callable`](https://docs.raku.org/type/Callable)) is created.

The angle bracket form (`:foo<…>`) follows the same rules as the [angle bracket quoter](https://docs.raku.org/language/quoting#Word_quoting:_%3C_%3E) used elsewhere in the language:

```` raku
:foo< 42  >.value.^name.say; # OUTPUT: «IntStr␤»
:foo<meows>.value.^name.say; # OUTPUT: «Str␤»
:foo<a b c>.value.^name.say; # OUTPUT: «List␤»
````

And keep in mind that these two forms are **not** equivalent:

```` raku
:42foo
:foo<42>
````

The first creates an [`Int`](https://docs.raku.org/type/Int) object, while the second one creates an [`IntStr`](https://docs.raku.org/type/IntStr) object, which is an [allomorph](https://docs.raku.org/language/glossary#index-entry-Allomorph). This difference is important for things that care about object identity, such as [set operators](https://docs.raku.org/language/setbagmix)

#### Sigiled Shortcut

The one thing I find a pain in the bit to write in other languages is constructs like this:

```` raku
my $the-thing-with-a-thing = …
…
some-sub the-thing-with-a-thing => $the-thing-with-a-thing;
````

It's fairly common to name your variables the same as some named argument to which you wish to pass that variable as a value. The Raku programming language offers a colonpair shortcut precisely for that case. Simply prepend a colon to the variable name to construct a colonpair with the key named the same as the variable (without including the sigil) and the value being the value of that variable. The only catch is the variable must have a sigil, so you can't use this shortcut with [sigilless variables](https://docs.raku.org/language/variables#Sigilless_variables) or constants.

```` raku
my $the-thing-with-a-thing = …
…
some-sub :$the-thing-with-a-thing;
````

You'll notice that the syntax above looks exactly like how you'd declare a *parameter* that takes such a named argument—consistency is a good thing.  All available [sigils and twigils](https://docs.raku.org/language/variables) are supported, which makes the full list of variants for this shortcut look something like this:

```` raku
# Name and value from variable
:$foo;  # same as :foo($foo)
:$*foo; # same as :foo($*foo)
:$?foo; # same as :foo($?foo)
:$.foo; # same as :foo($.foo)
:$!foo; # same as :foo($!foo)
:@foo;  # same as :foo(@foo)
:@*foo; # same as :foo(@*foo)
:@?foo; # same as :foo(@?foo)
:@.foo; # same as :foo(@.foo)
:@!foo; # same as :foo(@!foo)
:%foo;  # same as :foo(%foo)
:%*foo; # same as :foo(%*foo)
:%?foo; # same as :foo(%?foo)
:%.foo; # same as :foo(%.foo)
:%!foo; # same as :foo(%!foo)
:&foo;  # same as :foo(&foo)
:&*foo; # same as :foo(&*foo)
:&?foo; # same as :foo(&?foo)
:&.foo; # same as :foo(&.foo)
:&!foo; # same as :foo(&!foo)
````

This about wraps up the list of currently available colonpair shortcuts. As you can see, the huge list of shortcuts was reduced to a few simple patterns to follow. However, this might not be all the shortcuts that will exist for all the time…

#### The Future!

While currently aren't available, the following two shortcuts might become part of the language in future language versions.

The first one is the indirect lookup shortcut. If you have a named variable and the name of that variable in another variable, you can access the value of the first variable using the indirect lookup construct:

```` raku
my $foo = "bar";
my %bar = :42foo, :70bar;
say %::($foo); # OUTPUT: «{bar => 70, foo => 42}␤»
````

If you squint, the indirect lookup is sort'f like a sigilled variable and colonpair shortcuts for sigilled variables exist, so it makes sense for the language to be consistent and support indirect lookup colonpair shortcut, which would look something like this, where the **value** of `$foo` contains the name of the key for the colonpair.

```` raku
:%::($foo)
````

This form is currently listed as simply unimplemented feature in [R#1532](https://github.com/rakudo/rakudo/issues/1532), so it'll likely see life some day.

The second possible future construct is the `:.foo` form, which was proposed in [RFC R#1462](https://github.com/rakudo/rakudo/issues/1462).  This form calls method `.foo` on the `$_` topical variable and uses the return value as the value for the created [`Pair`](https://docs.raku.org/type/Pair), with the name of the method being the name of the key.

This form comes up semi-frequently when you're passing values of attributes of one object to another with similarly-named attributes, so something like this:

```` raku
Some::Other.new: :foo(.foo) :bar(.bar) :ber(.ber) with $obj
````

Would in shortcut form be written like this:

```` raku
Some::Other.new: :.foo :.bar :.ber with $obj
````

At the time of this writing, this RFC has been self-rejected, but you never know if there'd be more calls for introduction of this syntax.

## PART II: Use

Now that we're familiar with how to write all the forms of colonpairs, let's take a look at some of their available uses, especially those with special rules.

### Parameters

To specify that a parameter should be a named rather than a positional parameter, simply use the sigilled variable colonpair shortcut:

```` raku
sub meow($foo, :$bar) {
    say "$foo is positional and $bar is named";
}
meow 42, :100bar; # 42 is positional and 100 is named
meow :100bar, 42; # 42 is positional and 100 is named
````

Since parameters need some sort of a variable to bind their stuff to, pretty much all other forms of colonpairs are not available for use in parameters.  This means that you can't, for example, declare sigilless named parameters and must instead explicitly use the [`is raw` trait](https://docs.raku.org/type/Signature#index-entry-trait__is_raw) to get the rawness:

```` raku
sub meow (\foo, :$bar is raw) {
    (foo, $bar) = ($bar, foo)
}
my $foo = 42;
my $bar = 100;
meow $foo, :$bar;
say [$foo, $bar]; # OUTPUT: «[100 42]»
````

The one other colonpair form available in parameters is the standard form that is used for aliasing multiple named params to the same name and [parameter descructuring](https://docs.raku.org/type/Signature#Destructuring_Parameters):

```` raku
sub meow (:st(:nd(:rd(:$nth))), Positional :list(($, $second, |))) {
    say [$nth, $second];
}
meow :3rd, :list<a b c>; # OUTPUT: «[3 b]»
````

Pro-tip: if you're using the Rakudo compiler you may wish to take it easy with aliasing. Using aliases more than 1 level deep will cause the compiler to switch to the slow-path binder, which, as the name suggests, is about 10x slower.

A trick you can use is to use more than one parameter, each with aliases at most 1 level deep, and then merge them in the body:

```` raku
sub meow (:st(:$nd is copy), :rd(:$nth)) {
    $nd //= $nth;
}
````

### Argument Lists

Use of colonpairs in argument lists deserves a separate section due to a rule that's subtle enough to earn a spot in [language's traps section](https://docs.raku.org/language/traps#Named_Parameters). The rule involves the problem that a programmer may wish to pass [`Pair`](https://docs.raku.org/type/Pair) objects in argument lists as either a named or a positional argument.

In majority of cases, the colonpairs will be passed as named arguments:

```` raku
sub args {
    say "Positional args are: @_.`perl`";
    say "Named      args are: %_.`perl`";
}
args :foo, :50bar, e => 42;
# OUTPUT:
# Positional args are: []
# Named      args are: {:bar(50), :e(42), :foo}
````

To pass a [`Pair`](https://docs.raku.org/type/Pair) object as a positional argument, you can do any of the following:

1. Wrap the entire colonpair in parentheses
1. Call some method on the colonpair, such as [`.self`](https://docs.raku.org/routine/self) or [`.Pair`](https://docs.raku.org/routine/Pair); weird stuff like using [`R` meta op](https://docs.raku.org/language/operators#index-entry-R_reverse_metaoperator) on the `=>` operator applies as well
1. Quote the key in `foo => bar` syntax
1. In `foo => bar` syntax, use a key that is not a valid identifier
1. Put your [`Pair`](https://docs.raku.org/type/Pair)s in a list and slip it in with the `|` "operator"

Here's that list of options in code form:

```` raku
my @pairs := :42foo, :70meow;
args :foo.Pair, (:50bar), "baz" => "ber", e R=> 42, 42 => 42, |@pairs;
# OUTPUT:
# Positional args are: [:foo, :bar(50), :baz("ber"),
#   42 => 2.718281828459045e0, 42 => 42, :foo(42), :meow(70)]
# Named      args are: {}
````

Number (3) is especially worth keeping in mind if you're coming from other languages, like Perl, that use the fat arrow (`=>`) for key/value separation.  This construct gets passed as a named argument only if the key is unquoted and only if it's a valid identifier.

Should it happen that you *have* to use one of these constructs, yet wish to pass them as named arguments instead of positionals, simply wrap them in parentheses and use the `|` prefix to "slip" them in. For the list of [`Pair`](https://docs.raku.org/type/Pair)s we were already slipping in in previous example, you'll need to coerce it into a [`Capture`](https://docs.raku.org/type/Capture) object first, as [`Pair`](https://docs.raku.org/type/Pair)s stuffed into a [`Capture`](https://docs.raku.org/type/Capture)—unlike a list—end up being named parameters, when the [`Capture`](https://docs.raku.org/type/Capture) is slipped into the argument list:

```` raku
my @pairs := :42foo, :70meow;
args |(:foo.Pair), |(:50bar),   |("baz" => "ber"),
     |(e R=> 42),  |(42 => 42), |@pairs.Capture;
# OUTPUT:
# Positional args are: []
# Named      args are: {"42" => 42, :bar(50),
#                      :baz("ber"), :foo(42), :meow(70)}
````

The same slipping trick can be used to provide named arguments conditionally:

```` raku
sub foo (:$bar = 'the default') { say $bar }
my $bar;
foo |(:bar($_) with $bar);  # OUTPUT: «the default␤»
$bar = 42;
foo |(:bar($_) with $bar);  # OUTPUT: «42␤»
````

If `$bar` is not [`defined`](https://docs.raku.org/routine/defined), the [`with` statement modifier](https://docs.raku.org/language/control#index-entry-control_flow_with_orwith_without-with%2C_orwith%2C_without) will return [`Empty`](https://docs.raku.org/type/Empty), which when slipped with `|` will end up being empty, allowing the parameter to attain its default value.  Since `|(:)` looks like a sideways ninja, I call this technique "ninja-ing the arg".

### Auto-Quoting in `=>` Form

The sharp-eyed in the audience might have noticed the `e => 42` colonpair in the previous section used letter `e` as a key, yet in reversed form `e R=> 42`, the `e` became `2.718281828459045e0`, because the core language has `e` defined as [Euler's number](https://en.wikipedia.org/wiki/E_%28mathematical_constant%29).

The reason it remained a plain string `e` in the `e => 42` form is because this construct auto-quotes keys that are valid identifiers and so they will always end up as strings, even if a constant, a sigilless variable, or a routine with the same name exists:

```` raku
my \meows = '🐱';
sub ehh { rand }
say %(
    meows => 'moo',
    ehh   => 42,
    τ     => 'meow',
); # OUTPUT: «{ehh => 42, meows => moo, τ => meow}␤»
````

A multitude of ways exist to avoid this autoquoting behaviour, but I'll show you just one that's good enough: slap a pair of parentheses around the key:

```` raku
my \meows = '🐱';
sub ehh { rand }
say %(
    (meows) => 'moo',
    (ehh)   => 42,
    (τ)     => 'meow',
);
# OUTPUT: «{0.58437052771857 => 42, 6.283185307179586 => meow,
#           🐱 => moo}␤»
````

Simple!

## Conclusion

That's pretty much all there is to know about colonpairs. We learned they can be used to construct [`Pair`](https://docs.raku.org/type/Pair) objects, used as adverbs, and used to specify named arguments and parameters.

We learned about various shortcuts, such as using key only for boolean `True`, sticking the negation operator or an unsigned integer between the colon and the key to specify boolean `False` or an `Int` value. We also learned that parentheses can be omited on colonpair values if there's already a set of curly, square, or angle brackets around the value and that prepending a colon to a sigilled variable name will create a colonpair that will use the name of that variable as the key.

In the second half of the article, we went over available colonpair syntaxes when specifying named paramaters, the pecularities in passing colonpairs as either named or positional arguments, as well as how to avoid auto-quoting of the key by wrapping it in parentheses.

I hope you found this informative.

-Ofun
