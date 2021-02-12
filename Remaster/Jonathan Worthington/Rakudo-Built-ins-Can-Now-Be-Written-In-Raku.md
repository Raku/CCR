# Rakudo Built-ins Can Now Be Written In Raku
    
*Originally published on [18 February 2009](https://use-perl.github.io/user/JonathanWorthington/journal/38508/) by Jonathan Worthington.*

Rakudo day today was mostly about getting going with a Raku setting (what other languages tend to call a prelude) for Rakudo. This allows us to write built-ins in Raku rather than in PIR, which will speed development and, we hope, encourage more contributions. It is also a needed step on the way to other things.

After *Patrick* told me The Plan that he'd worked out for this, I dug in to doing the grunt work. The first task was to split the compilation into two steps: first, compile the core of Rakudo, then use that to compile the Raku prelude, then bundle the two together to get the final Raku compiler. It turned out that this step was fairly easy. We'd done plenty of work leading up to this to provide features that would make it possible, so within a couple of hours I had the changes to make this work comitted. The first two Raku methods in the prelude were `.raku` and `.ACCEPTS` on the class `Whatever` - easy, for sure, but enough to prove the concept.

I thought things were looking good - but then it all came to a screeching halt when I discovered that because of the way we were building things, we were ending up with duplicates of some things that were supposed to be unique per compilation unit. Happily, *Patrick* jumped on the PCT changes required to fix this one up while I had dinner and did some shopping, and when I was back from all of that I was able to continue porting a few more things over to Raku. It's a start, but of course there's a long way to go yet. Help is very welcome - I really do hope this will help more people to get involved with Rakudo, since now you don't have to learn PIR to write built-ins!

As well as working on the setting, I dealt with a few RT  tickets, to pull our queue back under the 250 mark that it had sneaked above again.

- Recently *masak* pointed out that you couldn't create an anonymous class that inherited from another class, or had traits and so forth. The syntax `my $x = class is Foo { }` gave a parse error, since the `is` was taken as the name and then it didn't know what to do with the `Foo`. *Larry* tweaked STD.pm and declared that the way to do this is `my $x = class :: is Foo { }` - the `::` token indicating anonymity. Today I put the matching change into Rakudo's grammar, did the work to support it and added a couple of tests.
- Getting good test coverage isn't always so easy. There is some syntax for initializing the parent attributes of a class when calling new (`Child.new( Parent{ x => 42 })`), which worked. Well, in that simple case - but as soon as you got two different parents in there, it wouldn't work, or you'd end up putting the wrong values in the wrong places. A little effort later, I found the logic bug in our `BUILDALL` implementation and corrected it.
- As well as `class Foo does Bar { }` you should be able to say `class Foo { does Bar }`. Now you can.
- Did some tweaks to get Rakudo building better on Win32, including the raku executable, which didn't really work on Win32 since we moved out to GIT.
- Applied a patch from *bacek*++ to get `min=` and `max=` working (`$foo min= 100` will assign 100 to `$foo` if it's smaller than what is in `$foo`).
- Applied another *bacek* patch to fix the associativity of the `**` infix operator - it's right associative.

Thanks to Vienna.pm for funding my work on Rakudo today.
