# Rakudo Hacking: Pairs and Refinement Types
    
*Originally published on [28 March 2008](https://use-perl.github.io/user/JonathanWorthington/journal/35993/) by Jonathan Worthington.*

First off, sorry it's been a while since I last posted. It's mostly been that I've just not done a lot between the Ukrainian and Dutch Perl Workshops and now, which was thanks to being busy with $REAL_LIFE and lacking either time or brain cycles for hacking Rakudo. Thankfully, I'm back into the swing of things now, and it's time to catch up on the blogging.

I'd like to give a belated thanks to everyone at the UPW and DPW for such a good time. I greatly enjoyed attending, meeting people and speaking at both workshops, and Kiev was a more beautiful city than I had imagined it being. The cathedrals and churches there are incredible - I'll surely be coming back to Ukraine to explore some more!

At UPW, some deficiencies in smart matching of arrays was discovered in Rakudo and I promised a fix. I also said I'd write a note about it here "soon", which I failed to do - sorry. I thought I had fixed array comparison with smart match, but that appears not to be working right now. :-( Also, the Perl and Raku way of checking if a list contains an element are different, and the Raku way was dependent on something else that wasn't implemented (though I've started work on it now, so hopefully we have that soon too). Anyway, it's on the horizon.

I'm hazy on exactly what I got done at DPW and around there, but I know I started on pairs. Thanks to some extra contributions from *cognominal*++, quite a lot of this is now implemented. As specifying named parameters in a sub was already done, happily it means you can now do things like:

```` raku
sub sayit (:$what) { say $what; }
sayit(what => "Oo minya pivo!");
Oo minya pivo!
````

It also works with object instantiation too.

```` raku
class Foo { has $.a }
my $x = Foo.new(a => 42); say $x.a;
42
````

As well as the fat arrow syntax, there's also the colon pair syntax, in various forms (we ain't got 'em all yet, but the most useful ones are there).

```` raku
sayit(:what);
1
sayit(:!what);
0
sayit(:what('privyet'));
privyet
my $what = 'nyam'; sayit(:$what);
nyam
````

Another thing I've hacked in some basic support for is the `subset` keyword, which allows you to write refinement types. You can smart-match against the type name to test if the variable meets that type.

```` raku
subset Guess where { $_ >= 1 && $_ <= 100 }; 
if 42 ~~ Guess { say "yes" } else { say "no" }
# yes
if 142 ~~ Guess { say "yes" } else { say "no" }
# no
if 97 ~~ Guess { say "yes" } else { say "no" }
# yes
subset LowGuess of Guess where { $_ <= 50; }; 
if 42 ~~ LowGuess  { say "yes" } else { say "no" }
# yes
if 97 ~~ LowGuess  { say "yes" } else { say "no" }
# no
if 0 ~~ LowGuess  { say "yes" } else { say "no" }
# no
````

Hopefully more types related stuff coming soon, amongst various other things. I'll be at the Oslo QA Hackathon, and hope to get plenty of free time there, as well as generally while traveling over the coming weekends.
