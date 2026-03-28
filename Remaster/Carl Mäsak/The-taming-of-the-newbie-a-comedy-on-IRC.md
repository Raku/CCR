# The taming of the newbie - a comedy on IRC
    
*Originally published on [19 January 2010](http://strangelyconsistent.org/blog/the-taming-of-the-newbie-a-comedy-on-irc) by Carl Mäsak.*

The other day, I remembered this old piece of #raku [backlog](https://irclogs.raku.org/perl6/2005-09-07.html#19:46) from 2005:

```
<masak> question: what are good ways in p5 and p6 respectively, to reverse a string?
<masak> the easiest way i found in p5 was join '', reverse split // $string
<masak> doesn't look very nice, now does it?
<integral> *blink*
<integral> $string = reverse $string
```

It feels odd to realize this five years later, but it seems that in 2005 I didn't have a firm grip on how `reverse` worked in Perl. Chances are, dearest reader, that you do. But if not, the rest of the refreshingly frank discussion will explain it.

Meanwhile, five years earlier, I persist in my innocent ignorance:

```
<masak> nope
<masak> doesn't work :(
<masak> reverse only reverses lists... i think
```

Reading this from the perspective of five years' work with Perl and 6 is... enlightening, in a slightly cathartic way. Sure, it *could* have been that I'm the first to discover that `reverse` in Perl doesn't in fact reverse strings, despite *thousands* of people using it daily for that purpose. But the chances of that are astronomically small. My peers on the channel tell me this.

```
<PerlJam> masak: clearly you are insane.
<integral> perl -le '$string = "abc"; $string = reverse $string; print $string'
<integral> masak: [and the faq](http://perldoc.perl.org/functions/reverse.html'>the manual *clearly* explains</a> all the stuff about context
<integral> <a href='http://perldoc.perl.org/perlfaq4.html#How-do-I-reverse-a-string%3F) `
```

They do, you know.

```
<PerlJam> masak: in raku it would be $string.=reverse probably.
```

This was true in 2005, but nowadays we have `flip` for strings, `reverse` for lists, and `invert` for hashes. The need for different functions falls out naturally from the fact that Raku doesn't depend as heavily on context as Perl does.

Back in the log, I'm still trying to reintegrate into reality.

```
<masak> integral: your example worked, thx
<masak> but nothing worked for me
<masak> apparently i am insane :P
```

PerlJam and integral are one step ahead of me.

```
<integral> no, you don't understand scalar context.  perl -le 'print scalar reverse shift' foobar
<PerlJam> masak: you were probably saying "print reverse $string"
<masak> no, but maybe something of the sort
<masak> and that doesn't work, because...?
<integral> masak: print's prototype is (@), ie list context.  It's a rightwards named list operator
<PerlJam> masak: context.
* masak thinks he sees it now
```

These explanations are actually very good, but just in case, let me restate them in my own words: `reverse` has two main behaviours. Either it reverses a list of things, or it reverses a string of characters. It switches between these two behaviours based on *something*. You might think that this something is what type of thing you send in (a scalar or a list), but that isn't so. Instead, `reverse` responds to its surroundings and figure out what they expect. `$string = reverse $string` is a scalar assignment, and expects a scalar. `print reverse $string`, as integral explains, puts `reverse` in list context, so it reverses the list of one thing (`$string`), i.e. doing nothing.

Steve Yegge has this to say, in a vitriolic [critique of Perl](https://sites.google.com/site/steveyegge2/ancient-languages-perl):

> Perl also has "contexts", which means that you can't trust a single line of Perl code that you ever read.

I would say that it's actually not that bad, and the idea of context can be unintuitive at times, in many cases it's actually very natural and useful. `reverse`, in my humble opinion, is not one of those cases. I'm glad it's split up into different methods in Raku.

At the end, we learn that I had actually Read The Faithful Manual already, I just hadn't read it *carefully*:

```
<PerlJam> masak: perldoc -f reverse
<masak> thx, integral and PerlJam
<masak> PerlJam: I read the perldoc entry but apparently not carefully enough
* masak reads it again
<masak> ah
<masak> "In scalar context, concatenates the elements of LIST and returns a string value with all characters in the opposite order."
<masak> this somehow went past me as something i didn't want :/
```

In summary, I mostly wrote this blog post because I like to make myself squirm. 哈哈

But I guess there's also a moral to it all. We all start somewhere, and in a way it's reassuring to find five-year old proof of this fact. A newbie is just on a part of the learning curve you've already visited; they haven't had a chance to tweak their keyboard and developing environment to maximum efficiency yet, and they sometimes forget that the manual is there, or misread it in some way. So, don't hesitate to be be kind to them, and help them connect to the goodness that is [perldoc](https://perldoc.perl.org/), [PerlMonks](https://www.perlmonks.org/) and Planet Iron Man so that they can grow and bloom into experienced wielders of Perl.

But don't hesitate to call them insane, either, when the situation calls for it.
