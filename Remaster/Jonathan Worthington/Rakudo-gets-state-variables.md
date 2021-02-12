# Rakudo gets state variables
    
*Originally published on [17 March 2009](https://use-perl.github.io/user/JonathanWorthington/journal/38658/) by Jonathan Worthington.*

I spent most of my Rakudo day today adding state variables to Rakudo. Perl.10 supports them, so it's nice that they can now be used in Raku - which first specified the feature - under Rakudo. As often happens, it took a first not-quite-right implementation to do one that I'm now reasonably happy with. I'm sure it can be improved in various ways, but for now it seems to get the right answers for everything we've thrown at it. So, a quick example.

```` raku
sub counter {
    state $count = 0;
    $*count*++;
    say $count;
}
`counter`; # 1
`counter`; # 2
`counter`; # 3
````

Here, `$count` is set the first time we run the sub to 0. But then in future invocations it remembers its value. The state is kept "per closure", such that you can do things like:

```` raku
sub make_counter($start = 1) {
    return {
        state $count = $start;
        $*count*++;
    }
}
my $c1 = `make_counter`;
my $c2 = make_counter(10);
$`c1`; $`c1`;
$`c2`; $`c2`;
say $`c1`; # 3
say $`c2`; # 12
````

Thanks to *masak*, *moritz* and *nicholas* for all contributing extra test cases to exercise the state implementation throughout the day - the already decent state.t has gained an extra ten tests thanks to their input. We now pass all tests in there apart from six which test the interaction of state with other not yet implemented features. So, 24 new tests passing. Nice.

I spent the rest of the day on some more minor things.

- *Karl Rune Nilsen* spotted a missing `\` in the hyper-ops generation code and sent in a patch. I applied it - that'll make the left-side dwimming variants work properly when we get the other issues blocking the unicode forms from working resolved.
- Fixed the ability to check something is a junction with `$j ~~ Junction`, which got broken a while back and was untested. When I went to add a test, I discovered we already had one - in a test file that we passed entirely now, but weren't running. Added it to to the known passing list. Easy win!
- Junctions have a `.eigenstates` method which gives a list of items in the Junction. However, recently it was suggested - and accepted by Larry - that Object should also get such a method that returns just a list containing the object itself. This means you don't have to check if something is a junction or not when you know that you just want a list of the one or many possible values. So, I added it, plus some tests.
- The initial implementation of `//=` mostly worked, but didn't short-circuit. This has now been fixed; `||=` and `&&=` were also implemented along the way. Fixing `//=` to short-circuit meant 2 more of the tests in state.t that depended on this working also ran.

So, enjoy the new features, and thanks to Vienna.pm for funding this work.
