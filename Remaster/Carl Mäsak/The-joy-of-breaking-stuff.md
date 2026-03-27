# The joy of breaking stuff
    
*Originally published on [21 October 2009](http://strangelyconsistent.org/blog/the-joy-of-breaking-stuff) by Carl Mäsak.*

It's not just that I like to try new things in Rakudo, lauding the devs when things work and making Nelson-from-Simpsons sounds when they don't.

It's not just that I like to build way too big applications using Rakudo, in which bugs occur with a rather constant rate, as long as the applications break new ground.

It's also that **I like breaking things**. As soon as you buy the fact that failure is necessary for eventual success, each new segmentation fault, each new Null PMC access, each new strange wtf-just-happened situation is a step forward for Rakudo. Hooray, we just discovered something really bad before our users did! That's great!

That's the reason. It's only an added bonus that there appears to be some kind of weird prestige in having submitted over 500 bug reports to `rakudobug@perl.org` over the past year-and-a-half, and that it's fun to see *pmichaud*++'s and *jnthn*++'s reactions when I smash their stuff. 哈哈

But the bugs I enjoy finding the most are probably the corner cases that I find *just by throwing crazy shit together*. At one point, I thought of automating this process; creating some sort of Raku code generator capable of spitting out insane combinations of feature use, and then feeding these snippets through Rakudo, sifting out the ones that crashed for manual inspection. (This was sometime late last year, when Rakudo felt horribly unstable, and you could basically crash it just by thinking of writing some code.)

Such a code generator might still be a good idea, but (surprise!) it's non-trivial to write. I might still get to writing one — my second design looks promising — but in the meantime, figuring out where untested corner cases might be by just thinking about it ain't that bad either.

The earliest such bug I remember is [trying out diamond inheritence](https://github.com/Raku/old-issue-tracker/issues/707) in Rakudo. You know, D inheriting from B and C, which both inherit from A? Except we use roles instead of classes.

```
<masak> I know. let's do diamonds!
<masak> rakudo: role A { method foo { say "OH HAI" } }; role B does A {}; role C does A {}; class D does B does A {}; D.new.foo
<p6eval> rakudo 543e22: OUTPUT«A conflict occurred during role composition due to method 'foo'. [...]
<masak> this should work, shouldn't it?
<masak> a method shouldn't conflict with itself.
<jnthn> That's a bug.
* masak bugmits rakudosub
```

It's only now that I notice that I botched up the diamond. I never use role C for anything. Oh well.

Roles are tricky. What if one tries to use `does` on a class and `is` on a role? [Boom](https://github.com/Raku/old-issue-tracker/issues/1303).

```
<masak> rakudo: class A {}; role B is A {}; class C does B {}
<p6eval> rakudo 836c8c: OUTPUT«Null PMC access in `get_string`␤in sub trait_mod:is [...]
<masak> mwhahaha.
* masak submits rakudobug
```

(You'll note how this kind of discovery is often followed by uncontrollable laughter on my part. I told you I like this.)

But the last one was especially rewarding. Yesterday, I overheard *jnthn*++ say this on the channel:

```
<jnthn> When a method is composed into a class, it gets associated with that class' methods table.
<jnthn> However, it's still in a lexical scoping relationship with the role.
```

And I immediately got to thinking, "hm, has anyone ever *tried* to reach a variable lexically scoped to a role, from a method called in a class doing that role?". Turns out [that's a bug](https://github.com/Raku/old-issue-tracker/issues/1371) too:

```
<masak> rakudo: role A { my $foo = "OH HAI"; method `bar` { say $foo } }; class B does A {}; B.new.bar
<p6eval> rakudo 1ab069: OUTPUT«Null PMC access in `type` [...]
<masak> haha!
* masak gleefully submits rakudobug
```

The past year has been the most dizzyingly educational year of my whole programming career, thanks to Raku and Rakudo. And to think that I get to combine two of my favorite hobbies: learning about the nitty-gritty of programming languages/compilers/interpreters, and just plain breaking stuff.
