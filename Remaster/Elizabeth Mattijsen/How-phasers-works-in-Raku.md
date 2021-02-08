#How phasers work in Raku

*Originally published on [26 October 2018](https://opensource.com/article/18/10/how-phasers-work-perl-6) by Elizabeth Mattijsen.*
  
This is the sixth in a series of articles about migrating code from Perl to Raku. This article looks at the [special blocks in Perl](https://perldoc.pl/perlmod#BEGIN,-UNITCHECK,-CHECK,-INIT-and-END), such as **BEGIN** and **END**, and the possibly subtle change in semantics with so-called [phasers](https://docs.raku.org/language/phasers) in Raku.

Raku has generalized some Perl features as phasers that weren't covered by special blocks in Perl. And it has added other phasers that are not covered by any (standard) Perl functionality at all.

One important feature to remember about phasers is that they are *not* part of the normal flow of a program's execution. The runtime executor decides when a phaser is being run depending on the type of phaser and context. Therefore, all phasers in Raku are spelled in uppercase characters to make them stand out.

##An overview

Let's start with an overview of Perl's special blocks and their Raku counterparts in the order they are executed in Perl:

| Perl      | Raku     | Notes                                  |
| :-------: | :------: | :------------------------------------- |
| BEGIN     | BEGIN    | Not run when loading pre-compiled code |
| UNITCHECK | CHECK    |                                        |
| CHECK     |          | No equivalent in Raku                  |
| INIT      | INIT     |                                        |
| END       | END      |                                        |

These phasers in Raku are usually called [program execution phasers](https://docs.raku.org/language/phasers#Program_execution_phasers) because they are related to the execution of a complete program, regardless of where they are located in a program.

##BEGIN

The semantics of the **BEGIN** special block in Perl and the **[BEGIN]https://docs.raku.org/language/phasers#BEGIN)** phaser in Raku are the same. It specifies a piece of code to be executed *immediately*, as soon as it has been parsed (so *before* the program, aka the compilation unit, as a whole has been parsed).

There is, however, a caveat with the use of **BEGIN** in Raku: Modules in Raku are pre-compiled by default, as opposed to Perl which does not have any pre-compilation of modules or scripts.

As a user or developer of Raku modules, you do not have to think about whether a module should be pre-compiled (again) or not. This is all done automatically under the hood when installing a module and after each Rakudo Raku update. It is also done automatically whenever a developer makes a change to a module. The only thing you might notice is a small delay when loading a module.

This means that the **BEGIN** block is executed only when the pre-compilation occurs, *not* every time the module is loaded. This is different from Perl, where modules ordinarily exist only as source code that is compiled whenever a module is loaded (even though that module can load already compiled native library components).

This may cause some unpleasant surprises when porting code from Perl to Raku, because pre-compilation may have happened a long time ago or even on a different machine (if it was installed from an OS-distributed package). Consider the case of using the value of an environment variable to enable debugging. In Perl you could write this as:

```` perl
# Perl 5
my $DEBUG;
BEGIN { $DEBUG = $ENV{DEBUG} // 0 }
````

This would work fine in Perl, as the module is compiled every time it is loaded, so the **BEGIN** block runs every time the module is loaded. And the value of **$DEBUG** will be correct, depending on the setting of the environment variable. But not so in Raku. Because the **BEGIN** phaser is executed only once, when pre-compiling, the **$DEBUG** variable will have the value determined at module pre-compilation time, *not* at module-loading time!

An easy workaround would be to inhibit pre-compilation of a module in Raku:

```` raku
# Perl 6
no precompilation;  # this code should not be pre-compiled
````

However, pre-compilation has several advantages that you don't want to dismiss easily:

- Data structure setup has to be done just once. If you have data structures that must be set up each time a module is loaded, you can do it once when a module is pre-compiled. This may be a huge time- and CPU saver if the module is loaded often.
- It can load modules *much* faster. Because it doesn't need to parse any source code, a pre-compiled module loads much faster than one that's compiled over and over again. A prime example is the core setting of Raku—the part that is written in Raku. This consists of a 64 [KLOC](https://en.wiktionary.org/wiki/KLOC)/2MB source file (generated from many separate source files for maintainability). It takes about a minute to compile this source file during Raku installation. It takes about 125 milliseconds to load this pre-compiled code at Raku startup. This is almost a *500x* speed boost!

Some other features of Perl *and* Raku that implicitly use **BEGIN** functionality have the same caveat. Take this example where we want a constant **DEBUG** to have either the value of the environment variable **DEBUG** or, if that is not available, the value **0**:

```` perl
# Perl 5
use constant DEBUG => $ENV{DEBUG} // 0;
````

```` raku
# Perl 6
my constant DEBUG = %*ENV<DEBUG> // 0;
````

The best equivalent in Raku is probably an **INIT** phaser:

```` raku
# Perl 6
INIT my \DEBUG = %*ENV<DEBUG> // 0;  # sigilless variable bound to value
````

As in Perl, the **INIT** phaser is run just before execution starts. You can also use Raku's module pre-compilation behavior as a feature:

```` raku
# Perl 6
say "This module was compiled at { BEGIN DateTime.now }";
# This module was compiled at 2018-10-04T22:18:39.598087+02:00
````

But more about that syntax later.

##UNITCHECK

The **UNITCHECK** special block's functionality in Perl is performed by the **[CHECK](https://docs.raku.org/language/phasers#CHECK)** phaser in Raku. Otherwise, it is the same; it specifies a piece of code to be executed when *compilation* of the current compilation unit is done.

##CHECK

There is *no* *equivalent* in Raku of the Perl **CHECK** special block. The main reason is you probably shouldn't be using the **CHECK** special block in Perl anymore; use **UNITCHECK** instead because its semantics are much saner. (It's been available since [version 5.10](https://metacpan.org/pod/perl5100delta#UNITCHECK-blocks).)

##INIT

The functionality of the **[INIT](https://docs.raku.org/language/phasers#INIT)** phaser in Raku is the same as the **INIT** special block in Perl. It specifies a piece of code to be executed *just before* the code in the compilation unit is executed.

In pre-compiled modules in Raku, the **INIT** phaser can serve as an alternative to the **BEGIN** phaser.

##END

The **[END](https://docs.raku.org/language/phasers#END)** phaser's functionality in Raku is the same as the **END** special block's in Perl. It specifies a piece of code to be executed *after* all the code in the compilation unit has been executed or when the code decides to exit (either intended or unintended because an exception is thrown).

##An example

Here's an example using all four program execution phasers and their Perl special block counterparts

```` perl
# Perl 5
say "running in Perl 5";
END       { say "END"   }
INIT      { say "INIT"  }
UNITCHECK { say "CHECK" }
BEGIN     { say "BEGIN" }
# BEGIN
# CHECK
# INIT
# running in Perl 5
# END
````

```` raku
# Perl 6
say "running in Perl 6";
END   { say "END"   }
INIT  { say "INIT"  }
CHECK { say "CHECK" }
BEGIN { say "BEGIN" }
# BEGIN
# CHECK
# INIT
# running in Perl 6
# END
````

##More than special blocks

Phasers in Raku have additional features that make them much more than just special blocks.

###No need for a Block

Most phasers in Raku do not have to be a [Block](https://docs.raku.org/type/Block) (i.e., followed by code between curly braces). They can also consist of a single statement *without* any curly braces. This means that if you've written this in Perl:

```` perl
# Perl 5
# need to define lexical outside of BEGIN scope
my $foo;
# otherwise it won't be known in the rest of the code
BEGIN { $foo = %*ENV<FOO> // 42 };
````

you can write it in Raku as:

```` raku
# Perl 6
# share scope with surrounding code
BEGIN my $foo = %*ENV<FOO> // 42;
````

###May return a value

All program execution phasers *return* the last value of their code so that you can use them in an expression. The above example using **BEGIN** can also be written as:

```` raku
# Perl 6
my $foo = BEGIN %*ENV<FOO> // 42;
````

When used like that with a **BEGIN** phaser, you are creating a nameless constant and assigning it at runtime.

Because of module pre-compilation, if you want this type of initialization in a module, you would probably be better of using the **INIT** phaser:

````
# Perl 6
my $foo = INIT %*ENV<FOO> // 42;
````

This ensures that the value will be determined when the module is *loaded* rather than when it is pre-compiled (which typically happens once during the module's installation).

##Other phasers in Raku

If you are only interested in learning how Perl special blocks work in Raku, you can skip the rest of the article. But you will be missing out on quite a few nice and useful features people have implemented.

###Block and Loop phasers

Block and Loop phasers are always associated with the surrounding Block, regardless of where they are located in the Block. Except you are not limited to having just one of each—although you could argue that having more than one doesn't improve maintainability.

Note that any **sub** or **method** is *also* considered a Block with regards to these phasers.

| Name    | Description                                       |
| :------ | :------------------------------------------------ |
| ENTER   | Run every time when entering a Block              |
| LEAVE   | Run every time when leaving a Block               |
| PRE     | Check condition before running a Block            |
| POST    | Check return value after having run a Block       |
| KEEP    | Run every tkme a Block is left successfully       |
| UNDO    | Run every time a Block is left **un**successfully |

###ENTER & LEAVE

The [ENTER](https://docs.raku.org/language/phasers#ENTER) and [LEAVE](https://docs.raku.org/language/phasers#LEAVE) phasers are pretty self-explanatory: the **ENTER** phaser is called whenever a Block is entered. The **LEAVE** phaser is called whenever a Block is left (either gracefully or through an exception). A simple example:

```` raku
# Perl 6
say "outside";
{
    LEAVE say "left";
    ENTER say "entered";
    say "inside";
}
say "outside again";
# outside
# entered
# inside
# left
# outside again
````

The last value of an **ENTER** phaser is returned so that it can be used in an expression. Here's a bit of a contrived example:

```` raku
# Perl 6
{
    LEAVE say "stayed " ~ (now - ENTER now) ~ " seconds";
    sleep 2;
}
# stayed 2.001867 seconds
````

The **LEAVE** phaser corresponds to the **DEFER** functionality in many other modern programming languages.

###KEEP & UNDO

The **[KEEP](https://docs.raku.org/language/phasers#KEEP)** and **[UNDO](https://docs.raku.org/language/phasers#UNDO)** phasers are special cases of the **LEAVE** phaser. They are called depending on the return value of the surrounding Block. If the result of calling the [defined](https://docs.raku.org/type/Mu#index-entry-method_defined) method on the return value is **True**, then any **KEEP** phasers will be called. If the result of calling **defined** is not **True**, then any **UNDO** phaser will be called. The actual value of the Block will be available in the topic (i.e., **$_**).

A contrived example may clarify:

```` raku
# Perl 6
for 42, Nil {
    KEEP { say "Keeping because of $_" }
    UNDO { say "Undoing because of $_.perl()" }
    $_;
}
# Keeping because of 42
# Undoing because of Nil
````

As may a real-life example:

```` raku
# Perl 6
{
    KEEP $dbh.commit;
    UNDO $dbh.rollback;
    ...    # set up a big transaction in a database
    True;  # indicate success
}
````

So, if anything goes wrong with setting up the big transaction in the database, the **UNDO** phaser makes sure the transaction can be rolled back. Conversely, if the Block is successfully left, the transaction will be automatically committed by the **KEEP** phaser.

The **KEEP** and **UNDO** phasers give you the building blocks for a poor person's [software transactional memory](https://en.wikipedia.org/wiki/Software_transactional_memory).

###PRE & POST

The **[PRE](https://docs.raku.org/language/phasers#PRE)** phaser is a special version of the **ENTER** phaser. The **[POST](https://docs.raku.org/language/phasers#POST)** phaser is a special case of the **LEAVE** phaser.

The **PRE** phaser is expected to return a true value if it is OK to enter the Block. If it does not, then an exception will be thrown. The **POST** phaser receives the return value of the Block and is expected to return a true value if it is OK to leave the Block without throwing an exception.

Some examples:

```` raku
# Perl 6
{
    PRE { say "called PRE"; False }    # throws exception
    ...
}
say "we made it!";                     # never makes it here
# called PRE
# Precondition '{ say "called PRE"; False }' failed

# Perl 6
{
    PRE  { say "called PRE"; True   }  # does NOT throw exception
    POST { say "called POST"; False }  # throws exception
    say "inside the block";            # also returns True
}
say "we made it!";                     # never makes it here
# called PRE
# inside the block
# called POST
# Postcondition '{ say "called POST"; False }' failed
````

If you just want to check if a Block returns a specific value or type, you are probably better off specifying a return signature for the Block. Note that:

```` raku
# Perl 6
{
    POST { $_ ~~ Int }   # check if the return value is an Int
    ...                  # calculate result
    $result;
}
````

is just a very roundabout way of saying:

```` raku
# Perl 6
--> Int {                # return value should be an Int
    ...                  # calculate result
    $result;
}
````

In general, you would use a **POST** phaser only if the necessary checks would be very involved and not reducible to a simple type check.

###Loop phasers

Loop phasers are a special type of Block phaser specific to loop constructs. One is run before the first iteration (**[FIRST](https://docs.raku.org/language/phasers#FIRST)**), one is run after each iteration (**[NEXT](https://docs.raku.org/language/phasers#NEXT)**), and one is run after the last iteration (**[LAST](https://docs.raku.org/language/phasers#LAST)**).

| Name  | Description                                       |
| :---- | :------------------------------------------------ |
| FIRST | Run before the first iteration                    |
| NEXT  | Run after each completed iteration or with `next` |
| LAST  | Run after the last iteration or with `last`       |

The names speak for themselves. A bit of a contrived example:

```` raku
# Perl 6
my $total = 0;
for 1..5 {
    $total += $_;
    LAST  say "------ +\n$total.fmt('%6d')";
    FIRST say "values\n======";
    NEXT  say .fmt('%6d');
}
# values
# ======
#      1
#      2
#      3
#      4
#      5
# ------ +
#     15
````

Loop constructs include **[loop](https://docs.raku.org/language/control#loop)**, **[while, until](https://docs.raku.org/language/control#while,_until)**, [**repeat/while** and **repeat/until**](https://docs.raku.org/language/control#repeat/while,_repeat/until), **[for](https://docs.raku.org/language/control#for)**, and [**map**, **deepmap**, **flatmap**](https://docs.raku.org/type/List#routine_map).

You can use Loop phasers with other Block phasers if you want, but this is usually unnecessary.

##Summary

In addition to the Perl special blocks that have counterparts in Raku (called phasers), Raku has a number of special-purpose phasers related to blocks of code and looping constructs. Raku also has phasers related to exception handling and warnings, event-driven programming, and document (pod) parsing; these will be covered in future articles in this series.
