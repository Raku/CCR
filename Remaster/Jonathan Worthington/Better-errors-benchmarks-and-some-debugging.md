# Better errors, benchmarks and some debugging
    
*Originally published on [16 May 2009](https://use-perl.github.io/user/JonathanWorthington/journal/38983/) by Jonathan Worthington.*

Up until today in Rakudo, when your program failed in some way, the errors were not too helpful because they missed a line number and file name that related to the original source code; instead, it told you about a position in the generated intermediate code. Various of us (*pmichaud*++, *Tene*++, *me*++) have been doing bits to get us towards being able to show line numbers at the Perl level rather than in the Parrot Intermediate Code. Today I coded up one of the final bits, and things are looking better. If you have for example this program:

```` raku
class A {
    method b {
        die "OH NOES I HAS A FAIL"
    }
}
sub bar {
    A.new.b;
}
sub foo {
    `bar`
}
`foo`;
````

Will now fail with:

```` raku
OH NOES I HAS A FAIL
in method A::b (crash.p6:3)
called from sub bar (crash.p6:7)
called from sub foo (crash.p6:10)
called from Main (crash.p6:12)
````

Which is rather more helpful. I was about to commit it just with line numbers, when *pmichaud* flew in with a quick patch to emit annotation directives for filenames too. So now we report both. Yay.

While I was working in the area, I also dealt with a ticket about our previously less than wonderful error if you did a return outside of a routine. We now say that, rather than the more cryptic "no message and no handler" that we gave before.

One of the most exciting happenings in Rakudo over the last few days is that *pmichaud*++ added support for overloading and defining new operators. Hopefully he'll have a moment to blog a little about that. *Tene*++ then allowed for defining [custom circumfix operators](http://blogs.gurulabs.com/stephen/2009/05/new-toys-in-perl-6-custom-ops.html). Today *ruoso* tried to define a (non-custom - I didn't figure out how to do custom ones of those yet) `method postcircumfix:<{ }> { }`, but that didn't work out too well. I added support for the postcircumfix category, but it still didn't work, at which point I discovered that methods hadn't quite caught up with routines yet in the world of op definition. A couple of lines later and then I had this running:

```` raku
class Foo {
    method postcircumfix:<{ }> ($name) { say $name }
}
Foo.new<abc>; # abc
````

One of the things we're noticing more and more with Rakudo as we add more features and need to run more tests is that it is, well, slow. Part of it is the parsing speed for sure, but a decent bit of it is at runtime too. Today I wrote and checked in some micro-benchmarks for some very specific language features that are heavily used in Raku (multi-dispatch, method dispatch) as well as checking startup time. I'm thinking that I may set these up to run regularly and graph the results over time so we can track - just as we do with passing spectests - when we do stuff that hurts performance and when we do stuff that improves it (not just when we're expecting it, but when something has an unexpected effect).

Along the way, I managed to do a small tweak to signature binding that got us a 7% performance win. However, it's a drop in the ocean compared to the gains we need. Signature binding right now is, bluntly, a pig - and Parrot's not exactly stellar calling performance doesn't do us any favors either. I was fairly happy to see that multi-sub dispatch was only slightly less performant (10% worse) compared to single-sub dispatch. And that's using a dumb multi-dispatch type cache that I threw together in an afternoon.

Rakudo is now living in its own HLL-space in Parrot, which means there's now opportunity to fix a few things up. Some things - like conflicts with Parrot built-in classes - just went away as a result of this, so I closed those tickets in RT. The first one I want to take on is avoiding re-blessing Parrot multis into Raku multis to get the correct dispatch semantics. However, that has the upshot that we need to consistently use Raku multi-dispatch everywhere now. This is going to take some work, so I created a branch, ripped out all of the re-blessing stuff, added the HLL-mapping. So far we don't even make it through the compile, let alone any tests. But it's started, and by the end of it we'll have got all of the operators running off proper Raku dispatch semantics, fix some of the overloading problems we have, get to rip out the special-case junction operator code and shave a bit off our startup time too. So, some effort, but an overall win once it's done.

I finished up the day trying and failing to track down a really weird issue. *mberends*++ has done some great work on `Temporal`, the date/time handling support in Raku. He'd got something running just fine under Rakudo, but trying to add it to the setting led to the stage 1 compiler hanging. Even more odd, however, was that compiling that file alone with the stage 1 compiler worked - it was just when we tried it added into the concatented setting that it failed. Removing some things seemed to help, but I didn't find a pattern, nor did I see anything that looked like it could obviously cause such an issue. So, color me confused. Very confused. Will be interesting - and probably very annoying - to get to the bottom of this one, but a couple of hours of trying later I'm stumped. Such are some problems.

Thanks to Vienna.pm for funding this Rakudo Day.
