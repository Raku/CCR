# p3: Is the integer in the rangeset?
    
*Originally published on [22 January 2011](http://strangelyconsistent.org/blog/p3-is-the-integer-in-the-rangeset) by Carl Mäsak.*

*Hi! New here, and don't know what's currently going on? Well, I'm currently summarizing the results of the [Raku coding context](http://strangelyconsistent.org/blog/masaks-perl-6-coding-contest).*

```
* moritz_ wonders if the test can be made without constructing the full included subset
```

I've reviewed and published [the p3 submissions](http://strangelyconsistent.org/p6cc2010/). On the page linked, you can browse the solutions, along with my notes.

As a refresher, Here's the p3 problem description:

## Find out whether a given integer is contained inside a given set of integer ranges

Two lines of input are expected. The first line should be a sequence of
included and excluded integer intervals, on this form:
```
+[ 42 .. 100 ] -[ 50 .. 60 ] -[ -10 .. 2 ]
```
The format of this line should be free-form and horizontal whitespace shouldn't
matter one way or the other.

The second line should be an integer to be tested for inclusion.

The output should be "yes" if the integer is contained in the ranges, and "no"
otherwise. The interval specification above would answer "yes" for all
numbers between 42 and 49 inclusive, or between 61 and 100 inclusive.

Note the difference between the '-' outside the brackets meaning "don't include
these numbers" and the '-' inside meaning "negative number". Also, as you see
from the example, it's perfectly OK to exclude numbers that were never
included. Inclusions and exclusions are performed from left to right. Before
any inclusions/exclusions have been made, all integers are excluded.

Consider that the ranges can be very large.

Ok, I need to admit I messed things up in preparing this task. I meant to steer people towards implementing inversion lists, but...

```
<pmichaud> hmmm, I've already solved #3 on paper (for handling character classes in nqp)
<masak> *nod*
<moritz_> inversion lists!
<masak> (dang) :)
* moritz_ cackles evilly
<masak> don't tell anyone, OK? :)
<moritz_> but actually inversion lists are not the easiest solution for this one
<masak> no?
<moritz_> no
```

...it would only make sense to implement the problem using inversion lists if the same rangeset is used for testing several different integers. When testing just one, as we do, a rangeset is overkill. Much less involved solutions exist.

So this became probably the easiest problem of the bunch. Still quite nice to see how people attack it. This time, three of the submitters go for a grammar-based solutions, whereas the other two favour smaller `.split`/`.comb`-based approaches. Of the three that went with grammars, two also included tests, using the cute ``MAIN``/`MAIN('test')` idiom.

Make sure you [have a look](http://strangelyconsistent.org/p6cc2010/) at the solutions.
