# The world according to .PARROT
    
*Originally published on [13 November 2008](https://use-perl.github.io/user/pmichaud/journal/37870/) by Patrick Michaud.*

In Rakudo we have a number of places where bits of Parrot poke out from underneath the covers at inconvenient times; masak, moritz, and chrisdolan have been particularly good at finding these, especially when dealing with [strings in Rakudo](../Carl Mäsak/November-11-2008-the-calm-after-the-storm.html).

When we get HLL mapping fully working in Rakudo then a lot of these will go away; in the meantime I've been trying to explain what's happening "behind the scenes" that cause the seemingly bizarre behaviors.  But yesterday I decided it would be better to provide a way to remove the covers entirely...

So, Rakudo now has a .PARROT method that reports the underlying Parrot data type for an object.  This is in contrast to .WHAT, which gives back the (sometimes imperfect) Raku view of an object.  

Here's an example involving %\*ENV -- normally we expect values in %\*ENV to be (Perl6) Str objects, but the current implementation of %\*ENV tends to give us String PMCs.  But rakudo considers Parrot String and Raku Str to have the same .WHAT protoobject, so it looks like it's a 'Str'.
```
> say %*ENV<HOME>;
/home/pmichaud
> say %*ENV<HOME>.WHAT;
Str
```

The new .PARROT method lets us view the true identity of an object:
```
> say %*ENV<HOME>.PARROT;
String
```

This still doesn't fix the problem, but at least it gives some transparency into what's going on.

I also adjusted the value semantics for the String PMC so that it auto-promotes to a Raku Str object whenever it's asked for its scalar value.  That should make it easier to get things into the form needed to get work done, at least until we can complete our other transitions that make this more seamless.
