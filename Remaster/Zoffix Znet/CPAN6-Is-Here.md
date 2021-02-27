# CPAN6 Is Here
    
*Originally published on [6 October 2017](https://perl6.party//post/CPAN6-Is-Here) by Zoffix Znet.*

If you've been following Rakudo's development since first language release on Christmas, 2015, you might've heard of numerous people working to bring CPAN support to Rakudo Raku.

Good news! It's finally here in usable form and you should start using it!

Let's talk about all the moving parts and how to upload your dists to CPAN.

## The Moving Parts and Status Report

All of the heavy lifting has been done awhile back, during Perl Toolchain Summit and other times. I wasn't present for it to know the details, but to catch up you could join [#rakuoolchain chat](https://webchat.freenode.net/?channels=#rakuoolchain) and talk to humans or read [the channel log](https://irclog.perlgeek.de/rakuoolchain/2017-10-06). Perl [programming] Authors Upload Server (PAUSE)/CPAN support for Raku dists was implemented and [zef module installer](https://modules.raku.org/dist/zef) was trained to check for CPAN dists as well as our GitHub/GitLab-based ecosystem (called "p6c").

The only bit that was left missing is a front-end to browse available CPAN dists. There is a team who wished to take [metacpan.org](https://metacpan.org/)'s codebase and modify it for Rakudo dists. I'm told that project is currently "stalled but not dead".

That's unfortunate, however, earlier this week, [modules.raku.org](https://modules.raku.org) was [taught to handle CPAN dists](http://modules.raku.org/search/?q=from%3Acpan), so—hooray!—we finally have some sort of a front-end for CPAN dists. If you only want to see CPAN dists in search results, you can use `from:cpan` search qualifier (just like you can use `from:github` and `from:gitlab` ones).

GitHub/GitLab dists URLs still direct to repos, but CPAN dists have a [file browser](http://modules.raku.org/dist/Number::Denominate:cpan:ZOFFIX) that lets you see what files are up in the dist. The file browser also renders `README.md`/`README.markdown` markdown readme files.

The viewer doesn't have all the bells and whistles of [metacpan.org](https://metacpan.org/) and doesn't (yet) render POD6, but it's certainly useable. The person who implemented this viewer will be busy preparing 6.d language release in the near future and won't have the time to make additional improvements to the CPAN dist viewer. So… [you're invited to contribute](https://github.com/raku/modules.raku.org) and make it better!

## Why Upload to CPAN

CPAN has many mirrors ensuring module installation is not affected whenever GitHub (a single website) has issues. The uploaded dists are also immutable and stay there forever (barring special deletion requests, even deleted dists remain available on [BackPAN](http://backpan.perl.org/)). This means people are more likely to trust these dists for use in their larger projects that need dependable dependencies. Lastly… it's what the cool kids use!

## How to Upload to CPAN

Here's the process for how you can get your dists to CPAN. If these dists are currently listed in our p6c ecosystem, both p6c and CPAN versions will appear on [modules.raku.org](https://modules.raku.org), and you're encouraged to remove the p6c version. Some of the described tools are brand-new and others are brand-old, created before Rakudo existed, so treat this guide as part information and part invitation to improve the tools.

### Step 1: Get a PAUSE account

PAUSE stands for "The [Perl programming] Authors Upload Server", it's located at [pause.perl.org](https://pause.perl.org), and it's a site you use to upload dists to CPAN.

Go to [request PAUSE account page](https://pause.perl.org/pause/query?ACTION=request_id) and subscribe for an account. The "desired ID" field is for your PAUSE ID, and it's currently used as "author" field on [modules.raku.org](https://modules.raku.org). For example, [mine is ZOFFIX](https://modules.raku.org/search/?q=from%3Acpan+author%3AZOFFIX).

I had my account for over a decade, so my memory is a bit fuzzy, but I think you'll need to wait for a human to approve and create your account—it's not instantaneous.

### Step 2: Make a Dist Archive

You can manually create a tarball or a zip archive. I don't have all the details on which files you're supposed to have in them; you can [take a look at other CPAN dists](http://modules.raku.org/search/?q=from%3Acpan) to see what they're doing or…

Use [App::Mi6 module](http://modules.raku.org/dist/App::Mi6:github)! It's possible you were already using it to create dists, in which case you're in luck, as you can just run `mi6 dist` to make a dist archive.

I rolled my dists by hand and wrote all the docs in `README.md`, so when I gave `mi6 dist` a whirl, it [replaced my `README.md`](https://github.com/skaji/mi6/issues/23) with emptiness because I wasn't using any POD6—something (currently) to watch out for.

### Step 3: Upload Your Dist

The first option is to upload manually: log into [pause.perl.org](https://pause.perl.org), then go to [Upload a file to CPAN](https://pause.perl.org/pause/authenquery?ACTION=add_uri), be sure to select `Perl6` in the select input and then upload either via an uploaded file or a URL.

The second option is to use [App::Mi6](http://modules.raku.org/dist/App::Mi6:github)'s `mi6 upload` command.

Shortly after the upload, you'll get an email about whether your upload succeeded (you can also see emails on [nntp.perl.org](https://www.nntp.perl.org/group/perl.cpan.uploads/)). Make sure you have a `META6.json` file in your dist and that the dist version you're uploading is higher than the currently uploaded version. Those are the most common upload errors.

### Step 4: Relax and Wait

If you're [on IRC](https://webchat.freenode.net/?channels=#raku), in about 10 minutes after your upload, our buggable robot will announce it:
  
> **<buggable>** New CPAN upload: Number-Denominate-1.001001.tar.gz by ZOFFIX
>      https://www.cpan.org/authors/id/Z/ZO/ZOFFIX/Perl6/Number-Denominate-1.001001.tar.gz<br>

In about 2 hours, the dist will also appear on [modules.raku.org](https://modules.raku.org). Its updater is started in a cron job on 20th and 40th minute of the hour (unless a job is already running) and it [takes about 2 hours](https://modules.raku.org/update.log) to finish each run.

### Step 5: Celebrate with the Appropriate Amount of Fun

That's about it to the process. I foresee more tools will be created in the future to make the process even easier than it is today. If you have any questions or issues, just talk to a human or a robot [on our #raku IRC channel](https://webchat.freenode.net/?channels=#raku).

## Conclusion

CPAN support for Rakudo Raku dists is now usably here. You're encouraged to upload your dists to CPAN, to grow a more dependable ecosystem. You're also invited to improve and create tooling that manages and displays CPAN uploads.

-Ofun
