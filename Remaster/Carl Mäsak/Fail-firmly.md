# Fail firmly
    
*Originally published on [11 June 2011](http://strangelyconsistent.org/blog/fail-firmly) by Carl Mäsak.*

The practice ["fail fast"](https://en.wikipedia.org/wiki/Fail-fast) comes from engineering. It's one of those wonderful ideas that sounds like bad advice, but is actually good advice.

Same as with ["release early; release often"](https://web.archive.org/web/20110605072324/http://catb.org/~esr/writings/cathedral-bazaar/cathedral-bazaar/ar01s04.html) &mdash; what, I shouldn't hold off releasing until I'm finished? No, because "finished" isn't well-defined, whereas a test suite full of passing tests is.

Same as with ["you ain't gonna need it"](https://wiki.c2.com/?YouArentGonnaNeedIt) &mdash; but I might need it! Well, we can talk about future needs when they actually manifest. That way, we're not boxing ourselves in and bloating our codebase today, and we can make future design choices closer to when they're needed.

Maybe those slightly counterintuitive adages stick around *because* our initial impulse is to resist them, and we have to "get them" and see what they actually say before we embrace them.

And so it is with "fail fast". The natural objection would be "but I don't want to fail", I guess. Well, dear, no-one does. But nothing is perfect. And when a failure creeps into the system &mdash; faulty data or unreachable states or unexpected occurrances &mdash; the idea is that it's better to hit the brakes early on, than to entangle ourselves further and then either fail even bigger, or &mdash; worse &mdash; just "succeed" and produce garbage results that may not even *look* wrong.

Funnily enough, on some levels Perl itself is very fault-tolerant and just keeps trying the next thing even when the previous thing was a total failure. `open`, for example, just returns a false value in Perl when something went wrong. That's why we as programmers have to learn to complement an `open` with `or die`. Or maybe we learn to reach for [`use autodie;`](https://metacpan.org/pod/autodie). (I still haven't, though I probably should in most cases.)

And even with other things, the tendency is to be robust to errors rather than being a canary in the coalmine. `no warnings` as the default, autovivification, implicit type conversions &mdash; they all represent a certain fault-tolerance in cases where we could have abended instead. (I'm not necessarily saying that all of those are bad, just that they encourage a culture of not testing for errors.)

Raku introduces many new mechanisms for failing fast, mostly through the type system. I program in Perl and Raku, and I *know* that I am more lazy with parameter checking in Perl. Both checking for the presence of the parameters and checking their types. Simply because it's more of a hassle. When I'm less lazy, I reach for [MooseX::Params::Validate](https://metacpan.org/pod/MooseX::Params::Validate), which is a great module... but even that is more of a hassle than Raku's signature handling.

But even Raku keeps up the odd Perl tradition of letting errors slip through, instead reporting them much later in the program execution. The primitive for doing this is called `fail`, and it means "return an unthrown exception, that is, a booby-trap value which will throw an actual exception once it's used". The usage site of the value might of course be miles away from the production site, making it an "interesting" exercise to track down the latter. For those of us who are slightly skeptical to the whole idea of delaying error messages, there's a pragma called `use fatal`, which makes `fail` act like `die`. Phew.

But that's not really what I wanted to write about. My topic is this: I think I've found an extension to fail fast, which I would like to popularize. I call it "fail firmly", but I'm open to better names. Here are three examples:

- The other day, weary of forgetting to match up my closing tags when using `XML::Writer`, I used a trick that I've at times used before. I created a `sub element`, that created the start tag, called a closure (one of the parameter), and then created the matching end tag. Now the problem had been reduced to matching up the curly braces in my program &mdash; something that I have ample training doing. Better yet, when I forget to do it, that's a compile-time error.
- Taking that a step further, Mauricio Fernández talks about generating HTML that must be correct because [the type system doesn't allow placing elements where they don't belong](https://web.archive.org/web/20110815130907/http://eigenclass.org/R2/writings/markdown-redux-html-generation). Cool!
- Both [my post about `Buf`](Str-and-buf-i-think-i-get-it-now.html) and [a Joel Spolsky post about *real* Hungarian Notation](https://www.joelonsoftware.com/articles/Wrong.html) talk about shaping the world so that mistakes stand out. Sometimes you can go all the way and push the knowledge into the type hierarchy; other times, you're left with having to make the distinction through good naming, as Spolsky describes.
- The whole idea about [CQRS](https://web.archive.org/web/20110616031209/http://cqrsinfo.com/documents/cqrs-introduction/) is to separate things that are different: first queries from commands, then the commands into even finer types. Eventually you end up with a system with very clear client-server boundaries, where the only way to communicate to send the right query or the right command &mdash; and it's all enforced and carried out by judicious use of the type system.

The unifying idea is this: code is meticulously checked in various ways. Data &mdash; not so much. Or rather data is never *a priori* wrong, and we have to write the checks ourselves. "Fail firmly" tells us to take those aspects of the data that *have* to be valid, and fold them into code somehow, in such a way that when the data is wrong, the *code* is wrong, too.

Or more briefly, root your important data firmly in code. Then the compiler will see it, and do its thing. Hook your important data into the parser or even the type system. And you'll fail even earlier, and sometimes with gorgeous error messages.

Just another step on the road of making our software more aware and intentional.
