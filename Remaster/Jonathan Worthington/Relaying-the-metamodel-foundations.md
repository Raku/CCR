# Relaying the metamodel foundations
    
*Originally published on [5 November 2009](https://use-perl.github.io/user/JonathanWorthington/journal/39844/) by Jonathan Worthington.*

It's taken me pretty much a whole Rakudo day to figure out how to go about the package declarator support in the ng branch, but I think it's been worth it. The result is not only a design, but some initial code that starts to re-build our classes and modules support in terms of it.

There are a couple of big things to take away from this. The first is that we're going to have the vast majority of things in place for custom meta-classes when the ng branch merges. This is something we were rather more distant from in master, and something that people were hoping we'd get in place by Rakudo \*, so I'm glad that we're going to be getting most of the way there on this. The really big deal here is that we're getting rid of a lot of stuff where things "just worked somehow" and re-building it all on top of calls to the meta-class. We're re-building how stuff happens with the new grammar and actions anyway, so it is a fitting time to get it in place.

So what are your options if you want to write a custom metaclass? First, you go and write the class - possibly subclassing one of the existing built-in metaclasses if you just want to do some small customization (for example, I expect `GrammarHOW`, the metaclass for `grammar` packages, will just be a very simple subclass of `ClassHOW` that at class composition time checks if we have a parent and if not makes `Grammar` the default parent rather than `Any`, then delegates to the super class). Second, you declare a sub-language and introduce a new package declarator to the grammar; if we want to support "controller" we'd add something a rule to our sub-language like:

```` raku
token package_declarator:sym<controller> {
    :my $*PKGDECL := 'controller';
    <sym> <package_def>
}
````

Note that you're actually adding a new type of package to the language here that will be associated with your metaclass. So how do we make this association? There's a context variable `%*HOW` which contains the mapping from the value set in `$*PKGDECL` to the name of the metaclass to use. You'll notice this means that we could actually just want our controller keyword for documentation, and just map it straight through to `ClassHOW`, and not write a metaclass, or we can associate multiple package declarators with the same metaclass.

While this covers the common cases, there's a few times where we need to do some slightly different code generation in terms of different packages. There's some hooks for this too, and while those will not be spec, but rather Rakudo specific, it does mean that the overall implementation will get a lot cleaner, with the Actions.pm file that maps parse tree to abstract syntax tree now not having to know the details of different types of package.

Already it feels a lot cleaner with the few bits that are in place so far, and I think as we start to build out on top of this, it's going to lead to something that overall is a lot less magical, and a lot more maintainable and extensible, than what we had before. All of which make a pause for thought, rather than a charge into the code, very much worthwhile. Thanks to Vienna.pm for making it possible for me to take the time to do these things. :-)
