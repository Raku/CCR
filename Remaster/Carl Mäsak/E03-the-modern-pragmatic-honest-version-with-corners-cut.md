# E03, the modern, pragmatic, honest version, with corners cut
    
*Originally published on [20 February 2010](http://strangelyconsistent.org/blog/e03-the-modern-pragmatic-honest-version-with-corners-cut) by Carl Mäsak.*

I was a bit optimistic with time. So what else is new.

Anyway, various distractions such as $WORK kept interrupting my translation of E03 today, but now I've finally got it all ported to modern Rakudo-Raku. [Here it is](https://gist.github.com/masak/309333). Two biggish things remain:

- I haven't tried running the code. I'm pretty sure it won't run on the new Rakudo master yet. But I've written it with alpha (the old development branch) in mind, and it should run there.
- 
I haven't looked at [SF's E03 translation](https://lastofthecarelessmen.blogspot.com/2010/02/e03-first-stab.html) yet. (Yes, I'm linking to a blog entry which I haven't read yet.) I saw that the title of his post is "first stab", which makes me feel a little better.

Here are a few random comments about the code. 
- The original code in E03 is the strangest example code I've ever read. All due props to Damian, but... quod? A program whose task it is to "locate a particular data file in one or more directories, read the first four lines of each such file, report and update their information, and write them back to disk"? Come again? (My suspicion is that this was the program arrived at by simply cramming in as much of A03 as possible into the same piece of code, but nevermind.)
- A few nice things are still missing from Rakudo. The `s{}{}` syntax is the last still unimplemented request in an [old blog post](Rakudo-good-cool-awesome-bad-ugly-weird.html) of mine. It'd be pretty nice to have. I think we'll have it soon, thanks to ng.
- You can't open files `rw` in Rakudo. Then again, you can't `seek` or `truncate` them either, so I guess opening them `rw` wouldn't make much sense anyway. Due to this, I had to work around a central part in the program, where filehandles were stored in a hashtable, to be read from in one subroutine and written to in the next one. Had to store the filenames instead, and re-open the files for writing.
- We don't have the `:r` and `:w` filetests yet, but `:e` and (strangely enough) `:s` are implemented. Someone with tuits should really do `:r` and `:w`.
- A fair amount of the updates in E03 are out-of-date. I guess operators and related things are an area where Raku really has evolved a lot in the past few years, or even in the past year. As I speak, the exact semantics for `infix<...>` is still being discussed on #raku.
- When I say things have changed around a lot, I should really mention that I say that with a sort of relief of the sort that means "gee, I'm glad we didn't stick to what we thought we wanted back then!". Things have, by and large, improved greatly. I actually hope to write more about that.

This exigesis-modernising is kinda fun! Now I'm eager to go read what *SF*++ has been up to.
