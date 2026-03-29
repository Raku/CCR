# Macros: nesting macros
    
*Originally published on [14 October 2014](http://strangelyconsistent.org/blog/macros-nesting-macros) by Carl Mäsak.*

Some features that the program author wants to implement need to straddle more than one macro. A common relationship between macros seems to be the outside-inside relationship.

AngularJS has this feature. When you declare directives (which can then act as elements or attributes in your application HTML), one directive can declare that it needs another one around it to function using the `require` option. See [this example](https://github.com/angular-ui/bootstrap/blob/master/src/tabs/tabs.js#L184) from UI Bootstrap, with `<tabset>` being the outer directive, and `<tab>` the inner.

There are two important parts of this feature:

- **Validation**

It doesn't make sense to have a tab outside of a tabset, and the framework makes sure that doesn't happen.

- **Sharing**

In the `compile` function later, each tab has access to their parent tabset controller and call methods on it (`.select` and `.removeTab`). The HTML structure of directives maps into an object graph where the children have access to their parent.

(Further down in that example, there's even a `tabHeadingTransclude` directive which nests inside `tab`. That is, a directive can be both a child and a parent. Though the `tabHeadingTransclude` is so simple that it only requires the inclusion for the "validity" reason above, not for "sharing".)

## Meanwhile, in Raku macros

I believe this feature is something that macro authors will want, and find useful. I think macros will end up working in groups like this sometimes, and by far the most common way to group things will be the parent/child relation. (Or ancestor/descendant, to be exact. Hm. Some things will want to be tightly nested with no stuff in between parent and child; other things will be more lenient.)

One example that's already in Raku: `given` and `when`.

```raku
given $food {
    when /pie/ { say "mm, pie" }
    default { say "waiter, could you send in some pie?" }
}
```

Actually, what Raku requires in this case is that the `when` (and `default`) find itself lexically inside a *topicalizer block*, not necessarily a `given`. So this is fine:

```raku
for @foods {
    when /pie/ { say "mm, pie" }
    default { say "waiter, could you send in some pie?" }
}
sub review-food($_) {
    when /pie/ { say "mm, pie" }
    default { say "waiter, could you send in some pie?" }
}
```

Which indicates that in some cases, the child macro might want to specify that it wants to be the child of (semantically) an `any` junction of parent macros.

Note that this example does not extend to the following likely parent/child constructs, which are too dynamic in nature and therefore the domain of the runtime rather than the compiler.

- `gather` and `take```
- loops and `next`/`last`/`redo```
- routines and `return```

## How about a more DSL-y example?

I went hunting for a good example of this, preferably one that exists already. I guess [my DSL advent post](http://rakuadvent.wordpress.com/2012/12/20/day-20-dynamic-variables-and-dsl-y-things/) is one. It does illustrate both the "validity" and "sharing" benefits. But I feel I need another example.

Let's imagine a DSL for making database transactions.

```
transact $conn {
    # do some queries
    # change stuff around in several steps
    rollback
        unless $success1;
    # more changes
    rollback
        unless $success2;
    commit;  # this would probably be optional at the end, though
}
```

I like this example more than the one in the advent post, because the parent macro `transact` and the child macros `rollback` and `commit` are collaborating on a type of data very central to the language itself: control flow. In the sense that we want a `commit` or `rollback` to also exit the `transact` block.

That makes the example feel *real* to me. Likely the mechanism for this would be `transact` setting up a custom handler, and `commit` and `rollback` throwing (control) exceptions with different cargo.

This type of examples inhabits a Goldilocks zone where the macros have to be not-too-simple (because then a frothy mix of subs, dynamic variables, and exception handling would work), but also not too much like a proper language (because then slangs would rush in and soak up the use cases). I think any more complicated than this and it'd be a slang. In fact, I don't mind if there's a nice, sliding scale, so that you can essentially evolve a cluster of macros of this type into a slang if you want.

## Grammars do it bottom-up

I don't know what to make of the fact that in our Raku grammars we've ended up with a solution where

- Most of the time we rely on rules firing in tree traversal post-order (with inner rules firing before outer ones, and the action methods firing at the same time). Which means that a parent or ancestor will have all the information of its children or descendants.
- In the cases where we *do* want to carry information downwards, we tend to declare a dynamic variable on parent rule entry, and then access that dynamical from the child rules.

Parsing is different from macros, so maybe it's fine. But by current design, macros can *neither* reach downwards to their macro children or upwards to their macro parents. And I just find it a bit odd that the design I find natural with macros (children declaring their need for/communication with parents) runs counter to the design we find useful in grammars (parents grabbing information from children by default).

I notice that I am confused. ☺

## Implementation

Remember, ["generate, analyze, and typecheck"](Macros-progress-report-after-a-long-break.html). The thing I'm suggesting here falls under "analyze", because we mainly want to introspect/read the program structure, and communicate things across it. Maybe the "validation" requirement falls under "typecheck".

Anyway, I fully expect there to be a general framework through which macros could do this the "hard way":

- Walk up the Q-tree to make sure that their parent macro is there, in place.
- When it finds it, ask the Q-tree node for the parent macro's home address, so that they two can interact.

(Hm. Will parent macros therefore leave a detectable trace of themselves in the Q-tree? Probably. I half-expected macros to desugar into more primitive types of nodes. But maybe parent macros are an exception, since they want to be found. Or they desugar to something primitive, like a block, but it's marked up in a standard way, with a `once I was a macro` symbol.)

What I'm proposing here is basically just sugar, for people writing the macros, to set up this relationship between parent and child the "easy way":

```raku
macro transact($conn, $block) { # TTIAR, but see separate post
    # ...
}
macro `commit` is inside(&transact) { #`[...] }
macro `rollback` is inside(&transact) { #`[...] }
```

This is enough to declare the relation between the macros. There also needs to be a mechanism to get the object representing the actual callsite of the macro call. That's the one in our example that would hold `$conn`. In the worst case, we could fall back on asking about this through a namespace or global object somehow. There may be a cuter/saner way that I'm missing right now. Either way, it's possible.

## Not addressed by this proposal

Identified in a [previous post](Macros-progress-report-after-a-long-break.html).

- The `{{{ }}}` syntax being universally hated
- Quasi slices only being usable in term position
- Macro parameters/operands being restricted to expressions
- Manipulexity of program elements
