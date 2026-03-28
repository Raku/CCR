# It isn't quite TDD, but I like it
    
*Originally published on [17 June 2010](http://strangelyconsistent.org/blog/it-isnt-quite-tdd-but-i-like-it) by Carl Mäsak.*

In several tightly controlled projects over the past few years, I seem to either follow or approximate this sequence of steps:

- Write a test suite **skeleton**.
- Flesh it out into a **test suite**. (Make the tests run with a minimal implementation skeleton.)
- Make the tests pass by fleshing out the **implementation**.

I haven't seen such a way of working mentioned elsewhere, so I thought I'd make note of it here.

The idea with the first step is to separate most of the thinking from the automatic task of writing the tests. I find if I do this, I get better test coverage, because separation allows me to **retain an eagle-eye view** of the model, whereas if I were to switch back and forth between thinking about the whole and writing about the parts, I'd lose sight of the whole. To some degree. Also, having something to flesh out **cancels out the impulse to cheat** and skip writing tests.

Step two ignores the mandate of TDD to write only one failing test at a time. I still prefer to **have the whole test suite done** before starting the implementation, again because I get rid of some context-switching. Usually I treat the implementation process in much the same way as if I had written the tests on-demand. It occasionally happens that a test already passes as soon as I write the minimal scaffold needed to run the tests. As I currently understand TDD, this is also "frowned upon". I leave them in there, because they're still part of the specification, and might even catch regressions in the future.

I tried this out last weekend, and it was a really nice match with the problem domain — an I/O-free core of a package installer:

- Write a test suite skeleton: [Just a bunch of prose comments](https://github.com/masak/proto/commit/d1123666b0c1954105a6b511166d21f2a2fd8d7c).
- Flesh it out into a test suite: [one](https://github.com/masak/proto/commit/61dc53918176998b25234ecc89af28d736ac46a6) [commit](https://github.com/masak/proto/commit/3612ad05e818e524487657cbd3099b77ec2d988f) [per](https://github.com/masak/proto/commit/1c8c201495a162a330b1ad0a19ae28bce657c920) [skeleton](https://github.com/masak/proto/commit/c7b2b6723d22e8a9a702ce0b7301af7a029f923a) [test](https://github.com/masak/proto/commit/649a7102c53347c4a54edc7d8f030efe62fcae32) [file](https://github.com/masak/proto/commit/11d92fa95fc1c4bcd8cf91d6834258b072655ef9).
- Make the tests pass: [one](https://github.com/masak/proto/commit/44c586b6807480d27e90cd5b138fd8f1aeb60339) [commit](https://github.com/masak/proto/commit/d952250d9a34d966426cb870a53812629b111885) [per](https://github.com/masak/proto/commit/07dcc69a90f61c5e2cac005e74721c07a86d81c1) [subpart](https://github.com/masak/proto/commit/0358c5ba39a822f93da16904773f8ef96be20b92).

And presto, a complete (core) implementation with great test coverage.

Those who follow the links to actual commits will note that mistakes are corrected during the implementation phase. That's a symptom of the haltingproblem-esque feature of code in general; you don't know its true quality until you've run it in all possible ways.
