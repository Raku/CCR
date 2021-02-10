# Bagging the changes in the Set specification
    
*Originally published on [7 December 2013](https://perl6advent.wordpress.com/2013/12/07/day-07-bagging-the-changes-in-the-set-specification/) by Elizabeth Mattijsen.*

In 2012, *colomon*++ implemented most of the then Set / Bag specification in [Niecza](https://github.com/sorear/niecza) *and* [Rakudo](https://github.com/rakudo/rakudo), and [blogged about](https://rakuadvent.wordpress.com/2012/12/13/day-13-bags-and-sets) it last year.

Then in May this year, it became clear that there was a flaw in the implementation that prohibited creating Sets of Sets easily. In June, *colomon*++ re-implemented Sets and Bags in Niecza using the new views on the spec. And I took it upon myself to port these changes to Rakudo. And I was in for a treat (in the [Bertie Bott’s Every Flavour Beans](http://harrypotter.wikia.com/wiki/Bertie_Bott's_Every_Flavour_Beans) kind of way).

## Texan versus (non-ASCII) Unicode

Although the Set/Bag modules were written in Raku, there were some barriers to conquer: it was not as simple as a copy-paste operation. First of all, all Set operators were implemented in their Unicode form in Niecza foremost, with the non-Unicode (ASCII) versions (aka Texan versions) implemented as a dispatcher to the Unicode version. At the time, I was mostly developing in rakudo on Parrot. And Parrot has this performance issues with parsing code that contains non-ASCII characters (at **any** place in the code, even in comments). Therefore, the old implementation of Sets and Bags in Rakudo, only had the Texan versions of the operators. So I had to carefully figure out which Unicode operator in the Niecza code (e.g. **⊆**) matched which Texan operator (namely **(<=)**) in the Rakudo code, and make the necessary changes.

Then I decided: well, why don’t we have Unicode operators for Sets and Bags in Rakudo either? I mentioned this on the #raku channel, and I think it was *jnthn*++ who pointed out that there should be a way to define Unicode operators *without* actually having to use Unicode characters. After trying this, and having *jnthn*++ fix some issues in that area, it was indeed possible.

So how does that look?

```` raku
  # U+2286 SUBSET OF OR EQUAL TO
  only sub infix:<<"\x2286">>($a, $b --> Bool) {
      $a (<=) $b;
  }
````

One can only say: Yuck! But it gets the job done. So now one can write:

```` raku
  $ raku -e 'say set( <a b c> ) ⊆ set( <a b c d> )'
  True
````

Note that Parcels (such as **<a b c>**) are automatically upgraded to Sets by the set operators. So one can shorten this similar statement to:

```` raku
  $ raku -e 'say <a b c> ⊆ <a b d>'  # note missing c
  False
````

Of course, using the Unicode operator in Rakudo comes at the expense of an additional subroutine call. But that’s for some future optimizer to take care of.

## Still no bliss

But alas, the job was still not done. The implementation using Hash in Rakudo, would not allow Sets within Sets yet still. It would *look* like it worked, but that was only because the stringification of a Set was used as a key in another set. So, when you asked for the elements of such a Set of Sets, you would get strings back, rather than Sets.

Rakudo allows objects to be used as keys (and still remain objects), by mixing in the TypedHash role into a Hash, so that *.keys* returns objects, rather than strings. Unfortunately, using the TypedHash role is only completely functional for user programs, *not* when building the Raku internals using Raku, as is done in the core settings. Bummer.

However, the way TypedHash is implemented, could also be used for implementing Sets and Bags. For Sets, there is simply an underlying Hash, in which the key is the *.WHICH* value of the thing in the set, and the value is the thing. For Bags, that became a little more involved, but not a lot: again, the key is the .WHICH of the thing, and the value is a Pair with the thing as the key, and the count as the value. So, after refactoring the code to take this into account as well, it seemed I could finally consider this job finished (at least for now).

## It’s all about values

Then, the [nitty gritty of the Set spec](http://perlcabal.org/syn/S32/Containers.html#line_1162) struck again.

```` raku
  "they are subject to === equality rather than eqv equality"
````

What does that mean?

```` raku
  $ raku -e 'say <a b c> === <a b c>'
  False
  $ raku -e 'say <a b c> eqv <a b c>'
  True
````

In other words, because any Set consisting of <a b c> is identical to any other Set consisting of <a b c>, you would expect:

```` raku
  $ raku -e 'say set(<a b c>) === set(<a b c>)'
  False
````

to return *True* (rather than False).

Fortunately, there is [some specification](http://perlcabal.org/syn/S03.html#line_3311) that comes in aid. It’s just a matter of creating a *.WHICH* method for Sets and Bags, and we’re set. So now:

```` raku
  $ raku -e 'say set(<a b c>) === set(<a b c>)’
  True
````

just works, because:

```` raku
  $ raku -e 'say set(<a b c>).WHICH; say set(<a b c>).WHICH'
  Set|Str|a Str|b Str|c
  Set|Str|a Str|b Str|c
````

shows that both sets, although defined separately, are really the same.

## Oh, and some other spec changes

In October, Larry [invoked rule #2](https://github.com/raku/specs/commit/2845cf6aefdc9bd0baaefe956302a480fe2a84db) again, but those changes were mostly just names. There’s a new immutable *Mix* and mutable *MixHash*, but you could consider those just as Bags with floating point weights, rather than unsigned integer weights. Creating Mix was mostly a [Cat license job](http://www.ibras.dk/montypython/finalripoff.htm#Fish).

## Conclusion

Sets, Bags, Mixes, and their mutable counterparts SetHash, BagHash and MixHash, are now first class citizens in Raku Rakudo. So, have fun with them!

