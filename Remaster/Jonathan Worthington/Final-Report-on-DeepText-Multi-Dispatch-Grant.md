# Final Report on DeepText Multi-Dispatch Grant
    
*Originally published on [11 December 2008](https://use-perl.github.io/user/JonathanWorthington/journal/38070/) by Jonathan Worthington.*

In May, DeepText offered to fund me to work 40 hours on implementing some features of my choosing from the Raku specification in Rakudo. I chose to use the grant to work on multiple dispatch. This post is my closing report on the work done under this grant, now that the 40 hours have been spent.

## Work Done Under The Grant
When proposing the topic of multiple dispatch, I wrote:

> At present, we have a sorta-working-ish multiple dispatch, apart from it only sort of works. For example, it doesn't pay any attention to roles and constraints. But more serious, I think the candidate sorting is also different from what S12 specifies, which means at the moment we probably sometimes would dispatch to the wrong thing. Then there's no support for `is default` proto, and so forth. So there's a lot of (in places I expect quite tricky) work to do here.

Using the grant, I have resolved every one of the isues I mentioned in this part of the proposal, and more. Here is a list of all the things that have been implemented.

- Correct sorting of candidates, using a topological sort on a DAG constructed after analysing type narrowness of the signatures of the candidates, as specified in S12.
- Dispatch on both class and role types.
- Tie-breaking on constraints. There is some work remaining here on constraints that reference paramters other than the one they are constraining and that rely on being run in the correct lexical context, but the case where the constraint just checks the block paramter it is passed work fine.
- The `is default` trait.
- Declaration of `proto` routines, and their acting as a fallback if all else fails in the dispatch.
- The use of `;;` to indicate some parameters do not participate in multiple dispatch.
- Muchly improved signature objects, which are introspectable. You can also `.raku` them, which prints a Raku representation of a routine's signature.
- Improved diagnostics: if you get an ambiguous dispatch, it tells you the signatures of the routines that were in conflict. (Once we've got some missing Parrot functionality in place, we can add line/file numbers easily too.)
- A first cut of multi methods. We don't get inheritance and multis used together correct yet, but other than that they work.
- The `.?`, `.+` and `.*` operators are now multi-aware and will now call all applicable multi-subs up the hierarchy. The work done here probably helps pave the way for implementing `.WALK` also.
- Improvements to subtypes (constraint types), because we needed them fixed to do dispatch on them correctly; this makes them better generally and more what the spec wants, however.
- A multiple dispatch cache, which can vastly improve dispatch performance. I implemented this generic enough not just to be usable with Rakudo's dispatcher, but also applied it to Parrot's multi-dispatch in opcodes, yielding some notable benchmark improvements there too. With some further Parrot refactoring, it can be applied to Parrot's own multi-sub dispatch for a probable performance win there too.

I believe that this grant has led to a lot of progress in Rakudo's implementation of multiple dispatch. In the future, we will have a Raku prelude and will then use this dispatcher not just for user defined routines, but for all of the built-ins (operators too, since they are also multi-dispatch).

As well as implementation, there has also been many tests unfudged and written to make sure that the things that have been made to work here keep on working.

## Reporting
As part of the grant, I was to make at least four blog posts about the things I implemented as part of it. I exceeded this and wrote seven, published on both use-perl.github.io and rakudo.org.

## Delivery Time
The initial grant specified that I should do this work in July and August. Given I am writing this report in December, I have massively failed to do this. I held off working on the grant while some issues surrounding signatures worked out, knowing they were a dependency. As a result, I didn't log any time on it during July. In August I unblocked the process by writing the first cut of the dispatcher and some tests in PIR for it that faked up signatures, but in reality I could have done this much earlier. Late August was swallowed up with other distractions, and it was September before I got Rakudo using the new dispatcher. Then I spent a month offline, backpacking accross Russia (part of the reason I didn't get more done in September was general demotivation and really needing a break from things). It was November before I dug back in, adding many features; the start of December saw the last few bits.

The blame for failing to deliver on time lies entirely with me - for bad scheduling early on, being in the wrong frame of mind in September, and not working as much as I could have to clear this up in November. For this, I apologise to both DeepText and the community, and I will try to do better on future grants.

## Conclusion
Despite going over-schedule, this grant did suceed in greatly improving the state of multiple dispatch in Rakudo, and as a side-effect aided various other parts of Rakudo and also led to an improvement to Parrot. At the start of the grant, I went through the Raku specification and extracted all of the parts relating to multiple dispatch. At the end, I went through and deleted all of the extracts relating to things that now worked. A lot was removed, and a lot of what remains relates to protos and the interaction of multiple dispatch with features that we have not yet implemented for the single dispatch case yet in Rakudo.

I would like to thank, first and foremost, [DeepText](http://www.deeptext.ru) for providing this grant and being patient while I worked on it. Many other people from #parrot and #raku contributed ideas and suggestions as I worked on this grant; I'd like to thank (this is not a complete list, just people who most come to mind who have said or done helpful stuff along the way) *chromatic*, *moritz*, *particle*, *pmichaud* and *TimToady*.
