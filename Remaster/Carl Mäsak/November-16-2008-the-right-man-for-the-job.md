# November 16, 2008 — the right man for the job
    
*Originally published on [17 November 2008](http://strangelyconsistent.org/blog/november-16-2008-the-right-man-for-the-job) by Carl Mäsak.*

624 years ago today, [Jadwiga](https://en.wikipedia.org/wiki/Jadwiga_of_Poland), a 10-year old girl, after two years of negotiations between her mother and the ruling lords, was crowned King of Poland.

Not that there's anything wrong with that. She appears to have been a just and respected monarch. [Wikipedia](https://en.wikipedia.org/wiki/Jadwiga_of_Poland):

> As a monarch, young Jadwiga probably had little actual power. Nevertheless, she was actively engaged in her kingdom's political, diplomatic and cultural life and acted as the guarantor of Władysław's promises to reclaim Poland's lost territories. In 1387, Jadwiga led two successful military expeditions to reclaim the province of Halych in Red Ruthenia, which had been retained by Hungary in a dynastic dispute at her accession.

> She died at the age of 25 from birth complications. Nowadays, she is venerated by the Roman Catholic Church as Saint Hedwig, and by others as the patron saint of queens, and of United Europe.

Been hacking on the MediaWiki parser today. Specifically, the code that finds `== headings ==` and makes `<h2>headings</h2>` out of them. I've now implemented the easy test case, where the heading is to be found on its own, and not intermixed with ordinary paragraph text. [Three tests](https://github.com/viklund/november/tree/mediawiki-markup/p6w/t/markup/mediawiki/05-headings.t) remain to be satisfied in which it is.

Also spoke to Shlomi Fish (rindolf) today, who apparently [got a grant](https://news.perlfoundation.org/post/perlbased_mediawiki_syntax_par) for doing a MediaWiki parser, but got stuck. I asked him why he found the task hard, and he gave as an example the text `a''b'''c''d'''e` (or something equivalent), i.e. improperly nested style tokens.

I know about that problem. I have [tests for it](https://github.com/viklund/november/tree/mediawiki-markup/p6w/t/markup/mediawiki/07-italic-and-bold.t) already.

In fact, a few years ago, I implemented an extremely reliable parser for a large subset of the MediaWiki syntax, but that time in Java. It had a very peculiar design goal, in that I never wanted it to fail with an error message, or with some other type of lack of output. Additionally, it sent the resulting HTML on to a set of XML transformers, so the resulting output had to be *impeccable* XHTML.

Think about it. The user can type any old broken, mis-nested, intentionally sadistic markup into the text box, and it *still* always comes out as freshly pressed valid XHTML. That's [DWIM](https://en.wikipedia.org/wiki/DWIM) on steroids, some sort of "the user is right even when she's wrong" mentality. That module is still being used by dozens of people every day at my former employer. Of all the software I've written in my life, that one is perhaps the one I'm still the most proud of.

I'm not trying to brag, just showing that I have some sense of what I'm up against. The objective for this module is somewhat different: right now, I aim for [bug-for-bug compatibility](http://www.catb.org/jargon/html/B/bug-for-bug-compatible.html). If MediaWiki parses something in an incredibly stupid way, I want to do it too. I know it would be much easier, and probably more sane, to 'tidy up' the grammar while implementing it. But I don't want that; then it wouldn't be MediaWiki markup. One should be able to copy a text from a MediaWiki instance, and paste it in a November instance.

Come to think of it, I might have to make some small concessions if MediaWiki generates invalid XHTML in some case. In that case, valid XHTML takes priority. But hopefully, I'll still be able to emulate the way the page looks.

I look forwards to the thorny bits of the markup parser. I think PGE and me will have a great time vanquishing those windmills. ☺

I already have [quite a few tests](https://github.com/viklund/november/tree/mediawiki-markup/p6w/t/markup/mediawiki); but some still remain to be written. A few tests will surely be added when I find more corner cases. But all in all, I'm making good progress. Too bad *I'm* not getting a grant. ☺

First up is satisfying those mixed-heading-and-paragraph tests. That code will have to be sufficiently general, or at least generalized later, because lists, definition lists and possibly other things will behave the same way, i.e. line-orientedly. Then comes that issue with correctly handling mis-nested bold/italic. (And mis-nested bold/italic/links.) That will most likely require its very own blog post.

P.S. I'm not usually this cocky in my blog posts, but I wrote this immediately after watching a video podcast with Randal Schwartz. In it, he said that people don't know what you're good at until you tell them. I think he's right.
