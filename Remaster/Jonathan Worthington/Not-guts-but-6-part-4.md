# Not guts, but 6: part 4
    
*Originally published on [2016-01-09](https://6guts.wordpress.com/2016/01/09/not-guts-but-6-part-4/) by Jonathan Worthington.*

I’ve managed to marry myself into getting two Christmases a year. The Orthodox one takes place on the 7th of January, so I’ve been celebrating that. And now the trek back home is underway, stopping off to enjoy the snow and nice mood in Kiev for a couple of nights before returning to Prague and normal life and work. (And, if you’re wondering, yes, I shall eat a Chicken Kiev while here.)

In today’s post, I’ll be keeping it simple: improving my test coverage, fixing a couple of small design issues, supporting unsubscription, and using a new little module I wrote to deal with a pesky data race.

## Tweaking send

The next easy thing to write tests for is the send method, so I’ll start there. Here’s the tests:

```` raku
constant $test-destination = "/queue/shopping";
constant $test-body = "Buy a karahi!";
my $send-promise = $client.send($test-destination, $test-body);
$message-text = await $test-conn.sent-data;
$parsed-message = Stomp::Parser.parse($message-text);
ok $parsed-message, "send method sent well-formed message";
$message = $parsed-message.made;
is $message.command, "SEND", "message has SEND command";
is $message.headers<destination>, $test-destination, "destination header correct";
is $message.headers<content-type>, "text/plain", "has default content-type header";
is $message.body, $test-body, "message had expected body";
is $send-promise.status, Kept, "Promise retunred by send was kept";
````

A little wordy, but there’s nothing new going on. One of them fails, though:

```` raku
not ok 13 - destination header correct
# Failed test 'destination header correct'
# at t\client.t line 75
# expected: '/queue/shopping'
#      got: '/queue//queue/shopping'
````

Hmm. Let me look at send:

```` raku
method send($topic, $body) {
    self!ensure-connected;
    $!connection.print: Stomp::Message.new:
        command => 'SEND',
        headers => (
            destination  => "/queue/$topic",
            content-type => "text/plain"
        ),
        body => $body;
}
````

Ah, there it is. My advent post hard-coded the RabbitMQ queue path, but the module really should allow full control over the destination. That’s easily fixed, and I’ll take the time to do a little rename also:

```` raku
method send($destination, $body) {
    self!ensure-connected;
    $!connection.print: Stomp::Message.new:
        command => 'SEND',
        headers => (
            destination  => $destination,
            content-type => "text/plain"
        ),
        body => $body;
}
````

It’s easy to under-value simple things like renaming variables to keep up with the evolving language of a design, but I’ve found it to be really worthwhile. I tend to call such refactors “domain refactors”. They are often small and subtle, but together they help make the code easier to follow, improve consistency, and so ease future development. Anyway, [committed](https://github.com/jnthn/p6-stomp/commit/116760c55ed7ff5bbd64efcb189f64d14e9b758f)!

There’s one other thing that stands out to me here, which is that it’d be good to be able to choose the content type also. First, a test:

```` raku
constant $test-type = "text/html";
$send-promise = $client.send($test-destination, $test-body,
    content-type => $test-type);
$message = Stomp::Parser.parse(await $test-conn.sent-data).made;
is $message.headers<content-type>, $test-type, "can set content-type header";
````

It’s easily implemented, adding an optional named parameter that defaults to the text/plain content type. With the variable names perfectly matching the header names, this means I can get some repetition out of the code with the variable colon pair syntax:

```` raku
method send($destination, $body, :$content-type = "text/plain") {
    self!ensure-connected;
    $!connection.print: Stomp::Message.new:
        command => 'SEND',
        headers => ( :$destination, :$content-type ),
        body => $body;
}
````

And there’s my [second commit](https://github.com/jnthn/p6-stomp/commit/5915ce65901692a46749d501e9de6d63e41db325).

### Subscription and unsubscription

Now I’ll turn to receiving messages. Once again, the tests aren’t too difficult to write, and follow a sufficiently common pattern I’m already starting to ponder whether it’s time to factor things out a bit:

```` raku
my $sub-supply = $client.subscribe($test-destination);
isa-ok $sub-supply, Supply, "subscribe returns a Supply";
my $sent-data-promise = $test-conn.sent-data;
is $sent-data-promise.status, Planned, "did not yet send subscription request";
my @messages;
my $sub-tap = $sub-supply.tap({ @messages.push($_) });
$message-text = await $sent-data-promise;
$parsed-message = Stomp::Parser.parse($message-text);
ok $parsed-message, "subscribe method sent well-formed message";
$message = $parsed-message.made;
is $message.command, "SUBSCRIBE", "message has SUBSCRIBE command";
is $message.headers<destination>, $test-destination, "destination header correct";
ok $message.headers<id>:exists, "had an id header";
````

One fails. Once again, it’s the destination header. Here’s how my subscribe method looks:

```` raku
method subscribe($topic) {
    self!ensure-connected;
    state $next-id = 0;
    supply {
        my $id = $next-*id*++;

        $!connection.print: Stomp::Message.new:
            command => 'SUBSCRIBE',
            headers => (
                destination => "/queue/$topic",
                id => $id
            );

        whenever $!incoming {
            if .command eq 'MESSAGE' && .headers<subscription> == $id {
                emit .body;
            }
        }
    }
}
````

Ah, yes, it’s the topic/destination discrepancy again. And, given I have a `$id` variable, I’ll be able to use the colon pair variable form again. Here goes:

```` raku
method subscribe($destination) {
    self!ensure-connected;
    state $next-id = 0;
    supply {
        my $id = $next-*id*++;

        $!connection.print: Stomp::Message.new:
            command => 'SUBSCRIBE',
            headers => ( :$destination, :$id );

        ...
    }
}
````

[That’s better](https://github.com/jnthn/p6-stomp/commit/c61d044d5fcc4c7b4ff94ab1ea01d9330f0f0444) but…something is not quite right still. I cheated a bit when I wrote this for the advent post, and nobody was observant enough to call me out on it – so I guess I’ll just have to out myself. There’s a data race on `$next-id`, should two threads end up making subscriptions at the same time. It’s not likely to crop up, but it still wants dealing with. I’ll do that in a moment.

Before that, I’d like to get unsubscription handled. Closing the tap should do an unsubscribe. First, some tests:

```` raku
my $expected-id = $message.headers<id>;
$sub-tap.close;
$message-text = await $test-conn.sent-data;
$parsed-message = Stomp::Parser.parse($message-text);
ok $parsed-message, "unsubscribing sent well-formed message";
$message = $parsed-message.made;
is $message.command, "UNSUBSCRIBE", "message has UNSUBSCRIBE command";
is $message.headers<id>, $expected-id, "id matched the subscription";
````

This hangs on the `await`, because at present nothing is sent when the tap on the supply is closed. Happily, the `CLOSE` phaser makes it easy to write logic that will be run on tap close:

```` raku
method subscribe($destination) {
    self!ensure-connected;
    state $next-id = 0;
    supply {
        my $id = $next-*id*++;

        $!connection.print: Stomp::Message.new:
            command => 'SUBSCRIBE',
            headers => ( :$destination, :$id );
        CLOSE {
            $!connection.print: Stomp::Message.new:
                command => 'UNSUBSCRIBE',
                headers => ( :$id );
        }

        ...
    }
}
````

I could write the `CLOSE` phaser wherever I wanted inside of the `supply` block, and so chose to put it near the logic to send a SUBSCRIBE message. Phasers are often handy in that way: they specify code that runs at certain phases in the program, and so free me to place that code in the most helpful place for the reader. And with that, the tests pass. [Commit!](https://github.com/jnthn/p6-stomp/commit/d0eee9f762c1f3fd2db391441dfc209b939ae6ba)

### Dealing with that data race

So, how to deal with the getting ascending IDs in the safe way? There are a couple of options that come to mind:

- Make `Stomp::Client` a monitor. That’s probably overkill, however. It’s quite capable of otherwise having methods invoked on it concurrently, since it has no state beyond that set up in connect.
- Use `Lock`. But using `Lock` is generally a last resort, not a first one.

What I really want is a mechanism that can just give me ascending integers. If I generalize that thought a little, I want a safe way to grab the next value available from some sequence. And sequences of values in Raku are typically handled by iterators. However, an Iterator is only safe for consumption from one thread at a time.

So, I wrote another little module: [`Concurrent::Iterator`](https://github.com/jnthn/p6-concurrent-iterator). It’s weighs in at [well under 50 lines ](https://github.com/jnthn/p6-concurrent-iterator/blob/master/lib/Concurrent/Iterator.pm6)of code, and does a bit more than I need for this use case. Using it, I can just ask for a concurrent iterator over the range of integers from 1 up to infinity, and keep it around in an attribute:

```` raku
has $!ids = concurrent-iterator(1..Inf);
````

And then [use it in subscribe](https://github.com/jnthn/p6-stomp/commit/09e2557ddd9431218f8fe1694f38d572fe3537da):

```` raku
method subscribe($destination) {
    self!ensure-connected;
    supply {
        my $id = $!ids.pull-one;
        ...
    }
}
````

### Message arrival

I’m almost up to having tests covering all the stuff that matters in `Stomp::Client`, but there’s one glaring exception: receiving messages from a subscription. I already set up an array that such messages can be pushed to:

```` raku
my $sub-tap = $sub-supply.tap({ @messages.push($_) });
````

So, I’ll now sneak some extra tests in between the subscription and unsubscription tests:

```` raku
my $expected-id = $message.headers<id>;
is @messages.elems, 0, "no messages received yet";
$test-conn.receive-data: Stomp::Message.new(
    command => 'MESSAGE',
    headers => ( subscription => $expected-id ),
    body    => $test-body
);
is @messages.elems, 1, "one message now received";
isa-ok @messages[0], Stomp::Message, "it's a Stomp::Message";
is @messages[0].command, "MESSAGE", "has the command MESSAGE";
is @messages[0].body, $test-body, "has the correct body";
````

And…epic fail!

```` raku
not ok 26 - it's a Stomp::Message
# Failed test 'it's a Stomp::Message'
# at t\client.t line 108
# Actual type: Str
````

Since the `Stomp::Message` headers may well contain relevant information for processing of the message – such as a content-type header, it would be a good idea to pass those along to the consumer. Thankfully, that’s an easy change to the whenever block, to emit the `Stomp::Message` itself rather than its body:

```` raku
whenever $!incoming {
    if .command eq 'MESSAGE' && .headers<subscription> == $id {
        emit $_;
    }
}
````

And that’ll be [the final commit](https://github.com/jnthn/p6-stomp/commit/d279a1c0cf26f564565f424b638cb6b8a7e7c399) for this time.

### I live to server

Next time, I’ll add support to `Test::IO::Socket::Async` for testing listening sockets, and then use it to start implementing a `Stomp::Server` class.
