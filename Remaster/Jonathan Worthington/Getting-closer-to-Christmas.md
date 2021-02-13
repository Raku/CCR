# Getting closer to Christmas
    
*Originally published on [2015-12-05](https://6guts.wordpress.com/2015/12/05/getting-closer-to-christmas/) by Jonathan Worthington.*

The list of things we “really want to do” before the Christmas release is gradually shrinking. Last time I wrote here, the xmas RT list was around 40 tickets. Now it’s under 20. Here’s an overview of the bits of that I’ve been responsible for.

### Supply API cleanup

I did the original implementation of supplies a couple of years back. I wasn’t sure how they would be received by the wider community, so focused on just getting something working. (I also didn’t pick the name `Supply`; *Larry* is to thank for that, and most of the other naming). Supplies were, it turns out, very well received and liked, and with time we fleshed out the available operations on supplies, and 6 months or so back I introduced the `supply`, `whenever`, and `react` syntactic sugar for supplies.

What never happened, however, was a cleanup of the code and model at the very heart of supplies. We’ve had to “build one to throw away” with nearly everything in Raku, because the first implementation tended to show up some issues that really wanted taking care of. So it was with supplies. Thankfully, since everything was built on a fairly small core, this was not to be an epic task. And, where the built-ins did need to be re-worked, it could be
done much more simply than before by using the new `supply` / `whenever` syntax.

While much of the cleanup was to the internals, there are some user-facing things. The most major one is a breaking change to code that was doing `Supply.new` to create a live supply. As I started cleaning up the code, and with experience from using related APIs in other languages, it became clear that making `Supply` be both the thing you tapped and the thing that was used to publish data was a design mistake. It not only would make it harder to trust `Supply`-based code and enforce the `Supply` protocol (that is, `emit [done | quit]`), but it also would make it hard to achieve the good performance by forcing extra sanity checks all over the place.

So, we split it up. You now use a Supplier in order to publish data, and obtain a Supply from it to expose to the world:

```` raku
# Create a Supplier
my $supplier = Supplier.new;

# Get a Supply from it
my $supply = $supplier.Supply;
$supply.tap({ .say });

# Emit on it
$supplier.emit('oh');
$supplier.emit('hai');
````

This also means it’s easy to keep the ability to emit to yourself, and expose the ability to subscribe:

```` raku
class FTP::Client {
    has $!log-supplier = Supplier.new;
    has $.log = $!log-supplier.Supply;
    ...
}
````

Since you can no longer call `emit` / `done` / `quit` on a `Supply`, you can be sure there won’t be values getting sneaked in unexpectedly.

The other change is that we now much more strongly enforce the supply protocol (that is, you’ll never see another `emit` after a `done` / `quit` unless you really go out of your way to do so) and that only value will be pushed through a chain of supplies at a time (which prevents people from ending up with data races). Since we can ask supplies if they are
already sane (following protocol and serial (one at a time), we can avoid the cost of enforcing it at every step along the way, which makes things cheaper. This is just one of the ways performance has been improved. We’ve some way to go, but you can now push into the hundreds of thousands of messages per second through a `Supply`.

Along the way, I fixed exceptions accidentally getting lost when unhandled in supplies in some cases, a data loss bug in `Proc::Async` and `IO::Socket::Async`, and could also resolve the RT complaining that the supply protocol was not enforced.

### Preparing ourselves for stronger back-comparability

Once the Raku Christmas release of the language is made, we’ll need to be a lot more careful about not breaking code that’s “out there”. This will be quite a change from
the last months, where we’ve been tweaking lots of things that bothered us. To help us with this change, I [wrote up a proposal](https://gist.github.com/jnthn/f3a691016c20f0cc4cfa) on how we’ll manage not accidentally changing tests that are part of the Raku Christmas language definition, allow code to be marked with the language version it expects, and how we’ll tweak our process to give us a better chance of shopping solid releases that do not introduce regressions. Further feedback is still welcome; as with all development process things, I expect this to continue to evolve over the years.

### I/O API cleanups

A few tickets complained about inconsistencies in a few bits of the I/O APIs, such as the differing ways of getting supplies of chars/bytes for async processes, sockets, and files. This has received a cleanup now. The synchronous and asynchronous socket APIs also got a little further alignment, such that the synchronous sockets now also have connect and listen factory methods.

### Bool is now a real enum

This is a years old issue that we’ve finally taken care of in time for the release: `Bool` is now a real `enum`. It was mostly tricky because `Bool` needs setting up really quite early on in the language bootstrap. Thankfully, *nine*++ spent the time to figure out how do to this. His patch nearly worked – but ran into an issue involving closure semantics with `BEGIN` and `COMPOSE` blocks. I fixed that, and was able to merge in his work.

### Interaction of start and dynamic variables

A start block can now see the dynamic variables where that were available where it was started.

```` raku
my $*TARGET_DIR = 'output/';
await start { say $*TARGET_DIR } # now works
````

### Correcting an array indexing surprise

Indexing with a range would always auto-truncate to the number of elements in an array:

```` raku
my @a = 1, 2, 3;
say @a[^4]; # (1 2 3)
````

While on the surface this might be useful, it was rather good at confusing people who expected this to work:

```` raku
my @a;
@a[^2] = 1, 2;
say @a;
````

Since it auto-truncated to nothing, no assignment took place. We’ve now changed it so only ranges whose iterators are considered lazy will auto-truncate.

```` raku
my @a = 1, 2, 3;
say @a[^4]; # (1 2 3 (Any)) since not lazy
say @a[0..Inf] # (1 2 3) since infinite is lazy
say @a[1..Inf] # (2 3) since infinite is lazy
say @a[lazy ^4] # (1 2 3) since marked lazy
````

### Phaser fixes

I fixed a few weird bugs involving phasers.

- RT #123732 noted that return inside of a `NEXT` phaser but outside of a routine would just cause iteration to go to the next value, rather than give an error (it now does, and a couple of similarly broken things also do)
- RT #123731 complained that the use of last in a `NEXT` phaser did not correctly exit the loop; it now does
- RT #121147 noted that `FIRST` only worked in for loops, but not other loops; now it does

### Other smaller fixes

Here are a number of other less notable things I did.

- Fix RT #74900 (candidate with zero parameters should defeat candidate with optional parameter in no-arg multi dispatch)
- Tests covering RT #113892 and RT #115608 on call semantics (after getting confirmed that Rakudo already did the right thing)
- Review RT #125689, solve the issue in a non-hacky way, and add a test to cover it
- Fix RT #123757 (semantics of attribute initializer values passed to constructor and assignemnt was a tad off)
- Hunt down a GC hang blocking module precomp branch merge; hopefully fix it
- Review socket listen backlog patch; give feedback
- Write up rejection of RT #125400 (behavior of unknown named parameters on methods)
