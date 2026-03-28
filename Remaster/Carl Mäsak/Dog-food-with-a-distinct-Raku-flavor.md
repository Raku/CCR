# Dog food with a distinct Raku flavor
    
*Originally published on [29 September 2010](http://strangelyconsistent.org/blog/dog-food-with-a-distinct-perl6-flavor) by Carl Mäsak.*

For a long time, I kept using use Perl for my blogging, knowing that there are better solutions out there. [blogs.perl.org](https://blogs.perl.org/) being among the most alluring alternatives. Various Raku bloggers were also reporting happiness with [Wordpress](https://wordpress.org/)-based blogs. Inertia kept me tied to use Perl.

Inertia &mdash; and something else. I had a teeny tiny dream that I could make a blogging solution in Raku. That would, I theorized, make me ultimately happy.

Except that it would never happen. It's quite a big step to move blogs, and doing it while actually *inventing* the new blog under oneself... no wai.

And then `use Perl` forced my hand. After ~10 years of service, it has now been [shut down](https://web.archive.org/web/20100912054404/http://use.perl.org/article.pl?sid=10/09/08/2053239). And suddenly, I found myself without a blogging platform.

So I thought, what the heck.

A couple of weeks later, here I stand with a working blogging solution in Raku. Yay!

I'll have a lot more to say about the blogging software as we go along, but here are the main points in bullet form:

- It's written in Raku. (See above.)
- It's currently 200 *lines* of Raku!
- It's a static website generator. (If it weren't for today's speed limitations, it'd probably generate pages dynamically. There is, after all, a wiki engine that pulled that off already two years ago.)
- It outsources Markdown generation to Perl. This may or may not be a temporary solution.
- I'm not ready to put it on github yet, but [here's a snapshot of the source](http://gist.github.com/masak/601864) if you're interested.
- There's a static website generator called Hakyll on which I'm basing the general design of my program. Over time, I hope to push things out into what will eventually become a port of Hakyll. I want to do this while continually running the blog, to make sure things keep working. (Hence the title of this post.)
- A friend tweeted that it'd be funny if there were a Java port of Hakyll [called Jyde](https://en.wikipedia.org/wiki/Strange_Case_of_Dr_Jekyll_and_Mr_Hyde). On the spot, I decided that the Raku port should be called Psyde. So that's what it'll be called.


In summary: yay, new blog! Watch this space.
