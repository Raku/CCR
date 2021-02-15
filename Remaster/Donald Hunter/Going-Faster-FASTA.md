# A Twist To The Rational Story
# Golfing Faster FASTA

*Originally published on [4 September 2018](https://donaldh.wtf/2018/09/golfing-faster-fasta/) by Donald Hunter.*

After reading *Timotimo*'s excellent [faster FASTA Please](https://wakelift.de/2018/08/31/faster-fasta-please/) blog post, I wanted to test some of the available performance tradeoffs.

## IO.slurp.lines

This is my baseline which incorporates *Timotimo*'s performance improvements to the original solution, somewhat simplified.

```` raku
my %seqs;
my $s = '';
my $id;
for 'genome.fa'.IO.slurp(:enc<latin1>).lines -> $line {
    if $line.starts-with('>') {
        if $id {
            %seqs{$id} = $s;
            $id = Nil;
        }
        $id = $line.substr(1);
        $s = '';
    } else {
        $s ~= $line;
    }
}
if $id {
    %seqs{$id} = $s;
}
say "Took { now - BEGIN now } seconds";
````

````
Took 3.58698513 seconds
````

## IO.lines

What if we avoid using slurp? Hopefully `IO.lines` will manage to be faster.

```` raku
my %seqs;
my $s = '';
my $id;
for 'genome.fa'.IO.lines(:enc<latin1>) -> $line {
    if $line.starts-with('>') {
        if $id {
            %seqs{$id} = $s;
            $id = Nil;
        }
        $id = $line.substr(1);
        $s = '';
    } else {
        $s ~= $line;
    }
}
if $id {
    %seqs{$id} = $s;
}
say "Took { now - BEGIN now } seconds";
````

````
Took 4.71259838 seconds
````

After a few runs, it seems to average out at being just a bit slower than slurping the file
before iterating. But it has the advantage of avoiding the memory required for the whole file
and should scale better for much larger files.

## Split and Skip

This is my baseline for the second implementation in *Timotimo*'s post.

```` raku
my %seqs = slurp('genome.fa', :enc<latin1>).split('>').skip(1).map: {
    .head => .skip(1).join given .split("\n").cache;
}
say "Took { now - BEGIN now } seconds";
````

````
Took 7.4847424 seconds
````

## Racing Split and Skip

```` raku
my %seqs = slurp('genome.fa', :enc<latin1>).split('>').skip(1).race.map: {
    .head => .skip(1).join given .split("\n").cache;
}
say "Took { now - BEGIN now } seconds";
````

````
4.2423127
````

## Hyper Split and Skip

```` raku
my %seqs = slurp('genome.fa', :enc<latin1>).split('>').skip(1).hyper.map: {
    .head => .skip(1).join given .split("\n").cache;
}
say "Took { now - BEGIN now } seconds";
````

````
Took 5.2303269 seconds
````
