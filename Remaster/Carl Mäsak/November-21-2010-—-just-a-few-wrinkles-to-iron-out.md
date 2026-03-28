# November 21 2010 — just a few wrinkles to iron out
    
*Originally published on [22 November 2010](http://strangelyconsistent.org/blog/november-21-2010-just-a-few-wrinkles-to-iron-out) by Carl Mäsak.*

> 227 years ago today, the brothers Montgolfier made their first untethered flight with human passengers in a [hot air balloon](https://en.wikipedia.org/wiki/History_of_ballooning#First_manned_flight).

> These brothers came from a family of paper manufacturers and had noticed ash rising in paper fires. [...] The first hot air balloons were essentially cloth bags (sometimes lined with paper) with a smoky fire built on a grill attached to the bottom. They were susceptible to catching fire, often upon landing, although this occurred infrequently.

I wanted to know whether this was the [first human flight](https://en.wikipedia.org/wiki/First_flying_machine) ever, and found a curious tale of a [Muslim scientist](https://en.wikipedia.org/wiki/Abbas_Ibn_Firnas) attempting flight in the 9th century, though it's unclear to how large an extent he succeeded.

Hah! [Just as I thought](November-20-2010-leftmost-longest-whale-wins.html).

```raku
if $title {
    return qq|[$title]($url)|;
} else {
    return qq|[$url]($url)|;
}
```

See what's amiss? I'll give you a few seconds.

Here's what's happening: through the various rules of string interpolation, all about which you can read in S02, the things interpolated above aren't `$url`, `$title`, `$url`, and `$title`. Instead, it's `$url`, `$title`, `$url`, `$url</a>`. Of course that shouldn't happen, but it does, after *jnthn*++ [implemented better string interpolation](https://github.com/rakudo/rakudo/commit/93fa3d5561df1122a32c3b6d985dc75394ad4d84) in the new Rakudo.

Now the error message makes a lot of sense, doesn't it?

```
postcircumfix:<{ }> not defined for type `Str`
```

(The reason it's `postcircumfix:<{ }>` and not `postcircumfix:«< >»` is that the latter, being a kind of syntactic sugar, delegates to the former.)

So, what's the obvious fix? Trouble is, there isn't one. It's not that it's *hard* to fix, it's just that this problem is annoying to get in the first place. It's an unplesant surprise to get in the first place, and basically *everyone* who dabbles in interpolating strings with HTML tags will be bitten by this, sooner or later.

Perhaps that will teach people not to roll their own HTML serialization. Hahaha. *sob*

I'd describe this as *the one remaining wrinkle in string interpolation*. And probably one that we won't get around to ironing out. It's highly likely that we'll settle for providing one of those spot-on warnings that make Perl a joy to use, and move on with life.

Oh, and the obvious fix, adding a backslash to break things up?

```raku
qq|[$title\]($url)|
```

Won't work, due to a wonderful little invention called *unspace*, which is also very nice but which just happens to work against us in this particular instance. So the modified thing means exactly the same as without the backslash. [**Update:** No, I'm wrong, says *TimToady*++. It means exactly what it should mean, and fixes the problem. It's just that it's not [implemented in Rakudo yet](https://github.com/Raku/old-issue-tracker/issues/2273).]

Here are the real fixes:

- End the string, concat with a new one: `qq|[$title| ~ ']($url)'```
- Use curly braces around the troublesome variable: `qq|[{$title}]($url)|```

The latter fix seems to be the one culturally winning out. Thing is, knowing to put them there in the first place is something you'll have to learn the hard way.

Maybe I should make a shot at putting that warning into Rakudo. Along with a way for experienced users to switch it off in a lexical scope.

Ok, [fixing that](https://github.com/viklund/november/commit/39ea975ced8ee0509b8f050574b292fc676d57b5). Next error:

```
Method 'page_tags_path' not found for invocant of class 'November;Tags'
  in 'November::Tags::read_page_tags' at line 74:lib/November/Tags.pm
  in 'November::Tags::page_tags' at line 142:lib/November/Tags.pm
  [...]
```

Oooh. Now that looks interesting. And I have no idea why that would happen. Join us tomorrow, or some other day, in the exciting quest to find out.
