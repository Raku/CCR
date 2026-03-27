# The dot is the cutest sigil
    
*Originally published on [4 October 2009](http://strangelyconsistent.org/blog/the-dot-is-the-cutest-sigil) by Carl Mäsak.*

I've recently gotten into this style of programming:

```raku
given %some-hash {
    if .<foo> {
        .<bar> = .<baz> + .<austria>;
    }
}
```

I keep thinking of it as a wonky kind of sigil, the `.<>` sigil, which has its very own variable namespace inside of the hash I've chosen as topic.

Now let's say that the above piece of code was part of a prototyped program which later evolved to use objects instead of sloppy hashes. Then the same code becomes even nicer:

```raku
given $some-object {
    if .foo {
        .bar = .baz + .austria;
    }
}
```

The advantages of objects to hashes are immediate (and well-known):

- Less to write.
- The translation between the old style and the new is automatic. Just remove the pointy elbows.
- Spelling errors are now caught at runtime, as opposed to never.
- The reason assignments (like the assignment to `.bar` above) work is that attribute accessors can be made `rw`. The flip side of that is that one can omit the `rw` and avoid assignment accidents. That's also an improvement over the hash.
- Now the dot really looks like a cute little sigil. It isn't, of course, it's still the call-public-method twigil we know and love. But it's even easier to pretend that the attributes are special variables namespaced under the chosen object.


All this is fairly trivial; I just think it's a nice syntax. But it is with this example that the truth finally sinks in: *keeping `$_` and `self` separate from each other in Raku was a really good idea*.

With the syntax Raku settled on, it's like there are two topics in a method: the common one (`$_`), and the OO one (`self`). And each has wonderful shortcuts: with `$_` you just use `prefix:<.>` as above, and with `self`, you can use `$.` or `@.` or `%.` ad lib. The OO form is slightly longer than the common form, since OO is more intricate (and less ubiquitous).

```
Long form     Short forms
=========     ===========
$_.foo        .foo
self.foo      $.foo
              @.foo
              %.foo
```

And since they're disjunct from each other, you never have to context-switch or worry about what it is you're looking at when you see `.foo`. Unless you explicitly mix the two together with `given self` or invocant `$_` which you're entirely free to do, but remember that it only buys you one character.

As an added bonus, we can now re-write the code example in the rejected rfc 342 so that it works in today's Raku, without introducing extra syntax:

```raku
my $record = loadrecord($studentID);
given $record {
    my $spam = open .minimum;
    $spam.say: qq:to'SPAM';
    Dear {.name}:
            Your tuition is now due.  Please send in a payment
    of at least {.minimum}.
    SPAM
};
```
