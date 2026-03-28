# November 25 2010 — the truth emerges
    
*Originally published on [25 November 2010](http://strangelyconsistent.org/blog/november-25-2010-the-truth-emerges) by Carl Mäsak.*

> 976 years ago today, Malcom II died and Duncan became the King of Scots. His cousin Macbeth, wasn't made king.

> Unlike the "King Duncan" of Shakespeare's Macbeth, the historical Duncan appears to have been a young man. He followed his grandfather Malcolm as king after the latter's death on 25 November 1034, without apparent opposition. He may have been Malcolm's acknowledged successor or *tánaise* as the succession appears to have been uneventful.

Wikipedia makes it sound like Macbeth had the right to the throne, but doesn't seem to explain how that squares with Duncan ascending it.

Ok, found the cause of the garbage.

```raku
my $cleaned_of_whitespace = $trimmed.trans( / \s+ / => ' ' );
```

Ironically, that's a line that I've been touching earlier this month. Huh. I really thought that worked, and that we had passing tests for this.

So, I [submitted a ticket](https://github.com/Raku/old-issue-tracker/issues/2277), and hope to have some time tonight to investigate this.
