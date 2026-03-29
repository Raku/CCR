# July 31 2012 — the finished game
    
*Originally published on [31 July 2012](http://strangelyconsistent.org/blog/july-31-2012-the-finished-game) by Carl Mäsak.*

All last days of a project should be like this.

No stress. No looming deadline, just a normal deadline. No tearing one's
hair. No failing test, just 144 really good passing ones.

First, I fixed something that I realized earlier today: I don't need to
special-case the wrapper methods for `take` and `put_thing_on` with special
handling of the tiny disk and its interaction with the bounded Hanoi context.
Now that all the disks and rods are objects in the game, I'll just [add more
hooks](https://github.com/masak/crypt/commit/4a89e8f3f057ca8be7d9e448abc9968be991b839).
Nice.

Then it was time to split the big script file into smaller modules and test
files.

```
$ wc bin/crypt 
  3483   8026 103863 bin/crypt
```

100 KB! All of it written this month... that means I've netted around 3 KB of
code per day. Hm, that actually sounds about right.

Anyway, some splitting later...

```raku
$ wc `find bin lib t -type f`
   334   1007  12198 bin/crypt
   938   1931  25364 lib/Adventure/Engine.pm
   276    612   9013 lib/Crypt/Game.pm
     9     31    274 lib/Event.pm
   327   1021   9950 lib/Hanoi/Game.pm
   309   1010   9726 t/hanoi.t
   714   1227  16398 t/crypt.t
   633   1359  17366 t/adventure-engine.t
  3540   8198 100289 total
```

The script file completely deflated; it now only contains the `MAIN` routine
for the game. Even it could be largely factored out into an
`Adventure::Engine::REPL` or something, but right now it's a little too coupled
with crypt for me to attempt that.

Much of the general logic went into `Adventure::Engine`, not surprisingly.
`Crypt::Game` now mostly contains the world-building logic and some wrapper
methods.

The test files also distribute easily. 54 `hanoi.t` tests. The `crypt.t` and
`adventure-engine.t` tests were all mixed together in one `MAIN` multi, but
they were easy to tease apart. (A deeper issue there is that some tests in
`crypt.t` would need to be duplicated, anonymized ("de-crypted", heh), and put
into `adventure-engine.t` so that it gets better coverage. I might get to
that.)

If you're wondering why things got *smaller* from this, I think it was because
some amount of indentation actually disappeared from the test files. Those
tests were all in separate `MAIN` routines previously &mdash; indented one
level. Now they're not.

But, just splitting things apart wasn't enough. I had promised to move
`Adventure::Engine` into its own repository as an independent module, so [I did
that](https://github.com/masak/crypt/commit/e10a8b7f252667d3fa61b3df44ae6b0fdc09fb79).
It can now be found at
[`github/masak/Adventure-Engine`](https://github.com/masak/Adventure-Engine).

Then I took the chance to publish crypt as well. I published it as
`Crypt::Game`, which was probably a mistake from an module naming perspective.
I'll investigate tomorrow what it takes to rename the module `Game::Crypt`.

Both modules can be found at [raku.land](https://raku.land),
of course. You should be able to install it with Panda now, though I haven't
tried.

The contest for finding bugs in the adventure game is now closed as well, and I
do have a winner &mdash; to be announced. If anyone wants to sneak in at the
end with lots of bug reports and suggestions for improvements, I won't be
impossible. The later they are, though, the more awesome they have to be in
order for me not to consider them to be too late.

...and that concludes this day's work, and this blogging month. Thanks for
following along this far. I'll probably sum up the month and what I learned,
when I've regained enough strength to do that.
