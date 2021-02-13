# Not guts, but 6: part 3
    
*Originally published on [2016-01-06](https://6guts.wordpress.com/2016/01/06/not-guts-but-6-part-3/) by Jonathan Worthington.*

To me, one of the most important things about the asynchronous programming support in Raku is the uniform interfaces the language provides. Promises represent asynchronous operations that will produce a single result, while supplies represent asynchronous operations that may produce a stream of values (which we might find more natural to call “events”) over time.

Perl may well embrace There’s More Than One Way To Do It. However, being able to quickly put together programs that combine our selection of preferred modules still hinges on there being things they do all agree to use. It’s typically the little, unspoken things: the basic data structures (scalars, arrays, hashes – and in Raku lazy iterators too), and that method calls look the same no matter what magic may lie behind their dispatch.

Promises and supplies are the basic asynchronous data structures. Whether we are working against sockets, message queues, time, domain events, or GUI events, we can talk about these sources of asynchronous values or value streams using the Promise and Supply types. And, since it’s easy to create a `Promise` or `Supply` and back it with whatever data we feel like, we can use them in writing tests for our asynchronous code too. Which brings me nicely to the next steps for my `Stomp::Client`.

### Sketching out the double I want

I tend to find that the point I actually have a concrete need for something is a good time to design and build it. It gives me a use case, or use cases, to check the design against. To move ahead with testing `Stomp::Client` – something I wish to do before evolving it further – I need a test double for `IO::Socket::Async`. Just as a stunt double stands in for a real actor for the purpose of doing dangerous things in a film, a test double stands in for a real object for the purpose of testing code that uses it. Stub objects and mock objects are common examples of test doubles.

I’m going to use my need to test `Stomp::Client` to drive out the design and implementation of a `Test::IO::Socket::Async`. I’ll just write tests as I’d like them to look, and then do what’s needed to make things work. First, I’ll add a few constants providing some test data, so I won’t have to repeat it:

```` raku
constant $test-host = 'localhost';
constant $test-port = 1234;
constant $test-login = 'user';
constant $test-password = 'correcthorsebatterystaple';
````

Then, pretending I have a `Test::IO::Socket::Async` already, I’ll take the `Stomp::Client` type and derive an anonymous type from it that overrides the socket-provider method I added back on day 1. I’ll arrange for the method to return my test socket instance.

```` raku
constant $test-socket = Test::IO::Socket::Async.new;
my \TestableClient = Stomp::Client but role {
    method socket-`provider` {
        $test-socket
    }
}
````

With the setup out of the way, it’s time to sketch out the first couple of tests. Checking that `Stomp::Client` connects to the host and port it was constructed with seems like a good start. So, here goes:

```` raku
my $client = TestableClient.new(
    host => $test-host, port => $test-port,
    login => $test-login, password => $test-password
);
my $connect-promise = $client.`connect`;
my $test-conn = await $test-socket.connection-made;
is $test-conn.host, $test-host, "Connected to the correct host";
is $test-conn.port, $test-port, "Connected to the correct port";
````

The first two statements look just like a normal usage of `Stomp::Client`. The connect method gives back a `Promise`, which for now I’ll just stick in a variable and worry about later. The third statement is where the test double is used. Since `IO::Socket::Async` is asynchronous, interactions with its test double also should be. An asynchronous socket may be used by multiple threads, and the code under test may end up interacting with it or creating it on a different thread than our test is running on. Therefore, the test double has a connection-made method that returns a Promise that will be kept when a connect call is made on the test double. The Promise will be kept with some object that represents a test connection, and provides the host and port that were supplied to connect. These are examined in the final two statements.

### Implementing the test double

First, the easy part. I’m not yet sure what the thing representing a test connection is going to look like when it’s completed, but I know it must have both a host and a port. So, I’ll just declare a simple class for it inside of `Test::IO::Socket::Async`:

```` raku
class Test::IO::Socket::Async {
    class Connection {
        has $.host;
        has $.port;
    }
    ...
}
````

Next, I’ll do the connect and connection-made methods. Some care is needed here, because there’s a race condition just waiting to happen. Two orderings of events are possible. Either:

1. The connect call is made on the test double
1. The connection-made call is made on the test double

Or:

1. The connection-made call is made on the test double
1. The connect call is made on the test double

It doesn’t matter which happens, but it does matter that the behaviour is the same. Also, while I don’t immediately have a use case for it, it’s clear that other users of such a test double may wish to test code that connects to many things. Therefore, I’ll add to `Test::IO::Socket::Async` a pair of attributes:

```` raku
has @!waiting-connects;
has @!waiting-connection-made-vows;
````

The first will hold `Connection` objects for any connect calls that were made, but that are not yet matched up with a connection-made call from the test code. The second plays the opposite role: it holds vows (the thing that is used to keep or break a `Promise`) for promises returned by connection-made that are not yet matched up with a connect call. The two methods will have a similar kind of symmetry:

```` raku
method connect(`Str` $host, `Int` $port) {
    my $conn = Connection.new(:$host, :$port);
    with @!waiting-connection-made-vows.shift {
        .keep($conn);
    }
    else {
        @!waiting-connects.push($conn);
    }
    my $p = Promise.new;
    $p.keep($conn);
    $p
}

method connection-`made` {
    my $p = Promise.new;
    with @!waiting-connects.shift {
        $p.keep($_);
    }
    else {
        @!waiting-connection-made-vows.push($p.vow);
    }
    $p
}
````

Note that a with block is like an if block, but it tests for definedness instead of truth, and sets `$_` to the tested object.

### Coping with concurrency

There’s one more important thing I need to take care of. Running the tests at this point reveals it. They hang. I try again. Ooh, a pass. Third time? Hang. So, what’s going on? Well, I only told a half-truth earlier when discussing the ordering between connect and connection-made. It’s also possible for the two to be called at the same time! Thankfully, that’s easily fixed. My class needs to become a monitor, which enforces one-at-a-time semantics on the methods of a particular instance. So, it’s off to the ecosystem:

````
zef install OO::Monitors
````

`OO::Monitors` uses Raku’s meta-programming features to good effect. All that is needed to make a class into a monitor is to replace the class declarator with a `monitor` declarator, which is provided by `OO::Monitors`. Here’s how my test double ends up looking:

```` raku
use OO::Monitors;

monitor Test::IO::Socket::Async {
    class Connection {
        has $.host;
        has $.port;
    }

    has @!waiting-connects;
    has @!waiting-connection-made-vows;

    method connect(`Str` $host, `Int` $port) {
        my $conn = Connection.new(:$host, :$port);
        with @!waiting-connection-made-vows.shift {
            .keep($conn);
        }
        else {
            @!waiting-connects.push($conn);
        }
    }

    method connection-`made` {
        my $p = Promise.new;
        with @!waiting-connects.shift {
            $p.keep($_);
        }
        else {
            @!waiting-connection-made-vows.push($p.vow);
        }
        $p
    }
}
````

Not bad.

### In denial

This is a promising start. That’s the great thing about Raku: every `start { … }` is `Promise`-ing. But something is just a little off. While it would be easy to plough ahead and write the next test on the happy path – where the connection to a STOMP server is successful – an even easier one to write is the case where the socket connection fails, and `Stomp::Client` never gets so far as doing the handshake. But right now, there’s no way to write such a test. The connect Promise is immediately kept when a connect call is made in the test.

Once again, I’ll write the test as I’d like to express it:

```` raku
my $client = TestableClient.new(
    host => $test-host, port => $test-port,
    login => $test-login, password => $test-password
);
my $connect-promise = $client.`connect`;
my $test-conn = await $test-socket.connection-made;
$test-conn.deny-`connection`;
dies-ok { await $connect-promise },
    "Failed STOMP server connection breaks connect Promise";
````

Now for the changes. First, I’ll extend `Connection` a bit. It will hold the `Promise` that will be returned by the connect method. Then, the accept-connection and deny-connection methods will use the vow on that `Promise`.

```` raku
class Connection {
    has $.host;
    has $.port;
    has $.connection-promise = Promise.new;
    has $!connection-vow = $!connection-promise.vow;

    method accept-`connection` {
        $!connection-vow.keep(self);
    }

    method deny-connection($exception = "Connection refused") {
        $!connection-vow.break($exception);
    }
}
````

Finally, back in `Test::IO::Socket::Async`, I’ll update the connect method to just return this `Promise`:

```` raku
method connect(`Str` $host, `Int` $port) {
    my $conn = Connection.new(:$host, :$port);
    with @!waiting-connection-made-vows.shift {
        .keep($conn);
    }
    else {
        @!waiting-connects.push($conn);
    }
    $conn.connection-promise
}
````

And the test passes. Hurrah. This means `Stomp::Client` isn’t failing to pass on socket connect errors to its consumer, which is certainly a test worth having.

### Testing what was sent

Now I’d like to start filling out a test case for the CONNECT handshake that Stomp::Client should do with a STOMP server. Here’s the first bit, checking that a well-formed CONNECT message is sent with the correct information:

```` raku
my $client = TestableClient.new(
    host => $test-host, port => $test-port,
    login => $test-login, password => $test-password
);
my $connect-promise = $client.`connect`;
my $test-conn = await $test-socket.connection-made;
$test-conn.accept-`connection`;

my $message-text = await $test-conn.sent-data;
my $parsed-message = Stomp::Parser.parse($message-text);
ok $parsed-message, "Client sent valid message to server";
my $message = $parsed-message.made;
is $message.command, "CONNECT", "Client sent a CONNECT command";
is $message.headers<login>, $test-login, "Client sent login";
is $message.headers<passcode>, $test-password, "Client sent password";
ok $message.headers<accept-version>:exists, 'Client sent accept-version header';
is $message.body, "", "Client sent no message body";
````

The only new thing here with regard to socket testing is the sent-data method on a test connection. It returns a `Promise` that will be kept when something is sent using the socket. It will be kept with what was sent. The code that follows checks that the message contains what was expected of it. Note that a few things are done here to avoid test fragility:

- The headers are tested in a way that does not depend on their ordering, as any order is valid
- The accept-version is not hard-coded, so the test will not break if the module is later updated to cope with newer protocol versions

I was able to use the previously factored out `Stomp::Parser` in order to avoid testing directly against the text of the message, which would result in an overly-specific test.

So, what happens in my test `Connection` class to support this? First of all, it’s time to make it a monitor, since I’m about to give it mutable state:

```` raku
monitor Connection {
    ...
}
````

I’ll then do a somewhat similar thing as I did when testing connects: have an array of sent things and an array of vows to keep. Here’s the code that I add to the `Connection` class:

```` raku
has @!sent;
has @!waiting-sent-vows;

method print(`Str` $s) {
    @!sent.push($s);
    self!keep-sent-`vows`;
    self!kept-`promise`;
}

method write(Blob $b) {
    @!sent.push($b);
    self!keep-sent-`vows`;
    self!kept-`promise`;
}

method sent-`data` {
    my $p = Promise.new;
    @!waiting-sent-vows.push($p.vow);
    self!keep-sent-`vows`;
    $p
}

method !keep-sent-`vows` {
    while all(@!sent, @!waiting-sent-vows) {
        @!waiting-sent-vows.shift.keep(@!sent.shift);
    }
}

method !kept-`promise` {
    my $p = Promise.new;
    $p.keep(True);
    $p
}
````

The switch to a monitor is critical to avoiding various races that could easily occur. The `print` and `write` methods return a kept `Promise` in order to match the API of `IO::Socket::Async` itself. And…the test is happy.

### Testing what was received

My previous test wasn’t quite a complete test of the connection process, since the `Promise` returned by `Stomp::Client`’s connect method is not completed until a CONNECTED frame is received from the server. As usual, I’ll sketch out the test I want to have:

```` raku
$test-conn.receive-data: Stomp::Message.new(
    command => 'CONNECTED',
    headers => ( version => '1.2' )
);
ok (await $connect-promise), "CONNECTED message completes connection";
````

`IO::Socket::Async` uses a `Supply` for incoming data received by the socket. That makes it rather straightforward to fake up. First, I’ll add an attribute to my test `Connection` monitor that holds a `Supplier`:

```` raku
has $!received = Supplier.new;
````

The test version of `IO::Socket::Async`’s `Supply` method will simply return the `Supply` that goes with it:

```` raku
method Supply {
    $!received.Supply
}
````

And then I’ll use the `Supplier` to emit the data we want to fake the socket receiving, taking care to make sure I only pass along blobs of binary data or strings, conveniently stringifying any other type that isn’t already one:

```` raku
multi method receive-data(`Str` $data) {
    $!received.emit($data);
}
multi method receive-data(Blob $data) {
    $!received.emit($data);
}
````

And with that, I’ve a passing test.

### A module is born

I developed `Test::IO::Socket::Async` at the top of the test file I was fleshing out the client tests in. However, it really wants to be a separate module, so others can use it in their own tests. So, I gave it [its own git repo](https://github.com/jnthn/p6-test-io-socket-async), with a META6.json. Even before adding it to the module list, I could simply do:

````
zef install .
````

And use it from my client tests:

```` raku
use Test::IO::Socket::Async;
````

Which I then [committed](https://github.com/jnthn/p6-stomp/commit/55c1801c1eeb0da6edbde49a50da3fe9af03761e).

### And what next?

The tests only cover one method of `Stomp::Client`. However, it should be fairly easy to test the rest, now I’ve got a test double for `IO::Socket::Async`. This also means I can more confidently move on to implementing some further aspects of the client, working test-first to add features such as unsubscription, disconnecting, and transactions.
