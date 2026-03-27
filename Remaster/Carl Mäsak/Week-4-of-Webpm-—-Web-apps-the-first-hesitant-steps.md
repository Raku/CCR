# Week 4 of Web.pm — Web apps, the first hesitant steps
    
*Originally published on [12 April 2009](http://strangelyconsistent.org/blog/week-4-of-webpm-web-apps-the-first-hesitant-steps) by Carl Mäsak.*

> *goliath walkd out to see david n laffd at him "Srsly lil kitteh, am i lyke sum dog dat u try to beat me up wit a stik? srsly dood, dat is teh suckz. come here n see me so i can groun u up lyke so much bird food." goliath yelld.*

> *n david sed, "u coem to meh wit all ur fancy armrz n stuffz, but i coem to u teh naem of teh Cat of teh Ceiling's armis, u kno, ceiling catz armis dat u leik to teez so much. today, ceiling cat wil totaly taek u, n i'm so goin to kill u and cutz off ur hed n stuff. n den, I will will groun all ur fighterkitteh leik so much bird food n den evryone will kno dat ceiling cat livs n israel! n evryone here wil kno dat ceiling cat savs his kittehs n he doan evn need any of dat fancy armor stuff. Dis is totaly ceiling cat's battl n he will so gif u to me. kthnx."*

> *s0 goliath cam fwd to meet david n david ranz at him. he grabd one of hiz rockz an den he leik thru it at goliath! n teh rock hit goliath in teh hed n he fell over and dyd. Pwnd!* — 1 Samuel 17:41-48  

A combination of persistently distracting `$WORK` and and initial lack of overview of the problem at hand has delayed this blog post more than an extra week. I had a clear goal, but no clear way of getting there.

My clear goal was this: get the Lobster running locally on the browser. For this, I would use the `HTTP::Daemon` module written by *mberends*++. I had significant problems using that code, most of which later turned out to be due to my own inability to follow mberends' given instructions. Scant progress and plenty of distractions are a bad combination.

When I finally managed to hook the Lobster up to HTTP::Daemon, things went quickly. Strangely enough, nothing happened when clicking the 'flip!' link... a moment's reflection gave the cause of this: a few days ago, *TimToady* has syntactically separated reversal of `List` (`.reverse`) from the reversal of `Str` (`.flip`); my code was like three weeks old and was still using `.reverse` for strings, which in the newest Rakudo got interpreted as one-elem lists, and list-reversed with no visible effect whatsoever. I fixed that, and found the fact that the link in the Lobster app was already called 'flip' an indication of the appropriateness of the name change. Raku just keeps getting nicer and nicer.

You could head over to github and [look at the Lobster](https://github.com/masak/web/blob/master/lib/Web/Lobster.pm) in its functioning form. (By the way, I'm considering changing the Lobster to a [Nibbler](https://www.google.com/search?q=nibbler+futurama&udm=2), so as to retain some originality wrt Rack. Anyone who masters the ancient art of ASCII images is welcome to help me out, thus being immortalized as the artist of the example webapp of Web.pm.)

According to the plan, this week should go to "Changing November to run on top of the framework". I've chosen to postpone this a bit, because there's lower-hanging fruit to be picked before that, namely Druid. So I spent this morning hooking up Druid to HTTP::Daemon the same way I did Lobster. It's nice to see the Druid board in the browser things are really ugly so far (a `pre` with the ASCII board, followed by a list of links with possible moves), but I have high hopes for improvements for the following weeks.

As a bonus, I got to test *Tene*++'s `Tags` module when creating the Druid web output. My use of it looked [like this](https://gist.github.com/masak/93929). I can definitely learn to live with that.

A strange thing happened though, when I rebuilt after including `Tags` in the webapp: the `new` method in `Druid::Game` broke! WTF? To repeat, I included one module, and another, completely unrelated one, stopped working. Not good.

After a bit of the usual detective work, I found the culprit: the `Tags` module exported a sub called `map`, and `Druid::Game.new` tried to use the vanilla `map` that we all know and love. ☺ I'm glad I was the one to find that... feature. (I've since patched the module so that it doesn't do that.)

What else? Oh, just a lot of small details that I've skipped over. Things that don't jump out as plain wrong until you try to run them. Fixing those is tedious, but the advantage is that my piece of Web.pm is no longer a theoretical construct, it's practiaclly useable (and used!).

I will spend the next week solidifying this groundwork, as well as giving `Druid::Webapp` some love, and starting to look at porting November over to use Web.pm. I also want to spend some time getting back to the overall plan for Web.pm what we have so far, how the pieces fit together, and where we're heading.

I wish to thank The Perl Foundation for sponsoring the Web.pm effort.
