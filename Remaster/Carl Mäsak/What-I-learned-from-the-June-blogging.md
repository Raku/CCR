# What I learned from the June blogging
    
*Originally published on [25 July 2011](http://strangelyconsistent.org/blog/what-i-learned-from-the-june-blogging) by Carl Mäsak.*

So, I confess: I had fun. Pushing out a blog post a day for a month sounds like a lot of work, but it was mostly enjoyable.

I've been wanting to try this kind of thing for a year or so. Now that it's behind me, it feels like the material produced begs for being put into a form other than just blog posts. Therefore, I've [created a repository](https://github.com/masak/adventure-game-book) for the chapters. From now on, changes/improvements will go into those, and the blog posts are essentially frozen. I expect to have a PDF of all the chapters soonish.

Having done three November blogging months, I guess I didn't expect to learn much new. But this kind of setup was sufficiently different, and I ended up with a few take-aways.

## What I learned from blogging once a day

- **It's easy to fall off.**

More exactly, I have a full-time job now, thanks to Raku. I thought that, if anything, would be what would prevent me from doing this. But no, it was essentially going to a conference and do the usual last-minute dance with slide preparations. D'oh! Having fallen off, it was a bit hard to get back on again.

- **It's fun.**

My regular hobby hacking more or less got put on hold, but every day I feel like I've accomplished something. It's great. There was never any real lack of things to write about; making up the topics ahead of time took more thinking than actually writing the posts.

- **I should have had a blog commenting system when doing a blogging month.**

Been wanting to build one, but `ENOTUITS`. [Disqus](https://disqus.com/) looks great, and people have been pointing me to it, but I think I'd prefer in the long run to build something myself. Yeah, that means it's going to take a bit longer, I know. As it was, I got a lot of good feedback from `#raku` (as usual). But not everyone hangs out on `#raku`.

## What I learned from trying to bootstrap Raku knowledge

- **Things can be bootstrapped fairly easily.**

This surprised me. There's at least one fairly linear order for concepts to be introduced.

- **I need to go back and re-do everything.**

For most games, but *especially* the last one, I found myself using concepts that I *should* have introduced in some earlier chapter, but didn't. Of course I should've mentioned bareword keys in the post about hashes. It's evident in retrospect that I should've spent more time on public accessors and constructors in the chapter about classes. And probably `.can` and the `.?method` syntax too. While the themes for each day seem to have been mostly well-chosen, there's just so much that I failed to mention.

- **It's easier to explain a concept than to explain why you wrote a game the way you did.**

Or rather, it got more difficult to adequately explain the games the bigger they got. It's like small games contain all these interesting little decisions, and that's fine to explain. But then as they grow bigger they also start to contain all these overarching, architectural decisions. And there just isn't enough blog space and reader attention to focus both on the big and the small issues, so I increasingly focused on the big ones. But the little decisions are still there, even in the bigger games.

- **There's just so much to tell.**

I'm thinking of adding sections to each chapter named "The full story" or something, just to bring up the slightly more advanced topics that aren't necessarily in the path of someone who just wants to learn the basics and implement a game.

## What I learned from writing a text adventure game

- **It was just as enjoyable as I hoped it would be.**

I had been looking forward to this.

- **It is a bigger project and takes more time than one might think.**

How hard can it be, right? Just four, no five, no six rooms. Be done in a jiffy. Looking at the commit logs for the game, it seems it took closer to 14 days. Keep in mind, that's for a game I expected to have ready in two days. Oh, the optimism.

- **I wish I had written tests for it.**

Not sure how it would have affected the code, but the game *definitely* is complex enough to merit tests. Henceforth, my answer to the question "Shall I write tests?" will be "Is it more than a screenful of code?". (The sad thing is, I *know* this, and have for a long time. I should listen more to myself.)

- **The game isn't finished.**

I had to push it out into the world, but feedback keeps coming in, and it'll keep settling and evolving for quite some time yet. It's a big little program now, and won't just sit around doing nothing. All I can do as a proud parent is look on from a distance and hope for the best.

Fun as it was, I can't think of a followup for this project for next June. Let's just see where we are at that point and decide then. 哈哈
