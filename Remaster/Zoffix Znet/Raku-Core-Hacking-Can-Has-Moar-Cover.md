# Raku Core Hacking: Can Has Moar Cover?
    
*Originally published on [22 September 2016](https://perl6.party//post/Perl-6-Core-Hacking-Can-Has-Moar-Cover) by Zoffix Znet.*

One of the more recent features of [MoarVM](http://www.moarvm.org/) (Raku's leading virtual machine) is the coverage reporter created by [Timo Paulssen](https://twitter.com/loltimo). In fact, it's still experimental and lives in its own branch. So today, I'll talk about how to build it and use it, as well as how you can give a helping hand to the Raku development.

## Part I: We Need To Talk About Your TPS Reports

As I've mentioned, coverage reporting is experimental, so many of the conditionals and individual lines may be wrong. What is mostly correct are the subs and methods. And you can help us out by writing tests for the uncovered ones!

There are several ways to get your hands on the core coverage report...

### [raku.WTF](http://raku.WTF/)

First, you don't have to build or run anything... I did it for you! You can view the current coverage status at [raku.WTF](http://raku.WTF). At its current state, I don't really have the infrastructure to update this continuously, because to do it right, we have to run stresstest a couple of times, so be sure to check the built-on date at the top of the page. I'll try to run it at least once a day.

### Undercover Robots

I've also built a bot called `Undercover`. It's in both [#raku](https://webchat.freenode.net/?channels=#raku) and [#rakuev](https://webchat.freenode.net/?channels=#rakuev) IRC channels, but if you want to run more than just a few commands, join in to the [#zofbot](https://webchat.freenode.net/?channels=#zofbot) channel, so you don't annoy anyone.

  
> **<Zoffix>** c: &pairs, (@ = ^10)<br>

> **<Undercover>** Zoffix, The code is NOT hit during stresstest See http://raku.WTF/src_core_​Any.pm.coverage.html#L464 for details

The bot is triggered with `c:` trigger and takes the same input as my other `SourceBaby` robot, which is the arguments to the [`sourcery` subroutine of my CoreHackers::Sourcery module](https://github.com/zoffixznet/rakuoreHackers-Sourcery#subroutines).

If the arguments you gave locate a proper Callable, the bot will provide a link to its coverage report.

### Build It Yourself

You can also build the coverage reporter yourself, so that you can run it any time you want and get the up-to-date version.

First, you may be reading this article far in the future enough that the coverage branch is already included in master MoarVM. You can check it by running:

```` raku
moar --help | grep COVER
````

Or, if you're in a Rakudo's build directory, by running:

```` raku
install/bin/moar --help | grep COVER
````

If this or similar line shows up, the coverage support is already there:

```` 
MVM_COVERAGE_LOG            Append line-by-line coverage messages to this file
````

If not, no worries, we'll build it. Here's a script that can do it. This builds Rakudo in `~/coverakudo` and generates the coverage HTML report in `~/coverakudo/coverage/index.html`

````
#!/bin/bash
# print out the commands we run and bail out on failures
set -x
set -e
# Check out rakudo into ~/coverakudo. You can change it to any dir you want
git clone https://github.com/rakudo/rakudo ~/coverakudo
# go to that dir
cd ~/coverakudo
# Configure
perl Configure.pl --gen-moar --gen-nqp --backends=moar
# Disable the optimizer, so routines we want don't get optimized away
perl -pi -e 's/--optimize=\K3/off/' Makefile
# Build Rakudo
make
# Install Rakudo
make install
# Go to MoarVM dir
cd nqp/MoarVM
# Check out the branch with coverage support
git checkout $(git branch -r | grep origin/line_based_coverage | tail -n1)
# Bring in any latest MoarVM changes from master
git pull --rebase https://github.com/MoarVM/MoarVM/
# Configure MoarVM
perl Configure.pl --prefix=../../install/
# Build MoarVM
make
# Install MoarVM
make install
# Go back to rakudo dir
cd ../..
# Just check that we've got coverage now. Should say "WE SUCCEEDED!!"
install/bin/moar --help | grep MVM_COVERAGE_LOG                 &&
      echo 'We SUCCEEDED!!'                                     ||
    { echo 'WE FAILED!!!!'; exit 1; }
# The following steps download `panda` package manager and install
# Inline::Perl5 module that we need for Rakudo stress testing. You may need
# a specially-built Perl for it. You can use `perlbrew` to obtain it.
# See instructions at https://github.com/niner/Inline-Perl5#building
git clone https://github.com/tadzik/panda
export PATH=`pwd`/install/bin:$PATH
cd panda; raku bootstrap.pl
cd ..
export PATH=`pwd`/install/share/raku/site/bin:$PATH
panda install Inline::Perl5
# Delete coverage directory, if it's there already
rm -fr coverage
# Create coverage dir; we'll store our coverage report here
mkdir coverage
# Turn off auto-bail-out, since stresstests may fail and that's OK
set +e
# Run stresstest. The MVM_COVERAGE_LOG var tells MoarVM where to store
# coverage report files; the `%d` in the filename is necessary to store
# the process IDs of running tests!
MVM_COVERAGE_LOG='coverage/cover-%d' TEST_JOBS=8 make stresstest
#########################
## Note: at least on my box, some stresstest flapped and exited early,
## because apparently disabling the optimizer changes the test results.
## For that reason, to get full coverage either run the stresstest
## several times, or run individual failing test files a few times with
## MVM_COVERAGE_LOG='coverage/cover-%d' make t/spec/THE-TEST-FILE.t
## some test files may end with `.rakudo.moar` extension. Change it to `.t`
#########################
# Bail out on fail
set -e
# Go into directory with all the coverage files
cd coverage
# Find entries we want, make sure they're unique, and store them all in
# a file. This step may take awhile to run, especially if you ran the
# entire stresstest several times
cat * | grep 'gen/moar/m-CORE.setting' | sort | uniq > full-cover
# Go back up
cd ../
# Generate the setting annotations
install/bin/moar --dump CORE.setting.moarvm > setting
# Run the coverage report
./raku nqp/MoarVM/tools/parse_coverage_report.p6 \
    --annotations=setting coverage/full-cover gen/moar/m-CORE.setting
# It's ready! All of the files are in coverage/ directory and you can
# start viewing them by opening coverage/index.html in your favourite browser
firefox coverage/index.html
````

You can also generate coverage reports for arbitrary chunks of code. You can use the same script, but simply replace this line:

```` raku
MVM_COVERAGE_LOG='coverage/cover-%d' TEST_JOBS=8 make stresstest
````

With this:

```` raku
MVM_COVERAGE_LOG='coverage/cover-%d' ./raku -e 'SOME CODE'
````

Or this:

```` raku
MVM_COVERAGE_LOG='coverage/cover-%d' ./raku some-script.p6
````

## Part II: Can Has Moar Cover?

While the reports are pretty, we don't want to just stare at them, we want to
improve them!

The `t/spec` directory in your Rakudo build directory will contain a checkout of [The Official Raku Test Suite or "Roast"](https://github.com/raku/roast/).  If you'd like to work on your own fork, just check it out into that directory and it'll work just the same. Our goal here is to find uncovered subroutines and methods using the coverage report and add tests for them. Most of the times, the uncovered versions will be multi candidates that take some uncommon arguments or handle degenerate cases. We need to find where the rest of the candidates are tested and add our tests along with them, but before we do, I want to make something clear:

#### What Rakudo Does Does Not Define Raku

Rakudo is *a* compiler for the Raku language and the Roast defines what that language is, not the other way around. Just because a particular method in Rakudo returns a particular value does not mean that value is correct. So, keep this in mind, and be suspicious of any weird behaviour. If in doubt whether the test you're about to write is testing the wrong behaviour, double-check with the folks in [#rakuev channel](https://webchat.freenode.net/?channels=#raku-dev).

---

There are two techniques that serve well for finding where to put your tests. First, try to find the name of the routine you want to cover right in the filename of the test. We can do it by piping the output of `tree -f` to `grep`. Here's a way to find where `.splice` method is tested:

```` raku
$ tree -f | grep splice
│   ├── ./S32-array/splice.t
````

If that fails, try to find the method by grepping over files' contents:

```` raku
$ grep -R '.combinations'
... lots of output ...
S32-list/combinations.t:# L<S32::Containers/List/=item combinations>
... lots of output ...
````

For most methods, that will give you an idea of which file is right, otherwise, try to find the best you can. A test in the wrong file is better than no test at all.

At the top of the test file, you'll find a plan that indicates how many tests you're expecting to run:

```` raku
plan 13;
````

Increase it by the number of tests you're adding. As for the tests themselves, I like to place them at the end of the file, in a separate block labeled that these are coverage tests:

```` raku
{ # coverage; 2016-09-21
    is Foo, 'Bar', 'Foo is Bar';
    ...
    ...
}
````

This way, if the tests' validity comes into question in the future, it will be easy to see that the tests were added as part of coverage, likely based on Rakudo's behaviour, rather than as part of thinking through of how the language is meant to work.

Once that is done, check your tests pass. From Rakudo's build directory, run `make t/spec/your-test-file`:

```` raku
make t/spec/S32-list/combinations.t
... lots of output...
All tests successful.
Files=1, Tests=13,  1 wallclock secs ( 0.03 usr  0.01 sys +  0.64 cusr  0.06 csys =  0.74 CPU)
Result: PASS
````

If you do get failures, you can get a more verbose output by running `prove -vlr` instead:

```` raku
prove -e './raku' -vlr t/spec/S32-list/combinations.t
````

Once the tests pass, you're ready to commit your changes. I like to prefix the commit message with `[coverage]` to indicate these tests are part of coverage work, but this isn't necessary.

```` raku
git add S32-list/combinations.t
git commit
````

All done!

## Part III: The Future!

Reading the article, you can notice two pain points:

- I said I don't have infrastructure to run continuous coverage reports due to large computational requirements
- Finding where to add the tests can be a pain, and it's even more difficult to find where a particular routine candidate is tested

There is a way to ameliorate both of those issues. I don't think I'll have the time to do it, but perhaps there's a willing volunteer in the audience who can lend a helping hand.

### Were You Tested?

The way to get the data for where a routine is tested is to run coverage report *per test file*. The issue with that is [the coverage report generator script](https://github.com/MoarVM/MoarVM/blob/line_based_coverage_4/tools/parse_coverage_report.p6) takes ages to run. However, most of that time is spent reading the annotations file, which is the same on each run.

The way to speed up the script is to make it take multiple raw coverage reports and generate the HTML reports for each of them in separate directories. This way, the annotations would have to be read just once and we can generate batches of reports per-stresstest-file.

The next stage would be to make `Undercover` robot (or any other means) to go through that batch of reports and see in which reports a particular given line of code is covered. The result: we get a list of test files that cover a particular routine!

### Continuous reports

Being able to run continuous reports overlaps a bit with the previous point.  The main issue is to ensure as many tests as possible have ran. If any of the test files prematurely bail out, we need to re-run them. The current blunt-force tool for that is to re-run the stresstest several times. On the server I have available, each run takes 20 minutes, which is less than ideal.

So, if the individual files are tested, and there's a mechanism to re-test failing files a couple of times, to get rid of flappers, the coverage reports can then be re-generated continuously and entirely automatically, when new Rakudo or Roast commits come in.

### Better Cover

The reports themselves need improvement. How they work is beyond my current understanding, so if you're interested in helping with that work, contact [Timo Paulssen](https://twitter.com/loltimo) ([`timotimo` on #moarv channel](https://webchat.freenode.net/?channels=#moarvm)).

## Conclusion

MoarVM has a new experimental feature to report test coverage for code. The reports are available on [raku.WTF](http://raku.WTF), via `Undercover` IRC bot, or you can generate them yourself, by building the coverage MoarVM branch.

We could use volunteers for writing the missing [roast](https://github.com/raku/roast/) tests to improve coverage, improve the performance of coverage report generator, as well as improve the validity of the coverage report itself.

There's lots of work to be done and you can be part of our awesome team!  Join us!

-Ofun
