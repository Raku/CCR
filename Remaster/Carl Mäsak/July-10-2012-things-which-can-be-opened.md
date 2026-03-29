# July 10 2012 — things which can be opened
    
*Originally published on [10 July 2012](http://strangelyconsistent.org/blog/july-10-2012-things-which-can-be-opened) by Carl Mäsak.*

Another day of relatively little coding. Well, that suits me fine; no sense in
burning out early in the month. And I *am* kind of on vacation this week.

So, we make a thing openable, and then [we open
it](https://github.com/masak/crypt/commit/97260bd778c12718e4be5cf6a5a1f045d553b6f5).
And it works, fantastic!

But then there are two sad paths, one where the thing we try to open [doesn't
exist](https://github.com/masak/crypt/commit/e0ac8d7cd40d94b7d3f73032e6e4181e3e0e5ee9),
and the other where the thing [is already
open](https://github.com/masak/crypt/commit/7132e8509553e6e4ed78302af2efa429b0e488eb).

Again, note how basically all the interesting logic goes in with the sad paths,
just like yesterday. This is a pretty new style of coding for me too. I
reflected over this via privmsg to jnthn today:

```
<masak> I think the single most important idea in BDD is "black box testing".
        the idea that if we have to resort to getters in the 'then' part, we've 
        failed.
<masak> we've failed *because* we need to break encapsulation to get important
        result information out of the object.
<masak> it's the testing equivalent of the Internet meme "pics or it didn't
        happen".
<masak> black box testing naturally leads to a wider focus on sad-path testing,
        because every sad path corresponds to one way to validate, and is what 
        necessitates keeping state between calls.
```

Maybe the right way to think about this is to engage in a kind of dialogue with
the client (or yourself, as it were):

```
<dev> *why* do you want to use a getter afterwards to check that the car
      is open?
<client> because otherwise how will I know it actually is open?
<dev> by testing whether it behaves as if it were open. what's particular about
      an open car? are there exceptions thrown now that weren't before?
<client> well, heh, I guess if I try to open it again, it should throw...
<dev> and that's all we need.
```

The trick is realizing that this is a general principle, not just something
that works here. We don't install windows into the black box, because that kind
of ruins its black-box-ness. Instead we make it behave sensibly through return
values and exceptions on its *behaviors*.

I have a feeling the next two days will be a bit more challenging and may make
some decisions jump around a bit.
