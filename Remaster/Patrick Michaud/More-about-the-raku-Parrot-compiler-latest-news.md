# More about the raku/Parrot compiler, latest news
    
*Originally published on [31 December 2007](https://use-perl.github.io/user/pmichaud/journal/35250/) by Patrick Michaud.*

I hope everyone is having a good holiday, I know that I am!  However, even with the holidays work has continued on raku/Parrot, so here's some of the latest tidbits.

Several people have commented that the plethora of tools and acronyms used for building the raku/Parrot compiler seems a bit overwhelming (PAST, PCT, PIR, PGE, NQP, ...).  I can totally understand the sentiment expressed, so this weekend I spent some time drafting some documentation that I hope will start to blaze a trail through the jungle.  The document is available in the Parrot repository (or follow the link to view it in a browser).

I also started a raku-specific glossary of acroynms and terms for the compiler.  Parrot has its own glossary that defines these items, it also includes a lot of terms and features that I think might be distracting to a raku hacker, so I created the rakupecific one.

Of course, both documents are first drafts, so they may still not be totally clear, and there are some sections to be written still).  The main goal for the documents is to highlight the important components, so that newcomers will be less distracted by the things of lesser importance.

Any feedback or comments on the drafts would be greatly appreciated.  I'm hoping that these can also serve as a start to the generic compiler tools documentation, or "How to write a compiler for Parrot".

As to making it easier for people to contribute code, there's still one piece that needs to be in place first:  we need to decide on the file structure we'll use to organize the Raku source files in the compiler, and how they'll be linked in to the raku runtime environment.  I expect to have this in place sometime tomorrow, and after that I think it will be much more obvious how it all fits together.

Several have expressed that they're looking to replace all of the existing PIR code with Raku equivalent...but I don't think that's realistic (or necessary).  The PIR code that exists now is mainly for implementing Raku primitive types and operations (things like Str, List, infix:<+>, etc.), and these are likely to remain in PIR because they're, well, primitives.  Once built, the primitives don't need much hackery anyway, and then other functions and features can be written using Raku sources on top of those primitives.

Anyway, if you're at all interested, read the documents, ask questions, and give it another day or two and I think (hope) it will all become much clearer, or that we can put the pieces in place to make it so.  And I expect to have some good detailed examples soon as well.

In other news, *chromatic*++ and others have made some excellent progress on getting the pbc_to_c translator working.  I haven't had a chance to play with it much yet, but once all of the kinks are worked out we should be able to compile raku into its own executable, so that someone can type "raku hello.pl" and have it work the way we all expect.

Also, Jerry Gay did a lot of work last week on adding optional and named parameters to NQP.  While this doesn't translate directly to raku, it does give us the basic outline for the raku implementation, which I think we will also have this week.

My other immediate task for the week is to get cracking on the test suite reorganization, because I know a lot of people are interested in helping with that.  As always, there's just so much to do!

Lastly, there have been quite a few opinion posts on perlbuzz this past week about the past, present, and future of Raku.  As part of the conversation Andy Lester asked if there was any way to describe what had been accomplished thus far in Raku, and in response I wrote up my [view of "Here's what we've done"](https://web.archive.org/web/20080203071348/http://perlbuzz.com/2007/12/one-view-of-heres-what-weve-done-in-perl-6.html).  I think it shows that we're a lot farther along than many people realize, and not only that but the pace of development is picking up dramatically.  It's worth a look.

Happy new year, everyone!
