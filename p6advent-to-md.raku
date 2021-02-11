# Helper script to do the initial conversion of HTML as produced in the
# Perl 6 Advent calendars to markdown.  Please note that this is only a
# rough translation, manual work should be done afterwards to complete
# the work.

my %*SUB-MAIN-OPTS = :named-anywhere;

my @month = <NaM
  January February March     April   May      June
  July    August   September October November December
>;

sub MAIN(IO() $source where .starts-with('Conserve/') && .IO.f, :$force) {

    my $author = $source.Str.split('/').skip.head;

    sub cleanup(\content) {
        content = content
          .subst('”',        '"'               , :global)
          .subst('“',        '"'               , :global)
          .subst('<p>',      "\n"              , :global)
          .subst('</p>'                        , :global)
          .subst('<br />'                      , :global)
          .subst('<em>',     '*'               , :global)
          .subst('</em>',    '*'               , :global)
          .subst('<ul>',     "\n"              , :global)
          .subst('</ul>',    "\n"              , :global)
          .subst("\n<li>",   "\n- "            , :global)
          .subst('</li>'                       , :global)
          .subst('<i>',      '*'               , :global)
          .subst('</i>',     '*'               , :global)
          .subst('<b>',      '**'              , :global)
          .subst('</b>',     '**'              , :global)
          .subst('<h2>',     "\n## "           , :global)
          .subst('</h2>'                       , :global)
          .subst('<h3>',     "\n### "          , :global)
          .subst('</h3>'                       , :global)
          .subst('Perl 6',   'Raku'            , :global)
          .subst('Perl 6',   'Raku'            , :global)  # non-breaking space
          .subst('P6',       'Raku'            , :global)
          .subst('PERL6',    'RAKU'            , :global)
          .subst('Perl 5',   'Perl'            , :global)
          .subst('Perl 5',   'Perl'            , :global)  # non-breaking space
          .subst('P5',       'Perl'            , :global)
          .subst('Parcel',   'List'            , :global)
          .subst("\n<code>",  "\n\n```` raku"  , :global)
          .subst("</code>\n", "````\n"         , :global)
          .subst('<code>',    '`'              , :global)
          .subst('</code>',   '`'              , :global)
          .subst("\n<pre>",   "\n\n```` raku\n", :global)
          .subst("</pre>\n", "\n````\n"        , :global)
          .subst('&nbsp;',   ' '               , :global)
          .subst('&gt;',     '>'               , :global)
          .subst('&lt;',     '<'               , :global)
          .subst('&amp;',    '&'               , :global)
          .subst('&trade;',  '™'               , :global)
          .subst('–',        '-'               , :global)
          .subst('TimToady', '*TimToady*'      , :global)
          
          .subst(/ perl6 ['-' \w]? /, 'raku'                   , :global)
          .subst(/ '&#' \d+ ';' /,    { $/.substr(2,*-1).chr } , :global)
          .subst(
            / '<a href="' (<-["]>+) '">' (<-[<]>*) '</a>' /,
            { "[$1]($0)" },
            :global)
          .subst(/ (\w+) '++' /,        { "*$0*++" }           , :global)
          .subst(/ (\w+) '()' /,        { "`$0`" }             , :global)
          .subst( / ^ 'Day ' \d+ ' – ' /                       , :global)
        ;
    }

    my $content = $source.slurp;
    my $header;
    my $footer;

    ($header,$content) = $content.split(/ '<div class="entry-content">' \s+ /);
    ($content,$footer) = $content.split('<div id="jp-post-flair"');

    $header ~~ / '<h1 class="entry-title">' (<-[<]>+) /;
    my $title = ~$0;
    $header ~~ / '<span class="posted-on"><a href="' (<-["]>+) /;
    my $url   = ~$0;
    $header ~~ / '"entry-date published" datetime="' (<-["]>+) /;
    my $date  = .day ~ " @month[.month] " ~ .year given $0.substr(0,10).Date;

    cleanup $content;
    cleanup $title;

    $content = qq:to/HEADER/;
# $title
    
*Originally published on [$date]($url) by $author.*
$content
HEADER

    my $destination = $title;
    $destination = $destination
      .subst(',',      :global)
      .subst('.',      :global)
      .subst('!',      :global)
      .subst(' ', '-', :global)
    ;
    $destination = "Remaster/$author/$destination.md".IO;
    if $force or !$destination.f {
        $destination.IO.spurt($content);
    }
    else {
        note "File $destination already exists and --force not specified"
    }
}
