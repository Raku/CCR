# Macros progress report: a bit of D1
    
*Originally published on [1 December 2011](http://strangelyconsistent.org/blog/macros-progress-report-a-bit-of-d1) by Carl Mäsak.*

I've not been making much noise about it, but work on macros is progressing nicely. D1 is about providing a `macro` declarator to parallel the `sub` declarator, and a `quasi` construct which creates ASTs... all of that works already, in [a branch of Rakudo](https://github.com/rakudo/rakudo/tree/macros). Try it out! Be the first one on your block to run macros in Raku!

November has been a busy month for me, `$dayjob`-wise. I knew that was going to happen, even though it ended up being even more busy than I had imagined. Now I'm taking a well-deserved two-week vacation, and then I'll be back and actually have some time for Raku hacking. Looking forward to that. 哈哈

A bit of the part of D1 that doesn't work yet: it turns out that there are "interesting" things happening with lexical lookup and quasiquotes. It's actually nothing very complicated, but it requires some extra wiring. So it's actually possible to cause Null PMC accesses right now because variable lookups from inside of the quasiquote end up confused.

I know how to solve this, in theory. ASTs have to start carrying around their own lexical environment. But I haven't had time to actually sit down and type out the solution. Will write more when I've done that. Till then, feel free to play around with the parts of macros that don't do too wild lexical lookups.

Beyond that, I'd like to give D1 a bit of test coverage in roast, and then I think we can merge the D1 work into nom. Looking forward to that.
