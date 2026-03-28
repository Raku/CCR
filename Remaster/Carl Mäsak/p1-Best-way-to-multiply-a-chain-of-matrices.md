# p1: Best way to multiply a chain of matrices
    
*Originally published on [19 January 2011](http://strangelyconsistent.org/blog/p1-best-way-to-multiply-a-chain-of-matrices) by Carl Mäsak.*

*If you're just stumbling in and wondering what this blog post is all about, it's all about summarizing the [Raku coding contest](http://strangelyconsistent.org/blog/masaks-perl-6-coding-contest).*

```
<moritz_> I think you just killed my weekend :-)
```

I've reviewed and published [the p1 submissions](http://strangelyconsistent.org/p6cc2010/). On the page linked, you can browse the solutions, along with my (mostly random) notes on same.

For those who need a refresher, here's the problem description:

## Find the optimal way to multiply a chain of matrices

Matrices are multiplied in a slightly peculiar way. If you're not familiar
with how, see (for example) https://en.wikipedia.org/wiki/Matrix_multiplication
A consequence of the way matrix multiplication is defined is that one can
only multiply a p⨉q matrix with a q⨉r matrix; that is, the number of columns
in the left-hand matrix has to match the number of rows in the right-hand
matrix. The result of the multiplication will be a matrix of dimension p⨉r.

The number of scalar multiplications needed during a matrix multiplication
happens to be p * q * r.

When multiplying the three matrices A1, A2, and A3 together (in that order),
we have a choice to make. We could multiply (A1A2)A3 or A1(A2A3). The
result will be the same no matter which parenthesization is chosen, but the
total work involved might vary. With a longer chain of matrices, the number of
choices grows exponentially. See http://oeis.org/A000108 for just how quickly.
Your job is to locate a best parenthesization, where "best" is defined so
as to minimize the total number of scalar multiplications needed to multiply
together the chain of matrices. You don't need to actually multiply together
any matrices; you just need to find out, given their sizes, how to
parenthesize so that the least amount of scalar multiplications is performed.
The input is just a set of numbers representing the dimensions of the
matrices. For example, the input "10 30 15 10" represents a 10⨉30 matrix
(A1) multiplied with a 30⨉15 matrix (A2) multiplied with a 15⨉10 matrix. The
output is a parenthesization, in this case either "((A1A2)A3)" or "(A1(A2A3))".

Let's find out which one.

Multiplying A1 and A2 would require 10 * 30 * 15 = 4500 multiplications. The
result would be a 10⨉15 matrix. Multiplying this with A3 would require
10 * 15 * 10 = 1500 multiplications, for a total of 6000 multiplications.
Multiplying A2 and A3 would require 30 * 15 * 10 = 4500 multiplications. The
result would be a 30⨉10 matrix. Multiplying A1 with this would require
10 * 30 * 10 = 3000 multiplications, for a total of 7500 multiplications.
So "((A1A2)A3)" would be the correct answer in this case.

Note that there's one set of parentheses for each multiplication being made.

I did the reviews in a single pass, so single-pass limitations apply. I know that I'm at least slightly inconsistent, pointing out things in one solution but not in others. I do try to be *fair* though, for some definition of the word. If you find something you think is less than fair, or simply wrong, do get in touch. Especially if it's your submission I was reviewing.

At some point in the reviews, I start talking in terms of line numbers. I'm aware that the code listing does not yet have line numbers. I hope to add this in the next few days. I'll also backport the line numbers to the first few reviews.

From a high-level perspective, the contestants did well on this one. All of them solved the *immediate* problem. One contestant got the deeper problem wrong, in the sense that his was a greedy solution that always eliminated the short-term most expensive matrix dimensions. This is fine for some inputs, but not for others. I give an example of an input that doesn't work in [the notes](http://strangelyconsistent.org/p6cc2010/p1-fox/).

Another contestant solved the problem correctly, but in such a way that for a sufficiently long chain of matrices, one would *lose* time finding the best order of multiplication. (The problem specification hints at this hurdle, but doesn't come out and say it outright.)

The remeaining three contestants' submissions are all dynamic programming solutions. This is what I was after when i posed the problem. moritz' and util's are ports of code from elsewhere &mdash; and nothing wrong with that, quite the contrary &mdash; whereas matthias' solution is the outlier of the three. All I can say is that it seems to have FP influences.

Apparently there are [even fancier algorithms](https://en.wikipedia.org/wiki/Matrix_chain_multiplication#An_Even_More_Efficient_Algorithm) to solve this problem... but at some point, it feels like overkill to slap more theory on a solution that's already fairly good.

So there we are. Go and [have a look](http://strangelyconsistent.org/p6cc2010/) for yourself. There are a number of nice small idioms in there; I've tried to enumerate them under "Idiomatic use of Raku".
