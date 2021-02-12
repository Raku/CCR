# 'eval' can see lexicals and other fixes
    
*Originally published on [14 March 2009](https://use-perl.github.io/user/JonathanWorthington/journal/38641/) by Jonathan Worthington.*

Back from my conference and vacation trip (travel tip: Lviv is very pretty and cheap), I did a Vienna.pm Rakudo Day yesterday. There's one main new thing to shout about: eval can now see outer lexical variables. So this:

```` raku
my $x = 42;
eval('say $x');
````

Will now print 42. This not only made the spectest for this particular feature pass, but also there were a bunch todo'd and skipped that needed this feature. So I reckon we'll have gained a double-figure number of tests with this, plus it should help the Web.pm effort a bit.

I also did a variety of other fixes:

- Fixed a Null PMC Access that could occur when looking into `&some_sub.signature.params`
- Multi-subs now respond to `.WHAT` by handing back the proto of a type `Multi`. You can call `.candidates` to get a list of all candidates, which you can iterate over to introspect them as needed. This cleared up a ticket or two on weird behavior when doing such things on multi-subs, which weren't quite proper Raku objects up to that point.
- Fixed a bug in the multi-dispatcher that came up where you got down through nominal typing and arity to a single candidate that had a subtype constraint on a parameter. Subtypes are indeed used as tie-breakers, which we were doing correctly, but should be enforced even if there is just one candidate and can rule out the single candidate if they don't match. We were also caching the dispatch result in this case, which we shouldn't do since the cache is type-based and subtypes can examine values. All clear? :-) Added a spectest.
- Using a role name as a type constraint could cause some issues, most notably when you used it as a type constraint on an attribute. These issues are now resolved and I added several tests covering this area.
- *Patrick* pointed out that my last big method dispatch refactor, which paved the way for many features that we now have, had some issues in relation to foreign objects (e.g. for interacting with objects from languages outside of Raku) and proposed another refactor to deal with this. Thankfully it was a pretty easy one this time, and it went quickly and smoothly. So this should improve things for langauge interoperability.

I also had discussions with various people (thanks to *Larry*, *Allison*, *Tene* and *Patrick* for input) about implementing .leave. Happily, *Tene*++ had thought it through a bit and had a good idea of how to do it. Which means I hopefully now don't have to do it, and can just make use of it once it's done to fix the auto-threading bug that sent me chasing after it in the first place.

As usual, a big thanks to Vienna.pm for funding my Rakudo hacking.
