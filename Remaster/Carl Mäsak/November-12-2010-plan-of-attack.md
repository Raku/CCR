# November 12 2010 — plan of attack
    
*Originally published on [12 November 2010](http://strangelyconsistent.org/blog/november-12-2010-plan-of-attack) by Carl Mäsak.*

> 68 years ago today, the Australian government approved a *second* attack on the enemy host &mdash; because the first one hadn't been particularly successful &mdash; in what was to become known as the "[(Great) Emu War](https://en.wikipedia.org/wiki/Emu_War)".

You read that correctly. The enemy that Australia was fighting was the large, silly relative to the ostrich known as the [emu](https://en.wikipedia.org/wiki/Emu). About twenty thousand of them were causing enough trouble for the Australian farmers, that it was decided that military action was needed.

> The emus consumed and spoiled the crops, as well as leaving large gaps in fences through which rabbits could enter and cause further problems. [...] The "war" was conducted under the command of Major G.P.W. Meredith of the Seventh Heavy Battery of the Royal Australian Artillery, with Meredith commanding a pair of soldiers armed with two Lewis Automatic Machine Guns and 10,000 rounds of ammunition.

Guns against emus. I'm not making this up. Anyway, the first attack wasn't the amazing success one might expect when the Royal Australian Artillery with frigging machine guns moves against a group of flightless birds.

> The number of birds killed is uncertain: one account claims just 50 birds, but other accounts range from 200 to 500 - the latter figure being provided by the settlers. On the plus side, [Major] Meredith's official report noted that his men had suffered no casualties.

In the words of ornithologist [Dominic Serventy](https://en.wikipedia.org/wiki/Dominic_Serventy):

> "The machine-gunners' dreams of point blank fire into serried masses of Emus were soon dissipated. The Emu command had evidently ordered guerrilla tactics, and its unwieldy army soon split up into innumerable small units that made use of the military equipment uneconomic. A crestfallen field force therefore withdrew from the combat area after about a month."

Major Meredith also expresses his clear disappointment at the birds' sturdy builds:

> If we had a military division with the bullet-carrying capacity of these birds it would face any army in the world...They can face machine guns with the invulnerability of tanks. They are like Zulus whom even dum-dum bullets could not stop.

I was going to say that in the century of gene modification, someone is bound to build an army of armed emus sooner or later. But I'm momentarily stunned by the comparison of emus to Zulus.

Anyway, the second attack was more successful, resulting in about a thousand direct kills, and about 2,500 birds dying from bullet injuries. Allegedly, 100 of the emu skins were collected, their feathers used to make hats for light horsemen.

A decent test suite can help you catch simple programming errors. An excellent test suite helps you with the design.

A decent test suite tells you "you missed a spot". An excellent test suite tells you "no, that's not it &mdash; I remember more of the design than you do". And *then*, when you get it mostly right, it tells you "you missed a spot". Or, put differently, you're not done until both you and the tests say it's fine. It's bloody frustrating, but it really helps, too.

Today, I had that kind of battle with `pls`. The tests are pretty good, and thus they boss me around. Even when I want them to adhere to a new design, like I did today, they still drive me more than I drive them. Brings a slightly new ring to the term "test-driven".

Here's how I originally thought project installation would happen:

- Fetch recursively
- Build recursively
- Test recursively
- Install recursively

Simple, and fine.

Then jnthn showed up (about half a year ago) and told me that that's not how people expect things to happen. So I got a new model, which looks more like this:

- Fetch
- Fetch-Build-Test-Install all dependencies (recursively)
- Build
- Test
- Install

Had to drag the tests, kicking and screaming, into this new model, but it was OK. They made sure I didn't botch things up. Things were fine again.

In testing `pls` with real projects, though, it turned out that the model contained a heinous oversight. See, we only know the dependencies of a project *after* it's been fetched, but the tests had all their dependencies given up front, and (oops) assumed in some places that they would be.

So I changed that. And everything broke completely.

Why? Because I had used test-driven development, and the code was shaped after the tests. So the *code* also relied heavily on the faulty assumption. Specifically, the counter-measures for cyclic dependencies seem to have assumed a static model of dependencies, and the cycle-detecting code seemed to end up doing infinite recursive nastiness when it didn't.

Making all of it work meant taking a good look at code that was perfect under the old model, trying to understand why it was less-than-perfect under the new. Ow; brain hurt.

The tests, and judicious debug output, helped me through it. [Here's the commit](https://github.com/masak/proto/commit/7522692059e60027fdb9032036fd01266c654610). Now my model looks like this:

- Fetch
- Make sure there are no cycles
- Fetch recursively
- Built-Test-Install all dependencies (recursively)
- Build
- Test
- Install

And it seems to work. Both the tests and I are happy.
