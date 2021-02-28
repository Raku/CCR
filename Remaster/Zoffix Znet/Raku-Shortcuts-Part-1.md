# Raku: Shortcuts (Part 1)
    
*Originally published on [1 February 2016](https://perl6.party//post/Perl-6-Shortcuts--Part-1) by Zoffix Znet.*

Programming is a task where laziness is a virtue. We write modules to avoid repeatedly writing subroutines. We write subroutines to avoid repeatedly writing loops. We write loops to avoid repeatedly writing code... And there's another level of laziness: we use language shortcuts to avoid writing too much code.

Shortcuts are a controversial subject. Some say they make code faster to write and easier to read. Some say they make it harder to understand for people unfamiliar with those shortcuts. So this article is merely *telling* you about shortcuts and it's up to you to decide whether to use them or to avoid them. Let's begin, shall we!

## Public Getter/Setter for Class Attributes

The concept of a "getter" and "setter" is common in many languages: you have a "thing" in your class and you write a method to set or get the value of that thing. In verbose Raku, such a set up might look something like this:

```` raku
class Foo {
    has $!attr = 42;
    method attr is rw { $!attr }
}
my  $obj = Foo.new;
say $obj.attr;
    $obj.attr = 72;
say $obj.attr;
# OUTPUT>>:
# 42
# 72
````

That looks pretty concise as it is, but public attributes are common enough to make writing even this bit of code annoying. Which is why the `$.` twigil exists. Using it alone creates a "getter"; if you want a "setter" as well, use the `is rw` trait:

```` raku
class Foo { has $.attr is rw = 42; }
my  $obj = Foo.new;
say $obj.attr;
    $obj.attr = 72;
say $obj.attr;
# OUTPUT>>:
# 42
# 72
````

We changed the `$!` twigil on our attribute to `$.` twigil and it took care of creating a public method for us. Moving on!

## Omitting Parentheses on method calls

It's not uncommon to see code like this, where you have a whole ton of parentheses at the end. Be sure they all match up!!

```` raku
$foo.log( $obj.nukanate( $foo.grep(*.bar).map(*.ber) ) );
````

For those who are reminded of a [popular webcomic](https://xkcd.com/297/), Raku has
an alternative:

```` raku
$foo.log: $obj.nukanate: $foo.grep(*.bar).map: *.ber;
````

If a method is last in the method call chain, you can omit its parentheses and use a colon `:` instead. Except for `.grep`, all of our calls above are "last in the chain," so that was quite a bit of parentheses we got rid of. Sometimes I also like to start the thing following the colon on a new line.

And just a note: you can always omit parenthesis on method calls if you're not supplying any arguments; no semicolons are needed either.

## Commaless Named Arguments

If you're calling a method or a sub and are providing **only named arguments,** you can omit commas between the arguments. Sometimes, I like to stack each argument on a new line as well:

```` raku
class Foo {
    method baz (:$foo, :$bar, :$ber) { say "[$foo, $bar, $ber]" }
}
    sub    baz (:$foo, :$bar, :$ber) { say "[$foo, $bar, $ber]" }
Foo.baz:
    :foo(42)
    :bar(72)
    :ber(100);
baz :foo(42) :bar(72) :ber(100);
# OUTPUT>>:
# [42, 72, 100]
# [42, 72, 100]
````

Again, this works when you are providing **only named arguments.** There are many, many other places where you'd be using the same form to provide arguments or [Pairs](http://docs.raku.org/type/Pair), but you can't omit commas there.

## Integers in Named Arguments/Pairs

Looking at the last code example, it's a bit parentheses-heavy. So there's another shortcut: if the argument or Pair takes a **positive integer** as a value, simply write it between the colon and the name of the key:

```` raku
say DateTime.new: :2016year :2month :1day :16hour :32minute;
# OUTPUT>>:
# 2016-02-01T16:32:00Z
````

This is one of those things that look jarring when you first learn it, but you get used to it quite fast. It also reads a lot like English:

```` raku
my  %ingredients = :4eggs, :2sticks-of-butter, :4cups-of-sugar;
say %ingredients;
# OUTPUT>>:
# cups-of-sugar => 4, eggs => 4, sticks-of-butter => 2
````

## Booleans in Named Arguments/Pairs

If we have a shortcut for Ints in named arguments, it'd be daft not to have one for Booleans too. And there is one: use the name of the key by itself to indicate `True`; insert an exclamation mark between the key and the colon to indicate `False`:

```` raku
sub foo (:$bar, :$ber) { say "$bar, $ber" }
foo :!bar :ber;
my  %hash = :!bar, :ber;
say %hash;
# OUTPUT>>:
# False, True
# bar => False, ber => True
````

Note: this applies to adverbs as well!

## Lists in Named Arguments/Pairs

If you're supplying a quote-word construct to a named argument/pair that expects something listy, you can omit parentheses; just don't use any spaces between the key and the the quote-words:

```` raku
sub foo (:@args) { say @args }
foo :args<foo bar ber>;
my  %hash = :ingredients<milk eggs butter>;
say %hash;
# OUTPUT>>:
# (foo bar ber)
# ingredients => (milk eggs butter)
````

## Pass-through of variables to Named Arguments/Pairs;

Did you think we were done with the named args? There's one more cool shortcut: s'pose you have a variable and it has the same name as the named argument...  just pass it in by using the variable itself, instead of the key, after the colon:

```` raku
sub hashify (:$bar, :@ber) {
    my %hash = :$bar, :@ber;
    say %hash;
}
my ( $bar, @ber ) = 42, (1..3);
hashify :$bar :@ber;
# OUTPUT>>:
# bar => 42, ber => [1..3]
````

Notice neither in the sub call nor in our hash creation are we duplicating the names of keys. They're derived from variable names.

## Subs as method calls

If you have a sub you're dying to call as a method on something, just prefix it with an ampersand. The invocant will be the first positional argument, with all the other args passed as usual.

```` raku
sub be-wise ($self, $who = 'Anonymous') { "Know your $self, $who!" }
'ABC'.&be-wise.say;
'ABC'.&be-wise('Zoffix').say;
# OUTPUT>>:
# Know your ABC, Anonymous!
# Know your ABC, Zoffix!
````

This is essentially a less-ugly way to call a `.map` in certain instances, but using a sub as a sub was meant to be used would likely win most of the time, in terms of readability.

```` raku
sub be-wise ($self, $who = 'Anonymous') { "Know your $self, $who!" }
'ABC'.map({be-wise $_, 'Zoffix'})».say;
say be-wise 'ABC', 'Zoffix';
# OUTPUT>>:
# Know your ABC, Zoffix!
# Know your ABC, Zoffix!
````

For the sake of completeness, and not anything overly practical, know that you can also inline the call and even use a pointy block to set a signature!

```` raku
'ABC'.&('Know your ' ~ *).say;
'ABC'.&( -> $self, $who = 'Anonymous' {"Know your $self, $who!"} )('Zoffix')
    .say;
# OUTPUT>>:
# Know your ABC
# Know your ABC, Zoffix!
````

## Hyper Method Calls

Since we're on the topic of shortcuts for `.map`, keep the `»` hyper operator in mind.  Using it before the dot of a method call indicates you want to call the following method on each element of the invocant, instead of the invocant itself. As with all fancy-pants operators, Raku provides ["Texas" variant](http://docs.raku.org/language/unicode_texas) for this operator as well, `>>`

```` raku
(1, 2, 3)».is-prime.say;
(1, 2, 3)>>.is-prime.say;
# OUTPUT>>:
# (False True True)
# (False True True)
````

This one has a bonus too: while currently not yet implemented in Rakudo, the spec permits this operator to perform concurrently, so you can eventually see it perform the faster the more cores your box has!

## Summary

- Use `$.` twigil to declare public attributes
- Use `:` instead of parentheses for giving arguments to a method call that is last in the chain
- Method/sub calls with only named arguments do not need commas
- Pass Int values by writing them between the key and the colon
- Use key by itself to specify a `True` boolean value
- Use key by itself, with `!` between it and colon to specify a `False` boolean value
- When value is a quote-word construct, write it right after the key, without any parentheses
- When a variable has the same name as the key, use it directly as the key (including the sigil), without specifying any values
- Prefix the name of a sub with `&` when calling it as a method.
- Use `»` operator to call a method on each item in the list.

## Conclusion

This isn't the full list of Raku shortcuts and I'm sure I'm yet to learn some of them myself. This is why I named the article 'Part 1'. Do you know any cool and useful shortcuts you'd like to be included in subsequent parts? Post them in the comments!
