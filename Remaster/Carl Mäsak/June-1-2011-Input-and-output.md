# June 1 2011: Input and output
    
*Originally published on [1 June 2011](http://strangelyconsistent.org/blog/june-1-2011-input-and-output) by Carl Mäsak.*

Hi.

Let's start from the basics on how to program. (If you want to follow along at home, you'll need to [download Rakudo](http://rakudo.org/downloads/).)

We'll start by writing a short program that prints something:

```raku
say "Hello World!";
```

The `say` here is the command to print something.

What we print is the string `Hello World`, all on its own line. We've put double quotes around the string value, because that's how we mark string values as being different from other things, like commands. (There are other ways to create string values, too.)

There's a semicolon at the end of the line. For our very short program, it doesn't matter if we put it there or leave it out, but for larger programs it matters. Semicolons separate individual statements from each other — individual things we want the program to do. They're like the full stops in a written sentence.

Let's write another program.

```raku
say "Hello.";
prompt "What is your name? ";
say "Nice to meet you.";
```

The prompt command does two things: it prints a prompt — in this case `What is your name?` — and then it waits for the user to type something on the keyboard and press Return.

So, in essence, this program carries on a little dialogue with the computer user. It says hello, asks for the user's name, and says nice to meet you.

Of course, the program is slightly inconsiderate because it doesn't repeat the name it just had the user tell it. Seems we need to teach it some manners. That is the topic for tomorrow.
