# Why I like having Tene on the team
    
*Originally published on [21 July 2009](http://strangelyconsistent.org/blog/why-i-like-having-tene-on-the-team) by Carl Mäsak.*

*eiro*++ asked me today why in [this piece of code](https://github.com/masak/web/blob/eede14b5520c6caa621bff329d1e84ee2935f7f0/bin/basic-demo.pl) in Web.pm, ``request`` is called on line 4, but `request($c)` is defined on line 6. (And it's not a `multi` or anything, so that's not it.)

I promised him I'd check it out, and I just did. In a few minutes, I found this in [HTTP::Daemon](https://github.com/masak/web/blob/eede14b5520c6caa621bff329d1e84ee2935f7f0/lib/HTTP/Daemon.pm#L213):

```raku
# hack until we can get real CALLER support
my %callerns := Q:PIR {{ $P0 = getinterp
                         %r = $P0['namespace';1] }};
# ...
%callerns<request>($c);
```

Whoa! There's a piece of `CALLER::` emulation in our copy of `HTTP::Daemon`. This is noteworthy for two reasons. Firstly, `CALLER::` isn't implemented in Rakudo Raku yet, so I thought some of the hard-core Rakudo hackers out there might like this tip. As you see, we're basically descending to PIR land and snatching the sacred information right from the claws of the interpreter. Use the trick wisely, Rakudo hackers.

Secondly, I think this is a good way to show how Tene (the one who added these lines to Web.pm, and the second remaining crew member of Web.pm) is, for lack of a less blunt way to say it, very handy to have around. He has a unique combination of Rakudo and Parrot knowhow, having delved into the internals of both quite a lot.

```
<masak> phenny: tell eiro if you look at the beginning and end of https://github.com/masak/web/commit/01cca04fcd75de86e90b4e17f25750866dfdd0b5 you will find that the request($c) is actually deliberate (and the nasty but cool hack used to make it work) *Tene*++
<phenny> masak: I'll pass that on when eiro is around.
<Tene> masak: what part of it is a nasty hack?
<Tene> (I don't remember)
<masak> Tene: the emulation of CALLER::
<masak> Tene: but it's not very nasty, mostly cool.
<Tene> ah
<masak> Tene: I'm thinking of writing a small blog post about it. someone might like the trick.
<pmichaud> (blog post)++
<masak> it would be called "Why I like having Tene on the team" or something. :)
<Tene> It's not that much of a trick.  That's what CALLER:: will end up being eventually.
<Tene> I just don't know enough about rakudo's lexical scoping stuff to know how to do CALLER:: right.
<masak> Tene: if you think using Q:PIR to emulate CALLER:: is not much of a trick, then you're way in deep, man. :)
```

Oh, and the mysterious parameterless call on line 4? Turns out that code was never reached, and is a remainder from earlier versions of `HTTP::Daemon`. I just pushed a patch that excises this dead code from the code examples in Web.pm.
