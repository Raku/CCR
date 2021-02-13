# Considering hyper/race semantics
    
*Originally published on [2017-03-16](https://6guts.wordpress.com/2017/03/16/considering-hyperrace-semantics/) by Jonathan Worthington.*

We got a lot of nice stuff into 6.c, the version of the language released on Christmas of 2015. Since then, a lot of effort has gone on polishing the things we already had in place, and also on optimization. By this point, we’re starting to think about Raku.d, the next language release. Raku is defined by its test suite. Even before considering additional features, the 6.d test suite will tie down a whole bunch of things that we didn’t have covered in the 6.c one. In that sense, we’ve already got a lot done towards it.

In this post, I want to talk about one of the things I’d really like to get nailed done as part of 6.d, and that is the semantics of hyper and race. Along with that I will, of course, be focusing on getting the implementation in much better shape. These two methods enable parallel processing of list operations. **hyper** means we can perform operations in parallel, but we must retain and respect *ordering of results*. For example:

```` raku
say (1, 9, 6).hyper.map(* + 5); # (6 14 11)
````

Should always give the same results as if the hyper was not there, even it a thread computing 6 + 5 gave its result before that computing 1 + 5. (Obviously, this is not a particularly good real-world example, since the overhead of setting up parallel execution would dwarf doing 3 integer operations!) Note, however, that the order of *side-effects* is not guaranteed, so:

```` raku
(1..1000).hyper.map(&say);
````

Could output the numbers in any order. By contrast, **race** is so keen to give you results that it doesn’t even try to retain the order of results:

```` raku
say (1, 9, 6).race.map(* + 5); # (14 6 11) or (6 11 14) or ...
````

Back in 2015, when I was working on the various list handling changes we did in the run up to the Christmas release, my prototyping work included an initial implementation of the map operation in hyper and race mode, done primarily to figure out the API. This then escaped into Rakudo, and even ended up with a handful of tests written for it. In hindsight, that code perhaps should have been pulled out again, but it lives on in Rakudo today. Occasionally somebody shows a working example on IRC using the eval bot – usually followed by somebody just as swiftly showing a busted one!

At long last, getting these fixed up and implemented more fully has made it to the top of my todo list. Before digging into the implementation side of things, I wanted to take a step back and work out the semantics of all the various operations that might be part of or terminate a **hyper** or **race** pipeline. So, today I made a list of those operations, and then went through every single one of them and proposed the basic semantics.

The results of that effort are [in this spreadsheet](https://docs.google.com/spreadsheets/d/1kpSb8LoskHSbM1FQvWdQ269rlRkU8vh5A_ElpN3Qay4/edit?usp=sharing). Along with describing the semantics, I’ve used a color code to indicate where the result leaves you in the hyper or race paradigm afterwards (that is, a chained operation will also be performed in parallel).

I’m sure some of these will warrant further discussion and tweaks, so feel free to drop me feedback, either on the #raku-dev IRC channel or in the comments here.
