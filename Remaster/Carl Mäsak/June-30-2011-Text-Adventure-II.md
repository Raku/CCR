# June 30 2011: Text Adventure II
    
*Originally published on [24 July 2011](http://strangelyconsistent.org/blog/june-30-2011-text-adventure-ii) by Carl Mäsak.*

Welcome back to the putting-together of a real, actual, old-school text adventure game. Today we'll see the second and final part of building the game. This also marks the finale of this blogging "month". Here we go.

We set the stage yesterday with the rooms of the game, and the ability to walk between them. Today we'll "just" add the things that occupy those rooms &mdash; and this, somewhat typically, turns out to constitute around 80% of the game.

In running through this, we'll see a number of useful techniques mirroring what we've been looking at earlier this month. Everything enters into the mix at this point: input/output, variables, `if` statements, various kinds of loops, string operators, arithmetic, `given`/`when`, arrays, boolean operators, subroutines, hashes, junctions, files, nested data, format strings, `map` and `grep` and `first`, subtypes, signatures, and definitely classes/objects/attributes/methods and roles. Yep, that's the whole month. We need it all to build this game.

Here's an excerpt from the final game:

```
> s
Chamber
This is a cramped space just inside the hidden opening in the hill. The
sun gets in enough to illuminate the place. There are some scribblings on
the wall.
There is a sign here.
There is a basket here.
You can go north.
> help   
Here are some (made-up) examples of commands you can use:
look (l)                             | take banana
examine banana (x banana)            | drop banana
[go] north/south/east/west (n/s/e/w) | put banana in bag
open bag                             | close bag
> read walls
"This sentence no verb."
> read walls
"Help, I'm stuck!"
> inventory
You are carrying:
  A flashlight.
  A rope.
> read sign
It says "LEAVE " with big, scrawly lettering. Maybe a warning or a threat.
On closer inspection, though, it looks like there might once have been one
more letter at the end, but it has since been worn away.
> put rope in basket
You put the rope in the basket.
>
```

Here we see the span of different commands that can be issued. A movement command (`s`) causes a new room to be described, along with the things in the room and the visible exits. There are some "special" commands, such as `help` and `inventory`. Apart from that we can do several things (`take`, `drop`, `open`, `close`) with single objects, as well as move objects in more advanced ways (`put rope in basket`).

What happens when we write `read sign` on the command line of the game? The command is *parsed*, which means that the program assigns some structure to the text. In this case, it is recognized that `read` is a verb and `sign` is a noun standing for a thing known to the game. A bit of validation and some magic later, and the user-provided command `read sign` has been translated to the computer-understandable method call `%things<sign>.read`. `%things` is a hash that maps all the nouns to their corresponding objects. In this case, it maps to an instance of the class `Sign` which just happens to have a `.read` method, provided through a role `Readable`.

Similarly, via a slightly different code path, the human command `put rope in basket` gets translated to the computer command `%things<rope>.put( %things<basket> )`. The `Rope` object thus found just happens to have a `.put` method by virtue of being `Takable`. (And this has been validated before the method is called.) Not only that, but the `Basket` object allows things to be put *inside* of it because it is a `Container` (that is, doing the `Container` role) and therefore being provided with an `.add` method.

From a sufficiently high-level perspective, all the common actions on things in the game are enabled by some class in the source code doing some role. "Program to interfaces", says the experienced OO programmer. This is what that's about. Several things in the game can be read, and that's because their object does the role `Readable`, giving them a `.read` method.

I bet you want to have a look at the source code. [Here it is](https://github.com/masak/crypt/blob/e0c02750325b40cf493e1a7e03ebe6f8de5cea67/crypt.pl). If you're concerned that peeking might be considered cheating, you hereby have the author's assurance that learning the principles of programming takes precedence over not gaining inside information in the game. (Or you could just finish the game first, then read the source. ☺)

I'd recommend keeping the source around in a tab while reading the following sections. The program is subdivided in eight parts, and the corresponding sections pull the noteworthy chunky bits out of the source code cookie. The explanations don't contain any particular spoilers, but the source code itself does.

## [Predeclarations](https://github.com/masak/crypt/blob/e0c02750325b40cf493e1a7e03ebe6f8de5cea67/crypt.pl#L1)

Raku programs are read through *once* by the compiler, from top to bottom. If you refer to a class or role before it's been defined, the compiler becomes confused and gives you an error. (In the future, Rakudo will give a compile-time error. Unfortunately, as of this writing it still gives a run-time error, which is worse.)

In order to avoid references to types that haven't been declared yet, we *could* be very meticulous about the ordering of our types, so that they always refer backwards to already defined types. For small programs, that's what we tend to do, and it works fine. (Sometimes, though, referral cycles between types are inevitable, and we can't use this solution.)

*Or* we do as in this script: we predeclare everything. A predeclaration looks like this: `class Sign { ... }`. The three dots there are to be pronounced "yadda yadda yadda", and here they mean that the class isn't defined here. But the class name is registered, and that's exactly what we wanted from the predeclaration. Further down in the code, we get to actually defining the insides of the class (as well as the roles it composes, etc).

In a way, the predeclarations form a "table of contents" of classes and roles. You'll note that they also are grouped suggestively: first comes a list of various roles that give objects various capabilities; then come the things themselves, then a few rooms/locations. As it happens, this is the order that these types are later introduced in the program.

## [Global variables](https://github.com/masak/crypt/blob/e0c02750325b40cf493e1a7e03ebe6f8de5cea67/crypt.pl#L44)

It is generally agreed-upon that global variables are Bad with a capital "B". Especially in a program that otherwise strives to be object-oriented, each global variable is like a defeat, a strike against all that we love and hold dear. Global variables can make people see red, and make them want to rip out all the code and rewrite it.

Why? How come globals are perceived so negatively? Well, it's easy: a global variable has a tendency to thread through the whole program, weaving in and out of classes/roles, forming unholy dependencies everywhere, and making the classes/roles far less re-usable. A class uses a global in a few places, and suddenly that class is dependent on that global. Want to move the class to a different file? That will be difficult; it's coupled to the global variable. Tough luck.

If they're so bad, why are they here, in a program supposed to teach good programmer values? Simply because the cure in this case is deemed to be worse than the desease. We're using these globals in various places &mdash; for example the `%things` hash &mdash; and encapsulating it properly would merely put it further away from everything else, resulting in more unnecessary code to get to it. Our smug sense of having implemented things right would be complemented by heaps of efficious code "doing the right thing" but amounting to nothing.

Strive to do things right, and by all means keep to principles. But be practical too, and know when to deviate from common rules of thumb. (And be prepared to take the ire from people who don't.)

## [Utility subroutines](https://github.com/masak/crypt/blob/e0c02750325b40cf493e1a7e03ebe6f8de5cea67/crypt.pl#L120)

Just as classes are concrete representations of things in our program that we talk about a lot, so subroutines often "condense" out of relations or circumstances that we find ourselves mentioning in a lot of places around the program. For example, whether there is any light in the current room is central to whether we can examine things, read things, or get any location descriptions at all. So we define `there_is_light` in one place, and then we can use and re-use the concept everywhere.

```raku
sub `there_is_light` {
    my $there_is_sun = $room !~~ Darkness;
    return True if $there_is_sun;
    my $flashlight = %things<flashlight>;
    my $flashlight_is_here = player_can_see($flashlight);
    return True if $flashlight_is_here && $flashlight.is_on;
    my $fire = %things<fire>;
    my $fire_is_here = player_can_see($fire);
    return True if $fire_is_here;
    return False;
}
```

The sub has four parts.

- The sun is considered to "be there" if the current `Room` is one that does not do `Darkness`. (That's locations that are outside and thus technically not rooms at all, or rooms that are sufficiently close to outside that the sun is shining in.) If the sun is shining, there is light.
- If there's a flashlight here and it's on, there is light. Note that the player doesn't have to *hold* the flashlight or anything like that; we only require that `player_can_see` the flashlight. (This use of "see" has nothing to do with available light sources, so there's no risk of recusion here; `can_see` simply means that the thing is in the same room and not hidden in a box or something.)
- If there's a fire in the room, that also counts as a light source.
- Having exhausted those three options, we give up and return a `False` value, indicating that the room is without light.

A concept such as `there_is_light` builds on other concepts, such as `player_can_see`, which in turn build on other concepts. Unlike classes and roles, subroutines don't mind referring to each other forwards or backwards, so we don't have to think about predeclaring those. (When the Raku compiler sees a name of something it hasn't seen before, it assumes that it's a subroutine call. Therefore, referring to subroutines that haven't been defined Just Works.)

## [Roles for things and rooms](https://github.com/masak/crypt/blob/e0c02750325b40cf493e1a7e03ebe6f8de5cea67/crypt.pl#L187)

The meat of the game; also, the most fun part to write. If something is meant to contain things, it's a `Container`. If something is meant to be picked up and carried around, it's `Takable`. All things in the game, directly or indirectly, do the general role `Thing`, which provides them with a name and a description, and an `.examine` method.

A couple of insights surprised me along the way. Starting out, I didn't suspect that `Inventory` could be a `Container`, although it's quite evident in retrospect. Shortly thereafter, it became clear that a `Room` is also a kind of `Container`. Then `put`ting things in different places mostly becomes a matter of moving them between various `Container`s.

The roles sometimes interact in fanciful ways. A thing can be `Openable` but not a `Container` (like a `Door`), or a `Container` but not `Openable` (like the `Inventory`). But if it *is* both `Openable` and a `Container`, the `.open` method in `Openable` makes sure to call `self.?on_open`, a method that &mdash; voilà &mdash; `Container` just happens to have. (This method shows the contents of the just-opened container, if any.)

## [Things](https://github.com/masak/crypt/blob/e0c02750325b40cf493e1a7e03ebe6f8de5cea67/crypt.pl#L369)

Most of the work is done and represented in the roles above, which means that in this section when we construct classes for the things in the game, they can be as simple as `class Sign does Readable {}`. Empty class &mdash; all we needed to say was that the `Sign` is `Readable`.

Sometimes, though, we add attributes and methods "at the last minute"; notable among these are `Doom`, the only thing in the game that can kill the player. It has a ticking `$!time_left` attribute, and it can cause the whole cave to collapse. Talk about a powerful object.

At other times, a class will override a method from a role. The class `Walls` would've got a `.read` method from `Thing`, but instead it provides its own, which allows random quips to be read from the walls in the various rooms.

## [Directions](https://github.com/masak/crypt/blob/e0c02750325b40cf493e1a7e03ebe6f8de5cea67/crypt.pl#L531)

This is a pleasant case of several language elements cooperating. We define a couple of global variables for the various "standard directions" and their abbreviations; then we define a subtype `Direction` that restricts `Str` to only the standard directions. Finally we draw up a subroutine that knows how to get the reverse `Direction` from a given `Direction`.

Observe the trick in that subroutine: we only specify one half of the mappings of opposites, and then we "mirror" the hash with `%opposites.invert`, automatically creating the other half.

## [Rooms](https://github.com/masak/crypt/blob/e0c02750325b40cf493e1a7e03ebe6f8de5cea67/crypt.pl#L574)

A `Room` is a `Container` with a few extra methods to handle connecting rooms together, examining the room, and entering the room. A few rooms have a few event methods to trigger various events.

The biggest class in the game is the `Hall`, a room with its own little subgame. The room redefines how it presents its contents, and encourages the player to move disks between rods. This goes to show that even when we've built a set of roles for our classes to compose, there's still plenty of wiggle-room outside of that framework. At any point, we can let a class bloom out into something quite different. The roles are just there for the standard behaviors.

## [The game itself](https://github.com/masak/crypt/blob/e0c02750325b40cf493e1a7e03ebe6f8de5cea67/crypt.pl#L826)

The rest of the game consists almost entirely of the command loop with `when` statements to direct the player's commands to the right method on the right object.

Worth noting is how, in the first few `when` statements, we use `proceed` a lot to "massage" any movement commands into a `Direction` that we can then just use to look up the exit directly. This is slightly easier and more maintainable than one big expression for trying to match and then translate all the possible variants at once.

Sometimes we match commands with string values, but most of the time we match them with regexes. Here the regex syntax comes very much in handy, being able to both match the command string *and* pull out the pertinent information from it. That's what things like `$<verb>` are about in this piece of the code: when a regex matches, the special capture variable `$<verb>` will contain a verb, and we can process it based on that knowledge.

In that vein, it might be instructive to see how we are often working on "two levels", as often happens when interacting with a user.

```raku
my $verb = $<verb>;
if %verb_synonyms{$verb} -> $synonym {
    $verb = $synonym;
}
[...]
unless $thing.can($verb) {
    say "You can't $<verb> the $<noun>.";
    succeed;
}
```

On the game level, we prefer to handle `$verb` which has been de-synonymized and therefor is more regular. (`pick up`, `pick` and `get` all become `take`, for example.) But on the user interface level, we still refer to it as `$<verb>`, the thing we got originally. That way, the user who writes `get basket` will see `You can't get the basket.` and not `You can't take the basket.` A small thing, but usability is king.

Finally, the real magic resides in the method call `.can` above. This method checks ahead of time whether a given method exists in an object. So if the program wants to `read` a `$thing`, it first checks whether `$thing.can("read")` &mdash; if the answer is yes, it proceeds to call the `.read` method on `$thing`.

How can we call a method with a name that varies depending on what `$verb` we provided? We do it like this:

```raku
$thing."$verb"();
```

So, if `$verb` is `read`, we call `$thing.read`, etc. This is the core, the treasure, the butterfly of the game code. Most of the verbs are routed through that line, which maps a player's verb into a method.

Have you finished the game yet? If not, get to it! Good luck!
