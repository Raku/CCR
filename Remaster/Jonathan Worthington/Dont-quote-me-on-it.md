# Don’t quote me on it…
    
*Originally published on [10 December 2012](https://perl6advent.wordpress.com/2012/12/10/day-10-dont-quote-me-on-it/) by Jonathan Worthington.*

In many areas, Raku provides you with a range of sane defaults for the common cases along with the power to do something a little more interesting when you need it. Quoting is no exception.

### The Basics

The two most common quoting constructs are the single and double quotes. Single quotes are simplest: they let you quote a string and just about the only “magic” they provide is being able to stick a backslash before a single quote, which escapes it. Since backslash has this special meaning, you can write an explicit backslash with \\. However, you don’t even need to do that, since any other backslashes just pass on straight through. Here’s some examples.

```` raku
> say 'Everybody loves Magical Trevor'
Everybody loves Magical Trevor
> say 'Oh wow, it\'s backslashed!'
Oh wow, it's backslashed!
> say 'You can include a \\ like this'
You can include a \ like this
> say 'Nothing like \n is available'
Nothing like \n is available
> say 'And a \ on its own is no problem'
And a \ on its own is no problem
````

Double quotes are, naturally, twice as powerful. :-) They support a range of backslash escapes, but more importantly they allow for interpolation. This means that variables and closures can be placed within them, saving you from having to use the concatenation operator or other string formatting constructs so often. Here are some simple examples.

```` raku
> say "Ooh look!\nLine breaks!"
Ooh look!
Line breaks!
> my $who = 'Ninochka'; say "Hello, dear $who"
Hello, dear Ninochka
> say "Hello, { prompt 'Enter your name: ' }!"
Enter your name: *Jonathan*
Hello, Jonathan!
````

