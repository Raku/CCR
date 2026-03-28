# June 7 2011: Arithmetics
    
*Originally published on [7 June 2011](http://strangelyconsistent.org/blog/june-7-2011-arithmetics) by Carl Mäsak.*

Part of the reason, in my view, that arithmetic has a reputation of being slightly boring, is that not enough focus is given on the fifth arithmetic operation.

You heard me. We all know about the original four: addition, subtraction, multiplication and division. Bla bla bla. They're so not-new that I've basically assumed familiarity with them so far, and not even introduced them.

```raku
my $a = 3;
my $b = 2;
say $a + $b;         # 5
say $a - $b;         # 1
say $a * $b;         # 6
say $a / $b;         # 1.5
```

So, which one is the fifth operation? I'm not talking about powers or square roots, though those can be pretty useful at times:

```raku
say $a ** $b;        # 3 ** 2 == 3 * 3 == 9
say sqrt($b);        # 1.414...
```

And I'm not talking about logarithms or sines or exponentials &mdash; although if you're serious about computers you should definitely familiarize yourself with all of those.

```raku
say log($a);         # some number
say sin($a);         # ditto
say exp($a);         # ditto
```

No; what I'm referring to is the "remainder operator". This was the way we were taught division in my school, back when all we had was integers and division usually left a small remainder. After that, we went on to learn about fractions, and stopped caring about whether the integers added up evenly or not. But those little remainders can be very useful.

```raku
say $a / $b;         # 3 / 2 = 1.5
say $a % $b;         # 1, because 3 == 2 * 1 + 1
```

Here's why it's useful: it will help you color chess boards correctly. It will help you make Pac-Man appear on the left side of the screen when he leaves it on the right side. It will help you pick out individual digits from a number. It will help you color within the lines, whatever the lines may be.

Don't listen to what the grownups are saying. Learn the remainder operation. And then everything else.

Here's a little bonus game that uses the remainder operation. Not even all grownups will know how this one works. `:-)```

```raku
say "Think of a number between 1 and 100";
prompt "Press Enter when ready.";
say "";
say "Ready? Good.";
say "";
my $a = prompt "What's the remainder of your number divided by 3? ";
my $b = prompt "What's the remainder of your number divided by 5? ";
my $c = prompt "What's the remainder of your number divided by 7? ";
say "";
my $number = (70 * $a + 21 * $b + 15 * $c) % 105;
my $reply = prompt "You thought of $number, didn't you (Y/N)? ";
if $reply eq "Y" {
    say "Yay! I rock!";
}
else {
    say "Ok, hm. One of us miscounted. And I'm a computer.";
    say "If you catch my drift...";
}
```
