# ;; works, making illegal things illegal
    
*Originally published on [10 December 2008](https://use-perl.github.io/user/JonathanWorthington/journal/38063/) by Jonathan Worthington.*

Today I have done a couple more things on multiple dispatch in Raku. The major one is that `;;` now works (it's been parsed for a while, but now it has the expected effects). The idea is that you put `;;` in a signature in place of a comma to separate two parameters. Any parameters after this are not considered by the multi-dispatcher. For example, the following two multis:

```` raku
multi foo(Int $a, Num $b) { 1 }
multi foo(Num $a, Int $b) { 2 }
````

Will, when invoked as `foo(1,1)`, give an ambiguous dispatch error, since neither of these subs is narrower than the other - they are tied. However, if you instead wrote:

```` raku
multi foo(Int $a;; Num $b) { 1 }
multi foo(Num $a;; Int $b) { 2 }
````

Then `foo(1,1)` will call the first of these multis, since it only looks at the signatures so far as the `;;` and `Int` is a narrower type than `Num`, so the bit of the signature it cares about is narrower, so the ambiguity is gone. Of course, `foo(1, "x")` will fail because while the multi-dispatcher doesn't care about the second parameter, you still have to meet its signature requirements.

The more minor one is that multi, only and proto may only be used, according to the spec, on named routines, not anonymous ones. Rakudo now meets this bit of the spec (it will give a compile time error), and I've put in some spec tests to check this too.

And with these two additions, the grant from [Deep Text](http://www.deeptext.ru/) draws to an end. I'll be posting a final report soon - thanks to Deep Text for funding this, and many other bits of, hacking on Rakudo's multiple dispatch! :-)
