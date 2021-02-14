# This week: fixing lots of RTs, digging into the GLR
    
*Originally published on [2015-08-05](https://6guts.wordpress.com/2015/08/05/this-week-fixing-lots-of-rts-digging-into-the-glr/) by Jonathan Worthington.*

This report covers the week starting 27th July. The first half was spent teaching the [course](http://edument.se/en/training/architecture/domain-driven-design) that I was busy finishing up writing last week; happily, it went extremely well and was a lot of fun to deliver. And since then, I’ve been back to Raku things pretty much exclusively. Anyway, here’s what I got up to.

### Fixing the &?ROUTINE pessimization

I noted in a recent episode that I fixed `&?ROUTINE`’s semantics with regards to closures. And indeed I had. Unfortunately, in doing so, I managed to make a whole bunch of things impossible for the MoarVM inliner to handle. Given how much fiddly work it was to implement multi-level inlining and deoptimization, I guess I should be happy that ending up with a lot less things being inlined would lead to a very measurable slowdown in real-world code – in this case, `Text::CSV`. This week I took another crack at `&?ROUTINE`, retaining the correct semantics, but making it so you only pay the cost of having it if you actually use it. And with that, the inlining started working much more effectively again (and `Test::CSV` regained some speed – and likely other code too).

### The status of our-scoped things inside roles

There were four RT tickets on the subject of our-scoped things inside of roles. They all hinged on a seemingly easy question. If this works:

```` raku
class C {
    our sub s { }
}
C::s;
````

Then why doesn’t this:

```` raku
role R {
    our sub s { }
}
R::s;
````

There’s actually not one, but two reasons why. The first is that a given role is actually rather like a template, generic on the type of the class that it actually ends up being composed into (think about how `::?CLASS` is generic inside the body of a role, then realize you could mention it in the our sub; you’ll note the our sub you’re referencing – if you could – would be ambiguous). The second is that you could later define:

```` raku
role R[::T] {
    ... 
}
````

That’s fine, this role and the previous one are disambiguated by their parameter lists. But it means that the symbol R that we install actually refers to a role disambiguator. (If you’re thinking this sounds like proto and multi subs all over again – you’re spot on. In fact, it’s implemented using the very same mechanism.)

Once you know these two things, it makes sense that you’re not going to reach an our-scoped thing burried two levels deep in genericity. Of course, when you start out with Raku you don’t know those two things, you’ll more likely flail around frustratedly. Now we reject our-scoped declarations inside of roles at compile time, with an explanation of why.

### The GLR

The Great List Refactor, or Great List Re-implementation, or Great List Re-design, was identifed as one of the Big Three Tasks for Raku ahead of the release we’re working towards later this year. In summary, the goal is to take on the semantic, speed, and memory issues with the current list design and implementation. I wasn’t expecting to be the person who led implementation work on this, but in the end it has fallen to me. Thankfully, a lot of the design thinking has already taken place, so it really is a case of focusing on the lower-level data structure design and implementation. Anyway, it takes a while to get from no code to something that’s ready for the wider community to have a conversation around, and so my GLR time in the week covered by this report started out with isolated contemplation and fleshing out code. Spoiler: I actually released it this Monday, and have continued evolving it since; you can [find the latest](https://gist.github.com/jnthn/aa370f8b32ef98e4e7c9) in a Gist I’m keeping updated (though I suspect in the next days I’ll be moving over to working in a Rakudo branch).

### Other fixes

I fixed quite a few other tickets too:

- Fix RT #125675 (tighten up various signatures so we get bind failures, not .count/.arity dispatch failures)
- Fix RT #125670 (rx{foo} as a parameter default caused compiler crash when it tried to do some static analysis)
- Fix RT #125715 (problems using `EXPORT`-d type as a type constraint on an attribute)
- Fix RT #125694 (private method calls in roles bound too tightly to role type)
- Fix getting ugly low-level backtrace when sinking last statement in a program
- Verify RT #125346 is fixed, write a test for it
- Fix a MoarVM crash involving lexotic (return) handlers and a race condition in frame validation
- Fix RT #125480 (program counter corruption due to bad interaction of LEAVE/return/closures)
- Trying to hunt down a MoarVM parallel GC bug. Found one issue and patched it, but it’s seemingly not The One…

See you next week!
