# Multi-dispatch progress
    
*Originally published on [4 September 2008](https://use-perl.github.io/user/JonathanWorthington/journal/37350/) by Jonathan Worthington.*

A little while ago I wrote about starting work on my Rakudo MMD implementation grant. At that point, I was just working out the algorithm and hadn't started on the implementation. Since then, with some hacking under the funding and some random extra hacking during YAPC::Europe, I have made some progress, which I'll talk about in this post. Before I do, I'd like to thank DeepText, who are providing the grant, for graciously allowing me to continue work under it this month, after (for reasons mentioned in the last post) I didn't start work on it until late in August, which was too close to the original deadline.

At this point, I have succeeded in subclassing the Parrot MultiSub PMC and have implemented the majority of the dispatch algorithm in the PMC, as planned. The dispatch currently takes into account the arity, class and role types ordered with type narrowness in mind and tie-breaking on subset constraints. Left to do is tie-breaking on the `is default` trait, which should be trivial, and then handling proto fallbacks, which will be less trivial but shouldn't be too hard; I'm leaving that for a bit later.

To make sure all of this code essentially works, I have written some tests in PIR that mock up subs with signatures, add subs to the Perl6MultiSub PMC and then invoke it, running the dispatch algorithm. It's quite tiring and verbose to write these tests in PIR, so there will be many more tests to be written once we can write multi subs using the dispatcher in Raku. And this is pretty much my next task - to start using this in Rakudo.

For those interested in something more technical, here's a little bit on the guts of what I've just implemented. The first time a call is done on a multi, we take all of the candidates and sort them in order of type narrowness, using the topological sort described last time. The only difference from a normal topological sort is that we care which candidates are equally narrow. It turns out that this is fairly straightforward to keep track of: we take the DAG that we built and remove together all of the things that do not have any incoming arrows and put them in the sorted result list, then stick a NULL value in, and then continue until we have taken all of the nodes from the graph. We then throw an extra NULL on the end, so a double NULL is our sentinel for end of list. We can then at dispatch time cheaply chase through the list, working out which candidates are admissible and knowing to stop if we had one or more admissible candidates of the same narrowness. It turns out that checking for admissibility based on arity is very cheap, but type-based admissibility checks are more costly. I think there will be ways to improve that a bit in the future, however.

So, the roadmap from here is:

- Clear up some memory leaks in the candidate sorting, while I remember that they're there! (Next day or two.)
- Get Rakudo properly attaching Raku signature objects to subs with all of the correct information in them that the dispatcher needs. (Within the next week.)
- Do what is needed in Parrot to ensure that when we generate code with MultiSubs we end up with Perl6MultiSub PMCs rather than the default Parrot one (HLL-Map style things). Once this is done, we're using the new dispatcher. (Within the next two weeks.)
- Write more tests in Raku to exercise the dispatch algorithm. (Within the next two weeks.)
- Add the `is default` trait and start using it for disambiguation, plus more tests. (Within the next three weeks.)
- Get `proto` and `only` to do something close to the Right Thing and make the dispatcher fall back to them as required. (Within the next three weeks, I hope.)
