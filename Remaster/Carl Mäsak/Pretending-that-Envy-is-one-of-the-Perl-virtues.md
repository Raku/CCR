# Pretending that Envy is one of the Perl virtues
    
*Originally published on [13 January 2009](http://strangelyconsistent.org/blog/pretending-that-envy-is-one-of-the-perl-virtues) by Carl Mäsak.*

Sometimes I read parts of `_why`'s [Poignant Guide to Ruby](https://poignantguide.net/ruby/), and marvel at the inimitable writing style, the pedagogical comics, and the balance between explanations and, uh, story. But the other day I read [The Tiger's Vest](https://poignantguide.net/ruby/expansion-pak-1.html), and I realized that we in the Raku community need to be really envious about two things in Ruby, otherwise we're not going provide good enough versions of these two things ourselves.

Actually, I'm not sure we need Envy to do this. It might be that this falls well under Hubris, whose definition (in the Perl context) is as follows, according to [Wikipedia](https://en.wikipedia.org/wiki/Larry_Wall): "Excessive pride, the sort of thing Zeus zaps you for. Also the quality that makes you write (and maintain) programs that other people won't want to say bad things about."

It might well be that we need not look at other languages to excel in this area, but I think that's the easiest way for us to be motivated. It sets a minimum bar, shows what actually can be done. And what more or less *needs* to be done so that people won't say bad things about Raku.

Oh, and the two things? They're simply the two main things `_why` talks about in the chapter: an interactive shell and a documentation tool. Will go into detail about these now.

## An interactive shell

This is not my main point for tonight, so I'll be brief. Rakudo has a REPL. It's — and I don't like to say this because I prefer to say nice things about Rakudo — not very good. Try it, and you'll see. (Just type `raku`, and you're in.) The main thing lacking from it is that you can't declare a variable, hit enter, and then use the variable on the next line.

I understand the technical limitations behind this behaviour; I've had them explained to me. But the explanations just make me want to whisper, really softly, "I want results, not excuses!". Surely Raku isn't so perfectly crystalline in its structure that a proper interactive shell (which, in case I didn't stress this enough, is a *really good thing* to have) is beyond its reach? I have enough motivation to see this happen that I'm willing to personally go ahead and implement an interactive shell that retains its variables between lines. (As soon as I figger out how to overcome the technical limitations, that is.)

Other non-essential but very desirable features of an interactive shell are also mentioned in the chapter: continuation prompts, nesting depth, tab completion. You get the idea. Envy.

## A command-line documentation tool

`raku_why` presents Ruby's documentation tool `ri` with giant brown serifed letters, reverberating with double parentheses as if struck like a heavenly gong. Or as if a chorus of angels were heard from inside of its name, I don't know. It is described in the text, somewhat obliquely, as the "*Most Blatantly Great Thing Since Michael Dorn*". The bottom line is, easily accessible documentation matters.

And it takes time. Not so much writing the script that displays the documentation for a certain class, method, sub, operator, macro or other syntactic feature — that's an important task, but a relatively easy one compared to putting together all the documentation, making sure it looks nice, is complete, understandable and nice to read. In fact, since it takes time, I think we'd better start now.

I hereby pronounce the Userdocs For Christmas project (U4X) started. Our official goal shall be to provide easy-to-access comprehensive user documentation, through a ridiculously easy-to-access command line tool, providing snippets of Raku clarification so perfectly worded and so brilliantly illustrative that the unsuspecting reader will be brought close to tears.

The documentation writing itself will be done in a controlled manner, where "controlled" means that people with tuits get to make sure that things are consistent. All the documentation will be written in Pod, the Raku version of POD. More information will be found in the U4X README file which I just committed to the Pugs repository.

When I look at all the things that are going on in the Raku community right now, I think that Envy really needn't be one of the Perl virtues. It could very well be Pride. But for that to happen in time for the release of Raku.0.0, an interactive shell and exquisitely good documentation are needed. At least if Raku is also to be the most blatantly brilliant thing since Michael Dorn.
