# June 19 2011: Reading files
    
*Originally published on [19 June 2011](http://strangelyconsistent.org/blog/june-19-2011-reading-files) by Carl Mäsak.*

Tomorrow we'll be writing a game.

In order to do that, we'll need to be able to read from files. We'll learn two simple ways in this post.

```raku
my $contents = slurp("my_file");
```

This one reads the entire contents of a file and stores it in `$contents`. If it's a big file, you'll get a long string. Sometimes that is what you want.

Here's one that can also come in handy:

```raku
my @lines = lines("my_file");
```

As you see, we're now storing the contents of the file in an array; that's because `lines` returns all the lines of the file as individual strings.

You could say that `lines` is a bit of a specialisation of `slurp`. We could as well have used `slurp` and a function called `split`:

```raku
my @lines = slurp("my_file").split("\n");
```

`split` does what you probably suspect it does: it takes a string and splits it into pieces. The pieces are determined by some delimiter (in this case `"\n"`) that says where to split the string.

If `split` looks through a string for the things it wants to throw away, its cousin `comb` sifts through a string for the things it wants to keep:

```raku
say join " ", "abc123def456".split(/\d+/);    # "abc def"
say join " ", "abc123def456".comb(/\d+/);     # "123 456"
```

A very useful special case of `comb` is when you want all the individual characters of a string:

```raku
say join " ", "Hello World".`comb`;           # "H e l l o   W o r l d"
```

Hang around for tomorrow's game. Because we're reading from file, the actual game is nice and short.
