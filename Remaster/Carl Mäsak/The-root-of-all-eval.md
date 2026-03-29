# The root of all eval
    
*Originally published on [22 April 2017](http://strangelyconsistent.org/blog/the-root-of-all-eval) by Carl Mäsak.*

Ah, the `eval` function. Loved, hated. Mostly the latter.

```
$ perl -E'my $program = q[say "OH HAI"]; eval $program'
OH HAI
```

I was a bit stunned when the `eval` function was renamed to `EVAL` in Raku (back in 2013, after spec discussion. I've never felt really comfortable with the rationale for doing so. I seem to be more or less alone in this opinion, though, which is fine.

The rationale was "the function does something really weird, so we should flag it with upper case". Like we do with `BEGIN` and the other phasers, for example. With `BEGIN` and others, the upper-casing is motivated, I agree. A phaser takes you "outside of the normal control flow". The `eval` function doesn't.

Other things that we upper-case are things like `.WHAT`, which look like attributes but are really specially code-generated at compile-time into something completely different. So even there the upper-casing is motivated because something outside of the normal is happening.

`eval` in the end is just another function. Yes, it's a function with potentially quite wide-ranging side effects, that's true. But a lot of fairly standard functions have wide-ranging side effects. (To name a few: `shell`, `die`, `exit`.) You don't see anyone clamoring to upper-case those.

I guess it could be argued that `eval` is very special because it hooks into the compiler and runtime in ways that normal functions don't, and maybe can't. (This is also how *TimToady* explained it in [the commit message](https://github.com/raku/specs/commit/0b7df09ecc096eed5dc30f3dbdf568bbfd9de8f6) of the renaming commit.) But that's an argument from implementation details, which doesn't feel satisfactory. It applies with equal force to the lower-cased functions just mentioned.

To add insult to injury, the renamed `EVAL` is also made deliberately harder to use:

```
$ raku -e'my $program = q[say "OH HAI"]; EVAL $program'
===SORRY!=== Error while compiling -e
EVAL is a very dangerous function!!! (use the MONKEY-SEE-NO-EVAL pragma to override this error,
but only if you're VERY sure your data contains no injection attacks)
at -e:1
------> program = q[say "OH HAI"]; EVAL $program⏏<EOL>
$ raku -e'use MONKEY-SEE-NO-EVAL; my $program = q[say "OH HAI"]; EVAL $program'
OH HAI
```

Firstly, injection attacks are a real issue, and no laughing matter. We should educate each other and newcomers about them.

Secondly, that error message (`"EVAL is a very dangerous function!!!"`) is completely over-the-top in a way that damages rather than helps. I believe when we explain the dangers of code injection to people, we need to do it calmly and matter-of-factly. Not with three exclamation marks. The error message makes sense to [someone who already knows about injection attacks](https://bobby-tables.com/); it provides no hints or clues for people who are unaware of the risks.

(The Raku community is not unique in `eval`-hysteria. Yesterday I stumbled across a StackOverflow thread about how to turn a string with a type name into the corresponding constructor in JavaScript. Some unlucky soul suggested `eval`, and everybody else immediately piled on to point out how irresponsible that was. Solely as a knee-jerk reaction "because eval is bad".)

Thirdly, `MONKEY-SEE-NO-EVAL`. Please, can we just... not. 😓 Random reference to monkies and the weird attempt at levity while switching on a nuclear-chainsaw function aside, I find it odd that a function that *enables* `EVAL` is called something with `NO-EVAL`. That's not Least Surprise.

Anyway, the other day I realized how I can get around both the problem of the all-caps name and the problem of the necessary pragma:

```raku
$ raku -e'my &eval = &EVAL; my $program = q[say "OH HAI"]; eval $program'
OH HAI
```

I was so happy to realize this that I thought I'd blog about it. Apparently the very dangerous function (`!!!`) is fine again if we just give it back its old name. 😜
