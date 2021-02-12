# Rakudo Day: Many bug fixes
    
*Originally published on [11 February 2009](https://use-perl.github.io/user/JonathanWorthington/journal/38463/) by Jonathan Worthington.*

So, back to the regular-ish Rakudo days! The RT queue for Rakudo has swelled enormously, so I'm planning to use my Rakudo days in the near future to focus on resolving tickets there rather than doing any cool new features. While I doubt this will make as exciting reading, Rakudo will be less buggy as a result, which I hope will make up for it by giving everyone a nicer product to play with.  

The first bug I fixed today was one related to proto-object definedness. They are meant to be undefined, something which I accidentally broke in dispatcher changes a while back and that, oddly, was untested. So I fixed that and added tests to make sure we don't regress on it again.

Next up was a more subtle one.

```` raku
class A {
    has $.b;
};
while shift [A.new( :b(0) )] -> $a {
    say $a.b;
    my $x = $a.clone( :b($a.b + 1) );
    say $a.b;
    last;
}
````

Clearly, the output should have been two zeroes, but it was giving zero and one - the original object was being modified. The cause was that we were getting some (internal) reference chains, and clone was only dereferencing one level, so we didn't properly clone the object after all. I ripped out the custom dereference code and put in a call to !DEREF, which does the Right Thing. So now clone is shorter and also fixed, at least in this aspect. I added something very much like the above as a test case.

In fact, we have some wider issues with clone in Rakudo. We can directly call Parrot's clone v-table method on things, but since it doesn't know about ObjectRef chains, that doesn't always work out so well. This example:

```` raku
sub foo($a) { say $a .. 5 }
foo(5)
````

Gave a warning and no output before I fixed it; the fix was making `postfix:<++>` (and I did `postfix:<-->` while I was at it) call `.clone` rather than directly using Parrot's clone v-table. I found that this fix also fixed one of our integration tests.

I then moved onto some work to incorporate various bits of STD.pm error checking to make things that should die at parse time do so. Therefore, the following, all of which actually parsed and did weird things at runtime, no longer do so:

```` raku
my DoesNotExist $x;
regex Foo {}; # Empty regex not allowed
regex Foo = { bar }; # Should barf on the = sign, now we do
````

Dealing with these allowed to to resolve a few RT tickets.

I then moved onto a couple of tickets about grammars. One of them reported a hang instead of an error message if you invoked .parse on a grammar that had no `TOP` rule.  I corrected that, and also implemented `.parsefile`, which slurps the passed filename and invokes the `TOP` rule of the grammar on that. Since *pmichaud*++ had already done `.parse`, that was pretty trivial. I added some tests for both methods, including one covering the hang, to the spectests too.

We've been getting readonly variables right for a while mostly, but we still didn't catch modifications through `++` and `--`. I put in a fix for that, and then realized that some tests for `<->` (the lambda that makes things rw by default) were now failing, since they had worked "by accident" before rather than through `<->` being implemented. So I implemented that also, and - after *pmichaud*++ pointed out a corner case - tweaked it to handle those and added more tests.

There were a couple of bug reports relating to optional parameters which had type constraints. When the parameter was not passed, they failed the type check. One was about positional parameters, another about named. Happily, there was a single fix that dealt with both cases. I unfudged a few existing tests for the positional optional typed case, and wrote some for the named case since I didn't find any existing spectests for that.

We've been adding lots of compile-time detection of bad stuff of late. One that was missing was checking that if you `is also` a class that doesn't exist, it should complain. So I fixed that and added a test.

Throughout the day, I've also closed up a few other tickets that were already dealt with, but hadn't been closed. So, a busy day. Thanks go to Vienna.pm for funding all of this. Happy hacking, and keep those bug reports coming in! :-)
