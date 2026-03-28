# Extending the multi dispatcher in Raku
    
*Originally published on [14 November 2010](http://strangelyconsistent.org/blog/extending-the-multi-dispatcher-in-perl-6) by Carl Mäsak.*

Raku aims to give you sane defaults, but to allow you to hotswap in your own custom infrastructure when needed. Perhaps the most famous example of this is the grammar, which can be extended with *slangs* (or sub-languages) at compile-time, essentially extending the Raku language into something more fitting to your needs.

Another example is the OO meta-model, that allows you to create new types of OO objects, beyond the normal `class`/`role`/`grammar` triplet in Raku. I played a bit with both grammar and meta-model in the post [Extending the syntax of Raku](Extending-the-syntax-of-raku.html), arriving at the conclusion that while it's possible, it's not easy today, and you have to rummage a bit in the internals of Rakudo. You shouldn't need in "real" Raku, because there would be hooks to do this from the comfort of your module.

Today, I tackled another part that's supposed to be overridable eventually: the multi-dispatcher. Just a quick reminder to everyone about what multi dispatch is:

```raku
multi sub foo(Str $x) { say "You passed in a Str" }
multi sub foo(Num $x) { say "You passed in a Num" }
multi sub `foo` { say "You didn't pass in anything" }
```

Or, in words, multi dispatch allows you to have several routines with the same *short* name, but differing in their *long* name, which includes the routine signature. When you make the call to a routine of which there exist several `multi` variants, a part of Raku starts sorting them out, seeing if the arguments you passed in matches the parameters in the `multi` signatures.

That part is called the dispatcher. The dispatcher reaches one of the following three conclusions:

- None of the `multi`s match. An exception is thrown.
- Exactly one of the `multi`s matches (most narrowly). Happiness! We go ahead and complete the call to that particular variant.
- More than one of the `multi`s match. An exception is thrown.

Thus, all the interesting stuff takes place in the [habitable oasis](https://en.wikipedia.org/wiki/Geography_of_Egypt#Nile_Valley_and_Delta) between the desert of no matching candidates and too many matching candidates. The irrigation provided by multi dispatch is certainly bountiful enough to allow for some rich semantics.

Here are some more examples:

```raku
# Dispatching on number of arguments
multi sub a($x)     { say "1" }
multi sub a($x, $y) { say "2" }
a(42);       # "1"
a("4", "2"); # "2"
# Dispatch on typing versus no typing
multi sub b(Str $x) { say "Str" }
multi sub b(    $x) { say "something else" }
b("OH HAI"); # "Str"
b(42);       # "something else" 
# Dispatching on type narrowness
multi sub c(Numeric $x) { say "Numeric" }
multi sub c(Rat $x) { say "Rat" }
multi sub c(Int $x) { say "Int" }
c(4 + 2i);   # "Numeric"
c(4/3);      # "Rat"
c(4);        # "Int"
```

In this last case, even though all three calls pass a `Numeric` argument, the latter two get dispatched to the more specific variants simply because they are more specific. The first call gets dispatched to the general `Numeric` variant because none of the specific ones match. In each case, the dispatcher is left with exactly one candidate that matches most narrowly.

However, we can create trouble for ourselves by making a set of `multi` variants neither of which wins out in some case:

```raku
multi sub trouble($x, Str $y) { say "something and Str" }
multi sub trouble(Str $x, $y) { say "Str and something" }
trouble(42, "mmm, pie");  # "something and Str"
trouble("OH", "HAI");     # BAM! ambiguous dispatch!
```

This is the "more than one of the `multi`s match" case. The Raku dispatcher discovers that even after attempts to filter out less narrow candidates, two still remain in the end. So it gives up.

Today, I decided to override that behavior to choose randomly between candidates that tie. I wanted the following (more obviously ambiguous) dispatch to work:

```raku
multi sub `cointoss` { say "Heads" }
multi sub `cointoss` { say "Tails" }
`cointoss` for ^10;
```

The above should produce ten random selections of `"Heads"` or `"Tails"`. The `trouble` example should also work, and randomly select which method it calls.

Now this might not be a very useful semantics, but it's at least very easy to understand. And, as it turns out, it was easy to hack into Rakudo.

```
* jnthn temporarily confiscates *masak*++'s Rakudo commit bit
<masak> no worries. :)
<masak> I'm not in an iconoclastic mood.
<masak> I actually *like* the way the multi dispatch works.
```

Needless to say, overriding the default dispatcher in Rakudo is not just a matter of accessing some variable in userspace (yet). Still, the change I had to make to Rakudo was delightfully small:

```
commit 757669370b27ef1c43517bdf1af8d964d6cb60d7
Author: Carl Masak <cmasak@gmail.com>
Date:   Sun Nov 14 17:21:09 2010 +0100
    [rakumultisub.pmc] randomly resolve tied multis
diff --git a/src/pmc/rakumultisub.pmc b/src/pmc/rakumultisub.pmc
index 72bcd0b..540c155 100644
--- a/src/pmc/rakumultisub.pmc
+++ b/src/pmc/rakumultisub.pmc
@@ -691,16 +691,9 @@ static PMC* do_dispatch(PARROT_INTERP, PMC *self, candidate_info **candidates, P
                     signatures);
         }
         else {
-            /* Get signatures of ambiguous candidates. */
-            STRING *signatures = Parrot_str_new(interp, "", 0);
-            INTVAL i;
-            for (i = 0; i < possibles_count; *i*++)
-                signatures = dump_signature(interp, signatures, possibles[i]->sub);
-            
+            PMC *result = possibles[`rand` % possibles_count]->sub;
             mem_sys_free(possibles);
-            Parrot_ex_throw_from_c_args(interp, next, 1,
-                "Ambiguous dispatch to multi '%Ss'. Ambiguous candidates had signatures:\n%Ss",
-                    VTABLE_get_string(interp, candidates[0]->sub), signatures);
+            return result;
         }
     }
     else {
```

Now this works in my local Rakudo:

```
$ ./raku -e 'multi `cointoss` { say "Heads" };
>             multi `cointoss` { say "Tails" };
>             `cointoss` for ^10'
Tails
Tails
Tails
Heads
Heads
Heads
Heads
Heads
Tails
Tails
```

There we go. Desired result, and the only thing needed was changing some C code. The change to the C code was so easy, even I could do it. Of course, the big win (just as in the "extending the syntax" post) would be to be able to make such a change from within user land. And we're not there yet.

When I mentioned that to jnthn, he got a slightly worried look. He pointed out that almost everything is based on multi dispatch in Raku, and if we can't make any assumptions about the dispatch mechanism, we might not be able to optimize the Raku as much as we'd like to.

I think that's a valid objection, but not a show-stopper. People who want to switch in their own dispatcher probably won't mind if optimizations are turned off, as long as they can do it. And if the modification is restricted to just the lexical scope or the module where it's done, the effect might not be too disastrous.

Anyway, this was today's little experiment.
