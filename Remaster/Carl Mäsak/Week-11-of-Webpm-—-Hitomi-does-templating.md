# Week 11 of Web.pm — Hitomi does templating
    
*Originally published on [26 July 2009](http://strangelyconsistent.org/blog/week-11-of-webpm-hitomi-does-templating) by Carl Mäsak.*

> *So the doodz went to Sodom, but Ceiling Cat waz stil wit Abraham, k? Abraham waz liek "OMFG, u srsly gonna kill teh good ppl wit teh bad ppl!?" "Wat if thers 50 good ppl? U stil gonna pwn it?" [...] So Ceiling Cat waz liek "k if iz 50 ppl i wont pwn it"<br></br>N Abraham waz liek "OMG, i sux, but wat if has 45 good ppl?" N Ceiling Cat sed "ill not pwn if has 45"<br></br>N Abraham was liek "wat bout 40???" an Ceiling Cat sed "i wont if has 40"<br></br>And Abraham sed "k, dont b mad or shred me, but wat if has 30?" and Ceiling Cat sed "i wont if has 30"<br></br>And Abraham sed "OMG, but wat if has 20?" and Ceiling Cat sed "i wont if has 20"<br></br>And Abraham sed "k, dont b mad, thsi is last tiem I promiz, but wat if has 10?" and Ceiling Cat sed "i wont if has 10. srsly"<br></br>And thei wer both liek "Kthxbai"* — Genesis 18:22-33

This last post was long in the coming, but I feel really happy about the progress in the past three days. I've had the chance to sit down and port large parts of the Genshi core to Hitomi, and it all nicely culminated in the first template-related test passing a few minutes ago. [Here it is](https://gist.github.com/masak/154937).

Since I'm so drenched in implementation details right now, let me just spend a paragraph or two on implementation details. What is it that happens in the test above? (It looks so easy, just replace two interpolated things, right?) Well, `MarkupTemplate` is a class which expects an XML document in some form, either as a string or as a parsed sequence of events. Since it's a string in our case, the string is sent off to `XMLParser` (a pure-Perl-6 module which will be replaced by something like [Expat](https://expat.sourceforge.net/) in the future), which reads the XML and spits out a sequence of events. It does this lazily, but the `MarkupTemplate` needs it right away, because it then goes through the events to find all instances of `$var` and `${$var}`, to replace them — hang on now — not with the values of these variables, but with special expression events with expressions containing the variable names. Why this extra level of indirection? Well, because the values haven't been supplied at this stage yet. Duh.

Ok, so the `MarkupTemplate` now sits ready with a stream of preparsed XML events intermixed with these special expression events. Now we call `$tmpl.generate` from the test, and the events are simply serialized out to a string — but before that happens, they are quickly traversed to replace all the expression events with text events containing the actual values of the variables, which we now have, since they were passed as arguments to `.generate`. Both the thing splicing the text nodes into text/expression events and the thing replacing the expression events with actual values, are called *filters*, by the way. They are very versatile and may perform any number of tasks, and they can be added at runtime to an entity such as `MarkupTemplate` to post-process the XML nodes. Also, the thing doing the serialization is called `XHTMLSerializer`, but there are a number of those, including `HTMLSerializer` which takes the same event stream but produces impeccable HTML 4.01. Well, not yet, but eventually. What I mean is that there's no need for people having a healthy aversion to XML to think that we're going overboard here by providing an XML-only solution. The XML-only is only for the insides, Hitomi will be able to both read and write HTML.

All this is on [Github](https://github.com/masak/web/tree/e4fa820911fb9cb18eb21af4ad47c4c5381cdc90/lib/Hitomi), so feel free to have a look.

This concludes my part of the grant, the one where I create the groundwork for a Web.pm module, and an XML-based templater. I promised last time to summarize the current vision for the project, along with indications for how much is done so far. Here goes:

- Web.pm

The core part of Web.pm provides a Rack-like interface for web applications of all kinds and sizes. What this means in practice is this: provide Web.pm with a callable object which accepts an `%env` argument and returns a three-item array `[$status, %header, $body]`, and you're set. (Good 8-minute introduction to Rack <a href='http://rubymanor.org/videos/rack/'>here</a>.) We've gotten this far and shown it to work with our `Nibbler` example. Rack also provides other nice things like webserver-agnosticism. We're not there yet with Web.pm, but hope to get there soon.

- Astaire

Astaire is meant to be a Web.pm port of <a href='http://www.sinatrarb.com/'>Sinatra</a>. I haven't had time to port it yet, but I imagine it will be quite simple and not too big a project. If there are any volunteers, I'll be happy to get you started!

- Tags

Tags makes it able to use Raku sub calls and blocks to output (X)HTML in Raku. It's Tene's baby, and people think it's way cool. It's certainly an improvement on CGI. Try it!

- Happle

Another idea which is not part of the grant, and which we're keeping on the back-burner for the time being. It's supposed to be a port of <a href='http://wiki.github.com/why/hpricot'>Hpricot</a>, although recently I heard that <a href='http://wiki.github.com/tenderlove/nokogiri'>Nokogiri</a> is quite awesome, too. It's blocking on things like XPath and CSS search engines.

- Hitomi

You know. The thing I've been hacking on for the majority of my Web.pm grant weeks. Feels like the work has taken of exponentially, though, and only in the past few days have I acheived results that makes Hitomi qualify as a templating engine. If you want to read about how cool Genshi is and Hitomi will be, I suggest this talk by its author. Status of the Hitomi project: see above. I just got the first templating test to pass.

- Grampa

This is a sub-project that invented itself a couple of weeks ago. It's aiming to be a general search module for Raku `Match` objects and DOM trees alike (though it still remains to be seen whether these two beasts can be fitted into the same mold; they're alike but not identical). It'll provide both CSS and XPath frontends for making searches, which will make it useful both in the Happle and Hitomi projects. I've <a href='https://github.com/masak/grampa'>started on Grampa</a>, but the progress is not substantial yet. Nevertheless, it's already the most flexible way in existence for extracting data from a `Match` object, which is saying something.

- Faz

**[Added later]** This is *ruoso*++'s baby, and ruoso isn't even part of the Web.pm grant crew, but he wanted so much to show us what he thought a regex-based URI-to-action dispatch system doing chained actions should look like, that he went ahead and [wrote one himself](https://github.com/ruoso/faz/). It's always nice to have kind-hearted outsiders add value to your project.</dd>

- Routes

This is ihrd's baby. He kept pressing me for an evaluation of it, but I simply don't know enough about MVC frameworks to be able to say anything coherent about it. It looks cool, though. I've since learned that Catalyst has something like this, and since we're aiming for something MVC-esque, this will probably come in handy.

- Forest

Our MVC framework, of which I know next to nothing. I'll be spending the next few Web.pm weeks trying to write it, though. I'm currently reading up on various MVC web frameworks to get an idea on how I want the Web.pm one to be.

Phew!

Also, while preparing for my YAPC::EU presentation, I suddenly realized that all of the above applications will require something very much like the Raku spec, which can then be tied to a spectest suite. I think that will help in many ways: it'll provide a clear explanation of what various parts of Web.pm do, it'll tie well into the tests and tell us what needs more test coverage, and it'll tell other people the status of the various projects so they know what to expect. Also, it sort of appeals to me to mimic the Raku modus operandi here, since Web.pm feels like a miniature of Raku in many other ways.

Taking over where *ihrd*++ left off, I'll be doing nine more weeks on the Web.pm grant. Let's call those weeks 12..20, just to keep the numbering simple. I've mulled over whether to switch from doing Lolcat Bible quotes to prefixing the posts with something else, like various [molecular aspects of metabolism](https://en.wikipedia.org/wiki/Citric_acid_cycle) — but I've decided to stick to the lolcats. I think I can dredge through the uneven mess that is the [Lolcat Bible](https://www.lolcatbible.com/) for nine more weeks, looking for acceptable quotes.

I wish to thank The Perl Foundation for sponsoring the Web.pm effort.
