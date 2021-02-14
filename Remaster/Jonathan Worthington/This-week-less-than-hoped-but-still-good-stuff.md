# This week: less than hoped, but still good stuff
    
*Originally published on [2015-07-15](https://6guts.wordpress.com/2015/07/15/this-week-less-than-hoped-but-still-good-stuff/) by Jonathan Worthington.*

This week actually means “the week starting 6th July”, which is around the time much of Europe was being unreasonably hot. I spent the week in lovely Kyiv with my wife – where the weather was, predictably, also hot. I’d hoped for a nice mix of hacking, sight-seeing, and nice food. Well, I got a decent amount of nice food. Unfortunately, I also had a pretty bad time with the pesky hayfever thing that’s been bothering me this year (mostly due to bad sleep and hot weather), got frustrated enough that I decided to try a different anti-allergy medication, reacted less than awesomely to it, and generally spent plenty of time feeling crap. Happily, things are improving a good bit now that I’m back home, and ahead of me are five weeks with only 3 nights that I need to be away from home. After two and a half months in which I was never in the same place for much more than a week, you can’t imagine how happy I am of that – I can only imagine it’ll do my productivity wonders, and I’m hopeful for my health too. Anyway, let’s take a look through the few bits I did manage to get done.

### Multi-dimensional array progress

In the last report, I mentioned I’d got most of the way with the new MultiDimArray representation I was implementing in MoarVM, along with various new ops. This week I got the last loose ends tied up, adding support for cloning, serialization, and deserialization.

With that done, it was time to move on to porting the work over to the JVM. I stubbed in all the new op mappings, so the NQP test file I established while working on the MoarVM implementation would compile on the JVM backend also (the strategy of writing tests at NQP level to exercise backend-level stuff continues to serve us very well). Then I set about working to make them pass. I got up to 71 out of 188 tests passing, which is a decent start – especially given there’s various bits of setup work to do early on.

### &?BLOCK and &?ROUTINE

The `&?BLOCK` symbol refers to the current block of code we’re in (which amongst other things provides a way to write recursive, yet anonymous, blocks). `&?ROUTINE` is the same, but for the current enclosing routine (`sub`, `method`, `token`, etc.) We’ve had `&?ROUTINE` for a while, but not `&?BLOCK`. I set out to implement it, and noted that one had to be careful that it refers to the current closure. Glancing at `&?ROUTINE`, I noticed it didn’t take sufficient care over closure semantics, and soon had a failing test case exposing the issue. So, I fixed the `&?ROUTINE` bug, wrote tests for `&?BLOCK`, and got that in place too. So, one missing feature added and one potential nasty bug down.

### when/default semantics

All the way back in April, I tried to deal with RT #71368, which noted that our `when` / `default` semantics were out of line with the design in S04. Trouble is, when I tried to bring us in line with them, I found that I would break a bunch of folk’s code. Of note, this pattern would not be allowed:

```` raku
sub foo($n) {
    $_ = bar($n);
    # use when/default here against $_
}
````

That is, setting `$_` – which you get fresh per block anyway – for the sake of using when/default. Nobody really felt this should be outlawed. I agreed and put aside my changes.

This week I finally got around to returning to the issue to try and bring it to some kind of conclusion. The result was a [commit to the design docs](https://github.com/raku/specs/commit/5f132abb41cf3d418333c28fee1f9fde0e81bb4a) to bring them in line with the semantics that folks seem to prefer (which was a nice simplification also), along with adding some more tests to give us better coverage.

### One more regex engine bug down

A while back, we got dynamic quantifiers, so you can use a variable (or any expression, really) to decide how many times to match something:

```` raku
/'x' ** {$n}/
````

RT #125521 pointed out an icky bug that showed up when you tried to mix this feature with captures. Thankfully, this turned out to be one of the easier kind of regex engine bugs to figure out: some capture-related code paths simply hadn’t been updated to understand dynamic quantifiers.

### And the usual other little bits

Here are a few other assorted small things that I dealt with:

- Fix RT #125537 (type variable resolution failed to look in outer scopes) and add test
u Fix RT #124940 (for type variable `T`, `my T $x = …` could fail to assign)
- Review test mentioned in RT #125003, correct it, resolve ticket.
- Fix RT #125574 (missing error on too-late application of `is repr(…)` trait)
- Fix RT #125513 (could auto-gen a `%_` when there already was one in some unusual cases)
- Review RT #80694, observe weird `.^can` behavior is gone, add a test for that, suggest a good solution to problem and test it too

Stay tuned for next week’s report, which already has as much to talk about as this one – and we’re only half way through the week!
