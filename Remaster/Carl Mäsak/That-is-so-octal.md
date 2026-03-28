# That is so octal
    
*Originally published on [6 February 2011](http://strangelyconsistent.org/blog/that-is-so-octal) by Carl Mäsak.*

There's a whole universe of impartial games out there, and in the middle of them all sits Nim, an insignificant little game of heaps of stones. Nim is the stuff of which all of the other impartial games are made.

We saw in the [last blog post](The-thing-with-nim.html) on the topic that all many-heap Nim positions can be summarized as a single Nim heap. But it goes further than that: *all positions in all impartial games can be summarized as a Nim heap*. That's the gist of the [Sprague-Grundy theorem](https://en.wikipedia.org/wiki/Sprague%E2%80%93Grundy_theorem).

Before I go any further, I'd just like to say that [Winning Ways](https://en.wikipedia.org/wiki/Winning_Ways_for_your_Mathematical_Plays) is what I'm basing this and the last blog post on. The book is sitting next to me as I write this. If you like thinking mathematically about games, you should definitely consider getting your hands on a copy. The authors are skilled and entertaining, and they invent notation that takes LaTeX for pretty wild rides sometimes. (Besides, one has to love a book where one of the mathematical results is "The green jungle slides down the purple mountain!") Chapter 4 is called "Taking and breaking", and is like a cookbook of the games I'm about to describe now.

One way to generalize Nim is to say that in each move, you're only allowed to remove up to *N* stones. In fact, as a kid I sometimes encountered this game called "21" where, starting with 21 stones in a single heap, each player was only allowed to remove one or two stones at a time; as usual, last-to-move wins. The notation for codifying this game would be *S(1, 2)*, with the *S* standing for *subtraction game*.

The strategy for this game is simple: let the opponent start. If she takes one stone, take two; if she takes two stones, take one. That way, both your moves combined always removes three stones, and you'll be sure to make the last move. Generalizing, if you're playing *S(1, 2 ... N)*, make sure that your move leaves the single heap with a multiple of *N + 1* stones.

We could imagine a *nim-sequence* for the game: an infinite sequence that tells us, for each heapsize, what size of a Nim-heap (or what *nimber*, remember?) that heapsize represents. For the game "21", the (zero-based) nim-sequence looks like this:
```
0.120120120120120120120...
```
(The dot is not a decimal dot, it's just there for show.)

It keeps repeating like that forever. Recall that you want to play into a 0-position, because that means your opponent is on his way to lose. Every third heapsize is a 0-position in the game "21", which is why we want to adopt the strategy of making both players' moves sum up to 3.

How is the above sequence calculated? The general rule is that a particular position is calculated as "the mex of its options". By *mex*, I mean the "minimum excluded number", and by *options*, I mean all (values of the) game positions available by making a single move. So, for example, in calculating G(21), the nim-value of the position with 21 stones, we only need to know that *G(19)* is 1 and *G(20)* is 2, so *G(21) = mex(1, 2) = 0*.

Here's a Perl one-liner to calculate the sequence:

```Draku
$ raku -e 'my @g = 0, 1; print "0.1"; loop { my %set; ++%set{@g[* - $_]}
            for 1, 2; my $mex = first { !%set.exists($_) }, 0..*;
            print $mex; push @g, $mex }'
0.12012012012012012012012012012^C
```

We could imagine other interesting sets of numbers to put inside the *S(...)*. Something like "you're only allowed to take 5, 12, or 30004 stones" &mdash; that is, *S(5, 12, 30004)* &mdash; would make a game. The important thing is that any such set of numbers would produce a nim-sequence like the one above (one we can compute), and so that particular subtraction game would translate back to Nim. In a sense, the game produced would just be a warped version of Nim.

But let's generalize Nim into something that includes problem p4 in the Raku Coding Contest. Let's introduce the following *operations* on heaps:

```
1 -- Remove, leave as zero heaps
2 -- Remove, leave as one heap
4 -- Remove, leave as two heaps
8 -- Remove, leave as three heaps
...
```

The operations are orthogonal, and can be added together to give a sort of bitmask of what's allowed. For example, 6 would mean "remove stones, leave remainder as one or two (non-empty) heaps". 0 would of course mean that no operations are permitted.

Finally, we encode a particular game with the notation **·d<sub>1</sub>d<sub>2</sub>d<sub>3</sub>**, where the three numbers represent the permitted operations when removing 1, 2, or 3 stones, respectively. So **·600** (or just **·6**, for short) would represent a game where in each move, you remove a stone from a heap, and then have the additional choice to leave the remainder as one heap or two.

Collectively, due to the notation employed, these games go under the name *octal games*. I find the notation to be a bit opaque, but I suppose one gets used to that. It's clearly a nice way to systematize this type of game.

For example, the authors describe the game Kayles. In this game, players knock down pins standing on a row. They can knock down either one pin or two adjacent pins.

Well, this game is just **·77** &mdash; the 7s are to be read as "you're allowed to remove a row of pins entirely, diminish it a bit, or split it into two", but since there are only two digits, you're only allowed to do this while removing one pin or two. So **·77** is equivalent to the informal description above.

So, what octal game would p4 correspond to? Let's find out.

We note that, after the initial (arbitrary) move breaks the circle, all we'll ever get in the p4 game is a bunch of heaps. The only allowed move is to take exactly two stones from a heap, either from the edge (diminishing it) or from the inside (breaking it up into two). This gives us **·07**, a game known in the book as *Dawson's Kayles*.

Here's the Perl one-liner to calculate the nim-sequence for **·07**:

```
$ raku -e 'my @g = 0, 0; print "0.0"; loop { my %set;
            ++%set{@g[$_] +^ @g[* - $_ - 2]} for 0 .. @g/2 - 1;
            my $mex = first { !%set.exists($_) }, 0..*;
            print $mex; push @g, $mex }'
0.0112031103322405223301130211045274
  0112031103322445523301130211045374
  8112031103322445593301130211045374
  8112031103322445593301130211045374
  8112031103322445593301130^C
```

I've taken the liberty of line-breaking the output so that one particular detail stands out: the nim-sequence of **·07** is "ultimately periodic", with a period of 34. (We could, but won't, prove that it's ultimately periodic.)

And this, dear reader, finally brings us face-to-face with the question these p4-preparatory posts were meant to answer, at least sketchily: is p4 solvable? Is there a strategy for rings of arbitrarily many stones? The answer is yes, there is, and all the required information can be found in the above sequence.

Don't you just hate it when math turns out to have all the answers? ☺ Well, perhaps not all... Where in the world does that period of 34 come from...?
