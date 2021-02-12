# A First Cut On proto
    
*Originally published on [5 December 2008](https://use-perl.github.io/user/JonathanWorthington/journal/38026/) by Jonathan Worthington.*

Today I spent a bit of time getting some basic support for the proto keyword in place. While there is an awful lot more to do, you can now at least write a proto that we fall back to if the multis couldn't decide amongst themselves. Here are some tests that now pass.

```` raku
class A { }
class B { }
class C is A is B { }
proto `foo` { 1 }
multi foo(A $x) { 2 }
multi foo(B $x) { 3 }
is(foo(A.new), 2, 'dispatch on class worked');
is(foo(B.new), 3, 'dispatch on class worked');
is(foo(C.new), 1, 'ambiguous dispatch fell back to proto');
is(foo(42),    1, 'dispatch with no possible candidates fell back to proto');
````

In the Raku prelude, we will use proto variants of builtins to map named parameters to positional parameters, since we don't do multiple dispatch on named parameters (at least, we don't in Raku.0.0 - we may add that in the future). So even this initial bit of support should get us something useful.

So what more will protos be able to do in the future? Well, if you declare traits on a proto, then they should be shared out amongst all of the variants, for one. Additionally, if you declare a proto for a given name, then it forces all subs and methods of that name to be multis even if they weren't declared that way (unless they are explicitly marked only, in which case the presence of a multi and an only in the same scope will give an error). This is useful if you are bringing conflicting methods in from two roles and would like to instead have them dispatch on their long names. Note also that a proto declaration may not appear after a multi declaration within a scope, but we aren't checking that yet - it'll be an error in the future.

Thanks to [Deep Text](http://www.deeptext.ru/) for funding this bit of hacking. And tomorrow brings this week's Rakudo Day. :-)
