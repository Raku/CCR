# Signature Objects
    
*Originally published on [8 July 2008](https://use-perl.github.io/user/JonathanWorthington/journal/36875/) by Jonathan Worthington.*

The first of this week's two Rakudo days (as I catch up from not having one last week) was today, and I dedicated it to working on signature objects. These are something I need to implement MMD, but also come into play in various other situations. For example, if you write something like:

```` raku
my ($a, $b);
````

Then this is constructing a signature object on the left hand side, which you can bind to; assignment to it will also work at some point in the future (but not yet). Signatures also appear, of course, on methods and subs, and we've had those working in some form for quite a while in so far as you could pass parameters, get them type-checked and so forth. We weren't constructing real signature objects, however. And to provide the rich information about the signature and the types that an implementation of Raku MMD needs, we need to start constructing them. This will also allow you to introspect the signatures of subs amd methods at runtime (it's not a lot more work to get that in place from what I've got done today).

While a lot of todays work was beneath the surface - actually constructing the signature objects rather than using them - there is some visible stuff. For one, you can now write declarations like this:

```` raku
my ($a, $b, $c); # declares all three variables
class Foo { has ($.x, $!y); } # declare both attributes
````

Note that you can't do assignment to many things at once just yet - that's part of list assignment. It's high on *Patrick*'s todo list, so we should have that soon. I'll probably get some parts of it in (implementing assignment to the signature) next Rakudo day.

I also implemented the :(...) syntax which parses what is between the parens as a signature and creates a signature object. This works now, though not all signature syntax is parsed yet.

Finally, you can get hold of the constructed `Signature` object by doing something like `&foo.signature`, though at the moment you can't do much at all with it. Well, I guess you can `say &foo.signature.WHAT` and see that it's a `Signature` object. The introspection interface isn't fully specified, but I asked about it on list and *Larry* provided an idea as to what he expects to see, so I'll use that to guide my implementation.

Signatures can be incredibly powerful; once we get a full implementation, you will be able to unpack trees nodes right there in a signature and all sorts. For now, I just want to get an initial implementation that builds signature objects holding all the information needed to get on with an MMD implementation, though I'm sure things like smart-matching against them and the more advanced features of them will follow in the not too distant future too.

Thanks to Vienna.pm for funding today's work, and also for knowing a really nice Mexican restaurant to go to after their tech meet last night. Good food, good beer, good fun. I like living in a city with a Perl Mongers group, and just an hour down the road from Vienna, which also has a good, active one. :-)
