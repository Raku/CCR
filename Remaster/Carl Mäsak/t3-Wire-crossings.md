# t3: Wire crossings
    
*Originally published on [29 August 2013](http://strangelyconsistent.org/blog/t3-wire-crossings) by Carl Mäsak.*

Apparently I solemnly swore in [the last p6cc blog
post](t2-Rectangle-haikus.html) that this blog
post would appear sooner than after a two-month break. Apparently I suck at
living up to what I solemnly swear. Anyway, kudos to `$dayjob` for keeping me
healthily occupied with things, and a big thanks to all people related to Perl
6 who gently reminded me to keep up with the reviewing.

(Or maybe I didn't specifically mean "the next
*[p6cc](https://github.com/masak/p6cc2012#readme)* blog post", but just "the
next blog post"? I wish I could make myself believe that. No, the real answer
is that reviewing stuff takes time and effort, and my time and effort have been
elsewhere lately.)

Let's talk about crossing wires in elegant ways! Here, I'll let the description
refresh your mind:

## Arrange wire crossings to rearrange wires

Ten wires are come in from the left. Ten wires leave to the right. Write a
program that, given a permutation of the digits 0..9, arranges crossings on a
grid that places the wires in the order designated by the permutation.

The output consists of a grid whose elements connect the left and right sides.
Each cell of the grid is either *empty* (in that it just lets the wires
through), or a *crossing* (in that it lets the wires trade places). Two
crossings can never be placed vertically adjacent to each other. (This is
equivalent to saying that the wires never split or merge, they only permute.)

Often, solutions require crossings to be spread out not just vertically but
also horizontally. It is considered elegant not to make the grid wider than it
has to be.

Examples:
```
Input: 1032547698
Output:
0 _  _ 1
   \/
1 _/\_ 0
2 _  _ 3
   \/
3 _/\_ 2
4 _  _ 5
   \/
5 _/\_ 4
6 _  _ 7
   \/
7 _/\_ 6
8 _  _ 9
   \/
9 _/\_ 8
```
(This permutation is simply flipping wires pairwise.)
Input: 1234567890
```
Output:
0 _  _________________ 1
   \/
1 _/\  _______________ 2
     \/
2 ___/\  _____________ 3
       \/
3 _____/\  ___________ 4
         \/
4 _______/\  _________ 5
           \/
5 _________/\  _______ 6
             \/
6 ___________/\  _____ 7
               \/
7 _____________/\  ___ 8
                 \/
8 _______________/\  _ 9
                   \/
9 _________________/\_ 0
```
(The simplest way to bubble 0 to the bottom.)
```
Input: 5012367894
0 _________  _ 5
           \/
1 _______  /\_ 0
         \/
2 _____  /\___ 1
       \/
3 ___  /\_____ 2
     \/
4 _  /\_______ 3
   \/
5 _/\  _______ 6
     \/
6 ___/\  _____ 7
       \/
7 _____/\  ___ 8
         \/
8 _______/\  _ 9
           \/
9 _________/\_ 4
```
(The simplest way to bubble 4 and 5 simultaneously.)

The reviews are in. To get the full enjoyment out of this blog post, I highly
recommend that you [read the
reviews](https://github.com/masak/p6cc2012/tree/master/t3/review) as well as
this post. The solutions are a varied bunch, and there's lots of nice code in
there.

How would a program find a nice, short solution to the write-crossing problem?
Wait, can we even be sure there always *is* a solution? If the fundamental
operation is crossing two adjacent wires, can we really generate the full space
of permutations? (As opposed to, say, only half the space, like in the [15
puzzle](https://en.wikipedia.org/wiki/15_puzzle).)

We can generate the full space of permutations. The quickest way to convince
ourselves of that is to think of sorting algorithms, many of which use "flip
two adjacent values" as its fundamental operation. Sorting algorithms can sort
anything, hence the wire-crossing problem always has a solution.

(Wouldn't it be weird to live in a world where sometimes you'd pass in a list
to be sorted, and the computer would come back and say "sorry, this is one of
those unsortable lists of values". What a bummer!)

In fact, many of the solutions took the sorting analogy to heart, producing
something like a [bubble sort](https://en.wikipedia.org/wiki/Bubble_sort) with
slightly modified rules. In bubble sort, the same value can be transposed
several times during one run, something that isn't possible in the wire
universe: you flip two writes, and you then have to wait until the next column
to flip either of those wires again. But with that little restriction added,
bubble sort seems to solve this problem just fine.

As always, it's nice to see how people's styles differ broadly. I never see two
identical solutions, but this time around, it felt especially varied. Maybe
because the problem is relatively small, and one wouldn't think there were that
much to vary. But just watch as people apply dynamic variables, feed operators,
enums, junctions, sequence operators, metaoperators, and many other things to
solve the same problem. There Is *indeed* More Than One Way To Do It.

As of last review post, we were down to five finalists. Now we're down to four.

Next post: pouring water on a block world!
