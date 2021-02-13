# Lots of improvements coming in the Rakudo November release
    
*Originally published on [2012-11-07](https://6guts.wordpress.com/2012/11/08/lots-of-improvements-coming-in-the-rakudo-november-release/) by Jonathan Worthington.*

The November release is still a couple of weeks off, but it’s already looking like one of the most exciting ones in a while. Here’s a rundown of the major improvements you can expect.

### User Defined Operator Improvements

The way Rakudo handles parsing of user-defined operators has been almost completely reworked. The original implementation dated back quite a long way (we’re talking largely unchanged since probably 2010 or so), and as you might imagine, we’ve the tools to do a lot better now. The most significant change is that we now parse them using a lexically scoped derived language. This is done by mixing in to the current cursor’s grammar – something we couldn’t have done some years ago when NQP lacked roles! This means that the additions to the grammar don’t leak outside of the scope where the user-defined operators are defined – unless they are explicitly imported into another scope, of course.

```` raku
{
    sub postfix:<!>($n) { [*] 1..$n };
    say 10!; # 3628800
}
say 10!; # fails to parse
````

Before, things were rather more leaky and thus not to spec. Raku may allow lots of language extensibility, but the language design takes great care to limit its scope. Now Rakudo does much better here. As well as making things more correct, the nasty bug with pre-compilation of modules containing user defined operators is gone. And, last but not least, the precedence and associativity traits are now implemented, so user defined operators can pick their precedence level.

```` raku
sub infix:<multiplied-with>($a, $b) is equiv(&infix:<*>) {
    $a * $b
}
sub infix:<to-the-power>($a, $b) is equiv(&infix:<**>) {
    $a ** $b
}
say 2 multiplied-with 3 to-the-power 2;
````

### Quote Adverbs and Heredocs

The other thing that’s had a big do-over is quote parsing. This meant a lot of quoting related things that hadn’t been easy to attack before became very possible. So possible, in fact, that they’ve been done. Thus, we now support heredocs:

```` raku
say q:to/DRINKS/
    Yeti
    Leffe
    Tokyo
    DRINKS
````

This outputs:

````
Yeti
Leffe
Tokyo
````

Notice how it trims whitespace at the start of the string to the same level of degree of indentation as the end marker, so you can have heredocs indented to the same level your code is, if you wish. The :to syntax is an example of a quote adverb, and we now support those generally too. For example, a double-quoted string normally interpolates a bunch of different things: scalars, arrays, function calls, closures, etc. But what if you want a quoting construct that only interpolates scalars? You do something like:

```` raku
my $value = 42;
say Q:s'{ "value": $value }';
````

Alternatively, you could take a quoting construct that normally interpolates everything and just switch off the closure interpolation:

```` raku
my $value = 42;
say qq:!c'{ "value": $value }';
````

Last but not least, the shell words syntax now works. This lets you do quoting where things are broken up into a list by whitespace, but you can quote individual parts to prevent them
getting split, and also do interpolation.

```` raku
say << Hobgoblin 'Punk IPA' >>.raku; # ("Hobgoblin", "Punk IPA")
````

Sadly, I’ve got too bad a headache today to enjoy any of the listed beers. But hey, at least now you know some good ones to try… :-)

### Operator Adverbs

Well, weren’t these some fun to implement. STD has parsed them for a long while. You’d think that’d make it easy to steal from, but no. Before you can do that, you have to figure out that not only does it parse adverbs as if they were infixes, but then pushes them onto the op stack in the operator precedence parser and does a reduce such that they come out looking like postfixes, which in turn need an AST transform to turn the postfix inside-out so what was originally parsed as a fake infix becomes a named argument to the thing preceding it. I’m still not sure if this is beautiful or horrifying, but now it’s in place. This means we can at last handle the adverb-y syntax for doing things like hash key existence checks or deletion:

```` raku
my %h = a => 0;
say %h<a>:exists; # True
say %h<a>:delete; # 0
say %h<a>:exists; # False
````

### Macros

Recent work by *masak*++ has got macros to the point where they’re powerful enough to be potentially useful now. See [his blog post](http://strangelyconsistent.org/blog/macros-progress-report-d2-merged) for the sometimes-gory details, illustrated with exciting adventures involving wine barrels and questionably pluralized bits of Russian landscape. Really.

### NFA Precomputation

This is decidedly a guts change, but worth a mention because it’s probably the main performance improvement we’ll see in the November release: the transitive NFAs that are used by the parser are now computed at the time we compile the Raku grammar, not on-demand as we start parsing. They are then serialized, so at startup we just deserialize them and dig into the parsing. They’re not entirely cheap to construct, and so this saves a bit of work per invocation of the compiler. In the spectests, it made an almost 10% difference to the time they take to run (many test files are quite small, and we run over 700 test files, so reducing invocation overhead adds up).

By the way, if you’re confused on what these transitive NFAs are about, let me try and explain a little. In order to decide which of a bunch of protoregexes or which branch of an alternation to take, the declarative parts of a grammar are analyzed to build NFAs: state machines that can efficiently decide which branches are possible then rank them by token length. It’s not only important for a correct parse (to get longest token matching semantics correct), but also important algorithmically. If you look at the way Raku grammars work, the naive view is that it’s recursive descent. That makes it nice to write, but if it really was evaluated that way, you’d end up trying loads of paths that didn’t work out before hitting upon the correct one. The NFA is used to trim the set of possible paths through the grammar down to the ones that are actually worth following, and their construction is transitive, so that we can avoid following call chains several levels deep that would be fruitless. If you’ve ever used the debugger to explore a grammar, and wondered how we seem to magically jump to the correct alternative so often, well, now you know. :-)

### Other Things

There are a few other bits and pieces: `INIT` phasers now work as r-values, you can use the `FIRST` / `NEXT` / `LAST` phasers in all the looping constructs now (previously, they worked only in for loops), version control markers left behind in code are gracefully detected for what they are, and a bunch of proto subs in the setting have been given narrower signatures which makes various things you’d expect to work when passed to, say, map, actually do so.

Oh, and whatever else we manage to get around to in the next couple of weeks. :-)
