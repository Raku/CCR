# The typo trap: a farcical FAQ
    
*Originally published on [8 February 2010](http://strangelyconsistent.org/blog/the-typo-trap-a-farcical-faq) by Carl Mäsak.*

*[Update 2010-04-03: The below post is about [a bug](https://github.com/Raku/old-issue-tracker/issues/651) which *jnthn*++ just [fixed](https://github.com/rakudo/rakudo/commit/9a20634ae6cf444b432d5b8dce40688a78b461fa) in Rakudo master. That means that the cause for the main complaint of the post — not getting any sensible error diagnostics whatsoever — has been removed. Yay!]*

**Help! I'm getting the error "`invoke` not implemented in class 'Undef'" in my large application. What did I do wrong?**

You've mistyped a class name which sits inside a namespace.

**How am I supposed to figure that out?**

I didn't say it was a particularly good error message.

It's like this: if you mistype a class name which is not in a namespace, you'll get an informative error message:

```
$ raku -e 'A.foo'
Could not find non-existent sub A
in Main (file src/gen_setting.pm, line 324)
```

However, if you mistype a class name which *is* in a namespace, you will get an *un*informative error message:

```
$ raku -e 'A::B.foo'
`invoke` not implemented in class 'Undef'
in Main (file <unknown>, line <unknown>)
```

So there's your error message. Linking it to the actual cause is something which you'll learn by experience.

**So in that case, I don't get the name of the class which was mistyped in my program?**

Correct.

**And I don't get the line number of my typo?**

Indeed not.

**Or the file?**

Right. You'll get no information about the location of the typo.

**Is that intentional?**

Well, no. As you see from the error message above, the information is meant to be printed, but it comes out as `(file <unknown>, line <unknown>)` instead.

**Why?**

Rakudo is built on top of Parrot. Usually, Rakudo generates its own error messages, but in some cases, Parrot will also generate an error. The error ``invoke` not implemented in class 'Undef'` is such a case. When a Parrot-internal error like this one occurs, Rakudo will not be able to extract the annotation information required to provide a sensible line number and file.

**I... I see.**

Yeah. Sorry about that.

**Are you able to pick up the irony in the fact that when I use namespaces to help mitigate the complexity of my project, I end up with an error message that in fact makes it harder for me to manage the complexity of my project?**

Hold on.

Yes. We are able to pick up the irony in that. Quite easily, in fact.

Consider not using namespaces at the present juncture. They are very useful, but they are also known as a frequent source of annoyances like this.

**By the way, I couldn't help but note that the line number and file information in your first example doesn't make any sense either. What the heck is `src/gen_setting.pm` and `line 324`?**

Well, uh, that's the last line of internal Rakudo code that actually has a working line-and-file annotation. It's nothing that should reach the user, really.

**So that's kinda broken, too?**

Annotations are currently broken, yes. Apologies.

**Back to my mistyped type name. My program is distributed over fifteen modules and ten thousand lines of code. How do you propose I find my typo?**

First off, we recommend that you compile often. That way, the diff from the last working code will not be too large, and you will not have to visually scan so much text hunting for your typo.

Secondly, it's often useful to have your project in a version tracker such as Git, so that you can do `git diff` to see the changes against the index, or against the latest commit.

Thirdly, when all else fails, you can always insert print statements into your code, to try to bisect the origin of the error.

**So in other words, Rakudo is no help whatsoever when this occurs?**

Now, that's not quite fair. Rakudo tells you *that* the error occurs. That's actually useful information.

**And you consider that adequate?**

No, I didn't say that! No-one is happy about this situation. It's just the way things are.

**So it can't be fixed?**

Theoretically, yes. But not easily. Remember that the error occurs in Parrot.

**Don't Rakudo and Parrot developers confer with each other?**

Oh, sure we do. Do not assume that we're deliberately causing this situation. It's just that the current way Rakudo and Parrot are welded together makes the situation non-trivial to rectify.

**So this problem is going to go away with the advent of the new `ng` branch?**

There's nothing to indicate that this would be the case. In `ng`, you currently get a Null PMC access:

```
$ ./raku -e 'A::B.foo' # ng branch
Null PMC access in `invoke`
current instr.: '_block14' pc 29 (EVAL_1:0)
called from Sub '!UNIT_START' pc 984 (src/glue/run.pir:17)
called from Sub 'raku;PCT;HLLCompiler;eval' pc -1 ((unknown file):-1)
called from Sub 'raku;PCT;HLLCompiler;command_line' pc 1489 (src/PCT/HLLCompiler.pir:794)
called from Sub 'raku;Perl6;Compiler;main' pc -1 ((unknown file):-1)
```

To its credit, Rakudo `ng` does provide more information in this case, but unfortunately the information is of a kind which was concealed from the user in Rakudo `master` about a year ago (because it tended to be very uninformative).

**Just to summarize: this all sucks, right?**

That would be a succinct description of the state of this particular error message, yes.

**I heard that the Raku community has adopted very high standards with respect to error messages. There's talk about "awesome error messages", and last summer I was in the audience when Larry Wall demonstrated how good Raku was at reporting error messages to the user. How does this error message square with all of that?**

The awesome error messages are like a platonic ideal towards which all implementations aspire. Rakudo, being rooted in our imperfect physical world, doesn't always get all the way. Yet.

**I'm about to go visually scan ten thousand lines of code, looking for where my error message might have originated. Any last words?**

We value your efforts as an early adopter of Rakudo. Your feedback is important to us. Have a nice day.
