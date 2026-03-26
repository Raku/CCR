# November 4, 2008 — "bug wrangler"
    
*Originally published on [4 November 2008](http://strangelyconsistent.org/blog/november-4-2008-bug-wrangler) by Carl Mäsak.*

86 years ago today, archaeologist and Egyptologist Howard Carter made a historical discovery: the steps leading to [Tutankhamun](https://en.wikipedia.org/wiki/Tutankhamun)'s tomb, "by far the best preserved and most intact pharaonic tomb ever found in the Valley of the Kings". The [Wikipedia article](http://en.wikipedia.org/wiki/Howard_Carter_(archaeologist)) about Carter tells the story about the discovery:

> He wired Carnarvon [Lord Carnarvon financed Carter's search for the tomb] to come, and on 26 November 1922, with Carnarvon, Carnarvon's daughter, and others in attendance, Carter made the famous "tiny breach in the top left hand corner" of the doorway, and was able to peer in by the light of a candle and see that many of the gold and ebony treasures were still in place. He did not yet know at that point whether it was "a tomb or merely a cache", but he did see a promising sealed doorway between two sentinel statues. When Carnarvon asked him if he saw anything, Carter replied: "Yes, wonderful things".

Today was spent hunting down a Parrot build failure which only I experienced, and no-one else. After I managed to show that it wasn't simply due to a corrupt working copy, and after I had both nagged and reminded people a bit, *chromatic*++ (who had made the commit that broke my Parrot) was genteel enough to send along a patch that fixed everything.

Suddenly I don't have to jump through hoops to make Parrot work again! On #parrot, shortly afterwards:

```
<pmichaud> *chromatic*++ *masak*++
<moritz> indeed
<masak> *chromatic*++
<masak> I just followed instructions. :)
<moritz> masak: and you bugged people to give you instructions ;)
<pmichaud> keeping on top of a bug is often as important as fixing it.
<masak> if you can find a good formal sounding title, I'd be very happy to be 'the guy who keeps on top of bugs, nagging other people about them' :)
<pmichaud> "bug wrangler"
<masak> pmichaud: I like it
```

Speaking of jumping through hoops, *jonathan*++ is back from vacation, and fixed many bugs which affect November in one way or the other. Two of these concern modules:

- Compiling modules to PIR and using them now supposedly works again.
- Namespaces should be able to `Contain::Double::Colons` again.

Though both these changes could mean improvements to the November code, I haven't looked into it today. I'll have a look tomorrow evening, but I'm kind of hoping someone will beat me to it. (Hint, hint.)
