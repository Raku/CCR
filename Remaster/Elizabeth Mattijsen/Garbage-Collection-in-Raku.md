Garbage collection in Raku
==========================

*Originally published on [16 August 2018](https://opensource.com/article/18/8/garbage-collection-perl-6) by Elizabeth Mattijsen.*

In the [first article](Migrating-Perl-code-to-Raku.md) in this [series on migrating Perl code to Raku](Migrating-to-Raku-Series.md), we looked into some of the issues you might encounter when porting your code. In this second article, we’ll get into how garbage collection differs in Raku.

There is *no* timely destruction of objects in Raku. This revelation usually comes as quite a shock to people used to the semantics of object destruction in Perl. But worry not, there are other ways in Raku to get the same behavior, albeit requiring a little more thought by the developer. Let’s first examine a little background on the situation in Perl.

Reference counting
------------------

In Perl, timely destruction of objects “going out of scope” is achieved by [reference counting](https://en.wikipedia.org/wiki/Reference_counting). When something is created in Perl, it has a reference count of 1 or more, which keeps it alive. In its simplest case it looks like this:

```` perl
# Perl
{
    my $a = 42;  # reference count of $a = 1, because lives in lexical pad
}
# lexical pad is gone, reference count to 0
````

In Perl, if the value is an object (aka blessed), the `DESTROY` method will be called on it.

```` perl
# Perl
{
    my $a = Foo->new;
}
# $a->DESTROY called
````

If no external resources are involved, timely destruction is just another way of managing memory used by a program. And you, as a programmer, shouldn’t need to care about how and when things get recycled. Having said that, timely destruction is a very nice feature to have if you need to deal with external resources, such as database handles (of which there are generally only a limited number provided by the database server). And reference counting can provide that.

However, reference counting has several drawbacks. It has taken Perl core developers *many* years to get reference counting working correctly. And if you’re working in [XS](https://en.wikipedia.org/wiki/XS_%28Perl%29), you always need to be aware of reference counting to prevent memory leakage or premature destruction.

Keeping things in sync gets more difficult in a multi-threaded environment, as you do not want to lose any updates to references made from multiple threads at the same time (as that would cause memory leakage and/or external resources to not be released). To circumvent that, some kind of locking or atomic updates would be needed, neither of which are cheap.

> Please note that Perl ithreads are more like an in-memory fork with unshared memory between interpreters than threads in programming languages such as C. So, it still doesn’t need any locking for its reference counting.

Reference counting also has the basic drawback that if two objects contain references to each other, they will never be destroyed as they keep each other’s reference count above 0 (a circular reference). In practice, this often goes much deeper, more like `A -> B -> C -> A`, where A, B, and C are all keeping each other alive.

The concept of a *weak reference* was developed to circumvent these situations in Perl. Although this *can* fix the circular reference issue, it has performance implications and doesn’t fix the problem of having (and finding) circular references in the first place. You need to be able to find out *where* a weak reference can be used in the best way; otherwise, you might get unwanted premature object destruction.

Reachability analysis
---------------------

Since Raku is multi-threaded in its core, it was decided at a very early stage that reference counting would be problematic performance-wise and maintenance-wise. Instead, objects are evicted from memory when more memory is needed *and* the object can be safely removed.

In Raku you *can* create a `DESTROY` method, just as you can in Perl. But you *cannot* be sure when (if ever) it will be called.

Without getting into [too much detail](https://github.com/MoarVM/MoarVM/blob/master/docs/gc.markdown), objects in Raku are destroyed only when a garbage collection run is initiated, e.g., when a certain memory limit has been reached. Only then, if an object cannot be reached anymore by other objects in memory *and* it has a `DESTROY` method, will it be called just prior to the object being removed.

No garbage collection is done by Raku when a program exits. Applicable [phasers](https://docs.raku.org/language/phasers) (such as `LEAVE` and `END`) *will* get called, but no garbage collection will be done other than what is (indirectly) initiated by the code run in the phasers.

If you always need an orderly shutdown of external resources used by your program (such as database handles), you can use a phaser to make sure the external resource is freed in a proper and timely manner.

For example, you can use the `END` phaser (known as an `END` block in Perl) to disconnect properly from a database when the program exits (for whatever reason):

```` raku
# Raku
my $dbh = DBIish.connect( ... ) or die "Couldn't connect";
END $dbh.disconnect;
````

Note that the `END` phaser does not need to have a block (like `{ ... }`) in Raku. If it doesn’t, the code in the phaser shares the lexical pad (lexpad) with the surrounding code.

There is one flaw in the code above: If the program exits *before* the database connection is made or if the database connection failed for whatever reason, it will *still* attempt to call the `.disconnect` method on whatever is in `$dbh`, which will result in an execution error.  There *is* however a simple idiom to circumvent this situation in Raku [using `with`](https://docs.raku.org/syntax/with%20orwith%20without).

```` raku
# Raku
END .disconnect with $dbh;
````

The postfix `with` matches only if the given value is defined (generally, an instantiated object) and then topicalizes it to `$_`. The `.disconnect` is short for `$_.disconnect`.

If you would like to have an external resource clean up whenever a specific *scope* is exited, you can use the `LEAVE` phaser inside that scope.

```` raku
# Raku
if DBIish.connect( >.. ) -> $dbh {
    LEAVE $dbh.disconnect;  # no need for "with" here
    # do your stuff with the database
}
else {
    say "Could not do the stuff that needed to be done"
}
````

Whenever the scope of the `if` is left, any `LEAVE` phaser will be executed. Thus the database resource will be freed whenever the code has run in that scope.

Summary
-------

Even though Raku does not have the timely destruction of objects that Perl users are used to, it *does* have easy-to-use alternative ways to ensure management of external resources, similar to those in Perl.
