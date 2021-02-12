# Better Diagnostics On Ambiguous Dispatch
    
*Originally published on [4 December 2008](https://use-perl.github.io/user/JonathanWorthington/journal/38017/) by Jonathan Worthington.*

My first task tonight was to fix up multi methods after some changes in Parrot broke them. They were good changes, I think, but left me with half an hour's tracking down of the problem and fixing to do. It also gave me opportunity to fill out a couple more missing VTABLE methods in the Perl6MultiSub PMC.

Now, onto the more interesting stuff. In Raku you can call the `.raku` method on stuff to get a Rakuish representation of it. We have this implemented for quite a few things. Tonight I did a first cut of this method on signatures. So this now works (example with single dispatch sub as we don't have a way to get a multi variant yet):

```` raku
sub foo(Int $a, Num $b?, *@xs) { 1 }
say &foo.signature.raku; # :(Int $a, Num $b?, Any *@xs)
````

Having made this work (making .raku on any proto-object work along the way - Any.raku doesn't fail any more), I put it to use in Perl6MultiSub. Now if we write two ambiguous multis and try to call them, it will tell you the conflicting signatures. Here is a blatantly boring and obvious example.

```` raku
multi foo(Int $a) { 1 }
multi foo(Int $a) { 2 }
foo(42);
````

This will now produce:

```` raku
Ambiguous dispatch to multi 'foo'. Ambiguous candidates had signatures:
:(Int $a)
:(Int $a)
````

Which is more helpful, especially in the case when it's not obvious (e.g. when you have two variants looking for different roles, and your parameter happens to do both of them).

Of course, this is an improvement, but it still isn't what we really want. What should follow this is the file and line number where the multi variants were declared, so you can quickly track them down. This will be especially useful once we have lexical multis and imports in effect. But you'll have to wait for that for a little while (though I am working on some of what will make this possible, along with line numbers for errors in general - but that's another blog post).

Thanks go to [DeepText](http://www.deeptext.ru/) for sponsoring my work on multiple dispatch in Rakudo.
