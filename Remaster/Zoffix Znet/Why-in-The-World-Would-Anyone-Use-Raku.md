# Why in The World Would Anyone Use Raku?
    
*Originally published on [12 January 2016](https://perl6.party//post/Why-in-The-World-Would-Anyone-Use-Perl-6) by Zoffix Znet.*

I mean, can you get it any more WRONG?! The juvenile logo and awful color scheme of the website.  The Christmas release that isn't all release-like. Version 6.c? Why not 6.0?  What's with the whole "language" and "compiler" distinctions no one cares about? Why is the first stable release of the compiler not optimized to the max? And why is it called "Perl" in the first place? They should rename it!!

Too little, too late. Is there a need for a new Perl? No, of course not.  What is it good for? Nothing. What is its business case? None! What's Raku's "Killer App"? Non-existent. Why in the world would anyone use Raku?!

In the three short months since I joined the Raku community, those are some of the criticisms and attacks I had to endure—and sometimes respond to—on blogs, HackerNews, IRC, and [Twitter](https://twitter.com/zoffix).... I don't mind it at all, since there's little substance in those attacks. At the end of the day, I'm just writing my Raku code. Enjoying it a lot, too.

Am I not meant to?

Must I look for logos tailored to the 50-something CIOs and not logos aiming to [discourage misogyny in the community](https://raw.githubusercontent.com/raku/mu/master/misc/camelia.txt), before I even try the language? Must I demand the first stable release of something to perform better than other things that had a couple of decades of optimization? Must I demand from volunteers they spend the Holidays making a picture-perfect release instead of enjoying rest with their families? Must I hold every open-source tool I use to such standards? A solid, clear business case or "Get The F\*#k Out" (GTFO)?

![cowsay](cowsay.png)

English isn't my native language. That language is something else and I can barely speak it now. Don't have much use for it. In fact, I dislike it. It's nothing major—some of the most famous literature in the world is written in that language, after all—but... well... it's the little things.

Maybe it's having too many letters or weird letters that aren't usually present on a keyboard. Maybe there are too many rules and too many special cases for them too! Maybe... Ugh, the language is just ugly, you know? I want results and not a language.

Of course, the same applies to programming languages too. It's the little things. Like having to write `foo(1, 2, 3)` instead of `foo 1, 2, 3`; or writing `some_var` instead of `some-var`; importing a lot of functionality instead of having it available from the get-go; perhaps writing `if 5 < x and x < 100` instead of the much clearer `if 5 < $x < 100`; or how about checking a set contains only valid elements? In Raku, it's just a set operator away: `if @given ⊆ @valid`; or use [subsets and junctions](https://github.com/zoffixznet/rakuO-MiddleMan/blob/347bfe653524b96595cfe80c5371317a269f47c8/lib/IO/MiddleMan.pm6#L3)!  I want results and not a language.

Omitted parentheses and fancy operators are little things, I know. But they add up. [Some programs](https://metacpan.org/source/ZOFFIX/Number-Denominal-2.001001/lib/Number/Denominal.pm) that I [converted to Raku](https://github.com/zoffixznet/rakuumber-Denominate/blob/master/lib/Number/Denominate.pm6) are nearly *half* the original size. In a 100,000-line program, that's 50,000 lines you don't have to write, **and, especially, read later**.

And it's things like these that make me enjoy programming in Raku. It's this that makes me feel—once again—the wonder I experienced 16 years ago, when I wrote my first program: writing something simple and getting the result, as if by magic. It's hackers like me who will nurture Raku and help her grow. The trailblazers.  The unabashed. We stare in the face of critique without flinching. We use the tools with value, not ones with solely a marketing campaign. We'll build the ecosystem and the killer apps. And should you decide to give our tool a spin and should you like it, we'll welcome you with open arms.

Why in the world would anyone use Raku? Well... it's the little things.
