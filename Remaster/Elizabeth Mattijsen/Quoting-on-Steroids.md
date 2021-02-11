# Quoting on Steroids
    
*Originally published on [16 December 2014](https://perl6advent.wordpress.com/2014/12/16/quoting-on-steroids/) by Elizabeth Mattijsen.*

A few days ago, there was a blog post about [String Interpolation](String-Interpolation-and-the-Zen-Slice.md).  Most of the examples there used a simple double quoted string.

```` raku
my $a = 42;
say "a = $a";   # a = 42
````

The possibilities of the double quoted string are quite powerful already.  But in the end, they’re just a special case of a much more generic and malleable quoting construct, named `Q`.

### Q’s Basic Features

In its most generic form, `Q` just copies the string without any changes or interpretation:

```` raku
my $a = 42;
say Q/foo $a \n/;  # foo $a \n
````

You can add adverbs to `Q[…]`, to change the way the resulting string will be formatted.  For instance, if you want to have interpolation of scalars, you can add `:s`.  If you want interpretation of backslashes like `\n`, you can add `:b`.  And you can combine them:

```` raku
my $a = 42;
say Q:s/foo $a\n/;      # foo 42\n
say Q:b/foo $a\n/;      # foo $a␤
say Q:s:b/foo $a\n/;  # foo 42␤
````

(If you wonder what a `␤` is, it is a *U+2424 SYMBOL FOR NEWLINE [So] (␤)* and should be show up in your browser as a character containing an **N** and an **L** as a visible representation of a new line character)

In fact, the list of adverbs of basic features is:

```` raku

    short       long            what does it do
    =====       ====            ===============
    :q          :single         Interpolate \\, \q and \' (or whatever)
    :s          :scalar         Interpolate $ vars
    :a          :array          Interpolate @ vars
    :h          :hash           Interpolate % vars
    :f          :function       Interpolate & calls
    :c          :closure        Interpolate {...} expressions
    :b          :backslash      Interpolate \n, \t, etc. (implies :q at least)

````

The `:q` (`:single`) basically gives you single quoted string semantics.  The other adverbs, give you typically the functionality that you would expect from double quoted strings. If you *really* want to be verbose on your double quoted strings, you can write them like this:

```` raku
  my $a = 42;
  say Q :scalar :array :hash :function :closure :backslash /foo $a\n/;  # foo 42␤
````

Of course, you can also specify the short versions of the adverbs, and not separate them by whitespace.  So, if you want to be less verbose:

```` raku
  my $a = 42;
  say Q:s:a:h:f:c:b/foo $a\n/;  # foo 42␤
````

As with any adverbs (which are just named arguments, really), the order does not matter:

```` raku
  my $a = 42;
  say Q:f:s:b:a:c:h/foo $a\n/;  # foo 42␤
````

Actually, the story about the order of the named arguments is a little bit more complicated than this.  But for this set of adverbs, it does not matter in which order they are specified.

*.oO( is that a brother of Johann Sebastian? )*

But seriously, that is still a mouthful.  So an even shorter shortcut is provided: `:qq`

| short | long    | what does it do                         |
| :---- | :------ | :-------------------------------------- |
| :qq   | :double | Interpolate with :s, :a, :h, :f, :c, :b |

So, you can:

```` raku
my $a = 42;
say Q:double/foo $a\n/;  # foo 42␤
say Q:qq/foo $a\n/;      # foo 42␤
````

All that for simply doing a double quoted string with interpolation?  Well, because people are using double quoted strings a lot, the simple `"` remains the quickest way of interpolating values into a string.  However, underneath that all, it’s really `Q:qq`, which in turn is really `Q:s:a:h:f:c:b`.

What about a double quoted string that has double quotes in it?  For those cases, the `Q:qq* form is available, but that is still quite verbose.  Synopsis 2 therefore specifies:

> In fact, all quote-like forms derive from `Q` with adverbs:
```` raku
 q//         Q:q//
qq//        Q:qq//
````

Which means we can shorten the `Q:qq` in that last example to `qq` (and have double quotes in the double quoted string without any problems):

```` raku
my $a = 42;
say qq/foo "$a"\n/;      # foo "42"␤
````

Both `q//` and `qq//` also support (the same) adverbs.  This initially seems the most useful with `q//`, for instance in combination with `:s`, which would (also) interpolate scalars:

```` raku
my $a = 42;
say q:s/foo "$a"\n/;      # foo "42"\n
````

However, adverbs (just as named arguments) are just a shortcut for a `Pair`: `:s` is really `s => True`.  And `:!s` is really just `s => False`.  Can we also apply this to quoting constructs?  The answer is: yes, you can!

```` raku
say qq:!s:!c/foo "$x{$y}"\n/;      # foo "$x{$y}"␤
````

Even though we specified `qq//`, the scalar is **not** interpolated, because of the `:!s` adverb.  And the scope is not interpolated, because of the `:!c`.  This can for instance be handy when building strings to be *EVAL*led.  So, if you want all quoting features **except** one or more, you can easily de-activate that feature by negating those adverbs.

### Some of Q’s Advanced Features

Quoting features do not stop here.  This is a list of some of the other features that already work in Rakudo Raku:

| short | long        | what does it do                               |
| :---- | :---------- | :-------------------------------------------- |
| :x    | :exec       | Execute as command and return results         |
| :w    | :words      | Split result on words (no quote protection)   |
| :ww   | :quotewords | Split result on words (with quote protection) |
| :to   | :heredoc    | Parse result as heredoc terminator            |

Here are some examples.  Note that we don’t bother specifying these features as attributes, because they’re basically the first additional attribute, so there is a shortcut version for them.  For example, `qq:x//` can be shortened to `qqx//`.  Whether you could consider that more readable or not, I leave up to the reader.  There is, after all, more than one way to do it.

Interpolate and execute as an external program:

```` raku
my $w = 'World';
say qqx/echo Hello $w/;   # Hello World
````

Interpolate as single quoted words (please look at what happens to the single quotes):

```` raku
.say for qw/ foo bar 'first second' /;
==
foo
bar
'first
second'
````

Interpolate as single quoted words with *quote protection*.  This will make sure that balanced quotes will be treated as one entity (and note again what happened to the single quotes).

```` raku
.say for qww/ foo bar 'first second' /;
==
foo
bar
first second
````

Interpolate variables into a heredoc:

```` raku
my $a = 'world';
say qqto/FOO/;
    Hello $a
    FOO
==
Hello world␤
````
The text is exdented automatically for the same number of indents as the target has.

### Conclusion

Raku has a very powerful basic quoting construct in `Q[…]`, from which all other quoting constructs are derived.  They allow mix and matching of features in various short and more verbose ways.  There are still some adverbs unimplemented, but the ones that are mentioned here, should Just Work™.

Finally, the Synopsis also indicates that there will be a way out of this alphabet soup:

> If you want to abbreviate further, just define a macro:
```` raku
macro qx { 'qq:x ' }          # equivalent to Perl's qx//
macro qTO { 'qq:x:w:to ' }    # qq:x:w:to//
macro quote:<❰ ❱> ($text) { quasi { {{{$text}}}.quoteharder } }
````

We can only hope that someone will find enough quality tuits soon to implement this.

