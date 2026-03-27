# Week 1 of Web.pm — Specifying a framework basics
    
*Originally published on [9 March 2009](http://strangelyconsistent.org/blog/week-1-of-webpm-specifying-a-framework-basics) by Carl Mäsak.*

> *An Ceiling Cat sed to teh man, ov evury tre in teh gardin iz ok u eatz: But of teh tre of teh nawlej of gud an evl, you not eatz cuz wen u eatz taht tre i fur sure mek u ded. Srsly.* — Genesis 2:16-17

Our grant task has commenced. Here's how our plan of attack looks for the coming weeks.

- Specifying framework basics
- Creating a minimal Web framework
- Changing November to run on top of the framework
- Setting up Maya to use the framework
- Setting up a proof-of-concept pastebin
- Implementing the features possible within the current limits of Rakudo
- Condensing the above experience into a tutorial

I started just throwing loose thoughts into a PLAN file. It is not complete by any means, but it has got me thinking about specifying. (*wayland*++ for contributing.)

Also, I've been visiting channels with web framework people and had fruitful discussions. One of these went on the november-wiki list for everyone to read. My overall impression is that people are very helpful and eager to share their experiences. ("Don't make the mistakes we make," they say. "Make new ones.")

The third thing I've done is try to quench my curiosity of Sinatra by reading the source. Ruby code is very cute, and quite readable most of the time even for an outsider like me. I think one of the first things I'll get working in Web.pm is [this script](https://gist.github.com/masak/68506), also found in the PLAN file above. That script is a direct translation of the script found here. Eager to find out how that `get` call worked, I went and dug it out of the Sinatra source. Here it is:

```
def get(path, opts={}, &block)
  conditions = @conditions.dup
  route('GET', path, opts, &block)
  @conditions = conditions
  route('HEAD', path, opts, &block)
end
```

In short, a call to another method called `route` is made, and an instance variable `conditions` is cloned and reinstated, probably because it was clobbered by the first call.

Ok, so how does `route` look? I thought you'd never ask:

```
def route(verb, path, opts={}, &block)
  host_name  opts[:host]  if opts.key?(:host)
  user_agent opts[:agent] if opts.key?(:agent)
  accept_mime_types opts[:provides] if opts.key?(:provides)
  pattern, keys = compile(path)
  conditions, @conditions = @conditions, []
  define_method "#{verb} #{path}", &block
  unbound_method = instance_method("#{verb} #{path}")
  block = lambda { unbound_method.bind(self).call }
  (routes[verb] ||= []).
    push([pattern, keys, conditions, block]).last
end
```

A bit more code, but still not horribly much. What happens here? A few reasonable settings are made if they come in through `opts`. We `compile` the path (whatever that means), clobber `conditions` just as we thought we would (actually, we clear it), create a closure which calls a method on `self`, and then put it all into a `routes` hash (and also return it).

It all seems quite straightforward. The only question that remains in my mind is what `compile` does.

```
def compile(path)
  keys = []
  if path.respond_to? :to_str
    pattern =
      URI.encode(path).gsub(/((:\w+)|\*)/) do |match|
        if match == "*"
          keys << 'splat'
          "(.*?)"
        else
          keys << $2[1..-1]
          "([^/?&#\.]+)"
        end
      end
    [/^#{pattern}$/, keys]
  elsif path.respond_to? :=~
    [path, keys]
  else
    raise TypeError, path
  end
end
```

This method concerns itself with stringlike things and matchlike things. If what it finds conforms to its expectations, it returns a regex and an array of keys. If I'm reading this correctly, the simple string `'hi'` in `path` would enter the `else` leg of the innermost `if` statement, and `'hi'` would end up as the single element in `keys`.

Hm, I'm one step closer to understanding this. It's basically a dispatcher. I'll talk more to Ilya about it; he's written November's dispatcher, and plans to do the one in Web.pm.

One final thing this week: the naming issue. The grant committee expressed slight doubts about the name Web.pm, so I wrote [this](https://gist.github.com/masak/73406) and had [this discussion](https://irclogs.raku.org/perl6/2009-03-03.html#05:31). After thinking a lot about this, I think we should keep the "Web.pm" name for the whole thing, but strive to name every component inside (dispatcher, tags library, templating engine, MVC framework, etc) to show that we really only provide these as reasonable defaults.

That ties in with our overall goal to make the Web.pm bundle a set of very reasonable defaults for web development. But most modules can be used outside the context of Web.pm as well, and conversely, modules in Web.pm can be replaced with other modules, and will work just as well as long as they adhere to some API. That's the idea anyway.

I wish to thank The Perl Foundation for sponsoring the Web.pm effort. We're very excited about this.
