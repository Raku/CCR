# November 16 2010 — the polite revolt
    
*Originally published on [16 November 2010](http://strangelyconsistent.org/blog/november-16-2010-the-polite-revolt) by Carl Mäsak.*

> 22 years ago today, Estonia took its first step towards independence, after having been [continually occupied](https://en.wikipedia.org/wiki/History_of_Estonia) since 1940 by first the Soviet Union, then by Nazi Germany, and then once again by the Soviet Union.

> The Republic of Estonia was occupied by the Soviet Union in June 1940. [...] After Nazi Germany invaded the Soviet Union on June 22, 1941, and the Wehrmacht reached Estonia in July 1941, most Estonians greeted the Germans with relatively open arms and hoped to restore independence. But it soon became clear that sovereignty was out of the question. Estonia became a part of the German-occupied "Ostland". [...] By the late autumn of 1944, Soviet forces had ushered in a second phase of Soviet rule on the heels of the German troops withdrawing from Estonia, and followed it up by a new wave of arrests and executions of people considered disloyal to the Soviets.

In the climate of Gorbachev's [Perestroika](https://en.wikipedia.org/wiki/Perestroika), however, Estonia could begin taking steps towards regaining independence.

> The Estonian Sovereignty Declaration was issued on November 16, 1988.

*Sovereignty* isn't the same as *independence*. This was only the first step in a chain of events that didn't end until 1994 with Russian (no longer Soviet) armed forces withdrawing from Estonia. It's the steps in the middle that are awesome, however. A new parliament was formed through a *grassroots* movement:

> A grassroots Estonian Citizens' Committees Movement launched in 1989 with the objective of registering all pre-war citizens of the Republic of Estonia and their descendants in order to convene a Congress of Estonia. Their emphasis was on the illegal nature of the Soviet system and that hundreds of thousands of inhabitants of Estonia had not ceased to be citizens of the Estonian Republic which still existed *de jure*, recognized by the majority of Western nations. Despite the hostility of the mainstream official press and intimidation by Soviet Estonian authorities, dozens of local citizens' committees were elected by popular initiative all over the country. These quickly organized into a nation-wide structure and by the beginning of 1990, over 900,000 people had registered themselves as citizens of the Republic of Estonia.

Estonia was unusual among the Baltic states both in the leading role it took in negotiating its independence, and the bloodlessness by which it happened.

Ok, remember how yesterday, I left off with a `"Cannot modify readonly value"` error? Turns out the reason for the error is at least of mild interest. Here's a simplified version of what happened in November (the wiki engine):

```
$ raku -e 'sub foo($x is rw = "OH HAI") { $x .= lc; say $x };
>           my $y = "TESTING"; foo($y);
>           `foo`'
testing
Cannot modify readonly value
  in '&infix:<=>' at line 1
  in 'foo' at line 1
  in main program body at line 1
```

See what's happening there? Our parameter `$x` is declared to be modifiable (`is rw`), but we can only actually modify it if we send in a variable from the outside. If we let the parameter assume its provided default (`"OH HAI"`), it no longer allows modification.

Is this correct? I can argue both ways on that point, I guess.

On one hand, assigning the default `"OH HAI"` to `$x` could be seen as equivalent to passing in the literal `"OH HAI"` to `&foo`. In this case, we do expect any modification to blog up with a `"Cannot modify readonly value"` error, because what we've bound to `$x` isn't really a variable, it's a constant literal.

On the other hand, we did specify that `$x` be `rw`, and we're not really passing in `"OH HAI"`, we're providing it as a default. So what's stopping Rakudo from *assigning* (rather than binding) `"OH HAI"` to `$x`, allowing for subsequent modification?

I'm currently leaning towards the other hand. ☺ But I'm betting *jnthn*++ will have useful input to offer, since he's the signature binder guy.

Here's an even smaller example of the same underlying issue:

```
$ raku -e 'sub foo($x? is rw) { $x = "OH HAI" }; `foo`'
Cannot modify readonly value
  in '&infix:<=>' at line 1
  in 'foo' at line 1
  in main program body at line 1
```

That is, when we don't pass in a value, it doesn't matter that `$x` has been declared `is rw`; we still can't modify it.

As a temporary workaround, `is copy` seems to solve all the perceived issues.

```
$ raku -e 'sub foo($x is copy = "OH HAI") { $x .= lc; say $x };
>           my $y = "TESTING"; foo($y);
>           `foo`'
testing
oh hai
```

So maybe the answer to my worries is simply "use `is copy` and stop whining!". Actually, now that I look at the original failing code, it's pretty clear to me tha `is copy` is a better fit in this case. But I'm still curious whether we can do better when `is rw` interacts with defaults. [**Update:** This is now [rakudobug #79288](https://github.com/Raku/old-issue-tracker/issues/2262).] [**Update on the update:** By the decree of a spec patch, [this discussion is now moot](https://github.com/raku/specs/commit/44511d749bbbae4286dd1675ad6264c72acd2433).]

[Applying that workaround](https://github.com/viklund/november/commit/57a5c0e1ceab1e53711700f3bbb1249aa84ada3f) I find, unsurprisingly, more bitrot-related runtime errors that require fixing. Some `$file ~~ :e` need to be [turned into `$file.IO ~~ :e`](https://github.com/viklund/november/commit/d157b1e59d06df794cae9f4a1a2b72d4889f1588). I end today's bushwhacking on a faulty `Str.trans` call somewhere in `Text::Markup::Wiki::MediaWiki`.
