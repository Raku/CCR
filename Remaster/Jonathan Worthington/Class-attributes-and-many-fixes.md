# Class attributes and many fixes
    
*Originally published on [26 July 2008](https://use-perl.github.io/user/JonathanWorthington/journal/37019/) by Jonathan Worthington.*

I took Friday off this week, so that I could work Saturday on Rakudo, matching up my Rakudo day with the post-OSCON Parrot/Rakudo hackathon. I started off the day by going through the Rakudo RT queue and trying to resolve some of the tickets in there. Rather than doing any big new thing today, I instead went to the RT queue for Rakudo and addressed some of the tickets in there, to resolve a range of bugs that people had reported.

- Applied patch from *Carl Masak* that avoids a NULL PMC Exception if the return value of `sleep` was evaluated.
- You can now (as per the spec) write just `multi foo { }` rather than `multi sub foo` to introduce a multi-sub.
- Writing `multi sub foo { }` (note there is no signature) now works the same as `multi sub foo { }` rather than giving a Null PMC access.
- Fixed a bug in Parrot that caused an assertion failure when trying to write to a closed file-handle; now it throws an exception, so we can implement the correct Raku semantics in Rakudo.
- Trying to inherit from a non-existent class now gives a meaningful error message, rather than a rather less informative null PMC access exception.
- Fixed a bug in PCT which could cause an exception to get lost in the return_pir control handler. This allowed at least one ticket to be closed out, and will likely help people working on other compilers written in NQP too.

I then turned to another ticket with a bigger task: getting class attributes to work. While there will be more bits to do on this, the basics are working. Here's what I've just put into the regression tests.

```` raku
class Foo {
    my $.x is rw;
}
my $x = Foo.`new`;
$x.x = 42;
is($x.x, 42, "class attribute accessors work");
my $y = Foo.`new`;
is($y.x, 42, "class attributes shared by all instances");
````

So essentially, you're introducing a lexically scoped variable and getting an accessor method generated for it.

During the day, I've also had various chats about other little bits of Raku stuff on IRC, and been re-reading bits of the spec as food for thought on implementing some more bits in the future. So, that's this week's Rakudo day. Thanks as usual goes to Vienna.pm for funding!
