# November 14, 2008 — pioneers
    
*Originally published on [14 November 2008](http://strangelyconsistent.org/blog/november-14-2008-pioneers) by Carl Mäsak.*

98 years ago today, [Eugene Ely](https://en.wikipedia.org/wiki/Eugene_Burton_Ely) performs history's first take off from a ship. He took off from a makeshift deck on the [USS Birmingham](http://en.wikipedia.org/wiki/USS_Birmingham_(CL-2)) in a [Curtiss](http://en.wikipedia.org/wiki/Glenn_Curtiss) [pusher](http://en.wikipedia.org/wiki/Pusher_configuration).

> On November 14, 1910, Ely took off in a Curtiss pusher from a temporary platform erected over the bow of the light cruiser USS Birmingham. The aeroplane plunged downward as soon as it cleared the 83-foot platform runway; and the aircraft wheels dipped into the water before rising. Ely's goggles were covered with spray, and the aviator promptly landed on a beach rather than circling the harbor and landing at the Norfolk Navy Yard as planned. Following this flight, Ely was made a lieutenant in the California National Guard to qualify for a $500 prize offered to the first reservist to make such a flight.

Barely one year later, in October 1911, he crashed during a flying exhibition in Macon, Georgia. He was posthumously awarded the [Distinguished Flying Cross](https://en.wikipedia.org/wiki/Distinguished_Flying_Cross_(USA)) in recognition of his contribution to naval aviation.

So he was a cool guy. But I especially like how he got into flying. [Wikipedia](https://en.wikipedia.org/wiki/Eugene_Burton_Ely#Background) again:

> They [Ely and wife] relocated to Portland, Oregon in early 1910, where he got a job as a salesman, working for E. Henry Wemme. Soon after, Wemme purchased one of Glenn Curtiss' first four-cylinder biplanes and acquired the franchise for the Pacific Northwest. Wemme was unable to fly the Curtiss biplane, but Ely, believing that flying was as easy as driving a car, offered to fly it. He ended up crashing it instead, and feeling responsible, bought the wreck from Wemme. Within a few months he had repaired the aircraft and learned to fly.

I don't have time to do any serious hacking today, but I do have time to give a quick overview of the data model of November. If you have November checked out, you can follow along by looking inside the `data` directory, either in `p5w` or in `p6w`. The things I describe below are roughly the same in both implementations.

November, being a wiki engine, stores articles containing (markup) text. It also stores earlier revisions of each article, as well as a list of the recent changes to the wiki as a whole. On top of that, there's a tagging system with which you can associate a 'tag' ('label', 'category', whatever) with a page.

The directory `data/articles` contains files describing the revision history of the wiki's articles. One would perhaps think that these files could contain the (latest) contents of the article instead, and in fact they once did, sometime early this summer. But that direct model was changed and replaced by the current scheme involving one level of indirection, to make article histories and recent changes work.

A typical file in `data/articles` looks like this:

```raku
[
  '1218057494',
  '1218057386',
  '1218056287',
  '1215026471'
]
```

There are two things to note about this file. First, it's legal Perl. Turned out that was by far the easiest way to read stuff from files, by parsing them with `eval`. This design decision will likely be replaced some time in the future... but currently it works well for us.

Second, the numbers (which are strings for some reason) are unique IDs -- actually return values from the `&time` builtin. They function as pointers to files with the same name in `data/modifications`. The revisions are stored latest-first. So, for example, information about the latest modification of the article above can be found in the file `data/modifications/1218057494`. It could look something like this:

```raku
[
  'Example_article',
  'Look, I\'m the contents of an illustrative example!
I even contain newlines, fancy that.',
  'carl'
]
```

Again, this is an array reference, readily parseable by Perl. It contains three elements: the title, the contents and the user who made the change.

Now you know enough to figure out how the file `data/recent-changes` is structured. That's right, it's a serialized array of unique IDs, much like those in the files in `data/articles`.

In fact, all files in the `data` directory are similarly serialized data structures. (Except for the files in `data/page_tags`, for some reason. I should find out why.)

Finally, tags. For every article that has tags, `data/page_tags` has a file with that article's name containing a single line with a comma-separated list of tag names.

```
automobiles, airplanes, trains, space vessels
```

And the `data/tags_count` contains a simple serialized hash which keeps track of the number of occurrences of each tag on the page. As far as I can see, this file does not reflect the actual number of tags on the wiki in the repository right now — most likely, it's only for testing purposes at this stage.

All this time, you were just a few minutes' reading from understanding the internal data model of November. Now you do.
