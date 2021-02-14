# Racing to writeness to wrongness leads
    
*Originally published on [2014-04-17](https://6guts.wordpress.com/2014/04/17/racing-to-writeness-to-wrongness-leads/) by Jonathan Worthington.*

In the Perl world I’m mostly known as a guy who hacks on Raku stuff. Less known is that outside of the Perl world, I spend a lot of my time with the .Net platform. C#, despite a rather uninspiring initial couple of releases, has escaped Java-think and grown into a real multi-paradigm language. It’s not Perl, but it’s certainly not unpleasant, and can even be a good bit of fun to work with nowadays. My work with it right now typically involves teaching, along with various mentoring and trouble-shooting tasks.

The Windows world has always been rather into threads – at least as long as I’ve been around. .Net is also, as a result. Want to do some computation in your GUI app? Well, better farm it off to a thread, so the main thread can keep the UI responsive to the user’s needs. Want to do network I/O? Well, that could probably use some asynchronous programming – and the completion handler will be run on some thread or other. Then the results will probably want marshaling somehow. (That used to hurt; now things are better.) Building a web application? Better learn to love threads. You don’t actually get any choice in the matter: having multiple request-processing threads is the unspoken, unquestioned, default in a web application on .Net.

Of course, just because threads are almost ubiquitous doesn’t mean the average developer – or even the above-average developer – gets things right. A bunch of my recent trouble-shooting gigs have boiled down to dealing with a lack of understanding of multi-threaded programming. “So, we embed this 80s library in our web application, but things tend to crash under load.” “How do you deal with the fact that 80s library likely isn’t threadsafe?” “It…what?” “Oh, my…”

So anyway, back to Raku. Last year, we managed to get Rakudo on the JVM. And, given we now ran on a VM where folks deploy heavily threaded software every day, and with no particular progress to be seen on concurrency in Raku for years, I did what I usually seem to end up doing: get fed up of the way things are and figured I should try to make them better. Having spent a bunch of years working with and teaching about parallel, asynchronous, and concurrent programming outside of the Perl world, it was time for worlds to collide.

And oh hell, collide they do. Let’s go word counting:

```` raku
my %word_counts;
for @files -> $filename {
    for slurp($filename).words {
         %word_counts{$_}++;
    }
}
````

OK, so that’s the sequential implementation. But how about one that processes the files in parallel? Well, it seems there are a bunch of files, and that seems like a natural way to parallelize the work. So, here goes:

```` raku
my %word_counts;
await do for @files -> $filename {
    start {
        for slurp($filename).words {
            %word_counts{$_}++;
        }
    }
}
````

Here, start creates a `Promise`, which is kept when the code inside of it completes. That work is scheduled to be done on the thread pool, and the code calling start continues onward, moving on to create another `Promise` for the next file. Soon enough, the thread pool’s input queue is nicely occupied with work, and threads are chugging through it. The loop is in a context that means it produces results – the `Promise` objects – thanks to our use of the do keyword. We give them to await, which waits for them all to get done. Perfect, right?

Well, not so fast. First of all, are hashes thread safe? That is, if I try to write to a hash from multiple threads, what will happen? Well, good question. And the answer, if you try this out on Rakudo on JVM today, is you’ll end up with a hosed hash, in all likelihood. OK. Go on. Say what you’re thinking. Here’s one guess at a common response: “But…but…but…OH NO WE MUST MAKE IT WORK, this is Perl, not Java, dammit!” Well, OK, OK, let’s try to make it work…

So the hash ain’t threadsafe. Let’s go put implicit locking in hash access. We’ll slow down everything for it, but maybe with biased locking it won’t be so bad. Maybe we can build a smart JIT that invalidates the JITted code when you start a thread. Maybe escape analysis will save the common cases, because we can prove that we’ll never share things. Maybe we can combine escape analysis and trace JIT! (Hey, anybody know if there’s a paper on that?) Heck, we gotta build smart optimizations to make Raku perform anyway…

So anyway, a patch or two later and our hashes are now nicely thread safe. We’re good, right? Well, let’s run it and…ohhhh…wrong answer. Grr. Tssk. Why, oh why? Well, look at this:

```` raku
%word_counts{$_}++;
````

What does the post-increment operator do? It reads a value out of a scalar, gets its successor, and shoves the result in the scalar. Two threads enter. Both read a 41. Both add 1. Both store 42. D’oh. So, how do we fix this? Hm. Well, maybe we could make `++` take a lock on the scalar. Now we’re really, really going to need some good optimization, if we ever want tight loops doing `++` to perform. Like, inlining and then lifting locks…if we can get away with it semantically. Or one of the tricks mentioned earlier. Anyway, let’s suppose we do it. Hmm. for good measure, maybe we’d better ponder some related cases.

```` raku
%word_counts{$_} += 1;
````

Not idiomatic here, of course, but we can easily imagine other scenarios where we want something like this. So, we’d better make all the assignment meta-ops lock the target too…uh…and hold the lock during the invocation of the `+` operator. Heck, maybe we can not do locks in the spin-lock or mutex sense, but go with optimistic concurrency control, given `+` is pure and we can always retry it if it fails. So, fine, that’s the auto-increment and the assignment meta-ops sorted. But wait…what about this:

```` raku
%word_counts{$_} = %word_counts{$_} + 1;
````

Well, uhh…darn. I dunno. Maybe we can figure something out here, because having that behave differently than the `+=` case feels really darn weird. But let’s not get bogged down with side-problems, let’s get back to our original one. My hash is thread safe! My `++` is atomic, by locks, or some other technique. We’re good now, aren’t we?

Nope, still not. Why? Turns out, there’s a second data race on this line:

```` raku
%word_counts{$_}++;
````

Why does this work when we never saw the word before? Auto-vivification, of course. We go to look up the current scalar to auto-increment it. But it doesn’t exist. So we create one, but we can’t install it unless we know it will be assigned; just looking for a key shouldn’t make it come to exist. So we put off the installation of the scalar in the hash until it’s assigned. So, two threads come upon the word “manatee”. Both go and ask the hash for the scalar under that key. Access to the hash is already protected, so the requests are serialized (in the one-after-the-other sense). The hash each time notices that there’s no scalar in that slot. It makes one, attached to it the fact that it should be stored into the hash if the scalar is assigned to, and hands it back. The ++ sees the undefined value in the scalar, and sticks a 1 in there. The assignment causes the scalar to be bound to the hash…uh…wait, that’s two scalars. We made two. So, we lose a word count. Manatees may end up appearing a little less popular than dugongs as a result.

![dugong](hue-manatee.jpg)

How do we fix this one? Well, that’s kinda tricky. At first, we might wonder if it’s not possible to just hold some lock on something for the whole line. But…how do we figure that out? Trying to work out a locking scheme for the general case of auto-viv – once we mix it with binding – feels really quite terrifying, as this REPL session reveals:

```` raku
> my %animals; my $gerenuk := %animals<gerenuk>; say %animals.perl;
().hash
> $gerenuk = 'huh, what is one of those?'; say %animals.perl;
("gerenuk" => "huh, what is one of those?").hash
````

So, what’s my point in all of this? Simply, that locking is not just about thread safety, but also about the notion of transaction scope. Trying to implicitly lock stuff to ensure safe mutation on behalf of the programmer means you’ll achieve thread safety at a micro level. However, it’s very, very unlikely that will overlap with the unspoken and uncommunicated transaction scope the programmer had in mind – or didn’t even know they needed to have in mind. What achieving safety at the micro level will most certainly achieve, however, is increasing the time it takes for the programmer to discover the real problems in their program. If anything, we want such inevitably unreliable programs to reliably fail, not reliably pretend to work.

I got curious and googled for transaction scope inference, wondering if there is a body of work out there on trying to automatically figure these things out. My conclusion is that either it’s called something else, I’m crap at Google today, or I just created a thankless PhD topic for somebody. (If I did: I’m sorry. Really. :-) My hunch is that the latter is probably the case, though. Consider this one:

```` raku
while @stuff {
    my $work = @stuff.pop;
    ...
}
````

Where should the implicit transaction go here? Well, it should take in the boolification of `@stuff` and the call to `pop`. So any such general analysis is clearly inter-statement, except that we don’t want to hard-code it for boolification and popping, so it’s interprocedural, but then method calls are late-bound, so it’s undecidable. Heck, it’d be that way even in boring Java. With Perl you can go meta-programming, and then even your method dispatch algorithm might be late bound.

At this point, we might ponder software transactional memory. That’s very much on-topic, and only serves to re-inforce my point: in STM, you’re given a mechanism to define your transaction scope:

```` raku
my %word_counts;
await do for @files -> $filename {
    start {
        for slurp($filename).words {
            # THE FOLLOWING IS IMAGINARY SYNTAX. No, I can't 
            # hack you up a prototype down the pub, it's *hard*!
            atomic { %word_counts{$_}++ }
        }
    }
}
````

This looks very nice, but let’s talk about the hardware for a bit.

Yes, the hardware. The shiny multi-core thing we’re trying to exploit in all of this. The thing that really, really, really, hates on code that writes to shared memory. How so? It all comes down to caches. To make this concrete, we’ll consider the Intel i7. I’m going to handwave like mad, because I’m tired and my beer’s nearly finished, but if you want the gory details see [this PDF](http://software.intel.com/sites/products/collateral/hpc/vtune/performance_analysis_guide.pdf). Each core has an Level 1 cache (actually, two: one for instructions and one for data). If the data we need is in it, great: we stall for just 4 cycles to get hold of it. The L1 cache is fast, but also kinda small (generally, memory that is fast needs more transistors per byte we store, meaning you can’t have that much of it). The second level cache – also per core – is larger. It’s a bit slower, but not too bad; you’ll wait about 10 cycles for it to give you the data. (Aside: modern performance programming is thus more about cache efficiency than it is about instruction count.) There’s then a
level 3 cache, which is shared between the cores. And here’s where things get really interesting.

As a baseline, a hit in the level 3 cache is around 40 cycles if the memory is unshared between cores. Let’s imagine I’m a CPU core wanting to write to memory at 0xDEADBEEF. I need to get exclusive access to that bit of memory in order to do so. That means before I can safely write it, I need to make sure that any other core with it in its caches (L1/L2) tosses what it knows, because that will be outdated after my write. If some other core shares it, the cost of obtaining the cache line from L3 goes up to around 65 cycles. But what if the other core has modified it? Then it’s around 75 cycles. From this, we can see that pretty much any write to shared memory, if another core was last to write, is going to be incurring a cost of around 75 cycles. Compare that to just several cycles for unshared memory.

So how does our approach to parallelizing our word count look in the light of this? Let’s take a look at it again:

```` raku
my %word_counts;
await do for @files -> $filename {
    start {
        for slurp($filename).words {
            %word_counts{$_}++;
        }
    }
}
````

Locks are just memory, so if we inserted those automatically – even if we did work out a good way to do so – then taking the lock is a shared memory write. That’s before we go updating the memory associated with the hash table to install entries, and the memory of the scalars to update the counts. What if we STM it? Even if we keep modifications in a local modification buffer, we still have to commit at some point, and that’s going to have to be a write to shared memory. In fact, that’s the thing that bothers me about STM. It’s a really, really great mechanism – way superior to locks, composable, and I imagine not too hard to teach – but its reason for existing is to make writes to shared memory happen in a safe, transactional, way. And its those writes that the hardware makes costly. Anyway, I’m getting side-tracked again. The real point is that our naive parallelization of our program – even if we can find ways to make it work reliably – is a disaster when considered in the light of how the hardware works.

So, what to do? Here’s an alternative.

```` raku
# Produce a word counts hash per file - totally unshared!
my @all_counts = await do for @files -> $filename {
    start {
        my %word_counts;
        for slurp($filename).words {
            %word_counts{$_}++;
        }
        %word_counts
    }
}

# Bring them together into a single result.
my %totals;
for @all_counts {
    %totals{.key} += .value;
}
say %totals.elems;
````

Those familiar with map-reduce will probably have already recognized the pattern here. The first part of the program does the work for each file, producing its own word count hash (the map). This is completely thread local. Afterwards, we bring all of the results together into a single hash (the reduce). This is doing reads of data written by another thread, of course. But that’s the cheaper case, and once we get hold of the cache lines with with the hash and scalars, and start to chug through it, we’re not going to be competing for it with anything else.

Of course, the program we get at the end is a bit longer. However, it’s also not hard to imagine having some built-ins that make patterns like this shorter to get in place. In fact, I think that’s where we need to be expending effort in the Raku concurrency work. Yes, we need to harden MoarVM so that you can’t segfault it even if you do bad things. Yes, we should write a module that introduces a monitor keyword, which is a class that automatically takes a lock around each of its method calls:

```` raku
monitor ThreadSafeLoggingThingy {
    has @!log;

    method log($msg) {
        push @!log, $msg;
    }

    method latest($n) {
        $n < @!log
            ?? @!log[*-$n .. *]
            !! @!log[]
    }
}
````

Yes, we should do an Actor one too. We could even provide a trait:

```` raku
my @a is monitor;
````

Which would take `@a` and wrap it up in a monitor that locks and delegates all its calls to the underlying array. However, by this point, we’re treading dangerously close to forgetting the importance of transaction scope. At the start of the post, I told the story of the hopelessly unsafe calls to a legacy library from a multi-threaded web application. I had it hunted down and fixed in a morning because it exploded, loud and clear, once I started subjecting it to load tests. Tools to help find such bugs exist. By contrast, having to hunt bugs in code that is threadsafe, non-explosive, but subtly wrong in the placing of its transaction boundaries, is typically long and drawn out – and where automated tools can help less.

In closing, we most certainly should take the time to offer newbie-friendly concurrent, parallel, and asynchronous programming experiences in Raku. However, I feel that needs to be done by guiding folks towards safe, teachable, understandable patterns of a CSP (Communicating Sequential Processes) nature. Perl may be about Doing The Right Thing, and Doing What I Mean. But nobody means their programs to do what the hardware hates, and the right thing isn’t to make broken things sort-of-work by sweeping complex decisions on transaction scope under the carpet. “I did this thing I thought was obvious and it just blew up,” can be answered with, “here’s a nice tutorial on how to do it right; ask if you need help.” By contrast, “your language’s magic to make stuff appear to work just wasted days of my life” is a sure-fire way to get a bad reputation among the competent. And that’s the last thing we want.
