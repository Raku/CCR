# t1: Tell knights from knaves
    
*Originally published on [22 February 2013](http://strangelyconsistent.org/blog/t1-tell-knights-from-knaves) by Carl Mäsak.*

> <grondilu> masak: are you sure problem #1 is computationnaly doable?  It's not NP = P or something, is it?  grondilu thinks of it and realizes the number of possibilities is not so large

```
<grondilu> .oO( 2**number_of_islanders  possibilities anyway )
```

And so, the time-honored tradition of reviewing [p6cc](https://github.com/masak/p6cc2012#readme) solutions begins. Again.

For our first task, we have the very human conundrum of figuring out who is telling the truth and who is lying. Fortunately, on the island of Smul, that's a much more tractable problem than in the real world.

The problem description follows.

## Tell knights from knaves based on what they say

On the mythical island of Smul, people suffer from a rare genetic disorder that
make them either tell the truth all the time, or lie all the time. These are
the only two types of people on the island, known as knights and knaves,
respectively.

Write a program that takes as input a number of utterances by islanders, and
outputs for each person whether that person is a knight or a knave. If there is
no possible assignment that works, the program should report that no solution
exists. In the case of multiple solutions, the program should report every
possible solution.

The islanders can make four different classes of utterances:
```
X is a knight.
X is a knave.
X and Y are of the same type.
X and Y are of different types.
```
(Here, X and Y are used as metavariables, of course, and can in fact be any
name of an islander.)

Islanders can refer to each other. The same islander can make several
utterances. If an islander mentions another islander that doesn't say anything,
your program should consider the entire input to be erroneous.

Here are a few examples:
```
A: A is a knight.
```
Both a knight and a knave would assert the same thing. So this input has two
solutions.
```
B: B is a knave.
```
Neither a knight or a knave would ever say this about themselves. So this input
allows no solution.
```
C: C and D are of the same type.
D: D and C are of different types.
```
Here, the two islanders are contradicting each other, so one of them must be a
knight and the other a knave. But this is exactly what D is saying, so D is the
knight. One solution.

Let's get one obvious thing out of the way: we can solve this with a brute-force method, supposing for each islander in a situation first that he is a knight and then that he is a knave. Each islander thus bifurcates the universe in two possible universes. Two islanders will yield four possible universes to investigate. Three islanders will yield eight universes. Ten islanders will yield 1024 universes. The universes grow exponentially with the islanders. The brute-force solution will always *work*, but at an exponential slowdown.

Many people choose the brute-force solution. I don't blame them; it's there for the picking. Some people get fancy with logical propositions or "affiliations" between islanders, but they all fall down the exponential pit at one point or another. The brute-forcers are all over the place in terms of style and brevity, and it's quite fun to watch.

Then there's this *one* contestant that gets the nice solution. It always thrills me when that happens.

Here, let me lay it out for you. Let 0 mean `False`/knave and 1 mean `True`/knight. Then let's translate the four possible utterances to equations:

- "A: X is a knight." → A = X
- "A: X is a knave." → A = 1 xor X
- "A: X and Y are of the same type." → A = 1 xor X xor Y
- "A: X and Y are of different types." → A = X xor Y

By some amazing coincidence, all the utterances can be put into more or less the same mold, and the only operator used is xor. It's actually fun to translate these formulas back, and get alternative formulations of things, sometimes giving a different perspective on things:

- A = X → "A is as truthful as X"
- A = 1 xor X → "A or X is truthful, but not both"

From that first formulation we see why, when A is asserting that A is a knight, that utterance devolves into a tautology A = A. It's as if an islander cannot assert his own knighthood solely on his own authority.

From the second formulation we see why, when A is asserting that A is a knave, such an utterance devolves into a contradiction A = 1 xor A. There just isn't any such number A. (We'd have to look in the murky domain of fuzzy logic, but that's outside the realm of the island of Smul.)

Anyway, translating all the utterances to this form is a *big* win. Now we can make a linear equation system of all the utterances, and solve the linear equation system. Do we have fast algorithms for that? Yes, we do! Gaussian elimination has an arithmetic complexity of O(n<sup>3</sup>). That's quite an improvement on exponential brute force!

We must take care to do all the additions and subtractions as xors, though. This is because our underlying algebra is truth values, outside of which we may not stray. So we're really doing Gaussian elimination on the [quotient ring](https://en.wikipedia.org/wiki/Quotient_ring) Z/2Z.

In the literature, we find this problem as [XOR-satisfiability](https://en.wikipedia.org/wiki/3SAT#XOR-satisfiability). Wikipedia dignifies it with two sentences.

One contestant did it this way. Yay him. You should check out his solution.

[Here are the solutions](https://github.com/masak/p6cc2012/tree/master/t1/review), and my reviews of same. Enjoy.

Next up: rectangle haikus, possibly the most fun I've ever had with a p6cc task.
