# Double-oh seven
    
*Originally published on [8 December 2015](http://strangelyconsistent.org/blog/double-oh-seven) by Carl Mäsak.*

It's now one year since I started working on 007. Dear reader, in case I haven't managed to corner you and bore you with the specifics already, here's the elevator pitch:
  
> 007 is a deliberately **small** language that's **fun** and **easy** to develop where I/we can **iterate quickly** on all the silly mistakes needed to get **good macros** in Raku.

At this stage, I'd say we're way into "iterate quickly", and we're starting to see the "good macros" part emerge. (Unless I'm overly optimistic, and we just went from "easy" into a "silly mistakes" phase.)

Except for my incessant blabbering, we have been doing this work mostly under the radar. The overarching vision is still to give 007 the [three types of macros](https://gist.github.com/masak/13210c51f034f931af0c) I imagine we'll get for Raku. Although we have the first type (just as in Rakudo), we're not quite there yet with the other two types.

Instead of giving a dry overview of the internals of the 007 parser and runtime &mdash; maybe some other time &mdash; I thought I would share some things that I've discovered in the past year.

## The AST is the program

The first week of developing 007, the language didn't even have a syntax or a parser. Consider the following simple 007 script:

```raku
say("Greetings, Mister Bond!");
```

In the initial tests where we just wanted to run such a program without parsing it, this program would be written as just its AST (conveniently expressed using Lisp-y syntax):

```
(compunit (block
  (paramlist)
  (stmtlist (stexpr (postfix:<()>
    (ident "say")
    (arglist (str "Greetings, Mister Bond!")))))))
```

(In the tests we helpfully auto-wrap a `compunit` and a `block` on the outermost level, since these are always the same. So in a test you can start writing at the `stmtlist`.)

But 007 isn't cons lists internally &mdash; that's just a convenient way to write the AST. The thing that gets built up is a *Qtree*, consisting of specific Q nodes for each type of program element. When I ask 007 to output what it built, it gives me this:

```raku
Q::CompUnit Q::Block {
    parameterlist: Q::ParameterList [],
    statementlist: Q::StatementList [Q::Statement::Expr Q::Postfix::Call {
        expr: Q::Identifier "say",
        argumentlist: Q::ArgumentList [Q::Literal::Str "Greetings, Mister Bond!"]
    }]
}
```

Yes, it's exactly the same structure, but with objects/arrays instead of lists. This is where 007 begins, and ends: the program is a bunch of objects, a hierarchy that you can access from the program itself.

I've learned a lot (and I'm still learning) in designing the Qtree API. The initial inspiration comes from [IntelliJ's PSI](https://github.com/JetBrains/intellij-community/tree/master/java/java-psi-api/src/com/intellij/psi), a similar hierarchy for describing Java programs. (And to do refactors and analysis, etc.)

The first contact people have with object-oriented design tends to be awkward and full of learning experiences. People inevitably design according to physical reality and what they see, which is usually a bad fit for the digital medium. Only by experience does one learn to play to the strengths of the object system, the data model, and the language. I find the same to be true of the Qtree design: initially I designed it according to what I could see in the program syntax. Only gradually have my eyes been opened to the fact that Qtrees are their own thing (and in 007, the *primary* thing!) and need to be designed differently from textual reality and what I can see.

Some examples:

- I actually put an assignment operator in the Qtree for `my foo = 5;` because that's the first idea that came to me. This was not just repetitive (have to repeat `foo` as the lhs of the assignment), but it conceptually confused assignment as an *operator* with assignment as part of the *special form* `my`. After seeing how PSI does it, I changed `Q::Statement::My` to have an optional expression property instead.
- `Q::CompUnit` is funny. We started out having it, then I removed it as unnecessary. And then it came back again. At this point, `Q::CompUnit` is "something that the runtime accepts and can run". Which means it occurs in exactly two places right now: for an entire program, and (wrapped at the last moment) around `BEGIN` blocks.
- For the longest time, we didn't have `Q::Parameter`. Why should we, when you can simply fill your parameter list with identifiers directly? I could see us wanting a `Q::Parameter` if we ever did optional or named parameters or something, but not without it. Then, the other day, a refactor dealing with "things that declare names" forced me to introduce `Q::Parameter`. A parameter is a kind of declaration (one that's often overlooked), and `Q::Identifier` can't really fill that role, since we use them all over the place even when we don't declare things.

Qtrees are the primary thing. This is the deep insight (and the reason for the section title). We usually think of the *source text* as the primary representation of the program, and I guess I've been mostly thinking about it that way too. But the source text is tied to the textual medium in subtle ways, and not a good primary format for your program. Much of what Qtrees do is separate out the *essential* parts of your program, and store them as objects.

(I used to be fascinated by, and follow at a distance, a project called [Eidola](http://web.archive.org/web/20071006004452/http://eidola.org/), aiming to produce a largely representation-independent programming medium. The vision is daring and interesting, and maybe not fully realistic. Qtrees are the closest I feel I've gotten to the notion of becoming independent of the source code.)

Another thing I've learned:

## Custom operators are harder to implement than macros

I thought putting macros in place wold be hard and terrible. But it was surprisingly easy.

Part of why, of course, is that 007 is perfectly poised to have macros. Everything is already an AST, and so macros are basically just some clever copying-and-pasting of AST fragments. Another reason is that it's a small system, and we control all of it and can make it do what we want.

But custom operators, oh my. They're not rocket science, but there's just so many moving parts. I'm pretty sure they're the most tested feature in the language. Test after test with `is looser`, `is tighter`, `is equal`. Ways to do it right, ways to do it wrong. Phew! I like the end result, but... there are a few months of drastically slowed 007 activity in the early parts of 2015, where I was basically waiting for tuits to finish up the `custom-operators` branch. (Those tuits finally arrived during YAPC::Europe, and since then development has picked up speed again.)

I'm just saying I was surprised by custom operators being hairier than macros! But I stand by my statement: they are. At least in 007.

(Oh, and by the way: you can combine the two features, and get custom operator macros! That was somewhere in the middle in terms of difficulty-to-implement.)

Finally:

## Toy language development is fun

Developing a small language just to explore certain aspects of language design space is unexpectedly addictive, and something I hope to do lots of in the next few years. I'm learning a lot. (If you've ever found yourself thinking that it's unfortunate that curly braces (`{}`) are used both for blocks and objects, just wait until you're implementing a parser that has to keep those two straight.)

There's lots of little tradeoffs a language designer makes all day. Even for a toy language that's never going to see any actual production use, taking those decisions seriously leads you to interesting new places. The smallest decision can have wide-ranging consequences.

## If you're curious...

...here's what to look at next.

- The [README](https://github.com/masak/alma#readme)
- The [tutorial web page](http://masak.github.io/alma/)
- The [ROADMAP.md](https://github.com/masak/alma/blob/master/ROADMAP.md)

Looking forward to where we will take 007 in 2016. We're gearing up to an (internal) [v1.0.0 release](https://github.com/masak/alma/blob/master/ROADMAP.md), and after that we have various language/macro ideas that we want to try out. We'll see how soon we manage to make 007 bootstrap its runtime and parser.

I want to take this opportunity to thank Filip Sergot and vendethiel for commits, pull requests, and discussions. Together we form both the developer team and user community of 007. 哈哈
