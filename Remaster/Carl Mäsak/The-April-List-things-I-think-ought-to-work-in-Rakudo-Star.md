# The April List: things I think ought to work in Rakudo Star
    
*Originally published on [8 September 2009](http://strangelyconsistent.org/blog/the-april-list-things-i-think-ought-to-work-in-rakudo-star) by Carl Mäsak.*

I took an hour or so to go through the RT bug list of known Rakudo issues, searching for things that I think should be fixed by April. Here they are.

There are currently over 400 new/open bugs in RT. These only form a slice of those. My criteria for slicing have been, more or less, "what would hurt more, fixing this bug, or having to explain to the hordes of new users in Q2 2010 why this particular bug exists?". Whenever the latter weighs heavier, I include the ticket in the list.

(This also shows a different statistic, and quite a positive one: while there are many bugs in RT right now, many of them pertain to corner cases, or minor issues. In other words, Rakudo is getting more usable.)

For those in a hurry, I've marked the most egregious issue in each category in bold.

## Command line

On the command line, Rakudo...

- ([#52242](https://github.com/Raku/old-issue-tracker/issues/66)) **thinks that unknown command line options are files** 
- ([#58592](https://github.com/Raku/old-issue-tracker/issues/297)) cannot combine the --target and -e command options
- ([#62462](https://github.com/Raku/old-issue-tracker/issues/614)) has no -V flag
- ([#68752](https://github.com/Raku/old-issue-tracker/issues/1249)) has a --version flag, but it's useless


## Parsing

During parsing, Rakudo...

- ([#53804](https://github.com/Raku/old-issue-tracker/issues/76)) parsefails on adverbial blocks
- ([#61494](https://github.com/Raku/old-issue-tracker/issues/506)) **gives different errors depending on the amount of whitespace between some things** (*Update 2010-03-20:* This particular parsefail is no longe plaguing us.)
- ([#61838](https://github.com/Raku/old-issue-tracker/issues/535)) doesn't complain when a variable is used before it's declared
- ([#64170](https://github.com/Raku/old-issue-tracker/issues/833)) uses the old 'is also' instead of the new 'augment' (*Update 2010-03-20:* Now uses 'augment'.)
- ([#64526](https://github.com/Raku/old-issue-tracker/issues/871)) doesn't complain when a variable is used in the statement where it's declared
- ([#64688](https://github.com/Raku/old-issue-tracker/issues/888)) can't import other modules inside class declaration
- ([#65904](https://github.com/Raku/old-issue-tracker/issues/1009)) dies horribly when declaring a sub with an invocant
- ([#65962](https://github.com/Raku/old-issue-tracker/issues/1016)) doesn't allow multiple 'my' declarations in loop init (*Update 2010-06-22:* Has been fixed a while now.)
- ([#66034](https://github.com/Raku/old-issue-tracker/issues/1020)) parses dotty and infix '.=' differently (*Update 2010-05-04:* Parses them the same now.)
- ([#66498](https://github.com/Raku/old-issue-tracker/issues/1049)) two words: snowman. comet. (*Update 2010-03-20:* No more.)
- ([#66948](https://github.com/Raku/old-issue-tracker/issues/1099)) should parse reduce metaops as listops
- ([#66996](https://github.com/Raku/old-issue-tracker/issues/1103)) doesn't parse all pair constructors correctly (*Update 2010-03-20:* Now it does.)
- ([#68086](https://github.com/Raku/old-issue-tracker/issues/1187)) allows the same positional to be declared multiple times in a param list (*Update 2010-05-04:* Fixed since quite a while back.)
- ([#68918](https://github.com/Raku/old-issue-tracker/issues/1265)) ignores decimal points in base conversions (*Update 2010-05-04:* Doesn't ignore them anymore.)

## Runtime

At runtime, Rakudo...

- ([#58258](https://github.com/Raku/old-issue-tracker/issues/270)) **oddly thinks that each line of interactive code is in an invisible block** 
- ([#58372](https://github.com/Raku/old-issue-tracker/issues/282)) dies when indexing undef
- ([#61566](https://github.com/Raku/old-issue-tracker/issues/513)) doesn't do type checking on binding
- ([#61732](https://github.com/Raku/old-issue-tracker/issues/537)) dies horribly on the return value of empty statements
- ([#63126](https://github.com/Raku/old-issue-tracker/issues/688)) treats junctions combined with indexing not-so-good
- ([#63430](https://github.com/Raku/old-issue-tracker/issues/718)) can't handle CATCH and &return together
- ([#63912](https://github.com/Raku/old-issue-tracker/issues/776)) can't &return a list of values (*Update 2010-05-13:* Now it can.)
- ([#64522](https://github.com/Raku/old-issue-tracker/issues/870)) allows constants to be modified (*Update 2010-05-13:* Also fixed now.)
- ([#64888](https://github.com/Raku/old-issue-tracker/issues/924)) tries (and fails) to redeclare anonymous classes when same code is re-run (*Update 2010-05-04:* Now tries and succeeds.)
- ([#66890](https://github.com/Raku/old-issue-tracker/issues/1093)) dies horribly in for loops when args don't match up with list
- ([#67142](https://github.com/Raku/old-issue-tracker/issues/1115)) ranges aren't immutable (*Update 2010-03-20:* They are now.)
- ([#67234](https://github.com/Raku/old-issue-tracker/issues/1118)) dies [during [*TimToady*'s keynote](http://videos.sapo.pt/yapc/50dllc2fnsM7phJy24fP)] when an undef is sent to PGE (*Update 2009-10-20:* now fixed)
- ([#67372](https://github.com/Raku/old-issue-tracker/issues/1128)) doesn't give line numbers with &warn (*Update 2010-06-22:* It does now.)
- ([#68116](https://github.com/Raku/old-issue-tracker/issues/1191)) doesn't accept subs as &-sigilled parameters (*Update 2010-05-04:*Does now.)

## TODOs

Perhaps the most subjective part of my list. What finally made it on this list are features which are "almost there", and which people will probably ask about if they're not fully implemented.

- ([#60672](https://github.com/Raku/old-issue-tracker/issues/418)) %C in sprintf
- ([#62476](https://github.com/Raku/old-issue-tracker/issues/635)) **:by on ranges** (*Update 2009-09-22:* :by is now deprecated by recent spec changes)
- ([#63292](https://github.com/Raku/old-issue-tracker/issues/705)) triangle reduce metaoperator (*Update 2010-05-04: *We can haz it!)
- ([#65654](https://github.com/Raku/old-issue-tracker/issues/994)) texas quotes not yet awesome
