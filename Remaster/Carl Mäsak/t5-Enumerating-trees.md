# t5: Enumerating trees
    
*Originally published on [30 June 2012](http://strangelyconsistent.org/blog/t5-enumerating-trees) by Carl Mäsak.*

> Thanks again for holding this contest.  Exercises like this give folks like me a fun chance to exercise skills and learn new ones that may not otherwise come up in a day job. It's reminded me specifically despite how far I've come, I still have much to learn.  Good thing I enjoy learning.  :-) And, since you publish the code with great commentary, we all get to learn from each other, which is awesome. &mdash; zbiciak`

Let's tackle the final task of the [Raku Coding Contest
2011](http://strangelyconsistent.org/blog/the-2011-perl-6-coding-contest).

I doodle on meetings. I make actual meeting notes too, but sometimes they are
decorated with curious geometrical patterns or shapes. The t5 problem
was born from such a doodle session. I started drawing little circles and
connecting them up in all possible ways, and then...

== Enumerating trees

We're used to thinking about rooted trees in computer science, but now
for a while we'll be talking about *un*rooted trees.
An unrooted tree is simply a graph with N nodes and N-1 edges,
without cycles. Each node is reachable from any other node through
exactly one simple path.
Here's an example tree with three nodes.
```
1--2--3         a tree with a line shape
```
In order to talk about different trees, we employ a traversal representation
that looks like this:
```
1-2-3-2         traversal representation
```
This can be thought of as the sequence of nodes encountered when tracing
around the tree (say) clockwise. In the above case, we start at node
1, continue to node 2, turn at node 3, find node 2 again, and then
we're back at node 1 (which we don't include at the end).
The traversal representation is simply a way to identify each graph by its
structure.

For simplicity's sake, let the traversal representation be "canonical", in the
sense that it always introduces previously unseen nodes with the numbers
1..*, in order. This reflects the fact that we're really dealing with
unlabeled trees, and don't consider nodes to be distinct.
Note that starting from a different node, or mirroring the tree in the
plane that embeds it, may yield a different canonical traversal
representation. (So it's not quite canonical.) You're free to pick any
one of these if there are several.

There's only one tree each with 1, 2, or 3 nodes. 4 is the first
interesting case, and has two unique trees
```
1--2--3--4      another line        1-2-3-4-3-2
1--2--3
   |            a T-shape           1-2-3-2-4-2
   4
```
Similarly, there are three unique trees with 5 nodes.
Write a program that accepts a positive integer N on the command line,
and outputs all unique unrooted unlabeled trees with N nodes, using
canonical traversal representation.

For example, for N = 4, the program should output the above two trees:
```
1-2-3-4-3-2
1-2-3-2-4-2
```

Now I *am* trying to trick you all in the above description. (What, you thought
we just put together the task descriptions to be as clear as possible?
Mwhahaha!) The traversal representation is all fine and good for representing
trees embedded in the plane, but some graphs can be embedded in the plane in
many differnt ways. So the programmer has to be careful.

This was perhaps the most deceitful of the tasks, if not the hardest. When I
solved it myself back in November, the mistake I did was thinking that the
(canonicalized) traversal representation was unique enough, and so I ended up
counting some trees twice.

The first thing one does with this kind of problem is to solve it for the first
few `N`, and then [go check at oeis.org](https://oeis.org/A000055) for the
actual sequence:

```raku
1, 1, 1, 1, 2, 3, 6, 11, 23, 47, 106...
```

I remember getting 12 trees for the case `N = 7`. Twelve, not elevent as I
should get. I had to actually draw them and see what was wrong. Turns out two
of my graphs were really the same graph but had been embedded in the plane in
two different ways.  Not a simple case of mirroring (like the task description
warns about), but more subtle than that: the traversal simply chose different
visiting orders, resulting in the same tree represented in two different ways.

I wanted to bury this interesting trap in a seemingly-innocuous problem, so
that I could observe people fall into it.

I think one contestant fell into this particular trap. Hehehehe. Other
contestants fall into different traps that I didn't set up.

The general problem can be solved quite nicely by induction. That is, we can
trivially generate a graph with just one node. Then we generate all the
```rakuN`-graphs by starting from all the `N-1`-graphs, and "extending" all of them
in all possible ways. That is, for the new generation we try to put an edge and
a node in all possible places in all of the graphs in the old generation. After
that, it's just a matter of weeding out duplicates.

This isn't the only way to solve it; some of the solutions are actually quite
clever and base their solutions on, you know, integer partitions and stuff.

Still, they all fail. No, hold on, all except one.

edgar's solution, by getting the right number of graphs as far as I have the
patience to test it (N = 19, 317955 graphs), while all the other solutions sent
in get N = 5 or N = 8 wrong, is like a runner who while all his competitors
trip and fall after a few meters, runs all the way to the moon and back. Way to
go, edgar!

Have a look at [everyone's solutions](http://strangelyconsistent.org/p6cc2011/).

There are two more interesting things worth mentioning that aren't in the
reviews. One is that I got sent a paper &mdash; from I don't remember who,
sorry! &mdash; from 1981, called ["The Semantic Elegance of Applicative
Languages"](https://cecs.wright.edu/~tkprasad/courses/cs776/paraffins-turner.pdf).

The FP language used in the paper looks a bit like Haskell, and arnsholt
[informs me](https://irclogs.raku.org/perl6/2012-06-25.html#19:03) that it is
indeed a direct ancestor. Now, what tickles my imagination about this paper is
how it's clearly set out to show how completely *nice* and feasible it is to
implement something in an applicative language like this. And even though it
does a good job of it in 1981, I bet the same approach would look even nicer in
2012 Haskell. Heck, I bet the same approach would look quite elegant in 2012
Raku.

The other thing is that one of our non-contestants (he simply applied too late)
not only used an algorithm out of the fourth "The Art of Computer Programming"
book, but found what he perceived to be a bug in same algorithm, and wrote an
email to Donald Knuth about it! Well, it turned out that professor Knuth's
algorithm was indeed correct and zbiciak's algorithm was wrong. This story
would have been much cooler if zbiciak was right, but I think it's still pretty
cool. The people involved in this contest are really motivated. And seeing
Donald Knuth's handwriting on a scanned printout of zbiciak's email &mdash;
professor Knuth doesn't do email &mdash; probably shouldn't be a big thing, but
it is.

Running this contest is so worth it.
