# Parallel Dispatch
    
*Originally published on [3 June 2009](https://use-perl.github.io/user/JonathanWorthington/journal/39072/) by Jonathan Worthington.*

> Aurora swims in the ether
> Emerald fire scars the night sky
> Amber streams from Sol
> Are not unlike the waves of the sea
> Nor the endless horizon of ice
> *Not Unlike The Waves - Agalloch*

After the successful completion of my previous Hague Grant, I applied for [another one](http://news.rakufoundation.org/2009/04/hague_perl_6_grant_request_tra.html). Happily, it was approved a little while ago, and I've been busily working away on it. In fact, I have already made significant progress towards most of the deliverables (though with plenty of work left to do) and one of them can be considered pretty much completed already. I plan to write several blog posts about the various things I achieve under the grant, and in this one I am going to talk about parallel dispatch, which is the topic of the completed deliverable.

I enjoy *masak*++'s blogging a lot for the extra little bits as well as the main content, and am taking a leaf from his book and augmenting each of my posts about my work under this grant with a quote. I listen to a lot of music while working, so I've chosen to quote some of the lyrics from what I'm listening to while working on this grant. And yes, I know, it sure doesn't beat the lolcat bible. So, on with the show...

I've talked about hyper operators before. They're the ones that let you perform an action element wise over arrays or lists. For example, we can add two arrays or lists element wise like this:

```` raku
say ((1,2,3) >>+<< (4,5,6)).raku; # Output: [5, 7, 9]
````

The same syntax can also be used to dispatch methods too, by placing the `>>` before the `.` operator. This means that you can dispatch a method on every item of a list or array and get an array of the return values.

```` raku
my @a = -1, 2, -3;
my @b = @a>>.abs;
say @b.raku; # [1, 2, 3]
````

Happily, the various other method call forms can be parallelized too. For example, we can modify an array in place:

```` raku
my @words = <foo bar baz>;
@words>>.=uc;
say @words.raku; # ["FOO", "BAR", "BAZ"]
````

Or use the `.?` form that only calls a method on things that have it and ignores those that don't to call methods on objects in an array that may or may not have the method.

```` raku
@pets>>.?lick($guest); # The dog will, the fish won't
````

You can also chain them together. Here's a quickie that prints out for you all of signatures of the candidates of a multi sub:

```` raku
multi double(Num $n) { return 2 * $n }
multi double(Str $s) { return "$s $s" }
&double.candidates>>.signature>>.raku>>.say;
````

The output of this is:

```` raku
:(Num $n)
:(Str $s)
````

Like with other hyper-operators, you're not just saying, "I want this method called on everything in the array", but also telling the compiler, "you can run them in different threads and in any order you want". Of course, even if it runs them out of order it will give you back the results in the correct order. For now Rakudo does not do anything like this, but one day when we have a threading implementation that works and a good way of deciding when to parallelize (or maybe pragmas to give hints) then this will be able to happen.

So, that's parallel dispatch. Have fun, and in the next grant post I'll talk about my work to overhaul Rakudo's method dispatcher, winning performance and shiny new features.
