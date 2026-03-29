# Deep Git
    
*Originally published on [1 February 2017](http://strangelyconsistent.org/blog/deep-git) by Carl Mäsak.*

I am not good at chess.

I mean... "I know how the pieces move". (That's the usual phrase, isn't it?) I've even tried to understand chess better at various points in my youth, trying to improve my swing. I could probably beat some of you other self-identified "I know how the pieces move" folks out there. With a bit of luck. As long as you don't, like, cheat by having a strategy or something.

I guess what I'm getting at here is that I am not, secretly, an international chess master. OK, now that's off my chest. Phew!

Imagining what it's like to be really good at chess is very interesting, though. I can say with some confidence that a chess master never stops and asks herself "wait &mdash; how does the knight piece move, again?" Not even *I* do that! Obviously, the knight piece is the one that moves √5 distances on the board. 哈哈

I can even get a sense of what terms a master-level player uses internally, by reading what master players wrote. They focus on tactics and strategy. Attacks and defenses. Material and piece values. Sacrifices and piece exchange. Space and control. Exploiting weaknesses. Initiative. Openings and endgames.

Such high-level concerns leave the basic mechanics of piece movements far behind. Sure, those movements are in there somewhere. They are not irrelevant, of course. They're just taken for granted and no longer interesting in themselves. Meanwhile, the list of master-player concerns above could almost equally well apply to a professional Go player. (`s:g/piece/stone/` for Go.)

Master-level players have stopped looking at individual trees, and are now focusing on the forest.

The company that employs me ([Edument](https://edument.se)) has a new slogan. We've put it on the backs of sweaters which we then wear to events and conferences:
  
> We teach what you can't google.

I really like this new slogan. Particularly, it feels like something we as a teaching company have already trended towards for a while. Some things are easy to find just by googling them, or finding a good cheat sheet. But that's not why you attend a course. We should position ourselves so as to teach answers to the deep, tricky things that only emerge after using something for a while.

You're starting to see how this post comes together now, aren't you? 😄

2017 will be my ninth year with Git. I know it quite well by now, having learned it in depth and breadth along the way. I can safely say that I'm better at Git than I am at chess at this point.

Um. I'm most certainly not an international Git grandmaster &mdash; but largely that's because such a title does not exist. (If someone reads this post and goes on to start an international Git tournament, I will be very happy. I might sign up.)

No, my point is that the basic commands have taken on the role for me that I think basic piece movements have taken on for chess grandmasters. They don't really matter much; they're a means to an end, and it's the end that I'm focusing on when I type them.

(Yes, I still type them. There are some pretty decent GUIs out there, but none of them give me the control of the command line. Sorry-not-sorry.)

Under this analogy, what are the things I value with Git, if not the commands? What are the higher-level abstractions that I tend to think in terms of nowadays?

- **Units of work**

I sometimes call these "atomic commits" or "unit commits". The main point being that work I do in a repository is no longer an uncountable dribble of haphazard changes. It's been *discretized* (turned into separate units), and as part of that it's also been described enough in commit messages. I find these days I write longer, more descriptive commit messages. I also link back to previous commits a whole lot more. Branches are, in a sense, somewhat bigger units of work, with different criteria for when they're "done".

- **Quality**

As we evolve with teams and projects, we find more and more places where we can test, lint, and statically analyze the code. Think of these checks as our "extended brain"; they're what we ourselves would find if we were super-attentive all the time, which we're not. They're our better selves, encoded as software. We usually have long lists of more checks to apply during a slough.
- 
**Isolation**. Different developers in a team work in branches and make pull requests so that the team is shielded from each developer's stepwise work, and vice versa. We try to avoid long-running branches &mdash; but now and then one merge prevents an ongoing PR from being merged cleanly, and we have to rebase. The main point is that this is now under that team member's explicit control. It's *very good* that "tests pass" and "no conflict with `master`" are two orthogonal concepts.

- **History**

I can count on commits being permanent and unchanging. Once I've *made* a commit, I know it's in my local repository forever. Once I've *merged* a commit, I know it's in the team's `master` branch forever. If one repository catches on fire or gets abducted by aliens &mdash; we've had very few such incidents &mdash; it's not a big deal because everyone has a full copy of all the history.

(Yes, these are the ACID guarantees for database transactions, but made to work for Git instead.)

A colleague of mine talks a lot about ["definition of done"](https://www.scrumalliance.org/community/articles/2008/september/definition-of-done-a-reference). It seems to be a Scrum thing. It's his favorite term more than mine, but I still like it for its attempt at "mechanizing" quality, which I believe can succeed in a large number of situations.

Another colleague of mine likes the Boy Scout Rule of "Always leave the campground cleaner than you found it". If you think of this in terms of *code*, it means something like refactoring a code base as you go, cleaning it up bit by bit and asymptotically approaching code perfection. But if you think of it in terms of *process*, it dovetails quite nicely with the "definition of done" above.

Instead of explaining how in the abstract, let's go through a concrete-enough example:

- Some regression is discovered. (Usually by some developer dogfooding the system.)
- If it's not immediately clear, we bisect and find the offending commit.
- ASAP, we revert that commit.
- We analyze the problematic part of the reverted commit until we understand it thoroughly. Typically, the root cause will be something that was *not* in our definition of done, but should've been.
- We write up a new commit/branch with the original (good) functionality restored, but without the discovered problem.
- (Possibly much later.) We attempt to add discovery of the problem to our growing set of static checks. The way we remember to do that is through a TODO list in a wiki. This list keeps growing and shrinking in fits and starts.

Note in particular the interplay between process, quality and, yes, Git. Someone could've told me at the end of step 6 that I had totalled 29 or so Git basic commands along the way, and I would've believed them. *But that's not what matters to us* as a team. If we could do with magic pixie dust what we do with Git &mdash; keep historic snapshots of the code while ensuring quality and isolation &mdash; we might be satisfied magic pixie dust users instead.

Somewhere along the way, I also got a much more laid-back approach to conflicts. (And I stopped saying "merge conflicts", because there are also conflicts during rebase, revert, cherry-pick, and stash &mdash; and they are basically the same deal.) A conflict happens when a patch P needs to be applied in an environment which differs too much from the one in which P was created.

*Aside*: in response to this post, *jast*++ wrote this on #raku: "one minor nitpick: git knows two different meanings for 'merge'. one is commit-level merge, one is file-level three-way merge. the latter is used in rebase, cherry-pick etc., too, so technically those conflicts can still be called merge conflicts. :)" &mdash; TIL.

But we actually don't care so much about conflicts. *Git* cares about conflicts, becuase it can't just apply the patch automatically. What we care about is that the *intent* of the patch has survived. No software can check that for us. Since the (conflict ↔ no conflict) axis is independent from the (intent broken ↔ intent preserved) axis, we get four cases in total. Two of those are straightforward, because the (lack of) conflict corresponds to the (lack of) broken intent.

The remaining two cases happen rarely but are still worth thinking about:

- **Harmless conflicts (intent preserved)**:

Two different developers added one line of code each at the exact same site. Either it's "obvious" which order they should go in, or it doesn't matter. You sigh inwardly because Git has wasted your valuable time with this silly conflict.

- **Harmful non-conflicts (intent broken)**:

*mst*++ had an example once where two people each add a test at the end of a `.t` file. The added tests conflict, but the test plan at the top does not (since they each added one test). Only by actually running the test suite after the conflict resolution can we discover that something broke.

- For a course I made up another example: in branch A, an old naming convention gets replaced with a new one. Meanwhile, in simultaneous branch B, a file gets added according to the old naming convention. The order in which A and B get merged into `master` doesn't matter &mdash; the result is still conflict-free but wrong.

If we care about quality, one lesson emerges from mst's example: always run the tests after you merge and after you've resolved conflicts. And another lesson from my example: try to introduce automatic checks for structures and relations in the code base that you care about. In this case, branch A could've put in a test or a linting step that failed as soon as it saw something according to the old naming convention.

A lot of the focus on quality also has to do with doggedly going to the bottom of things. It's in the nature of failures and exceptional circumstances to clump together and happen at the same time. So you need to handle them one at a time, carefully unraveling one effect at a time, [slowly disassembling the hex like a child's rod puzzle](https://www.hpmor.com/chapter/54). Git sure helps with structuring and linearizing the mess that happens in everyday development, exploration, and debugging.

As I write this, I realize even more how even when I try to describe how Git has faded into the background as something important-but-uninteresting for me, I can barely keep the other concepts *out* of focus. Quality being chief among them. In my opinion, the focus on improving not just the code but the process, of leaving the campground cleaner than we found it, those are the things that make it meaningful for me to work as a developer even decades later. The feeling that code is a kind of poetry that punches you back &mdash; but as it does so, we learn something valuable for next time.

I still hear people say "We don't have time to write tests!" Well, in our teams, we don't have time *not* to write tests! Ditto with code review, linting, and writing descriptive commit messages.

No-one but [Piet Hein](https://en.wikiquote.org/wiki/Piet_Hein) deserves the last word of this post:
  
```
The road to wisdom? &mdash; Well, it's plain
and simple to express:

Err
and err
and err again
but less
and less
and less.*
```
