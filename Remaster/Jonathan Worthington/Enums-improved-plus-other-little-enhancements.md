# Enums improved, plus other little enhancements
    
*Originally published on [1 May 2009](https://use-perl.github.io/user/JonathanWorthington/journal/38910/) by Jonathan Worthington.*

Since I missed a couple of Rakudo days in the middle of last month, thanks to the excellent Nordic Perl Workshop and the hackathon that followed it, I did an extra one today to get caught up with them a bit and to keep things moving.

I did a first cut of enums quite a while ago. Since then, a lot of things in Rakudo have changed, parts of the spec became clear and, well, the first cut of enums just wasn't that good. Sometimes you gotta get something wrong as a precursor to getting it right, or at least righter. :-) So today, noting that we had a huge number of tickets in RT relating to enums, I set about improving things.

The end result is pleasing in that actions.pm is now a lot shorter, since we construct enums in a quite different way. A bunch of code that only hung around because the previous enums implementation needed it has gone away. Also, the code that the compiler generates for enums is vastly more compact; the heavy lifting is done in a different place. It's also been easier to add a bunch of the missing stuff that people were asking for, and various other bugs just evaporated.

Now, for `enum` elements, you can introspect them some more:

```` raku
enum Day <Mon Tue Wed Thu Fri Sat Sun>;
say Mon.name; # Mon
say Mon.raku; # Day::Mon
say Min.WHAT; # Day - not just the string, but Day itself
````

Smart-matching now works too. So if you have some variable `$thingy` that has had `Day` mixed into it an initialied, you can do things like:

```` raku
given $thingy {
    when Mon { say "yaaaaawwwwn" }
    when Tue|Wed|Thu { say "work work work" }
    when Fri { say "w00t, nearly the weekend" }
    when Sat { say "OH HAI I'M AT THE BAR" }
    when Sun { say "good morning, vicar" }
}
````

You can also do `.pick` on an `enum` to select 1 (or more if you give pick an optional argument) of the values at random. And `.pick(*)` gives you all of them in a random order.

There's still some more bits to do, but enums should now be greatly improved in Rakudo. There's a couple more tickets, and I'm sure others will help flesh out the weaknesses of this new implementation, so we can shake out the bugs.

I also dealt with a few other bits and pieces.

- The `min` and `max` built-ins now take arity-1 blocks as well as arity-2 blocks. So, for example, if you had an array of Product objects with a price attribute, you could just do:

```` raku
my $cheapest = @products.min(*.price);
````

Which is kinda cute.

- Closed another long-standing ticket relating to declaring alternative multi-variants of `max`.
- Fixed a hang when you used the `does` or `but` operators with a non-role on the right hand side; it now reports the error as it should have before.
- Made `eval` compile things into the correct namespace, resolving a couple of tickets.
- `.raku` on a proto-object should not have parens after it, but stringifying a role should have them; corrected these two.

Thanks to Vienna.pm for sponsoring this Rakudo Day.
