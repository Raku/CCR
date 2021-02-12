# Multiple Dispatch Design Work
    
*Originally published on [5 August 2008](https://use-perl.github.io/user/JonathanWorthington/journal/37101/) by Jonathan Worthington.*

I have a grant from DeepText, a Russian company who have very kindly stepped up to buy 40 hours of my time on Rakudo. We agreed that I would work on Multiple Dispatch. At the moment, there are various Rakudo changes needed before we can actually get all of this in place, some of which Patrick is currently working on and another which needs more discussion between myself and Patrick to work out the exact way forward. I've been holding off work on multiple dispatch waiting for these, but as we're getting really rather close to the time I need to deliver stuff, I really want to start now. I realized (I really should have realized before now, I guess) that there's no reason I can't write PIR tests that will exercise the dispatch algorithm that I will implement, and provide the signature object interface for when we get a final implementation of that into Rakudo. So, I'm now going to follow this approach, and hopefully towards the end of the grant, or during YAPC::EU hacking, we'll push this into Rakudo so everyone can play with it.

I started work on the grant today by gathering all of the bits of the specification together that relate to MMD, and reading through all of them in detail. This post sort of summaries some of the design thinking I've been going through, and after some more of that I'll dig into some implementation. Throughout the whole process, I will work on tests, too. I want an outcome of my work here to be that we have many good tests for multiple dispatch. Of course, I will be writing some to exercise the PMCs from PIR until we get things into Rakudo.

Some general thoughts (I'm writing these because having to write stuff helps me to make sure I understand it, as much as for everyone else to read it, but I hope some folks will find it an interesting read).

1. I will implement the Raku dispatch algorithm by subclassing the Parrot MultiSub PMC, as the Parrot MMD spec recommends. From there, I can override invoke, thus implementing the Raku MMD algorithm.

2. Raku needs to be able to get at the MMD algorithm when not actually invoking in some cases. Therefore, it will not actually be inside invoke, but instead invoke will call some method on the PMC that computes the candidates and hands them back, to make it easy to do this stuff later.

3. We need to actually be able get at the list of all possible candidates to implement some operations, and not just the "winner".

4. Not all parameters may participate in the multiple dispatch, so we need to make sure the `;;` can be "seen" in the dispatch algorithm. so it knows just to consider what comes before the `;;`.

5. Before we do any multi-dispatches, and at `CHECK` time (so we can do this once per compile rather than once per run), we need to perform a topological sort of the candidates. (Note that if the set of possible multis to consider changes at runtime, we will have to re-do the sort. We can still cache it between these events.) I will likely do another post on this sort at some point in the future, but as I see it so far:

- We will first compare every candidate with every other candidate. This is an O(N\*\*2) operation in the number of candidates, but remember we do it once and can do it at compile time rather than runtime in the common case. Using this information, we make a directed acyclic graph, putting arrows from candidate A to candidate B if A is narrower than B.
- Now that we have built this, we perform a topological sort on the DAG. This means we get a list with the narrower candidates occuring earlier in the list, which is what we want.
- XXX: Somehow we need to persist where in the list we actually have one thing being more narrow than another, and when we have a tie, so we can know when we have a tie at dispatch time. (Idea: We really don't want to have to keep the DAG around and analyze it to do this. I suspect that with a slight modification on Kahn's algorithm, we might be able to insert NULLs into the candidate list between sets of tied candidates. Then at dispatch when we iterate through this list, if we have found one candidate that we will be able to dispatch to and then hit a null, we know we've got no tie. Need to prove to myself this will work yet.)

For now I'll just point at S12's definition of narrowness, and point out that we only consider class and role types in it - refinement types (those declared with subset) are only used to tie-break later, if we get a tie from the class/role checks.

6. The dispatch algorithm proceeds something like this.

- We loop over the list of candidates in their topologically sorted order, as pre-computed.
- If the current candidate can not be dispatched to because it requires more parameters than we have available, we can cheaply eliminate it.
- Next, we look at the class and role types and see if they could possibly bind to this candidate. As soon as we hit something non-bindable, we can short-circuit on checking any further parameters and consider the next candidate.
- If we find something bindable, then we continue checking the candidate list upto the point that we reach something that was not tied with the successful option we have found so far in the topological sort. We keep track of anything that we find that could also be dispatched to.
- At this point, we'll have either searched the whole candidate list and found nothing (so we give an error), found one unambiguous candidate (in which case we just hand it back) or found multiple ambiguous candidates that we need to try and dis-ambiguate (so we continue with the next steps).
- Now we check our candidates signatures to see if they have any refinement types. If so, we check them to see what matches. I don't think we will look at considering one constraint narrower than another, but I need to verify that. I think we just discard candidates that fail their constraints, and treat a candidate without any constraints as being a worse candidate than a candidate that matches one or more constraints. So if you have two candidates with no constraints and two candidates with constraints, and one of the candidates with constraints matches, then it wins; if both were to match, they would be the tied candidates going to the next stage; if both fail to match, they are discarded and we're left with the two candidates without constraints for the next stage.
- At this point, if we still have a tie, we look and see if any of the candidates have the "is default" trait. If exactly one of them does, then it wins. Otherwise, we still have an ambiguity.
- Finally, at this point, we have run out of options. If there is a proto, we call that. Otherwise, we die with an ambiguous dispatch error.

More news as I progress on this grant, and a big thanks to DeepText for the funding!
