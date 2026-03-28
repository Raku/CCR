# Dreaming in mixins
    
*Originally published on [4 July 2010](http://strangelyconsistent.org/blog/dreaming-in-mixins) by Carl Mäsak.*

Working with pls (a next-gen project installer for the Raku ecosystem), I had a few classes with code like this:

```raku
class POC::Tester does App::Pls::Tester {
    method test($project --> Result) {
        my $target-dir = "cache/$project<name>";
        if "$target-dir/Makefile" !~~ :e {
            return failure;
        }
        unless run-logged( relative-to($target-dir, "make test"),
                           :step('test'), :$project ) {
            return failure;
        }
        return success;
    }
}
```

(`success` and `failure` are `Result` enum values defined elsewhere. They felt like pleasant documentation, and when return type checking works, they'll even help catch errors!)

Now, I wanted to add super-simple progress diagnostics to this method. I wanted an `announce-start-of('test', $project);` at the start of the module, and either an `announce-end-of('test', success);` or an `announce-end-of('test', failure);`, depending on the success or failure of the method.

I have a low threshold for boilerplate. After realizing that I'd have to manually add those calls in the beginning of the method, and before each `return` — and not only in this method, but in several others — I thought "man, I shouldn't have to tolerate this. This is Raku, it should be able to do better!"

So I thought about what I really wanted to do. I wanted some sort of... method wrapper. Didn't really want a subclass, and a regular role wouldn't cut it (because class methods override same-named role methods).

Then it struck me: *mixins*. Did those already work in Rakudo? Oh well, try it and see. So I created this role:

```raku
role POC::TestAnnouncer {
    method test($project --> Result) {
        announce-start-of('test', $project&lt;name&gt;);
        my $result = callsame;
        announce-end-of('test', $result);
        return $result;
    }
}
```

And then, later:

```raku
POC::Tester.`new` does POC::TestAnnouncer
```

And it worked! On the first attempt! *jnthn*++!

(If you're wondering what in the above method that does the wrapping — it's the `callsame` call in the middle. It delegates back to the overridden method. Note that with this tactic, I get to write my `announce-start-of` and `announce-end-of` calls *exactly once*. I don't have to go hunting for all the various places in the original code where a `return` is made.)

I guess this counts as using mixins to do Aspect-Oriented Programming. This way of working certainly makes the code less [scattered and tangled](https://en.wikipedia.org/wiki/Aspect-oriented_programming#Motivation_and_basic_concepts).

So, in [this file](https://github.com/masak/proto/blob/4396d9b6c6eca4c9a0d1e9da7ac90903c4ea528c/proof-of-concept), I currently have a veritable curry of dependency injection, behavior-adding roles, lexical subs inside methods, AOP-esque mixins, and a `MAIN` sub. They mix together to create something really tasty. And it all runs, today, under Rakudo HEAD.

As jnthn said earlier today, it's pretty cool that a script of 400 LoC, together with a 230-LoC module, make up a whole working installer. With so little code, it almost doesn't feel like coding.
