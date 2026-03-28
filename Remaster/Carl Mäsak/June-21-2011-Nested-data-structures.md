# June 21 2011: Nested data structures
    
*Originally published on [28 June 2011](http://strangelyconsistent.org/blog/june-21-2011-nested-data-structures) by Carl Mäsak.*

We've seen scalars (single values), arrays, and hashes. Is there anything beyond that?

There is indeed. The simplest variation on the theme is that we can put arrays and hashes in a scalar variable:

```raku
my $names = [ "Huey", "Dewey", "Louie" ];
say $names[1];       # "Dewey"
my %words = { book => "書", fish => "魚", door => "門" };
say %words{"book"};  # "書"
```

You'll note that when we're using the dollar (`$`) sigil to denote scalar variables, we instead have to indicate that the value we're storing is an array (`[ ... ]`) or a hash (`{ ... }`). By an astonishing coincidence &mdash; which of course isn't a coincidence &mdash; these are the same symbols that are used for indexing arrays and hashes, respectively.

(Well, actually... there are two ways of writing hash indexings, as you might recall from [the post about hashes](June-17-2011-hashes.html). `%words{"book"}` is the general one, the one where you can write any expression you want within the indexing curly braces. When we're dealing with literal strings, it's easier to write it as `%words<book>`. Only the curly braces (`{ ... }`) can be used for creating hashes; the pointy brackets (`< ... >`) are used for creating lists of literal strings. Thus, `<liberty equality fraternity>` is a list of three literal strings, and we didn't have to surround them by quotes and separate them by commas because we used the pointy brackets.)

"Ok,' I hear you saying. "I needed a new, different way to create arrays and hashes like I needed a hole in the head." Well, astute reader, that's a fair observation. But now let me unveil this thing, and...

...and voilà!

```raku
my @unit_matrix =
    [ 1, 0, 0 ],
    [ 0, 1, 0 ],
    [ 0, 0, 1 ],
;
say @unit_matrix.elems;     # "3"
say @unit_matrix[0].elems;  # "3"
```

The new notation allows us to put arrays in arrays! Hence "nested" in the title of this post. Nesting, when it's not about birds, is about fitting one thing within another (similar) thing. Like boxes, or matryoshka dolls.

Just to be clear about what's happening: `@unit_matrix` is an array variable containing three elements. Each of these elements is another array containing three elements. The two 3s we're printing are answers to different questions: the first one how many "rows" there are in `@unit_matrix`; the second one how many "columns" there are in the first row.

So there are two levels: the outer array and the inner arrays it contains. Just as we would use a `for` loop for going through a regular array, we can use *two* `for` loops to go through an array of arrays:

```raku
for @unit_matrix -> @row {
    for @row -> $element {
        say $element;    # will print 9 lines in all
    }
}
```

And why stop at two levels? We can nest as many arrays as we care to inside each other. There's no magic limit where we suddenly cannot nest anymore. We can build the data structures as deep and intricate as the application calls for.

Oh, and the nesting works equally for hashes as well:

```raku
my %directories =
    "/" => {
        "usr" => {
            "local" => {},
        },
        "home" => {
            "cinderella" => {},
            "santa"      => {},
            "gretl"      => {},
        },
    },
;
say %directories.keys;          # "1" (just the root)
say %directories</><home>.keys; # "3" (users)
```

And it doesn't stop there, either. You can have

- arrays of hashes
- hashes of arrays
- arrays of arrays of hashes of arrays
- hashes of hashes of...

You get the picture. We can build any structure we want.

*This* is what I've been waiting to tell you. As your Perl-fu matures, you'll start to appreciate just how much this nesting of data structures is just what you need to model almost anything.

Your brain will need ever shorter time to go from problem specification ("How do I store my friends' bowling scores?") to nested data structure ("Oh! That's just a hash of arrays!"). And you'll be a better programmer and a more harmonious human being for it.

You're welcome. ;-)
