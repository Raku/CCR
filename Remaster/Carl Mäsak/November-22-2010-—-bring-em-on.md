# November 22 2010 — bring 'em on!
    
*Originally published on [23 November 2010](http://strangelyconsistent.org/blog/november-22-2010-bring-em-on) by Carl Mäsak.*

> 67 years ago today, President Franklin Roosevelt of the United States, Prime Minister Winston Churchill of the United Kingdom, and Generalissimo Chiang Kai-shek of the Republic of China met up in Cairo for what was to become known as the [Cairo Conference](https://en.wikipedia.org/wiki/Cairo_Conference).

> [The conference] addressed the Allied position against Japan during World War II and made decisions about postwar Asia. [...] Soviet leader Stalin refused to attend the conference on the grounds that since Chiang was attending, it would cause provocation between the Soviet Union and Japan.

I like [the photo](https://en.wikipedia.org/wiki/File:Cairo_conference.jpg). Winston Churchill looks a little sad.

> The three main clauses of the Cairo Declaration are that "Japan be stripped of all the islands in the Pacific which she has seized or occupied since the beginning of the First World War in 1914", "all the territories Japan has stolen from the Chinese, such as Manchuria, Formosa, and the Pescadores, shall be restored to the Republic of China", and that "in due course Korea shall become free and independent".

Mainland China did get Manchuria back, in the midst of its civil war, but Formosa and the Pescadores eventually went their own way. In due course, Korea became free and independent, but just as China, it split and hasn't been reunited yet.

So. Yesterday we left of with this error:

```
Method 'page_tags_path' not found for invocant of class 'November;Tags'
  in 'November::Tags::read_page_tags' at line 74:lib/November/Tags.pm
  in 'November::Tags::page_tags' at line 142:lib/November/Tags.pm
  [...]
```

That one was easy. Rakudo had [regressed](https://github.com/Raku/old-issue-tracker/issues/2272) on a certain feature, but it turned out we weren't dependent on that feature anyway. So I just [remove it](https://github.com/viklund/november/commit/0d56401f5f29db0e042d5ddf925e0832511475aa). Next!

```raku
Method 'e' not found for invocant of class 'Str'
  in 'Enum::ACCEPTS' at line 5250:CORE.setting
  [...]
```

Oh yeah, that's `$file ~~ :e` being `$file.IO ~~ :e` nowadays. I thought I fixed all of those, but evidently not. [Fixing now](https://github.com/viklund/november/commit/cab63ddded11183ba7a3aa77c5a2191bc4ea386e). Next!

```
postcircumfix:<{ }> not defined for type `Array`
  in <anon> at line 1
  in 'HTML::Template::substitute' at line 1
  in 'HTML::Template::output' at line 28:lib/HTML/Template.pm
  [...]
```

Ooh, interesting. Rakudo has changed a bit in how it loops over listy things in scalars; while you'd previously write `for ($contents<chunk> // ()) -> $chunk { ... }`, now it's just `for $contents<chunk>.list -> $chunk {`. [Fixing](https://github.com/masak/html-template/commit/f841583f6130e5fd5814909b6be7d2d5bcdb098f). Next!

```
Method 'HOW' not found for invocant of class 'Hash'
  in 'November::CGI::send_response' at line 1
  in 'November::CGI::send_response' at line 47:lib/November/CGI.pm
  in 'November::response' at line 388:lib/November.pm
  [...]
```

Eh? Ooh, something goes wrong when not passing in a hash to a routine with an optional hash parameter. That's a new one. [Submitting bug](https://github.com/Raku/old-issue-tracker/issues/2274), [fixing](https://github.com/viklund/november/commit/86acff6014e03f5941f4f75ef64a151b6867f3cd). Next!

At this point, I'm getting actual output from November. I'm so stuck in debug mode that I don't realize that's output. Instead, I think it's just a long error message. *Oh no*, I think.

But yay, it's output! It works!

Well. Um. Kinda. It outputs stuff like this.

```
Are y u eager t  see Per  6  eing re eased, s  y u  an write      
pr grams in it with ut w rrying if the  anguage is "d ne" yet?
```

(Yes, sentence chosen for maximum irony. So sue me.)

Anyway, there seems to be something wrong with `Text::Markup::Wiki::MediaWiki`. I have no idea what; never seen something like this before. But it's old code, so maybe not too surprising that it fails.

Seems the bug causing this hates the letters `b`, `c`, `l`, and `o`... oh, I know what that is! Will track down and fix tomorrow. I have a lingering feeling we're going to run into our old friend `.trans` again.
