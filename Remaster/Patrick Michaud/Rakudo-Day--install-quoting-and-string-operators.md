# Rakudo Day:  install, quoting, and string operators
    
*Originally published on [27 July 2009](https://use-perl.github.io/user/pmichaud/journal/39356/) by Patrick Michaud.*

Since I was busy at OSCON all this week, it was difficult to find
a single day to dedicate to my Vienna.pm grant.  But I did manage
to get several major tasks done from my hotel room,
so I'm going to bundle those together and count them as my
"Rakudo day" for the week.

The biggest accomplishment was to finally get
Rakudo so that it can build from an installed Parrot.  Prior to
Parrot 1.4.0 this has been exceedingly difficult, as an installed
copy of Parrot did not provide all of the tools needed to
compile dynamic PMCs and dynamic opcodes on our target platforms.
But over the past few weeks Allison Randal and Will Coleda
have gotten it to work for 
ParTcl, and now I've
been able to adapt those techniques to work with Rakudo.  The
current state of building Rakudo from an installed Parrot is
in the "ins2" branch of the github repository, if you wish to
give it a try.  (See below for instructions.)  Note that some of 
the spectests will fail if you try "make spectest"; because 
the "ins2" branch is using an older version of Rakudo and some 
spectests have been added to the test suite since then.
Since we're really just testing build/install, "make test"
is sufficient here (and I'll clean up any spectest issues when
I merge it back to the master branch).

Some may ask why we don't simply merge it back to master now;
I haven't wanted to merge the ins2 branch back into trunk until
we have verification that it builds properly on a variety of
platforms.  So far I've only had it fully tested on a couple
of versions of Linux; I don't want to end up cutting out
other operating systems from playing with Rakudo.

One of the downsides of building Rakudo from an installed Parrot 
is that we effectively lose the ability to easily build Rakudo
from a build-tree copy of Parrot (like we do now).  Part of the
problem is that the filesystem layout of a build-tree copy of Parrot
is very different from the filesystem layout of an installed Parrot.
So at a minimum we would need a lot of code that says "if installed
Parrot use this path, if Parrot build use this other path".  This
is true not only for file locations, but also for the tools used to
build dynamically loaded PMCs and opcodes.  Instead of trying to
support both layouts, I'd prefer to just stick with using an
installed Parrot for now.

(Note that it doesn't have to be a system-installed Parrot, the
```
--gen-parrot` option to Rakudo's `Configure.pl` will make
a local install of Parrot and then build Rakudo from that.)
```

We're not abandoning the ability to build Rakudo from a build-copy
of Parrot, we're just switching gears for a while.
Based on conversations with other Parrot team members at
YAPC::NA Pittsburgh and online, we've decided that of building 
(but not installing) Parrot should result in something that 
directly mimics the filesystem layout of an installed Parrot.
When this is done, it will be easier for HLL languages
and other tools built on Parrot to work from either a build
tree or install tree version of Parrot.

In other areas, during Monday's OSCON tutorial sessions I
sat in on Damian Conway's "Raku: Why? What? How?" tutorial.  I wanted to
see the tutorial itself, but I was also curious to know what
problems would arise during the tutorial so that I could work 
on fixing them quickly.  One of the problems that was quickly
identified was that the `<< ... >>` quoting operator
wasn't handling comments properly.  In other words, the following code

```raku
my $a = <<
    do         # a deer
    re         # a drop of golden sun
    mi         # a name I call myself
>>;
```

would act like a list of eighteen words instead of three.  To be
honest, I had overlooked that comments were allowed here, so that
evening I quickly updated the parser to skip over comments as well
as whitespace, and now the above works the way it is supposed to.  
Note that it even skips embedded and pod comments:

```raku
my $a = << do #(a deer) re #(a drop of golden sun) >>;  # ("do", "re")
```

We had quite a few tickets dealing with places where operations
end up returning Parrot `String` objects instead of Raku
`Str` objects.  The easiest way to detect when this happens
is to attempt to perform `.trans` on the string -- the `.trans`
method for Parrot strings doesn't work the same as Rakudo's
`.trans` method.  So I converted a few settings functions
(e.g., `.uc`, `.flip`, `.lc`, etc.) to explicitly call 
`prefix:<~>` on the result value; this guarantees that we 
end up with a Raku `Str` object.

When we ultimately switch Rakudo to use HLL mapping of Parrot
types, these explicit coercions won't be needed.  However,
at the moment using HLL mapping imposes a significant speed
penalty on Rakudo (we're working on this), and given that
things are on the slow side already I'd rather keep the
speed and maintain workarounds for the time being.

I also fixed up stringification of several of the builtin types,
especially `Int`, `Num`, and `Junction`.  Previously
printing a Junction object would produce a string like
`"Junction<0x7fb898cb42b0>"`, which is almost certainly not
what is wanted.  So I updated `Junction.Str` to simply
return its `.raku` representation.

Finally, Rakudo had been misparsing function names that began with
a keyword followed by an apostrophe or hyphen.  For example:

```raku
sub do-something { say 'hello'; }

do-something;
```

Because `do` is a keyword, Rakudo would often end up parsing
the above as `do -`something``, which of course wouldn't
work properly.  Similar issues existed with other keywords such
as `if`, `for`, `while`, etc.

Having a longest-token matcher in the parser can avoid a lot
of these misparses, but it's not always a complete solution.
The STD grammar (as well as Rakudo's grammar) has a special
`<.nofun>` lookahead subrule that can be used to verify that
the keyword we just scanned is actually a keyword and not
simply the lead-in to a function call.  I went ahead and
added a few <.nofun> calls to Rakudo's grammar, and now
subroutine names that begin with keywords work like they're
supposed to.  (Thus making them a lot more fun.  :-)

There were other fixes here and there throughout the week, and
of course Moritz Lenz did the Rakudo #19 release on Thursday
(which I describe in [another post](Behind-the-scenes-of-the-Chicago-Release.html).
I also worked with 
Jonathan on improving our internal object metamodel and 
introspection capabilities, and he and I worked out some 
ideas for refactoring our handling of lexicals.  And all of
this took place while I was attending OSCON, giving various
presentations, and engaging in useful hallway discussions with
other Perl folks.  So it's been a busy and good week.

As always, my thanks go to Vienna.pm for sponsoring the work
I did on the above tasks.  Because of all of the travel and
conferences I'm a bit behind on Rakudo days, so I will likely
try to double-up on them for a few weeks until I'm caught up.

To test the ins2 branch:

```
$ git clone https://github.com/rakudo/rakudo.git
$ git branch ins2 origin/ins2
$ git checkout ins2
$ perl Configure.pl --gen-parrot
$ make test
````
