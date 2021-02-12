# Rakudo MMD now using Raku algorithm
    
*Originally published on [13 September 2008](https://use-perl.github.io/user/JonathanWorthington/journal/37430/) by Jonathan Worthington.*

I came back from a trip to my local curry house tonight determined to get my recent work on implementing the Raku multiple dispatch algorithm being used by Rakudo. I had already got the algorithm itself implemented and got some PIR tests for it, but Rakudo was still using the Parrot multiple dispatch algorithm. This didn't provide the Raku candidate sorting algorithm, nor did it allow dispatch based upon roles as types or with subset type constraints acting as tie-breakers. So, I sat down and started hacking. About 2am, a series of patches hit the repository, the final one switching all code compiled with Rakudo over to using the Raku multi-dispatch algorithm. :-)

I'm a little tired now, but here's a couple of examples that now run. This first one decides which one to call based upon one of them having a constraint that can disambiguate them.

```` raku
 multi sub foo(Int $x) { 1 }
multi sub foo(Int $x where { $^n > 42 }) { 2 }
say foo(12); # 1
say foo(45); # 2
````

And here's one where we have a role involved.

```` raku
role Explode { }
class Firework does Explode { }
class Kitten { }
multi sub bar(Explode $x) { 1 }
multi sub bar(Kitten $x) { 2 }
say bar(Firework.new); # 1
say bar(Kitten.new); # 2
````

I've discovered that there are some problems that have come up with the candidate sorting, but I'm too tired to track them down right now. Curiously, there are PIR tests to exercise this and they pass. It's only when using it from Rakudo that the problems appear. So there's something not quite right there, and I'll investigate it in the next couple of days. In the meantime, all spectests that were passing before continue to pass (and we've got two more unexpected passes now too), so I'm quite hopeful that this isn't going to cause too much disruption to folks while the kinks are ironed out. Anyway, enjoy, and bug reports (other than the candidate sorting issue that I'm aware of) are most welcome. :-)

Thanks for funding me to stay up until this crazy hour hacking on this (OK, to be fair, I slept until mid day today^Wyesterday) goes to DeepText.
