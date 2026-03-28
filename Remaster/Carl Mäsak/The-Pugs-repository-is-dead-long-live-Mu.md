# The Pugs repository is dead; long live Mu!
    
*Originally published on [6 September 2010](http://strangelyconsistent.org/blog/the-pugs-repository-is-dead-long-live-mu) by Carl Mäsak.*

This weekend marks the end of a quite astonishing era. The Pugs repo, that hosted all the [amazing Raku activity](Happy-10th-anniversary-raku.html), is no more. At its height, this repository had 242 committers! I just checked.

The Pugs repository has functioned as a common writing area for Raku-related things. First [Pugs](https://github.com/audreyt/pugs); then a lot of external modules and scripts written in Raku; what would eventually morph into [the Raku test suite](https://github.com/Raku/roast); even the [Raku specification](https://github.com/Raku/old-design-docs) and the standard grammar. Commit bits (write access credentials) were handed out liberally, and newcomers were encouraged to help improve things they found amiss. The degree to which this system worked without a hitch has been quite astonishing. There have been no edit wars, no vandalism, no banning. Just the continuing flow of commits. Trust the anarchy.

So why are we killing off the Pugs repository? Well, technologies come and go; not so much because they worsen by each year, but because our expectations rise in a sort of software inflation. The SVN repository became too high-maintenance, and a transition to git was the natural next step. The Pugs repository has been split up into the git repositories linked to in the previous paragraph. Those bits that don't belong in any of the standard bins remain in the [Mu repository](https://github.com/Raku/Mu). (Its name is a reference to the most-general object type in Raku, what in other languages is commonly known as 'Object'.)

I for one salute our new git-based overlords! May the commits keep flowing even under this new system. Also, *moritz*++ for carrying out the move.
