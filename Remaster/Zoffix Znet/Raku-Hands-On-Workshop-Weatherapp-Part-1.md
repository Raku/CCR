# Raku Hands-On Workshop: Weatherapp (Part 1)
    
*Originally published on [20 May 2016](https://perl6.party//post/Perl-6-Hands-On-Workshop--Weatherapp--Part-1) by Zoffix Znet.*

*Welcome to the Raku Hands-On Workshop, or Raku HOW, where instead of learning about a specific feature or technique of Raku, we'll be learning to build entire programs or modules.*

*Knowing a bunch of method calls won't make you a good programmer. In fact, actually writing the code of your program is not where you spend most of your time. There're requirements, design, documentation, tests, usability testing, maintenance, bug fixes, distribution of your code, and more.*

*This Workshop will cover those areas. But by no means should you accept what you learn as authoritative commandments, but rather as reasoned tips.  It's up to you to think about them and decide whether to adopt them.*

## Project: "Weatherapp"

In this installment of *Raku HOW* we'll learn how to build an application that talks to a Web service using its API (Application Programming Interface).  The app will tell us weather at a location we provide.  Sounds simple enough! Let's jump in!

## Preparation

I'll be using Linux with bash shell. If you aren't, you can get a [good distro](http://www.bodhilinux.com/) and run it in [VirtualBox](https://www.virtualbox.org/wiki/Downloads), or just try to find what the equivalent commands are on your OS. It should be fairly easy.

I'll also be using [`git`](https://git-scm.com/) for version control. It's not required that you use this type of version control and you can skip all the `git` commands in the text. However, using version control lets you play around with your code and not worry about breaking everything, especially when you [store your repository somewhere online](https://github.com/). I highly recommend you familiarize yourself with it.

To start, we'll create an empty directory `Weatherapp` and initialize a new git repository inside:

````
mkdir Weatherapp
cd Weatherapp
git init
````

## Design Docs: "Why?"

Before we write down a single line of code we need to know a clear answer for what problem we're trying to solve. The statement "tell weather" is ridiculously vague. Do we need real-time, satellite-tracked wind speeds and pressures or is it enough to have temperature alone for one day for just the locations within United States? The answer will drastically change the amount of code written and the web service we'll choose to use—and some of those are rather expensive.

Let's write the first bits of our design docs: the purpose of the code.  This helps define the scope of the project and lets us evaluate what tools we'll need for it and whether it is at all possible to implement.

I'll be using [Markdown](https://daringfireball.net/projects/markdown/syntax) for all the docs. Let's create `DESIGN.md` file in our app's directory and write out our goal:

````
# Purpose
Provide basic information on the current weather for a specified location.
The information must be available for as many countries as possible and
needs to include temperature, possibility of precipitation, wind
speed, humidex, and windchill. The information is to be provided
for the current day only (no hourly or multi-day forecasts).
````

And commit it:

```` raku
git add DESIGN.md
git commit -m 'Start basic design document'
git push
````

With that single paragraph, we significantly clarified what we expect our app to be able to do. Be sure to pass it by your client and resolve all ambiguities. At times, it'll feel like you're just annoying them with questions answers to which should be "obvious," but a steep price tag for your work is more annoying. Besides, your questions can often bring to light things the client haven't even though of.

Anyway, time to go shopping!

## Research and Prior Art

Before we write anything, let's see if someone already wrote it for us.  Searching [the ecosystem](https://modules.raku.org/) for `weather` gives zero results, at the time of this writing, so it looks like if we want this in pure Raku, we have to write it from scratch. Lack of Raku implementation doesn't *always* mean you have to write anything, however.

### Use multiple languages

What zealots who endlessly diss everything that isn't their favourite language don't tell you is their closet is full of reinvented wheels, created for no good reason. In Raku, you can use C libraries with [NativeCall](https://docs.raku.org/language/nativecall), most of Perl modules with [Inline::Perl5](https://modules.raku.org/repo/Inline::Perl5), and there's [a handful of other Inlines](https://modules.raku.org/#q=Inline) in the ecosystem, including Python and Ruby. When instead of spending several weeks designing, writing, and testing code you can just use someone's library that did all that already, you are the winner!

That's not to say such an approach is always the best one. First, you're adding extra dependencies that can't be automatically installed by `zef`](https://modules.raku.org/dist/zef). The C library you used might not be available at all for the system you're deploying your code on.  `Inline::Perl5` requires perl compiled with `-fPIC`, which may not be the case on user's box. And your client may refuse to involve Python without ever giving you a reason why. How to approach this issue is a decision you'll have to make yourself, as a programmer.

### ~~Steal~~ Borrow Ideas

Even if you choose not to include other languages (and we won't, for the purposes of this tutorial), it's always a good idea to take a look at prior art.  Not only can we see how other people solved similar problems and use their ideas, but for our program we can also see which weather Web service people tend to use.

The two pieces we'll examine are Perl's [Weather::Underground](https://metacpan.org/pod/Weather::Underground) and [Weather::OpenWeatherMap](https://metacpan.org/pod/Weather::OpenWeatherMap).  They use different services, return their results in different formats (Perl's native data structures vs. objects), and the data contains varying amounts of detail.

I like ::OpenWeatherMap's approach of returning results as objects, since the data can be abstracted and we can add useful methods if we ever need to, however, traversing its documentation is more difficult than that of ::Underground—even more so for someone not overly familiar with Object Orientation. So in our program, I think we can return objects, but we'll have fewer of them. We'll think more about that during design stage.

Also, the implementations suggest none of the two Web services offer humidex or windchill values. We'll ask our client how badly they need those values and try to find another service, if they are absolutely required. A more common case will be where the more expensive plan of the service offers a feature while the free or less expensive doesn't. The client will have to decide how much they wish to splurge in that case.

Weather::Underground's service seems to offer more types of data, so let's look at it first. Even if we don't need those right now, we might in the future. The [website](https://www.wunderground.com/) is pretty slow, has two giant ads, has poor usability, and the availability of the API isn't apparent right away (the link to it is in the footer). While those aren't direct indicators of the quality of the service, there tends to be at least some correlation.

When we get to the [API service level options](https://www.wunderground.com/weather/api/d/pricing.html), we see the free version has rather low limits: 10 requests per minute up to a maximum of 500 per day. If you actually try to sign up to the site, you'll encounter a bug where you have to fill out your app's details twice. And the docs?  [They](https://www.wunderground.com/weather/api/d/docs?d=data/conditions) aren't terrible, but it took me a bit to find the description of [request parameters](https://www.wunderground.com/weather/api/d/docs?d=data/index). Also, none of the response parameters are explained and we're left to wonder what `estimated` is and what its properties are when it's not empty, for example. The API actually *does* offer windchill and "heat index," but in a sample response their values are "N/A". Are they ever available? Overall, I'd try to avoid this service if I have a choice.

Up next, Weather::OpenWeatherMap's service—[www.openweathermap.org](http://www.openweathermap.org/). Nicer and faster website, unintrusive ads, the API link is right in the navigation and leads to a clear summary of the APIs offered. The [free version](http://www.openweathermap.org/price) limits are much better too: 60 requests per minute, without a daily limit.  Signing up for the API key is simpler as well—no annoying email confirmations. And [docs](http://www.openweathermap.org/current) are excellent. Even though humidex and wind chill aren't available, the docs explicitly state how many worldwide weather stations the site offers, while Wunderground's site mentions worldwidedness as an afterthought inside a broken `<dfn>` hovering over which pops up `Definition not found` message.

The winner is clear: OpenWeatherMap. [Sign up](https://home.openweathermap.org/users/sign_up) for an account and generate an [API key](https://home.openweathermap.org/api_keys) for us to use.  You can use [a throwaway email address](http://www.throwawaymail.com/) for registration, if you prefer.

Alternatively, try finding yet another web service that's better suited for our weather application!

### Homework

By choosing OpeanWeathMap service we had to abandon providing humidex and wind chill in our data that we originally wrote in our design doc.  We pretended our client OKed changing the requirements of the app, so we need to update our docs to reflect that.

You can also update it to reflect some other service you found. Perhaps, don't mention the specific data types, but rather the purpose of the weather information. Is it for a city dweller to know what to wear in the morning? Is it for a farmer to know when to sow the crops? Or is the data to be used in a research project?

### Conclusion

Today, we started our design docs by defining the scope of our application.  We then looked at prior art written in Raku (found none) and other languages.  We evaluated to services that provide weather data on their potential quality, reliability, query limits, and feature sets.

At this point we have: start of the design doc, chosen service provider, and API key for it. In the next post, we'll write detailed design and tests for our app.

See you then!

UPDATE: [Part 2](http://raku.party/post/Perl-6-Hands-On-Workshop--Weatherapp--Part-2) is now available!
