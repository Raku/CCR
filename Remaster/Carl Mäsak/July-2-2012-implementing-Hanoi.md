# July 2 2012 — implementing Hanoi
    
*Originally published on [2 July 2012](http://strangelyconsistent.org/blog/july-2-2012-implementing-hanoi) by Carl Mäsak.*

[Yesterday](July-1-2012-Hanoi-as-a-black-box.html) was about the interface. Today is about the implementation.

Look, a game!

```
$ bin/crypt hanoi
     |            |            |     
     =            |            |     
    ===           |            |     
   =====          |            |     
  =======         |            |     
 =========        |            |     
-------------------------------------
> okay...
Sorry, the game doesn't recognize that command. :/
'help' if you're confused as well.
> help
Goal: get all the disks to the right rod.
You can never place a larger disk on a smaller one.
Available commands:
  add <disk> <target>
  move <source> <target>
  remove <disk>
  q[uit]
  h[elp]
  s[how]
Disks: tiny disk, small disk, medium disk, large disk, huge disk
Rods: left, middle, right
> show  
     |            |            |     
     =            |            |     
    ===           |            |     
   =====          |            |     
  =======         |            |     
 =========        |            |     
-------------------------------------
> move left right 
     |            |            |     
     |            |            |     
    ===           |            |     
   =====          |            |     
  =======         |            |     
 =========        |            =     
-------------------------------------
> move middle left
Cannot move from the middle rod because there is no disk there.
> move left middle
     |            |            |     
     |            |            |     
     |            |            |     
   =====          |            |     
  =======         |            |     
 =========       ===           =     
-------------------------------------
> move small disk right
Cannot put the small disk on the tiny disk.
> quit
```

Now, let's implement this.

## Moving disks

- [A legal move](https://github.com/masak/crypt/commit/35435dc33a99f2da443f7786658aa648a7593ed6). Things are introduced as we go.
- [Can't put a larger disk on a smaller one](https://github.com/masak/crypt/commit/b0affd256cd439fefa0810ecdf8f3f474339d172). We introduce a bit of infrastructure for handling exceptions.
- More illegal things: you can't move [from or to nonexistent rods](https://github.com/masak/crypt/commit/4b7c1d2dd1301e7f09d8c105fe38260431a5d074) or [from a rod with no disks](https://github.com/masak/crypt/commit/efa9ba6fdb1a179af0c41c40f656a3fe40b8360e). We create up the exception classes as we go.
- [Winning the game](https://github.com/masak/crypt/commit/b9caadefe07b226e23aedcf77845f76760603f02). There's actually a little hanoi solver in the test suite, because it made more sense to write out the moves than to generate them. [You can't win twice in a row](https://github.com/masak/crypt/commit/6aa70d45d0ce1a8ecb6361894e72597db3539bca).
- [However, you can un-win](https://github.com/masak/crypt/commit/96d9cf3bbc2e1b9bc7d56f82fa3fa017471531ce) by moving both the tiny and the small disk.
- [If you want, you can say which disk to move](https://github.com/masak/crypt/commit/e2a3e5d9f70c5c21ce432a3c2ea03b85c83cf366) instead of which rod to move from. Basically a case of Postel's law: we recognize this and do the right thing with it.
- But of course being accomodating creates problems, too. With the new syntax, it's possible to [try to remove a covered disk](https://github.com/masak/crypt/commit/e2a3e5d9f70c5c21ce432a3c2ea03b85c83cf366).

Let's just pause here for a while and say a bit about this method of working.
The tests exercise the Hanoi game. They do this by saying either "calling this
method returns this event" (success) or "calling this method throws this
exception" (failure). The Hanoi game keeps state around, but the attributes are
completely private. There are no getter methods. The public methods (`.move`,
and later `.remove` and `.add`) may read attributes, but the attributes are only
written to in a private `!apply` method. (The `!` means "private".) The
`!apply` method is called with an event.

So the only way to actually change the game state is to send an event of some
kind to the `!apply` method. This keeps us honest in a way; we have to
publicize all the important internal updates of the Hanoi game as events.

## Removing disks

- [You can remove a disk](https://github.com/masak/crypt/commit/a47664cab42119a83d7c6469326da4b2152d33d3).
- [Removing disks that are not the tiny disk is forbidden](https://github.com/masak/crypt/commit/94cf486c7de4c841c85ad5e4fc3df0cbb0b0954b). In the adventure game, the larger disks are too heavy to be lifted away from the Hanoi rods. In the Hanoi game, weight doesn't really exist, so we only say it can't be done.
- [If you try to remove a covered disk, you get another exception](https://github.com/masak/crypt/commit/b6edc9c5658bd095128b7ccde640a020abc6a697). If you uncover it and try to remove it and it's still not the tiny disk, [it's still forbidden](https://github.com/masak/crypt/commit/26f2c6bcf1654e134e49c9642bb24e0813787856). Tough.
- [You can't remove a disk that you already removed](https://github.com/masak/crypt/commit/50e0179cdb3d359149f6a78040c74fd09ecbc801). Implementing this is really about thinking about all the possible actions in all the possible situations.
- [You can't *move* a removed disk either](https://github.com/masak/crypt/commit/c9e01dda9cd8a4a0ca13dc3536231a5ff159e5e8). Introducing new commands can create new exceptional conditions in old ones.

Now this last point is interesting. We introduce `.remove`, and suddenly we
have to go back to `.move` and patch a "vulnerability" that suddenly opened up.
I think many bugs are of this kind; old operations which end up in new
situations for which they were not designed.

## Adding disks

- [You can add a disk](https://github.com/masak/crypt/commit/89ce1449010437126f1dea47b90a5c88420df0bf) that you removed before. We're always talking about the tiny disk in these cases, but it doesn't matter much.
- You can't add a disk [with a made-up name](https://github.com/masak/crypt/commit/41501d67f9e1c8e948ce155d29d0d1a9e62cdb68) or [that's already there](https://github.com/masak/crypt/commit/4d11a9df30cf2e3eb9205daa79b3e33b480220ac).
- At this point I realized that [some of my events attributes could be improved](https://github.com/masak/crypt/commit/0f569fa20ecf7c37aa9250487bfded1e4fde1dcb). The design was presented as a completed fact yesterday, but it very much evolved together with the test and the implementation. It's comforting to see that that works really well.
- You can't add to [a rod that doesn't exist](https://github.com/masak/crypt/commit/2fecc9137c1a24bcb20eb8527c7e86a39ee20a1c), either.

## Command-line client

As soon as I [implemented the client](https://github.com/masak/crypt/commit/72ef665c3faec428968eaa7a4db66c43ea3f4802) that you see above, I got feedback from people. There's a lesson in there somewhere. I got many good bug reports and could put in things that I'd forgotten.

- [Removing a non-existent disk](https://github.com/masak/crypt/commit/45fb27113b9d47d1a65ce446ea9b517e25328f6c) gave the wrong exception back. *Coke*++ discovered this, and I fixed it.
- [The client didn't tell you when you won](https://github.com/masak/crypt/commit/ed7110e4517169d40acd99933f78e9c6ae4871da) or un-won. It does now. *Coke*++.
- But the best one, and the one that I consider a real omission and mental error of mine, also discovered by *Coke*++: [you could only win by moving a disk, not by adding a disk](https://github.com/masak/crypt/commit/ed7110e4517169d40acd99933f78e9c6ae4871da). Ouch. I fixed.

See how easy it is to miss some cases? One could argue that this is a great
weakness of this way of developing, but I would argue the opposite: this way of
focusing on verbs and their results *enhances* the ability to think in terms of
these situations. Also note how small and self-contained each commit is, even
the fixes.

I'm really proud how the client turned out. Have a look at [the 'final' client](https://github.com/masak/crypt/blob/9f9b0becffa6fbca5c511fa6e78e7226a09b4331/bin/crypt#L231). I especially call your attention to the fact that we don't just list the available commands, we *ask the Hanoi game for them*. (Yay introspection!) Also, the `print_board` subroutine turned out really nice, for something that does formatted output. There's a little "cheating" that makes the command parser treat things like 'large disk' as one argument even though it's two words.

## So

75 tests pass and support this hanoi game. I can't guarantee there are no
remaining bugs to find, but I'm very confident it'll be easy and even a bit fun
to integrate what we now have into the adventure game when the time comes.

Also, I imagine the subsequent posts will be a bit smaller in scope than these
two first ones. Still, this was probably a good introduction to the style of
programming we'll be using for the rest of the month. Commands, events, and
exceptions. We'll see more advantages as we go along.

Now we can leave Hanoi behind us for a while, and... let the adventure begin!
