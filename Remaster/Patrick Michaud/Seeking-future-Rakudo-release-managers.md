# Seeking future Rakudo release managers
    
*Originally published on [8 July 2009](https://use-perl.github.io/user/pmichaud/journal/39249/) by Patrick Michaud.*

Over the next couple of weeks I'm working on fleshing out 
"job openings" and descriptions for people who want to help 
advance Rakudo Raku.  I'll write more about this in a later
post, and they're likely to appear in my OSCON
and YAPC::EU talks.

One of the jobs we've already identified is "Release Managers",
following closely on the Parrot model.  Release managers are people 
that are responsible for executing Rakudo releases according to the
release schedule.  And like Parrot, we want this responsibility
to be widely spread among a team of managers, and not always fall
to the same person for every release.  So, over the next month
or so I'll be recruiting people to be release managers, starting
with the August 2009 release.  (The July 2009 release is likely
to have a few significant changes -- most notably a "make install"
target -- so I think it's better for me to do that one last
release myself.  Also I may want to coordinate the release with
my talk.)

However, yesterday it occurred to me that thanks to github, it's
entirely possible *today* for people to independently go
through all of the steps of cutting and publishing a Rakudo
release.  So now I'm eager to have others try it and see what
happens.  At present the release steps are targeted to work
primarily from Unix environments -- I haven't tested or attempted 
to cut a release from other operating systems.  (I'll accept 
patches and suggestions for doing so, though! :-)

For those who want to try it, here are the basic steps for
creating a Rakudo "practice release":

- Fork the <a class='urllink' href='http://github.com/rakudo/rakudo'>Rakudo master repository</a> on github.
- Follow the steps in the <a class='urllink' href='http://github.com/rakudo/rakudo/tree/master/docs/release-guide.pod'>docs/release-guide.pod</a> file, substituting your own github repo clone for the Rakudo master.  
- Let us know "Hey, I just made a Rakudo release!" and point to
your forked copy github repo.  Or tell us where you ran into problems, so we
can improve the process.
- Profit.

Some notes about creating "practice releases":

- It's okay to skip steps 1-3 of the release guide for practice releases
- You can also safely skip any steps that involve communicating with others,
such as posting messages to the mailing lists or updating the wiki
- If you don't want to wait the 30+ minutes for a spectest run to
complete, "make test" is sufficient for a practice release.
- Yes, it's even possible for you to test uploading the tarball
to github -- just make sure to put it in your own repository
and not in Rakudo's master. :-)

So, anyone want to give it a try?  If you do, please let us know
how it works out, and places where you think things can improve.
I know that we'll be updating the release guide in response to
feedback from others, as well as adding things like testing of
"make install" and the like.

Thanks!
