# My Raku Hacking
    
*Originally published on [6 January 2008](https://use-perl.github.io/user/JonathanWorthington/journal/35309/) by Jonathan Worthington.*

These days I'm doing some hacking on the Parrot on Raku compiler. While I could write about this on the blog on my site, I figure it's probably of interest to people here and will reach more interested parties if I write it here. So, from now I'll try and blog about what I do on the Raku compiler on use perl. Not that Patrick doesn't do an awesome job of sumarising what other people are doing, but here I can give a little more detail. It will also give you another person's perspective on working on the Raku implementation.

The Big Thing I've been hacking on is junctions. They aren't really a dependency for much else, and not really a priority either, but I'd agreed (while not completely sober, and I think in front of *Larry* too) to implement them in the Raku on Parrot compiler while I was at OSCON. So not wanting to break a promise or look too chicken to implement them, I had a crack. I'm not all of the way there yet - far from it - but here's what I've done. You can construct junctions use the operator or function forms and call `.values` and `.pick` on them (but I believe `pick` is very broken because I didn't understand what it was meant to do and implemented it wrong; I'm waiting for a final answer from @Larry on what the Right Thing is, and I'll do it correctly once I have that). But those things are boring and trivial. Provided one understands the spec, anyway. ;-) So I've also got things like this working:

```` raku
if $word eq any(@swears) { censor($word); }
if all(@values) < 10 { say "all less than ten"; }
````

I've also started on auto-threading. So far it doesn't collect return values into junctions and has some other issues too, but it's enough to do:

```` raku
say "hi" & "bye";
````

And it will call `say` once for each of the values in the junction, printing "hi" and "bye" on separate lines. It can also handle multiple junctional arguments:

```` raku
sub foo($a,$b) { say "$a $b"; }
foo("Hola" | "Adios", "Pedro" | "Rita");
````

Which will give the output:
````
Hola Pedro
Hola Rita
Adios Pedro
Adios Rita
````

Though junctions are unordered and the compiler is allowed to parallelize the calls if it feels like it, so there's no promise you'll get the output in that order. I haven't done any work on parallelizing it, mind. I'm more intested in making Raku work at all first.

I've done some odds and ends away from juctions too. I did some of the work on the given block. The given statement itself is, I believe, completed now, as is the default block (though that's a bit of a no-op in the compiler, since it's exactly the same as an always executed bare block). I've half completed the when block; it does the smartmatch and enters if it matches, but doesn't throw a control exception just yet, so you get implicit fall-through semantics where as we should have implicit break ones. But it's a start.

Being a Parrot guts hacker also comes in handy now and then. I'm not working on eval myself, but *fglock* and *Patrick* are. They were blocking on being able to set the outer sub at runtime (basically, being able to state that the generated code after calling eval was textually enclosed in the sub that executed the eval, so the eval'd code can access that sub's lexicals). So after consulting *Allison* on a method name (it wound up being called set_outer), I implemented it. I'm writing this while hiding away in the Negev desert with no internet connectivity, but by the time I have some again and post this I'd not be surprised if eval is implemented, such is the pace of Raku development these days.

I've also been putting in a few of the list-associative operators. So far I have done `X` (the cross operator, though I've not done the hyper version; doing so would probably mean hacking on the grammar engine, and I'm too scared to do that, or at least you need to buy me beer and make me promise to first), `Z` (the zip operator), `min` and `max`.

While I've been doing little bits of Parrot here and there and known that at some level it's contributing towards making Raku happen, actually working on the compiler makes it feel a whole lot more real. That doesn't mean I'll totally step away from Parrot guts to work on the Raku compiler, but Parrot is certainly ready enough to do a lot of the things we need to implement Raku, and I know a lot of people want to see something concrete on Raku, so for now I'm putting the majority of my efforts there. I will be doing the packfile work in Parrot to support proper good high level language debug information real soon now, though. Provided real life doesn't find another pesky way to intefere by making me too sick, busy or depressed to do so, anyway. Here's praying. :-)
