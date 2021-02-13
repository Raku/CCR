# NQP changes getting there; Rakudo next!
    
*Originally published on [2011-01-30](https://6guts.wordpress.com/2011/01/30/nqp-changes-getting-there-rakudo-next/) by Jonathan Worthington.*

This week wasn’t quite as productive in terms of getting code written as the last few, though what did happen is noteworthy: native attribute support came along far enough that it is now used by Cursor to store its $!from and $!pos attributes. While the functionality isn’t yet exposed at NQP level, I’ve worked out with *pmichaud*++ how that can be arranged (there were a few possible ways to factor it) and it’ll land in the near future.

I also spent some time worrying exactly how to factor roles atop of 6model, and how to avoid certain problems in roles in Rakudo today – particularly with regard to parametricity (which is supported pretty well but has some icky rough edges in various cases). By this point I have a good idea of how to move forward and hope to have an implementation done in the next few days.

It will very soon be time to dig into the Rakudo changes. Here is a rough idea of how I think this will play out.

- Write new meta-objects against 6model that will cover the Raku semantics of classes, attributes, parametric roles, concrete roles, role composition, role object mixins, subset types and native types.
- Get definitions of base types in the stage 1 compiler reworked to use the new meta-objects.
- Update multi-dispatch core to use the proto semantics.
- Get grammar and actions happy again, and update them to work with compiling towards the new metamodel. At this point, everything up to the setting should work. 
- Get setting to build and work again.
- Fix up test regressions or tests based on bad assumptions. 

That said, I expect bits of these will happen in parallel. It’s hard to put times against them, but my aim is to be there – or close – by the time I go to OSDC.TW at the end of March.
