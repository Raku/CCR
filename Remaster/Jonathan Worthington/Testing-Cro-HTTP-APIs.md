# Testing Cro HTTP APIs
    
*Originally published on [22 December 2018](https://perl6advent.wordpress.com/2018/12/22/day-22-testing-cro-http-apis/) by Jonathan Worthington.*

A good amount of my work time this year has been spent on building a couple of Raku applications. After a decade of contributing to Raku compiler and runtime development, it feels great to finally be using it to deliver production solutions solving real-world problems. I’m still not sure whether writing code in an <a href="http://www.commaide.com/" rel="nofollow">IDE</a> I founded, using a <a href="https://cro.services/" rel="nofollow">HTTP library</a> I designed, compiled by a <a href="https://rakudo.org/" rel="nofollow">compiler</a> I implemented large parts of, and running on a <a href="https://moarvm.org/" rel="nofollow">VM</a> that I play architect for, makes me one of the world’s worst cases of “Not Invented Here”, or just really Full Stack.

Whatever I’m working on, I highly value automated testing. Each passing test is something I know works – and something that I won’t break as I evolve the software in question. Even with automated tests, bugs happen, but adding a test to cover the bug at least means I’ll make *different* bugs in the future, which is perhaps a bit more forgivable.

Most of the code, and complexity, in the system I’m currently working on is in its domain objects. Those are reached through a HTTP API, implemented using Cro – and like the rest of the system, this HTTP API has automated tests. They use one old module of mine – `Test::Mock` – along with a new module released this year, `Cro::HTTP::Test`. In today’s advent post, I’ll discuss how I’ve been using them together, with results that I find quite pleasing.

## A sample problem

It’s the advent calendar, so of course I need a sufficiently festive example problem. For me, one of the highlights of Christmas time in Central Europe is the Christmas markets, many set on beautiful historic city squares. And what, aside from sausage and mulled wine, do we need on that square? A tall, handsome Christmas tree, of course! But how to find the best tree? Well, we get the internet to help, by building a system where they can submit suggestions of trees they’ve seen that might be suitable. What could possibly go wrong?

One can PUT to a route `/trees/{latitude}/{longitude}` to submit a candidate tree at that location. The expected payload is a JSON blob with a tree `height`, and a text `description` of 10-200 characters explaining why the tree is so awesome. If a tree in the same location has already been submitted, a `409 Conflict` response should be returned. If the tree is accepted, then a simple `200 OK` response will be produced, with a JSON body describing the tree.

A GET of the same URI will return a description of the tree in question, while a GET to `/trees` will return the submitted trees, tallest first.

## Testability

Back in highschool, science classes were certainly among my favorite. Now and then, we got to do experiments. Of course, each experiment needed writing up – both the planning before, the results, and an analysis of them. One of the most important parts of the planning was about how to ensure a “fair test”: how would we try control all of the things we weren’t trying to test, so that we could trust in our observations and draw conclusions from them?

Testing in software involves much the same thought process: how do we exercise the component(s) we’re interested in, while controlling the context they operate in? Sometimes, we get lucky, and we’re testing pure logic: it doesn’t depend on anything other than the things we give it to work with. In fact, we can *create our own luck* in this regard, spotting parts of our system that can be pure functions or immutable objects. To take examples from the current system I’m working on:

- We have an object model built up from a bunch of specification files.The process of building it is pretty involved, with a bunch of sanity checks, a few graph algorithms, and so forth. But the result is a bunch of *immutable objects*. Once constructed, they never change. Testing is easy: throw a bunch of test input in, and check that it builds the expected objects.
- We have a small language with an evaluator. The data used by expressions in the language is passed in as an argument to the evaluator, and then we can check the result is what is expected. Thus, the evaluator is a *pure function*.

So, the first thing to do for testability is to find the bits of the system that can be like this and build them that way. Alas, not all things are so simple. HTTP APIs are often a gateway to mutable state, database operations, and so forth. Further, a good HTTP API will map error conditions from the domain level into appropriate HTTP status codes. We’d like to be able to create such situations in our tests, so as to cover them. This is where a tool like `Test::Mock` comes in – but to use it, we need to factor our Cro service in a way that is test-friendly.

## Stubbing a service

For those new to Cro, let’s take a look at the bare minimum we can write to get a HTTP service up and running, serving some fake data about trees.

```` raku
use Cro::HTTP::Router;
use Cro::HTTP::Server;

my $application = route {
    get -> 'trees' {
        content 'application/json', [
            {
                longitude => 50.4311548,
                latitude => 14.586079,
                height => 4.2,
                description => 'Nice color, very bushy'
            },
            {
                longitude => 50.5466504,
                latitude => 14.8438714,
                height => 7.8,
                description => 'Really tall and wide'
            },
        ]
    }
}

my $server = Cro::HTTP::Server.new(:port(10000), :$application);
$server.start;
react whenever signal(SIGINT) {
    $server.stop;
    exit;
}
````

This isn’t a great setup for being able to test our routes, however. Better would be to put the routes into a subroutine in a module `lib/BestTree.pm6`:

```` raku
unit module BestTree;
use Cro::HTTP::Router;

sub routes() is export {
    route {
        get -> 'trees' {
            content 'application/json', [
                {
                    longitude => 50.4311548,
                    latitude => 14.586079,
                    height => 4.2,
                    description => 'Nice color, very bushy'
                },
                {
                    longitude => 50.5466504,
                    latitude => 14.8438714,
                    height => 7.8,
                    description => 'Really tall and wide'
                },
            ]
        }
    }
}
````

And use it from the script:

```` raku
use BestTree;
use Cro::HTTP::Server;

my $application = routes();
my $server = Cro::HTTP::Server.new(:port(10000), :$application);
$server.start;
react whenever signal(SIGINT) {
    $server.stop;
    exit;
}
````

Now, if we had something that could be used to test that `route` blocks do the right thing, we could `use` this module, and get on with our testing.

## Stores, models, etc.

There’s another problem, however. Our Christmas tree service will be stashing the tree information away in some database, as well as enforcing the various rules. Where should this logic go?

There’s many ways we might choose to arrange this code, but the key thing is that this logic does *not* belong in our Cro route handlers. Their job is to map between the domain objects and the world of HTTP, for example turning domain exceptions into appropriate HTTP error responses. That mapping is what we’ll want to test.

So, before we continue, let’s define how some of those things look. We’ll have a `BestTree::Tree` class that represents a tree:

```` raku
class BestTree::Tree {
    has Rat $.latitude;
    has Rat $.longitude;
    has Rat $.height;
    has Str $.description;
}
````

And we’ll work with a `BestTree::Store` object. We won’t actually implement this as part of this post; it will be what we fake in our tests.

```` raku
class BestTree::Store {
    method all-trees() { ... }
    method suggest-tree(BestTree::Tree $tree --> Nil) { ... }
    method find-tree(Rat $latitude, Rat $longitude --> BestTree::Tree) { ... }
}
````

But how can we arrange things so we can take control of the store that is used by the routes, for testing purposes? One easy way is to make it a parameter to our `routes` subroutine, meaning it will be available in the `route` block:

```` raku
sub routes(BestTree::Store $store) is export {
    ...
}
````

This is a functional factoring. Some folks may prefer to use some kind of OO-based Dependency Injection, using some kind of container. That can work fine with Cro too: just have a method that returns the `route` block. (If building something non-tiny with Cro, check out the [documentation on structuring services](https://cro.services/docs/structuring-services) for some further advice on this front.)

## Getting a list of trees

Now we’re ready to start writing tests! Let’s stub the test file:

```` raku
use BestTree;
use BestTree::Store;
use Cro::HTTP::Test;
use Test::Mock;
use Test;

# Tests will go here

done-testing;
````

We use `BestTree`, which contains the routes we want to test, along with:

- `Cro::HTTP::Test`, which we will use to easily write tests for our routes
- `Test::Mock`, which we’ll use to fake the store
- `Test`, which we don’t strictly need, but having access to `subtest` will
let us produce more organized test output

Next, we’ll make a couple of tree objects to use in our tests:

```` raku
my $fake-tree-a = BestTree::Tree.new:
        latitude => 50.4311548,
        longitude => 14.586079,
        height => 4.2,
        description => 'Nice color, very bushy';
my $fake-tree-b = BestTree::Tree.new:
        latitude => 50.5466504,
        longitude => 14.8438714,
        height => 7.8,
        description => 'Really tall and wide';
````

And here comes the first test:

```` raku
subtest 'Get all trees' => {
    my $fake-store = mocked BestTree::Store, returning => {
        all-trees => [$fake-tree-a, $fake-tree-b]
    };
    test-service routes($fake-store), {
        test get('/trees'),
                status => 200,
                json => [
                    {
                        latitude => 50.4311548,
                        longitude => 14.586079,
                        height => 4.2,
                        description => 'Nice color, very bushy'
                    },
                    {
                        latitude => 50.5466504,
                        longitude => 14.8438714,
                        height => 7.8,
                        description => 'Really tall and wide'
                    }
                ];
        check-mock $fake-store,
                *.called('all-trees', times => 1, with => \());
    }
}
````

First, we make a fake of `BestTree::Store` that, whenever `all-trees` is called, will return the fake data we specify. We then use `test-service`, passing in the `route` block created with the fake store. All `test` calls within the block that follows will be executed against that `route` block.

Notice that we don’t need to worry about running a HTTP server here to host the routes we want to test. In fact, due to the pipeline architecture of Cro, it’s easily possible for us to take the Cro HTTP client, wire its TCP message output to put the data it would send into a Raku `Channel`, and then have that data pushed into the server pipeline’s TCP message input pipeline, and vice versa. This means that we test things all the way down to the bytes that are sent and received, but without actually having to hit even the local network stack. (Aside: you can also use `Cro::HTTP::Test` with a URI, which means if you really wanted to spin up a test server, or even wanted to write tests against some other service running in a different process, you could do it.)

The `test` routine specifies a test case. Its first argument describes the request that we wish to perform – in this case, a `get` to `/trees`. The named arguments then specify how the response should look. The `status` check ensures we get the expected HTTP status code back. The `json` check is really two in one:

- It checks that the HTTP content-type is a JSON one
- It checks that the body deserializes to the supplied JSON (if you don’t want to
test every single piece of it, pass a block there, which should evaluate to `True`)

If that’s all we did, and we ran our tests, we’d find they mysteriously pass, even though we didn’t yet edit our `route` block’s `get` handler to actually use the store! Why? Because it turns out I was lazy and used the data from my earlier little server example as my test data here. No worries, though: to make the test stronger, we can add a call to `check-mock`, and then assert that our fake store really did have the `all-trees` method called once, and with no arguments passed.

That just leaves us to make the test pass, by implementing the handler properly:

```` raku
get -> 'trees' {
    content 'application/json', [
        $store.all-trees.map: -> $tree {
            {
                latitude => $tree.latitude,
                longitude => $tree.longitude,
                height => $tree.height,
                description => $tree.description
            }
        }
    ]
}
````

## Getting a tree

Time for the next test: getting a tree. There are two cases to consider here: the one where the tree is found, and the one where the tree is not found. Here’s a test for the case where a tree is found:

```` raku
subtest 'Get a tree that exists' => {
    my $fake-store = mocked BestTree::Store, returning => {
        find-tree => $fake-tree-b
    };
    test-service routes($fake-store), {
        test get('/trees/50.5466504/14.8438714'),
                status => 200,
                json => {
                    latitude => 50.5466504,
                    longitude => 14.8438714,
                    height => 7.8,
                    description => 'Really tall and wide'
                };
        check-mock $fake-store,
                *.called('find-tree', times => 1, with => \(50.5466504, 14.8438714));
    }
}
````

Running this now fails. In fact, the `status` code check fails first, because we didn’t implement the route yet, and so get 404 back, not the expected 200. So, here’s an implementation to make it pass:

```` raku
get -> 'trees', Rat() $latitude, Rat() $longitude {
    given $store.find-tree($latitude, $longitude) -> $tree {
        content 'application/json', {
            latitude => $tree.latitude,
            longitude => $tree.longitude,
            height => $tree.height,
            description => $tree.description
        }
    }
}
````

Part of this looks somewhat familiar from the other route, no? So, with two passing tests, let’s go forth and refactor:

```` raku
get -> 'trees' {
    content 'application/json',
            [$store.all-trees.map(&tree-for-json)];
}

get -> 'trees', Rat() $latitude, Rat() $longitude {
    given $store.find-tree($latitude, $longitude) -> $tree {
        content 'application/json', tree-for-json($tree);
    }
}

sub tree-for-json(BestTree::Tree $tree --> Hash) {
    return {
        latitude => $tree.latitude,
        longitude => $tree.longitude,
        height => $tree.height,
        description => $tree.description
    }
}
````

And the tests pass, and we know our refactor is good. But wait, what about if there is no tree there? In that case, the store will return `Nil`. We’d like to map that into a 404. Here’s another test:

```` raku
subtest 'Get a tree that does not exist' => {
    my $fake-store = mocked BestTree::Store, returning => {
        find-tree => Nil
    };
    test-service routes($fake-store), {
        test get('/trees/50.5466504/14.8438714'),
                status => 404;
        check-mock $fake-store,
                *.called('find-tree', times => 1, with => \(50.5466504, 14.8438714));
    }
}
````

Which fails, in fact, with a 500 error, since we didn’t consider that case in our route block. Happily, this one is easy to deal with: turn out `given` into a `with`, which checks we got a defined object, and then add an `else` and produce the 404 Not Found response.

```` raku
get -> 'trees', Rat() $latitude, Rat() $longitude {
    with $store.find-tree($latitude, $longitude) -> $tree {
        content 'application/json', tree-for-json($tree);
    }
    else {
        not-found;
    }
}
````

## Submitting a tree

Last but not least, let’s test the route for suggesting a new tree. Here’s the successful case:

```` raku
subtest 'Suggest a tree successfully' => {
    my $fake-store = mocked BestTree::Store;
    test-service routes($fake-store), {
        my %body = description => 'Awesome tree', height => 4.25;
        test put('/trees/50.5466504/14.8438714', json => %body),
                status => 200,
                json => {
                    latitude => 50.5466504,
                    longitude => 14.8438714,
                    height => 4.25,
                    description => 'Awesome tree'
                };
        check-mock $fake-store,
                *.called('suggest-tree', times => 1, with => :(
                    BestTree::Tree $tree where {
                        .latitude == 50.5466504 &&
                        .longitude == 14.8438714 &&
                        .height == 4.25 &&
                        .description eq 'Awesome tree'
                    }
                ));
    }
}
````

This is mostly familiar, except the `check-mock` call looks a little different this time. `Test::Mock` lets us test the arguments in two different ways: with a `Capture` (as we’ve done so far) or with a `Signature`. The `Capture` case is great for all of the simple cases, where we’re just dealing with boring values. However, once we get in to reference types, or if we don’t actually care about exact values and just want to assert the things we care about, a signature gives us the flexibility to do that. Here, we use a `where` clause to check that the tree object that the route handler has constructed contains the expected data.

Here’s the route handler that does just that:

```` raku
put -> 'trees', Rat() $latitude, Rat() $longitude {
    request-body -> (Rat(Real) :$height!, Str :$description!) {
        my $tree = BestTree::Tree.new: :$latitude, :$longitude,
                :$height, :$description;
        $store.suggest-tree($tree);
        content 'application/json', tree-for-json($tree);
    }
}
````

Notice how Cro lets us use Raku signatures to destructure the request body. In one line, we’ve said:

- The request body must have height and description
- That we want the height to be a `Real` number
- That we want the description to be a string

Should any of those fail, Cro will automatically produce a 400 bad request for us. In fact, we can write tests to cover that – along with a new test to make sure a conflict will result in a 409.

```` raku
subtest 'Problems suggesting a tree' => {
    my $fake-store = mocked BestTree::Store, computing => {
        suggest-tree => {
            die X::BestTree::Store::AlreadySuggested.new;
        }
    }
    test-service routes($fake-store), {
        # Missing or bad data.
        test put('/trees/50.5466504/14.8438714', json => {}),
                status => 400;
        my %bad-body = description => 'ok';
        test put('/trees/50.5466504/14.8438714', json => %bad-body),
                status => 400;
        %bad-body<height> = 'grinch';
        test put('/trees/50.5466504/14.8438714', json => %bad-body),
                status => 400;

        # Conflict.
        my %body = description => 'Awesome tree', height => 4.25;
        test put('/trees/50.5466504/14.8438714', json => %body),
                status => 409;
    }
}
````

The main new thing here is that we’re using `computing` instead of `returning` with `mocked`. In this case, we pass a block, and it will be executed. (The block does not get the method arguments, however. If we want to get those, there is a third option, `overriding`, where we get to take the arguments and write a fake method body.)

And how to handle this? By making our route handler catch and map the typed exception:

```` raku
put -> 'trees', Rat() $latitude, Rat() $longitude {
    request-body -> (Rat(Real) :$height!, Str :$description!) {
        my $tree = BestTree::Tree.new: :$latitude, :$longitude,
                :$height, :$description;
        $store.suggest-tree($tree);
        content 'application/json', tree-for-json($tree);
        CATCH {
            when X::BestTree::Store::AlreadySuggested {
                conflict;
            }
        }
    }
}
````

## Closing thoughts

With `Cro::HTTP::Test`, there’s now a nice way to write HTTP tests in Raku. Put together with a testable design, and perhaps a module like `Test::Mock`, we can also isolate our Cro route handlers from everything else, easing their testing.

The logic in our route handlers here is relatively straightforward; small sample problems usually are. Even here, however, I find there’s value in the journey, rather than only in the destination. The act of writing tests for a HTTP API puts me in the frame of mind of whoever will be calling the API, which can be a useful perspective to have. Experience also tells that tests “too simple to fail” do end up catching mistakes: the kinds of mistakes I might assume I’m too smart to make. Discipline goes a long way. On which note, I’ll now be disciplined about taking a break from the keyboard now and then, and go enjoy a Christmas market. -Ofun!
