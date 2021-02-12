# Starting on Perl interop for Rakudo
    
*Originally published on [25 August 2009](https://use-perl.github.io/user/JonathanWorthington/journal/39530/) by Jonathan Worthington.*

I used the first chunk of my Rakudo day today to kick off a new project. At YAPC::EU, we had the Rakudo BOF where we collected together suggestions of features that mattered to people for Rakudo * - the major, usable Rakudo release we're planning for Q2 2010. One that came up was interoperability with Perl. 

This is something that I think had generally been assumed as something far off for Rakudo, or at least not really discussed in any great deal. The legacy is hardly great: the Ponie project, which tried to re-target Perl to the Parrot Virtual Machine, was put out to pasture after plenty of effort for a variety of reasons, including Parrot being too much of a moving target at that point.

As far as I can see, re-targeting Perl would be really quite a lot of work, and require a lot of guts knowledge. A lot of work in a specialized area presents a resourcing problem, and while I would happily cheer on a renewed effort to try and port Perl to run on Parrot, I'm not at all expectant that anyone is going to jump in to such a task soon. Even if that happens, the chances of having something ready for Rakudo * seem to me fairly slim.

So, enter [Blizkost](http://github.com/jnthn/blizkost/tree/master). 

The Blizkost project is aiming to embed the Perl interpreter and then build various bridges between it and Parrot. We'll start with the easy things - today I've done the easiest thing - and then build out from there. Rather than this being something built into Rakudo, instead Blizkost operates at the level of any other Parrot language implementation, meaning that it supports the HLLCompiler interface. This means that any other Parrot language that knows how to use this interface to eval code in another language, for example, will be able to make use of this.

The simplest thing I figured we could do is make it possible to eval a string of Perl code. You can't get the value it returns, nor will it find any outer lexicals, but this means that you can now do (copy paste from the REPL):

```` raku
> eval('print "Hello from Perl\n"', :lang<perl5>)
Hello from Perl
````

Rakudo itself needed no changes to deal with this (other than a minor fix to deal with a language inter-op regression that affected eval in any language). All I had to do was to configure, make and make install `Blizkost`, using the same installed Parrot as Rakudo is built against, and it Just Worked.

So, we have a starting point. It's a small one, but then I only spent several hours on this so far. :-) I really have little knowledge of Perl guts, so my dream situation is that now I've seeded this, people will come, look in horror at what I've done and find themselves helplessly patching it. It's [on GitHub](http://github.com/jnthn/blizkost/tree/master) so you can go fork it if you want to hack, and I'm also going to be giving out commit bits quite freely, so get in touch if you feel like joining in.

I spent remaining bit of my Rakudo day dealing with some bugs.

- Fixed code generation bug when you tried to bind an attribute. Added a spectest.
- Stopped a `sprintf` that is given too few arguments from exploding with a Null PMC Exception. Now it just returns a Failure. Another couple of spectests started passing.
- Finally figured out how to successfully catch attempts to get hold of attributes on a type object. You can't, and you got a Null PMC Access exception if you tried (people hit this one a decent bit). However, my previous attempt to give a nicer error failed. Today I realized why it had failed, made a cup of tea, then implemented something that did work - it now tells you what you did and also the name of the attribute you tried to get hold of in order to aid debugging. I found and corrected a bogus spectest along the way, enabled the one that checks this doesn't die with a Null PMC Access, and managed to close two tickets from this. However, I have a suspicion there's at least another one or two that I didn't spot that are in the queue and boiled down to this same problem. Anyway, that's another of our major sources of Null PMC Access errors plugged.

I also spotted two other RT tickets that represented issues that I knew had been solved recently and closed them. I noted that a third was fixed and could be closed if somebody wrote tests to cover it and make sure it doesn't come back. Happily, we have some awesome test writers who take care of such things. :-)

Thanks to Vienna.pm for funding this Rakudo day.
