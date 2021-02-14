# Phasers set to stun
    
*Originally published on [15 December 2012](https://perl6advent.wordpress.com/2012/12/15/day-15-phasers-set-to-stun/) by Jonathan Worthington.*

When writing programs, it’s important not only to separate the concerns that need separating, but also to try and keep related things close to each other. This gives the program a sense of cohesion, and helps to avoid the inevitable problems that arise when updating one part of a program demands an update in another far-away part. One especially tricky problem can be when the things we want to do are distributed over time. This can cause us to move related things apart in order to get them to happen at the times we want.

Phasers in Raku help you keep related concepts together in your code, while also indicating that certain aspects of them should happen at different points during the lifetime of the current program, invocation or loop construct. Let’s take a look at some of them.

### `ENTER` and `LEAVE`

One of the things I had most fun writing in Raku recently was the debugger. There are various things that need a little care. For example, the debugger needs to look out for exceptions and, when they are thrown, give the user a prompt to let them debug why the exception was thrown. However, there is also a feature where, at the prompt, you can evaluate an expression. The debugger shouldn’t re-enter itself if this expression throws, so we need to keep track of if we’re already showing the prompt. This meant setting and clearing a flag. Thing is, the prompt method is relatively lengthy; it has a given/when to identify the various different commands. I could, of course, have set the prompt flag at the start and cleared it at the end. But that would have spread out the concern of maintaining the flag. Here’s what I did instead:

```` raku
method issue_prompt($ctx, $cur_file) {
    ENTER $in_prompt = True;
    LEAVE $in_prompt = False;

    # Lots of stuff here
}
````

This ensures the flag is set when we enter the method, cleared when we leave the method – and lets me keep the two together.

### `INIT` and `END`

We’re writing a small utility and want to log what happens as we run it. Time wise, we want to:

- Open the log file at the start of the program, creating it if needed and overwriting an existing one otherwise
- Write log entries at various points during the program’s execution
- Close the log file at the end

Those three actions are fairly spread out in time, but we’d like to collect them together. This time, the INIT and END phasers come to the rescue.

```` raku
sub log($msg) {
    my $fh = INIT open("logfile", :w);
    $fh.say($msg);
    END $fh.close;
}
````

Here, we use `INIT` to perform an action at program start time. It turns out that `INIT` also keeps around the value produced by the expression following it, meaning it can be used as an r-value. This means we have the file handle available to us, and can write to it during the program. Then, at the `END` of the program, we close the file handle. All of these have block forms, should you wish to do something more involved:

```` raku
sub log($msg) {
    my $fh = INIT open("logfile", :w);
    $fh.say($msg);
    END {
        $fh.say("Ran in {now - INIT now} seconds");
        $fh.close;
    }
}
````

Note the second use of `INIT` in this example, to compute and remember the program start time so we can use it in the subtraction later on.

### `FIRST`, `NEXT` and `LAST`

These phasers work with loops. They fire the first time the loop body executes, at the end of every loop body execution, and after the last loop body execution. `FIRST` and `LAST` are especially powerful in so far as they let us move code that wants to special-case the first and last time the loop body runs inside of the loop construct itself. This makes the relationship between these bits of code and the loop especially clear, and lessens the chance somebody moves or copies the loop and forgets the related bits it has.

As an example, let’s imagine we are rendering a table of scores from a game. We want to write a header row, and also do a little ASCII art to denote the start and end of the table. Furthermore, we’d like to keep track of the best score each time around the loop, and then at the end print out the best score. Here’s how we could write it.

```` raku
for %scores.kv -> $player, $score {
    FIRST say "Score\tPlayer";
    FIRST say "-----\t------";
    LAST  say "-----\t------";

    NEXT (state $best_score) max= $score;
    LAST say "BEST SCORE: $best_score";

    say "$score\t$player";
}
````

Notice how we keep the header/footer code together, as well as being able to keep the best score tracking code together. It’s also all inside the loop, making its relationship to the loop clear. Note how the state variable also comes in useful here. It too is a construct that lets us keep a variable scoped inside a block even if its usage spans multiple invocations of the block.

### `KEEP` and `UNDO`

These are variants of `LEAVE` that trigger conditional on the block being successful (`KEEP`) or not (`UNDO`). A successful block completes without unhandled exceptions and returns a defined value. An unsuccessful block exits due to an exception or because it returns an undefined value. Say we were processing a bunch of files and want to build up arrays of successful files and failed files. We could write something like:

```` raku
sub process($file) {
    KEEP push @success, $file;
    UNDO push @failure, $file;

    my $fh = open($file);
    # ...
}
````

There are probably a bunch of transaction-like constructs that can also be very neatly implemented with these two.

### And there’s more!

While I’ve covered a bunch of the phasers here, there are some others. For example, there’s also `BEGIN`, which lets you do some computation at compile time. Hopefully, though, this set of examples gives you some inspiration in how phasers can be used effectively, as well as a better grasp of the motivation for them. Bringing related things together and setting unrelated things apart is something we need to think carefully about every day as developers, and phasers help us keep related concerns together, even if they should take place at different phases of our program’s execution.
