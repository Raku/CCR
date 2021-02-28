# Raku Hands-On Workshop: Weatherapp (Part 3)
    
*Originally published on [29 May 2016](https://perl6.party//post/Perl-6-Hands-On-Workshop--Weatherapp--Part-3) by Zoffix Znet.*

*Be sure to read [Part 1](/post/Perl-6-Hands-On-Workshop--Weatherapp--Part-1) and [Part 2](/post/Perl-6-Hands-On-Workshop--Weatherapp--Part-2) of this workshop first.*

There is black box testing, glass box testing, unit testing, integration testing, functional testing, system testing, end-to-end testing, sanity testing, regression testing, acceptance testing, load testing, stress testing, performance testing, usability testing, and many more types of testing.

I'll leave it for people with thicker glasses to [explain all of the types](http://www.testingexcellence.com/types-of-software-testing-complete-list/). Today, we'll write tests that ensure our weather reporting module works as expected, and as a bonus, you get to pick your own label for what type of tests these are. Let's dive in!

## TDD

TDD (Test-Driven Development) is where you write a bunch of tests before you write the actual code, ensure they fail—because code to satisfy them isn't there yet—and then you write code until the tests succeed. Now you can safely refactor your code or add new features without worrying you'll break something. Rinse and repeat.

Not only do you avoid having to convince yourself to bother writing tests after your code seems to work, you also get a feel for how comfortable your interface is to use before you even create it.

## Testing Modules

Raku comes with a number of standard modules included, one of which is a module called [`Test`](https://docs.raku.org/language/testing) that we'll use. The Ecosystem also has dozens of [other test related modules](https://modules.raku.org/#q=Test) and we'll use two called [`Test::When`](https://modules.raku.org/dist/Test::When) and [`Test::META`](https://modules.raku.org/dist/Test::META)

`Test` provides all the generic testing routines we'll use, `Test::When` will let us watch for when the user actually agreed to run specific types of tests, and `Test::META` will keep an eye on the sanity of our distribution's META file (more on that later).

To install `Test::When` and `Test::META`, run `zef install Test::When Test::META`.

## Testing Files

Our testing files are named with the extension `.t` and go into `t/` directory. They will be automatically discovered and run by module managers during installation of our module.

You are free to organize your tests under subdirectories; they will still be automatically found. It's also common to prefix the names of tests with a sequential number, e.g. `00-init.t`, `01-methods.t`, etc. It's more of an organizational practice and in no way should your tests in one file depend on whether tests in another file ran first.

## Boilerplate

```` raku
use Test;
use My::Module;
is get-`stuff`, 'the right stuff', 'The stuff we received is correct';
done-testing;
# or
use Test;
plan 1;
use My::Module;
is get-`stuff`, 'the right stuff', 'The stuff we received is correct';
````

The two versions above differ in that the first doesn't care how many tests you run and the second expects exactly one test to run. The former knows all tests ran when `done-testing` is called while the latter counts how many ran and complains if the count doesn't match the plan.

The version without a plan is generally easier to use, especially in a highly collaborative environment where multiple people might be adding tests to the file, so keeping an accurate test count becomes annoying. The one thing to be careful with planless method is this:

```` raku
my @results = get-results;
for @results.kv -> $i, $v {
    is $v, 'expected', "result #{$i+1} is correct";
}
````

This test will run correctly regardless of how many results we get in `@results`, even if it is none! We should add an additional test that ensures `@results` contains the correct number of results:

```` raku
is @results.elems, 5, 'got five results';
````

## Our Files

We'll create two test files and our directory structure will look like this:

```` raku
t
├── key
├── 01-use.t
├── author
│   └── 01-meta.t
└── online
    └── 01-weather-for.t
````

We placed our META file test into an `author` subdirectory because that test is useful only for us and not the user, so there's no point in having to require them to install the extra modules. The same logic should apply to other tests, like ones that test documentation completeness or any other test failing which does not mean the module itself is broken. No one wants their build to stall just because you didn't document a new experimental method, so we should avoid running those tests on the installer's machine.

Our main test file goes into `online` directory, as it will be run only when the installer requests online tests. The names of these subdirectories are arbitrary and their existence is purely for organizational purposes. Whether the tests are actually run is controlled by `Test::When` module.

Last but not least, we have the `key` file containing our API key. This way, we don't hardcode it into any one test, it's more obvious that this sort of data is present in our codebase, and we know where to go if we have to replace it (even if we add multiple files that need the key).  Depending on the service you are using, you may choose to make the key entirely private and ask the installer to enter their own key. Some services offer tester keys or sandboxed endpoints precisely for the purposes of users running tests.

The `01-use.t` and `author/01-meta.t` tests are rather unspectacular.

```` raku
# t/01-use.t
use Test;
use-ok 'WebService::Weather';
done-testing;
````

We call [`use-ok`](https://docs.raku.org/language/testing#Testing_modules) that tests whether the module can be loaded and we give it the name of our future module as the argument. Generally, this test isn't needed, since you're going to `use` your module to bring in the functionality for testing anyway. In this particular case, however, all of our other tests may get skipped (installer doesn't ask for author/online tests), resulting in `Result: NOTESTS` output, which I don't entirely trust for all module installers to know to interpret as success.

The Meta file test is just a copy-paste from [the docs](https://github.com/jonathanstowe/Test-META#synopsis), which works for any distribution:

```` raku
# t/author/01-meta.t
use Test::When <author>;
use Test;
use Test::META;
meta-ok;
done-testing;
````

In both tests we include `Test` module and call `done-testing` at the end.  In the Meta file test we've used `use Test::When <author>` to indicate this test [is an author test](https://github.com/zoffixznet/rakuest-When#author) and we'll need to set an environmental variable for it to run—more on that later.

## Main Test

To write the main test, we'll peak into what sort of values [the API returns](http://api.openweathermap.org/data/2.5/weather?q=London&appid=4f5572bc11dda69c43a0114ce5ce4116) and try to model them. We need to strike a balance between knowing we received a legit value from our subroutine or method, while not making the test so precise that it fails the minute the valid value we receive decided to wear a hat and put on makeup.

Here's the code for the test:

```` raku
# t/online/01-weather-for.t
use Test::When <online>;
use Test;
use WebService::Weather;
for ('London'), ('London', 'ca') -> $args {
    subtest {
        my $result = weather-for |$args;
        isa-ok $result, 'WebService::Weather::Result',
            'result is of a correct data type';
        does-ok $result."$_"(), Numeric, "$_ is numerical"
            for <temp wind precip>;
        cmp-ok $result.temp,   &[<],  70,   'temperature is not too high';
        cmp-ok $result.temp,   &[>],  -100, 'temperature is not too low';
        cmp-ok $result.wind,   &[<],  120,  'wind speed is not too high';
        cmp-ok $result.wind,   &[>=], 0,    'wind speed is not too low';
        cmp-ok $result.precip, &[<],  3200, 'precipitation is not too high';
        cmp-ok $result.precip, &[>=], 0,    'precipitation is not too low';
    }, "Testing with args: $args";
}
isa-ok weather-for('blargs' x 12), Failure,
    'we get a Failure for unknown city';
done-testing;
````

We use `Test::When` to mark this test as requiring an active Internet connection, so the test will only run when the installer explicitly requests to do so via an environmental variable. We also `use` the module we'll make.

In the first `for` loop, we're iterating over two sets of arguments: city only and city + country. The loop executes a `subtest` on each iteration, delineating our results in the output nicely. When we call `weather-for` we [`Slip`](https://docs.raku.org/type/Slip) each set of arguments in and save the return value into our `$result`.

We follow the interface described in [our DESIGN doc](https://github.com/zoffixznet/rakuorkshop-1-Weatherapp/blob/master/DESIGN.md#interface-details) to write the tests for the result. It needs to be an object and it has `.temp`, `.wind`, and `.precip` methods and their values are [`Numeric`](https://docs.raku.org/type/Numeric).

The [`isa-ok` sub](https://docs.raku.org/language/testing#By_object_type) tests our result is of the correct class and [`does-ok` sub](https://docs.raku.org/language/testing#By_role) checks all of the return values do the [`Numeric` role](https://docs.raku.org/type/Numeric)—note how we simply used another `for` loop there, to avoid duplicating the test code.

The last segment of the test uses a bunch of [`cmp-ok`](https://docs.raku.org/language/testing#By_arbitrary_comparison) tests to check the sanity of the range of the returned values. Since we don't know what the weather is like on the day we're running the test, we can't check for the exact values. I've consulted with the [list of weather records](https://en.wikipedia.org/wiki/List_of_weather_records) to get an idea for the range of the values we're expecting.

Lastly, outside our main `for` loop, we have one more test that gives `weather-for` a garbage city name and tests that it returns a [`Failure` object](http://docs.raku.org/type/Failure).

We're done with our tests, so let's commit them:

```` raku
git add t
git commit -m 'Write tests'
git push
````

Your distribution structure should look [something like this](https://github.com/zoffixznet/rakuorkshop-1-Weatherapp/tree/bfdd41d052e5f909125d65a01ddf63be8d0145a7) now.

## Extra Testing

Our tests did not test absolutely everything that can be tested. What happens when a city is an empty string? What happens when it's not a string? What happens when we give a garbage value for the country? What happens when network connection fails?

We could add that, but keep one thing in mind: tests are code and code needs maintenance. If adding a couple lines of code to your program requires you to also dig through thousands of lines of tests, you're going to have a bad day.

So how much testing is enough? It depends on the type of the software you're writing. If your software failing will result in the loss of human life (e.g. medical software) or loss of a large investment (e.g. software for space probes) you better make sure you test every possible case. On the other end, if you're writing a [cowsay](https://en.wikipedia.org/wiki/Cowsay) clone, you may scrimp on tests for the sake of easier maintenance.

## Running The Tests

To run the tests, we use the `prove` command and pass `raku` as executable to use. Since the modules we're writing tend to live in `lib/` directory, we should also pass the `-I` command line switch to include that directory in the module search path. We'll also tell it to find test files recursively and be verbose with its output. Thus, the full command is:

```` raku
prove -e 'raku -Ilib' -vr t/
````

Where `t/` is the directory with our tests, but we can give it individual test files as well. For convenience, I aliased the above command in my `.bash_aliases` file:

````
alias prove6="prove -e 'raku -Ilib' -vr"
````

And then I just use it as

```` raku
prove6 t/
````

Try running the tests right now. Unsurprisingly, they fail!

````
...
# Failed test 'The module can be use-d ok'
...
````

These failures will be our instructions on what to do next while implementing the module, which we'll cover in the next post!

## Refining the Design

At this point, we got a feel for using the code we haven't even written yet and that type of code is much cheaper to change than one we've written and shipped.  Does anything feel off or awkward to use? Are we missing anything? Does anything seem redundant? If yes, we probably should alter our design.

Three things jump out with our weather module:

- We don't know why we failed. Was the city name wrong? Did the service change and now we're not giving it the correct arguments? Was it a network error?  Perhaps, we should add some exception classes and throw one of them, depending on the error.
- We don't know whether we got the weather for the correct city. Calling with `('London')` gives weather for London in Britain, but calling with `('London', 'ca')` gives weather for London in Ontario, Canada. Perhaps, we could add a `.location` method to our result object that would return City + Country of the actual location we received the weather for.
- An astute reader will notice we never specced how `weather-for` obtains **the API key!** There are several approaches. We can specify it on the `use` line or call a `key` subroutine and store it in a class variable—both of which will restrict your program to use just one API key. Another way may be to pass a `:key` named argument to `weather-for` or even redesign the interface to be Object Oriented, with key specified as an attribute to the `WebService::Weather` object.

## Homework

Several problems with our code/design were brought up in this articles: we don't know how to specify the API key to use, tests don't test for everything, and we could use some extra features, such as precise failure mode indicators and providing the location of in the result.

Try to alter the design and modify the tests to accommodate that stuff.

## Conclusion

Today, we broke ground by laying down the first code for our app. This code tests the functionality of the actual app code we're yet to write.

Ensuring your code works is important and having automated tests do that for you lets you modify your code without fear that you'll break something.  The amount of tests you write depends on the type of your application. As tests require maintenance and you need to strike a balance between having your application work "correctly enough" and adding extra maintenance work for you.

In the next post, we'll write the actual code to fetch weather information.  Get excited!
