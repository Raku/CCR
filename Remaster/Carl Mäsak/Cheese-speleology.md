# Cheese speleology
    
*Originally published on [5 September 2009](http://strangelyconsistent.org/blog/cheese-speleology) by Carl Mäsak.*

Here's an idea I had the other day.

We're in the process of upgrading how proto installs Raku projects. *mberends*++ has taken the initiative by creating [a branch](https://github.com/masak/proto/tree/installed-modules) and [a TODO](https://github.com/masak/proto/blob/242497e1b767362be39bb80d0c20cc2bea485fed/proto#L510). Today, the same *mberends*++ also landed [a commit in Rakudo](https://github.com/rakudo/rakudo/commit/e8b631cd86ffeaeae8cf930c72ffd4a449e5d521) such that all our RAKULIB worries just vanish. It's looking good.

One thing I would like to fall out from this refactor is **a way to run all the tests in all Raku projects**. Think of it as a kind of community-level introspection — proto's [Ecosystem.pm](https://github.com/masak/proto/blob/adc11251ae1923c996b8ae8ed5b20bad90c1f9b5/lib/Ecosystem.pm) was my early attempt at this. And we can easily set up cron jobs and HTML serializers for a nightly run of these things on feather. This would have two benefits, I think:

- We get an ecosystem equivalent of the [spectest suite](https://github.com/Raku/roast), in the sense of "these things should all work, and if it doesn't, a human should check it out". Such testing helped us before — apps helping us [find holes in the Rakudo cheese](https://www.perlworkshop.no/npw2009/talk/1734) — but by not running all the tests regularly, we're doing ourselves a disservice, because it might be days between the introduction and discovery of a Rakudobug. The sooner these things are flagged down, the better for everyone.
- We could make the community more positively aware of project tests, and make the community celebrate them. Which Raku project out there has the most tests right now? I don't know. I have a guess, but I would like to know for sure. Which project passes the highest amount of tests? Which projects pass all of their tests (barring `:todo` and `:skip` tests)? Which project has had all its tests passing for the longest time? Which project has had all its tests passing for the longest time *while also adding more tests lately*? Which project has the best test coverage? And so on. It's not a contest, but if some authors choose to think of it that way, what we'll end up with is better-tested code.

Testing all of the Raku ecosystem sure is simpler than testing all of CPAN. But if it can help improve Rakudo and the Raku community, I think it can be very worthwhile.
