# Rakudo pre-release bug hunting
    
*Originally published on [19 August 2009](https://use-perl.github.io/user/JonathanWorthington/journal/39498/) by Jonathan Worthington.*

Between vacations and conferences, I've not done a Vienna.pm Rakudo Day for a little while. Anyway, today I took the opportunity to spend the day doing Rakudo improvements before tomorrow's monthly release.

As more and more people explore Rakudo, we get more and more issues and corner cases reported. At the start of today we had 470 tickets either new or open in the Rakudo RT queue. I hadn't reviewed the ticket queue in a while; back when it was more like 150 tickets I did it every week, but it's a bit too long a job for doing it weekly now. Doing so today was very worthwhile, however: I was able to close six tickets that related to missing features that had already been added or bugs that had already been fixed, and *masak*++ was able to confirm that another two that he had filed were now dealt with and close them as well. 8 tickets down before I'd even got through my first cup of coffee of the day. Not bad. *moritz*++ also made inquiries to the rakuanguage list over a ticket I brought up for discussion on the channel.

"Null PMC Access" is in many ways the Parrot equivalent of a segfault (though Parrot does actually segfault now and then too, so we get the best of both worlds... ;-)). Whenever one happens in Rakudo, it's Just Plain Wrong, and means we overlooked a check somewhere. Today I identified a group of tickets that all gave this error for very related reasons, patched them and unfudged various tests. That was another four tickets sorted out.

Another easy win was doing the last push on a ticket related to Failure object handling, which others had got mostly there. I did that and closed the ticket. Then I fixed a bug that has been causing some irritation for a while:

```` raku
sub foo returns Int { fail("oh noes!") }
````

This is meant to work fine, since failure is always acceptable for any non-native type. However, in reality it did not, since the type check wasn't allowing the Failure to get out. It's fixed now. And as a bonus, I could now use fail on one of the typed routines in the setting to fix another bug: Rakudo was dying if you called `ord('')` with an empty string, when it fact it should only have been failing.

I spent a chunk of the day dealing with some multiple dispatch tweaks. The first was a trivial bug fix: we were missing something out in the PAST-generation for `multi foo { ... }` but putting it in for `multi sub foo { ... }`. The second two tickets were trickier, and related to how we dealt with slurpy parameters and optional parameters when doing the narrowness analysis to sort candidates. First, the slurpy one.

```` raku
multi foo (*@a){ 1 }
multi foo () { 2 }
say `foo`;
````

This was being treated as ambiguous before. To deal with this, we've implemented the rule that if two candidates are tied, they may be disambiguated if one has a slurpy parameter and the other does not. The one without the slurpy is considered narrower. The thinking behind this is that specifying exactly how many arguments you can take is more specific than saying you can take just any number. The upshot of this is that the above program now prints 2 instead of dying. The optional parameter one was a different issue.

```` raku
multi foo (@a) { 1 }
multi foo ($a, %h?) { 2 }
say foo(<1 2 3>);
````

The narrowness analysis was looking at these two and saying "well, they have different numbers of items in the parameter list, so I can't compare them, so they're tied". I relaxed this rule a bit to allow comparison of these based on the non-optional parameters they have, and now since `@a` is narrower than `$a` (just out of the normal dispatch rules we already had in place), this example now outputs 1 instead of dying.

Finally, recently I've been helping `ash`, a new contributor to Rakudo, work on a patch to get us able to do method dispatches from the point of view of a different class. He showed up and said he was hacking on the patch, which was exciting because it's rather non-trivial as a way to get into Rakudo development and he was looking in the right places, but also challenging as I knew fairly well how to do it after some discussion with others on #raku about what the spec called for, but didn't want to end up just writing the patch for him, otherwise it'd be a crappy learning experience. Anyway, today *ash*++ made it, with a little more input, to a working patch, which I was very happy to review and apply. So now you can do this (the bottom line is the new thing):

```` raku
class A { method foo { say 42 } }
class B is A { method foo { say 69 } }
my $x = B.new;
$x.foo; # 69
$x.A::foo; # 42
````

And that, along with the usual assorted discussions on #raku plus some updates to the ChangeLog ahead of the release, was what I got up to today. Thanks to Vienna.pm for funding it.
