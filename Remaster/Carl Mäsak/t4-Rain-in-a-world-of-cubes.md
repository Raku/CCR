# t4: Rain in a world of cubes
    
*Originally published on [30 May 2014](http://strangelyconsistent.org/blog/t4-rain-in-a-world-of-cubes) by Carl Mäsak.*

```
<flussence> as a minecraft player I figured out what t4 was asking pretty much instantly :)
```

This is me trying to emerge from the big strange writer's block that has
inexplicably formed around the t4 blog post. Here goes.

The t4 task was my clear favorite this year. It has a certain William Gibson
quality to it, with virtual rain falling inside a three-dimensional world where
everything is made of cubes which mostly just hang there, suspended, in
mid-air.

## Simulate rain in a world of cubes

Write a program that calculates the volume of rain water collected in the cube
world described below.

The cube world &mdash; given as input &mdash; consists of a finite set of cubes
on integer coordinates `(x, y, z)`. The positive `y` coordinate means "up".

An infinite amount of rain then falls from an infinite height. Both of these
infinities are taken to really mean "large enough as to make no difference".

As it lands on cubes, the water will follow predictable rules:

* Rain falls everywhere.
* Water falling will land on the first cube below it. It does not fall through cubes.
* Water will collect on levels where walls on all sides will keep it in.
* Water will produce vertical waterfalls where such walls are missing.
* Cubes are packed tightly enough that gaps between cubes sharing an edge will not let water through. However, the same gaps will readily let air through if water needs to displace air for some reason.

Waterfalls work in the simplest way imaginable: if water "escapes" from a      
structure of cubes, it will fall straight down along the first available
"chute" of cube-formed empty cells until it hits a cube. (Which it may not
necessarily do. A waterfall may go on to infinite depth.) As a waterfall hits a
cube, it behaves just like other kinds of water: it may spread, collect, and
form new waterfalls as needed.

People had different ideas how to solve this one:

- **Massive flood**

Fill the whole universe with water, and then carefully
drain it, taking note of what's left.

- **Multiple joining pools**

Keep track of all the individual bodies of water.
Raise the water level as long as that's still possible, and join together
bodies of water that touch.

- **Waterfall, Frozen**

Track all bodies of water, following waterfalls in the
forwards direction. For each cell proven to contain steady-state water, turn
that block into solid wall, and increase a counter by 1.

I had fun guessing what solutions people would come up with. I correctly
guessed the first two, but not the last one. I guess it's a bit too mutable for
my FP brain to come up with these days.

Anyway, the mistakes! Oh, the *mistakes*. Not just one or two contestants for
this one; *all* of them. Turns out simulating rain on cubes is hard!

Here follows a choice list of assumptions broken by the contestants, that make
their programs return odd results.

## Assuming that rain can reach where it can't

```
XXX
X.X
X.X
XXX
```

Let me explain the above picture. In order to test the four entrants against
odd cases, I wrote a small program that builds a cube world from the above
syntax. It only describes a cross-section; and so walls in the depth direction
are automatically added. In other words, the above depicts a sealed box with no
way in.

It should contain no rainwater, of course. One of the programs returns that
it's full of water.

Oh, and by the way, the script that produces coordinates from pictures like the
above turned out quite cute and simple, so let me share it:

```raku
my %coords =
    ' ' => [         ],
    'X' => [-1, 0, +1],
    '.' => [-1,    +1],
    '~' => [-1,    +1],
;
for lines.kv -> $y, $line {
    for $line.comb.kv -> $x, $char {
        for %coords{$char}.list -> $z {
            say "($x, {-$y}, $z)";
        }
    }
}
```

## Assuming that the water can rise higher than its lowest outlet

```
  XXX
  X.X
  X.X
X~X~X
X~X~X
X~~~X
XXXXX
```

It's for cases like this that I felt a need in the problem description to talk
about gaps between cubes that "will readily let air through if water needs to
displace air". In other words, if the above is a kind of
[barometer](https://en.wikipedia.org/wiki/File:Barometer_Goethe_01.jpg), then
it's a completely useless one, because it leaks air and water find an
equilibrium based only on itself.

...which means that the correct answer above is 7. That's the number of
waterfilled cubes when the water level is the same "inside" the barometer and
at its mouth.

One of the programs got 9, assuming that the barometer fills up completely. Two
programs got 0, assuming no water can even enter.

Speaking of which...

## Assuming that some vessels are unable to contain water

```
    XXX
X~X X~X
X~XXX~X
X~~~~~X
XXXXXXX
```

Two programs had trouble with this one. I don't know if it's because of the
banana shape or the cover over one of the ends. But they got 0 cells of
rainwater collecting in it, when the correct answer is that it fills up all 9
internal cells.

## Underestimating the size of a vessel

```raku
XXXX~XXXX
X~~~~~~~X
X~~~~~~~X
X~~X~X~~X
X~~X~X~~X
XXXXXXXXX
```

A small vessel sitting in a bigger vessel. A naive program might reach the brim
of the small vessel, figure "oh, ok, we're done here", and then not fill up the
bigger vessel with water.

This happened with one of the programs.

## Concreteness and TDD

I've mentioned it in previous posts, but the way I pick problems for the
contest is I find problems where I myself go "oh, that's easy, I'll just..."
and then a while later, I go "...oh wait." Problems that *look* easy on the
surface, but then turn out to have hidden depths. (A bit like these vessels
holding water can have hidden depts, tunnels, nooks and crannies.) One of my
favorite feelings when I design something is having the model "break" for a
certain case. It's like the floor falling out from under me, and I have to
re-orient myself inside the solution space to accomodate the new rules.

All the failures above emphasize the need for having *actual* test cases to run
the program against. The base tests I send with the problems are
(intentionally) inadequate for this purpose. The contestant is meant to think
up their own tests, consider edge cases, special cases, and pathological cases.

To me, that's where unit testing shines. Development suddenly becomes a
back-and-forth discussion between you and the programming substrate over
something very tangible: concrete cases.

## Only one champion still standing

Only one of the programs passes all of the above tests with flying colors.
Well, I do want to stress that all four contestants made brave efforts. But for
one reason or another, one of the four programs ended up especially correct.

Check out [the
reviews](https://github.com/masak/p6cc2012/tree/master/t4/review) for details.

## ...no, wait

Hm. What about this case?

```
XXXX~XXXX
X~~~~~~~X
X~~XXX~~X
X~~~~~~~X
XXXXXXXXX
```

Should be able to hold 19 cells of water, right? Well, wouldn't you know. Our
so-far unblemished program fails this one, with the cryptic error message
`Merging non-balanced water masses`. (Two other programs get the correct 19,
and the last one gets 0.)

So I take it back. *None* of the programs are correct. Pity. But my points
about deep model thinking and representative test cases still stands.
Correctness is hard!

Next up: distributing weights evenly in bags.
