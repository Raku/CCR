# November 9 2009 — stuff comes tumbling down, yay!
    
*Originally published on [9 November 2009](http://strangelyconsistent.org/blog/november-9-2009-stuff-comes-tumbling-down-yay) by Carl Mäsak.*

> 20 years ago today, the wall dividing Berlin (and by metaphoric extension, Europe), [fell](https://en.wikipedia.org/wiki/Berlin_Wall). I wrote about this last year on this day, and I had planned not to repeat myself... but there's just no way I could refer to something else today, on the 20th anniversary and all.

During a revolutionary wave sweeping across the Eastern Bloc, the East German government announced on November 9, 1989, after several weeks of civil unrest, that all GDR citizens could visit West Germany and West Berlin. Crowds of East Germans climbed onto and crossed the wall, joined by West Germans on the other side in a celebratory atmosphere. Over the next few weeks, parts of the wall were chipped away by a euphoric public and by souvenir hunters; industrial equipment was later used to remove almost all of the rest. The fall of the Berlin Wall paved the way for German reunification, which was formally concluded on October 3, 1990.

Also, the cold war ended, and the world community eventually moved on to tackling more interesting political problems, such as the oppressive reign of the media industry, their vain efforts to prevent the arrival of an inevitable future, and the cowardly governments who heed their beckons rather than those of their citizens. (Just an example.)

*Woodi*++ [explained](https://irclogs.raku.org/perl6/2009-11-08.html#19:48-0004) where the error of yesterday was coming from: it comes from `Makefile.PL` itself. Looking at that file, I see that it is obviously made with great care, taking into account all manner of eventualities. It is, however, inevitably old, and it simply doesn't work anymore.

My immediate feeling is that since that `Makefile.PL` isn't filling any useful function, it'll have to be taken out. Just like that wall. So I remove it. I also remove the file `Makefile.in`, and the same two files in the November project.

We might have to put something else in their place, of course. It's nice to have a `make test` target, for one thing. And I kinda prefer projects not to lean on proto for functionality. But (especially in the case of November and HTML::Template) these things need to be seriously re-thought anyway. So for now, I'll just remove them.

Let's see how the installation goes now:

```
$ ./proto install november
Refreshing november...refreshed
Refreshing html-template...refreshed
Building html-template...built
Building november...built
Installing html-template...Method 'protected-files' not found for invocant of class 'Ecosystem'
in Main (file src/gen_setting.pm, line 324)
```

That's much better. Now only the mystery of the missing method `protected-files` remains. Will investigate that some other day.
