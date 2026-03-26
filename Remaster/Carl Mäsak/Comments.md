# Comments
    
*Originally published on [3 September 2008](http://strangelyconsistent.org/blog/comments) by Carl Mäsak.*

November is still a young project, but we already have a few nice coding habits. For example, we're pretty quick at marking as `TODO:` the things that merit a revisit at some point in the future. Right now, there are 8 `TODO:` comments in the `master` branch.

Another markup we have adopted is the `RAKUDO:` tag, essentially flagging all idioms that are the result of Rakudo not quite being Raku yet. :) As of this writing, there are 27 such comments in the `master` branch.

For those `RAKUDO:` comments which have a corresponding RT ticket, the ticket number is added for easy searching. (This habit also seems to make us report more bugs.)

Here's a little taste of what it looks like:

```raku
# RAKUDO: Chained trinary operators do not do what we mean yet.
# RAKUDO: Would be nicer to use map and [~].
# RAKUDO: Poor man's CATCH.
# RAKUDO: Need to match again inside while loop. [perl #58352]
```

But what's this?

```raku
# TODO: Довести до ума, чтобы корректно работало с
#       существующими но неопределенными $key
#       (Make code work properly with an existing but
#       undefined $key)
# RAKUDO: Hash.:exists еще не реализован (Hash.:exists not
#         implemented yet)
```

**[Update 2008-09-16: Fixed spelling errors noted by *esobchenko*++]**

Our first two international comments, from *ihrd*++ of Vladivostok.pm. We hope to see more comments in the future in languages other than English. The programming world is English-speaking to such a large extent nowadays, that we tend to forget all those who weren't fortunate enough to grow up with every-day exposure to the language — a significant fraction of programmers out there.

So, from now on, another habit of ours is: comment liberally, in a language you're comfortable with. Be proud! Express yourself in the language you're at home with.

Maybe your language will be the next one adorning the November source?
