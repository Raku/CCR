# Not guts, but 6: part 1
    
*Originally published on [2016-01-04](https://6guts.wordpress.com/2016/01/04/not-guts-but-6-part-1/) by Jonathan Worthington.*

After the Christmas release of Raku, I spent the better part of a week in bed, exhausted and somewhat sick. I’m on the mend, but I’m going to be taking it easy for the coming weeks. I suspect it’ll be around February before I’m feeling ready for my next big adventures in Raku compiler/VM hacking. It’s not so much a matter of not having motivation to work on stuff; I’ve quite a lot that I want to do. But, having spent six months where I was never quite feeling well, just somewhere between not well and tolerably OK, I’m aware I need to give myself some real rest, and slowly ease myself back into things. I’ll also be keeping my travel schedule very light over the coming months. The Raku Christmas preparations were intense and tiring, but certainly not the only thing to thank for my exhaustion. 3-4 years of always having a flight or long-distance train trip in the near future – and especially the rather intense previous 18 months – has certainly taken its toll. So, for the next while I’ll be enjoying some quality time at home in Prague, enjoying nice walks around this beautiful city and cooking plenty of tasty Indian dishes.

While I’m not ready to put compiler hat back on yet, I still fancied a little gentle programming to do in the next week or two. And, having put so much effort into Raku, it’s high time I got to have the fun of writing some comparatively normal code in it. :-) So, I decided to take [the STOMP client I hacked up in the space of an hour for my Raku advent post](https://rakuadvent.wordpress.com/2015/12/14/day-14-a-nice-supplies-syntactic-relief-for-working-with-asynchronous-data/), and flesh it out into a full module. As I do so, I’m going to blog about it here, because I think in doing so I’ll be able to share some ideas and ways of doing things that will have wider applicability. It will probably also be a window into some of the design thinking behind various Raku things.

### Step 0: git repo

I took the code from the blog post, and dropped it into lib/Stomp/Client.pm6. Then it was git init, git add, git commit, and [voila](https://github.com/jnthn/p6-stomp/commit/0229ad0cc5fc554662aad7125d714774b5e94152), I’m ready to get going. I also decided to use [Atom](http://atom.io/) to work on this, so I can enjoy the [nice Raku syntax highlighting](https://atom.io/packages/language-rakufe) plug-in.

### Testing thinking

Since my demos for the blog post actually worked, it’s fairly clear that I at this point have “working code”. Unfortunately, it also has no tests whatsoever. That makes me uneasy. I’m not especially religious about automated testing, I just know there have been very few times where I wrote tests and regretted spending time doing so, but a good number of times when I “didn’t need to spend time doing that” and later made silly mistakes that I knew full well would have been found by a decent suite of tests.

More than that, I find that testable designs tend to also be extensible and loosely coupled designs. That partly falls out of my belief that tests should simply be another client of the code. Sometimes on #raku, somebody asks how to test their private methods. Of course, since I designed large parts of the MOP, I can rattle off “use `.^find_private_method(‘foo’)` to get hold of it, then call it” without thinking. But the more thoughtful answer is that I don’t think you should be testing private methods. They’re private. They’re an implementation detail, like attributes. My expectation in Raku is that I can perform a correct refactor involving private methods or attributes without having to be aware of anything textually outside the body of the class in question. This means that flexibility for the sake of testability will need to make it into the public interface of code – and that’s good, because it will make the code more open to non-testing extension too.

My current `Stomp::Client` is not really open to easy automated testing. There is one non-easy way that’d work, though: write a fake STOMP server to test it against. That’s probably not actually all that hard. After all, I already have a STOMP message parser. But wait…if my module already contains a good chunk of the work needed to offer server support, maybe I should build that too. And even if I don’t, I should think about how I can share my message parser so somebody else can. And that means that rather than being locked up in my `Stomp::Client` class it will need to become public API. And that in turn would mean a large, complex, part of the logic…just became easily testable!

I love these kinds of design explorations, and it’s surprising how often the relatively boring question of “how will I test this” sets me off in worthwhile directions. But wait…I shouldn’t just blindly go with the first idea I have for achieving testability, even if it is rather promising. I’ve learned (the hard way, usually) that it’s nearly always worth considering more than one way to do things. That’s often harder that it should be, because I find myself way too easily attached to ideas I’ve already had, and wanting to defend them way too early against other lines of thought. Apparently this is human nature, or something. Whatever it is, it’s not especially helpful for producing good software!

Having considered how I might test it as is, let me ponder the simplest change I could make that would make the code a lot easier to test. The reason I’d need a fake server is because the code tightly couples to `IO::Socket::Async`. It’s infatuated with it. It hard-codes its name, declaring that we shall have no socket implementation, but `IO::Socket::Async`!

```` raku
my $conn = await IO::Socket::Async.connect($!host, $!port);
````

So, I’ll change that to:

```` raku
my $conn = await self.socket-provider.connect($!host, $!port);
````

And then add this method:

```` raku
method socket-provider {
    IO::Socket::Async
}
````

And…it’s done! My tests will simply need to do something like:

```` raku
my \TestClient = Stomp::Client but role {
    method socket-`provider` {
        Fake::Client::Socket
    }
}
````

And, provided I have some stub/mock/fake implementation of the client bits of `IO::Socket::Async`, all will be good.

But wait, there’s more. It’s also often possible to connect to STOMP servers using TLS, for better security. Suppose I don’t support that in my module. Under the previous design, that would have been a blocker. Now, provided there’s some TLS module that provides the same interface as `IO::Socket::Async`, it’ll be trivial to use it together with my `Stomp::Client`. Once again, thinking about testability in terms of the public interface gives me an improvement that is entirely unrelated to testability.

I liked this change sufficiently I decided it was time to commit. [Here it is.](https://github.com/jnthn/p6-stomp/commit/9f936f1ac51cb3e6d5397f07fbc9b84c1ffe4ec2)

### Exposing Message

I’m a big fan of the aggregate pattern. Interesting objects often end up with interesting internal structure, which is best expressed in terms of further objects. Since classes, grammars, roles and the like can all be lexically scoped in Raku, keeping such things hidden away as implementation details is easy. It’s how I tend to start out. For example, my `Message` class, representing a parsed STOMP message, is lexical and nested inside of the `Stomp::Client` class:

```` raku
class Stomp::Client {
    my class Message {
        has $.command;
        has %.headers;
        has $.body;
    }

    ...
}
````

The grammar for parsing messages is even lexically scoped inside of the one method that uses it! Lexical scoping is another of those things Raku offers for keeping code refactorable. In fact, it’s an even stronger one than private attributes and methods offer. Those you can go and get at using the MOP if you really want. There’s no such trickery on offer with lexical scoping.

So, that’s how I started out. But, by now, I know that for both testing and later implementing a `Stomp::Server` module, I’d like to pull `Message` out. So, off to a Stomp/Message.pm6 it goes. Since it was lexical before, it’s easy to fix up the references. In fact, the Raku compiler will happily tell me about them at compile time, so I can be happy I didn’t miss any. (It turns out there is only one). [Another commit.](https://github.com/jnthn/p6-stomp/commit/f71659449fca2ad1166565e3724404d00ad00408)

### Oh, behave!

At the point I expose a class to the world, I find it useful to step back and ask myself what it’s responsibilities are. Right now, the answer seems to be, “not much!” It’s really just a data object. But generally, objects aren’t just data. They’re really about behaviour. So, are there any behaviours that maybe belong on a `Message` object?

Looking through the code, I see this:

```` raku
await $conn.print: qq:to/FRAME/;
    CONNECT
    accept-version:1.2
    login:$!login
    passcode:$!password

    \0
    FRAME 
````

And, later, this:

```` raku
$!connection.print: qq:to/FRAME/;
    SEND
    destination:/queue/$topic
    content-type:text/plain

    $body\0
    FRAME
````

There’s another such case too, for subscribe. It’s quite easy for a string with a bit of interpolation to masquerade as being too boring to care about. But what I really have here is knowledge about how is STOMP message formed scattered throughout my code. As this module matures from 1-hour hack to a real implementation of the STOMP spec, this is going to have to respect a number of encoding rules – or risk being vulnerable to injection attacks. (All injection attacks really come from failing to treat languages as languages, and instead just treating them as strings that can be stuck together.) And logic that will therefore even be security sensitive absolutely does not want scattering throughout my code.

So, I’ll move the logic to `Stomp::Message`. First, a failing test goes into t/message.t:

```` raku
use Test;
use Stomp::Message;

plan 1;

my $msg = Stomp::Message.new(
    command => 'SEND',
    headers => ( destination => '/queue/stuff' ),
    body    => 'Much wow');
is $msg, qq:to/EXPECTED/, 'SEND message correctly formatted';
    SEND
    destination:/queue/stuff

    Much wow\0
    EXPECTED
````

I find it reassuring to see a test actually fail before I do the work to make it pass. It tells me I actually did something. Now for the implementation:

```` raku
method `Str` {
    qq:to/END/
        $!command
        %!headers.fmt('%s:%s')

        $!body\0
        END
}
````

The `fmt` method is one of those small, but valuable Raku features. It’s really just a structure-aware `sprintf`. On hashes, it can be given a format string for each key and value, along with a separator. The default separator is `\n`, which is exactly what I need, so I don’t need to pass it. This neatly takes a loop out of my code, and means I can lay out my heredoc to look quite like the message I’m producing. [Here’s the change.](https://github.com/jnthn/p6-stomp/commit/76fe5ef98b60bf4efc7b7349dd0352052ec4e85e)

### Construction tweaks

With a passing test under my belt, I’d like to ponder whether there’s any more interesting tests I might like to write Right Now for `Stomp::Message`. I know I will need to make a pass through the spec for encoding rules, but that’s for later. Putting that aside, however, are there any other ways that I might end up with my `Stomp::Message` class producing malformed messages?

The obvious risk is that an instance may be constructed with no command. This can never be valid, so I’ll simply forbid it. A failing test is easy:

```` raku
dies-ok
    { Stomp::Message.new( headers => (foo => 'bar'), body => 'Much wow' ) },
    'Stomp::Message must be constructed with a command';
````

So is this fix: just mark the attribute as required!

```` raku
has $.command is required;
````

It is allowable to have an empty body in some messages. At present, it kind of supports that without having to pass it explicitly, but there will be a warning. The fix is 4 characters. It’s really rather borderline whether this is worth a test, for me. But I’ll write one anyway:

```` raku
{
    my $msg = Stomp::Message.new(
        command => 'CONNECT',
        headers => ( accept-version => '1.2' ));
    is $msg, qq:to/EXPECTED/, 'CONNECT message with empty body correctly formatted';
        CONNECT
        accept-version:1.2

        \0
        EXPECTED
    CONTROL {
        when CX::Warn { flunk 'Should not warn over uninitialized body' }
    }
}
````

It fails. And then I do:

```` raku
has $.body = '';
````

And it passes. The boilerplate there makes me thing there’s some market for an easier way to express “it doesn’t warn” in a test, but I’ll leave that yak for somebody else.

Those went in as [two](https://github.com/jnthn/p6-stomp/commit/ab3d0c8ceeebe8a7c1ea0d8aad3a8b62488738eb) [commits](https://github.com/jnthn/p6-stomp/commit/805a5be253b32446246cd50dae956ef40fba068e), because they’re two separate changes. I like to keep my commits nice and atomic that way.

### Eliminating the duplication

Finally, I go and replace the various places that produced formatted STOMP messages with use of the `Stomp::Message` class:

```` raku
$!connection.print: Stomp::Message.new:
    command => 'SUBSCRIBE',
    headers => (
        destination => "/queue/$topic",
        id => $id
    );
````

3 changes, [1 commit](https://github.com/jnthn/p6-stomp/commit/c841d423bd9fcfbd290d48a46de63409c1b8342a), done.

### Enough for this time!

Next time, I’ll be taking a look at factoring out the parser, and writing some tests for it. Beyond that, there’ll be faking the async socket API, supporting unsubscription from topics, building STOMP server support, and more.
