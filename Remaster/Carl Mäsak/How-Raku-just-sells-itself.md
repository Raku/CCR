# How Raku just sells itself
    
*Originally published on [24 May 2009](http://strangelyconsistent.org/blog/how-perl-6-just-sells-itself) by Carl Mäsak.*

Having been away for the weekend, I had the pleasure of backlogging over the following [exchange](https://irclogs.raku.org/perl6/2009-05-22.html#20:22) on #raku. I'll reproduce it here (in a condensed form divided into sections), to show three things:

- What I mean by "#raku is a **friendly** place". (Cf. ["Barefoot"](Barefoot.html))
- Some of the **excitement** I myself sometimes feel when dealing with Raku.
- How Raku basically **sells itself** in some cases.

Enjoy.

## OH HAI

```
<sjohnson> hello, anyone awake and wants to chat about perl?
<jnthn> sjohnson: For some definition of awake. :-)
```

## Community transparency

```
<sjohnson> is it possible to submit something to the developers of perl for consideration into the new Raku spec?
<jnthn> A lot of Raku developers hang out here (well, mabye not loads at this exactly point in time... ;-))
<jnthn> There's also the rakuanguage mailing list.
<jnthn> What were you thinking of?
<*TimToady*> sjohnson: for most such suggestions, there's a good chance it has already been considered at some point :)
<sjohnson> ok i will tell my ideas
```

## `.trim```

```
<sjohnson> do you think Mr. Wall would consider a whitespace trim function like in every single other language, instead of 1) having to depend on CPAN or 2) having to write your own regex function or 3) doing the raw regex each time yourself
<*TimToady*> it's already there
<*TimToady*> S32-setting-library/Str.pod: =item trim
<jnthn> rakudo: my $x = "  abc  "; say $x.trim;
<p6eval> rakudo 5eac9b: OUTPUT«abc␤»
<jnthn> sjohnson: Implemented in Rakudo even. :-)
<sjohnson> YESSSSSSSSSSSSSSSSSSs
<sjohnson> !!!!
<*TimToady*> told you we might have considered it already :)
<sjohnson> i am very happy to ehar that
<[particle]-> (Mr. Wall)++
<*TimToady*> biab, will backlog
```

## `if` and curlies

```
<sjohnson> will Raku let you do:  if (1) return 1; .... or give you a syntax error
<jnthn> You must have the curly braces.
<jnthn> return 1 if cond; # is fine though
<sjohnson> ahh so perl 6 will still make the curly braces necessary for that one statement eh.. :(
<jnthn> sjohnson: Dangling syntax considered nasty.
<jnthn> sjohnson: On the up side, the parens around the conditional are optional.
<jnthn> if $x == 42 { say "the answer" }
<sjohnson> thats kind of nice
<sjohnson> as i hated those too
<sjohnson> but i can live with just writing it backwards
<sjohnson> do something if 1;
<sjohnson> tho in perl 5 you dont need parens when it's written like that either which is nice
<jnthn> Yes, true.
<sjohnson> but that is still good news to me
```

## Indexing strings

```
<sjohnson> can you edit strings by doing things like $string[3] = 'a';
<sjohnson> in perl 6?
<jnthn> sjohnson: No, not for a string, but there's a type called Buf (short for buffer) that lets you do that kind of thing.
<jnthn> So far as I know anyway.
<jnthn> One thing to note is that Raku is very careful in the whole area of units.
<jnthn> "length" is kinda a dirty word. :-)
<sjohnson> length($string) will behave a bit differently?
<jnthn> length is gone.
<jnthn> You gotta say what you want.
<jnthn> chars($string) # characters
<jnthn> bytes($string) # how many bytes
<jnthn> Note you can call 'em as methods too.
<jnthn> $string.chars
<sjohnson> thats not too bad
```

## Switch statements

```
<sjohnson> will Raku contain a switch / case structure?
<japhb> sjohnson: given/when.
<japhb> sjohnson: and it's quite powerful.
<sjohnson> wow i am excited
```

## `.pick```

```
<sjohnson> japhb: Perl has a `sort` for arrays without the need for cpan.  Will a `shuffle` be available for Raku?
<japhb> sjohnson: yup.  It's called pick
<japhb> rakudo: say <1 2 3 4 5>.pick(*)
<p6eval> rakudo 5eac9b: OUTPUT«53241␤»
<japhb> rakudo: say <1 2 3 4 5>.pick(2)
<p6eval> rakudo 5eac9b: OUTPUT«35␤»
<sjohnson> there's a shufflefunction called `pick` to shuffle arrays?  that's an odd name
<japhb> sjohnson: pick is the more general function.
<japhb> shuffle is just the special case of pick on the entire array.
<jnthn> sjohnson: .pick without an argument gets one item.
<sjohnson> jnthn:  does it remove it out of the array?  im worried about "picking" twice
<jnthn> sjohnson: No, it doesn't.
<jnthn> sjohnson: You can pass a number to .pick to say how many you want.
<jnthn> sjohnson: If you to .pick(*) it means "all of them"
<jnthn> When you ask for more than one, though, the order can vary.
<jnthn> (as in, is random)
<japhb> sjohnson: both pick-without-replace and pick-with-replace are available.  It's just an adverb on the pick method.
<jnthn> Ooh, I'd forgot about pick with replace. :-)
```

**[Update:]** Nowadays `.pick(:replace)` is spelled `.`roll``.

## `.uniq```

```
<sjohnson> Q:  is there a uniq(@array); function too?
<japhb> rakudo: say <1 2 3 2 5 6 4 3>.uniq.perl
<p6eval> rakudo 5eac9b: OUTPUT«["1", "2", "3", "5", "6", "4"]␤»
<japhb> yup
<japhb> :-)
```

## p6eval

```
<sjohnson> wow on irc parser eh
<sjohnson> rakudo: print "hello sjohnson";
<p6eval> rakudo 5eac9b: OUTPUT«hello sjohnson»
<japhb> sjohnson: Because Raku is a spec/testsuite with a number of implementations, the evalbot can actually show you the current response from each known implementation of Raku.
<jnthn> sjohnson: When you prefix something with rakudo: here, it takes it and compiles/runs it.
```

## Method-call syntax

```
<sjohnson> japhb: is what you wrote a real raku syntax?
<sjohnson> i dont think you can do that in perl 5... using dots after things like that. am i wrong / right?
<japhb> sjohnson: Yep.  $object.foo is roughly $object->foo in Perl.
<jnthn> sjohnson: The . is the Raku method call operator.
<jnthn> ETOOMANYEXPLAINERS :-)
<japhb> There can never be too many.
```

## Extacy

```
<sjohnson> fuck i cant wait for perl 6
<japhb> sjohnson: It's here.  Just not 100% implemented yet.
<sjohnson> print "happy "house".trim;
<sjohnson> rakudo:  print "    happy house    \n".trim;
<p6eval> rakudo 5eac9b: OUTPUT«happy house»
<sjohnson> fuck i am in love
<sjohnson> sorry for the course language
<sjohnson> but all of this is WAY better than perl 5
<japhb> It's a strong emotion, we understand. ;-)
<jnthn> sjohnson: There's even more cool stuff. :-)
<skids> sjohnson: rumor has it raku might swear occasionally too :-)
```

## Introspection

```
<sjohnson> rakudo: say <1 2 3>.class
<p6eval> rakudo 5eac9b: OUTPUT«Method 'class' not found for invocant of class 'List'␤»
<japhb> rakudo: say <1 2 3>.WHAT
<p6eval> rakudo 5eac9b: OUTPUT«`List`␤»
<skids> Most of the "introspection" stuff is allcaps methods like WHAT HOW etc.
<sjohnson> rakudo:  say 3.WHAT
<p6eval> rakudo 5eac9b: OUTPUT«`Int`␤»
<sjohnson> wow it's like ruby
```

## Community

```
<sjohnson> all this stuff larry wall decided should go into Raku?
<japhb> sjohnson: and more.  How about this one:
<japhb> rakudo: (<a b> X <1 2>).say
<p6eval> rakudo 5eac9b: OUTPUT«a1a2b1b2␤»
<[particle>-> sjohnson: it's a community rewrite of perl, not (just) larry's rewrite
```

## `qx//` without variable interpolation

```
<sjohnson> in Raku, can there be a qx/ / without $string interpolation?
<japhb> sjohnson: yes, there are both interpolating and non-interpolating versions of qx.
<skids> sjohnson: there's just about any quoting form you could desire, Q: takes many adverbs that can be mixed together.
```

## Learning Raku

```
<sjohnson> how will one learn about all the tricks in Raku that are new, if one has already purchased Programming Perl (v5)
<jnthn> sjohnson: There are various places to follow Raku news, and at least one documentation project.
<jnthn> Plus this place is pretty good for questions. :-)
```

## Do we like Perl or Python?

```
<sjohnson> do you guys in general, prefer Perl over Python?
<sjohnson> reason i ask is because the Perl fans seem to live in caves / don't post their thoughts on the debate
<sjohnson> it would be refreshing to hear some opinions that they like Perl better for once
<japhb> sjohnson: It just doesn't seem a debate worth fighting.  Especially since Parrot allows both to run in the same process and commingle nicely.
<jnthn> I can't speak for everyone, but on my part getting into "my language is better" debates always feels a tad pointless. For one because part of language preference is just what people personally like too.
<jnthn> I'm happy to point out factual inaccuracies if I spot them and it looks like a genuine mis-understanding rather than a troll.
<wayland76> sjohnson: Yes, I prefer Perl over Python.  But I mostly agree with jnthn about these debates being somewhat pointless.
<sjohnson> not so much a debate i would like to see, but someone sincerely admit that they prefer Perl over Python ... with that person having worked with both
<wayland76> Let me give an example of pointfulness, though
<wayland76> There's a book by Raphael Finkel called "Advanced Programming Language Design", and it talks about the criteria that people may or may not use for judging a language
<wayland76> Perl happily violates almost all the principles mentioned in order to maximise one principle -- expressiveness
<JDlugosz> I've read books like that from a more classic era.  Things were more interesting then, I think.  Now they just study Java and C.
<wayland76> JDlugosz: Well, the Finkel one actually means "Advanced".  This is "What to do next after you've done a basic Compilers course"
<wayland76> Oh, the opinion that Perl maximises expressiveness is mine, naturally, and didn't come from the book)
<wayland76> Btw, the Finkel book is free online as a PDF, but I liked it so much that I bought it anyway
<JDlugosz> Algol, PL/1, LISP, SnoBol, REXX, ...
<JDlugosz> Got a link for the PDF?  Like catnip...
<wayland76> JDlugosz: http://www.nondot.org/sabre/Mirrored/AdvProgLangDesign/
```

## Almost exactly like Ruby

```
<sjohnson> rakudo:  say 1..10.WHAT
<p6eval> rakudo 23718a: OUTPUT«Use of type object as value␤␤»
<sjohnson> rakudo:  say (1..10).WHAT
<jnthn> skids: S12.
<p6eval> rakudo 23718a: OUTPUT«`Range`␤»
<sjohnson> fuck Raku is almost exaclty like Ruby... am i right?  i am happy about it
<sjohnson> oops gotta watch my mouth
<sjohnson> just so excited!!!
<wayland76> sjohnson: Almost!  But More Better :)
<jnthn> sjohnson: Well, Ruby was a source of inspiration too.
<wayland76> (Actually I haven't used enough Ruby to make a judgement call :) )
<jnthn> Perl has always been a langauge that borrows from others though.
<sjohnson> i am so excited i can hardly stand it
<sjohnson> im not even joking
<wayland76> sjohnson: Raku has that effect on me too sometimes :)
```

## Official Larry Wall release?

```
<sjohnson> any time frame for an official Larry Wall release? hopefully not super long
<wayland76> sjohnson: Raku is a specification, there are multiple implementations of that specification
<wayland76> No one implementation is the "Official" one
<sjohnson> is there one written in C tho / will Larry Wall pick one of them to be official?
<sjohnson> or will he write one himself with his buddies?
<wayland76> There's one called "Rakudo" that's built on the virtual machine called "Parrot"
<wayland76> And there's one called SMOP that is, IIRC, written in C
<wayland76> The big advantages of Rakudo are a) it seems the most complete at the moment, and b) it will be very interoperable with other Parrot-based languages
<wayland76> The big advantage of SMOP is that it will integrate well with Perl
<japhb> sjohnson: Larry is specializing in spec and canonical parser (STD).  (Most) implementation is left to others.
<japhb> s/parser/grammar/
<wayland76> Yes, i forgot to mention STD is an official Larry Wall grammar
<wayland76> I'm expecting it will be used by both Rakudo and SMOP at some point
<wayland76> (I'm not involved in either project, except on the periphery of Rakudo)
<skids> std: my $a # STD doesn't run code it just says whether the syntax is valid
<p6eval> std 26914: OUTPUT«ok 00:02 36m␤»
<skids> pugs: "I'm cold, and I forgot where I put my teeth.".say
<p6eval> pugs: OUTPUT«I'm cold, and I forgot where I put my teeth.␤»
<wayland76> (pugs is an old implementation that doesn't seem to have anyone working on it any more)
```

## The state of things

```
<sjohnson_> wayland76:  are there Raku things out right now that are fully functional that i dont have to install 3 separate things to get it to inpret, so i can start scripting in it?
<sjohnson_> and that aren't much slower than perl 5
<wayland76> sjohnson: Not sure what you mean
<wayland76> No.  Raku is not complete, and Rakudo at least are not worried about speed very much until it's complete
<jnthn> JDlugosz: I tend to see it more as, in *C*++ I see there's one syntax and it may do a cast and it may do a coercion.
<revdiablo> sjohnson_: Do you mean is there a perl 6 implementation ready for production use? No. Not yet.
<skids> First make it work"
<wayland76> sjohnson1: Basically, there's nothing out there that's simple to install; i expect that to change within the next month or two, but feature complete and production ready are definitely further away
<sjohnson> i used to think ruby would solve all the scripting problems in the universe, but now i think perl 6 will
```

## Is the spec done yet?

```
<sjohnson> is the Raku spec done, finished, over?  or is larry still cooking up some ideas of his
<wayland76> The Raku spec is still changing
<wayland76> For example, Larry just recently added some more specific stuff about how to override sublanguages (eg. regex) in the grammar
<wayland76> But some sections of the spec are moderately stable
<wayland76> What tends to happen is the implementors get arguing about what *should* happen, and then Larry resolves everything with a brilliant new idea (That doesn't happen with all arguments, but it's what drives some of the spec changes)
```

## Community transparency redux (aka "Mr. Wall comes here!?")

```
<sjohnson> does anyone know of the -devel mailing list for Raku, and if Larry himself ever reads it?
<wayland76> sjohnson: There's a "Language" list and a "Compilers" list
<skids> He reads rakuanguage and also comes here.
<wayland76> Language is for arguing about the Spec.  I'm on it, and so is Larry.
<wayland76> (rakuanguage is the "Language" list I mentioned)
<wayland76> I'm not on Compilers, so I can't speak for it
<sjohnson> skids, how often does he come here?  what's his nickname when he does?
<wayland76> lambdabot: @seen *TimToady*
<lambdabot> *TimToady* is in #raku. I last heard *TimToady* speak 3h 9m 56s ago.
<skids> sjohnson: you already talked to him, in fact, when you first logged in.
<sjohnson> wow
<sjohnson> i had no idea that was him!!!
<skids> :-)
```
