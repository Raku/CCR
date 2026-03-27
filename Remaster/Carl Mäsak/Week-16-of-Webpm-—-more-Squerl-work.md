# Week 16 of Web.pm — more Squerl work
    
*Originally published on [28 September 2009](http://strangelyconsistent.org/blog/week-16-of-webpm-more-squerl-work) by Carl Mäsak.*

> *theer has is a sison for evryting, and a tiems for every perpos under teh ceiling. a tiemz 2 git kittehs, an a tiems 2 get ded. a tiemz to bury the cheezburger and a time to dig up the cheezburger you has planted. tiemz 4 killin the mouses and tiemz 4 being ok with them but not rly. theres a tiemz 4 lollin and a tiemz 4 not lollin so much. A teimz 4 weepins and a teimz 4 dancin. a tiemz to keep cheezburger and a tiemz to give them away, srsly. teimz 4 hugs, tiemz when hugz are NOT WANTED. a tiemz 4 lookin round and a timez 4 getin bored and stop lookin. a tiemz 2 brak and a teimz 4 fix and a teimz 4 STFU and a teimz 2 talkz. A teimz 4 LUV and a teimz 4 HAT. A teimz 4 lots a killin and a teimz 4 only killin when nobodys lookin. u get teh picture.* — Ecclesiastes 3:1-8

Ok, here we go. Have a look at this:

```raku
use v6;
use Squerl;
my $DB = Squerl.sqlite('example.db');
$DB.create_table: 'fruits',
    'id'   => 'primary_key',
    'name' => 'String',
    'qty'  => 'Int',
 ;
my $fruits = $DB<fruits>;
my $i = 0;
for <apples pears oranges ninjas peaches papayas>
  Z <    50    20      70      3      15      35> -> $name, $qty {
    $fruits.insert($*i*++, $name, +$qty);
}
# those ninjas get in anywhere
$fruits.filter('name' => 'ninjas').delete;
# new shipment of pears
$fruits.filter('name' => 'pears').update('qty' => 40);
for $fruits.filter(sql_number('qty').gt(35)).llist {
    say sprintf 'There are %d %s', .[2], .[1];
}
```

(Also available syntax-highlighted [here](https://gist.github.com/masak/195336).)

- Yes, this works already. If you want to try it, you'll need to have `web` and `rakuqlite` in your `RAKULIB` path.
- If you do play around with this, and I hope you will, you'll fairly quickly run into the limitations of the current Squerl. But what's there is already fairly solid. I'm working completely TDD, and enjoying myself greatly along the way. If someone reports something that they would like to work, I'm sure I can replan to make that happen sooner.
- I've had a several-months long personal conflict with passing named parameters to routines. It seemed that no matter what I did, I had to map my solutions around corner cases in ugly ways. Specifically, I often had to make signatures with both a slurpy array and a slurpy hash, and then mix them together and extract the pairs from both. I've now concluded that this is likely the wrong way to go about things. Instead, I've started using positional pairs almost exclusively, and named pairs only for adverb-like named arguments. This might be good to know for people who learn as slowly as I do. 哈哈
- I especially like the `$DB<fruits>` syntax. It's made possible by defining a `method postcircumfix:<{ }>` in `Squerl::Database`. Unfortunately, it also triggered [[perl #69438]](https://github.com/Raku/old-issue-tracker/issues/1326), so I had to add a lot of preemptive semicolons everywhere. Oh well. It was worth it.
- You'll have to excuse my extolling on workarounds; like it or not, they form the most spicy part of Raku development. In `sql_number('qty').gt(35)`, I could have used a `<` operator if 't weren't for [[perl #66552]](https://github.com/Raku/old-issue-tracker/issues/1055).
- I could have written `.list` instead of `.llist` if not for another bug (which I can't find in RT right now) causing Rakudo to freak out as soon as someone defines a `list` method. The thing about workarounds, of course, is that they can be successively removed as Rakudo improves. So you get to feel good twice: first, for finding a bug, and then for improving your own code by removing workarounds.
- Matt-*W*++ provided useful feedback for deciding how the table creation syntax should look. Ruby's Sequel uses a DSL for that, and Squerl might eventually do as well, when Rakudo supports it.
- For the coming week, besides adding and passing more tests for Squerl, I'll see if I can't dogfood a little by using Squerl for [Druid](https://github.com/masak/druid). Too long I've been waiting to make a Druid web application!
- I said last Monday that I'd be blogging again "later in the week". But, hey look, it's Monday again! Empirically, it seems that promising to blog later in the week makes me blog exactly one week later. So, I'll try to blog twice this week — in the worst case, that'll make me blog on time in a week too.

I wish to thank The Perl Foundation for sponsoring the Web.pm effort.
