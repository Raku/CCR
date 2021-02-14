# This week: too little sleep and too little Raku
    
*Originally published on [2015-08-01](https://6guts.wordpress.com/2015/08/01/368/) by Jonathan Worthington.*

This report covers the week starting the 20th July – which turned out to be the week I had to finish preparing course material and labs for one of Edument’s new courses. That managed to swallow most of the week, so only a handful of Raku things got done. Happily, August is free of any teaching and authoring responsibilities, and will be dominated with Raku work.

### Digging into multi-dimensional arrays in Raku

I started a Rakudo branch to work on the multi-dimensional array support, and made various decisions about how things will work. I got some way into the changes to Array itself (and had it basically working provided you worked in terms of the `*-POS` API directly), and started to look at the ways the slicing implementation will need to change to pass multiple dimensions along (so you’ll actually be able to do the access with `[…]` as you’d expect).

### Banning confusion

I took on one of the oldest RTs in the queue, which wished for there to be a compile time error on:

```` raku
say $*a; my $*a;
````

There’s long been one on:

```` raku
say $a; my $a;
````

Basically, it catches use-before-declaration confusion (since the declaration happens at compile time). The second case is clear cut; the first is less so as it involves a dynamically scoped variable and so we’re naturally a bit looser about those. But after a little discussion, *Larry* said he’d like to outlaw the first just like the second if it wasn’t too hard to implement. I took a look at the code, decided it wasn’t too bad at all, and fixed it.

### Unblocking the release

During the preparation for the 2015.07 release, somebody noticed a regression in reporting “return outside of routine” errors, that the tests had missed. I jumped in to get it fixed up, and added a better test so we don’t bust it again.

### This week’s token regex engine patches

I fixed RT #125648 (no syntax error for /00:11:22/), as well as looking into RT #77524 (Rakudo treated /a:/ as legal syntax and STD did not; it turns out Rakudo was right on this one).

### Other bits

- Fix RT #125642 and RT #121308 (traits expecting types didn’t report bad type or make suggestions)
- Analyze RT #125634 and get it down to a much smaller example of what’s wrong; no fix yet
