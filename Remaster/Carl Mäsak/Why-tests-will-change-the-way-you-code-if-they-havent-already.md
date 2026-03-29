# Why tests will change the way you code (if they haven't already)
    
*Originally published on [27 August 2011](http://strangelyconsistent.org/blog/why-tests-will-change-the-way-you-code) by Carl Mäsak.*

A dear colleague of mine keeps saying things like "I'll just do a few tests", or "I'll need to carry out these tests". It throws me off practically every time.

You see, I've been so completely swallowed up by the Unit Testers' Underground Movement, that to me these perfectly reasonable phrases sound slightly... *wrong*. You don't *do* tests, you *write* them. You don't *carry out* tests yourself, you have the computer run them *for* you.

Clearly my indoctrination has been effective, when conversation that sounds completely correct to my colleagues sets off silent alarm bells in my mind. I'm all like, "they're using the word "tests", to mean *what*? Manual testing?" (Nothing wrong with manual testing *per se*. It's a good tool in your toolbox. And ad-hoc tests often produce some of the best unit tests.)

There's a reason my mind ended up in this twisted state. We'll get to that.

For a number of years now &mdash; I don't actually remember how many &mdash; I've been quitting IRC with the message "tests rock!". I always type this message out, no automation involved. (Yes, I do see the sweet irony there.) Consider it my green wristband, if you like.

There's a reason I keep writing that, too. You see...

Tests rock. They truly and utterly rock.

I'll explain, and you might not believe me. I am after all, dear reader, trying to indoctrinate *you*, just as I was once the victim of the Unit Tester's Underground Movement's corrosive propaganda. You'll resist, you'll fight, but eventually we'll get you too. Resistance is futile, unless there's a unit test for it somewhere.

If you let down your guard even a little, you'll start discovering the **three benefits**, one by one. And then there's really no turning back &mdash; you'll be test-oriented before you can say "but I don't have time to write tests".

Mwhahaha.

## First benefit

It all begins so innocently. You're thinking "hey, I keep pressing the <up> arrow in my shell a lot, just to run the same test code all over again". So you decide to exercise some laziness, and put all your testing snippets in a file somewhere. Or a group of files, whatever.

This is the first benefit: by treating tests as program code, as something more permanent than just a shell command somewhere, you're unwittingly building up **a list of things that are true about your program**. That's all that unit tests really are: an executable list of assertions in a file somewhere. And then &mdash; oops &mdash; you checked it into your repository, too! Now other people can run those same tests. Fancy that.

In order to completely obviate the <up> arrow, I've come up with a small harness that runs all of your tests as soon as you hit Save in your editor. It has the same kind of addictive effect as does a good game: it sucks you in and keeps you there. I've written about it [here](Helpfully-addictive-tdd-on-crack.html) and [here](some-thoughts-on-tote.html); a small prototype of it can be found [here](https://gist.github.com/masak/834500).

## Second benefit

Of course, while this sounds trivial on paper, you actually don't want your tests to go wreak havoc with your production database, or send emails to customers, or whatever. Basically, you want to exercise all the important program logic while still having the program be side-effect-free. The Unit Testers' Underground Movement have had great successes in this department, deviously convincing people that testing is *so important* that it actually makes sense to "de-couple" the pure business logic from the different kinds of side effects.

Think of your normal application as a giant octopus. It has a brain, and it has arms. The tests want to interact with the brain without getting tangled up in the arms. With the correct decoupling, the brain can be lifted out and placed in a vat in a laboratory, and a set of *virtual* octopus arms can be plugged in. So the octopus brain still *thinks* it has all of its arms, and when it sends signals to flex them, the virtual arms happily send back signals of movement as if they were real, physical arms.

Coders do this kind of thing under various slightly overlapping names: dependency injection, mocks, fakes, stubs... They do this, and as an annoying little side effect of doing this, they just *have* to factor their code to be receptible to this kind of octopus plug-and-play behavior, and thus also more modular. How insidious.

You might think that this modularity is the second benefit. It's not. Good modularity is just common sense for a big system. It *is* a nice side effect of tests, though.

No, the second benefit is this: [it's been said](https://www.youtube.com/watch?v=aAb7hSCtvGw) that your [API](https://en.wikipedia.org/wiki/Application_programming_interface) won't be really stable/usable until you've made it work with three different clients. Usually, the application itself, or some component of it, or some component near it, makes up the first client. With the test, **you immediately have a second client**. That's well on your way to having three clients.

This is more important than it might at first seem. As a second client (or a first client, depending how you see it), tests will put you in the habit of thinking about the interface up front. Yes, [that thing](https://en.wikipedia.org/wiki/Object-oriented_user_interface) that your OO teacher went on about: the outwards-facing layer that the external world gets to interact with to get to query or modify the internal, heavily protected gooey stuff in the middle. It's true for the objects of your application, but it's also true for your whole application, even a non-OO application. You just need to momentarily view the application as a single coherent object. To me, that's what object-orientation really *means* nowadays: coming up with a decent interface behind which to hide the internal gooey stuff.

Put differently, the tests *make* you think about and design your interfaces. The face of design [changes from one of invention to one of discovery](https://www.jmock.org/oopsla2004.pdf).

The tests push the buttons and twist the dials on the outside of the machine without opening it up. So your first order of business is to make sure that all the right buttons and dials are there. When you feel like it, you could switch out the out-moded transistor innards for contemporary circuitry. The tests don't care, they just care about the buttons and dials on the outside.

And it's *because* the tests are internals-agnostic that you dare make such a crazy leap from transistors to circuits. Would you have made such a daring move before you had tests? Heavens no, something important might *break*! (A revision system helps greatly here, too.)

At this point, you're hooked on two of three benefits. You're already getting that glassy-eyed look, as if there's a chance you might just tell a random stranger on the street about test-driven development. You're starting to suspect that the Unit Testers' Underground Movement actually is a real movement.

## Third benefit

This is when the third and final benefit triggers, if it hadn't already. And I'm really sorry to report this, but when it does, you're a goner. There's just no going back after that.

You see... oh, how shall I put this? These test files, these dumb, inert lists of assertions about your program, they **find bugs for you**. Since they run your program as often as you want, with the simple-minded patience of a computer, testing every little thing you ever thought of during your brightest moments, they find your bugs **before you do**! At this point you might have accrued hundreds or thousands of individual tests in dozens or hundreds of files. They all just tirelessly iterate through everything that could conceivably go wrong with your program, and try it out without your having to lift a finger. The command line can go <up> itself.

And, boy, do the tests find bugs. Your reaction the first few times this happens will range from "oh right, forgot about that other bit" to "oh dear... that would've been embarrasing, wouldn't it?". Then you get used to the tests being a bit ahead of the curve.

When the third benefit started hitting me hard, when I had begun to use tests so much that they actually began reporting bugs for me in this way, I got to thinking that maybe I was becoming soft and careless due to having all those tests. Maybe the safety net that the tests provide had made me think less about the correctness of the code I was writing.

Then I realized that the bugs the tests were finding for me corresponded to bugs that I never found in my older programs, or bugs that came back later and bit me hard when I least needed it.

It's been said that an ounce of prevention is worth a pound of cure. *This is where it all pays off*. If you thought that all that explicit test writing and dependency injection and mocking and all that stuff was a bit, you know, tedious &mdash; this is where it all pays off in reduced debugging time. Just to see why, let's run a few common scenarios with our test-colored glasses on:

- **Does the program work?**

Run tests. **Green**? Yes, it works. **Red**? No, it doesn't work.

- **Will this change break something?**

Run tests. **Green**? No, the change is fine. **Red**? Yes, it broke something.

- **If I add this new feature, do the old features still work?**

Write a test for your new feature. Code until it turns from **red** to **green**. Run all the tests. **Green**? Yes, the old features still work. **Red**? Well, something broke, and you're really happy to realize this *now* rather than later, during a customer demo or something.

Making changes/additions without unit tests? Well, you would either have to proceed very slowly, possibly doing a lot of tiresome debugging anyway &mdash; or you might just never consider them as something that you would dare do to the application. *Sans* tests, it's far too easy to have technical debt pile up into such tall, insane piles of [Jenga blocks](https://en.wikipedia.org/wiki/Jenga) that pulling out another block just isn't considered. There's something immensely refreshing about how care-free you can be with tests backing you up.

## Conclusion

This is why I write tests. They're to a programmer as swimfins are to an underwater diver &mdash; sure, you can jump into the fray without them, buy you won't move as fast or as accurately. Or as far.

To summarize, these are the three benefits of tests, as I see them:

- Tests are simply static versions of various checks that you would've (or, as they grow, should've) run anyway.
- Tests provide you with a "second client" for free, and a very diligent client at that.
- Tests find bugs in your code before you do. It's awesome.

May your unit tests be fruitful and multiply. You can reach me by email to learn the secret handshake of the Movement. `;-)```
