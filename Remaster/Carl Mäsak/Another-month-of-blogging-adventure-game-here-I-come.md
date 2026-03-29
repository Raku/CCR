# Another month of blogging: adventure game, here I come!
    
*Originally published on [1 July 2012](http://strangelyconsistent.org/blog/another-month-of-blogging-adventure-game-here-i-come) by Carl Mäsak.*

Last summer I spent a month [blogging about basic programming](A-month-of-blogging-about-programming-fundamentals.html),
building stuff up out of small building blocks into bigger and bigger games.
The exercise was modeled on some books I liked when I was a teenager and
curious about programming.

The last game was a text adventure game. It became... big. More ambitious than
I had planned.

It's not that it had that many rooms or was that long. It didn't even
experience feature creep. It was just a fairly big and ambitious game. I
finished it, but more than half a month after I had planned. In retrospect, it
was insane to assume I would be able to write it in the last two days of that
month of blogging. Dedicating a whole month to writing the adventure game would
have been more appropriate.

So, that's what I will do. I will write *exactly the same game* over the scope
of a month. Well, functionally it will be the same. The details of the
implementation will be different. Better.

We will learn a lot together, dear reader. Things that got lost in a sea of
details last year.

What's more, there are a couple of other advantages with doing this all over
again:

- There's a certain amount of artistic suffering in writing text descriptions
and coming up with a plot and all that.

Since I'll be doing the same game, I
won't have to do that, I can just re-use everything from last year. Might put
in the odd improvement, of course.

- I [realized last year](What-i-learned-from-the-june-blogging.html)
that I really should have written this game with Test-Driven Development.i

I will this time around. Not only that, you will see the domain-oriented TDD
that I prefer nowadays, and that really should be more well-known. This
approach really makes you *understand* object orientation. At least that's
the effect it has on me.

- In retrospect, I don't think I should have leaned so hard on type system.

I used roles a lot last year, like `Openable`. And then mixed them
into classes, like `Door`. It seemed like a good idea at the time, but it
does make the whole object model a little inflexible and, well, static. This
year around I'll try something else, and I think it'll come out better and
more dynamic, while at the same time more light-weight. I think you'll like
it better.

There will be zillions of spoilers for the actual game. If *you* know a way to
give a detailed public account of how to implement an open-source adventure
game without giving away the whole plot, get in touch.

Until I conclude this blogging month, there will be an ongoing mini-contest
known as "Devastate The Adventure Game". Basically, you download the game and
run it on Rakudo. If at *any* point during its development you manage to get
the game to behave outside of its intended parameters, you're in the contest. I
want to hear about all instances of this, and I'll do my best to log them all
publicly. The most insane, creative, simply up-the-wall fruit-bat bananas
mis-use of the game (decided by me; any number of entries per person) wins an
Amazon book worth about 50 EUR. Crazy stunts may get honorable mentions in
the blog posts, too.

Suddenly this feels pretty exciting. 哈哈 Come on folks, nail the masakbot!

Oh, and I wrote a plan for the whole month. Subject to change, but the basic
structure is hopefully there.

- [2012-07-01](July-1-2012-hanoi-as-a-black-box.html): describing the hanoi subgame; methods/events/exceptions
- [2012-07-02](July-2-2012-implementing-hanoi.html): implementing the hanoi subgame
- [2012-07-03](July-3-testing-the-adventure-game-looking-around.html): testing the adventure game, looking around
- [2012-07-04](July-4-moving-around-i-compass-directions.html): moving around I (compass directions)
- [2012-07-05](July-5-moving-around-ii-up-down-in-out.html): moving around II (up/down, in/out)
- [2012-07-06](July-6-room-descriptions-look.html): room descriptions (look)
- [2012-07-07](July-7-saving-and-restoring.html): saving and restoring
- [2012-07-08](July-8-blocked-exits.html): blocked exits
- [2012-07-09](July-9-things-and-descriptions.html): things and descriptions
- [2012-07-10](July-10-2012-things-which-can-be-opened.html): things which can be opened
- [2012-07-11](July-11-2012-things-which-contain-other-things.html): things which contain other things
- [2012-07-12](July-12-2012-platform-things.html): platform things
- [2012-07-13](July-13-2012-things-which-you-can-read.html): things which you can read
- [2012-07-14](July-14-2012-hidden-things-which-can-be-revealed.html): hidden things which can be revealed
- [2012-07-15](July-15-2012-things-which-can-be-carried-around.html): things which can be carried around
- [2012-07-16](July-16-2012-things-which-are-part-of-the-scenery.html): things which are part of the scenery
- [2012-07-17](July-17-2012-getting-things-from-the-car.html): getting things from the car (car, rope, flashlight)
- [2012-07-18](July-18-finding-the-door-in-the-grass.html): finding the door in the grass (grass, bushes, door)
- [2012-07-19](July-19-filling-your-car-with-leaves.html): filling your car with leaves (trees, leaves)
- [2012-07-20](July-20-putting-the-leaves-in-the-basket.html): putting the leaves in the basket (sign, basket, walls)
- [2012-07-21](July-21-2012-its-too-dark-in-here.html): it's too dark in here! (can't see, turn on the flashlight)
- [2012-07-22](July-22-2012-playing-the-hanoi-game.html): playing the hanoi game (walls, all the disks)
- [2012-07-23](July-23-2012-being-blocked-by-the-fire.html): being blocked by the fire (fire, walls)
- [2012-07-24](July-24-2012-fetching-water.html): fetching water (brook, water, helmet)
- [2012-07-25](July-25-2012-putting-out-the-fire.html): putting out the fire
- [2012-07-26](July-26-2012-doom-and-cavern-collapse.html): doom and cavern collapse
- [2012-07-27](July-27-2012-triggering-doom-and-dying.html): triggering doom and dying (pedestal, butterfly, walls)
- [2012-07-28](July-28-2012-moving-around-iii-movement-synonyms.html): moving around III (movement synonyms)
- [2012-07-29](July-29-2012-verb-synonyms.html): verb synonyms
- [2012-07-30](July-30-2012-tying-up-various-loose-ends.html): tying up various loose ends
- [2012-07-31](July-31-2012-the-finished-game.html): the finished game


Stand by, blog post number one is already in the pipeline.
