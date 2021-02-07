sub filename($author) { "Collect/$author.md".IO }

sub MAIN($author where filename($author).e) {
    for filename($author).lines.grep: *.starts-with("- ") {
        if m/ '[' (.*?) '](' (.*?) ')' / {
            my $proc = run 'curl', ~$1, :out, :err;
            "Conserve/$author/$0.html".IO.spurt($proc.out.slurp(:close));
            $proc.err.slurp.say;
        }
        else {
            warn "no link found in '$_'";
        }
    }
}
