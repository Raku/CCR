# The ghost of Algol 68
    
*Originally published on [9 March 2010](http://strangelyconsistent.org/blog/the-ghost-of-algol-68) by Carl Mäsak.*

Ever wonder why `bash` closes `if` blocks with `fi`? This practice was inctroduced in [Algol 68](https://en.wikipedia.org/wiki/ALGOL_68), a language that Raku [was accused of reinventing](https://www.nntp.perl.org/group/perl.perl6.language/2010/03/msg33321.html) yesterday on the `rakuanguage` list.

Curious, I went to [the Wikipedia article](https://en.wikipedia.org/wiki/ALGOL_68) to read up on Algol 68.
<div class='quote'>
ALGOL 68 (short for ALGOrithmic Language 1968) is an imperative computer programming language that was conceived as a successor to the ALGOL 60 programming language, designed with the goal of a much wider scope of application and more rigorously defined syntax and semantics.</div>

"Successor." "Wider scope of application". "More rigorously defined syntax and semantics". Sound familiar?
<div class='quote'>
ALGOL 68 has been criticized [...] for abandoning the simplicity of ALGOL 60 becoming a vehicle for complex or overly general ideas, and doing little to make the compiler writer's task easy [...]</div>

Oh dear. ☺ We even have the 'do little to make the compiler writer's task easy' meme in Raku...

> *TimToady* after all, Perl Philosphy is simply to torment the implementors on behalf of the user (#raku, [2008-10-09](https://irclogs.raku.org/perl6/2008-10-09.html#20:34))

```
<pmichaud> aha! I have a quote for my keynote.
```

Besides that, there's all these other little parallels, such as

- Algol 68 seemingly playing with words (they borrowed the term 'gomma' from Finnegan's Wake, but the feature it denoted got scrapped in a 1973 revision),
- something junction-like called 'multiple value',
- a whole heap of values for different forms of nothing and undefinedness,
- a newly-invented grammar formalism, and
- a general feeling of deep ambitiousness and a desire to get things right.

So, there are deep similarities between Algol 68 and Raku. There's not much to say to that, except perhaps "huh".

If there's anything in it all that's uplifting though, it's the second paragraph of the article:

> Contributions of ALGOL 68 to the field of computer science are deep and wide ranging, although some of them were not publicly identified until they were passed, in one form or another, to one of many subsequently developed programming languages.

If that's not spot on for Raku, I think it will be in a decade or so.
