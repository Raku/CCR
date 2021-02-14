# What one Christmas elf has been up to
    
*Originally published on [2015-11-20](https://6guts.wordpress.com/2015/11/21/what-one-christmas-elf-has-been-up-to/) by Jonathan Worthington.*

Here’s a look over the many things I’ve been working on in recent weeks to bring us closer to the Christmas Raku release. For the most part, I’ve been working through the tickets we’ve attached to our “things to resolve before the Christmas release” [meta-ticket](https://rt.perl.org/Ticket/Display.html?id=123766) – and especially trying to pick off the hard/scary ones sooner rather than later. From a starting point of well over 100 tickets, we’re now down to less than 40.

### NFG improvements

If you’ve been following along, you’ll recall that I did a bunch of work on Normal Form Grapheme earlier on in the year. Normal Form Grapheme is an efficient way of providing strings at grapheme level. If a single grapheme (that is, thing a human would consider a character) is represented by multiple codepoints, then we create a synthetic codepoint for it, so we can still get O(1) string indexing and cheaply and correctly answer questions like, “how many characters is this”.

So, what was there to improve? Being the first to do something gives a low chance of getting everything right first time, and so was the case here. My initial attempt at defining NFG was the simplest possible addition to NFC, which works in terms of a property known as the Canonical Combining Class. NFC, to handwave some details, takes cases where we have a character followed by a combining character, and if there is a precomposed codepoint representing the two, exchanges them for the single precomposed codepoint. So, I defined NFG as: first compute NFC, then if you still see combining characters after a base character, make a synthetic codepoint. This actually worked pretty well in many cases. And, given the NFC quick-check property can save a lot of analysis work, NFG could be computed relatively quickly.

Unfortunately, though, this approach was a bit too simplistic. Unicode does actually define an [algorithm for grapheme clusters](http://unicode.org/reports/tr29/), and it’s a bit more complex than doing an “*NFC*++.” Fortunately, I’d got the bit of code that would need to change rather nicely isolated, in expectation that something like this might happen anyway. So, at least 95% of the NFG implementation work I’d done back in April didn’t have to change at all to support a new definition of “grapheme”. Better yet, the Unicode consortium provided a bunch of test data for their grapheme clustering algorithm, which I could [process](https://github.com/raku/roast/blob/master/S15-nfg/grapheme-break-test-gen.p6) into [tests for Raku strings](https://github.com/raku/roast/blob/master/S15-nfg/grapheme-break.t).

So far so good, but there was a bit of a snag: using the NFC quick check property was no longer going to be possible, and without it we’d be in for quite a slowdown when decoding bytes to strings – which of course we do every time we get input from the outside world! So, what did I do? Hack our Unicode database importer to compute an NFG quick check property, of course. “There, I fixed it.”

So, all good? Err…almost. I’d also back in April done some optimizations around assuming that anything in the ASCII range was not subject to NFG. Alas, \r\n has been defined as a single grapheme. And yes, that really does mean:

```` raku
> say "OMG\r\n".chars
4
````

I suspect this will be one of those “you’ll can’t win” situations. Ignore that bit of the Unicode spec, and people who understand Unicode will complain that Raku implements it wrong. Follow it, and folks who don’t know the reasoning will think the above answer is nuts. :-) By the way, asking “how many codepoints” is easy:

```` raku
> say "Hi!\r\n".codes
5
````

Making `\r\n` a single grapheme was rather valuable for a reason I hadn’t expected: now that something really common (at least, on Windows) exercised NFG, a couple of small implementation bugs were exposed, and could be fixed. It was also rather a pain, because I had to go and fix the places that wrongly thought they needn’t care for NFG (for example, the ASCII and Latin-1 encondings). The wider community then had to fix various pieces of code that used ord – a codepoint level operation – to see if there was a `\r`, then expected a `\n` after it, and then got confused. So, this was certainly a good one to nail before the Christmas release, after which we need to get serious about not breaking existing code.

As a small reward for slogging through all of this, it turned out that `\r\n` being a single grapheme made a regex engine issue involving `^^` and `$$` magically disappear. So, that was another one off the Christmas list.

There were a few other places where we weren’t quite getting things right with NFG:

- Case folding, including when a synthetic was composed out of something that case folded to multiple codepoints (I’m doubtful this code path will ever be hit for text in any real language, but I’m willing to be surprised)
- Longest Token Matching in grammars/regexes (the NFA compiler/evaluator wasn’t aware of synthetics; now it is)

And with that, I think we can call NFG done for Christmas. Phew!

### Shaped arrays

I’ve finally got shaped arrays fleshed out and wired into the language proper. So, this now works:

```` raku
> my @a[3;3] = 1..3, 4..6, 7..9;
[[1 2 3] [4 5 6] [7 8 9]]
> say @a[2;1]
8
> @a[3;1] = 42
Index 3 for dimension 1 out of range (must be 0..2)
````

This isn’t implemented as an array of arrays, but rather as a single blob of memory with 9 slots. Of course, those slots actually point to `Scalar`s, so it’s only so much more efficient. Native arrays can be shaped also, though. So, this:

```` raku
my int8 @a[1024;1024];
````

Will allocate a single 1MB blob of memory and all of the 8-bit integers will be packed into it.

Even if you aren’t going native, though, shaped arrays do have another sometimes-useful benefit over nested arrays: they know their shape. This means that if you ask for the values, you get them:

```` raku
> my @a[3;3] = 1..3, 4..6, 7..9; say @a.values;
(1 2 3 4 5 6 7 8 9)
````

Whereas if you just have an array of arrays and asked for the values, you’d just have got the nested arrays:

```` raku
> my @a = [1..3], [4..6], [7..9]; say @a.values;
([1 2 3] [4 5 6] [7 8 9])
````

The native array design has been done such that we’ll be able to do really good code-gen at various levels – including down in the JIT compiler. However, none of that is actually done yet, nor will it be this side of Christmas, so the performance of shaped arrays – including the native arrays – isn’t too hot. In general, we’re focusing really hard on places we need to nail down semantics at the moment, because we’ll have to live with those for a long time. We’re free to improve performance every single monthly release, though – and will be in 2016.

### Module installation and precompilation

I spent some time pondering and [writing up a gist](https://gist.github.com/jnthn/47a42b2e86e7e552b2e2) about what I thought management of installed modules and their precompilations should look like, along with describing a precompilation solution for development time (so running module test suites can benefit “for free” from precompilation). I was vaguely hoping not to have to wade into this area – it’s just not the kind of problem I consider myself good at and there seem to be endless opinions on the subject – but got handed my architect hat and asked to weigh in. I’m fairly admiring of the approach taken under the .git directory in Git repositories, and that no doubt influenced the solution I came up with (yes, there are SHA-1s aplenty).

After writing it, I left for a week’s honeymoon/vacation, and while I was away, something wonderful happened: *nine*++ started implementing what I’d suggested! By this point he’s nearly done, and it’s largely fallen out as I had imagined, with the usual set of course corrections that implementing a design usually brings. I’m optimistic we’ll be able to merge [the branch](https://github.com/rakudo/rakudo/commits/curli) in during the next week or so, and another important piece will have fallen into place in time for Christmas. Thanks should also go to *lizmat*++, who has done much to drive module installation related work forward and also provided valuable feedback in earlier drafts of my design.

### Line endings

Windows thinks newlines are `\r\n`. Most of the rest of the world think they are `\n`. And, of course, you end up with files shared between the two, and it’s all a wonderful tangle. In regexes in Raku, `\n` has always been logical: it will happy match `\r\n` or the actual UNIX-y `\n`. That has not been the case for `\n` in strings, however. Thus, on Windows:

```` raku
say "foo!";
````

Would until recently just spit out `\n`, not `\r\n`. There actually are relatively few places that this actually causes problems today: the command shell is happy enough, pretty much every editor is happy (of course, Notepad isn’t), and so forth. Some folks wanted us to fix this, others said screw it, so I asked *Larry* what we should do. :-) The solution we settled on is making `\n` in strings also be logical, meaning whatever the `$?NL` compile-time constant contains. And we pick the default value of that by platform. So on Windows the above say statement will spit out `\r\n`. (We are smart enough to recognize that a `\r\n` sequence in a string is a “single thing” and not go messing with the `\n` inside of it!) There are also pragmas to control this more finely if you don’t want the platform specific semantics:

```` raku
use newline :lf; # Always UNIX-y \x0A
use newline :crlf; # Always Windows-y \x0D\x0A
use newline :cr; # \x0D for...likely nothing Raku runs on :-)
````

Along with this, newline related configuration on file handles and sockets has been improved and extended. Previously, there was just `nl`, which was the newline for input and output. You can now set `nl-in` to either a string separator or an array of string separators, and they can be multiple characters. For output, `nl-out` is used. The default `nl-in` is `[“\r\n”, “\x0A”]`, and the default nl-out is `“\n”` (which is logically interpreted by platform).

Last but not least, the VM-level I/O layer is now aware of chomping, meaning that rather than it handing us back a string that we then go and chomp at Raku level, it can immediately hand back a string with the line ending readily chopped off. This was an efficiency win, but since it was done sensitive to the current set of seperators also fixed a longstanding bug where we couldn’t support auto-chomping of custom input line separators.

### Encodings

A couple of notable things happened with regards to encodings (the things that map between bytes and grapheme strings). On MoarVM, we’ve until recently assumed that every string coming to us from the OS was going to be decodable as UTF-8 (except on Windows, which is more into UCS-2). That often works out, but POSIX doesn’t promise you’ll get UTF-8, or even ASCII. It promises…a bunch of bytes. We can now cope with this properly – surprisingly enough, thanks to the power of NFG. We now have a special encoding, UTF-8 Clean-8-bit, which turns bytes that are invalid as UTF-8 into synthetics, from which we can recover the original bytes again at output. This means that any filename, environment variable, and so forth can be roundtripped through Raku problem-free. You can concat “.bak” onto the end of such a string, and it’ll still work out just fine.

Another Christmas RT complained that if you encoded a string to an encoding that couldn’t represent some characters in it, it silently replaced them with a question mark, and that an exception would be a better default. This was implemented by *ilmari*++, who also added support for specifying a replacement character. I just had to review the patches, and apply them. Easy!

### Here, here

I fixed all of the heredoc bugs in the Christmas RT list:

- RT #120788 (adverbs after `:heredoc/:to` got “lost”)
- RT #125543 (dedent bug when `\n` or `\r\n` showed up in heredocs)
- RT #120895 (`\t` in heredoc got turned into spaces)

### The final regex fixes

Similarly, I dealt with the final regex engine bugs before Christmas, including a rather hard to work out backtracking one:

- RT #126438 (lack of error message when quantifying an anchor, just a hang)
- RT #125285 (backtracking/capturing bug)
- RT #88340 (backreference semantics when there are multiple captures)

Well, or so I thought. Then *Larry* didn’t quite like what I’d done in RT #88340, so I’ll have to go and revisit that a little. D’oh.

### Other smaller Christmas RTs

- Fix RT #125210 (postfix `++` and prefix `++` should complain about being non-associative)
- Fix RT #123581 (`.Capture` on a lazy list hung, rather than complaining it’s not possible)
- Add tests to codify that behavior observed in RT #118031 (typed hash binding vs assignment) is correct
- Fix RT #115384 (`when` / `default` should not decont), tests for existing behavior ruled correct in RT #77334
- Rule on RT #119929 and add test covering ruling (semantics of optional named parameters in multi-dispatch)
- Fix RT #122715 and corrected tests (`Promise` could sink a `Seq` on `keep`, trashing the result)
- Fix RT #117039 (`run` doesn’t fail); update design docs with current reality (`Proc` will now throw an exception in sink context if the process is unsuccessful), and add tests
- Fix RT #82790 (indecisive about `$*FOO::BAR`; now we just outright reject such a declaration/usage)
- Check into RT #123154; already fixed on Moar, just not JVM, so removing from xmas list
- Review RT #114026, which confused invocation and coercion type literals. Codify the response by changing/adding tests.
- Get ruling on RT #71112 and update tests accordingly, then resolve it.
- Work on final bits needed to resolve RT #74414 (multi dispatch handling of `is rw`), building on work done so far by *psch*++
- Fix RT #74646 (multi submethods were callable on the subclass)
- Implement `nextcallee` and test it; fix `nextsame` / `nextwith` on nowhere to defer; together these resolved RT #125783
- Fix RT #113546 (MoarVM mishandles flattening named args and named args with respect to ordering)
- Fix RT #118361 (gist of `.WHAT` and `.WHO` isn’t shortname/longname respectively); RT #124750 got fixed along the way
- Tests codifying decision on RT #119193 (`.?/.+/.*` behavior with multis)
- Review/merge pull requests to implement IO::Handle.t from *pmurias*++, resolving RT #123347 (IO::Handle.t)

Busy times!

### And last but not least…

I’ll be [keynoting at the London Perl Workshop](http://act.yapc.eu/lpw2015/news/1369) this year. See you there!
