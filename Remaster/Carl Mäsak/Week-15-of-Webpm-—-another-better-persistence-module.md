# Week 15 of Web.pm — another, better persistence module
    
*Originally published on [21 September 2009](http://strangelyconsistent.org/blog/week-15-of-webpm-another-better-persistence-module) by Carl Mäsak.*

> *Has happen? Gunna be agin. Nuthing new undur teh sunz.* — Ecclesiastes 1:9

Last time, I wrote "We'll see if [Viper](week-14-of-webpm-a-persistence-module.html) survives in any form. I wouldn't be surprised if it's replaced quickly by something much better." That was what happened. *mst*++ recommended I check out Sequel, which I did. There's no question Sequel is a better starting point than ActiveRecord.

- The port of Sequel received the name Squerl. I quickly threw together functionality to [mimic](https://github.com/masak/web/blob/master/t/squerl/01-sqlite-write.t) what I had in Viper. That was two weeks ago.
- Since then, I've successively been porting over tests for the central class in Sequel: `Dataset`. If you're interested in the workings of this class, I recommend the [Sequel README.rdoc](https://github.com/jeremyevans/sequel/blob/master/README.rdoc). If that doesn't quench your thirst for knowledge, I recommend the beautifully-written [dataset.rb](https://github.com/jeremyevans/sequel/blob/master/lib/sequel/dataset.rb) and [dataset/sql.rb](https://github.com/jeremyevans/sequel/blob/master/lib/sequel/dataset/sql.rb). One can tell that this code is written by people who know stuff.
- When porting, I'm using a quickly thrown-together version of [tote](Helpfully-addictive-tdd-on-crack.html). A bastardisation of the idea, basically; once I had outlined the idea of tote, I just couldn't stand the thought of working without such a framework. The results are significant. Maybe it's the effect of just using some new framework, I don't know. But I look forward to writing the real tote.
- The increased programming activity has led to increased bug reporting activity. That makes me feel a bit relieved; for a while there I wasn't reporting as many bugs — I thought maybe we were running out of them. 哈哈
- I've really been working two weeks' worth of grant work lately, but haven't gotten around to blogging. Therefore, I'll keep this post short, and get back to my TDD-on-crack coding, and then hopefully give another short update later in the week. In that post, I promise to tell you how to use this new database module in your own Raku projects! Until then, you'll just have to use [the tests](https://github.com/masak/web/tree/master/t/squerl/) as guidance.

I wish to thank The Perl Foundation for sponsoring the Web.pm effort.
