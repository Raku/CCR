# Planning for my Hague Grant
    
*Originally published on [11 December 2008](https://use-perl.github.io/user/JonathanWorthington/journal/38073/) by Jonathan Worthington.*

Yesterday I was delighted to hear that my request for a Hague Grant to work on various aspsects of Rakudo has been [accepted](http://news.rakufoundation.org/2008/12/jonathan_worthingtons_hague_gr.html). *Jesse* asked me to blog a project plan, and this post is my attempt at that. It's not going to be exhaustive and detailed everywhere, especially because some parts of this involve me working out how to do things rather than just doing them, and thus I don't know the exact details of all that has to be done yet. I'm going to break this down into what I hope to achieve over the three months this grant is scheduled for - this one and the next two.

## December
This month from an implementation angle will be mostly about getting us registering symbols in the namespace at compile time and then reaping the various benefits of doing so. Thus a (probably quite complete) list of the implementation tasks will be:

- Modifications to Rakudo actions/guts so that we registering classes, roles, subset types and routines in the namespace as we are compiling. These will be stub insertions that will be replaced by the Real Thing once we have it.
- Switching us to really do `use` at compile time; last time I tried this, it broke things in pre-compiled modules, but now this needs to be figured out properly.
- Elimination of the hack that restricts us to using only type names that start with an uppercase character.
- Fix up nested classes and namespaces - this isn't really needed here, but I'd rather do it now to make sure we get the things that follow correct.
- Detection at compile-time of re-declaration of symbols and giving of errors in such situations.
- Make a `proto` being in scope make all other subs/methods without a plurality declarator be multis.
- Make a `proto` in a class turn any non-multis on roles that the class does also be multis if they were not declared that way (but see below for "only" caveat).
- Detection of `only` conflicting with `multi` and reporting of such errors.

I will also be spending some time thinking through various issues and doing some design work, to see how I'm going to do various things. Of note I want to spend time pondering:

- How dispatch is going to look. I have a lot of ideas here, many discussed with *Patrick* already. But we need to be in line with the metaclass interface too (which needs to make it into S12). Basically I just need to spend some time working out all of the requirements and then trying to come up with the Right Solution.
- Class construction/build things.
- Representation of parametric types, in signatures and elsewhere. We will want to be able to introspect them, enforce them, and so on.

## January
In this month I plan to do two of the big changes/refactors and start building some stuff around them. The first will be changes to the dispatcher. The second will be refactoring roles to handle parameters, and the selection of what role to do based upon a multiple dispatch on the provided parameters. Since the design work this month will determine exactly what tasks will be needed, I'll instead list the things that I will expect to work by the end of the month.

- Working submethod dispatch.
- Junctions are handled in the dispatcher for both single and multiple dispatch (built-ins by this stage will be done in the Raku prelude, so the special-case code that makes Junctions kinda work for operators now can be removed).
- Declaration of roles with parameters.
- Ability to specify values for those parameters when doing the role and ending up with the correct role being done, both for compile time composition and runtime mix-in.

And some nice-to-haves that can slip to February if needed will be:

- Complete filling out the various other cases of the handles `trait` verb.
- Test cases for writing a different dispatcher in a meta-class, to check that we've done it right (note that this means implementing knowhow, which isn't really part of this grant, but I do hope to have done this by January).

## February
This month the nice-to-haves from January must be completed if they weren't already. The rest of the work will focus on parametric roles. Of note, by the end of this month, and thus the grant, I expect the following to work.

- Ability to and use parameters passed to a role when deciding to do it in the role body.
- The `of` keyword for declaring parametric types, e.g. `List of Int`.
- Typed arrays and hashes implemented using parametric roles, usable and working.
- Declaring an `of` type for subroutines.

## Extra Notes
There is a plan to create a Synopsis 14 that focuses on generics/type parameterization. Since I will be reviewing all of this material and will probably have some clarifications to seek/make and various things to flesh out, I plan to talk with Larry about me producing a draft of this as I am working on the grant.

So, to work I go!
