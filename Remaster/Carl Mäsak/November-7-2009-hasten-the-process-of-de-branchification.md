# November 7 2009 — hasten the process of de-branchification
    
*Originally published on [7 November 2009](http://strangelyconsistent.org/blog/november-7-2009-hasten-the-process-of-debranchification) by Carl Mäsak.*

> 53 years ago today, the United Nations General Assembly adopted a resolution calling for the United Kingdom, France and Israel to immediately withdraw their troops from Egypt during the [Suez Crisis](https://en.wikipedia.org/wiki/Suez_Crisis). The Wikipedia article is so interesting that I have a hard time limiting the amount of quotes today:

The events that brought the crisis to a head occurred in the spring and summer of 1956. On 16 May, Nasser officially recognized the People's Republic of China, a move that angered the U.S. and its secretary of state, John Foster Dulles, a keen sponsor of Taiwan. This move, coupled with the impression that the project was beyond Egypt's economic capabilities, caused Eisenhower to withdraw all American financial aid for the Aswan Dam project on 19 July. Nasser's response was the nationalization of the Suez Canal. [...]

British government concluded a secret military pact with France and Israel that was aimed at regaining control over the Suez Canal. [...]

Canadian Lester B. Pearson, who would later become the Prime Minister of Canada, went to the United Nations and suggested creating a United Nations Emergency Force (UNEF) in the Suez to "keep the borders at peace while a political settlement is being worked out." Both Britain and France rejected the idea, so Canada turned to the United States. [...] Pearson was awarded the Nobel Peace Prize in 1957 for his efforts. The United Nations Peacekeeping Force was Pearson's creation and he is considered the father of the modern concept of "peacekeeping". [...]

The imposed end to the crisis signalled the definitive weakening of the United Kingdom and France as global powers. Nasser's standing in the Arab world was greatly improved, with his stance helping to promote pan-Arabism. The crisis also arguably hastened the process of decolonization, as the remaining colonies of both Britain and France gained independence over the next several years.

Hokay. The weekend distracts me to no end, but let's try and install November on the `installed-modules` proto branch; that would be quite fitting, no?

```
$ ./proto showstate november
november: legacy
```

Right. "legacy" here means "proto knows you used to have this installed, so you might want to do something, such as install it again". (If this seems harsh, be aware that my proposed line [was even harsher](https://irclogs.raku.org/perl6/2009-11-06.html#23:02), but *mberends*++ has this weird idea about caring about and assisting the userbase in the migration.)

Here goes.

```
$ ./proto install november
Downloading november...downloaded
Downloading html-template...downloaded
Building html-template...configure failed, see /Users/masak/gwork/proto/cache/html-template/make.log
Building november...configure failed, see /Users/masak/gwork/proto/cache/november/make.log
Installing html-template...Method 'protected-files' not found for invocant of class 'Ecosystem'
in Main (file src/gen_setting.pm, line 324)
```

Heh. "[Malsukceso](https://en.wiktionary.org/wiki/mal-#Esperanto)", as we say in Esperanto.

I won't fix it today, but I'll just note that I see three errors in that output.

- Firstly, both html-template and november fail in the configure step. That's possibly a proto issue, but it could as well be issues with the projects. Both november and html-template have really old build systems, because they are among the oldest projects we have.
- Secondly, what's it doing trying to install html-template when the build obviously failed?
- Thirdly, there seems to be a method missing.

Right. We're definitely not ready for prime time. But that's all right; everything in life is provisional. 哈哈
