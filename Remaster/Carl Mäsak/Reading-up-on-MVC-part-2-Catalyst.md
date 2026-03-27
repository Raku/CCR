# Reading up on MVC, part 2: Catalyst
    
*Originally published on [10 July 2009](http://strangelyconsistent.org/blog/reading-up-on-mvc-part-2-catalyst) by Carl Mäsak.*

I was pleasantly surprised by the relatively large number of comments to [my first MVC post](Reading-up-on-mvc-part-1-ruby-on-rails.html). Either people are very interested in MVC in general, and have things to say about it, or there's some reverse psychology going on in starting a post with "don't mind me".

Just in case it's the latter... **don't mind me** this time either. In fact, if anything, I seem to have gotten even more ignorant and directionless since last time. MVC frameworks are hard, let's go shopping!

Reviewing Catalyst. I found this screencast a couple of weeks ago. Here are my impressions while watching it:

- It's nice to have a skeleton of the application generated for you. Can be taken to extremes, of course, but the general idea is sound.
- Compared to the Rails screencast, this one cheats a bit on details. It skips parts of the installation process. It says "there's really no excuse not to document your code any more" but then doesn't fill in the blanks.
- It also (unconsciously) presupposes a lot of prior knowledge. Example: "The index method does the actual handling of requests for the root path. It has two attributes: :Path and :Args. We specify that it handles all paths (because there is nothign like '/foo' after :Path), and it takes no arguments off of the stash." I see. What's the stash?
- The debug screen is nice. It makes good use of the terminal.
- Suddenly, the screencast is over. It refers to a Part 2, but there's no Part 2 yet.
- Overall impression: Catalyst is an application that lets me dispatch on URLs. I'm sure there must be more to it than that.


I also stepped through the slides about [chained](https://www.slideshare.net/jshirley/catalyst-and-chained), since I've gotten good vibes about those, but don't really grok them yet. I'll have to come back to it, because I didn't understand everything in it yet.

After both of these, I still feel very much in the dark about what makes Catalyst great. I almost feel as if I'm starting at the wrong end. I had a chat with the good people over at #catalyst, and they advised me to buy [the book](https://www.amazon.com/Definitive-Guide-Catalyst-Maintainable-Applications/dp/1430223650), which I did. Hopefully it will quench my thirst for knowledge.

Next up: Django.
