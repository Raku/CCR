# Extra-Typical Raku
    
*Originally published on [27 April 2016](https://perl6.party//post/Perl-6-Extra-Typical-Perl-6) by Zoffix Znet.*

Have you ever grabbed an [`Int`](http://docs.raku.org/type/Int) and thought, *"Boy! I sure would enjoy having an .even method on it!"* Before you beg the core developers [on IRC](irc://irc.freenode.net/#raku) to add it to Raku, let's review some user-space recourse available to you.

## *My Grandpa Left Me a Fortune*

One way to go is to define your own custom Int-like class that knows how to perform the `.even` method. You don't have to reinvent the wheel, just *inherit* from the `Int` type. You can mix and match core Raku types and roles any way that pleases you.

```` raku
class BetterInt is Int {
    method even { self %% 2 }
}
my BetterInt $x .= new: 42;
say $x.even;
$x .= new: 71;
say $x.even;
say $x + 42;
# OUTPUT:
# True
# False
# 113
````

We created a `BetterInt` class and inherited from `Int` using `is Int` trait. The class body has just the extra method `even` we want to add. Using such a class requires a bit of extra code, however.  The `my BetterInt $x` part restricts `$x` to contain objects of just `BetterInt` or subclasses. The `.= new: 42` in this case is the same as `= BetterInt.new: 42` (it's a shorthand method-call-assign notation, same as `+=` is a shorthand to add to original value).

If we ever want to change the value, we have to do the same `.= new:` trick again to get a `BetterInt` inside of our container or else we'll get a fatal error.  The good news, however, is that math operators work just fine on our new class, and it's even accepted by anything that wants to have an `Int`. Here's a sub that expects an `Int` but happily gobbles up our `BetterInt`:

```` raku
sub foo (Int $x) { say "\$x is $x" }
my BetterInt $x .= new: 42;
foo $x;
# OUTPUT:
# $x is 42
````

## *But... But... But...*

Another option is to mix in a role.  The `but` infix operator creates a copy of an object and does just that:

```` raku
my $x = 42 but role { method even { self %% 2 } };
say $x.even;
# OUTPUT:
# True
````

The role doesn't have to be inlined, of course. Here's another example that uses a pre-defined role and also shows that our object is indeed a copy:

```` raku
role Better {
    method better { 'Yes, I am better' }
}
class Foo {
    has $.attr is rw
}
my $original = Foo.new: :attr<original>;
my $copy = $original but Better;
$copy.attr = 'copy';
say $original.attr;  # still 'original'
say $copy.attr;      # this one is 'copy'
say $copy.better;
say $original.better; # fatal error: can't find method
# OUTPUT:
# original
# copy
# Yes, I am better
# Method 'better' not found for invocant of class 'Foo'
#   in block <unit> at test.p6 line 18
````

This is great and all, but as far as our original goal is concerned, this solution is rather weak:

```` raku
my $x = 42 but role { method even { self %% 2 } };
say $x.even; # True
$x = 72;
say $x.even; # No such method
````

The role is mixed into our object stored inside the container, so as soon as we put a new value into the container, our fancy-pants `.even` method is gone, unless we mix in the role again.

## *Sub it in*

Did you know you can call subs as methods? It's pretty neat! You receive the object as the first positional parameter and you can even continue the method chain, with a caveat that you can't break up those chains onto multiple lines if the &sub method call doesn't remain on the first line:

```` raku
sub even { $^a %% 2 };
say 42.&even.uc;
# OUTPUT:
# TRUE
````

This does serve as a decent way to add extra functionality to core types. The `$^a` inside our sub's definition refers to the first parameter (the object we're making the call on) and the entire sub can be written differently as `sub ($x) { $x %% 2 }`. And, of course, your sub-now-method can take arguments too.

## *Here Be Dragons*

The docs for what I'm about to describe contain words "don't do this" at the beggining. No matter what [the JavaScript folks might tell you](http://shop.oreilly.com/product/9780596517748.do), augmenting native types is dangerous, because you're affecting *all* parts of your program—**even modules that don't see your augmentation.**

Now that I have the right to tell you 'I told you so' when the nuclear plant you work at melts down, let's see some code:

```` raku
# Foo.pm6
unit module Foo;
sub fob is export {
    say 42.even;
}
# Bar.pm6
unit module Bar;
use MONKEY-TYPING;
augment class Int {
    method even { self %% 2 }
}
# test.p6
use Foo;
use Bar;
say 72.even;
fob;
# OUTPUT:
# True
# True
````

All of the action is happening inside `Bar.pm6`. First, we have to write a `use MONKEY-*` declaration, which is there to tell us we're doing something dangerous. Next, we use keyword `augment` before `class Int` to indicate we want to *augment* the existing class. Our augmentation adds method `even` that tells whether the Int is an even number.

Now, let's look at the whole program. We have module `Foo` that gives us one sub that simply prints the result of a call of `.even` on `42` (which is an `Int`). We `use` `Foo` BEFORE we use `Bar`, the module with our augmentation. Lastly, in our script, we call method `.even` on an `Int` and then make a call to the sub exported by `Foo`.

The scary thing? It all works! Both `72` in our main script and `42` inside the sub in `Foo` now have method `.even`, all thanks to our augmentation we performed inside `Bar.pm6`. We got what we wanted originally, but it's a dangerous method to use.

## *Evil Flows Through Me*

If you're still reading this, that means you're not above messing everything up, core or not. We augmented an `Int` type, but our numbers can exist as types other than that. Let's augment the [`Cool` type](http://docs.raku.org/type/Cool) to cover all of 'em:

```` raku
use MONKEY-TYPING;
augment class Cool {
    method even { self %% 2 }
}
.say for 72.even, '72'.even, pi.even, ½.even;
# OUTPUT:
# Method 'even' not found for invocant of class 'Int'
# in block <unit> at test.p6 line 8
````

Oops. That didn't work, did it? As soon as we hit our first attempt to call `.even` (on `Int` 72), the program crashed. The reason for that is all the types that derive from `Cool` were already composed by the time we augmented `Cool`. So, to make it work we have to re-compose them with `.^compose` Meta Object Protocol method:

```` raku
use MONKEY-TYPING;
augment class Cool {
    method even { self %% 2 }
}
.^compose for Int, Num, Rat, Str, IntStr, NumStr, RatStr;
.say for 72.even, '72'.even, pi.even, ½.even;
# OUTPUT:
# True
# True
# False
# False
````

It worked! Now `Int, Num, Rat, Str, IntStr, NumStr, RatStr` types have an `.even` method
(note: those aren't the only types that inherit `Cool`)! This is both equisitely evil and plesantly awesome.

## Conclusion

When extending functionality of Raku's core types or any other class, you have several options. You can use a subclass with `is Class`. You can mix in a role with `but Role`. You can call subroutines as methods with `$object.&sub`. Or you can come to the dark side and use augmentation.

Raku—There Is More Than One Way To Extend it.
