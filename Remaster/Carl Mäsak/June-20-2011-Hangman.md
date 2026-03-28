# June 20 2011: Hangman
    
*Originally published on [21 June 2011](http://strangelyconsistent.org/blog/june-20-2011-hangman) by Carl Mäsak.*

*I'm a day behind. Computer trouble. Will try to catch up in the next few days.*

In the game "Hangman", one person guesses letters in a hidden word, while another person keeps track of the guessed letters, and penalizes wrong guesses with increments of a drawing of a stick figure in an unfortunate situation:

```
 +
 |
 |
 |
 |
 |
 |
-+-
 +----+
 |    |
 |
 |
 |
 |
 |
-+-
 +----+
 |    |
 |    o
 |
 |
 |
 |
-+-
 +----+
 |    |
 |    o
 |    |
 |    |
 |
 |
-+-
 +----+
 |    |
 |    o
 |   /|
 |    |
 |
 |
-+-
 +----+
 |    |
 |    o
 |   /|\
 |    |
 |
 |
-+-
 +----+
 |    |
 |    o
 |   /|\
 |    |
 |   /
 |
-+-
 +----+
 |    |
 |    o
 |   /|\
 |    |
 |   / \
 |
-+-
```

Let's put all those drawings in a file and call the file `states`; they're the states that the game can be in.

Then we need a list of juicy, sufficiently long words:

```
excessive
investigation
realisation
idiomatic
misinterpret
endocrinology
colloquial
```

Let's put *that* in a file and call it `words`.

Finally, we have the game itself. Look how short it is! (Of course, partly because we put all the data in files...)

```raku
my @states = slurp("states").split("\n\n");
my $WORD = lines("words".IO).roll;
my %letters_found;
while @states {
    loop {
        my @guessed_word;
        for $WORD.comb {
            if %letters_found{$_} {
                push @guessed_word, $_.uc;
            }
            else {
                push @guessed_word, "_";
            }
        }
        say "Word: ", join " ", @guessed_word;
        if none(@guessed_word) eq "_" {
            say "Congratulations! You guessed it right!";
            exit;
        }
        say "";
        my $letter = prompt "Guess a letter: ";
        my $correct_guess = any($WORD.comb).lc eq $letter.lc;
        if $correct_guess {
            %letters_found{$letter} = True;
        }
        else {
            say shift @states;
            last;
        }
    }
}
say "Aww, you ran out of guesses.";
say "The correct word was '$WORD'";
```

Make sure to copy the game to your own computer and run it. It's a nice little game, if I may say so myself.

Some diverse comments:

- The way we build `@guessed_word` is simple, but a bit long. There are shorter, nicer ways to do it which we haven't touched on yet.
- The junctions `none` and `any` really help to bring the code size down by avoiding loops. And they blend into the code quite well, too. It's easy to realize what their purpose is.
- There are a few cases of the methods `.uc` (uppercase) and `.lc` (lowercase). This is another case of wanting to keep one internal representation of things, and one external. We want to print all the letters as uppercase when we print them, but we also want to compare letters internally without regard to case. When making a caseless comparison, it's prudent to lowercase both sides, rather than to uppercase them.
- Look how we're actually "eating" states as we go along, `shift`ing and `say`ing the next one in one go. Then we can simply loop until `@states` is empty, which is what `while @states` does.

Next game we're aiming for is called "Animals". It'll be wild.
