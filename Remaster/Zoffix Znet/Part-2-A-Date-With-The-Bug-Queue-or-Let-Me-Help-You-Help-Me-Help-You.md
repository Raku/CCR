# [Part 2] A Date With The Bug Queue or Let Me Help You Help Me Help You
    
*Originally published on [15 July 2016](https://perl6.party//post/A-Date-With-The-Bug-Queue-or-Let-Me-Help-You-Help-Me-Help-You--Part-2) by Zoffix Znet.*

*Be sure to read [Part I](https://github.com/Raku/CCR/blob/main/Remaster/Zoffix%20Znet/A-Date-With-The-Bug-Queue-or-Let-Me-Help-You-Help-Me-Help-You.md#a-date-with-the-bug-queue-or-let-me-help-you-help-me-help-you) of this series.*

As I was tagging tickets in my [bug ticket helper app](https://github.com/zoffixznet/rakuicket-Trakr), I was surprised by how often I was tagging tickets with this particular tag:

![Needs core member decision](core-button.png)

It may have been the most used tag of them all. And so, it made be think about...

## PART II: The Experienced Contributor

I will be referring to "core developers," but this generally applies to any person who has great familarity with the project, how it should, does, and will work —The Experienced Contributor. When it comes to bug queues, can this type of people do more than just pick the bug they like the most and fix it?

### LESSON 3: Many Tickets Can Be Fixed With A Single Comment

On my date with the bug queue, I found many tickets that looked relatively easy to fix, from a technological point of view, but I couldn't even begin working on them for a simple reason: I didn't know what the correct behaviour should be.

Here's a good example:

```` raku
> "345".Int
345
> "3z5".Int
Cannot convert string to number: trailing characters after number in '3^z5'
> "34\x[308]5".Int
3
````

When non-numeric characters are found, the conversion from `Str` to `Int```` fails with an error message, but if a diacritic is present on a digit, the conversion stops and returns only a partial number. The issue sounds simple enough, so let's get cracking? But wait!

What is the correct behaviour here? Should it fail with the same error message as `"3z5"` fails with, since a diacritic isn't a digit, or should it be silently ignored? After all, the entire string *does* match `\d+`:

```` raku
say "34\x[308]5" ~~ /^ \d+ $/
# OUTPUT:
# ｢34̈5｣
````

In this case, we have a contributor ready to resolve the ticket, but they are stimied by the lack of direction. When a core member sees a ticket like that, and they don't have the time to fix the bug, **they should comment** on the ticket, indicating what the expected behaviour is. Now, a different contributor who *does* have the time can proceed to fix the bug with great confidence their patch will be accepted.

And just like that, with a single comment from a core developer the ticket became much easier to fix! And speaking of easy things to fix...

### LESSON 4: Tag Your Tickets and Make Them Easy to Find!

When it comes to your bug ticket queue, this is probably something you don't want to see:
  
> **<BrokenRobot>** [Coke]: I've no idea how to locate them and now RT pissed me off enough that I gone off the idea of doing those tickets ~\_~

> **<BrokenRobot>** 18 minutes to find tickets. Retarded

And when a contributor is trying to find some bugs to fix, this is something they don't want to see:

![RT search](rt-search.png)

This isn't the interface for the latest NASA space probe. It's the search page for the RT ticket system. And that's not even the full story, because if the contributor wants to find tagged tickets, they have to use "Advanced" version that is nothing more than a textbox asking for what may or may not be a SQL query.

Sure, if you've used it a few times, it becomes simple enough to use, but a new contributor who's beggining to learn the guts of your project probably doesn't want to spend their entire afternoon learning how to search for tickets. They probably wouldn't be too sure about what to search for anyway.

So what's the solution? Tags! Categorize your tickets with tags and then you can have a Wiki or page on your project's website linking to search queries for specific tags. Here are some ideas to consider when deciding on ticket tags:

#### For Core Member Review / Bikeshed

Consider this comment on a ticket:
  
> This should probably return a List instead of a Hash.

The problem with it is that it's unclear whether or not there needs to be a discussion or if the ticket should be resolved following the suggestion.  So you have one group of people who wait for more comments before doing anything and another group who agree with the suggestion and move on without further comments. In the end, you have a stalled ticket and nothing gets fixed.

For that reason, you should use more direct language in your comments. State explicitly whether you're just sharing your opinion/vote on the issue, inviting discussion, or giving direction for how the ticket should be resolved.

For core member reviews, discussions, and general [bikeshed](http://bikeshed.com/), tags can be very useful. For example, [the Mojolicious project](http://mojolicious.org/) uses `needs feedback` Issue labels to invite discussion from its users. The Raku ticket queue has `[@LARRY]` tag for tickets that need review by the core team members—and core members should review such tickets regularly, because as we've learned in the previous Lesson, some bugs are just a comment away from being fixed!

#### Area of Expertise

Different issues may require different expertise. For example, an issue with the [Raku documentation website](https://docs.raku.org) may require someone experienced with:

- **Design:** the look of the website
- **UX:** usability of the website
- **CSS/HTML/JS:** the front-end of the website
- **Raku:** scripts for site generation
- **Advanced Raku:** documenting arcane features
- **Pod6:** documentation format writing and parsing
- **English:** ensuring correct grammar and good writing style
- **Other languages:** translation

All that just for a static website. Imagine one that's driven by a web app with a SQL backend!

Not everyone will be an expert in all the areas, so tagging by area of expertise will let a person pick tickets that are easy for them to resolve, depending on what sort of knowledge and training they possess.

#### Easy / Low Hanging Fruit

These are pretty common in projects: tags that indicate the ticket is very easy to solve. This is typically what new contributors will look for.

However, developers often mistake this tag to mean *so easy a blind monkey could do it*, and the result potential new contributors see when they view the tag is often:

![zero tickets found](zero-tickets.png)

Easy tickets should not mean brain-dead tickets. Text editing is a task I often see listed as Low Hanging Fruit tickets, but it's booooring. New contributors don't want to get bored. They want to fix things. And there's nothing wrong with requiring to do a bit of learning while they're at it.

The tickets tagged as easy can simply have a comment narrowing down the potential hiding spot of the bug with, perhaps, some guidance on how to debug and fix it. And speaking of guidance...

## LESSON 5: Mentoring Converts New Contributors into Experienced Contributors

So you have 20 devs on the team and 1,000 tickets in the bug queue. With 50 tickets per a pair of hands, you sure are busy! The devs never see the light of day and rarely appear on chat channels or comment on mailing lists, bug tickets, and other commentables. That's what busy people do.

However, what would happen if you also spend a bit of time writing tutorials and [project internals courses](https://github.com/edumentab/rakudo-and-nqp-internals-course), or training specific people?
<blockquote>
  
> **<psch>** i can also guide you how i figured out what to change where to throw a typed Exception there, because as i said, i think it's a great ticket for getting used to the Grammar and Actions

> **<BrokenRobot>** psch: sure, I'd love to learn that

> **<psch>** BrokenRobot: the most important thing is --target=parse

> **<psch>** BrokenRobot: as in, the start for any bug that most likely is Grammar or

> **<psch>** Actions based is by isolating it as far as possible - in this case a bare

> **<psch>** '&0' - and running that through ./raku --target=parse -e

> **<psch>** [https://gist.github.com/peschwa/1e6a9f84a4c9e67638ff93e5b79f86d9](https://gist.github.com/peschwa/1e6a9f84a4c9e67638ff93e5b79f86d9) # like this

> **<psch>** EXPR is a scary place, i don't go there

> **<psch>** so it's about variable

> **<psch>** [https://github.com/rakudo/rakudo/blob/nom/src/Perl6/Grammar.nqp#L2017](https://github.com/rakudo/rakudo/blob/nom/src/Perl6/Grammar.nqp#L2017) so this

> **<BrokenRobot>** So <sigil> needs to exclude '&'  on here?

> **<psch>** [https://github.com/rakudo/rakudo/bl​ob/nom/src/Perl6/Grammar.nqp#L2025](https://github.com/rakudo/rakudo/blob/nom/src/Perl6/Grammar.nqp#L2025)

It's the old adage: teach a person to fish... and you'll turn a profit.  Don't think of it as a *team of 20 devs*. Think of it as a team of 20 devs *and several trainees*. By dedicating some time on training new contributors you'll be growing your team and reducing the number of bugs per pair of hands.  The time you won't spend on fixing bugs right now is an investment into people who will fix more bugs for you later on.

## Conclusion

And so ends our date with the bug queue. Whether you're a [newbie contributor](/post/A-Date-With-The-Bug-Queue-or-Let-Me-Help-You-Help-Me-Help-You) or a seasoned core hacker, the bug queue is a valuable place to spend your time at.

New contributors help core developers by filtering out the queue, doing preliminary debugging, and writing tests. Core developers help new contribitors by tagging tickets, giving direction for how tickets should be resolved, and providing training. This in turn, lets new contributors help back by fixing bugs and... eventually becoming core contributors themselves.
