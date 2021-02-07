Lazy and Industrious Elves
==========================

Originally published at https://perl6advent.wordpress.com/2018/12/06/day-6-lazy-and-industrious-elves/ on 6 December 2018.

Christmas is always a busy time of the year for Santa. Fortunately, Santa has a lot of helpers. Always doing little jobs and chores, just to create the best holiday season experience there is to be!

The [Object::Delayed](https://modules.raku.org/dist/Object::Delayed) module adds two more very interesting elves to Santa's merry bunch of elves! Their names are `slack` and `catchup`!

Lazy slack
----------
The `slack` elf is very lazy indeed. It won't do anything until you actually want to use whatever it was that you asked the `slack` elf to do. Although one could consider this a very bad character trait in an elf, it's also a very ecological trait. One could consider the `slack` elf to be the greenest elf of them all! How many times have you asked an elf to do something for you and then not used the result of the hard work of that elf? Even though it's only recycled electrons that are being moved around, it still costs energy to move them around! Especially if those electrons are used to tell other elves to do something far away, like in an external database!

```` raku
use Object::Delayed;
my $dbh = slack { DBIish.connect(...) }
````

That's what you need to have a `$dbh` variable that will only make a connection to a database when it is actually needed. Of course, if you want to make a query to that database, that can also be made to slack!

```` raku
use Object::Delayed;
my $dbh = slack { DBIish.connect(...) }
my $sth = slack { $dbh.prepare(...) }
````

Since the statement handle is also slacked, it won't actually do the query preparation until actually needed.

```` raku
use Object::Delayed;
my $dbh = slack { DBIish.connect(...) }
my $sth = slack { $dbh.prepare(...) }
# lotsa program
if $needed {
    $sth.execute;  # opens database handle + prepares query
}
````

So if `$needed` is true, calling the `.execute` function will make the `$sth` become a real statemement handle after having made `$dbh` a real database handle. Isn't that great? Because if you didn't need it, all the elves doing the query preparation could be doing other things, and the elves making the database connection could **also** be doing other things. Not to mention the elves of the database being blissfully ignorant of your initial plan to make a database connnection at all!

Of course, if you **did** need the database connection, it is always a good idea to tell the elves of the database that you're done. In Perl 6, this doesn't happen automatically, because Santa doesn't keep track of how much each elf is doing. Santa likes to delegate responsibility! You typically tell the database elves that you're done when you leave the section of code in which you needed the database handle.

```` raku
LEAVE .disconnect with $dbh;
````

The `LEAVE` elf is special in that it will do the stuff it is told to do when you leave the block in which `LEAVE` elf is called. In this case the `.disconnect` method is called on `$_` if the `$dbh` is defined: the `with` elf not only tests if the given value is defined, bit **also** sets `$_`.

But, but, but, won't checking whether `$dbh` is defined actually **make** the connection to the database? No, the `slack` elf is smart enough that if you're asking if something is `.defined`, or `True` or `False`, it will **not** actually start doing the work for you. Which is **sooo** different from the `catchup` elf!

Industrious catchup
-------------------
If the `slack` elf is the greenest elf in Santa's employ, the `catchup` certainly appears to be the reddest elf. Because you always are trying to catch up with the `catchup` elf. But the `catchup` elf only **appears** to be very industrious.

When you tell the `catchup` elf to do something, the `catchup` elf will immediately find another elf to do the actual work and tell you that it is done. Which it most likely isn't. By the time you actually want to use the result of what you asked the `catchup` elf to do, there are two possibilities: If the other elf is done and the result is available, you will get it immediately from the `catchup` elf. If the other elf is not done yet, it will let you wait until the other elf is done: it will force you to catch up! So how does that look?

```` raku
use Object::Delayed;
my $foo = catchup { sleep 5; "Merry" }      # sleep is just
my $bar = catchup { sleep 9; "Christmas" }  # another word
my $baz = catchup { sleep 8; "everyone" }   # for baking
say “$foo $bar, $baz!”;
say “Took { now - INIT now } seconds”;
# Merry Christmas, everybody!
# Took 9.008 seconds
````

Here, the `catchup` elf had **3** other elves work on producing those nicely baked lettering with that sweet crusty glaze, where each letter takes about a second to make. If it had been only one elf doing that, it would have taken at least 5 + 9 + 8 = **22** seconds. Thanks to the `catchup` elf, it only took slightly more than **9** seconds! More than twice as fast!

Of course, if all other elves were already busy doing other things, it might actually take a little longer than just over 9 seconds. Or even longer than 22 seconds, if the other elves are working on more important things than baking letters with the right glazing. So your elf mileage may vary. You don't want to overwork your elves, well not for too long. A few seconds should be ok.

Use the right elf
-----------------
If you want to be as green as possible, use the `slack` elf. If you want it, and you want it **now** (well, as soon as possible), then using the `catchup` elf is an option if you can be reasonably sure that there will be enough other elves to do the actual job!

And a happy advent from all of the elves involved in this blog post! Yours truly is pretty sure no fast, slow or any other elf was harmed in any way.
