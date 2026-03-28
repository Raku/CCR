# June 12 2011: for loops
    
*Originally published on [12 June 2011](http://strangelyconsistent.org/blog/june-12-for-loops) by Carl Mäsak.*

Yesterday, we went through array variables, and there was much rejoicing. We saw how to add and remove things at the ends. We learned how to treat arrays as a single item. We learned how to inspect and change individual array elements.

But there's something missing still. Something important. We will often want a way to say, "for every element in this array, do this...".

We need a kind of loop for arrays.

```raku
my @seasons = "winter", "spring", "summer", "fall";
for @seasons {
    say "Yay, $_!";
}
# Yay, winter!
# Yay, spring!
# Yay, summer!
# Yay, fall!
```

In the olden days, one used to loop through arrays by repeatedly increasing an index counter (often called `$i`), and then indexing the array with it. This is now considered gauche and primitive.

Our good friend the topic variable `$_` shows up again here. The for loop takes care of *binding* it to the appropriate value; in this case, it is bound to each element in the array in turn. Since the array contains four elements, we make four iterations through it. Simple.

So, to summarize, `given` sets the topic for a single value, whereas `for` sets the topic for each of the elements in an array or list.

Sometimes we want a more descriptive name than just `$_`. The topic variable is fine for shorter loops, but when programs get larger and one can't see the closing brace of a block from its opening brace, it increasingly makes sense to name the variable something else.

We *could* do this each time:

```raku
my @seasons = "winter", "spring", "summer", "fall";
for @seasons {
    my $season = $_;
    say "Yay, $season!";
}
```

But there's a nicer way:

```raku
my @seasons = "winter", "spring", "summer", "fall";
for @seasons -> $season {
    say "Yay, $season!";
}
```

In the latter case, `$_` is *not* set, so any value that it had before will be preserved. You could think of it as the "default" of a `for` loop being `-> $_`, which is correct enough for now.

We don't have to loop over arrays, either. Here's a short program that loops over the words that we input:

```raku
my $sentence = prompt "Enter a sentence: ";
for $sentence.words -> $word {
    say "'$word' has $word.`chars` characters";
}
```

Running the program could look like this:

```
Enter a sentence: This isn't my hamster
'This' has 4 characters
'isn't' has 5 characters
'my' has 2 characters
'hamster' has 7 characters
```

Two new methods above: `.words` is a method on a string that returns a list of contiguous "word characters" (anything but whitespace).

`raku.chars` gives the length (number of characters) of a string. Note that we can even do method calls and have them interpolate in strings; the proviso is that we end in parentheses (`()`).

That's it for today. Tomorrow we'll have a look at regexes, whatever that may be. `:-)```
