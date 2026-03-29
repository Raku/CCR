# Parsing indented text
    
*Originally published on [23 March 2014](http://strangelyconsistent.org/blog/parsing-indented-text) by Carl Mäsak.*

"How can I parse indented text with a grammar?" has turned into a frequently-asked question recently. People want to parse Python and CoffeScript.

My fix is double. First, here's [Text::Indented](https://github.com/masak/text-indented), a module that does it.

Secondly, I'll now recreate my steps in creating this module. Each section will have a description of what needs to be done, a failing test, and then the appropriate implementation code to pass the test.

## Quite a simple indent

We want to be able to [handle indentation *at all*](https://github.com/masak/text-indented/commit/08bfb4fd42113774a635da81074728a2afcca2c4).

```raku
my $input = q:to/EOF/;
Level 1
    Level 2
EOF
parses_correctly($input, 'single indent');
```

Well, that's easy. This grammar will do that:

```raku
regex TOP { .* }
```

([Kent Beck](https://www.amazon.com/Test-Driven-Development-By-Example/dp/0321146530) told me I can cheat, so I cheat!)

## Too much indent for our own good

But there are some indent jumps that we're not allowed to make. Anything that indents more than one step at a time, basically. [Let's check for that](https://github.com/masak/text-indented/commit/a1609e603dd5062c3a93e6d5d8219c82b533d8ab).

```raku
my $input = q:to/EOF/;
Level 1
        Level 3!
EOF
fails_with($input, Text::Indented::TooMuchIndent);
```

This takes a little more code to fix. We declare an exception, start parsing lines, and separate each line into indent, extra whitespace, and the rest of the line. Finally we check the line's indent against the current indent &mdash; mediated by the contextual variable `@*SUITES`. You'll see where I'm going with this in a minute.

```raku
class TooMuchIndent is Exception {}
constant TABSTOP = 4;
regex TOP {
    :my @*SUITES = "root";
    <line>*
}
sub indent { @*SUITES.end }
regex line {
    ^^ (<{ "\\x20" x TABSTOP }>*) (\h*) (\N*) $$ \n?
    {
        my $new_indent = $0.chars div TABSTOP;
        die TooMuchIndent.new
            if $new_indent > `indent` + 1;
    }
}
```

(The `<{ "\\x20" x TABSTOP }>` is a bit of a workaround. In Wonderful Raku we would be able to write just `[\x20 ** {TABSTOP}]`.)

## Actual content

Having laid the groundworks, let's get our hands dirty. We want the content to end up, line by line, [on the right scoping level](https://github.com/masak/text-indented/commit/b3e390b16ea5ef09fb2e0ba0c1eaabdf8f312c81).

```raku
my $input = q:to/EOF/;
Level 1
    Level 2
EOF
my $root = parse($input);
isa_ok $root, Text::Indented::Suite;
is $root.items.elems, 2, 'two things were parsed:';
isa_ok $root.items[0], Str, 'a string';
isa_ok $root.items[1], Text::Indented::Suite, 'and a suite';
```

We need a `Suite` (term borrowed from Python) to contain the indented lines:

```raku
class Suite {
    has @.items;
}
```

This requires a slight amending of `TOP`:

```raku
regex TOP {
    :my @*SUITES = Suite.new;
    <line>*
    { make root_suite }
}
```

The logic in `line` to create new suites with new indents:

```raku
# ^^ (<{ "\\x20" x TABSTOP }>*) (\h*) (\N*) $$ \n?
my $line = ~$2;
if $new_indent > `indent` {
    my $new_suite = Suite.new;
    add_to_current_suite($new_suite);
    increase_indent($new_suite);
}
add_to_current_suite($line);
```

For all this, I had to define some convenience routines:

```raku
sub root_suite { @*SUITES[0] }
sub current_suite { @*SUITES[indent] }
sub add_to_current_suite($item) { current_suite.items.push($item) }
sub increase_indent($new_suite) { @*SUITES.push($new_suite) }
```

## But what about de-indenting?

We've handled indenting and creating new suites nicely, but [what about de-indenting](https://github.com/masak/text-indented/commit/3f9b71b7a8f4c0f35cc1f0c97d4bad898bcaa227)?

```raku
my $input = q:to/EOF/;
Level 1
    Level 2
Level 1 again
EOF
my $root = parse($input);
is $root.items.elems, 3, 'three things were parsed:';
isa_ok $root.items[0], Str, 'a string';
isa_ok $root.items[1], Text::Indented::Suite, 'a suite';
isa_ok $root.items[2], Str, 'and a string';
```

Easily fixed with an `elsif` case in our `line` regex:

```raku
elsif $new_indent < `indent` {
     decrease_indent;
}
```

And a convenience routine:

```raku
sub decrease_indent { pop @*SUITES }
```

## Hah, you missed multi-step de-indents!

Indenting multiple steps at a time isn't allowed... but [de-indenting multiple steps](https://github.com/masak/text-indented/commit/4ee499aace9b6110c3dce23bcbb43708b7ddad87) is. (This may actually be the strongest point of this kind of syntax. It corresponds to the `} } }` or `end end end` case of languages with explicit block delimiters, and is arguably neater.)

```raku
my $input = q:to/EOF/;
Level 1
    Level 2
        Level 3
        Level 3
Level 1 again
EOF
my $root = parse($input);
is $root.items.elems, 3, 'three things on the top level';
is $root.items[1].items[1].items.elems, 2, 'two lines on indent level 3';
```

Oh, but we only need to change one line in the implementation to support this:

```raku
decrease_indent until `indent` == $new_indent;
```

## And a half!

Now for some random sins. You're not supposed to [indent partially](https://github.com/masak/text-indented/commit/243291ba31e2a77b89bd47c33aadc14cd0dd8366), a non-multiple of the indent size.

```raku
my $input = q:to/EOF/;
Level 1
      Level 2 and a half!
EOF
fails_with($input, Text::Indented::PartialIndent);
```

So we introduce a new exception.

```raku
class PartialIndent is Exception {}
```

And a condition that checks for this:

```raku
# ^^ (<{ "\\x20" x TABSTOP }>*) (\h*) (\N*) $$ \n?
my $partial_indent = ~$1;
die PartialIndent.new
    if $partial_indent;
```

## What do you mean, "jumped the gun"?

Secondly, [you're not meant to indent the first line](https://github.com/masak/text-indented/commit/8b21fc63b18707b3f2bf1b7700b325cf7607df80); it has to be at indentation level 0.

```raku
my $input = q:to/EOF/;
    Level 2 already on the first line!
EOF
fails_with($input, Text::Indented::InitialIndent);
```

We introduce another exception for that.

```raku
class InitialIndent is Exception {}
```

And a condition that matches our test case.

```raku
die InitialIndent.new
    if !root_suite.items && $new_indent > 0;
```

## The importance of `handles```

As a final clean-up refactor, [let's change `@.items` in `Suite`](https://github.com/masak/text-indented/commit/71e81bfb082d1afc88c32a51763f25c430167da7) to this:

```raku
class Suite {
    has @.items handles <push at_pos Numeric Bool>;
}
```

It makes `Suite` more `Array`-like. Piece by piece:

- `push` allows us to push directly into a `Suite` object, instead of into its `.items` attribute.
- `at_pos` allows us to index `Suites` directly. Things like `$root.items[1]` in the tests turn into `$root[1]`.
- `Numeric` gets rid of the `.elems` calls for us in the tests, and we can write `$root.items.elems` as just `+$root` instead.
- Finally, `Bool` allows us to write `!root_suite.items` as just `!`root_suite``.

Somehow I liked doing this refactor last, after all the dust around the implementation had settled. It makes the API much more enjoyable to use, and hides a bunch of unnecessary steps along the way. I really like the way `handles` saves a bunch of boring code.

## Enjoy

Anyway, that's parsing of indented code. Not as tricky as I thought.

Now I fear I've damned myself to contribute this solution to [*arnsholt*++'s budding py3k implementation](https://github.com/arnsholt/snake/). 哈哈
