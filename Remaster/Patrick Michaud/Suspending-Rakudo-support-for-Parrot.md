# Suspending Rakudo support for Parrot
    
*Originally published on [16 February 2015](https://pmthium.com/2015/02/suspending-rakudo-parrot/) by Patrick Michaud.*

At [FOSDEM 2015](https://archive.fosdem.org/2015/), Larry [announced](https://archive.fosdem.org/2015/schedule/event/get_ready_to_party/) that there will likely be a [Raku](https://raku.org/) release candidate in 2015, possibly around the September timeframe. What we’re aiming for is concurrent publication of a language specification that has been implemented and tested in at least one usable compilation environment — i.e., [Rakudo](https://rakudo.org/).

So, for the rest of 2015, we can expect the Rakudo development team to be highly focused on doing only those things needed to prepare for the Raku release later in the year. And, from previous planning and discussion, we know that there are three major areas that need work prior to release: the [Great List Refactor](APW2014-and-the-Rakudo-Great-List-Refactor) (GLR), Native Shaped Arrays (NSA), and Normalization Form Grapheme (NFG).

…which brings us to Parrot. Each of the above items is made significantly more complicated by Rakudo’s ongoing support for Parrot, either because Parrot lacks key features needed for implementation (NSA, NFG) or because a lot of special-case code is being used to maintain adequate performance (lists and GLR).

At present most of the current userbase has switched over to [MoarVM](https://moarvm.org/) as the backend, for a multitude of reasons. And more importantly, there currently aren’t any Rakudo or NQP developers on hand that are eager to tackle these problems for Parrot.

In order to better focus our limited resources on the tasks needed for a Raku language release later in the year, we’re expecting to suspend Rakudo’s support for the Parrot backend sometime shortly after the 2015.02 release.

Unfortunately the changes that need to be made, especially for the GLR, make it impractical to simply leave existing Parrot support in place and have it continue to work at a “degraded” level. Many of the underlying assumptions will be changing. It will instead be more effective to (re)build the new systems without Parrot support and then re-establish Parrot as if it is a new backend VM for Rakudo, following the techniques that were used to create JVM, MoarVM, and other backends for Rakudo.

NQP will continue to support Parrot as before; none of the Rakudo refactorings require any changes to NQP.

If there are people that want to work on refactoring Rakudo’s support for Parrot so that it’s more consistent with the other VMs, we can certainly point them in the right direction. For the GLR this will mainly consists of migrating parrot-specific code from Rakudo into NQP’s APIs. For the NSA and NFG work, it will involve developing a lot of new code and feature capabilities that Parrot doesn’t possess.
