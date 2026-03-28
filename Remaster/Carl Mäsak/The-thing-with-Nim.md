# The thing with Nim
    
*Originally published on [31 January 2011](http://strangelyconsistent.org/blog/the-thing-with-nim) by Carl Mäsak.*

In order to understand the solutions to p4, one needs to understand a kind of game called "taking and breaking" games. To understand that kind of game, one needs to understand Nim. So let's talk about Nim.

Nim is played with a number of heaps with stones. Here's a typical startig situation:

```
3 OOO
4 OOOO
5 OOOOO
```

Players take turns choosing one of the heaps (shown as rows in the ASCII picture above), and removing a positive number of stones from that heap. The player who picks the last stone(s) wins. (Or, equivalently, the player who faces a board situation with zero remaining stones loses.)

So, here's a perfect-information, impartial game &mdash; *impartial* meaning that the available moves don't depend on whose turn it is &mdash; and there are good tools to analyze this type of game already, to the point of being able to say who will win in the above situation. (It's the player on turn, by the way.)

There's a bit of math involved in the analysis, but I thought we'd take the scenic route and explore the game on our own instead. Turns out that you can get all the way without any explicit algebra.

A very basic observation: a game played with only *one* heap is a done deal.

```
4 OOOO
```

The player on turn is *allowed* to take all of the stones and win the game. This goes for any game with a single heap, regardless of size. So the single-heap game is trivially won by the player on turn.

The two-heap game can look in two different ways. Either the two heaps are equal in size:

```
3 OOO
3 OOO
```

In which case the player on turn is in a bad seat, since all his moves will be mirrored by a good opponent, eventually giving the opponent the last move. Darn.

In fact, let's go ahead and give losing positions of that kind the numeric value of 0. Similarly, we can give all the single-heap positions a numeric value corresponding to the number of stones in the heap. There's even an informal motivation to do that: a 2-stone heap is "more worth" than a 1-stone heap, in the sense that it gives you the option *either* to take two stones and win, *or* to take one stone and lose. (Why would it be an advantage to have the option to lose? Bear with me.)

The other possible way a two-heap game can look is with the two heaps being unequal in size:

```
2 OO
4 OOOO
```

This is a winning move, because the player on turn can always bring the bigger heap down in size to match the smaller one, making the opponent face a &mdash; losing &mdash; equal-heaps position.

Putting two game positions together to form a bigger, combined game position is called a *disjunctive sum* of games. The underlying assumption is that when the games are combined, you're only allowed to move in either of them. This works perfectly with Nim's model of individual heaps.

For impartial games, there is a special theorem, the *[Sprague-Grundy theorem](https://en.wikipedia.org/wiki/Sprague%E2%80%93Grundy_theorem)*, which states that if all you do is combine nim-heaps, the number you end up with is the number for another nim-heap. Put simpler, we could *summarize* a whole Nim game down to its combined "Nim-heap number" (named, cutely, in the lingo of the theory, a *nimber*).

The question is, how.

The combined nimber is not just the sum of the nimbers of all the heaps in the game, because we already know that two heaps of equal size cancel out into a lost 0-position. On the other hand, sometimes the combining operation *does* act just like a sum, for example in the case of a 1-heap and a 4-heap:

```
1 O
4 OOOO
```

Combined, these act just like a 5-heap. Which in turn means that this game...

```
1 O
4 OOOO
5 OOOOO
```

...is a loss for the player on turn, because the first two act like a 5-heap, and cancel out the actual 5-heap. (Play it out for yourself, and you'll see that the second player can always win.)

Eventually, we might be so mystified at the pattern that some heaps *do* sum properly when combined and others *don't*, that we make a table to try to find a pattern:

```
nim-sum    1  2  3  4  5  6  7  8
== sum?
      1       Y     Y           Y
      2    Y        Y           Y
      3
      4    Y  Y                 Y
      5
      6
      7
      8    Y  Y     Y
```

A-ha! Powers of two... only when two heaps with sizes equal to two different powers of two...

A further insight leads us to draw games like this instead:

```
1      O
4 OOOO
5 OOOO O
```

So the three *heaps* cancel each other out, because together they have (power-of-two) *components* that cancel each other out.

And from this, the whole rest of the analysis of Nim more or less falls out.

Of course, in the algebraic treatment of the game, the "components" instead become "digits in the binary expansion of the heap-number". But this way is more fun. ☺

Let's summarize what we know in terms of the new component terminology:

- The player to move will lose the game if all the components cancel each other out in pairs, i.e. if there's an even number of components of each size.
- Conversely, the player to move will win the game if there are "leftover" components that don't add up.


How can we be sure of the last point? Well, the nimber representing the whole game turns out to be exactly the (normal addition) sum of the components that don't add up. A positive nimber means the player to move is in a winnable position.

We don't even need to *prove* that there's a winning move from any such winnable position, we can just take it on faith that there is. But, of course, it's not a bad idea to work out an algorithm to find the winning move if, say, we're in the business of writing algorithms to win impartial games for us. 哈哈

We want to place the opponent in a losing position, which is the same as a 0-position. So whatever leftover components there are in our position, we want to cancel out. We could try each possible move in each possible heap, but that's inelegant. Instead we do this:

Find out what the biggest leftover component is. (There has to be exactly one, or it would have added up.) Find a heap with this type of component. (There has to be one, unless the game just started and is unwinnable anyway.) Remove that whole component, *minus* the sum of remaining leftover components. This will cancel out not only the big component (because we remove it), but also the remaining smaller ones (because we leave copies in the heap). We know that the sum of the remaining leftover components can't exceed the size of the biggest component, because that's how powers-of-two work.

Let's apply these insights to the game from the beginning:

```
3 OOO
4 OOOO
5 OOOOO
```

We now know that we should really be looking at the game in terms of components:

```
3      OO O
4 OOOO
5 OOOO    O
```

Looking at it this way, we immediately spot the leftover 2-component. Since this is the only leftover component in this game position, it also makes up the winning move: take two stones from the first heap, and you'll eventually win the game. (Sure enough, this puts the opponent in a 1-4-5 position, which we already know is a losing one.)

And that's all that needs to be said about Nim strategy. Now we have a way to recognize winnable/unwinnable positions, and a way to make the right move every time in winnable ones.

But what does this have to do with p4? Last I looked p4 wasn't Nim... Well, as it happens, Nim is the "base game" for a whole family of games; specifically, the "taking and breaking" games mentioned at the beginning. More on that in the next post.
