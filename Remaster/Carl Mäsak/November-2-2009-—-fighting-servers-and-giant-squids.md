# November 2 2009 — fighting servers and giant squids
    
*Originally published on [3 November 2009](http://strangelyconsistent.org/blog/november-2-2009-fighting-servers-and-giant-squids) by Carl Mäsak.*

> 131 years ago today, the (allegedly) largest giant squid ever [washed or was pulled ashore](https://en.wikipedia.org/wiki/Giant_squid):

For example, a specimen washed ashore in Thimble Tickle Bay, Newfoundland on November 2, 1878; its mantle was reported to be 6.1 metres (20 ft) long, with one tentacle 10.7 metres (35 ft) long, and it was estimated as weighing 2.2 tonnes.

While the quoted article claims that the squid washed ashore, another page claims that it was found aground/alive off shore, [tied with rope and pulled to shore](https://en.wikipedia.org/wiki/List_of_giant_squid_specimens_and_sightings). This latter page also mentions that none of the squid remains, because it was cut up and used for dog food. So it goes.

Today I wanted to start fixing bugs for *lichtkind*++, who has been waiting for months for me to return to active November development. But when I was about to begin doing that, it occurred to me that the November web app at november-wiki.org is still down. Need to fix that first, so that there'll be a place to point at and say "look! fixed!".

I emailed *viklund*++ and negotiated with him to take over the responsibility for keeping the site online. He gave me some pointers as to how to configure the unholy union between November and Apache so that things work. viklund has been getting November running on feather so many times by now that he has developed a system for doing it. As part of that system, he uses proto (!) to set up Rakudo, Parrot, November and its dependency, html-template for him. Schmot guy, viklund.

So I try to do the same.

```
masak@feather:~/proto-2009-06-23$ ./proto
Building proto...== SORRY! ==
Unable to find Raku dynops and dynpmcs library.
If you want to run Rakudo outside of the build directory, please make install.
== SORRY! ==
Unable to find Raku dynops and dynpmcs library.
If you want to run Rakudo outside of the build directory, please make install.
done
== SORRY! ==
Unable to find Raku dynops and dynpmcs library.
If you want to run Rakudo outside of the build directory, please make install.
```

Oh ouch. Can it be that the last time we (or *viklund*++, rather) tried to do this, Parrot and Rakudo didn't do the `make install` trick yet? Yes, it can be. We've been living on some kind of borrowed time since then.

I have two options here. Either I use the newest Rakudo, and make things work with it; or I stick with the version from June that worked last time. The first option is clearly the right one; trying the second one.

Ok, done "downdating" and building Rakudo.

```
masak@feather:~/proto-2009-06-23$ ./proto install november
Downloading november...downloaded
Downloading html-template...downloaded
Building html-template...built
Building november...built
The following projects are not in your $RAKULIB env var: november
Please add them if you want to compile and run them outside of proto.
```

Huh. For some reason I didn't expect that to work.

```
masak@feather:~/apache/cgi-bin$ ./w
Method 'Int' not found for invocant of class 'Float'
```

Why, that error reminds me of the un-bitrot commit I made yesterd... oh. The most recent November doesn't work with the Rakudo as of June. After picturing trying to juggle commits to make November keep working with an old Rakudo, I decide to try to make proto work with the latest Rakudo instead.

Here's the change I make. It's short-term and not very thorough, but it makes proto build.

```
diff --git a/proto b/proto
index a28da2f..ad1fa39 100755
--- a/proto
+++ b/proto
@@ -48,7 +48,7 @@ my $silently = ' > /dev/null 2>&1';
 install\_raku( $config\_info );
 my $rakudo\_directory = rakudo\_directory( $config\_info );
-my $raku = "$rakudo\_directory/raku";
+my $raku = "$rakudo\_directory/**parrot\_install/bin/**raku";
 make\_pir\_modules( $raku );
 # Delegate to installer
 exec( "env RAKUDO\_DIR=$rakudo\_directory $raku installer @ARGV" );
```

Next hurdle:

```
masak@feather:~/proto-2009-10-02$ ./proto
Building proto...done
Required named parameter 'projects-dir' not passed
in Main (file src/gen_setting.pm, line 324)
```

I think I recognize *jnthn*++'s new binder when I see it. 哈哈. But why do I get the error?

Well, first off, here's the method that fails to bind:

```
class Ecosystem;
# ...
method new(:$projects-dir!) {
```

Hey, look at this!

```
method new {
    self.bless(
        self.CREATE,
        config-info => (my $c = load-config-file('config.proto')),
        ecosystem   => Ecosystem.new($c{'Proto projects directory'}),
    )
}
```

No wonder it doesn't work, when we're trying to pass a positional argument to a named-only parameter. This is the second day in a row that I catch this type of error in app-cheese code.

(Not only that. I ran `git blame`, and the originator of that line is unquestionably me. G'ah!)

Fixing.

It works now! Wohoo! But, hm, the skin doesn't seem to appear as it should. Need to email viklund and ask. But the site's up again!

Summary: it's certainly not easy to set up November with Apache. Lots of moving parts and scary pitfalls. It doesn't help that November, Rakudo and proto are all moving targets. But considering all that, it's less lethal than I feared.
