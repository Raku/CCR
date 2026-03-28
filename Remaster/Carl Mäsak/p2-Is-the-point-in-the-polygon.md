# p2: Is the point in the polygon?
    
*Originally published on [22 January 2011](http://strangelyconsistent.org/blog/p2-is-the-point-in-the-polygon) by Carl Mäsak.*

*If you're just passing by and don't have any context as to what this blog post is all about, it's all about summarizing the [Raku coding context](http://strangelyconsistent.org/blog/masaks-perl-6-coding-contest).*

```
<colomon> "It should not matter whether the points in the polygon run clockwise or counterclockwise."  Silly masak!
```

I've reviewed and published [the p2 submissions](http://strangelyconsistent.org/p6cc2010/). On the page linked, you can browse the solutions, along with my notes.

Here's the problem description for p2:


## Find out whether a given point is inside a given (simple) polygon

Well, that's it, really.

A polygon is *simple* if its edge doesn't intersect itself. You only have
to solve the problem for this type of polygon. You also don't have to
consider polygons with holes.

Of course, if you're terribly disappointed at this restriction, by all means go
ahead and solve a more general variant of the problem.
Here's what the input might look like:
```
1.0,1.0 1.0,-1.0 -1.0,-1.0 -1.0,1.0
0.0,0.0
```
The points in the first line describe a square with side 2 centered on the
origin. (It is assumed that edges connect all adjacent pairs of coordinates,
as well as the first and the last pair.) The point in the first line is the
one tested for inclusion, so in this case the output should be "yes".
It should not matter whether the points in the polygon run clockwise or
counterclockwise.

I'd say that all the contestants "passed" this one, in that they all have good, usable
solutions. I only found one bug in one of the solutions, and even it wasn't too serious.

Four of the solutions carry the same general theme (but with many details different). colomon's
solution is the outlier, bringing in ambitious machinery to make sure the point doesn't
cheat its way in and out of that polygon. I'm honestly not comp.geom.-savvy enough to determine
whether those extra safety measures are "worth it", but I'll happily take colomon's word for
it.

All of the solutions are worth [browsing through](http://strangelyconsistent.org/p6cc2010/). I know I did.

Code submitters, let me know if I've omitted or committed something in my reviews! Speak now, or forever hold your point in a polygon!
