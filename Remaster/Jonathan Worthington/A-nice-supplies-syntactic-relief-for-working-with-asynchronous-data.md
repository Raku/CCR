# A nice supplies: syntactic relief for working with asynchronous data
    
*Originally published on [14 December 2015](https://perl6advent.wordpress.com/2015/12/14/day-14-a-nice-supplies-syntactic-relief-for-working-with-asynchronous-data/) by Jonathan Worthington.*

Asynchronous data is all around us. What is it? It’s data that arrives whenever it pleases, as opposed to when we ask for it. Some common examples are:

- GUI events
- Data arriving over an async socket
- Messages arriving from a message queue
- Ticks of a timer
- File change notifications
- Signals

These contrast with synchronous data, which we get when we ask for it. For example, when we query a database and iterate the resulting rows, or iterate through file system entries in a directory, we block until the data we wish to have is available.

Our programming languages tend to be pretty good about synchronous data, giving us a range of syntactic constructs for producing and processing it. For example, in Raku we have for loops for consuming streams of synchronously produced values, and gather blocks for producing them – perhaps doing so by in turn using for loops to consume other synchronous data sources. Inside for and gather, we’re free to use state (kept in variables), and use our comfortable range of conditionals (if, when, etc.) That is to say, we’re free to act like normal, down to earth, imperative programmers in dealing with our synchronous data. Sure, sometimes something just looks far nicer using the functional style, and we map, grep, zip, and reduce our way to the solution. But some problems are just unnatural – at least for most of us, me included – to see in that way.

In Raku, we have a common interface for talking about things that produce values over time – that is, synchronous data. These things do the `Iterable` role, and work in terms of `Iterator` objects. You never really see an `Iterator` in day to day Raku, and instead see the `Seq` type. These `Seq`s are the things `gather` blocks produce, and `for` loops can consume.

In the last years, we introduced supplies to Raku. Supplies are our common interface for talking about asynchronous data. These have, from the beginning, been rather well received. With supplies, you can grep UI events, map file system notifications, and zip whatever you fancied with ticks of a timer. And that’s just great when it’s easy to think about your problem in functional terms. But what about the rest of the time?

In the last year, we’ve also added `supply` / `react` blocks, along with the `whenever` asynchronous looping construct. In this post, we’ll take a look at how they might be used.

### STOMP!

As I wrote the list of sources of asynchronous data at the start of this post, I realized that there was only one of them that I’d not yet done in Raku: working with message queues. Hmm. Two hours until midnight. Advent post needs completing before I sleep. Challenge accepted!

10 minutes later, and I’ve RabbitMQ happily installed and am reading the [STOMP specification](http://stomp.github.io/stomp-specification-1.2.html). STOMP is a simple text-oriented message protocol – that is, a text-based way to deal with message queues. Within an hour, I’d got a working STOMP client handling the absolute basics of sending messages to a queue and subscribing to a queue to get messages. So, let’s take a look at how I did it.

First, I sketched in a `Stomp::Client` class. I figured it would need the host and port we want to connect to, the connection credentials (yes, yes, this is not the height of security engineering), and something to hold the socket representing the connection to the server.

```` raku
class Stomp::Client {
    has Str $.host is required;
    has Int $.port is required;
    has Str $.login = 'guest';
    has Str $.password = 'guest';
    has $!connection;
}
````

So, let’s get connected. The connect method will contain a start block, because we want it to function asynchronously. This means the method will return a `Promise` that the caller can `await`. To connect to a stomp server, you establish a TCP connection and send a CONNECT frame:

```` raku
method `connect` {
    start {
        my $conn = await IO::Socket::Async.connect($!host, $!port);
        await $conn.print: qq:to/FRAME/;
            CONNECT
            accept-version:1.2
            login:$!login
            passcode:$!password
            
            \0
            FRAME
        True
    }
}
````

But…then what? Well, then you wait for the server to either return a CONNECTED frame or an ERROR frame. Hm, seems we’ve some work to do. First is to translate the BNF from the STOMP specification into a Raku grammar:

```` raku
my grammar StompMessage {
    token TOP {
        <command> \n
        [<header> \n]*
        \n
        <body>
        \n*
    }
    token command {
        < CONNECTED MESSAGE RECEIPT ERROR >
    }
    token header {
        <header-name> ":" <header-value>
    }
    token header-name {
        <-[:\r\n]>+
    }
    token header-value {
        <-[:\r\n]>*
    }
    token body {
        <-[\x0]>* )> \x0
    }
}
````

Note it’s lexically scoped inside of our `STOMP::Client` class. So is the following little message data structure:

```` raku
my class Message {
    has $.command;
    has %.headers;
    has $.body;
}
````

An `IO::Socket::Async` connection exposes incoming data as a `Supply`. There are a few things to consider:

- A message may be spread over multiple packets
- Two messages may be in one packet
- The next packet may arrive while we’re processing the current one, and since Raku delivers I/O notifications on the thread pool – like various other languages – we might worry about data races

In fact, the third point is a non-problem: Raku promises that, unless you go out of your way to avoid it, supplies are serial, and will only have you processing one message at a time on a given message pipeline. Supplies are a tool for taming concurrency rather than introducing it.

Now, if I was writing this synchronously, and I wanted to expose a `Seq` of the incoming messages, I’d use a `gather` block, keep myself a buffer, recv each incoming chunk of data from the socket, and try to parse a new message at the start of the buffer. Whenever I got a message I’d take it. What about with supplies? Here’s how it looks:

```` raku
method !process-messages($incoming) {
    supply {
        my $buffer = '';
        whenever $incoming -> $data {
            $buffer ~= $data;
            while StompMessage.subparse($buffer) -> $/ {
                $buffer .= substr($/.chars);
                if $<command> eq 'ERROR' {
                    die ~$<body>;
                }
                else {
                    emit Message.new(
                        command => ~$<command>,
                        headers => $<header>
                            .map({ ~.<header-name> => ~.<header-value> })
                            .hash,
                        body => ~$<body>
                    );
                }
            }
        }
    }
}
````

Taking it from the top, `$incoming` will be the `Supply` of data arriving from the socket, decoded to strings. We wrap the code in this method up in a `supply` block, since we’d like to return a new `Supply`. We declare `$buffer`, to hold data we’ve yet to parse. In this case, our thread safety is fairly trivial: `$incoming` will deliver a message at a time. But what if we were going to bring together data from many supplies? We’d still be fine: a `supply` block promises that, per tapping of the `Supply`, only one thread will ever be allowed in the code inside of the `supply` block at a time.

The `whenever` construct is a asynchronous loop. It taps the supply we specify, and the loop body will run whenever a value is emitted by that supply. In our case, that is every time we get data from the socket. We concatenate the incoming `$data` onto the `$buffer`. We then try to parse a message at the start of the buffer (`subparse` means that we don’t mind if we don’t reach the end of the buffer, unlike `parse` which will complain if it doesn’t completely parse the incoming string). When we do parse data, we lop it off the start of the buffer.

For each message we parse, we first see if it’s an ERROR frame; if so, we simply die with the message. A die inside a whenever block will propagate the error to whatever tapped the supply, so errors will not be lost. Otherwise, we’ve some kind of more interesting message; we turn the parsed data into a `Message` instance and `emit` it.

A `supply` block gives an “on-demand” supply. Each tap performed on the block will run the `supply` block, which in turn will tap each of the `whenever`s. That’s the right thing in most cases, but for my `Stomp::Client` I’d like to have various bits of code tap the same messages, to look for interesting things. One of these bits of code will look for a single CONNECTED message. So, I’ll add an `$!incoming` attribute to my class:

```` raku
has $!incoming;
````

And then, after establishing the connection to the message queue server, do this:

```` raku
$!incoming = self!process-messages($conn.Supply).share;
````

That is, I share the result of processing messages out amongst everything that is interested. And interested things will tap the `$!incoming` supply and filter out what they care about. For example, here’s how I create a `Promise` that will be kept when we receive a CONNECTED frame:

```` raku
my $connected = $!incoming
    .grep(*.command eq 'CONNECTED')
    .head(1)
    .Promise;
````

Here is the connect method in full:

```` raku
method connect {
    start {
        my $conn = await IO::Socket::Async.connect($!host, $!port);
        $!incoming = self!process-messages($conn.Supply).share;
        
        my $connected = $!incoming
            .grep(*.command eq 'CONNECTED')
            .head(1)
            .Promise;
        await $conn.print: qq:to/FRAME/;
            CONNECT
            accept-version:1.2
            login:$!login
            passcode:$!password
            
            \0
            FRAME
        await $connected;
        $!connection = $conn;
        
        True
    }
}
````

Sending messages is easy:

```` raku
method send($topic, $body) {
    self!ensure-connected;
    $!connection.print: qq:to/FRAME/;
        SEND
        destination:/queue/$topic
        content-type:text/plain
 
        $body\0
        FRAME
}
````

And subscription is implemented using another `supply` block, and a bit of simple filtering on the incoming message:

```` raku
method subscribe($topic) {
    self!ensure-connected;
    state $next-id = 0;
    supply {
        my $id = $next-*id*++;
        
        $!connection.print: qq:to/FRAME/;
            SUBSCRIBE
            destination:/queue/$topic
            id:$id
 
            \0
            FRAME
        
        whenever $!incoming {
            if .command eq 'MESSAGE' && .headers<subscription> == $id {
                emit .body;
            }
        }
    }
}
````

And with that, we have a working STOMP client. Let’s try it:

```` raku
my $queue = Stomp::Client.new(host => 'localhost', port => 61613);
await $queue.`connect`;
await $queue.send("test", "hello world");
react {
    whenever $queue.subscribe('test') {
        .say;
    }
}
````

Here, for the first time, we encounter the `react` block. What’s that? Well, if you imagine that `supply` blocks are a little like `gather` – that is, used to create something that can produce values – a `react` block is for the places you might normally use a for loop when processing synchronous data. However, in the asynchronous world you’re usually interested in a range of things that might happen. A `react` block runs, sets up all the `whenever`s, and then blocks until either all of the supplies tapped by whenever blocks are done, or the `done` control operator is used somewhere inside of react.

### A little example

Suppose that we wanted to build a simple monitoring system. Workers “sign on”, and must send us a ping every 10 seconds. If they fail to do so, then a monitor will report this. Workers can sign off when finished. Here is the worker process:

```` raku
sub MAIN($name) {
    my $queue = Stomp::Client.new(host => 'localhost', port => 61613);
    await $queue.`connect`;
    $queue.send('signon', $name);
    react {
        whenever Supply.interval(10, 5) {
            if <y y n>.pick eq 'y' {
                $queue.send('ping', $name);
            }
        }
    
        whenever signal(SIGINT) {
            $queue.send('signoff', $name);
            done;
        }
    }
}
````

We start it from the command line with a name. Every 10 seconds it sends a ping – or at least, two thirds of the time it will. And if we hit Ctrl+C the worker signs off.

Next, here’s the monitor:

```` raku
my $queue = Stomp::Client.new(host => 'localhost', port => 61613);
await $queue.connect;
react {
    my %last-active;
 
    whenever $queue.subscribe('signon') -> $name {
        %last-active{$name} = now;
    }
  
    whenever $queue.subscribe('ping') -> $name {
        %last-active{$name} = now;
    }
  
    whenever $queue.subscribe('signoff') -> $name {
        %last-active{$name}:delete;
    }
 
    whenever Supply.interval(10) {
        for %last-active.kv -> $name, $last-ping {
            if now - $last-ping > 11 {
                say "No ping from $name";
            }
        }
    }
}
````

Note that the `react` block, like `supply` block, enforces that only a single thread at a time may be operating across the various `whenever` blocks, so the `%last-active` hash is safe. We have three subscriptions to queues, and every ten seconds look for missing pings. We give an extra second’s grace on those.

Notice how, by exposing the message queue in terms of supplies, we are able to effortlessly compose this asynchronous data with both signals and time. This is where the real power of a uniform interface to asynchronous data comes in. And, with a little syntactic support, we are no longer required to put our functional hat on to wield that power.
