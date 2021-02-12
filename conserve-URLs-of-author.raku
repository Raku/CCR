sub filename($author) { "Collect/$author.md".IO }

sub MAIN($author where filename($author).e) {
    for filename($author).lines.grep: *.starts-with("- ") {
        if m/ '[' (.*?) '](' (.*?) ')' / {
            my $basename = $0.subst('/', '-', :g);
            my $url      = ~$1;
            my $path     = "Conserve/$author/$basename.html".IO;
            unless $path.e {
                my $proc = run 'curl', $url, :out;
                $path.IO.spurt("$url\n" ~ $proc.out.slurp(:close));
            }
        }
        else {
            warn "no link found in '$_'";
        }
    }
}
