# July 1 2012 — Hanoi as a black box
    
*Originally published on [2 July 2012](http://strangelyconsistent.org/blog/july-1-2012-hanoi-as-a-black-box) by Carl Mäsak.*

So, here's a fun challenge. We're gonna write the Hanoi game *first*, despite
it being in the middle of the adventure game. Then we start writing the
adventure game, and when the time comes, we'll plug Hanoi into the adventure
game. If we do it right, it should be fairly easy. If we do it wrong, it will
hurt immensely.

Think of it as an exercise in design, extensibility, and requirements
prediction.

Now, I've done this before. I wrote the Hanoi game basically as a class in the
adventure game. This time around it'll be an independent part. The Hanoi game
will know nothing about adventurers or inventories or quests. It will be a
brain in a vat who happens to be really good at the rules of the one-player
game Towers of Hanoi.

Here are our design primitives:
  
> The player interacts with the game by moving **disks** between three **rods** which we call 'left', 'middle', and 'right'. We label the disks by size, and refer to them as the tiny, small, medium, large, and huge disk, respectively.  For aesthetic reasons, a larger disk may never be positioned on top of a smaller disk. The disks all start out on the left rod; you **win** by moving all of them to the right rod.

This starts us down the road of understanding the language and the bounded
context we're dealing with. There are still many details that need sorting out,
though.

Specifically, the adventure game will influence and distort the way the Hanoi
game works:

- The adventure game is open-ended

The Hanoi game doesn't shut down or
finish just because you unlock its achievement. So it's actually possible
to *un-*unlock the achievement too. You can regress in the Hanoi game as
well as progress.

- For reasons having to do with finishing the game

It is important that the
tiny disk be possible to pick up and carry with you. However, this should
not be possible to do with the larger disks, because if it's possible to
pick up disks and place them back anywhere, the Hanoi game ceases to be
a challenge.

- You have to be able to unlock the Hanoi achievement

And take the tiny disk
with you without the achievement locking back up again. However, moving
disks around beyond that will re-lock the achievement.

We'll pick an approach to designing the Hanoi game that may be new to some
readers. We will not talk about data or algorithms at all. Instead we will
consider the game a black box, and only focus on behaviors (methods),
successful responses (events), and unsuccessful responses (exceptions). These
will completely occupy us for the rest of this post.

Here are the public methods we know we need:

- `move($source, $target)` &mdash; move the top disk of one rod to another
- `remove($disk)` &mdash; remove a disk from the game
- `add($disk, $target)` &mdash; add a disk to the top of some rod

Again, note that a "regular" Hanoi game only deals with the first one, but we
know we'll have the adventure game as a client, and that client will need to
remove the tiny disk.

Here are the events that represent successful responses:

- `Hanoi::DiskMoved` &mdash; a `:disk` was moved from `:source` rod to `:target` rod
- `Hanoi::DiskRemoved` &mdash; a `:disk` was removed from `:source` rod
- `Hanoi::DiskAdded` &mdash; a `:disk` was added to `:target` rod
- `Hanoi::AchievementUnlocked` &mdash; we just won the hanoi...
- `Hanoi::AchievementLocked` &mdash; ...aaaand we somehow screwed it up again

We see that we have one event each for each of the three public methods. That's
quite normal. And then we also have events for emergent change of state, when
we "win" and "un-win" the game. The rule of thumb for what we need events for
in this style of designing things is that the black Hanoi box emits one event
per change it itself needs to keep track of, so if we would lose our black box,
we could theoretically get a new one, feed it a list of past events, and it
would be able to pick up the work from there. So, one event per "important"
change.

Now, those are the successful return values from the black box. Let's also look
at the exceptional return values, those that don't change the state and just
report back why it won't do what you told it to:

- `X::Hanoi::NoSuchRod` &mdash; no, you can't do something with the rod `:name` of type `:rod` (source or target) because it doesn't exist
- `X::Hanoi::NoSuchDisk` &mdash; no, you can't `:action` (add or remove) a `:disk` that doesn't exist either
- `X::Hanoi::RodHasNoDisks` &mdash; no, you can't move disks from rod `:name` that doesn't have any disks
- `X::Hanoi::DiskHasBeenRemoved` &mdash; no, you can't `:action` (move or remove) a `:disk` because it's not currently in the game
- `X::Hanoi::DiskAlreadyOnARod` &mdash; no, you can't add a disk from outside the game that is already in the game
- `X::Hanoi::ForbiddenDiskRemoval` &mdash; no, you can't remove that `:disk` from the game
- `X::Hanoi::LargerOnSmaller` &mdash; no, you can't put a `:larger` disk on a `:smaller` one according to the rules
- `X::Hanoi::CoveredDisk` &mdash; no, you can't move or remove that `:disk`, because it's `:covered_by` all these other disks

These fall into approximate categories: first, four "out of bounds" type
responses, where the input doesn't make sense because there is nothing there.

The next one (`X::Hanoi::DiskAlreadyOnARod`) is the opposite; trying to
introduce duplicate objects into the game. (The adventure game won't make that
possible unless hacked; but it feels prudent to prevent it anyway.)

The next one after that (`X::Hanoi::ForbiddenDiskRemoval`) prevents the Hanoi
game from becoming trivial when embedded in an adventure game where you can
just take stuff and put them back in any order. I don't know what to call that
category. Anti-corruption countermeasure? The "remove a disk" thing is already
a concession for the surrounding adventure game, but we box it in and prevent
it from going too far.

And the final two are basically upholding the rules of the game. They are
"illegal operation" exceptions, while the initial two/three are "illegal
argument" excpetions, and the rest are somewhere in the murky hinterland
between those endpoints.

Ok, so we have our constituent parts. Tomorrow we'll be writing tests using
the behaviors/events/exceptions introduced today.

If you're curious about where we're heading, I already pushed what I'll talk
about tomorrow. It's the
[`crypt.pl`](https://github.com/masak/crypt/blob/2fecc9137c1a24bcb20eb8527c7e86a39ee20a1c/crypt.pl)
file in the `crypt` repo. But I'll be going through the process tomorrow commit
by commit. This is a very nice way to write code.
