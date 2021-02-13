# Looking for Raku, Rakudo, and MoarVM development funding
    
*Originally published on [2017-05-12](https://6guts.wordpress.com/2017/05/12/looking-for-perl-6-rakudo-and-moarvm-development-funding/) by Jonathan Worthington.*

**Note for regular 6guts readers:** this post isn’t about Raku guts themselves, but rather about seeking funding for my Raku work. It is aimed at finding medium-size donations from businesses who are interested in supporting Raku, Rakudo, and MoarVM by funding my work on these projects.

I started contributing to the Rakudo Raku compiler back in 2008, and since then have somehow managed to end up as architect for both Rakudo and MoarVM, together with playing a key design role in Raku’s concurrency features. Over the years, I’ve made time for Raku work by:

- Spending a bunch of my free time on it.
- Only working an 80% day-job for five years, effectively self-funding a day a week for Raku things. During this time I did also take various “milestone” grants (for delivering notable features); this mostly ended up paying for my travel to a bunch of workshops and conferences, which was a great deal of fun and helped keep the community informed during Raku’s long gestation period.
- Most recently, taking funding at a rate that – while less than I could make doing other stuff – lets me comfortably work on Raku as a part of my normal daily job.

I’m still greatly enjoying doing Raku stuff and, while I’ve less free time these days for a variety of reasons, I still spend a decent chunk of that on Raku things too. That’s enough for piecing together various modules I find we’re missing in the ecosystem, and for some core development work. However, the majority of Raku, Rakudo, and MoarVM issues that end up on my plate are both complex and time-consuming. For various areas of MoarVM, I’m the debugger of last resort. Making MoarVM run Raku faster means working on the dynamic optimizer, which needs a good deal of care to avoid doing the *wrong* thing really fast. And driving forward the design and implementation of Raku’s concurrent and parallel features also requires careful consideration. Being funded through The Perl Foundation over the last couple of years has enabled me to spend quality time working on these kinds of issues (and plenty more besides).

### So what’s up?

I’ve been without funding since early-mid February. Unfortunately, my need to renew my funding has come at a time when The Perl Foundation has been undergoing quite a lot of changes. I’d like to make very clear that I’m hugely supportive and thankful for all that TPF have done and are doing, both for me personally and for Raku in general. Already this year, two Raku grants have been made to others for important work. These were made through the normal TPF grants process. By contrast, my work has been funded through a separate Raku Core Development Fund. As a separate fund, it thus needs funds raising specifically for it, and has its own operation separate from the mainstream grant process.

Between the fund being almost depleted, and various new volunteers stepping up to new roles in TPF and needing to get up to speed on quite enough besides the Raku Core Development Fund, unfortunately it’s not been possible to make progress on my funding situation in the last couple of months. I’m quite sure we can get there with time – but at the same time I’m keen to get back to having more time to spend on Raku again.

So, I’ve decided to try out an alternative model. If it works, I potentially get funded faster, and TPF’s energies are freed up to help others spend more time on Perl. If not, well, it’ll hopefully only cost me the time it took to write this blog post.

### The Offer

I’m looking for businesses willing to help fund my Raku development work. I can offer in return:

- To spend quality time on Raku, Rakudo, and MoarVM.
- To either spend the time on the areas that I feel are most pressing based on my own judgement and input from the community, *or* to spend it focusing on areas of the sponsor’s interest (for example: improving native call performance, delivering concurrency improvements such as completing non-blocking `await` or `hyper`/`race`, building a sampling profiler to give better insight into long-running programs, improving the MoarVM dynamic optimizer so hot code can run faster, etc.)
- To write at least one blog post here per 25 hours of work completed. Rather than a boring list of stuff that I got done, I prefer to write posts that focus around particularly interesting problems I solved or that dig into the details of things that I have implemented. I will be happy to mention the sponsor of the work in these posts, together with a link, logo, etc.
- Per 100 hours funded, provide 5 extra hours of my time that the sponsor may use as they wish (within reason!) That may be for consultation on any topic you figure I might be clueful about (not just Raku), writing an article for you on a topic of your choice, and so forth. Or, if you wish to donate the bonus time back to Raku related work, that’s of course fine too (and I’ll be sure to mention you did so!)
- Billing by invoice issued from a VAT-registered company with its seat in Prague, Czech Republic.
- When I get a Raku related book done (shhhh…don’t tell *anyone* I said that I’m working on one), I’ll send along a few signed copies. :-)

I’m setting a rate for this work of 55 EUR / hour with a minimum order of 25 hours. This need not be billed all in one go; for example, if you happened to be a company wishing to donate 1000 EUR a month to open source and wished to be invoiced that amount each month, this is entirely possible. After all, if 3-4 companies did that, we’d have me doing Raku stuff for 2 full days every week.

If you’re interested in helping, please get in contact with me, either [by email](mailto:jonathan@edument.se) or on freenode (I’m `jnthn` there). Thank you!
