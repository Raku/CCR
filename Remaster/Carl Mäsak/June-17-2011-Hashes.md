# June 17 2011: Hashes
    
*Originally published on [18 June 2011](http://strangelyconsistent.org/blog/june-17-2011-hashes) by Carl Mäsak.*

Hashes are like phone books. We use them to go from one thing (like a name) to another thing (like a phone number).

```raku
my %phone_numbers =
    "Ada"     => "555-414141",
    "Charles" => "555-567123",
    "Ernest"  => "555-832238";
```

Hashes are written with a percent sign (`%`) up front. Not to be confused with when the percent sign is used as the remainder operator. That's a totally different usage.

We index hashes much like we index arrays. But instead of `[]`, we tend to use `<>`:

```raku
say %phone_numbers<Ada>;    # "555-414141"
```

In fact, the above way only works if what we're indexing with is a literal string value. If it's a variable or something more complicated, we need to use `{}`:

```raku
my $inventor = "Charles";
say %phone_numbers{$inventor};  # "555-567123"
```

Assignment to hash values works in the same way.

Apart from that, there are plenty of useful methods on hashes:

```raku
say %phone_numbers.elems;            # "3"
say join " ", %phone_numbers.keys;   # "Charles Ada Ernest"
say join " ", %phone_numbers.values; # "555-567123 555-414141 555-832238"
```

The lists of things returned from `.keys` and `.values` will come out in some unspecified order. This is because hashes, unlike the real phone book, aren't sorted. We basically want hashes as a fast, string-based indexing system. And if it's supposed to be fast, it can't also be ordered, because it would take too long to add new things to a hash.

It's worth knowing about something in hashes called *autovivification*. That's a fancy term for this effect:

```raku
my %h;
say %h.elems;       # "0", of course
say %h<chocolate>;  # "`Any`", means there's nothing there
say %h.elems;       # "0", still
%h<chocolate>++;    # here is where the autoviv happens
say %h.elems;       # "1"
say %h.keys;        # "chocolate"
say %h.values;      # "1"
```

In many other languages, you get an error if you increment a hash entry that doesn't exist. In Raku, incrementing something that isn't there causes it to spring into existence. We'll often use that to our advantage.

I have to go; I believe that's Ada on the other line. See you tomorrow for... some other topic.
