# A code review of Pod::Parser, written by mberends
    
*Originally published on [15 March 2009](http://strangelyconsistent.org/blog/a-code-review-of-podparser-written-by-mberends) by Carl Mäsak.*

In October 2006, Damian Conway released an alpha draft of [S26](https://github.com/Raku/old-design-docs/blob/master/S26-documentation.pod), the Raku synopsis aboutPod documentation. That email begins ["Before Christmas, as promised!"](https://www.nntp.perl.org/group/perl.perl6.language/2006/10/msg26469.html). The draft is large, but even for an alpha, it's a good read.

The release of the draft spurred a whole lot of discussion on the rakuanguage mailing list. People seem to care a lot about these things. Late November the same year, Damian [posted](https://www.nntp.perl.org/group/perl.perl6.language/2006/11/msg26746.html) a version of S26 without the 'alpha' in its version number. He also promised to release a Pod-to-XHTML module. (He eventually [did](https://metacpan.org/pod/Perl6::Perldoc), in December 2007.)

The discussion following the release of these documents was intense and at times harsh. Damian eventually declared ["I'm not going to argue about the design of Pod 6 any more."](https://www.nntp.perl.org/group/perl.perl6.language/2007/06/msg27757.html) This was in June 2007. What was the debate about? Browsing through the many emails on the matter, I find it was mainly about the exact relation between Raku code and its Pod comments. The vocal opposition, headed (in some sense) by Mark Overmeer, argued for greater connectivity between Raku code and Pod comments. It's the old configurability-vs-defaults discussion again, with Damian representing the configurability camp and Mark the defaults camp. Damian challenged Mark to write his own S26, which Mark did. Damian [wrote back](https://www.nntp.perl.org/group/perl.perl6.language/2007/07/msg27899.html) that he was "thinking very carefully about what Mark suggested", and that he would "reply properly as soon as I am able."

That was in July 2007. Since then Damian has made a few cameos on the rakuanguage mailing list, but on matters other than Raku Pod. S26 remains in the state it was released in 2006, but nowadays with this message ([here](https://github.com/Raku/old-design-docs/blob/master/S26-documentation.pod)):

```
The information that is in this file is a draft specification that is
known to be out of date and likely to undergo some substantial revision.
Until the document is updated, look at STD.pm for the valid POD syntax.
```

Beware of the leopard. (**Update 2010-05-01:** Time has passed, and since this post was written Damian has made one more sweeping change to S26, and then graciously declared it to be of the same status as the other synopses, i.e. changeable wiki-like by anyone who cares.)

Good thing about that reference to STD.pm as an up-to-date source of information. Unfortunately, when you read STD.pm, what you find is this, and *only* this:

```
# XXX We need to parse the pod eventually to support $= variables.
```

Essentially, S26 and Raku Pod are in limbo since 2007, waiting for the return of Damian (or some other heroic soul) to the scene.

Against this backdrop, this happened in January 2008:

```
mberends: finally pushed my first draft of perldoc pod2text
  pod2man Pod::Parser Pod::to::text Pod::to::man
  to https://github.com/eric256/rakuxamples/tree/master
mberends: please try to run it, there's more to follow (xhtml and a test suite)
masak: mberends: whoa! did you write that?
mberends: yes! over the last 3! months
```

You have to admire the courage of someone who implements a spec that's about to change, in Raku whose spec is also in flux, on top of Rakudo, which is still being written.

I just asked mberends about a status report on his Pod suite. He said this:

```
mberends: masak: the low hanging fruit of common Pod is complete,
  including Pod5 upconverter. Format codes about 50% in text, man,
  xhtml, pod5 and pod6 emitters. =table and =use not even started.
```

What follows is my review of his Pod suite.

The Pod suite can be found here. It consists, for my purposes, of four parts: a test suite, the module Pod::Parser, emitters to various serialization formats, and build scripts. I will review them in that order.

## The tests

The tests are somewhat awkwardly situated inside a `t` directory in `lib/Pod` in the repository. This is somewhat of a deviation from common Perl practice, but the reason is most likely that the rakuxample repository hosts many different things, and a `t` directory outside of `lib` might simply get lost in the general commotion.

The test files make use of `Test::Differences`, also found in `rakuxamples`, which provides a method that extends the diagnostics from the standard `Test` module to include "got" and "expected" output.

All the test files begin with a class that mocks the class being tested in that file by deriving it. That particular code is repetitive, with the exception of the base class, and the name of the class itself, which alternately gets the names `Test::Parser` and `TestParser`. This would be an excellent place for a role, putting all the mocking code in one module, and just mixing it in with a one-line declaration.

We also find the same comment in all these derived classes:

```
# Possible Rakudo bug: calling a base class method ignores other
# overrides in derived class, such as the above `emit` redefine.
# workaround: redundantly copy base class method here, fails too!
```

This, after trying various one-liners, I find not to be the case. Rakudo works perfectly in this case. The comment is probably stale and should be removed. (This, by the way, is why I've taken to write `RAKUDO` comments which reference RT ticket numbers whenever possible. This makes it easy to see whether the comment has grown stale, and whether the workaround can be removed.)

The initialization of these classes is also a bit mysterious.

```raku
my Test::Parser $p .= new; $p.parse_file('/dev/null'); # warming up
```

Why do we parse `'/dev/null'` here? The comment appears to want to explain, but only serves to heighten the mystery. Whence the need to warm up a mock object? And must we really introduce a Unix shibboleth into an otherwise platform-independent test file to do it?

Beyond that, everything else looks fairly good and normal. The tests basically throw different inputs at the modules, and check that they get the right output. Perhaps a module such as [`Test::InputOutput`](November-29-2008-i-will-call-it-the-graphophone.html) could alleviate some of the repetition here, but not by much, and only at the cost of another dependency.

I have the impression that the test coverage is actually pretty good; the 37 tests do get to exercise much of the code written so far. Keep up the good TDD, *mberends*++.

## Pod::Parser

We now get to the centerpiece of the module suite, at this writing weighing in at 33121 characters. The general structure is this: it starts with an awe-inspiring grammar `Pod6`, followed by a few smaller grammars, enums, and classes. After that, the class `Pod::Parser` takes up the bulk of the file, followed (very appropriately) by excellent Pod documentation.

```
mberends: I wish the rest of you would bother to write more comments and POD
```

The `Pod6` grammar is exquisite. Care has been taken to align regexes and their parts vertically so as to bring out structure. There are no empty lines, but there are one-line comments grouping the regexes into logical units.

Two comments about the class `PodBlock`, which seems to effectively be a simple C-like struct (not that there's anything wrong with that): first, since all of the attributes are marked `is rw`, it would probably make sense to put the `is rw` declaration on the class itself, as in [this example](https://github.com/Raku/old-design-docs/blob/master/S12-objects.pod#line_98) from S12. However, Rakudo [doesn't yet implement this](https://github.com/Raku/old-issue-tracker/issues/414), which might be considered a reasonable excuse.

Second, this:

```raku
my Str $typename = defined $.typename ?? $.typename !! 'undef';
my Str $style    = defined $.style    ?? $.style    !! 'undef';
```

...should be written thus...

```raku
my Str $typename = $.typename // 'undef';
my Str $style    = $.style    // 'undef';
```

Now for the main class `Pod::Parser`. We are greeted by a longish list of attributes, alphabetically sorted, each with a half-line comment after it. Such details warm the heart of a reviewer, I can tell you. The one comment I couldn't get my head around is this:

```raku
has $!context is Context;          # not (yet) in Rakudo r35960
```

After thinking for a minute, I realize that `Context` is a previously-declared enum, and that the comment probably refers to enums and attributes not working properly, or some such. (Once again, a reference to an RT ticket would have helped here.) Trying out enums in attributes in bleeding Rakudo (commit 1dea76), I find that it works well, so the comment should go away. Also, there's no need to put the type after the attribute, when all the other types are written before. The line should look like this:

```raku
has Context $!context;                     # which state is the parser in?
```

On the bright side, here's a comment before another attribute:

```raku
# $*OUT broke in r35311, reported in RT#62540
```

Yes! That's what I'm talking about.

Here comes my favorite method:

```raku
method parse_line { # from parse_file
    given $!line {
        when /<Pod6::directive>/ { self.parse_directive; } # '=xx :cc'  /
        when /<Pod6::extra>/     { self.parse_extra; }     # '=    :cc' /
        when /<Pod6::blank>/     { self.parse_blank; }     # '' or ' '  /
        default { if @!podblocks { self.parse_content; }   # 'xx' or ' xx'
                  else           { self.ambient($!line); } # outside pod
        }
    }
}
```

See what happens here? Yes, all the logic, all the grunt work, is made by the `Pod6` grammar; the method basically lists the cases, and that's it. It's obvious in retrospect, but I wouldn't really have thought of using given/when in this case. There's even some room left to document what the cases look like. Cute!

The method `parse_directive` seems to be a close relative of `parse_line`. It would be interesting to investigate whether these methods, and the methods they called, could be fit into an action class, and called automatically through `{*}` directives in the grammar. Only direct experimentation would answer that question.

An nice practice: all the methods called from `parse_line` and `parse_directive` have a comment saying so. This gives some piece of context, almost like declaring pre- and postconditions of a method. Since these methods *are* only called from `parse_line` and `parse_directive`, however, I wonder if they could not be made into submethods instead.

In a cozy little method called `buf_flush`, we find this:

```raku
self.emit( ~ ( $!buf_out_line eq "\n" ?? "" !! $!buf_out_line ) );
# why is the ~ necessary?
```

Now, the attribute `$!buf_out_line`, in case you are wondering, is declared as a `Str`, and is set to the empty string before every parse. So the question about a stringifying `~` being necessary is reasonable: why isn't the expression from the trinary always a `Str`? Someone should remove that `~`, find a case where the trinary doesn't give a `Str`, put that case in quarantine and have it sent to the good people over at RT for further classification.

The Pod documentation at the end of the file, as I wrote earlier, is excellent. It has everything one would expect from the POD of a mature CPAN module. I'm not just saying this because the Pod ends by praising me (and the other November devs); it really does go an extra mile. It even contains a section about how to build your own Pod serializer. It also quotes [General Helmuth von Moltke](https://en.wikipedia.org/wiki/Helmuth_von_Moltke_the_Elder), and has expansive TODO and BUGS sections. The only thing I find missing is that the `METHODS` section only lists the most important methods, it doesn't describe them.

Among the `BUGS`, I find this gem:

```
Long or complex documents randomly suffer segmentation faults.
```

As a Rakudo-using Raku developer, I can empathize with that. However, I believe that a few of those might actually have disappeared with the recent fixes from *jonathan*++.

## The emitters

The emitters, or "Podlators", all subclass `Pod::Parser`. I get really good vibes from `Pod::to::text`, `Pod::to::pod5` and `Pod::to::pod6`. The `pod6` emitter, however, contains this:

```raku
  $!needspace = $!needspace and (substr($content,0,1) ne " ");
# $!needspace &&= (substr($content,0,1) ne " "); # crashes
```

Those parentheses are not necessary, and as far as I can tell, this statement no longer crashes.

Now, out of the four existing emitters, `Pod::to::xhtml` is the most complicated one. That's perhaps not too surprising. I have two comments on this code, one minor and one major: first, a few emit cases are commented out with no reason given. The `BUGS` section seems to give indications as to why, but the connection is not overly clear. This seems to be a case where unit tests for the particular problems encountered would help.

Second, and more alarming, is the way the XML is serialized. Sure, the content is properly escaped, but the mechanism is still fully text-based, which can introduce subtle nesting bugs. It would perhaps be advisable to use a serialization technique similar to the one in the Raku SVG module. For a quick introduction to the pitfalls of XML generation, see [this article](https://hsivonen.fi/producing-xml/). Many of the tips therein could probably be directly applied to the XHTML emitter, making it more robust in the process.

## The build scripts

mberends wrote his own `Configure.pm` in Raku. There are deep coolness points in that; the rest of us are stuck with lame `Makefile.PL` files written in Perl. The `Configure.pm` solutions are a bit Unix-specific (for example a `qx` workaround that presupposes `/tmp`), but there's hardly any room to do better in Rakudo right now. Windows users haven't shown up in great amounts to work on our Raku projects anyway. (Funny, that. Are people still using Windows these days?)

Here's a cutie:

```raku
# The opposite of slurp
sub squirt( Str $filename, Str $text ) {
    my $handle = open( $filename, :w );    # should check for success
    $handle.print: $text;
    $handle.close;
}
```

Let me provide that check for success, free of charge:

```raku
    my $handle = open( $filename, :w )
        or die $!;
```

(A more interesting question might be what the sub should do if the file already exits. At present it simply overwrites files, which might or might not be the desired behaviour.)

The `Makefile.in`, finally, shouldn't be remarkable in any way, but it is. It contains friendly instructions how to get started with downloading, reading the documentation (using, of course, the Pod tools themselves), how to contact the author, and how to contribute.

## In conclusion

All in all, this is a set of modules that mberends has put a lot of effort into, and it shows. When we wrote November, we hoped that our code could serve as inspiration for others -- mberends has in many cases taken our ideas and run with them. His work on this suite of modules puts it on the second place in complexity (after November) among the Raku projects out there. As someone who always delights in new Raku code, I'm very happy about these modules.

The future of Raku Pod is uncertain. By that I don't mean that I don't believe it *has* a future; it's just that it's been left in the limbo described in the beginning of the post. (**Update 2010-05-01:** Though not anymore, as also described above.) One day, Damian might return and completely Change Everything. We can only hope. If and when that happens, *mberends*++ has already given us a head start in parsing the Pod of tomorrow, by providing modules that do it today.

*In the spirit of the [Reviewer's Manifesto](Code-reviews-a-manifesto.html), I have contributed patches to most of the things I found worth changing during this review.*
