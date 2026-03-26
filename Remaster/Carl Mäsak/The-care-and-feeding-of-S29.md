# The care and feeding of S29
    
*Originally published on [27 December 2008](http://strangelyconsistent.org/blog/the-care-and-feeding-of-s29) by Carl Mäsak.*

As I've [said before](November-6-2008-making-waves.html), S29 needs a lot of attention. It's a good resource for the things it covers, but it's also sadly lacking in many places.

Last night I found the time to skim through the synopses in one sitting, looking for functions and methods covered in other synopses but not in S29. My findings divide into "questions" and "omissions".

## Questions

- I see the sub version of `defined` declared in S29. Is the method version (used in S02:519) also in S29? I can't see it, but I might be missing something about how method signatures work.
- Should the methods `.new` and `.clone` be covered by S29? They're slightly different beasts than `abs` or `push`, but they're still in a sense "builtin functions in Raku".
- Same question for `BUILD` and `CREATE`.
- What about metaclass methods, like `.HOW.methods`? Should they be covered in S29?
- Should there be a way to extract information about a `Rat`'s numerator/denominator? What methods does a `Rat` have?
- if `:exists` and `:delete` get honourable mentions as methods, maybe we should have `:p`, `:kv`, `:k` and `:v` too
- what's the name of the class that method descriptor objects belong to?
- ditto attribute descriptor objects.

## Omissions

Things that no longer are omissions are marked in parentheses with a date and the wonderful person who added it.

- `isa`, `does`, `can` (*moritz*++ 2009-01-05)
- `.perl` (*moritz*++ 2009-01-05)
- `.succ`, `.pred` (fixed on 2009-01-08)
- `any`, `all`, `one`, `none`. these are also methods, on `Hash` for example. (fixed on 2009-01-08)
- `warn` (fixed on 2009-01-08)
- The `slice` contextualizer. (S03:1945) (fixed on 2009-01-08)
- The `hash` contextualizer. (fixed on 2009-01-08)
- The filetest operators. These are covered in S16, so maybe just mention them.
- ``true``, ``not``, also methods
- `Range` objects have `.from`, `.to`, `.min`, `.max` and `.minmax` methods (*wayland*++ 2009-02-27)
- .`contains` on `Hash` and `Array` [update: not anymore]
- `Code` has a `.sig` [update: now unambiguously .signature]
- `.ACCEPTS` and `.REJECTS` on most everything -- provided by the Pattern role. Likely a mistake to put one under each section, though. Perhaps put one under Object and put a reference to S03.
- The `cat` contextualizer (*wayland*++ 2009-02-27).
- `Object` has `.print` and `.say`.
- `Block` types have `.next`, `.last`, `.redo` and `.leave` on them. These are also functions, and need to be specced as such. (*wayland*++ 2009-02-27)
- `Block` also has a `.labels` method. (*wayland*++ 2009-02-27)
- `fail` and `.handled` (the former is in S29, but has no signature/summary). (*wayland*++ 2009-02-27)
- `.match`, `.subst` and `.trans` from S05. (*wayland*++ 2009-02-27)
- `Match` objects: `.from`, `.to`, `.chars`, `.orig` and `.text`. (*wayland*++ 2009-02-27)
- Match state objects: `.pos`. (*wayland*++ 2009-02-27)
- ``context`` (*wayland*++ 2009-02-27).
- `.wrap`, `.unwrap` and `.assuming` (*wayland*++ 2009-02-27).
- `callsame`, `callwith`, `nextsame`, `nextwith`, `lastcall`.
- ``VAR``, though a macro, could possibly get honourable mention. (*wayland*++ 2009-02-27)
- Method descriptor objects: `.name`, `.signature`, `.as`, `.multi`, `.do`.
- Attribute descriptor objects: .`name`, .`type`, .`scope`, .`rw`, .`private`, .`accessor`, .`build`, .`readonly`.

I'll see if I can add these during the coming month. A helping tuit or two would be greatly appreciated.
