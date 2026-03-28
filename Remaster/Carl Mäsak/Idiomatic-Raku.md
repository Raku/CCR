# Idiomatic Raku
    
*Originally published on [27 August 2010](http://strangelyconsistent.org/blog/idiomatic-perl-6) by Carl Mäsak.*

So, I wrote a program to generate [Pascal's triangle](https://en.wikipedia.org/wiki/Pascal). The first ten rows of the triangle, at least. It only used simple features of Raku, such as scalars, nested arrays, and `for` loops.

```raku
my $ELEMENTS = 10;
my @pascal = [1];
for 1 .. $ELEMENTS - 1 {
    my @last = @pascal[ * - 1 ].list;
    my @current;
    push @current, @last[0];
    for 0 .. @last - 2 {
        push @current, @last[$_] + @last[$_ + 1];
    }
    push @current, @last[ * - 1 ];
    push @pascal, [@current];
}
say @pascal.raku;
```

In fact, save for simple mechanically substitutable differences, it could have been a Perl script. In fact, with a bit of manual array allocation, it could have been a C script. That's OK; there's a tolerance in the Perl community of writing code that looks like it was thunk in some other language.

But I've heard that Raku is great at doing things with operators. For example, the `Z` operator, which interleaves two lists, seems to be able to help me write my `push` statements more succinctly:

```raku
my $ELEMENTS = 10;
my @pascal = [1];
for 1 .. $ELEMENTS - 1 {
    my @last = @pascal[ * - 1 ].list;
    my @current;
    **for (0, @last) Z (@last, 0) -> $left, $right {<br></br>
        push @current, $left + $right;<br></br>
    }** 
    push @pascal, [@current];
}
say @pascal.raku;
```

The parentheses before and after the `infix:<Z>` aren't necessary, because the `Z` operator has looser precedence than comma. They're just shown here to make your eyes accustomed to reading this construct.

In fact, now that only the addition is performed in the inner loop, I might as well use the `Z+` operator, which does this for me.

```raku
my $ELEMENTS = 10;
my @pascal = [1];
for 1 .. $ELEMENTS - 1 {
    my @last = @pascal[ * - 1 ].list;
    my @current **= 0, @last Z+ @last, 0;** 
    push @pascal, [@current];
}
```

Now as the remaining loop shrinks to a size I can take in all at once, I see a bit more clearly what I'm doing: I'm building each new list from the previous one. I could feed the previous list into a named function to get the current one:

```raku
my $ELEMENTS = 10;
my @pascal = [1];

sub next-list(@p) {
    [0, @p Z+ @p, 0]
}
for 1 .. $ELEMENTS - 1 {
    my @last = @pascal[ * - 1 ].list;
    my @current = next-list(@last);
    push @pascal, @current;
}
say @pascal.raku;
```

Or I could just feed it into a in-place anonymous sub.

```raku
my $ELEMENTS = 10;
my @pascal = [1];
for 1 .. $ELEMENTS - 1 {
    my @last = @pascal[ * - 1 ].list;
    push @pascal, (sub (@p) { [0, @p Z+ @p, 0] }).(@last);
}
say @pascal.raku;
```

But why even a sub? Raku has a lighter construct, namely a "pointy block" (also known as a "closure" or a "lambda"). It doesn't participate in the call stack, and it's slightly easier to write.

```raku
my $ELEMENTS = 10;
my @pascal = [1];
for 1 .. $ELEMENTS - 1 {
    my @last = @pascal[ * - 1 ].list;
    push @pascal, (-> @p { [0, @p Z+ @p, 0] }).(@last);
}
say @pascal.raku;
```

Let's look at what the code does. Seed with one element. Calculate the next element based on the previous one. Stop at some point.

But that's exactly what the series operator does. The one that's written with three dots. We have a starting value, a way to get from one value to the next (our code block above), and a stopping value.

Well actually, we don't have the stopping value. But that's OK, since the series operator is *lazy*. So if we only request the first 10 values, it won't loop forever giving us the rest of the list.

```raku
my @pascal := do [1], -> @p { [0, @p Z+ @p, 0] } ... *;
say @pascal[^10].raku;
```

(The extra `do` required because of a [shortcoming in Rakudo](https://github.com/Raku/old-issue-tracker/issues/2102).)

Now. Something very much like this code was posted first [on Rosetta code](https://rosettacode.org/wiki/Pascal's_triangle#Raku) and then [on Moritz' blog](https://perlgeek.de/blog-en/perl-6/pascal-triangle.html). (*TimToady* used a sub, but said later that he'd have preferred binding.)

A couple of Perl people's reactions were — somewhat uncharacteristically — of a negative flavour, similar to how people [seem to react](Raku-the-frankensteins-monster-of-operators.html) to the periodic table of operators:

> [@shadowcat_mst](https://x.com/shadowcat_mst/status/22112066276): an excellent example of why I consider camelia perl to be a language research project more than a production language


> @pedromelo: I'm seriously considering this post as an example of what I don't want Raku to become... 

I think these reactions are mainly feature shock. Higher-order operators, pointy blocks, and the series operator... they're all good, well-established features, which find daily use in Raku programs. Maybe using them all together like that flung some people off the deep end. Never mind that the resulting script is all [essential complexity](https://en.wikipedia.org/wiki/Essential_complexity), with virtually no boilerplate from the original script left.

This is the first time that's happened. I think it's important to listen to what Perl people think and to try to respond to that. But I also think that this time, it's a case of them seeing some highly idiomatic Raku, and freaking out a bit.

And I think that that, in some odd sense, is a good thing. Well, not freaking people out, per se. But the fact that we did shows that there's something forming which might be tentatively called "idiomatic Raku": people on the inside can read it quite easily, but those on the outside, even Perl folks looking in, instinctively go "eeeeew!".

That's OK. You're not meant to start with the idiomatic stuff. *Language acquisition takes place step by step*, and that goes for learning Raku as well. On the way there, just don't confuse distaste with lack of familiarity.
