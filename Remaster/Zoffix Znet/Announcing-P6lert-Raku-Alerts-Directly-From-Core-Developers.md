# Announcing P6lert: Raku Alerts Directly From Core Developers
    
*Originally published on [29 December 2017](https://perl6.party//post/Announcing-P6lert-Perl-6-Alerts-Directly-From-Core-Developers) by Zoffix Znet.*

Development of Rakudo Raku is quite fast-paced, with hundreds of commits made each month to its five core repositories. Users undoubtedly feel some impact from those commits: bug fixes may break code that relied on them, backend changes may have unforeseen impact on the user code, new useful features may be implemented that users would want to know about.

In the past, for things with very large impact, we made blog posts, but there are lots of small things that fly under the radar, unless you actively pay a lot of attention to [Rakudo Raku's core development](https://rakudoweekly.blog/).

To help *all* of our users to be aware of important issues, we're announcing introduction of *P6lert* service: tweet-sized alerts from Raku Core Developers.

## The Goods

The *P6lert* service primarily consists of [alerts.raku.org](https://alerts.raku.org) website, but with it come a variety of ways to receive alerts posted on it:

- All alerts are automatically tweeted by unmonitored [@p6lert Twitter account](https://twitter.com/p6lert); all tweets include [#p6lert hashtag](https://twitter.com/search?q=%23p6lert&src=typd)
- There is an [RSS feed](https://alerts.raku.org/rss) you can subscribe to
- The site offers an [API](https://alerts.raku.org/api), which you can use in Raku via [`WWW::P6lert` module](https://modules.raku.org/repo/WWW::P6lert).
- Command line [`p6lert` script](https://modules.raku.org/repo/p6lert) gets you access to alerts from command line and can even be integrated into compiler upgrade scripts.
- An embeddable [HTML Widget](https://alerts.raku.org/api#widget) can show alerts on your blog or any other useful place.

## The Content

While we'll make adjustments as we move forward, I foresee most of the non-critical alerts will largely include things that are: (a) more important than simply hoping users-who-care will read about it in the ChangeLog; (b) not as important to warrant a notification blog post.

As a rule-of-thumb, if you picture a user who added [`p6lert` script](https://modules.raku.org/repo/p6lert) to their compiler upgrade procedure, the alerts the script will show will inform that user on everything they need to know to perform that upgrade safely.

The alerts are also deliberately length-limited to be easy to process and fast to digest. As they're [posted via an IRC bot](https://github.com/raku/alerts#posting-alerts), the poster has at most about 400 characters to work with.

Each alert has an `affects` field for it, giving additional info what the alert applies to. I think it'll often be empty, as alerts affecting latest compiler versions imply they affect whatever latest release is at the time alert was posted.

The alerts have a `severity` rating: `low`, `normal`, and `high` indicating how important an alert is. Along with those, come two out-of-band ratings: `info```` and `critical`. Info alerts will usually be something the users don't need to act upon, while critical alerts will often simply contain a link to a blog post that details a critical issue.

Of the top of my head, here are some real-life examples from the past and how I'd rate their severity on the P6lert service:

- **info** - [`Telemetry`](https://docs.raku.org/type/Telemetry) implementation. This was a fairly large implementation of a feature in the core and some users may be interested in it. At the same time, they don't have to act on this alert. Rakudo and Rakudo Star release may also be `info` alert material.
- **low** - implementation of output buffering on IO handles. Once that was implemented, we noticed some minor fallout in code that assumed lack of buffering. A low-severity alert could notify users about this.
- **normal** - A real-life `normal`-severity alert is [already posted](https://alerts.raku.org/) on the site. During 6.d spec pre-release review, the `Str.parse-names```` method was placed under deprecation and its functionality was moved to live under `Str.uniparse`. While this method always existed as a 6.d-proposal, it's known to us that some users already use it and an alert will help them ensure their code keeps working past 6.e language release.
- **high** - a while ago, `.subst` was briefly made to die if it couldn't write to `$/`; same as some methods already do. Upon examination of ecosystem fallout, this change was reverted, pending further review.  However, were it to stay, a high-severity alert would be in order.
- **critical** - when we finished work on lexical require, conditional loading of modules many users used was silently failing and the users needed to change their code to correct reliance on the old, buggy behavour. We issued [a blog post](http://rakudo.org/2017/03/18/lexical-require-upgrade-info/) with upgrade instructions. A critical alert would be a link to this blog post.

That's my vision for host the system will be used, but it'll evolve to suit our needs as more core devs and more of our users start using it. The core dev docs for the system along with code for all the pieces is available [in raku/alerts repo](https://github.com/raku/alerts#posting-alerts).

## Conclusion

As part of improving using user experience, Raku core devs now offer [alerts.raku.org](https://alerts.raku.org) service that will list important information about latest developments in the land of Raku. There are numerous ways to consume those alerts, such as an RSS or Tweeter feeds, a command line utility, and an easy-to-use API.

The alerts will come in 5 different severity ratings, indicating their importance. We'll continue to improve the system to best suit our users' needs.

If you have any questions or feedback, you can always talk to the core devs [on #raku-dev IRC chat](https://webchat.freenode.net/?channels=#raku-dev).

-Ofun
