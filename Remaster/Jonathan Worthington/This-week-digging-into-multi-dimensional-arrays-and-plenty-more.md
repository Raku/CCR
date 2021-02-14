# This week: digging into multi-dimensional arrays – and plenty more
    
*Originally published on [2015-07-09](https://6guts.wordpress.com/2015/07/09/this-week-digging-into-multi-dimensional-arrays-and-plenty-more/) by Jonathan Worthington.*

This report covers what I got up to during the closing days of June and the opening days of July.

### Multi-dimensional array support in MoarVM

I’ve been pondering how to approach the multi-dimensional array aspects of the S09 Raku design document for a while. I started out the implementation phase by taking another pass through the document, with an eye for things that were likely to hurt, or simply that did not fit with the current Raku language as we have it today. That resulted in [a gist that I tossed in Larry’s direction](https://gist.github.com/jnthn/fa6a9a3618ae322cb581). Thankfully, nothing in that list was a huge blocker for getting the majority of the work done. With the top-down bit of out the way, it was time to move on to the bottom-up. MoarVM’s opset wanted a few additions, the representation API wanted a few extensions, and a new representation (named MultiDimArray) was needed. To recap, a representation is a memory allocation, layout, and access strategy, and is one half of what makes up the Raku notion of “type” (the other half being the meta-object, which cares for all the high-level, VM-independent bits like method dispatch and type relations). Gradually, I test-drove my way through implementing the new multi-dimensonal APIs on the existing 1D dynamic array representation, then started to flesh out the new multi-dimensional representation. By the end of the week, I had the majority of it in place. The new representation can happily, for example, store a 10x10x10 array of 8-bit integers in a single 1000-byte blob. To come is filling out a few more missing pieces, the JVM port of these new guts (thankfully with a nice set of tests to guide the way), and then onwards and upwards to making use of it all at Rakudo level, so we can have multi-dimensional array support in Raku.

### Another pre-compilation bug nailed

One of the most annoying kinds of bugs people run into are pre-compilation bugs: ones where your modules work fine, but a version of the module pre-compiled to bytecode breaks in some way. While that’s not always the compiler’s fault (for example, if you monkey-patch recklessly, or meta-program carelessly), most of the time it is. This week I hunted down a bug involving variables typed with subset types running into pre-compilation issues. Thankfully, it wasn’t overly difficult to fix once I worked out what was going on – but most happily, it was also the pre-compilation bug afflicting Text::CSV. It now works just fine pre-compiled.

### A few tasks down in the regex engine

For a while, there’s been some debate of the failure semantics of the goal-matching syntax. That is, should:

```` raku
/'(' ~ ')' \d+/
````

Backtrack on not finding the closing parentheses, as if you’d just written:

```` raku
/'(' \d+ ')'/
````

Or should it throw an exception? Now, all of the uses of this construct in the Raku grammar want the exception semantics. So, that’s the behavior we’ve had. However, it was argued (on a few occasions over the years) that this was not a desirable behavior for using the construct in normal regexes. My argument was always, “so just write it the other way” – but after enough tickets on the issue it was time for a review. *Patrick Michaud* wrote up a possible way forward a while ago, and this week I ran that by *Larry*, who agreed we’d change things. So, I set about putting the change into effect. Here, the design of the goal matching error mechanism came in handy. Actually, the syntax:

```` raku
/'(' ~ ')' \d+/
````

Desugars to:

```` raku
/'(' \d+ [ ')' || <.FAILGOAL(')')>]/
````

And the `FAILGOAL` method threw the exception. So, the behavior change simply meant adding:

```` raku
token FAILGOAL($missing) { <!> }
````

The compiler toolchain already overrode `FAILGOAL` to throw a more helpful exception, so things continued to work for the Raku grammar’s own needs. The only folks left in the middle are those using the goal matching syntax who wanted the exception. Thankfully, that’s easy to get back in your own grammars:

```` raku
method FAILGOAL($missing) {
    die "Oh noes, I needed a '$missing'";
}
````

I also fixed another obscure, but potentially infuriating bug involving a mis-guided optimization. I’ll just reference [RT #72440](https://rt.perl.org/Ticket/Display.html?id=72440) and the [patch that fixed it](https://github.com/raku/nqp/commit/5263e63464d410738c812ff72ebb0a5cacd71668).

### More failure mode improvements

Here’s a selection of things I did related to improving error reporting, to improve overall user experience:

- Fix RT #125120 (bad error reporting if you declared a type X then made a syntax error)
- Fix RT #108462 (missing redeclaration checks)
- Fix RT #125335 (lack of escaping in error message about illegal numification)
- Fix RT #125227 (trait warnings pointed to useless internals line, not relevant position in the source code)
- Implement RT #112922 (catch impossible default values on parameters at compile time)
- Add test for and resolve RT #123897 (bad error reporting, improved by implementing RT #112922)

### And finally…

There’s the usual collection of things not worth a headline mention, that that are gladly dealt with.

- Fix RT #125505 (getting `Capture` elements stripped away `Scalar` containers)
- Working on RT #125110 (leading combining characters mis-handed in `Str.raku`) and unfudge tests, plus further fixes to combining chars and `Str.raku`
- Fix RT #125509 (`===` didn’t work on `Complex`), plus a few other issues observed with `===`
- Add test coverage for RT #115868, plus improve the two errors that are produced
- Fix RT #116102 (`ENTER` phaser did not work as an r-value)
- Add test coverage for RT #125483 (the `;;` syntax actually influences mutli-dispatch when placed prior to the first parameter)
- Update test now `my ${a}` is parsed as legal Raku (allows anonymous hash with key type declarations)
