# Rakudo milestones posted
    
*Originally published on [28 April 2008](https://use-perl.github.io/user/pmichaud/journal/36261/) by Patrick Michaud.*

Last week I heard that someone was having trouble finding the Rakudo sources, and it was suggested that blogging about it here might provide an additional pointer.  So, if you're looking for the sources to Rakudo Perl, it's currently held in the languages/raku/ directory of the Parrot repository.

Eventually Rakudo and other languages on Parrot will likely get separate repositories, but for now we all find it easier to keep everything in a single repository.

The architecture and layout of the Rakudo source code is described in docs/compiler_overview.pod.  This says what each source file does and how it all fits together.

Also, by popular demand, I've created a list of "milestones" for Rakudo Perl development and stuck them in the ROADMAP.  Reproducing the 2008-04-28 version here, we have:

* list context, list assignment
* return and control exceptions
* class, role, objects
* regex, token, rule, grammar
* selected libraries written in Raku
* modules
* junctions
* lazy lists
* slices
* multi sub & multi-method dispatch
* captures and signature handling
* operator overloading
* other S09 features (typed arrays, sized types)
* heredocs
* macros
* module versioning

While the milestones roughly in priority sequence, this list isn't meant to be rigid or strictly sequential in nature.  If someone wants to work on a later milestone even though we haven't completed the earlier ones, that's certainly okay.  This list just gives us a way to see where things are fitting in my head.

Suggestions and additions to the above list are welcome.
