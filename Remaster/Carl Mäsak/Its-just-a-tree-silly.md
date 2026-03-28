# It's just a tree, silly!
    
*Originally published on [29 September 2010](http://strangelyconsistent.org/blog/its-just-a-tree-silly) by Carl Mäsak.*

![Tree and Road](tree-and-road.jpg)

I'm starting to see a pattern in more and more places of programming. I haven't looked too hard for its real name — and it probably has one, as common as it is — but for now, I  can think of several: *the compiler pattern*, or *generate, transform, serialize*, or *it's just a tree, silly*.

> Tweets audreyt: 'Reminds me of ["Origami Programming"](https://www.comlab.ox.ac.uk/people/jeremy.gibbons/publications/origami.pdf) named by Jeremy Gibbons'

If I am first in formulating this as a pattern, then... wohoo! But I strongly doubt that I am.

Here's how it works: at the start of the program, something reads some input and converts it to an internal format called, for the purposes of this post, *the internal format*. Then zero or more dedicated parts of the program massage the data, which is now in the internal format. Finally, something converts the whole thing to a serialized form and outputs it. That's it: input, massage, output. Or, if you wish, generate, transform, serialize.

The pattern should be familiar to Perl programmers. Perl is, after all, an *extraction* and *reporting* language, and professes to perform at least these two tasks in a practical way. In the case of Perl, the internal representation consists of data structures in the form of arrays and hashes.

In a previous life, I helped manage a web app written on top of [Apache Cocoon](http://cocoon.apache.org/), through which I learned the triplet *generate, transform, serialize*. In the case of Cocoon, the internal representation is XML. Cocoon is one of the few programs out there that actually use XML for something significantly more than hype and cargo culting. It's worth checking out. The generators, transformers and serializers in Cocoon are the actual primitives, and changes to the web app are made in a sitemap file containing the way these primitives are piped together.

A compiler can be seen as these three steps. There's even a ready-made vocabulary for them: front end, middle end, and back end. The internal structure is a tree representing the nested regions of the program text, or (later) possibly a more abstract tree representing actions and control flow. One example is Yapsi, our p6-implementation-in-p6. There's a grammar at the front end parsing the text into a tree of Matches. Little top-downers and bottom-uppers climb around this tree and decorate it with important information. Then the tree is flattened out into flat text-y SIC and shuttled off to the runtime.

Or take Hitomi, the not-quite-finished template engine that lets you mix XML and Perl code, leveraging the power of both. The secret recipe it uses to make this possible... is the patterns again: read in the original template at one end, parse it up into an XML stream, let the stream flow joyously through various filters before finally being serialized as text at the other end.

Even a small utility program that I wrote years ago to convert a bunch of money transactions to a final tally of who owed whom what qualifies for this pattern, though only barely. See, it read in the format (in YAML), represented it internally as a directed weighted graph, did a number of simplifications on the graph until it could get no simpler, and finally spat out the result (as YAML).

Why is this pattern so common? This seems to be a difficult question to answer until one realizes that the alternative, *not* to convert to the internal format, is usually much, much worse. In all of the above cases, the data is *lifted* from its original format, it's *freed* from the shackles of text, and clad in beautiful clothes made of the purest trees, graphs, streams and other structures that allow the programmer not only to *see* the things she is manipulating more clearly, but also to think more clearly about the programmatical units doing the manipulating. In freeing the data from the text, she frees herself from death by a million `substr` calls.

In some sense, [Postel's law](https://en.wikipedia.org/wiki/Robustness_principle) is showing through here as well.
<div class="quote">Be conservative in what you send; be liberal in what you accept.</div>

By having to pass through the fire test at the beginning, we make sure that nothing of the liberalness remains of the input that we accept into the sensitive inner workings of the program (perhaps because they can't even be *represented* by the internal format), and knowing that what we have after that point is a very exact version of the data allows us to be very flexible in manipulating it. The strictness in the output follows as a natural consequence of the internal format being strict. Cocoon will never output mismatched XML tags, unless perhaps you write a faulty serializer.

It was the following last example that made me think of all this: in order to rescue the blog content from `use Perl` to my new blog, I decided to download it all and massage it with a Perl script. Source format: `use Perl`'s idiosyncratic HTML soup. Target format: Markdown. Three, two, one, go!

What I ended up writing was a `while (m//g) { ... }` loop that found start and end tags for me, thus tokenizing the input into tags and their intervening text content. Friendly hash references made sure things ended up in the right places in a tree. Presto, an explicit tree made from the implied tree of the HTML tags.

(It was a this point that I started noticing that `use Perl` produces opened-but-never-closed `<div>` entities each time someone uses the made-up `<quote>` entity in a blog post. Easy enough to work around, but... odd that no-one has noticed, during all those years of Slashcode.)

Next step: serialize the tree down into Markdown. This step contained a lot of heuristics, some catering to Markdown's preferred number of escapings in various contexts, some adding post-facto richness that never was, and never could be, in the original `use Perl`-crippled HTML. It was fun work, because what this script was a lot of blog posts that I had written in insane HTML, now converted to sane Markdown.

It was only after I was done that I stopped to wonder why I had chosen to go the way of a tree when doing this. Couldn't I have skipped the middleman and just converted HTML tags to Markdown directly?

And here's the thing: no, I don't think so. I don't think I would have finished the task had I chosen to solve it without the intermediate tree structure. Because it would have come down to parsing *a lot* of text with increasingly crazy regexes, some of which would have had to take into account deep nesting... instead of handling the deep nesting using subroutines recursing over a tree.

So, yes, *it's just a tree, silly*. Or a directed graph, or a DOM, or a stream. But often that's just what's needed to make the problem manageable.
