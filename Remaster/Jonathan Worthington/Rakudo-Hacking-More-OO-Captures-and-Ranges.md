# Rakudo Hacking: More OO, Captures and Ranges
    
*Originally published on [17 May 2008](https://use-perl.github.io/user/JonathanWorthington/journal/36451/) by Jonathan Worthington.*

After yesterday's day of Rakudo hacking, I was too tired to write up what had happened coherently, so I left it until today. I did quite a few different things throughout the day, so rather than taking them in order I'll group them in a way that makes it a bit easier to follow.

First, I dealt with some things from the perl6-compilers list. There was a patch from *Moritz* to factor out a large chunk of one of the methods in the parser actions file to help make it more readable, which I applied. There was also a bug report from *Chris Fields*, pointing out that typed variables had stopped working. After trying to work out why from some debugging, I then started working out which check-in had caused the problem, which soon led to a fix. So, type annotations will now work again.

I had tried to get some basic capture support in place before, but it was based upon the Capture PMC. For some reason, this didn't work out so well, and I was keen to have captures for something else I was going to implement later on. Therefore, I did a quick PIR version. I also implemented the `$( )`, `@( )` and `%( )` contextualizers (which put whatever is inside the brackets into item, list and hash context respectively). Therefore, you can now do things like:

```` raku
my $x = \(1, 2, 3, foo => 42);
say $x[1];    # 2
say $x<foo>;  # 42
for @($x) -> $val {
    say $val; # 1\n2\n3\n
}
````

There's plenty more to do on captures, but you have the basics now. And of course, the contextualizers work much more generally than just with captures, but we've some work to do in order to make these useful in the general case.

Each week I'm implementing a little more of S12 (the objects specification). This week was no exception. We now have basic support in for declaring and calling private methods.

```` raku
class A {
    my method private {
        12;
    }
    method public {
        self!private
    }
}
say A.`new`.public; # 12
````

Notice how they are called with an entirely different syntax, so its obvious when looking at the code that you're calling something private. Talking of different calling syntaxes, there are some other variations to just writing `.` to call a method. `.?` will call a method of that given name if there is one, or just return an undef (rather than throwing an exception) if there is no such method. `.*` will call all methods in the class hierarchy with that name, including inherited ones, and return a list of captures containing the values that were returned, and if there are no methods you will just get an empty list. `.+` is like `.*`, but if it can't find at least one method to call it throws an exception. Think of them like quantifiers on regexes, but relating to method calls instead.

```` raku
class Dog {
    method bark { say "WOOF" }
}
class Puppy is Dog {
    method bark { say "woof" }
}
my Puppy $x .= `new`;
$x.?`bark`; # woof\n
$x.?`doesnotexist`; # no exception
$x.+`bark`; # woof\nWOOF\n
````

I haven't collected return values into captures in these examples, but it works too.

Something else that had been on the want list for a while was allowing explicit specification on a variable to hold the invocant of a method. This turned out to be trivial to implement, so rather than just having the self keyword you can now say:

```` raku
class Foo {
    method test($inv: $x, $y) {
        say $inv.`WHAT`;
        say $x + $y;
    }
}
my $x = Foo.`new`;
$x.test(14, 28); # Foo\n42\n
````

As a slightly ad-hoc thing, I implemented the prefix `^` operator. On the name of a class, this gets the meta-class. On a number, it generates a range from 0 up to that value minus one. So the following prints the numbers 0 through 4, each on a line of their own.

```` raku
for ^5 -> $n {
    say $n
}
````

This was actually just a trivial task I spotted while persuing the specification for ranges. We just fake them up in Rakudo at the moment to produce a list, but they are supposed to be lazy and have a whole load of other semantics. I stubbed in a `Range` class to get us started in that direction, but it needs quite a bit more work before we're ready to actually get Rakudo's `..` operator to construct it. For now it just stores its start and end points and knows how to give a Perl representation of itself.

Once again, thanks for Vienna.pm for sponsoring this work. Also, thanks to everyone else contributing to Rakudo, be it with patches, bug reports or general feedback. :-)
