# A Request to Larry Wall to Create a Language Name Alias for Perl 6
    
*Originally published on [7 October 2018](https://perl6.party//post/A-Request-to-Larry-Wall-to-Create-a-Language-Name-Alias-for-Perl-6) by Zoffix Znet.*

I (Zoffix Znet) am writing this document to Larry Wall to request the creation of a second name for the *"Perl 6"* language. This name is *not* a rename of the language, but is simply an alternative name, an alias. Similar to how **TimToady** is an alias for *Larry Wall*.

It's been a year and a half since the time when I first re-opened this issue with a blog post, and in this document, I compiled the argumentation for creation of the alias, the community suggestions for what that alias might look like, along with the observations of discussions on the topic that occured during that time period.

I ask that Larry Wall renders his decision on the alias by November 1, 2018, so we would have the time to create proper informational materials for the 6.d language release, during which time, the name alias would be officially announced, if one is chosen.

## Community Alias

The [original idea for the alias](https://www.youtube.com/watch?time_continue=4885&v=E5t8qaAGw9w) came in the form of creating a "marketing alias", for markets where Perl "is a swear word." However, I believe such an alias has a more immediate application closer to home, by improving the wellbeing of the existing community and the interactions of its members with other programming communities, including the Perl community.

The idea of Perl 6 was birthed in the form of the community rewrite of the Perl language. This name alias, then, is the Community Alias for that language.

## Reasoning for Alias

The current language name "Perl 6" comes with a set of built-in assumptions that do not apply either to the language or to currently-available compilers for it. The assumptions encoded in the name are:

- It is similar to earlier Perl language (and thus comes with all the negative connotations attributed to it)
- It is the next version of Perl language
- It is faster, more stable, and "better" than earlier Perl language

In reality, what we have is an entirely brand new language. Different, and with all the caveats typical of brand new software.

#### Similarity

Other than the "spirit" some claim the Perl 5 and Perl 6 languages share, they're dissimilar in many ways.

```` raku
$ perl  -e 'print "I am a Perl ", "0" && 6||5, " program\n"'
I am a Perl program
$ raku -e 'print "I am a Perl ", "0" && 6||5, " program\n"'
I am a Raku program
````

In Perl 5 you choose your own OO system, concurrency/parallelism system, your list processing utilities, etc; in Perl 6, many of these features are a large part of the standard language itself. In Perl 5, you're told to never `use threads`; in Perl 6, even an empty program is multi-threaded (JIT runs on a separate thread). In Perl 5, lists autoflatten; In Perl 6, they don't and you have a choice of multiple core list types.

*Thus, we lose on two fronts: those who love Perl 5 and come to Perl 6 get disappointed because they get a different language; and those who hate Perl 5 never bother trying out Perl 6, assuming it's the same language they hate.*

#### Next Version

The naming of "Perl 6" has a strong suggestion that "6" is the version number rather than a part of the name. Some suggested it's easy to explain this caveat of naming, but my personal experience was quite the opposite of that. First, it's hard to wedge this information during a real-time meatspace conversation:
  
> — What are you working on?
>   <br>
>   — Writing an AI for a game in Python.
>   <br>
>   — You?
>   <br>
>   — Hacking on Rasperry Pi with C.
>   <br>
>   — You?
>   <br>
>   — Making a media center for my car in Perl 6. YES. YOU MAY HAVE HEARD OF PERL, BUT PERL 6 IS NOT PERL BUT A RELATED LANGUAGE.
>   <br>
>   — ...

Second, even after you make that clarification, people still continue to shorten the name to just Perl (*"You're the Perl guy, right?"*). Moreover, some media, such as banners and posters, often do not allow for adding a suitable clarification.

Lastly, similar shortening of the name occurs with some software, such as DuckDuckGo search engine producing results for Perl 5 instead of Perl 6 when searching for "raku argv".

The biggest issue here, however, is the relationship with the Perl 5 community. The mere existence of a "Perl 6" language paints Perl 5 as obsolete. While the Perl 6 community has to make clarifications to distance itself from Perl 5's negatives that don't apply to Perl 6, the Perl 5 community must make the same clarifications just to convince people they're not dead. This brews understandable animosity towards Perl 6.

The Perl 5 language is effectively blocked from releasing the next "major version", because Perl 6 is squatting on it. And were Perl 5 to release a "Perl 7", that would immediatelly paint Perl 6 as obsolete. The lack of any established alternate names leaves Perl 6 vulnerable to such a scenario.

*Thus, we have three community issues: difficulty for community to explain what language they're using; difficulty for community to find information about the language; and difficulty of amicable existence beside the Perl 5 community.*

#### Speed and Stability

The Christmas release of Perl 6 came with a caveat that it's the *language spec* that's stable now, and the compiler itself needed more work. That is exactly the sort of a caveat you'd expect to come with a brand new language.

However, our brand new language is not named that way. The current name suggests it's the next version of Perl and thus it should be slightly different, and faster and more stable. None of which is currently true. By using the name to associate ourselves so closely with Perl 5, we effectively set a performance target to surpass. Yet, due to how new our language is, there is still a lot of work needed to reach that target, and due to significant differences between the languages, some of these targets might not be met when comparing exactly the same constructs (e.g. Raku regexes produce a much more complex data structure—a tree of `Match` objects).

*Thus, by mislabeling our brand new language with a next-version language, we suffer disproportionally when our compiler does not perform as well or is not as stable as a well-established language.*

#### Summary

In summation, the name "Perl 6" is a misrepresentation. It's a wrong label on a can. It causes friction within the broad Perl community and confusion or difficulty when communicating with those outside the Perl community.

It sets incorrect expectations of performance, stability, and features of the language.

It is detrimental to our future.

## No Full Rename

While numerous members of the community would have liked to see a full language rename, there are also those who believe a full rename would be detrimental. The full rename at this point in time is also a lot more challenging due to the existence of books, websites, documentation, environmental variables, and dynamic variables in the language—all with the name "Perl" in them.

As such, we are creating an alias only. One that does not have any reference to Perl in it (i.e. no "*Perl*++"). If another name is truly as superior as the full-rename proponents claim it would be, I believe the alias can become a defacto name through its sheer amount of use. Thus, the creation of the alias can be seen as a means for the full-rename proponents to prove their claims.

## References

What follows are references to real-world examples of confusion and problems due to the current name, additional community discussions on the naming along with suggestions for what that name can be, and other resources relevant to the topic.

#### Naming Confusion

The *(parentheticals)* indicate what issue was encountered in an item. The issues refer to issues examined in *Reasoning for Alias* section above.

- *(next version)* The first paragraph of *Learning Perl 6*: "Welcome to the first edition of Learning Perl 6, a book title that sounds similar to others you may have read and I may have written. This one, however, is my first book about the language called "Perl 6." I know the name is a bit confusing; I'm not in charge of that part. I'm just the book writer."
- *(next version)* "I thought raku was meant to be a natural upgrade, but if there is a competition between them, why hijack its name and version path?" [https://twitter.com/nicomen/status/1045997248645976064](https://twitter.com/nicomen/status/1045997248645976064)
- *(similarity)* "<JJJ> I think this chatroom is as dead as the perl language. ouch!" [http://colabti.org/irclogger/irclogger_log/raku?date=2018-08-14#l241](http://colabti.org/irclogger/irclogger_log/raku?date=2018-08-14#l241)
- *(next version)* Confusion that Perl 6 is older than Python, [https://twitter.com/brentsaner/status/1028737133064998913](https://twitter.com/brentsaner/status/1028737133064998913) when naming was clarified, followed by *(similarity)* by claiming it's "still" unreadable
[https://twitter.com/brentsaner/status/1028738466161610752](https://twitter.com/brentsaner/status/1028738466161610752)
- *(next version)* Interview about CommaIDE, with people surprised Perl is "still" a thing [https://www.facebook.com/JetBrains/posts/1893431294013449](https://www.facebook.com/JetBrains/posts/1893431294013449)
and *(similarity)* as well, with people cracking jokes thinking Raku is outdated.
- *(next version)* in a book [https://www.reddit.com/r/perl/comments/72u6g5/we_suggest_avoiding_perl_for_new_work_at_this/](https://www.reddit.com/r/perl/comments/72u6g5/we_suggest_avoiding_perl_for_new_work_at_this/)
- *(next version)* in an Issue about broken Perl 6 GitHub highlights: [https://github.com/github/linguist/issues/3637#issuecomment-319026186](https://github.com/github/linguist/issues/3637#issuecomment-319026186)
- *(next version)* question about "moving to" Perl 6: [https://www.reddit.com/r/perl/comments/6qsv6k/how_many_people_plan_to_move_to_perl_6/](https://www.reddit.com/r/perl/comments/6qsv6k/how_many_people_plan_to_move_to_perl_6/)
- *(similarity)* search results for wrong language [http://colabti.org/irclogger/irclogger_log/raku?date=2017-08-02#l447](http://colabti.org/irclogger/irclogger_log/raku?date=2017-08-02#l447)

#### Naming Suggestions

- Damian's email in response to my earlier articles on naming: [https://gist.github.com/zoffixznet/522abeb84debe64041ea70afeebc058a](https://gist.github.com/zoffixznet/522abeb84debe64041ea70afeebc058a)
- Damian's comments on the naming in the middle of the article: (search: "if you got to choose what Raku be called"):
[https://www.mappingthejourney.com/single-post/2017/11/09/episode-13-interview-with-damian-conway-designer-of-perl-6-programming-language/](https://www.mappingthejourney.com/single-post/2017/11/09/episode-13-interview-with-damian-conway-designer-of-perl-6-programming-language/)
- Discussion Thread 1: [https://www.reddit.com/r/perl/comments/6lstqu/the_hot_new_language_named_rakudo/](https://www.reddit.com/r/perl/comments/6lstqu/the_hot_new_language_named_rakudo/)
- Discussion Thread 2: [https://www.reddit.com/r/raku/comments/6lstq3/the_hot_new_language_named_rakudo/](https://www.reddit.com/r/raku/comments/6lstq3/the_hot_new_language_named_rakudo/)
- Discussion Thread 3: [http://blogs.perl.org/users/zoffix_znet/2017/07/the-hot-new-language-named-rakudo.html#comments](http://blogs.perl.org/users/zoffix_znet/2017/07/the-hot-new-language-named-rakudo.html#comments)
- Discussion Thread 4: [https://www.reddit.com/r/raku/comments/70ojde/the_rakudo_book_project/dna3ayb/](https://www.reddit.com/r/raku/comments/70ojde/the_rakudo_book_project/dna3ayb/)
- Reddit thread asking for names, with upvotes as poll: [https://www.reddit.com/r/perl/comments/7rjr8u/new_name_for_perl_6_languageenvironment/](https://www.reddit.com/r/perl/comments/7rjr8u/new_name_for_perl_6_languageenvironment/)
- Branding Proposal/Collection of proposed names [http://nigelhamilton.com/perl-branding-proposal.html](http://nigelhamilton.com/perl-branding-proposal.html) and some discussion that followed [http://colabti.org/irclogger/irclogger_log/raku?date=2018-03-16#l532](http://colabti.org/irclogger/irclogger_log/raku?date=2018-03-16#l532) *(Editor's note: all the names with "Perl" in them would only have merit in a full language rename; they miss the point when it comes to alias creation)*
- "Lusk" -> "mollusk" -> "makes pearls" suggestion: [https://www.reddit.com/r/raku/comments/8987l1/raku_renaming_status/dwppvd7/](https://www.reddit.com/r/raku/comments/8987l1/raku_renaming_status/dwppvd7/)
- "6lang" (suggested on IRC)
- "+-1" as name: [https://mail.pm.org/pipermail/toronto-pm/2017-November/004023.html](https://mail.pm.org/pipermail/toronto-pm/2017-November/004023.html)

#### Other

- Calls for a revolt: [https://www.reddit.com/r/perl/comments/8b5yoh/why_do_you_have_to_be_afraid_of_the_programming/dx63nq2/](https://www.reddit.com/r/perl/comments/8b5yoh/why_do_you_have_to_be_afraid_of_the_programming/dx63nq2/)
- Mail list thread on naming debate: [https://www.nntp.perl.org/group/perl.raku.language/2018/02/msg36759.html](https://www.nntp.perl.org/group/perl.raku.language/2018/02/msg36759.html)
- Naming bikeshed in comments on Issue: [https://github.com/raku/doc/issues/1807](https://github.com/raku/doc/issues/1807)
- Lots of bits in the comments about bad name: [https://www.reddit.com/r/perl/comments/7r1b33/an_open_letter_to_the_perl_community/](https://www.reddit.com/r/perl/comments/7r1b33/an_open_letter_to_the_perl_community/)
- Larry's answer to question about naming: [https://youtu.be/E5t8qaAGw9w?t=1h21m25s](https://youtu.be/E5t8qaAGw9w?t=1h21m25s)
- Having space in the name broke GitHub highligher: [http://colabti.org/irclogger/irclogger_log/raku?date=2018-01-06#l687](http://colabti.org/irclogger/irclogger_log/raku?date=2018-01-06#l687)
- Weekly from when first (recent) blog post on naming went out: [https://p6weekly.wordpress.com/2017/07/10/2017-28-rakudo-is-hot/](https://p6weekly.wordpress.com/2017/07/10/2017-28-rakudo-is-hot/)
- Even a positive article about Raku starts with: "Want to hear a programming joke?     Raku."
[http://www.evanmiller.org/why-im-learning-perl-6.html](http://www.evanmiller.org/why-im-learning-perl-6.html)
- Request for examples of why "Raku" is a good name: [https://twitter.com/zoffix/status/1028977967454666758](https://twitter.com/zoffix/status/1028977967454666758)

## Conclusion

With the 6.d release around the corner, we have approached the point where a direct request to Larry Wall is made with the matter of assuaging the problem of the naming of the language.

Through a year and a half worth of discussions, we came to a conclusion that a second name to the language should be created, as opposed to a full rename. This will let the proponents of a rename to prove their claims, without severely upsetting those who believe the current name is beneficial.

This document presented argumentation for why a second name is beneficial, as well as compiled the discussions and suggestions that occured during that year and a half.

It is now up to **TimToady** to reach the final decision on whether the official alias is to be created during the 6.d language release and what that alias is to be.

See you at the 6.d release party! Bring your own virtual beer.
