# July 9 2012 — things and descriptions
    
*Originally published on [9 July 2012](http://strangelyconsistent.org/blog/july-9-things-and-descriptions) by Carl Mäsak.*

I did what was on the agenda today, which wasn't much. Since there isn't much
today, I'll break away from my habit of only talking about the commits that
"matter" for the game development, and talk about the two "in-between" commits
I did as well. These commits don't usually make a good story, but today they
might help.

First thing I did was run the tests. They had broken after the "show exits"
commit I did yesterday, and I hadn't noticed because I hadn't re-run the tests
after making that additions. (Note to self: changing the events API always
merits a test run.) So I [fixed the
tests](https://github.com/masak/crypt/commit/f8d2a55f31a534887d202a2796ea6ea77f8b9b32).

Next up, the happy path of today's work: [examining an
object](https://github.com/masak/crypt/commit/02858d2a97204ed09586f296eb42625766ed0f0c)
that was placed in the room. Works fine. As usual, look how "clean" the
addition is. Practically no code at all.

At this point I realized that one of the attributes on an old event was
unfortunately named. This is why good design takes time; you have to actually
use the stuff for a while for these things to surface. So I [renamed the
attribute](https://github.com/masak/crypt/commit/015b292d311ebac11c70158deac916fcbda3d655).
And yes, I did run the tests this time.

Finally, the sad path of examining an object: if you examine something that's
simply not there, the game [tells you it's not
there](https://github.com/masak/crypt/commit/fcd3e8d0927d447907867137777cc0a6072ab464).

Perhaps most interesting is to note that *the placing logic ends up in this
commit*, not in the previous one. Why? Because due to the way we're only ever
testing external reactions from the game, it's not until we test sad-path
activities that we actually need to do validation against the game state, and
it's not until we do validation that we need to actually apply events. That
feels backwards before one gets used to it... but in a way it makes one
remember to write sad-path code for everything, because those are the tests
that *allow* you to write the validation code.

Still very much liking where this year's version is going. Stay tuned.
