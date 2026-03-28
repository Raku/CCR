# June 2 2011: Variables
    
*Originally published on [2 June 2011](http://strangelyconsistent.org/blog/june-2-2011-variable) by Carl Mäsak.*

Yesterday we wrote a program that engaged in a bit of dialogue with the user.

```raku
say "Hello.";
prompt "What is your name? ";
say "Nice to meet you.";
```

Problem is, by the time the program reaches the last line and prints `Nice to meet you.`, it's already "forgotten" the user's name. We'd like some way for the program to keep the name around so that we can re-use it later.

There's a mechanism for this, and it's called a *variable*. With two simple additions to our program, we can make it do what we want:

```raku
say "Hello.";
**my $name =** prompt "What is your name? ";
say "Nice to meet you**, $name**.";
```

See how we use the variable `$name` first to scoop up the result from the `prompt` command, and then again in the string we print? That's generally the two things that we do with variables: we assign values to them, and later we use those values. They're like little sticky notes that we write things on to remember for later.

We can decide for ourselves what we want to call a variable. Here we went with `$name`, since it stores a name. The dollar sign up front (`$`) needs to be there: that's how we know it's a variable and not a command. (In other words, `say` is a command, but `$say` would be a variable.) The dollar sign is called a *sigil*. We'll see other sigils later on, but for now we only need the dollar sign. For the rest of the variable name, we're allowed to use letters, numbers, underscores (`_`), even a dash (`-`) if we're nice. The variable name should start with a letter though, after the sigil.

The first time we mention a variable in a program, we need to write `my $variable`, or we'll get an error when we try to compile the program. We call this practice of writing `my` the first time *variable declaration*: we declare that we're going to use a variable. It needn't be that way — some languages allow you to go ahead and just use a variable without declaring it first. That may be less work, but it's also far easier to slip up and make a typo somewhere. If you make a typo in a Raku variable, you'll notice right away when you try and compile.

Note that when we use the variable, we use it inside of a *string value*. That's perfectly fine, and will do what we mean. One of the nice things about having sigils on our variables is that we can put them inside string values like that, and they will be recognized and handled (*interpolated*) appropriately. Interpolation will only work if you use double quotes around your string, by the way.

In other words, string interpolation allows us to write this:

```raku
say "Nice to meet you, $name.";
```

Instead of something like this:

```raku
say "Nice to meet you, ", $name, ".";
```

In most languages, you have to do the latter trick: do a bit of a string, then a variable, and then a string again. In Raku, you just effortlessly switch between the two without thinking about it much.

So... it was nice to meet you, `$name`. Tomorrow we'll talk about `if` statements and their relation to saunas.