The second example shows the interpolation of a scalar, and the third shows how closures can be placed inside double quoted strings also. The value the closure produces will be stringified and interpolated into the string. But what about all the other sigils besides `$”? The rule is that you can interpolate all of them, but only if they are followed by some kind of postcircumfix (that is, an array or hash subscript, parentheses to make an invocation, or a method call). In fact, you can put all of these on a scalar too.

```` raku
> my @beer = <Chimay Hobgoblin Yeti>;
Chimay Hobgoblin Yeti
> say "First up, a @beer[0]"
First up, a Chimay
> say "Then @beer[1,2].join(' and ')!"
Then Hobgoblin and Yeti!
> say "Tu je &prompt('Ktore pivo chces? ')"
Ktore pivo chces? *Starobrno*
Tu je Starobrno
````

Here you can see interpolation of an array element, a slice that we then call a method on and even a function call. The postcircumfix rule happily means that we don’t go screwing up your email address any more.

```` raku
> say "Please spam me at blackhole@jnthn.net"
Please spam me at blackhole@jnthn.net
````

### Choose Your Own Delimiters

The single and double quotes are suitable for a bunch of cases, but what if you want to use a bunch of single or double quotes inside the string? Escaping them would rather suck. Thing is, you could probably make that argument about any choice of quoting characters. So instead of making the choice for you, Raku lets you pick. The `q` and `qq` quote constructs expect to be followed by a delimiter. If it’s something with a matching closer, it will look for that (for example, if you use an opening curly then your string is terminated by a closing curly; note that there’s only a finite set of these, and no, it doesn’t include having a comet be terminated by a snowman). Otherwise it looks for the same thing to terminate the string. Note you can also use multi-character openers and closers too (but only by repeating the same character). Otherwise, the `q` gives you the same semantics as single quotes, and `qq` gives you the same semantics as double quotes.

```` raku
> say q{C'est la vie}
C'est la vie
> say q{{Unmatched } and { are { OK } in { here}}
Unmatched } and { are { OK } in { here
> say qq!Lottery results: {(1..49).roll(6).sort}!
Lottery results: 12 13 26 34 36 46
````

### Heredocs

All of the quoting constructs demonstrated so far allow you to include multiple lines of content. However, for that there’s usually a better way: here documents. There can be started with either `q` or `qq`, and then with the `:to` adverb being used to specify the string we expect to find, on a line of its own, at the end of the quoted text. Let’s see how this works, illustrated by a touching story.

```` raku
print q:to/THE END/
    Once upon a time, there was a pub. The pub had
    lots of awesome beer. One day, a Perl workshop
    was held near to the pub. The hackers drank
    the pub dry. The pub owner could finally afford
    a vacation.
    THE END
````

The output of this script is as follows:

````
Once upon a time, there was a pub. The pub had
lots of awesome beer. One day, a Perl workshop
was held near to the pub. The hackers drank
the pub dry. The pub owner could finally afford
a vacation.
````

Notice how the text is not indented like in the program source. Heredocs remove indentation automatically, up to the indentation level of the terminator. If we’d used `qq`, we could have interpolated things into the heredoc. Note that this is all implemented by using the indent method on strings, but if your string doesn’t do any interpolation we do the call to indent at compile time as an optimization.

You can also have multiple heredocs, and even call methods on the data that will be located in the heredoc (note the call to lines in the following program).

```` raku
my ($input, @searches) = q:to/INPUT/, q:to/SEARCHES/.lines;
    Once upon a time, there was a pub. The pub had
    lots of awesome beer. One day, a Perl workshop
    was held near to the pub. The hackers drank
    the pub dry. The pub owner could finally afford
    a vacation.
    INPUT
    beer
    masak
    vacation
    whisky
    SEARCHES

for @searches -> $s {
    say $input ~~ /$s/
        ?? "Found $s"
        !! "Didn't find $s";
}
````

The output of this program is:

````
Found beer
Didn't find masak
Found vacation
Didn't find whisky
````

### Quote Adverbs for Custom Quoting Constructs

The single and double quote semantics, also available through `q` and `qq`, cover most cases. But what if you have a situation where you want to, say, interpolate closures but not scalars? This is where quote adverbs come in. They allow you to turn certain quoting features on and off. Here’s an example.

```` raku
> say qq:!s"It costs $10 to {<eat nom>.pick} here."
It costs $10 to eat here.
````

Here, we use the semantics of `qq`, but then turn off scalar interpolation. This means we can write the price without worrying about it trying to interpolate the 11th capture of the last regex. Note that this is just using the standard colonpair syntax. If you want to start from a quote construct that supports basically nothing, and then just turn on some options, you can use the `Q` construct.

```` raku
> say Q{$*OS\n&sin(3)}
$*OS\n&sin(3)
> say Q:s{$*OS\n&sin(3)}
MSWin32\n&sin(3)
> say Q:s:b{$*OS\n&sin(3)}
MSWin32
&sin(3)
> say Q:s:b:f{$*OS\n&sin(3)}
MSWin32
0.141120008059867
````

Here we start with a featureless quoting construct, then turn on extra features: first scalar interpolation, then backslash escapes, then function interpolation. Note that we could have chosen any delimiter we wished too.

### Quote Constructs are Languages

Finally, it’s worth mentioning that when the parser enters a quoting construct, really it is switching to parsing a different language. When we build up quoting constructs from adverbs, really this is just mixing extra roles into the base quoting language to turn on extra features. For the curious, here’s [how Rakudo does it](https://github.com/rakudo/rakudo/blob/a8d2cc29320344a3e693df3df88dbba43eb84eec/src/Perl6/Grammar.pm#L3237). Whenever we hit a closure or some other interpolation, the language is temporarily switched back to the main language. This is why you can do things like:

```` raku
> say "Hello, { prompt "Enter your name: " }!"
Enter your name: Jonathan
Hello, Jonathan!
````

And the parser doesn’t get terribly confused about the fact that the closure being interpolated contains another double quoted string. That is, we’re parsing the main language, then slip into a quoting language, then recurse into the main language again, and finally recurse into the quoting language again to parse the string in the closure in the string in the program. It’s like the Raku parser wants to give us all matryoshka dolls for Christmas. :-)
