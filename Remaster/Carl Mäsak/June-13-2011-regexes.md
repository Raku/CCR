# June 13 2011: regexes
    
*Originally published on [13 June 2011](http://strangelyconsistent.org/blog/june-13-regexes) by Carl Mäsak.*

How could we tell whether a string contains another string? There are several ways, but this is one:

```raku
my $password = prompt "Enter the secret password: ";
if $password ~~ /sekkrit/ {
    say "Welcome, sir or madam!";
}
else {
    say "Bah, go away.";
}
```

With that `if` statement, the door will kindly open for us regardless if we write `sekkrit` or `sekkrit42` or `I haz a sekkrit`. But not `secret` or `sekkr` or `sek krit`. The exact substring has to be in there.

Oh, and we recognize the smartmatch operator `~~` in there. That makes sense, since we're making a kind of comparison. But we're comparing against the *regex* `/sekkrit/`, which finds us a substring.

That's only the beginning of what regexes can do. Here are some more examples, in quick succession:

```raku
/ ^ foo /                # Does the string begin with "foo"?
/ foo $ /                # ...end with "foo"?
/ ^ foo $ /              # ...contain only "foo"?
/ ^ $ /                  # ...contain nothing?
/ \d /                   # ...contain a digit?
/ \w /                   # ...contain an alphanumeric character?
/ \s /                   # ...contain a whitespace character?
/ foo || bar /           # ...contain either "foo" or "bar"?
/ fo? /                  # ...contain an "f" and then maybe an "o"?
/ fo* /                  # ...contain an "f" and zero or more "o"s?
/ fo+ /                  # ...contain an "f" and one or more "o"s?
/ [foo]+ /               # ...contain one or more "foo"s in sequence?
/ 'foo'+ /               # (same thing)
/ [foo] ** 5 /           # ...contain exactly 5 "foo"s in sequence?
```

As you can see, it does quite a bit more than check for substrings.

And not only that. It can also "capture" parts of the thing it matches, and give it back to you in nice, numbered variables:

```raku
my $promise = "I will eat my vegetables.";
if $promise ~~ / (\w+) \s \w+ \s (\w+) \s \w+ \s (\w+) / {
    say $0;    # "I"
    say $1;    # "eat"
    say $2;    # "vegetables"
}
```

There's much more to say about regexes, and Raku relishes in their power. But now it's my bedtime, and maybe yours, too. Good night.
