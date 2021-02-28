# Python is The New 'Write-Only, Linenoise' Language
    
*Originally published on [20 January 2016](https://perl6.party//post/Python-is-The-New-Write-Only-Linenoise-Language) by Zoffix Znet.*

As a Perl programmer of about a decade, I'm well aware of how it was referred to at some point or another as the "write-only" and "linenoise" language. With the newest addition of the baby Raku language to the Perl family, I fear that I must ~~declare~~ (wildly speculate) based on my ~~extensive research~~ (a boring ride on a bus, while staring at my phone) that Python steals that title now!!

Why Python? Blame whoever made the [Stackoverflow Python Report](http://python-weekly.blogspot.ca/2016/01/ii-stackoverflow-python-report.html) scroll through my Twitter feed. I merely picked two problems from that list and asked myself what would the Raku solutions to them look like.

## Interleave Two Strings

The top rated item of the week is [interleaving two strings](http://stackoverflow.com/questions/34756145/most-pythonic-way-to-interleave-two-strings).

```` raku
#Given:
u = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
l = 'abcdefghijklmnopqrstuvwxyz'
#Wanted:
'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz'
````

The accepted Python answer is this:

```` raku
res = "".join(i + j for i, j in zip(u, l))
print(res)
````

Certainly isn't bad, but using a two-variable postfix `for` loop inside a method call is something I wouldn't want to read in code very often. Let's examine the Raku version:

```` raku
say join '', (u.comb Z l.comb)
````

Just like the Python version, we're utilizing the ``join``, but the rest looks certainly cleaner: we're using the `.comb` method on our two strings, which without arguments returns characters in a string, and we combine them with the `Z` zip operator. That is it! No loops needed. (And before someone points it out, no, I haven't missed any sigils. Raku can have sigilless vars, baby).

## Round-Robin Merge Two Lists of Different Length

Another interesting item on the list is [round-robin merge of two different-length lists](http://stackoverflow.com/questions/34692738/merge-lists-in-python-by-placing-every-nth-item-from-one-list-and-others-from-an). There isn't an accepted answer to the question, so I'll go with the highest-voted:

```` raku
list1 = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']
list2 = ['x', 'y']
n = 3
iter1 = iter(list1)
res = []
for x in list2:
    res.extend([next(iter1) for _ in range(n - 1)])
    res.append(x)
res.extend(iter1)
>>> res
['a', 'b', 'x', 'c', 'd', 'y', 'e', 'f', 'g', 'h']
````

I see a `for` loop, and another `for` loop, `.extend` method and then `.append` method and after another `.extend` after the outer `for` loop, voilà! Result.

Being a Raku noob, I first reached for the trusty `Z` operator, then I messed with the [Hyper Operators](http://rakumaven.com/tutorial/rakuyper-operators), and all I got in return were either wrong solutions or messy solutions... Until someone pointed out that Raku actually has a [`roundrobin` routine](http://docs.raku.org/routine/roundrobin)! So what's the Raku answer?

```` raku
my @list1 = 'a' .. 'h';
my @list2 = <x y>;
say flat roundrobin @list1, @list2;
# >>>
# OUTPUT«a x b y c d e f g h»
````

On the first two lines, we're simply creating two variables for our lists. `@list1` uses a range with letters and `@list2` uses the quote word construct. I'm sure similar things exist in Python too, so I won't count clarity and ease-of-writing points for those, but the rest of the code is rather different. There are no loops, extends, or appends. We use the `roundrobin` routine to... surprise... round-robin through the two lists. Now, it returns a `Seq` of `List`s, which is why I added the `flat` routine as well, to flatten the output to what the Python answer returns.

**EDIT:** as one of the commenters pointed out, I wasn't paying much attention to this one and completely missed the "nth element" requirement. Never fear, however, the alternate requirement only needs the addition of trusty [`.rotor` List method](http://docs.raku.org/routine/rotor) that breaks up a list into sublists:

```` raku
my @list1 = 'a' .. 'h';
my @list2 = <x y>;
my $n = 3;
say flat roundrobin @list1.rotor($n - 1, :partial), @list2;
# >>>
# OUTPUT«a b x c d y e f g h»
````

## Summary

This post is, of course, a tongue-in-cheek joshing, based on a random post I saw on Twitter. However, on a more serious and deeper note, it does seem that the brand-new language like Raku that has an actual language specification, when compared to an old grandpa specless language like Python, seems to offer built-in methods, operators, and subroutines specifically geared to real-world problems that—for however short a period of time—made it to the top of a popular programming question website.

And now, if you'll excuse me, I'm off to make a [silly YouTube video](https://www.youtube.com/watch?v=9SyUFO9X_TU) declaring Python to be the new "Write-only, Linenoise" language. Sorry, Perl. You lose.

## Update 1

As I'm not the one to shyly sit in a silo, I went to #python on irc.freenode.net and asked for feedback on this article, and it's this:

In the first example, the use of the for loop is extremely idiomatic Python, so the code is perfectly readable to a competent Python programmer. As for the second Python example, the general opinion was that it's overly-complex and I did see a simple 1-line round-robin example presented to me in-channel. The nth element variant may be dropped to me on Twitter as well in the future :)

I stayed for some drinks, there was cake too! And then I left the channel...
