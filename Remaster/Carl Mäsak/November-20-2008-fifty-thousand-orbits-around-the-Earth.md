# November 20, 2008 — fifty thousand orbits around the Earth
    
*Originally published on [21 November 2008](http://strangelyconsistent.org/blog/november-20-2008-fifty-thousand-orbits-around-the-earth) by Carl Mäsak.*

Ten years ago today, the first module of the [International Space Station](https://en.wikipedia.org/wiki/International_Space_Station) (ISS) was launched. Its name, Zarya (Заря), means "dawn" in Russian. [Wikipedia](https://en.wikipedia.org/wiki/Zarya):

> Although only designed to fly autonomously for six to eight months, Zarya was required to fly autonomously for almost two years due to delays to the Russian Service Module, Zvezda. Finally, on July 12, 2000, Zvezda was launched and docked on July 26 using the Russian Kurs system.

> Zarya initially had problems with battery charging circuits, but these were resolved. It will eventually require supplemental micro meteor shielding, as it was given an exemption to the ISS rules when it launched.

> Zarya passed the 50,000-orbit mark at 15:17 UTC. on August 14, 2007, during the STS-118 mission to the International Space Station.

I was going to write today about all the branches we're working on nowadays, but I got so involved in doing markup parsing and (because of that) finding Rakudo bugs, so I'll have to write about that instead.

Having realised that the first letter in MediaWiki links is automatically upcased, I needed to do something about the link-producing closure that I sent along to the formatting routine. It looked like this:

```raku
my $link_maker = { "<a href=\"/?page=$^page\">$^page</a>" }
```

Nice, huh? Might be even nicer once we get better quoting constructs.

(For those who haven't buried their noses in the Raku specifications, that `$^page` variable is called a *placeholder parameter*, a positional parameter that you don't have to declare in your routine, but which sort of "declares itself" when you mention it the first time. Think of them as the sane version of the special variables `$a` and `$b` in `sort` blocks.)

So the above line creates a closure that expects one parameter and returns strings: if I call the closure like this: `$link_maker('main_page')`, I get `'[main_page](?page=main_page)'` back. The closure is a machine that makes links.

But I needed to tweak the machine; I needed to upcase the first letter in the link. So I came up with this, which seemed reasonable:

```raku
my $link_maker = { "<a href=\"/?page={$^page.ucfirst}\">$^page</a>" }
```

(Ah, that new `ucfirst` function *is* handy at times.)

I should note here that in Raku.0.0, I shouldn't have to use the curlies, because method calls are handled just as well as variables. (I'd have to end with `()` though. But Rakudo isn't Raku.0.0-compatible, not yet. Getting there. So I did it with closure curlies instead.

And that's why it didn't work. I got this error:

```
too few arguments passed (0) - 1 params expected
```

Can you guess why? What's getting zero arguments here instead of the one it expected?

That's right, my new closure. It's almost too obvious in retrospect. The `$^page` in the closure is not the same variable reference as the `$^page` outside. Why? Well, because each closure has its own right to placeholder params. Note that there's no way to *pass* such params to a closure in a string, but at least we're consistent!

I turned to [#raku](https://irclogs.raku.org/perl6/2008-11-20.html#22:01), and then to [p6l](https://www.nntp.perl.org/group/perl.perl6.language/2008/11/msg29931.html), asking whether we prefer DWIM or consistency in this case. It was just a while ago, so the jury is still out.

In the meantime, I have to write this:

```raku
my $link_maker = { my $l = $^page.ucfirst; "<a href=\"/?page=$l\">$^page</a>" }
```

That was today's bedtime story. I found another bug too, I think, but I haven't boiled it down to its essentials yet. It occurs when, in my [second link test](https://github.com/viklund/november/tree/mediawiki-markup/p6w%2Ft%2Fmarkup%2Fmediawiki%2F06-links.t), I *don't* pass in the link maker as a named argument, but the formatter goes on and uses a link maker anyway. (How does it *do* that?) I'll know more tomorrow.
