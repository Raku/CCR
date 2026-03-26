# November 29, 2008 — "I will call it 'the graphophone'!"
    
*Originally published on [30 November 2008](http://strangelyconsistent.org/blog/november-29-2008-i-will-call-it-the-graphophone) by Carl Mäsak.*

131 years ago today, Thomas Edison demonstrated for the first time a device he called a "[phonograph](https://en.wikipedia.org/wiki/Phonograph)", which plays back recorded sound. [Wikipedia](https://en.wikipedia.org/wiki/Phonograph#First_phonograph):

> Edison's early phonographs recorded onto a tinfoil sheet phonograph cylinder using an up-down ("hill-and-dale") motion of the stylus. The tinfoil sheet was wrapped around a grooved cylinder, and the sound was recorded as indentations into the foil. Edison's early patents show that he also considered the idea that sound could be recorded as a spiral onto a disc, but Edison concentrated his efforts on cylinders, since the groove on the outside of a rotating cylinder provides a constant velocity to the stylus in the groove, which Edison considered more "scientifically correct". Edison's patent specified that the audio recording be embossed, and it was not until 1886 that vertically modulated engraved recordings using wax coated cylinders were patented by Chichester Bell and Charles Sumner Tainter. They named their version the Graphophone. Emile Berliner patented his Gramophone in 1887.

Dang, I kinda liked the sound of "graphophone". 哈哈

Today, in order to reduce some of the [repetitiveness](https://github.com/viklund/november/tree/d58040420ba34561cf8213dfa96455cb5e7b5c7c/p6w/t/markup/mediawiki/07-italic-and-bold.t) of the MediaWiki markup parser test suite (set input, set expected output, calculate actual output, test, rinse, repeat), I created the module [`Test::InputOutput`](https://github.com/viklund/november/tree/mediawiki-markup/p6w/Test/InputOutput.pm), which resembles CPAN's `Test::Base` a bit, minus the syntactic relief. Some of the MediaWiki tests now look [like this](https://github.com/viklund/november/tree/f882a653455e6eb3370f4c997fac6b52d02a2726/p6w/t/markup/mediawiki/07-italic-and-bold.t) instead. Typical example of separating the algorithm from the specifics.

Since that wasn't what I set out to do today, I'm going to stop here, and do that instead. I want to continue passing tests concerning italic and bold.

Also, *ihrd*++ merged his dispatch branch today into master, so I'll review that merge.

In short, if you haven't downloaded November yet, you should. If nothing else, there's a lot of working Raku code to look at. It's not even hard: look, [a link](https://github.com/viklund/november/)! The kind folks over at github even provide a [zipball](https://github.com/viklund/november/zipball/master) and a [tarball](https://github.com/viklund/november/tarball/master) for those who don't have git yet. That's what I call service.

Enjoy!
