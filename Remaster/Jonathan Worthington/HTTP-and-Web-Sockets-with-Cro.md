# HTTP and Web Sockets with Cro
    
*Originally published on [9 December 2017](https://perl6advent.wordpress.com/2017/12/09/http-and-web-sockets-with-cro/) by Jonathan Worthington.*

It’s not only Christmas time when gifts are given. This summer at the Swiss Perl Workshop – beautifully situated up in the Alps – I had the pleasure of revealing [Cro](http://cro.services/). Cro is a set of libraries for building services in Raku, together with a little development tooling to stub, run, and trace services. Cro is intially focused on building services with HTTP (including HTTP/2.0) and web sockets, but early support for ZeroMQ is available, and a range of other options are planned for the future.

## Reactive pipelines

Cro follows the Perl design principle of making the easy things easy, and the hard things possible. Much like Git, Cro can be thought of as having porcelain (making the easy things easy) and plumbing (making the hard things possible). The plumbing level consists of components that are composed to form pipelines. The components come in different shapes, such as sources, transforms, and sinks. Here’s a transform that turns a HTTP request into a HTTP response:

```` raku
use Cro;
use Cro::HTTP::Request;
use Cro::HTTP::Response;

class MuskoxApp does Cro::Transform {
    method consumes() { Cro::HTTP::Request }
    method produces() { Cro::HTTP::Response }
    method transformer(Supply $pipeline --> Supply) {
        supply whenever $pipeline -> $request {
            given Cro::HTTP::Response.new(:$request, :200status) {
                .append-header: "Content-type", "text/html";
                .set-body: "Muskox Rocks!\n".encode('ascii');
                .emit;
            }
        }
    }
}
````

Now, let’s compose it with a TCP listener, a HTTP request parser, and a HTTP response serializer:

```` raku
use Cro::TCP;
use Cro::HTTP::RequestParser;
use Cro::HTTP::ResponseSerializer;

my $server = Cro.compose:
    Cro::TCP::Listener.new(:port(4242)),
    Cro::HTTP::RequestParser.new,
    MuskoxApp,
    Cro::HTTP::ResponseSerializer;
````

That gives back a `Cro::Service`, which we can now `start`, and `stop` upon Ctrl+C:

```` raku
$server.start;
react whenever signal(SIGINT) {
    $server.stop;
    exit;
}
````

Run it. Then `curl` it.

````
$ curl http://localhost:4242/
Muskox Rocks!
````

Not bad. But what if we wanted a HTTPS server? Provided we’ve got key and certificate files handy, that’s just a case of replacing the TCP listener with a TLS listener:

```` raku
use Cro::TLS;

my $server = Cro.compose:
    Cro::TLS::Listener.new(
        :port(4242),
        :certificate-file('certs-and-keys/server-crt.pem'),
        :private-key-file('certs-and-keys/server-key.pem')
    ),
    Cro::HTTP::RequestParser.new,
    MuskoxApp,
    Cro::HTTP::ResponseSerializer;
````

Run it. Then `curl -k` it.

````
$ curl -k https://localhost:4242/
Muskox Rocks!
````

And middleware? That’s just another component to compose into the pipeline. Or, seen another way, with Cro everything is middleware. Even the request parser or response serializer can be easily replaced, should the need arise (which sounds like an odd thing to need, but that’s effectively what implementing FastCGI would involve).

So, that’s how Cro is plumbed. It also requires an amount of boilerplate to work at this level. Bring in the porcelain!

## HTTP server, the easy way

The `Cro::HTTP::Server` class gets rid of the boilerplate of building the HTTP processing pipeline. The example from earlier becomes just:

```` raku
use Cro;
use Cro::HTTP::Server;

class MuskoxApp does Cro::Transform {
    method consumes() { Cro::HTTP::Request }
    method produces() { Cro::HTTP::Response }
    method transformer(Supply $pipeline --> Supply) {
        supply whenever $pipeline -> $request {
            given Cro::HTTP::Response.new(:$request, :200status) {
                .append-header: "Content-type", "text/html";
                .set-body: "Muskox Rocks!\n".encode('ascii');
                .emit;
            }
        }
    }
}

my $server = Cro::HTTP::Server.new: :port(4242), :application(MuskoxApp);
$server.start;
react whenever signal(SIGINT) {
    $server.stop;
    exit;
}
````

There’s no magic here; it really is just a more convenient way to compose a pipeline. And while that’s only so much of a saving for `HTTP/1.*`, a `HTTP/2.0` pipeline involves some more components, and a pipeline that supports both is a bit more involved still. By comparison, it’s easy to configure `Cro::HTTP::Server` to do HTTPS with support for both HTTP/1.1 and HTTP/2.0:

```` raku
my %tls =
    :certificate-file('certs-and-keys/server-crt.pem'),
    :private-key-file('certs-and-keys/server-key.pem');
my $server = Cro::HTTP::Server.new: :port(4242), :application(MuskoxApp),
    :%tls, :http<1.1 2>;
````

## The route to happiness

A web application in Cro is ultimately always a transform that turns a HTTP request into a HTTP response. It’s very rare to want to process all requests in exactly the same way, however. Typically, different URLs should be routed to different handlers. Enter `Cro::HTTP::Router`:

```` raku
use Cro::HTTP::Router;
use Cro::HTTP::Server;

my $application = route {
    get -> {
        content 'text/html', 'Do you like dugongs?';
    }
}

my $server = Cro::HTTP::Server.new: :port(4242), :$application;
$server.start;
react whenever signal(SIGINT) {
    $server.stop;
    exit;
}
````

The object returned by a `route` block does the `Cro::Transform` role, meaning it would work just fine to use it with `Cro.compose(...)` plumbing too. It’s a good bit more convenient to write an application using the router, however! Let’s look at the `get` call a little more closely:

```` raku
get -> {
    content 'text/html', 'Do you like dugongs?';
}
````

Here, `get` is saying that this handler will only deal with HTTP `GET` requests. The empty signature of the pointy block means no URL segments are expected, so this route only applies to `/`. Then, instead of having to make a response object instance, add a header, and encode a string, the `content` function does it all.

The router is built to take advantage of Raku signatures, and also to behave in a way that will feel natural to Raku programmers. Route segments are set up by declaring parameters, and literal string segments match literally:

```` raku
get -> 'product', $id {
    content 'application/json', {
        id => $id,
        name => 'Arctic fox photo on canvas'
    }
}
````

A quick check with `curl` shows that it takes care of serializing the JSON for us also:

````
$ curl http://localhost:4242/product/42
{"name": "Arctic fox photo on canvas","id": "42"}
````

The JSON body serializer is activated by the content type. It’s possible, and pretty straightforward, to implement and plug in your own body serializers.

Want to capture multiple URL segments? Slurpy parameters work too, which is handy in combination with `static` for serving static assets, perhaps multiple levels of directories deep:

```` raku
get -> 'css', *@path {
    static 'assets/css', @path;
}
````

Optional parameters work for segments that may or may not be provided. Using subset types to constrain the allowed values work too. And `Int` will only accept requests where the value in the URL segment parses as an integer:

```` raku
get -> 'product', Int $id {
    content 'application/json', {
        id => $id,
        name => 'Arctic fox photo on canvas'
    }
}
````

Named parameters are used to receive query string arguments:

```` raku
get -> 'search', :$query {
    content 'text/plain', "You searched for $query";
}
````

Which would be populated in a request like this:

````
$ curl http://localhost:4242/search?query=llama
You searched for llama
````

These too can be type constrained and/or made required (named parameters are optional by default in Raku). The Cro router tries to help you do HTTP well by giving a 404 error for failure to match a URL segments, 405 (method not allowed) when segments would match but the wrong method is used, and 400 when the method and segments are fine, but there’s a problem with the query string. Named parameters, through use of the `is header` and `is cookie` traits, can also be used to accept and/or constrain headers and cookies.

Rather than chugging through the routes one at a time, the router compiles all of the routes into a Raku grammar. This means that routes will be matched using an NFA, rather than having to chug through them one at a time. Further, it means that the Raku longest literal prefix rules apply, so:

```` raku
get -> 'product', 'index' { ... }
get -> 'product', $what { ... }
````

Will always prefer the first of those two for a request to `/product/index`, even if you wrote them in the opposite order:

```` raku
get -> 'product', $what { ... }
get -> 'product', 'index' { ... }
````

## Middleware made easier

It’s fun to say that HTTP middleware is just a `Cro::Transform`, but it’d be less fun to write if that was all Cro had to offer. Happily, there are some easier options. A `route` block can contain `before` and `after` blocks, which will run before and after any of the routes in the block have been processed. So, one could add HSTS headers to all responses:

```` raku
my $application = route {
    after {
        header 'Strict-transport-security', 'max-age=31536000; includeSubDomains';
    }
    # Routes here...
}
````

Or respond with a HTTP 403 Forbidden for all requests without an Authorization header:

```` raku
my $application = route {
    before {
        unless .has-header('Authorization') {
            forbidden 'text/plain', 'Missing authorization';
        }
    }
    # Routes here...
}
````

Which behaves like this:

````
$ curl http://localhost:4242/
Missing authorization
$ curl -H"Authorization: Token 123" http://localhost:4242/
<strong>Do you like dugongs?</strong>
````

## It’s all just a Supply chain

All of Cro is really just a way of building up a chain of Raku `Supply` objects. While the `before` and `after` middleware blocks are convenient, writing middleware as a transform provides access to the full power of the Raku `supply`/`whenever` syntax. Thus, should you ever need to take a request with a session token and make an asynchronous call to a session database, and only then either emit the request for further processing (or do a  redirection to a login page), it’s possible to do it – in a way that doesn’t block other requests (including those on the same connection).

In fact, Cro is built entirely in terms of the higher level Raku concurrency features. There’s no explicit threads, and no explicit locks. Instead, all concurrency is expressed in terms of Raku `Supply` and `Promise`, and it is left to the Raku runtime library to scale the application over multiple threads.

## Oh, and WebSockets?

It turns out Raku supplies map really nicely to web sockets. So nicely, in fact, that Cro was left with relatively little to add in terms of API. Here’s how an (overly) simple chat server backend might look:

```` raku
my $chat = Supplier.new;
get -> 'chat' {
    # For each request for a web socket...
    web-socket -> $incoming {
        # We start this bit of reactive logic...
        supply {
            # Whenever we get a message on the socket, we emit it into the
            # $chat Supplier
            whenever $incoming -> $message {
                $chat.emit(await $message.body-text);
            }
            # Whatever is emitted on the $chat Supplier (shared between all)
            # web sockets), we send on this web socket.
            whenever $chat -> $text {
                emit $text;
            }
        }
    }
}
````

Note that doing this needs a `use Cro::HTTP::Router::WebSocket;` to import the module providing the `web-socket` function.

## In summary

This is just a glimpse at what Cro has to offer. There wasn’t space to talk about the HTTP and web socket clients, the `cro` command line tool for stubbing and running projects, the `cro web` tool that provides a web UI for doing the same, or that if you stick `CRO_TRACE=1` into your environment you get lots of juicy debugging details about request and response processing.

To learn more, check out the [Cro documentation](http://cro.services/docs), including a [tutorial about building a Single Page Application](http://cro.services/docs/intro/spa-with-cro). And if you’ve more questions, there’s also a recently-created `#cro` IRC channel on Freenode.
