# Back and hackin’
    
*Originally published on [2011-01-08](https://6guts.wordpress.com/2011/01/09/back-and-hackin/) by Jonathan Worthington.*

Some time in November, I got a little ill, and in the weeks that followed never quite recovered my usually energy levels. Work was busy, and after dealing with that each day, I had very little energy for anything else – be it Raku, studying Russian, or…well, just about anything. Anyway, I took a long Christmas and New Year’s break, rested lots and got back from that yesterday. So, here I am. :-)

I’d love to say I’m well, but I seem to have managed to bring a throat infection back from my break. Thankfully, not being able to swallow anything big doesn’t seem to have damaged my ability to hack, so I started to take some tentative first steps back into Raku hacking today, in preparation for digging back into my grant work – hopefully as soon as tomorrow! Today I…

- Had a crack at putting in a 6model-inspired [nominal type check cache](https://github.com/rakudo/rakudo/commit/803a4f10cd83d7b5878f4964ccd6f32db446a050) into Rakudo’s signature binder. It’s not especially clever, and when 6model lands it’ll give this kind of win – but bigger – in many more places. But I wanted to give users of Rakudo today some kind of improvement. It shaves about 30% of the runtime off running tools/benchmark.pl. It’s in master, and hopefully will hold up. There were no spectest regressions.
- In the [jnthn-opts branch](https://github.com/rakudo/rakudo/commits/jnthn-opts), I played around with some other ideas. The main thing in that branch is a (not quite completed) improvement to the way we store the scalar and rw flags for some types of container, dropping the Parrot property hash in favor of some bit flags (and yes, this means 1 less GC-able object for a lot of things – notably, for every `$/`, `$!` and `$_` container). It gives some performance improvement, and since arrays contain nested containers that the improvement applies to, it seems to offer a notable memory saving, especially for large arrays.  This improvement isn’t quite ready for the prime time yet, thus why it’s in a branch. I’ll try and get it finished up shortly.
- Spent a while analyzing why iteration is so painfully slow in Rakudo. Thanks to *pmichaud*++, Rakudo currently has a pretty sound iterator model. Sadly, the implementation of it is horribly slow. It’s not so much that there’s any one single reason for this; it’s more a case of “death by a thousand cuts”. The forthcoming meta-model improvements will make it faster in some ways, but even with faster OO primitives in place, and changes so it takes advantage of them, it will still suffer from doing a lot to much shuffling around of data.
- Cherry-picked some bits from nqp-rx master into the [nom](https://github.com/raku/nqp-rx/commits/nom) (New Object Model) branch, in preparation for continuing work there.
- Encouraged by *tadzik*++, added META.info files to some of my modules, so they play better with the various pieces of the module ecosystem.

My goals for the next week are to:

- Write an overview document explaining 6model architecture
- Port the various 6model core additions – including the type check bits and method cache infrastructure – from nqpclr (the .Net NQP implementation) to nqp-rx/nom
- Start to port the multi-dispatch bits from nqpclr to nqp-rx/nom
- Do more planning and maybe initial code sketching on natively typed attributes

My goals for the month are:

- Get nqp-rx/nom classes using the new meta-model
- Implement a role meta-object that works on both nqp-rx/nom and nqpclr (being able to write it once and use it on both will be a key test of compatibility of the two implementations)
- Have significant progress on natively typed attributes on at least one backend
- Have progress towards switching the grammar keyword in nqp-rx/nom over to the new meta-model (achieving this will mark the elimination of the old object model from the code that nqp-rx/nom generates)

More soon, when I’ve written some more code and have something interesting to blog about. :-)
