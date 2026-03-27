# November 16 2009 — digging into some real paperwork
    
*Originally published on [17 November 2009](http://strangelyconsistent.org/blog/november-16-2009-digging-into-some-real-paperwork) by Carl Mäsak.*

> 64 years ago today, the first batch of German scientists is admitted to the US to help develop rockets. Their backgrounds were white-washed in what became known as [Operation Paperclip](https://en.wikipedia.org/wiki/Operation_Paperclip):

President Truman authorized Operation Paperclip in August 1945; however he expressly ordered that anyone found "to have been a member of the Nazi party and more than a nominal participant in its activities, or an active supporter of Nazi militarism" would be excluded.

Under this criterion many of the scientists recruited would have been ineligible. These included Wernher von Braun, Arthur Rudolph and Hubertus Strughold, who were all officially on record as Nazis and listed as a "menace to the security of the Allied Forces." All were cleared to work in the U.S. after having their backgrounds "bleached" by the military; false employment histories were provided, and their previous Nazi affiliations were expunged from the record. The paperclips that secured newly-minted background details to their personnel files gave the operation its name.

I can't help getting anachronistic visions of the little overly helpful character in Microsoft Word, popping up and saying "I see you're trying to write a fake CV without all your previous Nazi affiliations. Would you like some assistance?"

Today I started in on the accrued [lichtkindbugs](https://github.com/viklund/november/issues#list) in the November github site. I quickly fixed [20](https://github.com/viklund/november/issues#issue/20) and [21](https://github.com/viklund/november/issues#issue/21), and concluded that [22](https://github.com/viklund/november/issues#issue/22) is a duplicate of 10.

Now, what about that [10](https://github.com/viklund/november/issues#issue/10)? Why has the user committed a deadly URL just by visiting the history page of an article? I go to investigate.

```
$ ack 'deadly URL'
lib/November.pm
246:    method error_page($message = "You have commited a deadly URL") {
```

Ah. It's the default error message. This is written in the pre-LTA era, so I'll just change it to "An internal error occurred. Apologies." and move on.

I'm not one to throw rocks, by the way. The login page still says "Everything you say can, and will, be used against you. Please put on your own mask first, then help others." because I was in a less-than-serious mood when I made it. I have no ideas what to write there instead, though, so I'm leaving it. Others are welcome to contribute a better wording.

```
$ ack error_page
lib/November.pm
32:        my $d = Dispatcher.new( default => { self.error_page } );
246:    method error_page($message = "An internal error occurred. Apologies.") 
kaye:november masak$ vi lib/November.pm
```

Look at that. It's referred to exactly once, namely when the dispatcher finds nothing better to do with its input. Could it be...?

Yes, it could. We have all these actions, but no `history` action.

```raku
$d.add: [
  [''],                     { self.view_page },
  ['view', /^ <-[?/]>+ $/], { self.view_page(~$^page) },
  ['edit', /^ <-[?/]>+ $/], { self.edit_page(~$^page) },
  ['in'],                   { self.log_in },
  ['out'],                  { self.log_out },
  ['recent'],               { self.list_recent_changes },
  ['all'],                  { self.list_all_pages },
];
```

So now I know the cause of the bug. I won't add the missing action today, but that's a perfect task for some other day.

Also, I'm seriously considering again changing the error message I just changed, to something more specific like "There's no action 'history'. Did you spell the URL correctly?" or something similar, seeing as it's only being used when actions are not found.

Ah. Finally some November action. I'm pleased. I had forgotten the warm feelings I have for this little wiki engine. It's starting to come back now.
