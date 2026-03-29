# Lexpads and why roles need fixups
    
*Originally published on [4 January 2014](http://strangelyconsistent.org/blog/lexpads-and-why-roles-need-fixups) by Carl Mäsak.*

> *We need a solution that makes us need less vodka.*

&mdash; jnthn

There are many extremely simple and elegant software solutions out there. But there are also those special moments, when you realize that something is more complex than you thought, and that the complexity [is most likely essential](https://en.wikipedia.org/wiki/Essential_complexity).

Character encodings are the prototypical example for me. Certainly datetime handling qualifies as well.

Reaching the realization that there is that extra essential complexity, comes (at least for me) with a sinking feeling as I get used to the idea of living with that complexity forever.

With me so far? Something seemed quite easy, wrapped up, ready to go home for the day, but then all this extra complexity rears its head. And it's never going away.

I started writing this blog post because I realized that a certain snag in role handling in Rakudo [doesn't have a URL](https://en.wikipedia.org/wiki/Web_resource), and it really should. So, without fanfare, here's the situation:

```raku
my $x;
role R {
    method foo {
        say $x;
    }
}
class C does R {
}
$x = "OH HAI";
C.new.foo;
```

I think we all agree that this should print `OH HAI`. Good? Good. Nothing up my sleeve, no hidden mirrors or escape hatches &mdash; it *does* print `OH HAI`. Relax. Take a deep breath.

Ready? Because after you learn this, there's no going back. The world will forever be more complicated and, with some luck, you'll be having that sinking feeling.

Ok, so. Just a few simple facts:

- **Blocks have lexpads.**

Think of a lexpad as "all the variables declared in that block, along with the values they contain." I count four blocks in the code above. From smallest to biggest, they are: the method inside the role, the class block, the role block, and finally the entire code which gets a "mainline" block even though that block doesn't have any curly braces.

- **Blocks are linked through `OUTER` links.**

A small block nested inside a larger block has the larger block as its `OUTER`. More precisely, it's the lexpads that are linked. I think the literature refers to these as "parent" blocks, but in Raku we taboo that word and use `OUTER` for lexical lookup (and `CALLER` for dynamic lookup).

- **There's often more than one lexpad per block.**

This one is hard to swallow. But think of a recursive factorial function: `sub fac($N) { $N ?? fac($N - 1) * $N !! 1 }`. As this function calls itself, it's going to need a fresh lexpad with each call. (Or it'll clobber the distinct `$N` values.) Let's call these lexpads *runtime lexpads*.

- **A block always has a static lexpad, and then one or more runtime lexpads.**

Consider this code: `class C { method foo { my $x = 42; method bar { say $x } } }; C.bar;`. In Rakudo, it prints `(Any)`, not 42 as you might think. Why not 42? Because `C.foo` has never run. In fact, the `(Any)` value of `$x` is coming from `C.foo`'s static lexpad, because that's the only lexpad `C.foo` has. (Interesting historical note: it took us a while to get this right in Rakudo. Used to be you could make variable lookups that *didn't* reach the static lexpad, but instead caused a Null PMC Access or similar. Ah, the pain.)

- **Roles are created at compile time.**

This one shouldn't come at a surprise. But we need it for the pressing agony up ahead.

- **Classes are composed at compile time.**

Yep, same. Unless, you know, you're doing high-level MOP-ery. Which we're not in this code.

Let's recap what we know by applying it to the code. There's the variable `$x`. We know we will find it in the static lexpad of the mainline, because it's declared on the top level and everything has a static lexpad. Does it also have a runtime lexpad? Yes, it does, because the mainline starts running after compilation is over. Will we find `$x` in *several* runtime lexpads? No, only the one.

Now, we ask ourselves the question: *which lexpad is `C.foo` referring to?*

"Of course, it's the runtime lexpad", we reply, innocent to the fact that the trap has already shut around us and there's no way out. See, it *has* to be the runtime lexpad, because the sane thing for the program to do is to print `OH HAI`, and that value is *certainly* stored in the runtime lexpad.

But no. It's not possible. It can't. There's no way. Because *roles are created at compile time*, before there is a runtime lexpad! The role method has no choice: it's bound to the static lexpad, because at that point, that's all there is.

And there we are. The trap has now closed. There's no way to both (a) do what the user expects, and (b) keep the internal model nice and free of weird exceptions.

Since we like (a), we ditch (b) and create an exception in Rakudo. It's called a **fixup**, it's installed during role creation, and it makes sure that whenever the block surrounding the role is entered, the role rebinds its `OUTER` to that block's fresh lexpad.

Simple it ain't. Nor is it pretty. But it makes the user happy.

The reason I started thinking about this is that we run into the same kind of problem [with macros](https://rt.perl.org/Ticket/Display.html?id=120928), and the same kind of fixup will probably be needed there.

More to the point, at the point where this need-for-a-fixup starts showing up in different parts of the architecture, it's time to give it a name and perhaps think of a uniform way to address this. That's where jnthn's quote from the start of the post originates &mdash; we need a solution that isn't worse than the problem, and that we can reason about without having to scale the Ballmer peak.
