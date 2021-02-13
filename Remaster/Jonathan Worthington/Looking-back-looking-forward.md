# Looking back, looking forward
    
*Originally published on [2012-01-15](https://6guts.wordpress.com/2012/01/15/looking-back-looking-forward/) by Jonathan Worthington.*

So, 2012 is here, and here’s my first Raku post of the year. Welcome! :-)

### Looking Back

2011 brought us a faster Rakudo with vastly improved meta-programming capabilities, the first work on exploring native types in Raku, the start of a powerful type-driven optimizer and many other bits. It also took me to various conferences and workshops, which I greatly enjoyed. I’d like to take a moment to thank everyone involved in all of this!

This was all great, but slightly tainted by not managing to get a Rakudo Star distribution release out based on a compiler release with all of these improvements. I’d really hoped to get one out in December. So what happened? Simply, there were a certain set of things I wanted to get in place, and while many of them got done, they didn’t all happen. While the compiler releases are time based – we do one every month – the distribution releases are more about stability and continuity. By the time I headed back to the UK to spend Christmas with family, we were still missing a some things I really wanted before a Star release was done. Given the first thing that happened when I started relaxing a little was that I immediately got unwell, I figured I should actually use my break as, well, a break – and come back recharged. So, I did that.

### So, let’s try again

So, the new goal is this month. I’m happy to report that in the week since I’ve got back to things, one of the things I really wanted to sort out is now done: `Zavolaj`, the native calling library, now does everything the pre-6model version of it did. In fact, it does a heck of a lot more. It’s even [documented now](https://github.com/jnthn/zavolaj/blob/master/README.markdown)! It’s also far cleaner; the original implementation was built in the space of a couple of days with *mberends*++ while I was moving apartment, and was decidedly hacky in places. The missing bits of the `NativeCall` library were important because they are depended on by MiniDBI, and I really didn’t want to ship a Rakudo Star that can’t connect to a database. So, next up is to make sure that is in working order. I’m not expecting that to be difficult.

That aside, there were some things to worry about in Rakudo itself. I’ve dealt with some of those things in the last week, and perhaps the one important remaining thing I want to deal with before Star is a nasty regex engine backtracking related bug (I’ve been hoping *pmichaud*++, the regex engine guru, might appear and magic it away, but it seems it’s going to fall on my plate). But overall, we’re well on track to cut the Star release this month.

### What’s the direction for the year ahead?

During 2011, Rakudo underwent a significant overhaul. It was somewhat painful, at times decidedly not much fun, but ultimately has been very much worth it: many long standing issues have been put to rest, performance has been improved and many things that were once hard to do are now relatively easy or at least accessible.

I think it goes without saying that we won’t be doing any such wide-ranging overhaul in 2012. :-) The work in 2011 has opened many doors that we have yet to walk through, and 2012 will see us doing that.

At a high level, here’s what I want:

- **Less bugs, more stability:** mostly this is about continuing to work through the ticket queue and fix things, adding tests as bugs are fixed to ensure they stay fixed.
- **Better error reporting:** there are things in STD, the Raku standard grammar, that allow it to give much more informative error reports on syntax errors than we often can in Rakudo today. I want us to bring these things into Rakudo. Additionally, there’s plenty of improvements to be made in runtime errors. Furthermore, I want to expand the various bits of static analysis that I have started doing in the optimizer to catch a much wider range of errors at compile time.
- **Run programs faster:** this process is helped by having decent profiling support these days. There’s a lot more to be done here; the optimizer will help, as will code generation improvements.
- **Compile programs faster:** this will come from more efficient parsing and greatly improving the quality of the code NQP generates (NQP is the language we write much of the compiler in)
- **Shorter startup time:** this mostly involves finishing the bounded serialization work up. I think the best way to describe this stuff is “fiddly”.
- **Use less memory:** Rakudo has got faster in no small part thanks to being able to understand its performance through profiling. Our understanding of its memory consumption is much more limited, which makes it harder to target improvements. That said, I’ve some good guesses, and some ideas for analyzing the situation.
- **More features:** while being able to do the things Rakudo can do today faster and with less bugs would give a very usable language for quite a lot of tasks, there’s still various features to come. In particular, Rakudo’s support for S05 and S09 needs work.
- **VM Portability:** we’ve made good progress towards being able to make a serious stab at this over the last year, while at the same time also managing to perform vastly better on Parrot too. With help from *kshannon*++, I’m currently working on completing the switch to QRegex (a regex engine with NFA-powered LTM, and written in NQP rather than PIR), which should carry on a pattern of simultaneously increasing performance and portability. Beyond that will be an overhaul of our AST and code generation, with the same goal in mind.

So, lot’s of exciting things coming up, and I look forward to blogging about it here. :-)

### A way to help

There are many ways to get involved, depending on what you’re interested in. One way is to take a look at our [fixed bugs that need tests writing](https://rt.perl.org/rt3/Search/Results.html?Rows=50&Page=1&Format=%27%20%20%20%3Cb%3E%3Ca%20href%3D%22%2Frt3%2FTicket%2FDisplay.html%3Fid%3D__id__%22%3E__id__%3C%2Fa%3E%3C%2Fb%3E%2FTITLE%3A%23%27%2C%0A%27%3Cb%3E%3Ca%20href%3D%22%2Frt3%2FTicket%2FDisplay.html%3Fid%3D__id__%22%3E__Subject__%3C%2Fa%3E%3C%2Fb%3E%2FTITLE%3ASubject%27%2C%0A%27__Status__%27%2C%0A%27__QueueName__%27%2C%0A%27__OwnerName__%27%2C%0A%27__Priority__%27%2C%0A%27__NEWLINE__%27%2C%0A%27%27%2C%0A%27%3Csmall%3E__Requestors__%3C%2Fsmall%3E%27%2C%0A%27%3Csmall%3E__CreatedRelative__%3C%2Fsmall%3E%27%2C%0A%27%3Csmall%3E__ToldRelative__%3C%2Fsmall%3E%27%2C%0A%27%3Csmall%3E__LastUpdatedRelative__%3C%2Fsmall%3E%27%2C%0A%27%3Csmall%3E__TimeLeft__%3C%2Fsmall%3E%27&Query=%20%20%28%20%20Status%20%3D%20%27new%27%20OR%20Status%20%3D%20%27open%27%20%29%20AND%20Queue%20%3D%20%27raku%27%20AND%20%27CF.{Tag}%27%20LIKE%20%27%25testneeded%25%27&Order=ASC|ASC|ASC|ASC&OrderBy=id|||). At the time of writing, just short of 100 tickets are in this state. No guts-y knowledge needed for this – you just need to understand enough Raku (or be willing to learn enough) to know what the ticket is about and how to write a test for it. Drop by #raku for hints. :-)
