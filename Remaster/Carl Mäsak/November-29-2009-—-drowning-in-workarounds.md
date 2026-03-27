# November 29 2009 — drowning in workarounds
    
*Originally published on [30 November 2009](http://strangelyconsistent.org/blog/november-29-2009-drowning-in-workarounds) by Carl Mäsak.*

> 228 years ago today, the crew on board the slave ship Zong [murdered 133 Africans](https://en.wikipedia.org/wiki/Zong_Massacre) by dumping them into the sea, in order to claim insurance.

The resulting court case, brought not by the authorities as a mass-murder charge against the ship-owners, but as a civil action by the ship-owners seeking compensation from the insurers for the slave-traders' lost "cargo", was a landmark in the battle against the African slave trade of the eighteenth century.

The term "Zong Massacre" was not universally used at the time. It was usually called "The Zong Affair," the term "massacre" being used mainly by those considered to be "dangerous radicals," as late eighteenth-century politics stood. At the time, the killing of slaves—individually or en masse—was not considered to be murder, at least legally. In English law, the act was completely legal and could be freely admitted to the highest court in the land, without danger of prosecution. The publicity over this case was, however, one of the factors that led to the legal situation being completely changed within a few decades.

Despite the long way we've come since then, I hear slavery is bigger than ever, in absolute numbers, in our day.

Today I decided to find out why `GGE::OPTable` was emitting warnings. When writing that class and inadvertently introducing those warnings, I had the intuitive feeling that they were not my fault, so to speak, but the result of a yet-undiscovered rakudobug.

I was right. It was a spooky-action-at-a-distance bug where a declaration of a postcircumfix `.{}` operator in one file caused Rakudo to report a completely innocent variable declaration nested deeply inside another file as being [a redeclaration](https://github.com/Raku/old-issue-tracker/issues/1420), when in fact it wasn't.

Postcircumfix `.{}` is notoriously difficult to get right. It already had [two](https://github.com/Raku/old-issue-tracker/issues/1326) [bugs](https://github.com/Raku/old-issue-tracker/issues/1347) to its name before today. It clashes syntactically with not only blocks, but sometimes even with itself! 哈哈

I wouldn't care about a warning which I didn't cause and which would go away as soon as the rakudobug in question is fixed, if it weren't for the fact that when Rakudo emits warnings during precompilation, it [generates broken PIR files](https://github.com/Raku/old-issue-tracker/issues/1412). So, by working around the false warning bug, I could precompile my module files, which would help make the Glacial Grammar Engine slightly less glacial at startup.

But... uh. Uhn. GGE is big. Because it's the declaration of the postcircumfix `.{}` operator that's triggering the bug, I needed to remove that declaration *and all its usages*. How does a use of that method look? Well, like a normal hash access. That's the point of declaring it in the first place!

Hash accesses aren't really searchable. They can look like `.{}` or like `.<>` (most often without the dot, of course), but even worse, they are hidden behind many hash accesses on other objects (mostly hashes), which also look like that. This is one of the times where non-strict typing does not really help. So there was a lot of manual inspection involved, to separate the goat hash accesses from the sheep hash accesses.

In the end, all you can really do is replace all the occurrences you find by eye, run the tests and see where things fail, insert loads and loads of debug statements to find out how far into the code the execution reaches before things blow up, finally finding the offending hash access. It is the pure masochism in this kind of work, along with the fact that I haven't heard others complain a lot, which makes me think that I am indeed writing some of the most complex stuff out there in Rakudo right now. Either that, or I'm simply doing it wrong. 哈哈

I got partially there. In order to be able commit and push something today, I shunted my work off in a branch. [Here it is](https://github.com/masak/gge/commit/9256ca6e8193ac51979cd5e844637fbb4a12b291). Will merge as soon as all the old tests pass again.
