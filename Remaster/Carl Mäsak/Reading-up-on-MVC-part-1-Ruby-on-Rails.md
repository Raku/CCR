# Reading up on MVC, part 1: Ruby on Rails
    
*Originally published on [26 June 2009](http://strangelyconsistent.org/blog/reading-up-on-mvc-part-1-ruby-on-rails) by Carl Mäsak.*

Hello, don't mind me. I'm just going through a few MVC frameworks to see how they differ and how they're alike. I need the knowhow to create an MVC for Web.pm. Right now, my plan is to examine Rails, Catalyst, Django and Jifty. I'll write down my impressions of each of the in some kind of list, for future reference. Basically the only way you'd want to read this is if you want to laugh at how little I know about MVC frameworks.

Here's the list I got from watching this screencast:

- Man, the Ruby folks sure can make a beatuiful screencast!
- Rails uses scaffolding. I've heard not all people like scaffolding, but it does look kinda convenient to my untrained eye.
- Partial templates are called, logically, "partials". They bind smartly with variable names somehow.
- Different output formats are really easy to add. XML, JSON, Atom...
- A blog is a really nice example for an MVC framework screencast, because it's just a list of posts, each with a list of comments.
- Rails can add authentication through before_filter.
- Hm, clearly the strength of Rails comes largely through the keywords it introduces. Wonder if it uses monkey typing for that?
- Rails has Routes! Maybe this is my chance to finally understand *ihrd*++'s Routes, which I never really grokked.
- Controllers do things like index, show, new, update and delete. Probably related to CRUD somehow.
- That 'debugger' trick is fantastic! One of those features which you feel can't be just hot air.
- AJAX is fairly well integrated, though I'll be danged if I understand exactly how. Looks like magic to me.
- Did I hear that right? "rjs is just a way to generate JavaScript using Ruby." Wow.
- There's graceful fallback from JS to non-JS.
- There's built-in automated testing.
- The console seems like the debugger again, but without the breakpoint. Yes, I can see how that might be very useful.
- Never once do they explicitly say 'the database' in the screencast. They say the word 'database-agnostic' once, and 'table' and 'column' a few times, but most of the time it's just 'model', 'view', 'controller'. Seems like the abstraction is largely intact.


Um. Well, in summary, that cool-aid sure seems to have an effect on me. I'll leave the comments open so that you people can tell me how Rails, despite all appearances, is really bad for your teeth and leaves skid marks on your puppy.

Next up: Catalyst.
