sub filename($author) { "Collect/$author.md".IO }

sub MAIN($author where filename($author).e) {
    my @done;

    for filename($author).lines.grep: *.starts-with("- ") {
        if m/ '[' (.*?) '](' (.*?) ')' / {
            my $basename = $0.subst('/', '-', :g);
            my $url      = ~$1;
            my $path     = "Conserve/$author/$basename.html".IO;
            unless $path.e {
                my $proc = run 'curl', $url, :out, :err;
                $path.spurt("$url\n" ~ $proc.out.slurp(:close));
                $proc.err.slurp(:close);
                @done.push: ~$path;
            }
        }
        else {
            warn "no link found in '$_'";
        }
    }

    say @done.sort.join("\n")
}
