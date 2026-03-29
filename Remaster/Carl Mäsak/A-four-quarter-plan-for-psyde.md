# A four-quarter plan for psyde
    
*Originally published on [5 February 2012](http://strangelyconsistent.org/blog/a-four-quarter-plan-for-psyde) by Carl Mäsak.*

*(If this blog had had a tagging system, this post would have been tagged "meta". You have been warned.)*

My blogging engine, [psyde](https://github.com/masak/psyde), is written in Raku. It's been serving me well in the past year-and-a-quarter since use.perl went read-only and [forced my hand](Dog-food-with-a-distinct-Raku-flavor.html) to move out. It's not too powerful, and it's kinda idiosyncratic, but it has definitely made me happy.

Howver, I've increasingly been picturing where I want to take the engine. It could do more, and I know what bits I want it to do. But I never seem to get to the point where I sit down and tinker with the engine to make it better. You know, 'cus of tuits and yaks and worse-is-better and all that.

So, here goes. Now I'm changing that. Here's a four-quarter plan for 2012:

- Q1: **A way to create/edit posts online.**

All my posts sit in a repository, and theoretically I should be able to post from anywhere, just as one would expect from a blogging system. But in practice, I always forget to push the latest changes, which makes my local copy on my laptop at home the athoritative copy, and so I've no choice but to post from home. Better then to author all the posts online, to store the post sources on the server, and to have those be the authoritative copy.

Also, while writing posts in Emacs is hard to beat from a text-editing perspective, one advantage of authoring posts on the web is that I would be able to see the final HTML in real time. Better than having to wait through a compilation process to see how things will turn out.
- Q2: **A commenting system.** Finally. This includes converting the old comments from my use.perl blog and retroactively adding them, too. I'd like to use something like openID as an authentication system, or more generally, something ready-made that makes it easy to just post a comment.

I've had [Disqus](https://www.disqus.com/) recommended to me as a way to add a commenting system. While it would certainly work, it's slightly against the spirit of psyde, which is more or less [NIH](https://en.wikipedia.org/wiki/Not_invented_here). I believe it's sometimes healthy to reinvent wheels, as much to learn how to make them round as to figure out how they can be made to work better. More importantly, I wouldn't be as happy with someone else's wheel, even a well-oiled one, as with my own.

- Q3: **A text-oriented graphic library.**

I often desire to inject an image/graph/diagram or other in my blog posts, explaining the relationship between some things. But there are too many steps involved:

- open up Inkscape
- painstakingly draw and position a bunch of rectangles and arrows and text fields
- export to .png
- upload the .png
- insert an `<img>` tag linking to where I uploaded the .png

...and besides, I always feel like I'm doing work that the computer should be doing for me, drawing the SVG. I've drawn graphs like that a hundred times before, and they all look the same.

Imagine if I could just write a few symbols in my post saying "oh boy, here comes le graph!", a bit like `\[` takes me into the `displaymath` environment in LaTeX. And, *and*! Because the groundwork I will have done in Q1 enables me to see things as I type in real time, and because the graphic library that I haven't written yet will be mostly implemented in JavaScript, those graphs will appear as I type them, too! Instant graphic!

I haven't seen any other blog system do this. Let me know if there's prior art.

The graphic library will support not just graphs, but any number of pre-set picture drawing modes: graphs, class diagrams, chess boards, hex boards, tables, Nim positions, pentomino pieces, sudoku boards, sparklines, basically anything. Adding another mode should be as simple (for a programmer) as adding a syntax parser and a generator of iamge elements. There will have to be an API for all of this; details pending.

- Q4: **Productize psyde.**

After all of this, I actually think I'll have something worth sharing with people. Not everyone will prefer to leave the cozy confines of Wordpress or Movable Type or whatever it is you kids use these days, but some people will like the combination of features in psyde, and will want to set up their own blog with it.

(This already happened once, by the way. I'm not at all prepared for this, so I just sent them a `.tar.gz` file with the minimal environment needed to get set up, and they succeeded. It was a slightly bumpy ride for them, of course, but they got it working.)

Now psyde isn't really a blogging system at its core, but a static web page generator. Making a product out of it probably means turning a bunch of things into modules, and have them play nicely with [the Raku ecosystem](https://raku.land). And to make setup a one-click operation, or as close to it as possible. Probably psyde the static web generator and the yet-unnamed blogging software will separate into a module-client relation as a part of this.

When I say "product", by they way, I don't imagine I'll charge money for it. The source will remain free in all senses. I just want to make it easier to approach the software and get started with it. Removing various hard-coded things, as well as adding documentation and installation instructions, will be necessary.

Early on, I told myself that this would be a ten-year blog. We're now a few months into the second year. It's time to introduce some furniture and make this blog engine fit to live in. Fit to relax in after a hard day's work.

I want to be able to blog from my iPad. Or from a 40-inch TV screen. Or, in a pinch, from my Android phone. I want people to be able to comment. I want those graphs, oh nicely laid out, skinnable, auto-generated instant-gratification graphs! And I want to push psyde out into the wild, make it stand on its own legs.

I want to use Raku more in production, because the time is here. Even though I know it's prudent to underpromise and overdeliver, I choose to publish my plans like this because so far I've only been scheming and dreaming &mdash; this somehow makes it all more concrete.

Onwards!
