# Rakudo any/all/none junctions now collapse
    
*Originally published on [13 November 2008](https://use-perl.github.io/user/pmichaud/journal/37868/) by Patrick Michaud.*

For those who are wondering what happened to my journal posts over the past couple of months -- I've been focusing on some underlying Rakudo/Parrot design issues and supporting others more than writing code or prose.  Also, I think I needed a bit of a break.

I've decided that it'll be easier (and thus more likely) for me to increase visibility on Rakudo progress if I blog about new features and decisions as they happen rather than try to batch them up for a post every few days.  I do still plan to come up with "weekly summaries" as well, but I figure the immediate posts will be more satisfying for me and more helpful for others.

So, here's the first such post -- earlier this week I refactored Rakudo's Junction implementation to be cleaner and more correct, and *bacek*++ provided a patch to collapse duplicate values of one, any, and none Junctions.  We had to wait for confirmation from rakuanguage for this, which we just got today.  So, we now have:
```
> say any(1,2,2,1,3,2).raku;
any(1, 2, 3);
> say (any(1,2,3) % 2).raku;
any(1, 0);
```
Although any/all/none junctions collapse, `one` junctions do not:
```
> say (one(1,2,2,1,3,2) % 2).raku
one(1, 0, 0, 1, 1, 0)
```
This is because duplicate values change the boolean meaning of a `one` junction, so we can't simply collapse them.  As Larry says, "... `one` junctions produce bags rather than sets."

As a result we've been able to unfudge more spectest for rakudo -- we're currently (r32625) passing 4598 spectests.
