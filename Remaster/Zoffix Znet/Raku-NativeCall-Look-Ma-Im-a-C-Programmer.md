# Raku NativeCall: Look, Ma! I'm a C Programmer!
    
*Originally published on [12 May 2016](https://perl6.party//post/Perl-6-NativeCall--Look-Ma-Im-A-C-Programmer) by Zoffix Znet.*

A while back, I wanted to write a post talking about how Raku lets you use C libraries without writing any C code. It was cool and clickbaity, but I quickly realized two things: (a) the statement isn't always true; and (b) I'm too ignorant to talk about it without sounding like a moron.

And so has [started](http://learnxinyminutes.com/docs/c/) my path to [re-learn C](http://www.amazon.com/Programming-Language-Brian-W-Kernighan/dp/0131103628) (I barely ever used it and it was over a decade ago) and to learn Raku's NativeCall in great detail. Oh, and I'll blog about my journey in a series of bite-sized posts. Let's begin!

## Use C Libraries Without Writing Any C Code!

[`NativeCall`](http://docs.raku.org/language/nativecall) is one of the standard modules included with Raku that provides interface to C libraries.  No compilers or `-dev` versions of the libraries are needed! And this, of course, means you can use C libraries without writing any C code!

The `is `native`` trait is applied to a sub with an empty body and signature that matches the prototype of the C function you wish this sub to call.  Magic! Right?

As I've already hinted, things get complex fast, and in some circumstances not writing any C might be unfeasible or maybe even impossible. In such situations, you'd simply create a wrapper library. But let's look at some code already!

## The Standard C Library

If no argument is given to `is native` trait, it will look in the Standard C Library. Programmers coming from Perl often notice there's no ``fork`` in Raku. The reason for that is that, unlike in Perl, it's almost never needed, but thanks to NativeCall, it *is* actually "there":

```` raku
use NativeCall;
sub `fork` returns int32 is native {};
given `fork` {
    when 0     { say "I'm a kid!";                      };
    when * > 0 { say "I'm a parent. The kid is at $_";  };
    default    { die "Failed :(";                       };
}
sleep .5;
say 'Hello, World!';
# OUTPUT:
# I'm a parent. The kid is at 13099
# I'm a kid!
# Hello, World!
# Hello, World!
````

On the first line, we `use` the NativeCall module to bring in its functionality. The second line is where all the magic happens. We declare a sub with an empty body and name it the same as its named in the C library. The sub is sporting `is native` trait which tells the compiler we want a C library function, and since the name of the library isn't there, we want the Standard Library.

For a successfull call, we need to match the prototype of the C function.  Looking at `man 2 fork`, we see it's `pid_t fork(void)`. So our sub doesn't take any arguments, but it returns one. If you dig around, you'll find `pid_t` can be represented as a C `int` and if we look up an `int` in the [handy table mapping C and Raku types](http://docs.raku.org/language/nativecall#Passing_and_Returning_Values), you'll notice we can use `int32` Raku native type, which is what we specified in the `returns` trait.

And that is it! The rest of our code uses ``fork`` as if it were a Raku sub. It will be looked up in the library on the first call and cached for any subsequent look ups.

## Basic Use of Libraries

For our learning pleasure, I'll be using [libcdio](http://www.gnu.org/software/libcdio/) library that lets you mess around with CDs and CD-ROMs (anybody still got those?). On Debian, I'll just need `libcdio13` package. Notice is it *not* the `-dev` version and on my box it was actually already installed.

I'm going to create a Raku program called `troll.p6` that opens and closes the CD tray:

```` raku
use NativeCall;
sub cdio_eject_media_drive(Str) is native('cdio', v13) {};
sub cdio_close_tray(Str, int32) is native('cdio', v13) {};
say "Gimme a CD!";
cdio_eject_media_drive Str;
sleep .5;
say "Ha! Too slow!";
cdio_close_tray Str, 0;
````

The `cdio_eject_media_drive` and `cdio_close_tray` functions are provided by the library. We declare them and apply `is native` trait. This time, we give the trait two arguments: the library name and its version.

Notice how the name lacks any `lib` prefixes or `.so` suffixes. Those are not needed, as NativeCall figures out what those should be automatically, based on the operating system the code is running on.

The version is optional, but it's not recommended that you omit it, since then you never know whether the version that's loaded is compatible with your code. In future posts, I'll explore how to make naming/versioning more flexible.

The one thing to look at are the C function prototypes for these two subs:

```` raku
driver_return_code_t    cdio_eject_media_drive (const char *psz_drive)
driver_return_code_t    cdio_close_tray (const char *psz_drive, driver_id_t *p_driver_id)
````

That looks mighty fancy and it seems like we haven't reproduced them exactly in our Raku code. I'm cheetsy-doodling here a bit: while `Str` is correct for `const char *`, I looked up what `int` value will work for `p_driver_id` so I don't have to mess with structs or enums, for now. I'm also ignoring return types which may be a bad idea and makes my code less predictable and perhaps less portable as well. When making calls to subs, I used the type object `Str` for the strings. That translates to a `NULL` in C.

I'll leave more detailed coverage of passing arguments around for future articles. Right now, there's a more serious issue that needs fixing. The names!

## Renaming Functions

One thing that sucks about C functions is they're often named with snake_case, which is an eyesore in Raku with it's shiny kebob-case.  Luckily, the fix is just a trait away:

```` raku
use NativeCall;
sub open-tray(Str) is native('cdio', v13)
    is symbol('cdio_eject_media_drive') {};
sub close-tray(Str, int32) is native('cdio', v13)
    is symbol('cdio_close_tray') {};
say "Gimme a CD!";
open-tray Str;
sleep .5;
say "Ha! Too slow!";
close-tray Str, 0;
````

The usage is simple: name your sub with whatever you want its name to be, then use `is symbol` trait and use the C function's name as its argument. And that's it! With just a couple of lines of code, we're making a call into a C library and we're using purty sub names to do it!

## Conclusion

Today we've seen a glimpse of the power Raku provides when it comes to C libraries. It lets you get pretty far without needing a C compiler.

In future posts in the series, we'll learn more about passing data around as well as various helpers that do the heavy lifting.

See you next time!
