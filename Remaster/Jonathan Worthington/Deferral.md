# Deferral
    
*Originally published on [20 August 2009](https://use-perl.github.io/user/JonathanWorthington/journal/39499/) by Jonathan Worthington.*

> The ones who seek justice,
> Will pray for it all their lives.
> They can and they will skin us all one day,
> Oh can you hear them cries.
> As far as the man can run from us,
> We're following the trail of blood,
> So hunt my young ones,
> The pack they have always feared is back.
> *Ain't Your Fairytale - Sonata Arctica*

In this Ian Hague Grant update post, I'm going to discuss deferral. Deferral allows a method to pass control to the next best candidate that method dispatch would have called had the current method not existed. Control can either be passed on entirely - that is, we stop executing the current method and skip to the next one - or you can capture the results of the next method in the chain and do some post-processing on them. Additionally, you can massage the arguments before deferring, or alternatively just pass on the arguments as they were originally provided.

So what do I mean by next best candidate? Let's look at a simple example. Suppose I have a class that knows how to format and output some legal report.

```` raku
class ReportRenderer {
    method render(Report $r) {
        ...
    }
}
````

This works fine for internal things, however when such reports are published on the web we need to redact certain things. Thus we can write a subclass with a report method that does this redaction by modifying the data structure, and then defers to the parent's render method to actually do the display work.

```` raku
class PublicReportRenderer is ReportRenderer {
    method render(Report $r) {
        # Code to redact the report...
        nextwith($r);
    }
}
````

At this point you may be thinking, "hey, is this not just like a call to the superclass?" And in a way, yes, it is. However, a couple of things make deferral interesting. First of all, "who is my parent" gets more interesting in a multiple inheritance world; deferral instead walks the full method resolution order as seen from the object you initially dispatched on. Second, there's more than one way to defer - in fact, there are four:

- `nextwith($arg1, $arg2, ...)` ends execution of the current method and passes control to the next method, using the supplied arguments.
- `nextsame` ends execution of the current method and passes control to the next method, using the arguments the current method was originally invoked with.
- `callwith($arg1, $arg2, ...)` calls the next method, using the supplied arguments. It returns with the return value(s) of the method that was deferred to.
- `callsame` calls the next method, using the arguments the current method was originally invoked with. It returns with the return value(s) of the method that was deferred to.

Deferral isn't just up the inheritance hierarchy, however. It's also possible to defer to multiple dispatch variants that are less specific. For example, suppose that we have a web crawler, and one class in the system is responsible for persisting the interesting pages that we found while crawling. We get a report that long pages take too much processing later, and we are asked to store a summary. Imagining our class looks along the lines of...

```` raku
class CrawlerPersistence {
    method save(Str $page) {
        # various code to break up the page and store it
    }
}
````

We could do a few things. One is that we could put the check and the logic inside of the save method to make the summary, but this may make the method longer than is really desirable. We could write a worker sub, do a length check in the save method and call that, which is better. However, in Raku we have a third option: make the methods multis, and write an additional multi that handles the summarization process and defers.

```` raku
class CrawlerPersistence {
    multi method save(Str $page) {
        # various code to break up the page and store it
    }

    multi method save(Str $page where { $page.chars > 10000 }) {
        # summarize
        nextwith($summary);
    }
}
````

Note that a multi with a constraint is considered to be narrower than one with the same type and no constraint, so we always will call the second of these if the constraint matches.

In general, deferral gives you a nice way of saying "call or pass on control to the next best thing". You can use it when you need to customize behavior, or in cases where you get data that you don't know what to do with but know a more general method accepting more general types or further up the inheritance hierarchy may be able to handle better.

Under the hood, every method dispatch saves enough information to be able to resume the dispatch and find the next candidate. It does not compute all of the possibilities in advance, since a lot of the time when we do a method invocation we won't defer. Thus we compute the candidates lazily.

So, that's deferral. Check in soon for my final Hague Grant update post for this grant, in which I'll talk about traits.
