# Grammars Get Class-Like, And Other Bits
    
*Originally published on [6 May 2008](https://use-perl.github.io/user/JonathanWorthington/journal/36343/) by Jonathan Worthington.*

I started out the day by looking through the RT queue for Rakudo. Two tickets were already dealt with, so I just closed those. Another was a bug report concerning assigning undef to typed variables. Doing:

```` raku
my Int $x = undef;
````

Would give a type check failure. This is now resolved. Furthermore, if your type is a class name, then assigning `undef` at any point to it will result in it holding the protoobject for that class again. I also took a moment to post to Raku Language to get some clarifications on what `my TypeName $x;` left `$x` being when `$x` was a role, subset type or a junction of types.

Last week I started getting grammars in place. I got so far as having the regex live in the correct namespaces, but that didn't make grammars at all class-like, which is how they should be. This week I set out to fix that. Grammars now get protoobjects too, which you can call `.WHAT` and so forth on. Furthermore, I got inheritance working and also smart-matching against a grammar, which runs its `TOP` rule. Therefore you can now run the following example in Rakudo.

```` raku
grammar Loads { regex Lots { \d+s } };
grammar Many is Loads { rule TOP { <Lots> of <Lots> } };
if "100s of 1000s" ~~ Many {
    say $/; # 100s of 1000s
}
````

Having closed four RT tickets so far, I took a look through there to see what else there was. There was one that did most of what was needed to implement the `.raku` method on `Junction`s (which you can call, in theory anyway, on anything to get a Perl representation of it). I did the required fixes and applied it, but realized in the process that we were missing .raku for any of the really fundamental types, so I added it for `Num`, `Int` and `Str`.

With that done, I spent a little time on the S12 tests. I added fudge directives to get one of the that failed to parse to do so, and added an extra test. I plan to add much more here and flesh out the tests quite a bit over time.

Turning back to the OO support, I did some updates to the grammar that both brought us closer to STD.pm - the official grammar - and added the ability to parse a range of extra things. The first grammar changes were related to method calling. Normally you call a method just with `.`, but private methods are called with `!`. Additionally, there are ways to call sets of methods with quantifiers (^.?^, ^.+^ and ^.*^, with meanings analogous to those in regexes). Finally, I added the ability to scope declarations of routines too, so we can now parse lexical subs and private methods. I stubbed in conditionals for all of these cases that throw unimplemented exceptions, so people didn't use them expecting that because they parse, they will also work.

So, now there's a bunch of stubs in there for another bunch of OO features and, if nobody beats me to it, I'll be filling some of those out on my next Rakudo day, or maybe before then if time allows (though I'm moving apartment - and country - over the coming week, so I'm not expecting to have much time). A big thanks to Vienna.pm for funding today's work.
