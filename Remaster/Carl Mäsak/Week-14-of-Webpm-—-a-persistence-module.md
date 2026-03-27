# Week 14 of Web.pm — a persistence module
    
*Originally published on [24 August 2009](http://strangelyconsistent.org/blog/week-14-of-webpm-a-persistence-module) by Carl Mäsak.*

> *"If u juj u wil be jujded. So don't. Bcz u will be jujded teh saem az u jujded teh othr d00d.*
> *Teh sawdust iz in ur brothrz i, makin u confused. Why u caer so much when u gotz a board in ur i LOL? Why u sez "O hai takin teh sawdust out of ur i"? U gotz board in ur i! Taek teh board out of ur i furst dumass. Den taek teh dust out of ur brotherz i aftr dat. Duh.* — Matthew 7:1-5

After looking a bit more closely first at Camping today, and then at ActiveRecord, I decided to try and create something a little like ActiveRecord.

Now, after trying to wrap my head around what ActiveRecord is, I understand it is an ORM layer — that's Object-Relational Mapping, i.e. a bridge between the class-based world of programming languages and the table-based world of databases — that also (according to [Wikipedia](https://en.wikipedia.org/wiki/ActiveRecord_(Rails))) gives you inheritance and associations, something not all ORM layers deliver. Without understanding Rails completely yet, I'm coming to view it as the killer app of ActiveRecord, an application which seems pretty innovative on its own.

Now, we're in a position with Web.pm that if we're to start building something that looks like an MVC framework, we need something that looks like a persistence layer. So that's what I wrote this evening: something that looks like a persistence layer. Right now, it's more likely to bite you than to do some actual good... which is one of the reasons I called it Viper. (The other reason being that "orm" is Swedish for "snake". I'm running low on names; so sue me.)

What I did was to start from the outside in with what I wanted. The following simple blog example was loosely inspired by the Camping [README file](https://github.com/camping/camping/blob/fa8802511fd745dedcbeab61d809ddf15af80e43/README):

```raku
use v6;
use Viper;
class User is Viper::Base {
}
class Post is Viper::Base {
    has $.user_id is persisted;
}
class Comment is Viper::Base {
    has $.user_id is persisted;
}
my $session = Viper.new( :types[User, Post, Comment], :db('data/') );
my Post @posts = Post.find($session, :all);
say .name for @posts;
```

(Actually, the syntax and other details started quite different, and I adapted them as I learned more. But I have done *git rebase --interactive* on irrelevant details for the purpouses of this post, so that it'll be easier to follow.)

The idea with the above script is that the initialization of `$session` should connect back to a database — a set of files, in this case — and pull up a persisted store of `User`, `Post` and `Comment` objects. The `persisted` trait on the attributes is there to give us a couple of extra accessor methods to the objects.

Ok, so what's the smallest piece of code that can implement this for us? Scratch that, what's the smallest piece of code that will make the above script *compile*? Here it is:

```raku
class Viper {
}
class Viper::Base {
    method `find` {
    }
}
```

Not very exciting. Note that we haven't even bothered to define the trait we're using. Wonder when that'll bite us? 哈哈

Anyway, functionality. The two classes will need some attributes for book-keeping:

```raku
class Viper {
    has $.db;
    has %.objects;
    # ...
}
class Viper::Base {
    has $.id is persisted;
    has $.name is persisted;
    # ...
}
```

These store the path to the database, a mapping from all known types to all known objects of that type, and id/name, two ubiquitous properties of all persisted objects, respectively.

Actually, having decided on the structure of the `%.objects` attribute, we can already flesh out the `find` method in `Viper::Base`:

```raku
    method find(Viper $session, :$all!) {
        return $session.objects{self}.list;
    }
```

It's not very versatile, but it does exactly what it advertises: finds all objects of a given type. (It does this by using itself as a key to the `%!objects` hash in the `Vipser` session. See the script at the top for an example.)

Now, for this to work, something needs to happen when a `Viper` object is initialized. Thus, let's write a `BUILD` submethod:

```raku
submethod BUILD(:@types!, :$db!) {
    $!db    = $db;
    if $db !~~ :e {
        run("mkdir $db");
    }
    for @types -> $type {
        my $filename = $!db ~ '/' ~ $type.substr(0,-2);
        if $filename !~~ :e {
            self.create-new-db-file($type, $filename);
            %!objects{$type} = [];
        }
        else {
            %!objects{$type}
                = Text::CSV.parse-file($filename, :output($type));
        }
    }
}
```

Translated into bullet points, here's what the above code does:

- check if there's a directory; if not, make one;
- check if the files we want to load are there; if they're not, create them, if they are, load them in.

As it happens, I wrote a CSV parser the other week (which I haven't blogged about yet, but will), and Viper uses that. The `Text::CSV.parse-file` call does the actual reading-from-the-database part, and as an added bonus, the parameter `:output($type)` makes sure we get an array of objects of the desired type back. Pretty neat, huh?

What I realized was that there's no way (yet) for `Text::CSV` to *write* a CSV file, so we'll get no help from the module when we want to create an empty table file. Fortunately, that's fairly straightforward:

```raku
submethod create-new-db-file($type, $filename) {
    my @columns = $type.^attributes>>.name>>.substr(2); # w/o sigil/twigil
    my $dbfile = open($filename, :w)
        or die $!;
    $dbfile.say: join(',', map { qq["$_"] }, @columns);
}
```

Don't you just love Raku?

With that initialization code, we're ready to take our script-at-the-top for a test drive. If we succeed, it'll create a `data/` directory for us, with the files `User`, `Post` and `Comment`...

And it does. Yay!

Since we now have a persisted database, we can now open `data/Post` and enter our first object:

```raku
"user_id","id","name"
1,1,"Hello Austria!"
```

Now, the script, once we run it again, should print `Hello Austria!`, since it lists the names of all our stored `Post` objects. We run it, and...

BAM!

```raku
$ raku blog-example
No applicable candidates found to dispatch to for 'trait_mod:is'
```

Ah, so now you know when that missing trait is going to bite you: at object creation time. :)

So, we (grudgingly) add a stubbed method to the `Viper` module:

```raku
multi trait_mod:<is>(AttributeDeclarand $a, $names, :$persisted!) {
}

Et voilà! Our script now prints:

```raku
$ raku blog-example
Hello Austria!
```

Which means that Viper picks things up from file, dresses them in objects, stores them in the session, so that our script can find them and print their names. Well, "its name", since we only injected one `Post`.

## Try it out yourself!

See if *you* can get Viper to persist something. Start from the script above (which can also be found in the [Web.pm github repository](https://github.com/masak/web/blob/68c15a604a1f487eb2774376079c05fa59622170/drafts/blog-example)). Then, let your imagination run free. Write that blog engine in Raku, for example.

Oh, and because Viper uses `Text::CSV`, make sure you [have that too](https://github.com/masak/csv), and that `RAKULIB` can see it.

We'll see if Viper survives in any form. I wouldn't be surprised if it's replaced quickly by something much better. But it has definitely been an interesting exercise so far in trying to understand the problem space better.

I wish to thank The Perl Foundation for sponsoring the Web.pm effort.
