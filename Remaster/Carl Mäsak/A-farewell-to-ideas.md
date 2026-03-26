# A farewell to ideas
    
*Originally published on [8 January 2009](http://strangelyconsistent.org/blog/a-farewell-to-ideas) by Carl Mäsak.*

Isn't it oddly typical? When I finally hatch a plan for equipping my [Druid](https://github.com/masak/druid/) computer player with some better-than-random awareness of the game, I don't come up with *one* idea worthy of pursuing, but *two*. And this happens exactly in the transition between the holidays, when tuits are free and abundant, and the return of $COURSE and $WORK, when they aren't. G'ah!

I figure the least I can do is write about the two ideas in sufficient detail. Doing this will have several gains:

- I get to put them into words.
- It will protect them somewhat against wetware routine garbage collection, so that I can come back to them later.
- Lazyweb might surprise. Forking someone on github is saying ["I care"](https://tomayko.com/writings/github-is-myspace-for-hackers).


Before you read the ideas, I'd recommend playing at least one game against the Druid computer player. Doing that will help you realize why this is needed. Download [Druid](https://github.com/masak/druid/) and give it a shot.

## Idea #1: Patterns

Think regular expressions, but for a 2D board game. Patterns match against a local configuration on the board. Instead of matching for word boundaries and character classes, what interests us here are the colors of stones, (and more likely the relative "player's color" vs "opponent's color" rather than the absolute "vertical" vs "horizontal"), the positions of such pieces, and perhaps the distance and direction to the closest friendly edge.

Tied to the patterns could be positive actions (saying "if this situation occurs, try that move"), or negative actions (saying "don't do that move; I know it seems tempting but it's actually rather bad"). There could be positive actions that play out during several successive moves, retaining the state of the action until it has all played out.

Of course, when I said "2D board game" above, I fibbed slightly becuase, as anyone who has tried Druid knows, it's only *mostly* 2D. Sometimes the gameplay makes ambitious excursions into the heavens, dauntlessly saluting higher powers with stunning edifices. Though it's only a hunch, I think that it'd still be a good idea to keep the pattern language in 2D. It will be easier to handle and to reason about, and patterns can be easily visualized using ordinary strings. The cost of "hiding" the 3D will then [waterbed](https://en.wikipedia.org/wiki/Waterbed_theory) into the syntax of the pattern language, and part of the challenge will be to design that wisely.

## Idea #2: Shortest path

This is actually an old idea, but one with merit in connection games. Think of the board as a graph, where each cell corresponds to a node. Furthermore, add your two edges as nodes, giving them the evocative names "source" and "sink", respectively. Neighboring cells are connected through (graph) edges, and the (board) edges are also connected to their adjacent cells.

Now, the act of finding a good move can be seen as evaluating which path you have the best chances of connecting "source" and "sink". It seems a fair bet that a shorter path will have better chances. The friendly and enemy stones already on the board facilitate and obstruct such paths, respectively: a friendly stone can be seen as nuking its own node out of existence, but tying its neighbors together, effectively making the graph smaller in that locality. An enemy stone nukes its own node, deleting its edges in the process, impeding or completely blocking routes through that area.

Now, a shortest path can be found using a [breadth-first search](https://en.wikipedia.org/wiki/Breadth-first_search), starting at "source". I'm asking myself whether *all* shortest paths ought to be found, or just the first one that the BFS happens to come upon. I don't know, but I'm leaning towards the former, on the grounds of general algorithm pessimism.

Also, if this procedure is carried out for both players, we get two sets of "interesting nodes" — the intersection of these two sets intuitively feels like it could contain a good move.

After this basic setup has been made to work, a number of obvious improvements could be made. For example, stones which are two steps apart can still be connected in one move in Druid; by rights, they should have an edge of their own. (And, from the perspective of the opponent, chains trying to make their way between them should be cut off.) The heights come into play here; both those of the positions which are two steps apart (`$a` and `$c`, say), but also the height of a possible enemy tower in-between (`$b`). If `$b > min($a, $c)`, the two towers are disconnected. If `$b == min($a, $c)`, they can be connected, but the position is threatened. Finally, if `$b < min($a, $c)`, the difference `min($a, $c) - $b` says something about the urgency of connecting the towers (the higher the difference, the less urgent), while `abs($a-$c) + 1` gives the required number of moves to do it.

Diagonally adjacent stones, while not *actually* connected, still make fairly secure connections (correspond as they do to the bridge in Hex). If weighted edges are used, maybe diagonally adjacent cells ought to have edges with a real-numbered weight strictly between 1 and 2. (And then [Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra's_algorithm) would have to be employed instead of BFS.)

Lintels, the long pieces in Druid, can be used both for bridging gaps and for stealing territory already claimed by the opponent. So far, I've only described how the shortest-path algorithm can be made to find good moves on unoccupied cells, or good bridges. But it also seems to me that enumerating all possible territory-stealing moves, and then evaluating what happens to shortest paths in each of the cases, might be something worth trying.

## A farewell to ideas

I'd very much like to sit down and spend time on these two ideas. But work must come before play... and even then, I want to have time to look at November and S29 more. Also, right now, I'm implementing `unpack` in Rakudo.

So, see you later, ideas.
