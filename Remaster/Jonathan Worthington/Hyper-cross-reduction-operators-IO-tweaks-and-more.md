# Hyper/cross/reduction operators, IO tweaks and more
    
*Originally published on [9 December 2008](https://use-perl.github.io/user/JonathanWorthington/journal/38056/) by Jonathan Worthington.*

It's been an exciting few days in the Rakudo world. *Patrick* has landed some great stuff, which I'm sure he'll blog about soon. We're approaching the 5,000 passing spectests mark, and I'd not be surprised if we passed it before the next Parrot/Rakudo release on Tuesday.

First I spent some time on IO. I'd done a few bits before, but there were various issues and, as we'd made other bits of Rakudo better, IO hadn't always caught up. Then, last night, some Parrot IO improvements landed that meant a couple of things needed tweaking. Also, the state of IO testing is far from great. First I applied a couple of patches from *bacek*++. One fixed readline so it met up with the Parrot changes; at this point, I realized we must have no tests for it. The other implemented the lines method on an IO handle, which gets an array of all lines in the file.

```` raku
my $fh = open("README", :r);
my @lines = $fh.lines; # or lines($fh) - it's exported
````

Then I set about fixing up using `=$fh` in a loop, which I think we may have had working for a short time at one point before, but other muchly needed list handling refactors broke it. You can now write things like:

```` raku
my $fh = open("README", :r);
my $count = 1;
for =$fh -> $line { print "$count $line"; $*count*++ }
````

And unlike before, it should give the correct number of lines back too, rather than one too many. While I was fixing this, I also made `chomp` Win32 aware, and implemented auto-chomping, as specified in S29. I also added another S16 test that we now pass fully, so we won't regress unknowingly on this again.

One of the things *pmichaud*++ had done was some work on reduction operators. These are awesome - you can write factorial $n as just:

```` raku
my $fact = [*] 1..$n;
````

It's just like taking every value in the list after the reduction operator and sticking the `*` operator between it, e.g. `1 * 2 * 3 * ... * $n`. However, it only worked for some infix operators. The biggest missing ones were comparision operators, which I have now implemented. For example, you can check if a list is sorted with:

```` raku
if [<=] @list { say "Sorted, like!" }
````

Which is just like doing a `<=` between each element of the array @a.

Now we'd got one sort of meta-operator, I wanted more! So, I went on and did a first cut of hyper operators. Some examples of what you can do now.

```` raku
say ((1,2,3) >>+<< (3,2,1)).raku; # [4, 4, 4]
say ((1,2,3) >>*<< (3,2,1)).raku; # [3, 4, 3]
say ((1,2,3) >>+>> 1).raku; # [2, 3, 4]
say ((1,[2,3]) >>+<< (1,[2,3])).raku; # [2, [4, 6]]
say (10 <<*<< (1,[2,3])).raku; # [10, [20, 30]]
````

Note that if you want a side to auto-upgrade, you point the angle brackets towards it. Not doing so will give an exception. There are also unicode variants of the hyper operators, which in theory are implemented, but in practice fail to parse because of a Parrot bug (happily, *Patrick* was able to quickly narrow it down and produce a very short test case to pass on to Parrot folks who might be able to help fix it up).

For a while people have wanted to be able to set initial values for attributes at the point of declaration. Tonight I've put in some basic support for this (just for constants so far - there are some issues with lexicals declared outside of a class not being visible inside the class, plus there is also the `is build` trait to do to implement for more complex initialization). You can now write at least:

```` raku
class Universe {
    has $.answer = 42;
}
````
And have it work, though.

For my final trick, realizing that we now had reduction and hyper ops, that left cross operators. These produce each permutation of the lists and then combine them using the operator between them. It turns out that since they can be expressed in terms of `infix:<X>` - which we already had - and reduction operators, which we also have - it was trivial to implement also. So, I did it, and unfudged some more tests. So we now have:

```` raku
say (<a b> X~X <1 2>).raku; # ['a1', 'a2', 'b1', 'b2']
say (1,2 X*X 3,4).raku; # [3, 4, 6, 8]
````

While there's more to do on all of the things I've been working on here today - IO, OO, and meta-operators - hopefully there's some nice things in here that will make hacking on Rakudo a better experience. Thanks to Vienna.pm for funding my work today.
