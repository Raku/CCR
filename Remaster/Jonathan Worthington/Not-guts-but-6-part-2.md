# Not guts, but 6: part 2
    
*Originally published on [2016-01-05](https://6guts.wordpress.com/2016/01/05/not-guts-but-6-part-2/) by Jonathan Worthington.*

It’s time for more hacking on my Raku STOMP module. Today: parsing.

### Pulling out the parser

Given my plans for adding a `Stomp::Server` to go with my `Stomp::Client`, I need to factor my STOMP message parser out so it can be used by both. That will be an easy refactor. First, the parser moves off into a file of its own and gets called `Stomp::Parser`:

```` raku
grammar Stomp::Parser {
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

Then it’s just a use statement and a small tweak back in `Stomp::Client`. [Done!](https://github.com/jnthn/p6-stomp/commit/f14337ccde76f05f25ad1e566caeafd998c79710)

### Testing parsing of commands – and a discovery

Perhaps the most basic test I should write is for being able to parse all of recognized commands, but not unrecognized ones. So, here goes:

```` raku
use Test;
use Stomp::Parser;

plan 16;

my @commands = <
    SEND SUBSCRIBE UNSUBSCRIBE BEGIN COMMIT ABORT ACK NACK
    DISCONNECT CONNECT STOMP CONNECTED MESSAGE RECEIPT ERROR
>;

for @commands {
    ok Stomp::Parser.parse(qq:to/TEST/), "Can parse $_ command (no headers/body)";
        $_

        \0
        TEST
}

nok Stomp::Parser.parse(qq:to/TEST/), "Cannot parse unknown command FOO";
    FOO

    \0
    TEST
````

This doesn’t pass yet, because it turns out the grammar only supports the commands that a server may send, not those a client may send. That’s an easy fix:

```` raku
token command {
    <
        SEND SUBSCRIBE UNSUBSCRIBE BEGIN COMMIT ABORT ACK NACK
        DISCONNECT CONNECT STOMP CONNECTED MESSAGE RECEIPT ERROR
    >
}
````

That makes me stop and think a bit, though. I just took a parser suitable for Stomp::Client and generalized it. But now it will also accept messages that a client should never expect to receive. That means I’ll have to add an extra error path for them, which feels suboptimal. Thankfully, since grammars are just funky classes, I can easily introduce variants of the parser that just accept client and server commands:

```` raku
grammar Stomp::Parser::ClientCommands is Stomp::Parser {
    token command {
        <
            SEND SUBSCRIBE UNSUBSCRIBE BEGIN COMMIT ABORT ACK NACK
            DISCONNECT CONNECT STOMP
        >
    }
}

grammar Stomp::Parser::ServerCommands is Stomp::Parser {
    token command {
        < CONNECTED MESSAGE RECEIPT ERROR >
    }
}
````

And yes, I added tests to cover these too, in [the resulting commit](https://github.com/jnthn/p6-stomp/commit/73afe9bffceb815029237b1a0ba7bec525f4ff61).

### From parse tree to message

It’s fairly common in Raku for a grammar to come paired with actions, which process the raw parse tree into a higher level data structure. I certainly have a desired data structure: `Stomp::Message`. So how is it being made today? Here is the code in question:

```` raku
while Stomp::Parser::ServerCommands.subparse($buffer) -> $/ {
    $buffer .= substr($/.chars);
    if $<command> eq 'ERROR' {
        die ~$<body>;
    }
    else {
        emit Stomp::Message.new(
            command => ~$<command>,
            headers => $<header>
                .map({ ~.<header-name> => ~.<header-value> })
                .hash,
            body => ~$<body>
        );
    }
}
````

Clearly, part of this would end up getting duplicated in a `Stomp::Server`, so it’d be better pulled out, and stuck in an actions class. So, I’ll define an actions class nested inside my grammar, and put the logic there:

```` raku
grammar Stomp::Parser {
    ...

    class Actions {
        method TOP($/) {
            make Stomp::Message.new(
                command => ~$<command>,
                headers => $<header>
                    .map({ ~.<header-name> => ~.<header-value> })
                    .hash,
                body => ~$<body>
            );
        }
    }
}
````

It’s nice to notice how this is basically a cut-paste refactor. Now for a test:

```` raku
{
    my $parsed = Stomp::Parser.parse(qq:to/TEST/);
        SEND
        destination:/queue/stuff

        Much wow\0
        TEST
    ok $parsed, "Parsed message with header/body";

    my $msg = $parsed.made;
    isa-ok $msg, Stomp::Message, "Parser made a Stomp::Message";
    is $msg.command, "SEND", "Command is correct";
    is $msg.headers, { destination => "/queue/stuff" }, "Header is correct";
    is $msg.body, "Much wow", "Body is correct";
}
````

The test fails, because I forgot to set the actions class when calling parse. Hmm…I’d need to do that in `Stomp::Client` too…and in `Stomp::Server`. In fact, I don’t have an example off hand when I’d care to avoid producing a `Stomp::Message`. That probably means it wants to be the default. That’s easily taken care of by overriding parse and subparse to set the actions by default:

```` raku
method parse(|c) { nextwith(actions => Actions, |c); }
method subparse(|c) { nextwith(actions => Actions, |c); }
````

I use `|c` to swallow up all the incoming arguments, and then pass them along. Notice how I take care to put my default first, and then splice in anything the caller specifies. This means there’s still a way to provide alternate actions, or to pass Nil to get none at all. Test passes. [Commit.](https://github.com/jnthn/p6-stomp/commit/9f7cb06021ce50021df702c779d6a04f30b1dccf) Yay.

Finally, I can go back and tidy up the code in the buffer processing some:

```` raku
method !process-messages($incoming) {
    supply {
        my $buffer = '';
        whenever $incoming -> $data {
            $buffer ~= $data;
            while Stomp::Parser::ServerCommands.subparse($buffer) -> $/ {
                given $/.made -> $message {
                    die $message.body if $message.command eq 'ERROR';
                    emit $message;
                }
                $buffer .= substr($/.chars);
            }
        }
    }
}
````

It no longer needs to dig into the parse tree to find the command and body for the error handling. Generally, the code in this method is much more focused on doing a single thing: turning a stream of incoming characters into a stream of messages, coping with messages that fall over packet boundaries. [Win!](https://github.com/jnthn/p6-stomp/commit/4b09ad6e4cf83dd79405b9c9b9073e5c5ce89b25)

### Simplifying the actions

Refactoring feels nicer when there’s tests. So, is there anything of the code I now have nicely covered that I fancy cleaning up? Well, perhaps there is a little bit of simplification on offer in my small `Actions` class:

```` raku
class Actions {
    method TOP($/) {
        make Stomp::Message.new(
            command => ~$<command>,
            headers => $<header>
                .map({ ~.<header-name> => ~.<header-value> })
                .hash,
            body => ~$<body>
        );
    }
}
````

For one, I don’t actually need to explicitly do the hash coercion there. The default semantics of construction perform assignment, not binding, and a list of pairs can happily be assigned to a hash. That map is digging into the parse tree too, and it’d probably be neater to do handle the pair construction in a second action method. So, here goes:

```` raku
class Actions {
    method TOP($/) {
        make Stomp::Message.new(
            command => ~$<command>,
            headers => $<header>.map(*.made),
            body    => ~$<body>
        );
    }
    method header($/) {
        make ~$<header-name> => ~$<header-value>;
    }
}
````

I think I like that better. Not really any shorter, but breaks the work up into smaller chunks for easier digesting of the code. So, [it’s in](https://github.com/jnthn/p6-stomp/commit/873e98297353d23f584270a034487ff35ce48edf).

### Pretty nice progress

That’ll do me for this time. By now, I’ve got the things I’d need to build my `Stomp::Server` module nicely factored out. Better still, they’re covered by some tests. `Stomp::Client` itself is now much more focused, and down to under a hundred lines of code.

Next, I’ll want to look into getting some testing in place for `Stomp::Client`. And that will mean taking a little diversion: there’s no test double in the ecosystem for `IO::Socket::Async` yet, so I’ll need to build one.
