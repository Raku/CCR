# November 25 2009 — you guys can be on our team
    
*Originally published on [26 November 2009](http://strangelyconsistent.org/blog/november-25-2009-you-guys-can-be-on-our-team) by Carl Mäsak.*

> 34 years ago today, Suriname [gained full independence](https://en.wikipedia.org/wiki/Suriname#History) from the Netherlands. You don't even know where Suriname is, do you? (I didn't.) It's [a small country in South America](https://en.wikipedia.org/wiki/File:Suriname_(orthographic_projection).svg).

In 1954, the Dutch placed Suriname under a system of limited self-government, with the Netherlands retaining control of defense and foreign affairs. In 1973, the local government, led by the NPK (a largely Creole, meaning ethnically African or mixed African-European, party) started negotiations with the Dutch government leading towards full independence, which was granted on 25 November 1975. The severance package was very substantial, and a large part of Suriname's economy for the first decade following independence was fueled by foreign aid provided by the Dutch government.

The first President of the country was Johan Ferrier, the former governor, with Henck Arron (the then leader of the Nationale Partij Suriname (Suriname's National Party)) as Prime Minister. Nearly one third of the population of Suriname at that time emigrated to the Netherlands in the years leading up to independence, as many people feared that the new country would fare worse under independence than it did as an overseas colony of the Netherlands. Suriname's diaspora therefore includes more than a quarter of one million people of Suriname origin living in the Netherlands today, including several recent members of the Dutch national football (soccer) team.

Ah, there's a story with a happy ending. Us westerners used to call'em "marroons" and use them as slaves; now we abandoned the whole imperialism thing, and let the Surinameese play in our teams in the pretend-wars we refer to as 'sports'.

Today I want to sync up with [Astaire](https://github.com/masak/web/blob/master/spec/Astaire.pod), the cute little dispatcher in Web.pm that I almost didn't write at all (it's mostly written by *arthur*++). In my Web.pm directory, I do this:

```
$ raku t/spec/astaire/01-basics.t
1..18
ok 1 - used Astaire without errors
Could not find non-existent sub !SIGNATURE_BIND
```

This happens to me all the time, otherwise I might become intimidated when I see similar errors. In seconds the association between 'non-sequitur internal error' and 'stale .pir files' activates. This will continue to be the case as long as Rakudo and Parrot have the crazy speed of development they do currently.

```
$ find . -name \*.pir | xargs rm
$ make
```

Ok, here we go again:

```
$ raku t/spec/astaire/01-basics.t
1..18
ok 1 - used Astaire without errors
ok 2 - set up get action without errors
ok 3 - set up post action without errors
ok 4 - set up application without errors
ok 5 - set up request without errors
ok 6 - got response without errors
ok 7 - body of response to get was as excpected
ok 8 - status of response to get was as excpected
ok 9 - response to post was as excpected
ok 10 - nonexistant page gives 404 error
ok 11 - request to get action with post fails as excpected
ok 12 - request to post action with get fails as excpected
ok 13 - can add actions after application object was created
ok 14 - double action matching same request works as excpected
ok 15 - matched on long ( > 1 ) path
ok 16 - 404 error with wrong long path ( different length )
ok 17 - 404 error with wrong long path ( same length )
ok 18 - path with wildcard
Too many positional parameters passed; got 2 but expected between 0 and 1
in Main (file src/gen_setting.pm, line 324)
```

I recognize this error. Let's see what it was again. Here's what the code after test 18 looks like:

```
get '/path/to/file/*.*' answers {
    "Starz";
};
{
    my $response = $astaire_app.call( Web::Request.new({ PATH_INFO => "/path/to/file/my_file.xml", REQUEST_METHOD => "GET" }) );
    ok( $response.body eq "Starz" , 'path with several wildcards');
}
```

The only line which reasonably *can* fail is that long one, and it must fail in `$astaire_app.call`. Don't ask me how I know that — the short answer is that all the other components are harmless or well-tested.

So, looking inside the `AstaireApp.call` method.

```raku
has Dispatch $.dispatch is rw;
```

method call ( Web::Request $request ){<br>
     return $.dispatch.dispatch( $request );<br>
 } 

The trail leads on to the `Dispatch.dispatch` method...

```raku
method dispatch ( Web::Request $request ){
    my Web::Response $response .= `new`;
    for @.handlers -> $candidate {
        my %match = $candidate.matches( $request.path_info );
        if %match{'success'} and $candidate.http_method eq $request.request_method {
            my $code = $candidate.code;
            $response.write( $code(|%match<splat>) );
            return $response;
        }
    }
    #Not found
    $response.status = 404;
    return $response;
}
```

Ok, it's pretty clear what's happening. (This is all going too easy, I think I've followed this debugging trail before...) That `|%match<splat>` is flattening into two parameters, but the closure sitting in `$code` — see the line above which begins with '`get`' — is an ordinary closure, which means it possibly takes a `$_`, but nothing else. So, it expects zero or one parameters. Hence the error message.

Time is quickly running out, so I won't solve the issue today. But let me just list the two possible solutions I see, and I'll leave it to some other day to sort it all out by going down one of the paths.

- Fix the closure. In other words, make sure that it expects two parameters.
- Fix `.dispatch`, by checking the number of expected parameters before making the call itself.

Now here's the tricky thing: the first solution feels too brittle, because the problems will affect the user, and at the time when the request is made, possibly long after the handler has been registered.

However, the second solution involves introspecting the closure to find out how many parameters it expects — something that is generally considered a code smell. So that might not be the right way either.

Hm. I'll need to check how Sinatra solves this.
