# Where in the world is the package lexpad?
    
*Originally published on [22 August 2010](http://strangelyconsistent.org/blog/where-in-the-world-is-the-package-lexpad) by Carl Mäsak.*

*(This post isn't very punny. For those of you who need puns to survive, try to figure out why *jnthn*++ named the IRC logs "the hottest footwear" recently. The answer, as with all good puns, is highly unsatisfying.)*

My quest for a Raku implementation takes me ever deeper into the esoterics of lexpads, runtimes, and a far-more-than-everything-you-needed-to-know mindset. Today some random firings in my brain turned into the following conversation on #raku.

During the conversation, I proposed two theories, both of which turned out to be wrong. (*pmichaud*++ shone the necessary light both times.) Being wrong felt less important than getting my mental model fixed.

I first thought of presenting the results of the below conversation as a simple tutorial ("How `our` declarations work. The complete guide."), but now I think that the conversation, minimally edited, manages to be such a tutorial on its own.

Besides, blogging things in their raw and undigested form is a sign of the times. Enjoy!

```
<masak> I have a question. is there a need for a special "package lexpad" containing 'our'-declared variables, or can the package lexpad simply be equated to the topmost lexpad in the package?
<masak> my suspicion is the latter, but I might be missing something.
<pmichaud> the package lexpad can't be the same as the top most lexical
<pmichaud> **module XYZ { my sub `abc` { ... } };   # abc should not appear in the package** 
<masak> oh!
<masak> right.
<masak> so, separate one, then.
<jnthn> Additionally, lexpads are meant to be static by the time we hit runtime, and you're allowed to shove stuff into the package dynamically. Not quite sure how those two hold together.
<pmichaud> well,  **module XYZ { ... }**   creates a lexical XYZ entry that holds the package entries
<jnthn> Aha!
<pmichaud> and it's just a hash, really.
<masak> does inserting the package lexpad below the outside lexpad (and above the topmost lexpad) make sense? that way, Yapsi wouldn't need any special opcodes for doing 'our'-variable lookups.
<pmichaud> the package lexpad is an entry in the outside lexpad, yes.
<pmichaud> I'm not sure it encapsulates the nested lexpad, though.
<masak> hm.
<masak> if it doesn't, I don't really see how it's visible from inside the package.
<masak> I've more or less convinced myself that sandwiching it between outer and topmost is what I want to do for Yapsi.
<pmichaud> **our &xyz**  can make an entry in both the package and in the lexical.
<pmichaud> this is what rakudo does now.
<pmichaud> we have to do similar things for methods already, too.
<masak> sure. it makes entries in both.
<pmichaud> by having entries in both, that's how it's visible inside the package
<masak> hm, indeed.
<masak> no need to have the package lexpad visible from inside.
<pmichaud> anyway, sandwiching might work too.  haven't quite gotten to that point in Rakudo thinking yet.  And it can get a bit tricky with multis.
<masak> no need to sandwich it in, either. it can sit in limbo outside the tree of scopes.
<pmichaud> oh, I know why it perhaps shouldn't (or should) be visible:
<pmichaud> **my $x = 'lexical';   module XYZ { say $x;  { our $x = 'package'; } }** 
<masak> ...yes?
<pmichaud> I'm pretty sure "say $x" needs to grab the 'lexical' $x, not the one that might be "sandwiched" in a package.
<masak> of course.
<masak> that falls out from ordinary scope nesting and shadowing.
<masak> innermost block binds its lexical to the container in the package lexpad.
<masak> so, that speaks out against sandwiching.
<masak> *pmichaud*++
```

So there you go. There's a separate package scope, and it isn't sandwiched.

*(Answer: The missing link is the "IR clogs" meme from #parrot. I can hear you groaning... I did warn you.)*
