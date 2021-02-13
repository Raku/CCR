# A roadmap for 6model and nqp-rx changes
    
*Originally published on [2010-09-11](https://6guts.wordpress.com/2010/09/11/a-roadmap-for-6model-and-nqp-rx-changes/) by Jonathan Worthington.*

So, I had a lovely vacation in Central Europe…

![Lovely Ljubljana](img_2173.jpg)

…and now it’s back to the hacking! :-)

While the eventual goal of [my current grant](http://news.perlfoundation.org/2010/07/hague-grant-application-meta-m.html) is, obviously, to deliver significant improvements to Rakudo, there are quite a lot of preliminaries that need to be taken care of first. My first steps have been to spawn a small research project in which I’ve done from-scratch prototype of how the Raku meta-model could look, plus a few things around it to be able to actually run some code. The project, named [6model](http://github.com/jnthn/6model/), currently consists of:

- A small .Net [“runtime layer”](http://github.com/jnthn/6model/tree/master/dotnet/runtime/) written in C#. It’s where I’ve been exploring a whole loading of things in relative isolation from the wider concerns of a runtime engine. Of note, it’s where I’ve implemented, or am implementing, research and exploratory versions of representation polymorphism, using pure prototypes to form a meta-model foundation, a cheaper way to handle lexicals than we currently have available in Parrot, boxing/unboxing, the revised multi-dispatch specification, a thread-safe and lock free multi-dispatch cache, native types and more.
- A [compiler](http://github.com/jnthn/6model/tree/master/dotnet/compiler/) for a tiny subset of NQP that runs atop of this runtime. Well, for a slightly wonky definition of subset: it actually already supports a few things that nqp-rx on Parrot is yet to do so – that’s kinda the point of the project at the moment. For those curious, it is actually compiling a PAST subset down to some C# code, through an intermediate DNST (DotNet Syntax Tree). Oh, and it’s actually written in NQP too. We’re much, much hacking off being at the point where we can bootstrap nqp-rx on a second VM, but one of the fruits of this research project is that we have the initial work towards that.
- An initial – but compiling and running – sketch of a  [low-level NQP Setting](http://github.com/jnthn/6model/blob/master/common/NQP/NQPSetting.pm). This is very, very different in nature from the current nqp-rx idea of an NQP Setting (and as such I’ll perhaps find a new name for it) in that it’s defining such low level things as our boxed low-level types and the coercion methods for moving between them. It also defines operators implementations in terms of multiple dispatch. You may also want to note the use of representation polymorphism.
- *mberends*++ has started porting my .Net work [to the JVM](http://github.com/jnthn/6model/tree/master/java/) and that also lives in the 6model repository.

So, that’s where things stand today. So where are we going from here? I’d like to break this down into two parallel tracks, both of which I’m going to be working a lot on in the coming weeks.

### The 6model Research Track

The 6model project has been highly valuable so far for exploring design, and there’s a few things I want to explore further in it. My main research tasks here over the coming weeks will be (this is a rough ordering):

1. Getting a working **and** efficient lexical multi-dispatch working, and integrating/testing the dispatch cache I recently committed
1. Work out how to do multi-method dispatch with the same kind of mechanism also
1. Some more bits to start supporting native attributes
1. Finish up Rakuopaque representation and support attributes in KnowHOWs
1. Start working towards running a very basic ClassHOW – that is, an implementation of classes

### The nqp-rx Track

Now that I’m increasingly happy with various parts of the model I’ve explored and evolved in 6model, it’s time to start bringing it to the Parrot implementation of nqp-rx, as a pre-requisite to bringing it to Rakudo. However, there are a couple of other things that I expect to do **first** in Parrot nqp-rx, simply because they are dependent on having a bootstrapped NQP to do them.

Here is a rough outline of how I expect things to go, though some of these may well be re-ordered and they’re also in places parallelizable. I’ve broken it down into phases. Note that if your eyes glaze over at some of the terminology, don’t worry – I’ll blog a lot more on the details of many of these in the future.

#### Phase 1: get classes and grammars using the new meta-model

- Port the meta-model core from C# to C. Of note, this means porting STable, the representations, KnowHOW and KnowHOWBootstrapper.
- Branch NQP and teach it about compiling KnowHOWs (actually, we can mostly crib this from the research compiler in 6model). Actually this probably means changing how it emits all packages, so from here on it we break NQP bootstrapping for a little while.
- Implement a KnowHOW called “NQPClassHOW”, which will be the implementation of classes on NQP. (If I’m feeling enterprising, I could write NQPRoleHOW and a composer at this point too, and thus give nqp-rx roles)
- Implement Raku style multi-method dispatch (we’ll need it even to get the stringification of type objects right, it turns out)
- Get attribute compilation smart enough to do optimized, indexed lookups rather than doing them all by name
- Switch Cursor and the regex classes away from Rakuobject to the new meta-model. This – after some hacking – should make grammars work with the new object model. We may end up porting more of them to NQP from PIR in the process, if convenient.
- Do the renaming hacking (if any) to regain our ability to bootstrap nqp-rx and pass its test suite. This means that the actions class as well as the grammar will now be using the new meta-model implementation. This will be a great milestone.

#### Phase 2: building meta-objects at compile time and supporting gradual typing

- The pre-requisite for this is having a way to take an object we make at compile time and have it serialized into a PBC file, along with the linkage so we can have inter-PBC references. This is a fairly low-level task and can be done by rolling our own or improving Parrot to be able to provide what is needed. It _is_ rather complex, but do-able. My next blog post will probably discuss this particular issue in much more detail.
- Switch to creating meta-objects (e.g. ClassHOW instances and type objects) at compile time, adding them to the list of things to serialize into the bytecode.
- Add a type attribute to PAST::Var nodes to reference the type object
- Get PAST::Compiler able to emit optimized method calls in the cases we know the type
- Work out a way for objects implemented using the new meta-model to provide methods that will handle Parrot v-table function calls

When we get to this point, we probably do have enough to start on getting Rakudo to use the new meta-model. However, it’s not the end of the changes that I think we’ll really want; next comes:

- Implement Raku style multiple dispatch for subs in nqp-rx. (I don’t expect that objects making use of the new Raku meta-model are going to play with Parrot multi-dispatch, but I’d rather fix that by nqp-rx adopting Raku multiple dispatch semantics. NQP is, after all, meant to be a subset.)
- Switch the PAST hierarchy to use the new meta-model, and also re-write PAST::Compiler in NQP so we can take advantage of the gradual typing stuff.

Looking a little further down the road (quite probably beyond getting my current grant done unless this suddenly becomes important), I also somewhat expect that nqp-rx may switch away from using Parrot’s String/Integer/Float/ResizablePMCArray  PMCs to using real objects implemented in a low-level setting, using  representation polymorphism, as shown in the example I linked earlier. That would further entail switch all operators over to be Raku multi-dispatch subs. Rakudo  has already done the latter and will certainly do the former in the new  meta-model implementation. But it could well make a lot of sense –  especially from a semantics and portability angle but maybe also a  performance and usability one – to do this in NQP too.

So when will the nqp-rx branch that all this will take place in get merged (or possibly just become master)? Well, the answer is “probably not until Rakudo itself has evolved far enough to work on it”. This is going to entail a Rakudo branch, targeting an nqp-rx branch, for a while until we’re ready to switch them both.

This is, really, the same kind of depth of change as when we went from the first NQP implementation to nqp-rx. I’m not saying that we’ll end up with the mass regressions seen in Rakudo that were a necessary part of that process – I expect to pull this off with very little of that, simply because the nature of the changes here are very different.  But a lot of things are going to look quite different after this process, and it’s not going to be without some pain. It is, however, a critical part of the path on the way towards Rakudo being a high quality Raku implementation, and NQP and the compiler tools surrounding it being a high quality tool chain for implementing a language atop of a VM.
