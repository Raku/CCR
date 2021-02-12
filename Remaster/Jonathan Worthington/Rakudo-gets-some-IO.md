# Rakudo gets some IO
    
*Originally published on [31 March 2008](https://use-perl.github.io/user/JonathanWorthington/journal/36013/) by Jonathan Worthington.*

Reading through the transcript of the Raku call last week, I noticed that I/O was mentioned as something that Rakudo was lacking and that people were really missing. I flew to the UK on Friday, was at a wedding on the Saturday weekend and meeting up with a friend in London on the Sunday and flew back today. However, I managed to grab a few spare hours on the train on the way there, and on the Sunday evening while Normal People slept and the morning before my flight on the Monday to get some Rakudo hacking done. As a result, we now have the beginings of IO in Rakudo.

Here's a quickly hacked up random number game.

```` raku
my $answer = int(rand(100)) + 1;
my $guesses = 0;

say "Guess the number (between 1 and 100)";

for =$*IN -> $guess {
    $*guesses*++;
    if $guess == $answer {
        say "You got it right in $guesses guesses!";
        exit
    }
    elsif $guess < $answer {
        say "Too low";
    }
    else {
        say "Too high";
    }
}
````

Here's an example run of the game.

```` raku
C:\Hacking\parrot\languages\raku>..\..\parrot raku.pbc guess.p6
 Guess the number (between 1 and 100)
 > 50
 Too low
 > 75
 Too low
 > 87
 Too low
 > 95
 Too high
 > 91
 Too low
 > 93
 Too high
 > 92
 You got it right in 7 guesses!
````

You'll note that here I'm using `$*IN`. This is an instance of the `IO` class, so you can do:

```` raku
say $*IN.WHAT;
````

And it will report `IO`. Writing `=$*IN` means "get me the iterator to read from `$*IN` which reads a line at a time. `$*OUT` and `$*ERR` are also available, so we can output to STDERR now by doing:

```` raku
$*ERR.say("OH NOES! IT DID EXPLOSHUN!");
````

So we have those three file handles, but what about getting one to a file itself? That's what open is for. Here's a program that takes a file name and then prints each line in that file with the line number at the start of it.

```` raku
my $fh = open(@*ARGS[0], :r); # :r = read mode
my $line = 1;
for =$fh {
    say $*line*++ ~ " $_";
}
$fh.`close`;
````

I ran it on the readme; I'll just quote the top bit of the output.

```` raku
C:\Hacking\parrot\languages\raku>..\..\parrot raku.pbc ln.p6 README
1 ## $Id: README 25155 2008-01-22 19:25:25Z pmichaud $
2
3 =head1 Rakudo Raku
4
5 This is the Raku compiler for Parrot, called "Rakudo Raku,"
````

You'll notice the use of the new pair syntax for specifying the mode to open the file in, which I talked about in my last post. So already we're building stuff on top of that syntax. :-)

I'm not sure how busy the coming week will be, but I do know that next weekend and Monday are set aside for doing Raku related things: I will be joining the Oslo QA Hackathon. So I look forward to seeing any of you that will be attending there, and hopefully bringing us another few steps closer to Raku on Parrot.
