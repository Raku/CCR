# .rotor: The King of List Manipulation
    
*Originally published on [29 January 2016](<!DOCTYPE html>) by Zoffix Znet.*

Rotor. The word makes a mechanic think about brakes, an electrical engineer about motors, and a fan of [Red Letter Media YouTube channel](https://www.youtube.com/watch?v=s76vZATqLrE) about poorly executed films. But to a Raku programmer, [`.rotor`](http://docs.raku.org/routine/rotor) is a powerful tool for list operations.

## Break up into chunks

At its simplest, `.rotor` takes an integer and breaks up a list into sublists with that many elements:

```` raku
say <a b c  d e f  g h>.rotor: 3;
# OUTPUT: ((a b c) (d e f))
````

We have a list of 8 elements, we called `.rotor` on it with argument `3` and we received two [Lists](http://docs.raku.org/type/List), with 3 elements each. The last two elements of the original list we not included, because they don't make up a complete, 3-element list. That can be rectified, however, using the `:partial` named argument set to `True`:

```` raku
say <a b c  d e f  g h>.rotor: 3, :partial;
# OUTPUT: ((a b c) (d e f) (g h))
say <a b c  d e f  g h>.rotor: 3, :partial(True);
# OUTPUT: ((a b c) (d e f) (g h))
say <a b c  d e f  g h>.rotor: 3, :partial(False);
# OUTPUT: ((a b c) (d e f))
````

Here's what we've learned so far, used as a crude means to fit a chunk of text into 10-column width:

```` raku
"foobarberboorboozebazmeow".comb.rotor(10, :partial)».join».say
# OUTPUT:
#    foobarberb
#    oorboozeba
#    zmeow
````

We broke up the string into individual letters with `.comb` method, then we `.rotor` them into 10-element lists,
specifying that `:partial` lists are fine too, and lastly we use a pair of hyper method calls to `.join` and `.say` each of those sublists.

## Mind The Gap

Say, you're receiving input: you get a word, its French translation, and its Spanish translation, and so on for a whole bunch of words. You want to output only a particular language, so we need to somehow skip over some items in our list. `.rotor` to the rescue!

Specifying a [Pair](http://docs.raku.org/type/Pair) of integers as the argument makes `.rotor` break up the list into `$key` elements, with `$value` gap in between. Easier to see in the example:

```` raku
say ^10 .rotor: 3 => 1, :partial;
# OUTPUT: ((0 1 2) (4 5 6) (8 9))
say ^10 .rotor: 2 => 2, :partial;
# OUTPUT: ((0 1) (4 5) (8 9))
````

On the first line, we have a range of integers from `0` to `9`, we're asking `.rotor` to break that up into lists
of 3 elements (including partial lists) and use a gap of `1`. And indeed, you can see the output is missing number `3` as well as `7`. Those are the gaps we skipped. In the second example, we've increased the gap to `2`, and broke up the list into 2-element sublists: the `2`, `3`, `6`, and `7` are the numbers that fell into gaps and were not included. Back to our exquisitely convoluted translations program:

```` raku
enum <English French Spanish>;
say join " ", <Good Bon Buenos morning matin días>[French..*].rotor: 1 => 2;
# OUTPUT: Bon matin
````

We cheatsy-doodle with an `enum` and then use the `[LANG..*]` to toss the head of the list. The `French` in our example is `enum`erated into integer `1`, which means `[1..*]` gets rid of the first element. Then, we use `.rotor` to make 1-element lists with a 2-element gap. This makes it skip over the words for languages we're not interested in.

Now, I'm sure some in the audence are currently throwing tomatoes at me and saying I'm going mental with my examples here... Let's look at something more real-worldly.

## Overlaps

You have a list and you want to Do Things™ based on whether the next item is the same as the current one. Typically, this would involve a loop and a variable holding the index. You check the `index+1`, while also checking you've not reached the upper boundary of the list. Sounds tedious. Let's use `.rotor` instead!

We've already learned above that using a Pair we can introduce gaps, but what if we make the gap negative? It actually works!

```` raku
say <a a b c c c d>.rotor: 2 => -1;
# OUTPUT: ((a a) (a b) (b c) (c c) (c c) (c d))
say <a a b c c c d>.rotor(2 => -1).map: {$_[0] eq $_[1] ?? "same" !! "different"};
# OUTPUT: (same different different same same different)
````

On the first line, we're just printing the results from `.rotor` to see what they look like and on the second line, we're performing the actual comparison and acting accordingly. Looking at the first result: we get 2-element lists, where the first element is the element from the original list and the second element is the one that follows it. That is, were we to print just the first elements of our sublists, we'd receive our original list back, minus the last element. The second elements are all just a bonus!

## All Out

A single `Int` or a `Pair` are not the only thing `.rotor` can accept. You can specify additional positional parameters that are `Int`s or `Pair`s to break up lists into sublists of different sizes, with different gaps between them.

Say, I have a custom daemon that creates logs about users that access it. The log is in plain text, each record
follows the other. Records are multi-line and always look something like this (two records + separator shown):

```` raku
IP: 198.0.1.22
Login: suser
Time: 1454017107
Resource: /report/accounting/x23gs
Input: x=42,y=32
Output: success
===================================================
IP: 198.0.1.23
Login: nanom
Time: 1454027106
Resource: /report/systems/boot
Input: mode=standard
Output: success
````

Each item contains a "header" with user information and resource they tried to access, as well as the "operation" they wanted to execute. In addition, each item is separated by a double-line. I would like to print the header and the executed operation, and I want `Resource:` to be present in both.

To parse this, we could use [Grammars](http://docs.raku.org/language/grammars), but `.rotor` can do the trick too:

```` raku
for 'report.txt'.IO.lines».indent(4).rotor( 4 => -1, 3 => 1 ) -> $head, $op {
    .say for "Header:",    |$head,
             "Operation:", |$op, '';
}

# OUTPUT:
#    Header:
#        IP: 198.0.1.22
#        Login: suser
#        Time: 1454017107
#        Resource: /report/accounting/x23gs
#    Operation:
#        Resource: /report/accounting/x23gs
#        Input: x=42,y=32
#        Output: success
#
#    Header:
#        IP: 198.0.1.23
#        Login: nanom
#        Time: 1454027106
#        Resource: /report/systems/boot
#    Operation:
#        Resource: /report/systems/boot
#        Input: mode=standard
#        Output: success
````

We fetch lines from file `report.txt` with `'report.txt'.IO.lines`. To make output prettier, we indent each line with 4 spaces by calling `.indent(4)` on each item using the hyper operator (`»`). Now comes `.rotor`!  We use it to break up lines into repeating chunks of 4 and 3 items: that's items for our header and our operation. After grabbing the 4-element chunk, we use a negative gap to backtrack and include `Resource:` line in our operation chunk as well. In the 3-element chunk, we use a positive gap, to skip over the separator line.

Afterwards, we use a `for` loop and give it two variables with `-> $head, $op`, so it loops over two items at a time.  Inside the loop, we merely print each log item onto the screen. Since `$head` and `$op` are Lists, we use the pipe (`|`) character to [slip](http://docs.raku.org/type/Slip) them in.

Keep in mind, the pattern you supply to `.rotor` can be dynamically generated! Here we use a sine to generate it:

```` raku
say ^92 .rotor(
    (0.2, 0.4 ... 3).map: (10 * *.sin).Int # pattern we supply to .rotor
).join: "\n"

# OUTPUT:
#    0
#    1 2 3
#    4 5 6 7 8
#    9 10 11 12 13 14 15
#    16 17 18 19 20 21 22 23
#    24 25 26 27 28 29 30 31 32
#    33 34 35 36 37 38 39 40 41
#    42 43 44 45 46 47 48 49 50
#    51 52 53 54 55 56 57 58 59
#    60 61 62 63 64 65 66 67 68
#    69 70 71 72 73 74 75 76
#    77 78 79 80 81 82
#    83 84 85 86 87
#    88 89 90
#    91
````

So whether you're an electrician, mechanic, or anyone else, I hope you'll find `.rotor` a useful multipurpose tool.

## Update 1:

It's been pointed out to me that

```` raku
"foobarberboorboozebazmeow".comb.rotor(10, :partial)».join».say
````

Is better written as

```` raku
`"foobarberboorboozebazmeow".comb(10)».say
````
