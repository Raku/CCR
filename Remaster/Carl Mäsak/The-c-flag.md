# The -c flag
    
*Originally published on [28 December 2011](http://strangelyconsistent.org/blog/the-c-flag) by Carl Mäsak.*

The p6cc contest is underway. Yay.

[Coke]++ discovered on the channel that Rakudo nom didn't have a `-c` flag. The five `base-test` files all syntax-check the corresponding `code` files using the `-c` flag. Which made Rakudo nom and the `base-test` files incompatible. Oh noes.

```
<moritz> moritz-- # not reviewing the test harness properly
```

The fault is even more mine, of course, since I *wrote* the test harness. And I may be an "early adopter" with Raku, but I'm always very late at switching over to a new Rakudo branch.

I was late at switching over to `ng`, back when it was still called `ng`. And I'm late this time in switching over from `b` (the new name for `ng`, since the `n` stands for "new" and `ng` isn't new anymore) to `nom` (the new "new").

I'll take the leap any day now, I promise.

*moritz*++ was quick in patching up the `-c` omission.

```
<dalek> rakudo/nom: a9bead6 | *moritz*++ | src/ (2 files):
<dalek> rakudo/nom: reimplement -c command line option
<dalek> rakudo/nom: review: https://github.com/rakudo/rakudo/commit/a9bead6d48
<moritz> masak: there you go
<masak> *moritz*++
```

What this means in practice is: you can't use the latest Rakudo nom compiler release to solve the p6cc problems. Not without modifying the `base-test` files anyway. But you *can* use the bleeding-edge git checkout of the nom branch.

If you're on either Niecza or Rakudo b, things should be fine: those have a working `-c` flag already.

Those are the breaks. Raku is evolving, and the mat is constantly being pulled out from under us. To keep up, one has to do a jig now and then.

We added a [`NOTES`](http://strangelyconsistent.org/p6cc2011/NOTES) file to keep track of information of this kind that we didn't manage to get into the contest instructions.

On the channel, we also had some nice concluding discussion about the nature of the `-c` flag.

```
<moritz> to me it felt a bit like a cheat
<moritz> because there is already some mechanism for specifying the target stage
<moritz> but it's too tightly coupled to the output from the existing stages to
         be easily usable
<moritz> so I feel like hijacking an existing mechanism
<masak> I guess.
<masak> in some sense, "checking syntax" isn't so much of a compiler stage as...
        a decision not to go past a certain compiler stage.
<*TimToady*> in a sense, -c adds the final CHECK, that just exits with status
<masak> right.
<*TimToady*> it can even be implemented that way, since CHECKS do lifo order
<masak> "everything turns out to be yet another setting" :)
<*TimToady*> yes, it could also be done with a variant setting, but that seems
           a bit heavyweight
<*TimToady*> otoh, it would be possible to sneak CHECK pushes in before the -c,
           so maybe a setting is the cleaner way
```
