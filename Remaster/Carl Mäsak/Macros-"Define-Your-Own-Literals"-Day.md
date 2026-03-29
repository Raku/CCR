# Macros: "Define Your Own Literals" Day
    
*Originally published on [28 November 2014](http://strangelyconsistent.org/blog/macros-define-your-own-literals-day) by Carl Mäsak.*

There's clearly a blurry line between macros and slangs. We should probably
keep it that way. But for this post &mdash; as I keep mapping out more of the
possible futures the best of which we are aiming for &mdash; I don't *exactly*
know if it's macros I'm talking about, or slangs.

(Meanwhile, in a parallel universe, masak-with-a-toggled-goatee writes a
similarly ambiguous post in his series of investigative blogginations about
slangs.)

Consider this code from the near future:

```raku
use Slang::HTML;
use Slang::SQL;
my $keyword = "dugong";
my $db = $*DB;
my $webpage = html`
    <html>
        <body>
            <h1>Results for {$keyword}</h1>
            <ul>
                {list-items($db.query( sql`
                    SELECT title, snippet
                        FROM products
                        WHERE {$keyword} in title
                `))}
            </ul>
        </body>
    </html>
`;
```

Let's ignore the fact that mixing HTML and database calls is something that
most of us did back in the nineties and would prefer not doing again. Let's
also leave aside the fact that I don't know the actual syntax for introducing a
slang, and I basically just picked something that didn't look awful. (Or maybe
it does. Anyway, it's not my call.)

Instead, let's focus on the three awesome things with the above code:

- Yes, that is indeed SQL in Raku in HTML in Raku.
- Lexical scoping still works, all the way down the slang stack.

Both the HTML
and SQL slangs are pulling out `$keyword` from the mainline Raku code.
Similarly, the sandwiched Raku code pulls out `$db` from the mainline.

- Lastly, implied in all this is that both SQL injection and cross-site
scripting are basically solved problems with these slangs

*And it's not even hard* because Raku already treats these languages as AST-based, not
text based. (A-ha! I knew there was a connection to macros somewhere!)

Where's all this coming from? I've had the above long-term vision for a long time,
but it was re-triggered by the paper [*Safely Composable Type-Specific
Languages*](https://www.cs.cmu.edu/~aldrich/papers/ecoop14-tsls.pdf). It's nice,
although the first half is lighter reading than the second. My code above is
based on their code from page 2, except mine has better indentation.

I *do* like the idea from that paper that literals could basically be defined
by module authors. And there's another sense that stirs in me that I've had lately
when writing hobby Raku: that of defining first a model (objects), then a set
of rules (functions and methods), and then a syntax (custom operators). I've
only had a small taste of that kind of programming, but I *like* it.

Anyway, here are my takeaways from the paper:

- Yes, we *do* need to get away from treating languages as strings.

Raku already
does this excellently with grammars ("the first slang"). We need to do it with
All The Things, though.

- Later examples in the paper with the Wyvern language use a kind of "typed heredoc"

Which I think is foreign to the way parsing works in Raku.
Specifically, in the example in Figure 1, the switching into the HTML slang
is governed by the compiler knowing the signature of the ``serve`` function.
I think neither the Raku parser nor Perl programmers would find it natural
to let types influence language switching in that way. Better to be
explicit.

- It's perfectly fine if the HTML slang returns an `HTML` object of some kind.

Type signatures could then be checked at compile time, and `Calling 'serve'
would never work`-style errors thrown, etc. Type checking information can
propagate outward.

- The Wyvern language does something interesting with specifying parsing of a
type along with the type declaration itself.

It's yet another case of
something that would probably look quite a bit different in a Raku
factoring, but it's worth remembering that declaration of model and
declaration of syntax can be brought this close together.

Possible ways forward on this: both the HTML and SQL slangs are possible today,
with some degree of bending the implementation. *FROGGS*++ is showing the way
with [`Slang::Tuxic`](https://raku.land/zef:raku-community-modules/Slang::Tuxic) &mdash; let's
do something similar with these.

*Edit: not one minute after publishing this post, I'm made aware of [`Slang::SQL`](https://raku.land/?q=Slang%3A%3ASQL). It's not
quite there yet, but it's working its way toward the ideal I have in mind.
Nice! Ok, so now I only have to rally the people to building `Slang::HTML`.
哈哈*

Signing off with this thought:
  
> Any sufficiently complicated syntax highlighter for Raku contains an ad hoc,
informally-specified, bug-ridden, slow implementation of half of STD.pm6.
