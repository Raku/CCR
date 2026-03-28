# November 6 2009 — wait, that's not gold...
    
*Originally published on [7 November 2009](http://strangelyconsistent.org/blog/november-6-2009-wait-thats-not-gold) by Carl Mäsak.*

> 65 years ago today, the first industrial batch of [plutonium](https://en.wikipedia.org/wiki/Plutonium#Production_during_the_Manhattan_Project) was produced.

Element 94 was first synthesized in 1940 by a team led by Glenn T. Seaborg and Edwin McMillan at the University of California, Berkeley laboratory by bombarding uranium-238 with deuterons. McMillan named the new element after Pluto, and Seaborg suggested the symbol Pu as a joke. [...] The entire plutonium weapon design effort at Los Alamos was soon changed to the more complicated implosion device, code-named "Fat Man." With an implosion weapon, a solid sphere of plutonium is compressed to a high density with explosive lenses—a technically more daunting task than the simple gun-type design, but necessary in order to use plutonium for weapons purposes.

"Fat Man", as you may know, was subsequently dropped on Nagasaki, Japan. Perhaps it contains some revealing truth about mankind, that when we finally make reality out of the alchemical dream to change material from one element to another, we use it not to create beauty or riches, but to wipe cities off the face of the Earth.

Okay, switching to the `installed-modules` branch. (If you're coming in through non-linear time, you might want to read what I did [yesterday](November-5-2009-hanging-in-there.html) first.)

```
$ ./proto
*** CONFIG FILE TOO OLD ***
Hello, faithful proto user. Since the August 2009 release, Rakudo installs
and runs outside its source directories. It's time for proto to make projects
install Raku projects in a similar way. Rather than spend a lot of effort
trying to guess how to upgrade our userbase from distributed to merged, we'll
just deprecate the old ways and let you do a bit of the work. Hope it's OK!
So here's the thing: we're moving to a model where RAKULIB becomes optional
or needs to point to only one library base directory. You should probably
reinstall the projects you have already, so that they end up in that place.
Here are your currently installed projects ('legacy' in projects.state):
november html-template druid rakuxamples uri web svg svg-plot maya form pun io-prompt wtop xml statistics-lite json faz http-daemon yarn ppm epoxy epoxy-resin grampa csv rakuiterate rakuqlite mwbot
When you're ready to go with the new ways, please remove your old
config.proto and reinstall the above projects.
```

Ok. Bravely going where no man has gone before. Save for *mberends*++, and probably *viklund*++, and *moritz*++...

I remove `config.proto`.

```
$ ./proto
*** CONFIG FILE CREATED ***
Greetings! I have created a file '/Users/masak/gwork/proto/config.proto'
that you may want to review. Next time you run ./proto
these settings will be used to bootstrap your Raku software ecosystem.
If you're new to this, or reluctant to do configuration, you probably want
the default settings anyway. The most important ones are:
Raku executable -> /Users/masak/gwork/rakudo/parrot_install/bin/raku
Raku library    -> /Users/masak/.raku/lib
```

Looks good. Proceeding.

```
$ ./proto 
Building proto...done
don't know how to parse the line «    state: legacy: /Users/masak/gwork/november», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/html-template», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/druid», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/rakuxamples», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/uri», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/web», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/svg», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/svg-plot», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/maya», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/form», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/pun», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/io-prompt», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/wtop», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/xml», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/statistics-lite», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/json», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/faz», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/http-daemon», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/yarn», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/ppm», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/epoxy», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/epoxy-resin», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/grampa», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/csv», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/rakuiterate», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/rakuqlite», ignoring it
don't know how to parse the line «    state: legacy: /Users/masak/gwork/mwbot», ignoring it
```

Now, that's not very pretty. The error is coming from lib/Ecosystem.pm:126. It's caused by the fake YAML parser not recognizing more than one word after the first colon.

Ah, this is the TODO point recording this piece of data format.

```
10. Drop the migration plan for existing installations: *laziness*++ ;)
    Just warn the user as long as the old config.proto has not been
    upgraded, and record as "state: legacy: /path" in projects.state.
    This must be overwritten if the user later re-installs the project.
    [DONE]
```

Need to talk to *mberends*++ about how to solve this. My guess is that we need to make the fake YAML parser a bit smarter, but even that might come at a cost.
