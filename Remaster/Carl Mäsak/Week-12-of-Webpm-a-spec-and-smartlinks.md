# Week 12 of Web.pm — a spec and smartlinks
    
*Originally published on [2 August 2009](http://strangelyconsistent.org/blog/week-12-of-webpm-a-spec-and-smartlinks) by Carl Mäsak.*

> *Moses all growup now!. Wun dayz he go see his frenz. they is workin hard. Moses seez sum Gypshun d00d beatin up a Joo laik Mosis. Mosis look round & not see no 1 and he go and pwnd teh Gypshun. He sed b00m hed shot but qu1et laik. He hided teh bodi in sand to makes it invisabl bodi.* — Exodus 2:11-12

Very brief, because I'm on vacation:

For the past week, I've had the idea to hook up smartlinks in the tests of Web.pm, and then generate spec HTML files from spec Pod files. (Just like the Raku project does.)

I've succeeded in generating the HTML, thanks to a pre-packaged `Text::SmartLinks` module, that only required a few tweaks to do exactly what I want. Here's the spec for the Astaire sub-project, which got started at the same time I had this idea.

Now, ideally we'd also like test statistics in the HTML files, tracking the implementation progress. There are scripts in the Pugs directory for doing this, but they are... written by clever people. Meaning I don't see what I should change to have this code work for me.

To make the question very concrete (in case someone out there has the know-how and tuits to help me): how to I smoke my tests and generate a `smoke.yml` file which I can then feed into the `Text::SmartLinks` process?

I wish to thank The Perl Foundation for sponsoring the Web.pm effort.
