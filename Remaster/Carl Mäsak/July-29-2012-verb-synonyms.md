# July 29 2012 — verb synonyms
    
*Originally published on [30 July 2012](http://strangelyconsistent.org/blog/july-29-2012-verb-synonyms) by Carl Mäsak.*

I'm now the janitor in my own code, having switched from "let's implement
feature X" to "let's make it all fit nicely together". Needless to say, there
is some technical debt in there to repay.

- Playing the game, I noticed that I can't actually `take tiny disk` on the
CLI, something that would be necessary to win the game.

I [fixed
that](https://github.com/masak/crypt/commit/ecdc8a1383fce9e6d9d03b85af743b8dc3ae3864).

- I moved the abbreviated-directions logic [into the adventure engine itself](https://github.com/masak/crypt/commit/4b750afb4cfe34dcf1f58cd4ea7fcdb12d0f866e)

Because I figure it belongs there. Better for the engine to recognize even
abbreviated directions than for the CLI to munge it.

- Taking *lue*++'s suggestion on channel, I [wrote a short grammar](https://github.com/masak/crypt/commit/51cbe97931f4dd4a85f0846b7e1072dad043c39c) for parsing commands for the adventure game.

- Going through the code in this way, I realized that there's a `.hide` method in the adventure engine.

I used it to [hide the
fire](https://github.com/masak/crypt/commit/48e2a6f4b01c22117dabb3362805fa040753f479)
when extinguished, instead of moving it to a made-up location "nowhere".
Cleaner.

- Playing the game some more, fixed [some subtle things](https://github.com/masak/crypt/commit/f1219e1c1ca8ad49099e4656c76d7377a900ffff)

Having to do with when things are visible or listed.

- The game used to say "There is a car here.", but now it says "Your car is parked here."

Such thing-specific overridings [are now
handled](https://github.com/masak/crypt/commit/44ef4e38fa47a69830a54ed51f85b53c293ab56c)
through a separate namespace in the `descriptions` file. Much cleaner than last
year's solution. Actually, the event-based approach is *forcing* many of these
"much cleaner" solutions, because it's harder to mix levels.

Another example of the latter is the "remark" system &mdash; lots of
game-specific remarks that the game made during various stages. All of these
were spread over last year's codebase as literal strings. Now they are all in
the `descriptions` file, too. It wasn't so much that I decided to do it that
way; I basically *had* to do it that way. Which is nice.

There's more to say, and more refactors to do. But I'll save some for tomorrow
and the day after.
