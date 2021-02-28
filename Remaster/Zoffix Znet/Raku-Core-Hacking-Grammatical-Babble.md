# Raku Core Hacking: Grammatical Babble
    
*Originally published on [12 September 2016](https://perl6.party//post/Perl-6-Core-Hacking-Grammatical-Babble) by Zoffix Znet.*

Feelin' like bugfixing the Raku compiler? Here's a [great grammar bugglet](https://rt.perl.org/Ticket/Display.html?id=128304): the `„"` quotes don't appear to work right when used in quoted white-space separated words list constructor:

```` raku
say „hello world";
.say for qww<„hello world">;
.say for qww<"hello world">;
# OUTPUT:
# hello world
# „hello
# world"
# hello world
````

The quotes should not be in the output and we should have just 3 lines in the output; all `hello world`. Sounds like a fun bug to fix! Let's jump in.

## How do you spell that?

The fact that this piece of code doesn't parse right suggests this is a grammar bug. Most of the grammar lives in [src/Perl6/Grammar.nqp](https://github.com/rakudo/rakudo/blob/83b8b1a/src/Perl6/Grammar.nqp), but before we get our hands dirty, let's figure out what we should be looking for.

The `raku` binary has a `--target` command line parameter that takes one of the compilation stages and will cause the output for that stage to be produced. What stages are there? They will differ, depending on which backend you're using, but you can just run `raku --stagestats -e ''` to print them all:

````
zoffix@leliana:~$ raku --stagestats -e ''
Stage start      :   0.000
Stage parse      :   0.077
Stage syntaxcheck:   0.000
Stage ast        :   0.000
Stage optimize   :   0.001
Stage mast       :   0.004
Stage mbc        :   0.000
Stage moar       :   0.000
````

Grammars are about parsing, so we'll ask for the `parse` target. As for the code to execute, we'll give it just the problematic bit; the `qww<>`:

````
zoffix@leliana:~$ raku --target=parse -e 'qww<„hello world">'
- statementlist: qww<„hello world">
  - statement: 1 matches
    - EXPR: qww<„hello world">
      - value: qww<„hello world">
        - quote: qww<„hello world">
          - quibble: <„hello world">
            - babble:
              - B:
            - nibble: „hello world"
          - quote_mod: ww
            - sym: ww
````

That's great! Each of the lines is prefixed by the name of a token we can find in the grammar, so now we know where to look for the problem.

We also know that basic quotes work correctly, so let's dump the parse stage for them as well, to see if there is any difference between the two outputs:

````
zoffix@leliana:~$ raku --target=parse -e 'qww<"hello world">'
- statementlist: qww<"hello world">
  - statement: 1 matches
    - EXPR: qww<"hello world">
      - value: qww<"hello world">
        - quote: qww<"hello world">
          - quibble: <"hello world">
            - babble:
              - B:
            - nibble: "hello world"
          - quote_mod: ww
            - sym: ww
````

And... well, other than different quotes, the parse tree is the same. So it looks like all of the tokens involved are the same, but what is done by those tokens differs.

We don't have to examine each of the tokens we see in the output.  The `statementlist` and `statement` are tokens matching general statements, the `EXPR` is the precedence parser, and `value` is one of the values it's operating on. We'll ignore those, leaving us with this list of suspects:

````
- quote: qww<„hello world">
  - quibble: <„hello world">
    - babble:
      - B:
    - nibble: „hello world"
  - quote_mod: ww
    - sym: ww
````

Let's start interrogating them.

## Down the rabbit hole we go...

Get yourself a local [Rakudo repo](https://github.com/rakudo/rakudo/) checkout, if you don't already have one, pop open [src/Perl6/Grammar.nqp](https://github.com/rakudo/rakudo/blob/83b8b1a/src/Perl6/Grammar.nqp), and get comfortable.

We'll follow our tokens from the top of the tree down, so the first thing we need to find is `token quote`, `rule quote`, `regex quote`, or `method quote`; search in that order, as the first items are more likely to be the right thing.

In this case, it's [a `token quote`](https://github.com/rakudo/rakudo/blob/83b8b1a/src/Perl6/Grammar.nqp#L3555) which is a [proto regex](https://docs.raku.org/language/grammars#Protoregexes). Our code uses the `q` version of it and you can spot the `qq` and `Q` versions next to it as well:

```` raku
token quote:sym<q> {
    :my $qm;
    'q'
    [
    | <quote_mod> {} <.qok($/)> { $qm := $<quote_mod>.Str }
        <quibble(%*LANG<Quote>, 'q', $qm)>
    | {} <.qok($/)> <quibble(%*LANG<Quote>, 'q')>
    ]
}
token quote:sym<qq> {
    :my $qm;
    'qq'
    [
    | <quote_mod> { $qm := $<quote_mod>.Str } <.qok($/)>
        <quibble(%*LANG<Quote>, 'qq', $qm)>
    | {} <.qok($/)> <quibble(%*LANG<Quote>, 'qq')>
    ]
}
token quote:sym<Q> {
    :my $qm;
    'Q'
    [
    | <quote_mod> { $qm := $<quote_mod>.Str } <.qok($/)>
        <quibble(%*LANG<Quote>, $qm)>
    | {} <.qok($/)> <quibble(%*LANG<Quote>)>
    ]
}
````

Seeing that bodies of `qq` and `Q` look similar to `q`, let's see if they have the bug as well:

````
zoffix@leliana:~$ raku -e '.say for qqww<„hello world">'
„hello
world"
zoffix@leliana:~$ raku -e '.say for Qww<„hello world">'
„hello
world"
````

Yup, it's there as well, so `token quote` is unlikely to be the problem.  Let's break down what the `token quote:sym<q>` is doing, to figure out how to proceed next; one of its alternations is not used by our current code, so I'll omit it:

```` raku
token quote:sym<q> {
    :my $qm;
    'q'
    [
    | <quote_mod> {} <.qok($/)> { $qm := $<quote_mod>.Str }
        <quibble(%*LANG<Quote>, 'q', $qm)>
    | # (this branch omited)
    ]
}
````

On line 2, we create a variable, then match literal `q` and then the `quote_mod` token. That one was part of our `--target=parse` output and if you do locate it the same way we located the `quote` token, you'll notice it's a proto regex that, in this case, matches the `ww` bit of our code. The empty `{}` block that follows we can ignore (it's a workaround for a bug that may have already been fixed when you read this). So far we've matched the `qww` bit of our code.

Moving further, we encounter the call to `qok` token with the current [`Match`](https://docs.raku.org/type/Match) object as argument. The dot in `<.qok` signifies this is a non-capturing token match, which is why it did not show up in our `--target=parse` dump. Let's locate that token and see what it's about:

```` raku
token qok($x) {
    » <![(]>
    [
        <?[:]> || <!{
            my $n := ~$x; $*W.is_name([$n]) || $*W.is_name(['&' ~ $n])
        }>
    ]
    [ \s* '#' <.panic: "# not allowed as delimiter"> ]?
    <.ws>
}
````

Boy! Lots of symbols, but this shit's easy: `»` is a [right word boundary](https://docs.raku.org/language/regexes#%3C%3C_and_%3E%3E_,_left_and_right_word_boundary) that is *not* followed by an opening parenthesis (`<![(]>`), followed by an alternation (`[]`), followed by a check that we aren't trying to use `#` as delimiters (`[...]?`), followed by <a href="https://docs.raku.org/language/grammars#ws">`<.ws>` token</a> that gobbles up all kinds of whitespace.

Inside the alternation, we use the first-token-match `||` alternation (as opposed to longest-token-match `|` one), and the first token is a lookahead for a colon `<?[:]>`. If that fails, we stringify the given argument (`~$x`) and then call `is_name` method on the [World object](https://github.com/rakudo/rakudo/blob/83b8b1a/src/Perl6/World.nqp) passing it the stringified argument as is and with `&` prepended. The passed `~$x` is what our `token quote:sym<q>` token has matched so far (and that is string `qww`). The `is_name` method simply checks if the given symbol is declared and our token match will pass or fail based on that return value. The `<!{ ... }>` construct we're using will fail if the evaluated code returns a truthy value.

All said and done, all this token does is check we're not using `#` as a delimiter and aren't trying to call a method or a sub. No signs of the bug in this corner of the room. Let's get back up to our `token quote:sym<q>` and see what it's doing next:

```` raku
token quote:sym<q> {
    :my $qm;
    'q'
    [
    | <quote_mod> {} <.qok($/)> { $qm := $<quote_mod>.Str }
        <quibble(%*LANG<Quote>, 'q', $qm)>
    | # (this branch omited)
    ]
}
````

We've just finished looking over the `<.`qok`>`, so next up is `{ $qm := $<quote_mod>.Str }` that merely assigns the string value of the matched `<quote_mod>` token into the `$qm` variable. In our case, that value is the string `ww`.

What follows is another token that showed up in our `--target=parse` output:

```` raku
<quibble(%*LANG<Quote>, 'q', $qm)>
````

Here, we're invoking that token with three positional arguments: the [`Quote` language braid](https://github.com/rakudo/rakudo/blob/04af57c3b3d32353e36614de53396d2b4a08b7be/src/Perl6/Grammar.nqp#L424), string `q`, and string `ww` that we saved in the `$qm` variable. I wonder what it's doing with 'em.  That's our next stop. Full speed ahead!

## Nibble Quibble Babbling Nibbler

Here's the full `token quibble` and you can see right away we'd have to dig deeper from the get-go, as fifth line is another token match:

```` raku
token quibble($l, *@base_tweaks) {
    :my $lang;
    :my $start;
    :my $stop;
    <babble($l, @base_tweaks)>
    {
        my $B  := $<babble><B>.ast;
        $lang  := $B[0];
        $start := $B[1];
        $stop  := $B[2];
    }
    $start <nibble($lang)>
    [
        $stop
        || {
            $/.CURSOR.typed_panic(
                'X::Comp::AdHoc',
                payload => "Couldn't find terminator $stop (corresponding $start was at line {
                    HLL::Compiler.lineof(
                        $<babble><B>.`orig`, $<babble><B>.`from`
                    )
                })",
                expected => [$stop],
            )
        }
    ]
    {
        nqp::can($lang, 'herelang')
        && self.queue_heredoc(
            $*W.nibble_to_str(
                $/,
                $<nibble>.ast[1], -> {
                    "Stopper '" ~ $<nibble> ~ "' too complex for heredoc"
                }
            ),
            $lang.herelang,
        )
    }
}
````

We define three variables and then invoke the `babble` token with the same arguments we invoked `quibble` with. Let's find it the same way we found all the previous tokens and peek at its guts. For the sake of brevity, I removed [about half of it](https://github.com/rakudo/rakudo/blob/bc35922/src/Perl6/Grammar.nqp#L111-L125): that portion deals with adverbs, which we aren't using in our code at the moment.

```` raku
token babble($l, @base_tweaks?) {
    :my @extra_tweaks;
    # <irrelevant portion redacted>
    $<B>=[<?before .>]
    {
        # Work out the delimeters.
        my $c := $/.CURSOR;
        my @delims := $c.peek_delimiters($c.target, $c.pos);
        my $start := @delims[0];
        my $stop  := @delims[1];
        # Get the language.
        my $lang := self.quote_lang($l, $start, $stop, @base_tweaks, @extra_tweaks);
        $<B>.'!make'([$lang, $start, $stop]);
    }
}
````

We start by capturing a lookahead into the `$<B>` capture, which serves to update the current Cursor postion, and then go in to execute the code block. We store the current Cursor into `$c`, and then call `.peek_delimiters` method on it. If we `grep```` in a built rakudo directory for it, we'll see it's defined [in NQP, in `nqp/src/HLL/Grammar.nqp`](https://github.com/raku/nqp/blob/4fd4b48afb45c8b25ccf7cfc5e39cb4bd658901d/src/HLL/Grammar.nqp#L200), but before we rush out to read its code, notice how it returns two delimiters. Let's just print them out?

The `.nqp` extension of the `src/Perl6/Grammar.nqp` we are in signifies we're in NQP land, so we need to use [NQP ops](https://github.com/raku/nqp/blob/master/docs/ops.markdown) only and not full-blown Raku code. By adding this line after the lines where `@delim` is assigned to `$start` and `$stop`, we can find what `.peek_delimiters` gives us:

```` raku
nqp::say("$start $stop");
````

Compile!

```` raku
$ perl Configure.pl --gen-moar --gen-nqp --backends=moar &&
  make &&
  make test &&
  make install
````

Even during compilation, by spewing extra stuff, our debug line already gives us an idea what these delimiters are all about. Run our problematic code again:

```` raku
$ ./raku -e '.say for qww<„hello world">;'
< >
hello world
````

The delimiters are the angled bracket delimiters of the `qww`. We're not interested in those, so we can ignore `.peek_delimiters` and move on. Next up is the `.quote_lang` method. It's got "quote" in the name and we have a problem with quotes... sounds like we're getting closer. Let's take a note of what arguments we're passing to it:

- `$l`—the [`Quote` language braid](https://github.com/rakudo/rakudo/blob/04af57c3b3d32353e36614de53396d2b4a08b7be/src/Perl6/Grammar.nqp#L4752)
- `$start`/`$stop`—angled bracket delimiters
- `@base_tweaks`—contains one element: string `ww````
- `@extra_tweaks`—extra adverbs, which we do not have, so the array is empty

Locate `method quote_lang`; it's still in the [`src/Perl6/Grammar.nqp` file](https://github.com/rakudo/rakudo/blob/04af57c3b3d32353e36614de53396d2b4a08b7be/src/Perl6/Grammar.nqp#L65):

```` raku
method quote_lang($l, $start, $stop, @base_tweaks?, @extra_tweaks?) {
    sub `lang_key` {
        # <body redacted>
    }
    sub `con_lang` {
        # <body redacted>
    }
    # Get language from cache or derive it.
    my $key := `lang_key`;
    nqp::existskey(%quote_lang_cache, $key) && $key ne 'NOCACHE'
        ?? %quote_lang_cache{$key}
        !! (%quote_lang_cache{$key} := `con_lang`);
}
````

We have two lexical subroutines `lang_key` and `con_lang`, below them we store the output of `lang_key` into `$key` which is used in the whole cache dance in `%quote_lang_cache`, so we can ignore the `lang_key` sub and go straight to `con_lang`, which is called to generate the return value of our `quote_lang` method:

```` raku
sub `con_lang` {
    my $lang := $l.'!cursor_init'(self.`orig`, :p(self.`pos`), :shared(self.'!shared'()));
    for @base_tweaks {
        $lang := $lang."tweak_$_"(1);
    }
    for @extra_tweaks {
        my $t := $_[0];
        if nqp::can($lang, "tweak_$t") {
            $lang := $lang."tweak_$t"($_[1]);
        }
        else {
            self.sorry("Unrecognized adverb: :$t");
        }
    }
    nqp::istype($stop,VMArray) ||
    $start ne $stop ?? $lang.balanced($start, $stop)
                    !! $lang.unbalanced($stop);
}
````

After initializing Cursor position, `$lang` contains our Quote language braid and then we descend into a `for` loop over `@base_tweaks`. For each of them, we call method `tweak_$_`, passing it a truthy value `1`. Since we have just one base tweak, this means we're calling method `tweak_ww` on the Quote braid.  Let's see what that method is about.

Since the Quote braid is defined in the same file, just search for `method tweak_ww`:

```` raku
method tweak_ww($v) {
    $v ?? self.add-postproc("quotewords").apply_tweak(ww)
       !! self
}
````

Great. The `$v` we gave it is true, so we call `.add-postproc` and then `.apply_tweak(ww)`. Looking above and below that method, we see `.add-postproc` is also used in other, non-buggy, quoters, so let's ignore it and jump straight to `.apply_tweak`:

```` raku
method apply_tweak($role) {
    my $target := nqp::can(self, 'herelang') ?? self.herelang !! self;
    $target.HOW.mixin($target, $role);
    self
}
````

Aha! Its argument is a role and it mixes it into our Quote braid. Let's see what that role is about (again, just search the file for [`role ww`](https://github.com/rakudo/rakudo/blob/94b09ab9280d39438f84cb467d4b3d3042b8f672/src/Perl6/Grammar.nqp#L4846), or simply scroll up a bit):

```` raku
role ww {
    token escape:sym<' '> {
        <?[']> <quote=.LANG('MAIN','quote')>
    }
    token escape:sym<‘ ’> {
        <?[‘]> <quote=.LANG('MAIN','quote')>
    }
    token escape:sym<" "> {
        <?["]> <quote=.LANG('MAIN','quote')>
    }
    token escape:sym<" "> {
        <?["]> <quote=.LANG('MAIN','quote')>
    }
    token escape:sym<colonpair> {
        <?[:]> <!RESTRICTED> <colonpair=.LANG('MAIN','colonpair')>
    }
    token escape:sym<#> {
        <?[#]> <.LANG('MAIN', 'comment')>
    }
}
````

Oh, boy! Quotes! If this isn't the place were we fix our bug, then I'm a ballerina. We found it!

The role we located mixes in some tokens into the Quote braid we are using to parse the `qww`'s contents. Our buggy combination of `„"` quotes is conspicuously absent from the list. Let's add it!

```` raku
token escape:sym<„ "> {
    <?[„]> <quote=.LANG('MAIN','quote')>
}
````

Compile! Run our buggy code:

```` raku
$ ./raku -e '.say for qww<foo „hello world" bar>'
foo
bar
````

Oopsie! Well, we certainly found the right place for quote handling, but we made the problem worse. What's happening?

## Quotastic Inaction

Our new token sure parses the quotes, but we never added the Actions to...  well, act on it. Action classes live next door to Grammars, in `src/Perl6/Actions.nqp`. Pop it open and locate the matching method; let's say <a href="https://github.com/rakudo/rakudo/blob/94b09ab9280d39438f84cb467d4b3d3042b8f672/src/Perl6/Actions.nqp#L9243">`method escape:sym<" ">`</a>.

```` raku
method escape:sym<' '>($/) { make mark_ww_atom($<quote>.ast); }
method escape:sym<" ">($/) { make mark_ww_atom($<quote>.ast); }
method escape:sym<‘ ’>($/) { make mark_ww_atom($<quote>.ast); }
method escape:sym<" ">($/) { make mark_ww_atom($<quote>.ast); }
````

Let's add our version to the list:

```` raku
method escape:sym<„ ">($/) { make mark_ww_atom($<quote>.ast); }
````

Compile! Run our buggy code:

```` raku
$ ./raku -e '.say for qww<foo „hello world" bar>'
foo
hello world
bar
````

Woohoo! Success! It's no longer buggy. We fixed it! 🎊🎉

But, wait...

## Left out, but not forgotten

Take a look at the [list of all the possible fancy-pants quotes](https://docs.raku.org/language/unicode_texas#Other_acceptable_single_codepoints). Even though our bug report only mentioned the `„"` pair, neither `‚‘` nor `｢｣` are in the list of our `role ww` tokens. More than that, some left/right quotes, when swapped, work just fine when quoting strings, so they should work in `qww` too. However, adding a whole bunch of extra tokens and a whole 'nother bunch of actions methods is quite un-awesome.  Is there a better way?

Let's take a closer look at our tokens:

```` raku
token escape:sym<" "> {
    <?["]> <quote=.LANG('MAIN','quote')>
}
````

The `sym<" ">` we can ignore—here it's functioning just as a name. What we are left with is a look-ahead for a `"` quote and the assigment of the result of the `quote` token from MAIN language braid to `$<quote>` capture. So we can look-ahead for all of the opening quotes we care about and let the MAIN braid take care of all the details.

So, let's replace all of the quote handling tokens with this single one:

```` raku
token escape:sym<'> {
    <?[ ' " ‘ ‚ ’ " „ " ｢ ]> <quote=.LANG('MAIN','quote')>
}
````

And replace all of the matching actions methods with this single one:

```` raku
method escape:sym<'>($/) { make mark_ww_atom($<quote>.ast); }
````

Compile! Run our code with some quote variations:

```` raku
$ ./raku -e '.say for qww<„looks like" ‚we fixed‘ ｢this thing｣>'
looks like
we fixed
this thing
````

Awesome! Not only did we make all of the quotes work right, we also managed to clean up the existing tokens and action methods. All we need now is a test for our fix and we're ready to commit.

## Feasting on The Bug Roast

The [Official Raku Test Suite (Roast)](https://github.com/raku/roast) is in `t/spec` inside of the Rakudo build dir. If it's missing, just run `make spectest` and abort it after it clones the roast repo into `t/spec`.  We need to find where to stick our test and `grep` is a good friend at that task:

````
zoffix@VirtualBox:~/CPANPRC/rakudo/t/spec$ grep -R 'qww' .
Binary file ./.git/objects/pack/pack-5bdee39f28283fef4b500859f5b288ea4eec20d7.pack matches
./S02-literals/allomorphic.t:    my @wordlist = qqww[1 2/3 4.5 6e7 8+9i] Z (IntStr, RatStr, RatStr, NumStr, ComplexStr);
./S02-literals/allomorphic.t:        isa-ok $val, Str, "'$val' from qqww[] is a Str";
./S02-literals/allomorphic.t:        nok $val.isa($wrong-type), "'$val' from qqww[] is not a $wrong-type.`perl`";
./S02-literals/allomorphic.t:    my @wordlist  = qqww:v[1 2/3 4.5 6e7 8+9i];
./S02-literals/allomorphic.t:    my @written = qqww:v[1 2/3 $num 6e7 8+9i ten];
./S02-literals/allomorphic.t:    is-deeply @angled, @written, "«...» is equivalent to qqww:v[...]";
./S02-literals/quoting.t:    is(qqww[$alpha $beta], <foo bar>, 'qqww');
./S02-literals/quoting.t:    for (<<$a b c>>, qqww{$a b c}, qqw{$a b c}).kv -> $i, $_ {
./S02-literals/quoting.t:    is-deeply qww<a a ‘b b’ ‚b b’ ’b b‘ ’b b‘ ’b b’ ‚b b‘ ‚b b’ "b b" „b b"
./S02-literals/quoting.t:    'fancy quotes in qww work just like regular quotes';
./integration/advent2014-day16.t:    for flat qww/ foo bar 'first second' / Z @a -> $string, $result {
````

It appears `S02-literals/quoting.t` is a good place for it. Pop open the file.  At the top of it, increase `plan` number by the number of tests we're adding—in this case just one. Then scroll to the end and create a block, with a comment in front of it, referencing the RT ticket number for the [bug report](https://rt.perl.org/Ticket/Display.html?id=128304) we're fixing.

Inside of it, we'll use [`is-deeply`](https://docs.raku.org/language/testing#index-entry-is-deeply-is-deeply%28%24value%2C_%24expected%2C_%24description%3F%29) test function that uses [`eqv` operator](https://docs.raku.org/routine/eqv) semantics to do the test. We'll give it a `qww<>` line with whole bunch of quotes and then tell it what list of items we expect to get in return. Write the test description as well:

```` raku
# RT #128304
{
    is-deeply qww<a a ‘b b’ ‚b b’ ’b b‘ ’b b‘ ’b b’ ‚b b‘ ‚b b’ "b b" „b b"
            "b b" "b b" "b b" „b b" „b b" ｢b b｣ ｢b b｣>,
        ('a', 'a', |('b b' xx 16)),
    'fancy quotes in qww work just like regular quotes';
}
````

Back in the Rakudo checkout, run the modified test and ensure it passes:

```` raku
$ make t/spec/S02-literals/quoting.t
# <lots of output>
All tests successful.
Files=1, Tests=185,  3 wallclock secs ( 0.03 usr  0.01 sys +  2.76 cusr  0.11 csys =  2.91 CPU)
Result: PASS
````

Sweet. Commit the tests and the bug fix and ship them off! We're done!

## Conclusion

When fixing parsing bugs in Raku, it's useful to reduce the program to the minimum that still reproduces the bug and then use the `--target=parse` command line argument, to get the output of the parse tree, finding which tokens are being matched.

Then, follow those tokens in [`src/Perl6/Grammar.nqp`](https://github.com/rakudo/rakudo/blob/04af57c3b3d32353e36614de53396d2b4a08b7be/src/Perl6/Grammar.nqp), which also inherits from [NQP's `src/HLL/Grammar.nqp`](https://github.com/raku/nqp/blob/4fd4b48afb45c8b25ccf7cfc5e39cb4bd658901d/src/HLL/Grammar.nqp). In conjunction with the actions classes located in [`src/Perl6/Actions.nqp`](https://github.com/rakudo/rakudo/blob/04af57c3b3d32353e36614de53396d2b4a08b7be/src/Perl6/Actions.nqp), follow the code to figure out what it is doing and hopefully find where the problem is located.

Fix it. Test it. Ship it.

-Ofun
