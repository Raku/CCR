# Code reviews — a manifesto
    
*Originally published on [14 March 2009](http://strangelyconsistent.org/blog/code-reviews-a-manifesto) by Carl Mäsak.*

It has been famously said that programs should be written for people to read,and only incidentally for machines to execute[1]. I find the value in that saying lies not in its inherent truth — when we finish a piece of code, we normally show it to a compiler/interpreter and not to a fellow human being; and the code is normally executed many more times inside these metal boxes where we keep our Turing machines than inside the wetware where we keep our minds — but in its inherent [truthiness](https://en.wikipedia.org/wiki/Truthiness). The phrase rings true, it wants to tell us something. It wants to tell us that we can write software with a reader in mind. That we can write a story, one which is coherent and connects with the reader much like a novel does. Here's the protagonist; over here's the narrative thread; there's the bad guy, watch out for him.

At this point, the wise reader is nodding and probably thinking "oh yes, comments. I really should write more of those". But it's not about that, it's not about forcing yourself into a frame of mind where you have to document everything your program does. Rather, it's about setting the scene, guiding the reader through rough passages, and filling the lines of text with some higher sense of purpose. Whereas a reader of a novel might find overused expressions jarring, balk at the paucity or overabundance of dialogue, or ask herself "why was that character given so much attention, only to disappear halfway through the book?", a code reader can wonder about unused or badly named variables, comments which befuddle rather than enlighten, antipatterns, copypasted code, or code fossils.

Of course, there are many differences between a novel and a piece of source code, too. Some superficial, some more fundamental. One of the more fundamental differences is perhaps that when a novel reaches us, it's finished, whereas a piece of code can be anywhere between pre-alpha and thoroughly tested and bug-free[2]... but regardless, it's probably not finished. Books, in their current incarnation, get released in a stable state; code, as a rule, lives on in a state of flux. Which means that reading the source code, we can expect to find "TODO" comments, incomplete test coverage, thoughts written down by the programmer for later, inconsistent coding styles, unfortunate last-resort solutions, or simply bugs. Things we do not generally expect to find in a novel. And while on some level all these things are flaws, they must perhaps be accepted as inherent in most code out there. Code, in a very real sense, does not get finished.

There's also a kind of disturbing honesty to code. Sure, a novelist can voluntarily choose to linger at an unpleasant chapter, or outline some mundane process in minute detail... but a programmer *must* do this, must write the truth and the whole truth, because if something is missing, the program won't do what it's supposed to. At best, refactoring can be used to diminish the pain of code drudgery, but not always remove it altogether.

I read a lot of books, but I don't read a lot of code. I would like to change that; I want to be inspired by great works out there. I'm sure I'll find code all over the spectrum, from infra-write-only to ultra-literate. That's ok. There are lessons to be learned regardless.[3]

I would also like, if I may be so bold, to try to inspire the Raku community to do the same. It's still young and small, this community, so maybe such an ambition can have visible impact. Here's what I have in mind: **code reviews**. A bit like book reviews, but adapted to the medium of source code. Recount what you felt and thought as a reader, what you think were the strong and weak points of the code, what you learned, what you would have done differently yourself.

That's what book reviewers do. But since we're in the fluent medium of code in flux, we can do better, and **contribute** to the project we just reviewed. Nothing complicated; a failing unit test or a simple refactor is about the appropriate scale. This, more than anything, says "I have read your code so thoroughly that I can contribute constructively to it." It's also the postmodern thing to do; becoming absorbed and part of the very process you are evaluating.

A community creates itself, often through semi-random processes. Raku is a deliberate redesign of the community, and I deeply believe that as part of that redesign, we should create a habit of **reviewing each other's code**. Software as literature; programmers as authors. And I believe that when we start to think of ourselves as authors, and of our code as something that people will at some point read, we will start writing more purposeful code.[4]

Let's give it a try. I'll go first.

[1] Do you recognize where the quote is from? It's from [this book](https://web.archive.org/web/20010308171622/http://mitpress.mit.edu/sicp/full-text/book/book.html), which you should probably read if you haven't already.

[2] Yeah, right.

[3] [Scott Hanselman](https://www.hanselman.com/blog/CategoryView.aspx?category=Source+Code) already does this. And likely lots of other enlightened people.

[4] This idea is by no means mine. Chapters 5 and 6 in Donald Knuth's [Literate Programming](https://www-cs-faculty.stanford.edu/~knuth/lp.html) do something very similar.
