# Some thoughts on tote
    
*Originally published on [6 October 2009](http://strangelyconsistent.org/blog/some-thoughts-on-tote) by Carl Mäsak.*

People reacted approvingly to [tote](Helpfully-addictive-tdd-on-crack.html), the nicest piece of vaporware I've never written. I received an interesting email pointing out that research on this goes back to "50s and 60s as part of the psychological movement of behaviourism"; my post was featured on [reddit](https://www.reddit.com/r/programming/comments/9lkmt/helpfully_addictive_tdd_on_crack/), and there were some [mentions](https://irclogs.raku.org/perl6/2009-09-17.html#13:17-0002) [on](https://irclogs.raku.org/perl6/2009-09-18.html#12:32-0001) [IRC](https://irclogs.raku.org/november-wiki/2009-09-23.html#06:33). All of this makes for a nice data point on how much attention you can make people pay something that isn't written yet. I don't think it's likely that tote, even if it turns out to be a nice harness, will ever get that kind of attention again. ☺

Speaking of capturing people's attention, I tend to make it a habit of including something bolded in the second paragraph, sort of my take-home message. I don't really have such a message today, except perhaps to say that in the past few weeks, **I've tried tote, and it works**. I've already spent hours in it, playing it like a game. Unfortunately, the versions I used are too hard-coded to the two projects I tried them on, so I still need to write the real thing from scratch. But I've learned some new things along the way, which I thought I'd relay here, partly for my future self, and partly for any readers interested in the (imminent) development of tote.

I used my tote prototype on two projects. To abstract away non-essentials, let's call them "project A" and "project B", respectively. They were different enough to make me think about the different TDD styles that tote needs to support.

Project A is a port. Its tests need to be ported along with the implementation, so the general workflow becomes (1) write test, (2) write code to make it pass, (3) refactor, if needed. Also known as red-green-refactor. Except that, as the image given by that link shows, the 'red' portion of the loop might be missing, and that might be fine, too. All talk about 'the test should fail' aside, sometimes (such as when porting the test suite) a test will succeed on the first run. We cannot mandate a red part.

Project B is also a port, but one in which the tests could be adapted from the ported project. So I have only steps (2) and (3) above. This had the advantage of making me think more clearly about test results and checkpoints.

My concept of "checkpoint" is akin to "leveling up" in role-playing games. It's when all your tests that used to pass still pass, but also some new test passes. The idea is that tote should be able to parse the test output, and be able to recognize checkpoints, and compare the latest test run against such a checkpoint to see if we've regressed, progressed, or neither. The checkpoint is also a good place to make a commit, maybe automatically with an appropriate commit message calculated from the test messages of the new test that was just made to pass.

Passing/not-passing is a two-state thing, so one way to look at a particular test run is as a long bit string. Now, let's say I want to compare a test run just made to that of the last checkpoint, to see whether we've regressed, progressed, or neither. My first idea was to classify the current test run as 'regressed' if bits had flipped over from 1 to 0, 'progressed' if bits had flipped over from 0 to 1, and 'neither' if the bit strings were equal, or if bits had flipped over in both directions. Here it is in Perl code:

```raku
sub compare_passes {
    my ($new, $old) = @_;
    return -1 if length $new < length $old;
    my ($regression, $progression) = 0, 0;
    for my $i (0..length $old) {
        my ($n, $o) = map { substr($_, $i, 1) }, $new, $old;
        if ($n < $o) {
            $regression = 1;
        }
        elsif ($n > $o) {
            $progression = 1;
        }
    }
    return $progression - $regression;
}
```

It's a mathematically elegant idea, but unfortunately it's flawed in practice. Think of project B, where all of the tests were already written. Those will count in the bitstream, and the bits after the point where you're currently working can distort the test result negatively in three ways: (1) you might have passed the test you were working on, but later tests failed randomly, so the state counts as 'neither' and you get no checkpoint; (2) you might have regressed on some tests before the one you were working on, but later tests succeeded randomly, so the state counts as 'neither', and you don't get a 'regression' notification; (3) the tests up to the test you were working on might be unchanged, but the tests after that might have passed or failed randomly, leading to spurious 'progression' or 'regression' states.

Notice how the idea of 'the test you were working on' spontaneously forced itself into the data model. It can be seen as an emergent attribute of the checkpoint bit string: it's simply the length of the initial run of 1's in that bit string. Expressing the 'regression', 'progression' and 'neither' states in this model is much simpler than before:

```raku
sub compare_passes {
    my ($new, $old) = @_;
    my ($passing_new_tests, $passing_old_tests)
        = map { /^(1*)/ and length $1 } $new, $old;
    return $passing_new_tests <=> $passing_old_tests;
}
```

When I tried out *this* idea in practice, it turned out to have a slight flaw as well, but not a fatal one this time: in project B type projects, some tests you can't reasonably make pass right now, but the "length of the initial run of 1's" model kinda demands that you do. You could move the tests, but that might not always be practical, and suddenly we're doing the tool favors, which sets a bad precedent. But having '# TODO' tests count as 1's in the bit string does the trick. Perhaps a more refined future model will even recognize when a TODO test starts passing, and consider that a checkpoint. But for now, this slightly muddled version will do.

After using the tote prototype for a while, I get that feeling one gets when tests do what they should. First, they form a dialogue between the programmer and the test suite: "Now?" - "Nope." - "Now?" - "Still not." - "How about now?" - "Yes, SUCCESS! Oh yay!". That's nice. An additional bonus, and quite a large one at that, is that the test suite might at any point say "Whoa! If you do that, then this (which used to work) will break. Careful." And that's a safety net, just as version control is a safety net, which actually allows me to be more reckless and try different ideas. And that's really, really nice. None of this is news, of course. But if you're still uncertain about whether to do unit tests, that's the reason you should consider it.

Also, a bit disappointingly, I find myself thrown out of the loop every time I save and the tote prototype goes into compile-then-test mode. I usually automatically Cmd-Tab to the browser and read a paragraph or two in the open tab. It's disappointing because the idea of tote is to keep me inside the loop, and not give me such a loophole. Maybe it's completely OK that this happens, or maybe I should find some way to stay focused on the code... looking for ways to refactor, or looking at the 'git diff' so far. I bring this up because it feels like a weakness of the system. Partly this is because Rakudo is slow, both when compiling and when running the tests. I think with a faster cycle overall, I'd distract myself less often.

Oh, and sometimes I wish there were a way to enter a 'narrow mode', where the tote framework would focus on one test, and one test only. That'd mostly solve the speed problem, actually. Once the test in question passes, 'wide mode' is turned on again and the whole test suite is run to check against regressions. Hm, I like that. The problem is that in the general case, it's not possible to pry out just one test from a test file and run only that. Maybe with some testing frameworks it might be. My old [Test::Ix](https://github.com/masak/druid/blob/master/t/01-game-rules.t) could probably be made to work that way, for example.

Each time I mention tote, I want it a little bit more.
