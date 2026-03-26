# November 28, 2008 — "...take thee, Annam Whatley..."
    
*Originally published on [29 November 2008](http://strangelyconsistent.org/blog/november-28-2008-take-thee-annam-whatley) by Carl Mäsak.*

426 years ago today, William Shakespeare and [Anne Hathaway](https://en.wikipedia.org/wiki/Anne_Hathaway_(Shakespeare)) paid a £40 bond for their marriage license. He 18, she 26 and pregnant. This has led some historians to speculate that perhaps this was a [shotgun wedding](https://en.wikipedia.org/wiki/Shotgun_wedding). [Wikipedia](https://en.wikipedia.org/wiki/Anne_Hathaway_(Shakespeare)):

> The argument was apparently supported, though, by documents from the Episcopal Register at Worcester, which records in Latin the issuing of a wedding licence to "Wm Shaxpere" and one "Annam Whatley" of Temple Grafton. The day afterwards, Fulk Sandells and John Richardson, relatives of Hathaway from Stratford, signed a surety of £40 as a financial guarantee for the wedding of "William Shagspere and Anne Hathwey". Frank Harris, in The Man Shakespeare (1909), argues that these documents are evidence that Shakespeare was involved with two women. He had chosen to marry Whatley, but, when this became known, he was immediately forced by Hathaway's family to marry their pregnant relative. According to the Oxford Companion to Shakespeare, most modern scholars take the view that the name Whatley was "almost certainly the result of clerical error".

> Germaine Greer argues that the age difference between Shakespeare and Hathaway was typical of couples of their time. Women such as the orphaned Hathaway often stayed at home to care for younger siblings and married in their late twenties, often to younger eligible men. Furthermore, a "handfast" marriage and pregnancy were frequent precursors to legal marriage at the time. Shakespeare, certainly, was bound to marry Hathaway, having made her pregnant, but there is no reason to assume that this had not always been his intention. It is likely that the respective families of the bride and groom had known one another.

Back on MediaWiki markup again. Started out on the parsing of italic and bold text; made a solution using regexes that I'm almost certain won't take me the whole way.

This is actually a situation where regexes are especially badly suited, as far as I can see. Or rather, successively transforming the same string with one regex after the other is kind of a dead end in this case. I would advise anyone who doubts this to take a look at [the tests](https://github.com/viklund/november/tree/mediawiki-markup/p6w/t/markup/mediawiki/07-italic-and-bold.t) and try to mentally concieve of a series of regex transforms that will satisfy those tests. ☺

Instead, I will probably build a simple tokenizer (which perhaps uses regexes in some way), because tokens are much easier to handle than text. Whatever the final solution, it will almost surely have to iterate through the stream of tokens, flip bits for italic and bold text, and watch out for all the mis-nesting pitfalls.

4 tests out of 14 pass by this naïve approach. Let's see if I can make us less naïve tomorrow.

Also, today *pmichaud*++ said he's going to start working on array assignment. Another improvement in which to bask.
