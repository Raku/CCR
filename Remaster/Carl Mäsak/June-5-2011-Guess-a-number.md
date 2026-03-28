# June 5 2011: Guess a number
    
*Originally published on [5 June 2011](http://strangelyconsistent.org/blog/june-5-2011-guess-a-number) by Carl Mäsak.*

Without much ado, here's our first game:

```raku
say "I'm thinking about a number between 1 and 100.";
my $answer = (1 .. 100).roll;
my $tries = 0;
loop {
    my $guess = prompt "Guess the number: ";
    $tries = $tries + 1;
    if $guess < $answer {
        say "Your guess was too low.";
    }
    elsif $guess > $answer {
        say "Your guess was too high.";
    }
    else {
        last;
    }
}
say "Yay!";
say "You got it right in $tries tries!";
```

All of what we've seen in the past few days works together in this bit of code. There's the `loop` that makes sure the program runs as many times as needed, and the `last` inside of it that makes sure we exit the loop when we hit upon the right answer. There's the `if`/`elsif`/`else` inside of the loop to make decisions about the guess that was just made. And a bunch of `say` and `prompt` and variables along the way to communicate with the user.

The `(1 .. 100).roll` thing is new. This is how we generate random numbers. In this case, we're interested in a random number between 1 and 100. You can think of it as rolling a 100-sided die, if that helps. In fact, that's why `.roll` is called the way it is.

(You might wonder why `say` is written before and `roll` is written after things, and what the dot is doing there. We'll talk more about the difference between subroutines and methods later, when it starts to matter. For know, just know that there is a bit of leeway sometimes, and that `"Hello World".say` also works, for example.)

The `$tries` variable is an interesting example of an *accumulator*, something that we see in loops a lot, and in many shapes and forms. An accumulator is anything that starts as some empty value and then keeps adding things onto it. In our case, we keep adding `1` until the loop finishes. In some other case, we might want to calculate a sum or a product of many things.

Your math teacher doesn't have to get gray hairs just because you write `$tries = $tries + 1;` in your programs: this is assignment, not the equals sign from maths equations. Besides, there is a shorter way to write it when the same variable appears on both sides of the equals sign: `$tries += 1;`. It means the same. For the case of adding one, there's an even shorter way to write it: `$*tries*++;`.

It's also worth noticing how we subtly affect the relationships between different parts of the program by adding empty lines here and there. For example, the first empty line in the program makes it understood that `my $answer = ...` is part of initialization of the entire program, whereas `my $tries = 0` belongs to the loop, because it looks "attached" to it.

How many tries does it take you to beat the game? Despite the fact that there's a hundred different possible answers in this game, you can always beat it in seven tries or less. Do you agree? How come at most seven tries are needed?

Our next lofty goal is to write a moon lander game, but before that we'll talk some more about strings and arithmetic and the `given` statement. See you on the moon in five days!
