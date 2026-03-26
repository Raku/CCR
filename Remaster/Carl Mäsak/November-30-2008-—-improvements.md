# November 30, 2008 — improvements
    
*Originally published on [1 December 2008](http://strangelyconsistent.org/blog/november-30-2008-improvements) by Carl Mäsak.*

136 years ago today, the first [international soccer match](https://en.wikipedia.org/wiki/Scotland_v_England_(1872)) was played. Scotland versus England. There's a [drawing](https://en.wikipedia.org/wiki/Image:England_v_Scotland_(1872).jpg), which reveals that at this early time, soccer was played by hobgoblins and elves. [Wikipedia](https://en.wikipedia.org/wiki/Scotland_v_England_(1872)#The_match):

> The Scots had a goal disallowed in the first half after the umpires decided that the ball had cleared the tape which was used before crossbars were introduced. [...] Scotland would come closest to winning the match when, in the closing stages, a Robert Leckie shot landed on top of the tape which was used to represent the crossbar. At some point in the game, the England goalkeeper, Robert Barker, decided to join the action outfield when he switched places with William Maynard.

The match finished 0-0.

After blogging yesterday, I stayed up all night programming. Repeatedly attacking the problem of parsing mis-nested italics and bold tags, I made more and more tests pass. When I had to give up from exhaustion and go to bed, three tests still failed.

Today I woke up and continued. Now all fourteen tests in [07-italic-and-bold.t](https://github.com/viklund/november/tree/mediawiki-markup/p6w/t/markup/mediawiki/07-italic-and-bold.t) pass. What follows is a short summary of the four components in [Text::Markup::Wiki::MediaWiki](https://github.com/viklund/november/tree/mediawiki-markup/p6w/Text/Markup/Wiki/MediaWiki.pm) that accomplish this, with an eye to Raku features which made the job easier.

First, a tokenizer picks apart a line of text, separating "just text" from tokens with special meaning, such as `''` and `'''`. Note that a tokenizer doesn't care about hierarchical structure; it just dispassionately records the order in which the tokens arrive. A small grammar takes away the pain of iterating manually through the string. Yay Raku!

Second, the tokens are traversed in a `for` loop, and acted upon one by one. "Just text" passed through unharmed, whereas the special tokens changed the state of the traversal mechanism in some way. My goal with this loop was to carry enough state that I wouldn't have to care about anything except for the state and the current token. (For example, I didn't want to post-process the text that I had already output.) I don't know if this type of design is called something, but that seemed wise. Because of this, I could create the final result with a `given` block.

Third, the part of state that kept track of which styles I had already enabled in the current position in the token stream. It's a stack (`@style_stack`), because I have to disable styles in reverse order. The nasty parts of this algorithm consist of digging through the stack, looking for things. I have to do that because the input is not guaranteed to be balanced. The task was slightly improved by smartmatching and a helper sub. Subs are not particular to Raku, but being able to call `take` from within the sub is.

Fourth, another array called `@promises` turned out to be necessary, also because of the non-niceness guarantee of the input. To illustrate, consider the following string:

```
a'''b''c'''d''e
```

Note that italic and bold tokens are mis-nested. A possible output corresponding to this would be this:

```
a<b>b<i>c</i></b><i>d</i>e
```

The array `@promises` would be responsible for briefly carrying the information about an `i` element needing to be re-opened before the `d` text token. We cannot do this in the iteration before `d`, because we don't know at that time that the next token isn't a `''`, like this:

```
a''b'''c'''''d
```

In this case, nothing would be re-opened, because a second `''` token would have already ended the italic style mode before the `d`.

This was the hard part of parsing MediaWiki markup (I hope), and with this part behind me, I'm now aiming for being in a position when replacing our current parser with the `MediaWiki` parser is desirable. Basically, I just need to fix links (which I partly broke during my implementation of styles), and then we're ready to use MediaWiki markup parsing. I will continue work on the mediawiki-markup branch after that, adding features one by one, and merging to master regularly.

A couple of days ago, two non-trivial skins. Then, nice URLs (*ihrd*++). Now, or very soon, solid markup. In a very short time, November has shifted from something that we whipped up during the summer, to something that actually looks good. Don't get me wrong, much work still remains. But we're heading in the right direction, and we're building quite a bit of speed.
