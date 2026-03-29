# When I don't even feel like using blame
    
*Originally published on [6 June 2015](http://strangelyconsistent.org/blog/when-i-dont-even-feel-like-using-blame) by Carl Mäsak.*

The other day we ran into a bug in the following code in the Raku setting:

```raku
multi method sign(Real:D:) {
    self < 0 ?? -1 !! self == 0 ?? 0 !! 1
}
```

Kudos to you if you automatically start poring over the cases in that function,
trying to see which one is the wrong one. You won't find it though.

The function implements what is more or less the mathematical definition of the
`sign` (or `sgn`) function:

```
          /
          | -1      if x  < 0
          |
sign(x) = |  0      if x == 0
          |
          | +1      if x  > 0
          \
```

The method does exactly this. So what's the problem?

Right, `NaN`.

Before the bug was fixed, you'd get this, which is surely wrong:

```
$ raku -e 'say sign(NaN)'
1
```

Oh, and this is what the fixed code looks like:

```raku
multi method sign(NaN:)    { NaN }
multi method sign(Real:D:) { self < 0 ?? -1 !! self == 0 ?? 0 !! 1 }
```

(That is, original method remains the same, but a new multi candidate handles
the `NaN`-invocant case.)

And now it does the right thing:

```
$ raku -e 'say sign(NaN)'
NaN
```

I'm trying to come up with an appropriate emotion to go with this kind of bug.
It's hard to muster any strong sentiment either way, but I think it's
appropriate to say I'm sick of this kind of bug. I wish it were a thing of the
past. It feels like it should be a thing of the past.

See, the code *looks* right. It's based right off of the mathematical
definition of real numbers. The only slight mistake the original author made
was briefly forgetting about the strange numeric value IEEE 754 specifies
called "not a number" (`NaN`), which demands to be taken into account when
doing this kind of exhaustive case-matching.

Don't get me wrong. `NaN` is there for a reason, and I'm not clamoring for its
removal. The IEEE 754 people certainly had their hearts and their heads in the
right place. They got a lot of things right, including the inclusion of `NaN`.
There has to be something that's returned when you take the square root of
negative 1, or multiply zero with infinity, or try to find a limit which
doesn't exist.

No, what frustrates and exhausts me is that *it's 2015, and we're still
creating bugs rooted in lack of exhaustive case-matching*. This should be
*a solved problem* by now. We ought to have moved on to more interesting
challenges.

And indeed, solutions exist out there. There are linters that will point out
when you've left out an important case. (Not for Raku, yet, but there's
nothing to stop us from having one.) Some languages have case statements over
enum types where you're not *allowed* to leave out a case. Nowadays we also
handle things with `Maybe` or `Option` types.

These things are not even fancy new technology at this point. They're proven to
work, and to improve the incidence of thinkos and the quality of code. If we're
not equipped with a language (or tooling) that checks this stuff for us, we're
part of a rapidly shrinking unfortunate majority. If we're not looking to *fix*
that in our home language, we're increasingly irresponsible and reckless.

This is what computing machines are good at! Enumerating cases! We should be
having them do that all the time, on our business-critical code. Or,
conversely, just writing code without the safety net of full enumeration of
cases should be rightly recognized as belonging with other barbaric development
practices of the mid-20th century, surely caused by extreme scarcity of memory
or CPU, but which we have &mdash; ought to have &mdash; grown out of by now.

But... *sigh*... yes, the code looks right. Which is why I don't particularly
feel like running `git blame` on it this time.

Maybe the code snippet was even code-reviewed, and someone had looked at it,
nodded, and (at some more or less conscious level) noted that the code aligns
perfectly with the mathematical three-case definition. A real number is either
smaller than, equal to, or greater than zero. Sure, we know that! This
hypothetical code reviewer did not have alarm bells go off just becase the case
of `NaN` wasn't considered.  Because `NaN` is an exception, a fairly uncommon
one, and humans enjoy thinking about happy paths.

A lot of what constitutes "experience" in a developer seems to be installing
these alarm bells in prominent places in one's brain, so that one can write
code that's "robust" in the face of unusual values and unhappy paths. Two other
such cases spring to mind:

- [Null pointers/references](https://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare).
- [NULL values in SQL](https://blogs.perl.org/users/ovid/2013/02/three-value-logic-in-perl.html).

(And indeed, `NaN` is a kind of "null value" for floating-point numbers.)

But it's also about considering edge cases in general. What if the list is
empty when we ask for an element? What if the network is unavailable when we
try to access a web service? What if the player can exceed 2,147,483,647 points
in the game? Things like this *can*, and *should* be checked automatically, by
the machine, as we developers worry about higher levels of abstraction.

Don't settle for less. Let the machine check that we've considered all the
cases.
