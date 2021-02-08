The Raku Collect, Conserve and Remaster Project
===============================================

Raku has a more than 20 year long history, most of it as "Perl 6".  In this timeframe, many people have been involved in the project and have written blog posts about it.  Sadly, some of these have already been lost in the mists of time.

On the other hand, the syntax and semantics of the Raku Programming Language has seen several shifts and changes, so at leat some of the blog posts are now providing examples that will not run in the latest version of Raku.

Finally, from a search engine optimization perspective, the Raku Community could benefit from an immediate source of up-to-date blog posts of the Raku Programming Language, as opposed to out-of-date Perl 6 blog posts.

The Raku CCR project intends to remedy this situation in three stages:

[Collect](Collect)
-------
The goal of this phase is to collect as many URLs of Perl 6 blog posts that we can find, and order them by author.  If URLs are known to fail already, they should be collected anyway in the hope that places like the Wayback Machine can provide a copy of the blog post after all.

These URLs are put into a file in markdown format with a file per author.  This will mostly be a manual process.

[Conserve](Conserve)
--------
The goal of this phase is to get a raw version of the HTML of the blog post, including any pertinent graphics (images) into the CCR repository, so that they can be saved for posterity.  Each author has a separate directory, and each blog post has its own subdirectory with the content of the blog post and associated assets and meta-information.

[Remaster](Remaster)
--------
The goal of this phase is to produce updated blog posts from the original content, making sure that the name Raku is used instead of Perl 6, and that the code examples in the blog posts will actually work in the most recent version of Raku (or be marked as no longer being supported).  If the license of the blog post is unclear, permission will need to be obtained from the author.  If an open source license is used for the blog post, no further permission is needed, but contacting the author as a courtesy, will be appreciated.

If a permission for remastering is (implicitly) obtained, then a blog post can be remastered to make it up-to-date on the current state of Raku.  This will mostly be a manual process.  The resulting blog posts will be made available at a dedicated website for this purpose with hopefully an easily searchable URL, something like "blogs.raku.org", potentially in a "Remastered" section.

Participation
=============
This should become a community project.  Hopefully some authors of blog posts will take the opportunity to update their blog posts in this format, or decide to redo them in their own way.  Pull Requests for changes, particularly for the Collect and Remaster phase will be greatly appreciated.  Hopefully, the Conserve phase can be largely automated taking the URLs from the Collect phase.  Pull Requests for creating / maintaining that process, will also be greatly appreciated.

Naming
======
Yes, the name is a reference to [https://en.wikipedia.org/wiki/Creedence_Clearwater_Revival](Creedence Clearwater Revival), one of yours truly favourite bands.
