# July 24 2012 — fetching water
    
*Originally published on [25 July 2012](http://strangelyconsistent.org/blog/july-24-2012-fetching-water) by Carl Mäsak.*

It's five months until Christmas, and I'm coding up tests and implementation
for my Raku adventure game to allow me to fetch water from a brook. Life
could be worse. 哈哈

Github, roll the commits!

- [There's now a helmet](https://github.com/masak/crypt/commit/e4f2c0ce868fedf2fd6c6db76cf89daed9f32a56).

- [You can't take it](https://github.com/masak/crypt/commit/ecf3cabe62314a44460b0bfb228e62e668336425) if it's pitch black.

I talked about adding this a few days ago. Now I got around to it.

- [You can't examine it either](https://github.com/masak/crypt/commit/0287a471826dbb117408fe4bad00a01966d6550b) if it's pitch black.

- Let's add [a brook and water](https://github.com/masak/crypt/commit/08d990461038d5301ea14083a6745306f95cc1d9) to the hill.

I feel like a landscape architect here.

- There are two ways to fetch water.

One is the more direct ["put water in
helmet"](https://github.com/masak/crypt/commit/45e6ac87166bf3c461b0344c48be07ec842ea1ed),
which works.

- Some people, however, feel like it should work equally well to put the helmet in the brook and then pick it up again.

They are right; that should work. And [now it
does](https://github.com/masak/crypt/commit/48c757550e531083bb32e825749f3d57cb429d63).

I don't have much to say in the way of comments. Making those commits was very
straightforward. The last one meant a little tinkering around since I had to
add yet another hook/listener. But not so bad overall.

Working this way really feels like "programming in the domain". The events and
exceptions really help in this regard. I want to program more things like this.

Tomorrow we'll use our newly-fetched water to put out the fire. Then we'll have
access to the innermost room... the room after which the game is named... the
*crypt*, where it's silent as a grave, because well, you know.

Not much left now.
