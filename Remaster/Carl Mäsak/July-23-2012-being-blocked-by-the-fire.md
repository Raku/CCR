# July 23 2012 — being blocked by the fire
    
*Originally published on [23 July 2012](http://strangelyconsistent.org/blog/july-23-2012-being-blocked-by-the-fire) by Carl Mäsak.*

Well, this is amusing. I hurried through catching up after my strangely
energy-deficient yesterday by

- [allowing a nicer syntax](https://github.com/masak/crypt/commit/2656ea529f4bc81473c67be1d16ccfadf98893b9) when moving disks

- [adding some response](https://github.com/masak/crypt/commit/3d9700e1657a0a8e89c991e38fc816189920759f) to the CLI when the player moves a disk

- [causing the floor to tilt appropriately](https://github.com/masak/crypt/commit/69d6d841ae49c81160b91e45d12da9075740cf36) when the hanoi game is solved and re-unsolved, respectively

- [even adding a test](https://github.com/masak/crypt/commit/1df2f524eead44c646574ebaf356add7d98fb9c3) after the fact to make sure the whole sequence works,

and I was just poised to implement today's functionality &mdash; that of the
player being blocked by the fire when trying to walk northwest in the cave
&mdash; but it was already implemented!

```
> down
Cave
This is a perfectly cylindrical chamber. An oversized fire-pit takes up most
of the floor space in the middle of the room. Ancient runes run along the
circumference of the wall. It's hot and stuffy.
You can go northwest and up.
> northwest
You try to walk past the fire, but it's too hot!
```

Huh!

It was me. On [July 8](July-8-blocked-exits.html), with a blog post
starting with this paragraph:
  
> I don't quite remember what I meant by "blocked exits" when I wrote the month plan... But let's improvise! Way I see it, it can mean two things. So we'll do them both today.

I love it when people steal my TODO items. Even if it's a younger version of
myself. Thank you masak-of-July-8! I was a bit behind today, and it's nice of
you to help me out. 哈哈

Today I have total confirmation of what was meant to become evident already
yesterday according to the schedule. The Hanoi game fits. It doesn't just fit
fairly well; it fits like a hand in a glove. It integrated right in. Events are
good "joints" for the application to flex with. Now I can say with the
authority of experience: events rock. Use them.

Tomorrow we'll go for some water.
