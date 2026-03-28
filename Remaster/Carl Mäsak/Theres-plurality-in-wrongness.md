# There's plurality in wrongness
    
*Originally published on [15 February 2011](http://strangelyconsistent.org/blog/theres-plurality-in-wrongness) by Carl Mäsak.*

It was the hackathon after NPW 2009 in Oslo. mberends and I were placed in
front of the same screen-and-keyboard in order to provide Rakudo with an
`IO::Socket` implementation. We already had some Parrot code that worked,
but we wanted to have it as Raku code, or mostly Raku code.

"Let's change it little by little until it's a Raku class," decided mberends.
"**It's easier to start from something that works and notice when it breaks,
than it is starting from something that doesn't work and trying to make it
work.**" (Emphasis mine. mberends said it matter-of-factly, not extra boldly.)

The hacking session went like a breeze. As I recall, we did indeed have a few
failures along the way, but in each case we were but a permutation or two from
the main path where things worked. Had we started from the other end, with
squeaky-clean Raku code, we would likely not have connected the dots that
day. Overwhelmed by permutations.

The dictum has somehow stayed with me, and I'm reminded of it now and then.
It's a fairly general principle, and natural selection employs it all the time,
always starting with a clean batch of living specimen for the next mutation
experiment. (Though I can't find the quote right now, some biologists has
said something to the effect of "The number of ways to be alive is vastly
smaller than the number of ways to be dead.")

In Configuration Space, the configurations that we appreciate run like a thread
through a sea of chaos, error conditions, and wrongness.

In some sense, eXtreme Programming, TDD, Scrum, and Continuous Integration all
make use of this principle too: always keeping one foot on the path of Working
while exploring the jungle ahead.

Even such a simple thing as Unix exit statuses speak to the fact that while
success is singular, failure is many-flavored and multitudinous.
<div class='quote'>"All happy families resemble one another, each unhappy family is unhappy in its own way." &mdash; Anna Karenina</div>

The other day I was reminded of the principle in yet another guise. While
tinkering with Yapsi, I found a program that compiled even though it shouldn't.
Obediently, I added it to a test file containing programs that shouldn't make
it through compilation. (That is, "ok" means "indeed doesn't compile".)

To my surprise, the test passed, i.e. the compiler choked on the program.
This was surprising indeed &mdash; I had just run it on the command-line
without a problem. Suspicious, I added some logging to reveal the errors the
compiler gave for each failing program.

Turns out the errors were themselves mostly erroneous, and that the compiler
was suffering from a nasty case of state bleedover between individual
compilations. Once I was aware of that, the problem in the code was easily
fixed... but the bigger issue was that the tests were satisfied with asserting
that "this program fails... somehow".  I fixed the test file to actually match
the error message in question as well.

There are many ways to fail. Therefore, a test checking for failure may not
succeed for the reason you think. Even failing successfully is an art.
