# Extending the syntax of Raku
    
*Originally published on [17 October 2010](http://strangelyconsistent.org/blog/extending-the-syntax-of-perl6) by Carl Mäsak.*

Raku allows us to define classes and roles and grammars, and they all look much the same.

```raku
class C {
    method foo { ... }
    method bar { ... }
}
role R {
    method foo { ... }
    method bar { ... }
}
grammar G {
    regex foo { ... }
    token bar { ... }
}
```

The similarities don't just exist on the surface; all these three OO-style packages get parsed with the same rule (`package_declarator`) in the Perl6 grammar, and their insides get parsed with the same rule (`package_def`). The only difference is the metaclass object handed to each one. ("What's a metaclass?" you might ask. If you are, I recommend [this post](https://6guts.wordpress.com/2010/09/20/gradual-typing-merged-mops-and-bounded-serialization/) by *jnthn*++.)

So classes get handed a `ClassHOW`, roles a `RoleHOW`, and grammars a `GrammarHOW`. And that's basically how they differ. In theory, if we wanted to give (Rakudo) Raku a bigger repertoire of OO-style package declarators, all we have to do is add a few rules to the Raku grammar, and add a new `SomethingHOW` metaclass.

The operative phrase being "in theory". See, no-one has ever done this, and whereas things are designed for people *eventually* being able to do that. Right now, you're advised to sit back and wait while some foolhardy person gets a thousand small cuts and bruises trying to make it all work without a hitch.

That's where I come in.

## The new syntax

This is going to look almost trivial. Well, it *is* trivial to describe. One day it'll be trivial to get to work in Rakudo as well. Here's the new syntax:

```raku
diagram D {
    element foo { ... }
    element bar { ... }
}
```

Hm; actually, I have a full-blown example of the `diagram` DSL, that I might as well show at this point.

```raku
class Page {
    has Str $.style = 'fill: #333333';
}
class Book {
    has Str $.abbreviation;
    has Str $.name;
    has Str $.author;
    has Str $.year;
    has Page @.pages;
}
diagram BookLayout {
    element LAYOUT { <booktable> on <attribution> }
    element booktable { table(<book> from .books, :4columns) }
    element book { .abbreviation on table(<page> from .pages, :10columns) }
    element page { <rect width="1" height="2" style="{.style}"> }
    element attribution {
        vline on "SOURCE BOOKS"
              on table(<source> from .books, :2columns, :down)
    }
    element source { .name on "by $_.author, $_.year" }
}
my Book @books = ...;
BookLayout.render(:@books);
```


The above example was written to produce something very much like the third image over at [One book, many readings](https://samizdat.cc/cyoa/). (Here's a [direct link to the image](https://s3.amazonaws.com/cyoa/img/etc/endings-grid-i.png).) Compare the elements in that image and the `element`s in the `BookLayout` diagram, and you'll see the similarities.

The final line, `BookLayout.render(:@books);`, would spit out a string full of SVG, or some other scene description format. The array `@book` would contain 12 `Book` objects corresponding to the 12 books in the image.

Anyway, I thought this was a nice idea. It's certainly the best idea for a non-core extension to Raku that I've been able to think up so far. The syntax of the `element` blocks is reminiscent of Raku `regex` syntax, but the process is almost a reverse of the one for regexes: whereas a grammar does a complicated dance over a string of text and eventually produces an object hierarchy (a parse tree), a diagram does a complicated dance over an object hierarchy (in this case, a set of `Book`s with sets of `Page`s) and produces an image.

Did I get Rakudo to parse my new syntax? Yes, I did. Here's how to do it.

## Adding a new package declarator

I wanted to add the package declarator `diagram` and hook it up with a metaclass `DiagramHOW`. So I added these rules to `src/Perl6/Grammar.pm`:

```
     %*HOW<module>  := 'none';
     %*HOW<class>   := 'ClassHOW';
     %*HOW<grammar> := 'GrammarHOW';
+    %*HOW<diagram> := 'DiagramHOW';
     %*HOW<role>    := 'RoleHOW';
     my %*PKGCOMPILER;
     %*PKGCOMPILER<role>    := Perl6::Compiler::Role;
     <sym> :my $*PKGDECL := 'grammar';
     <package_def>
 }
+token package_declarator:sym<diagram> {
+    <sym> :my $*PKGDECL := 'diagram';
+    <package_def>
+}
 token package_declarator:sym<role> {
     <sym> :my $*PKGDECL := 'role';
     <package_def>
```

`GrammarHOW` is defined in `src/metamodel/GrammarHOW.pir`. I just took that file, replaced every occurrence of `Grammar` with `Diagram`, and saved the result as `src/metamodel/DiagramHOW.pir`. Since `GrammarHOW.pir` made reference to a `Grammar` class in `src/core/Grammar.pm`, I created a `Diagram` class and saved it in `src/core/Diagram.pm`.

In `src/Perl6/Actions.pm` I had to make a corresponding addition:

```
 method package_declarator:sym<module>($/)  { make $<package_def>.ast; }
 method package_declarator:sym<class>($/)   { make $<package_def>.ast; }
 method package_declarator:sym<grammar>($/) { make $<package_def>.ast; }
+method package_declarator:sym<diagram>($/) { make $<package_def>.ast; }
 method package_declarator:sym<role>($/)    { make $<package_def>.ast; }
 method package_declarator:sym<does>($/) {
```

Usually when I made a false step and got an internal error (not shown here), it was because I had neglected to add something to 
`src/Perl6/Actions.pm`.

## Adding the `element` declarator

Adding this to `src/Perl6/Grammar.pm`:

```
 token term:sym<routine_declarator> { <routine_declarator> }
 token term:sym<multi_declarator>   { <?before 'multi'|'proto'|'only'> <multi_declarator> }
 token term:sym<regex_declarator>   { <regex_declarator> }
+token term:sym<element_declarator> { <element_declarator> }
 token term:sym<circumfix>          { <circumfix> }
 token term:sym<statement_prefix>   { <statement_prefix> }
 token term:sym<**>                 { <sym> <.panic('HyperWhatever (**) not 
     | '(' ~ ')' <signature> <trait>*
     | <routine_declarator>
     | <regex_declarator>
+    | <element_declarator>
     | <type_declarator>
     ]
 }
+proto token element_declarator { <...> }
+token element_declarator:sym<element> {
+    <sym> {*} #= open
+    :my $*METHODTYPE := 'regex';
+    <element_def>
+}
+rule element_def {
+    [
+      { $*IN_DECL := '' }
+      <deflongname>?
+      <.newpad>
+      [ [ ':'?'(' <signature> ')'] | <trait> ]*
+      {*} #= open
+      '{'[ '<...>' |<p6regex=.LANG('Regex','nibbler')>]'}'<?ENDSTMT>
+    ] || <.panic: "Malformed element">
+}
```

And this to `src/Perl6/Actions.pm`:

```
     if    $<variable_declarator> { make $<variable_declarator>.ast }
     elsif $<routine_declarator>  { make $<routine_declarator>.ast  }
     elsif $<regex_declarator>    { make $<regex_declarator>.ast    }
+    elsif $<element_declarator>  { make $<element_declarator>.ast  }
     elsif $<signature> {
         my $list  := PAST::Op.new( :pasttype('call'), :name('&infix:<,>') );
         my $decls := $<signature>.ast.get_declarations;
+method element_declarator:sym<element>($/, $key?) {
+    if ($key) {
+        my %h;
+        %REGEX_MODIFIERS := %h;
+    } else {
+        make $<element_def>.ast;
+    }
+}
+method element_def($/, $key?) {
+    make PAST::Stmts.`new`;
+}
+class Perl6::DiagramActions {
+}
+
```

At this point, `element` declarations just called into the normal regex sublanguage. Needed to change this as a final step.

## Adding the `Perl6::Diagram` sublanguage

Finally, we make these changes to `src/Perl6/Grammar.pm`:

```
     my %*LANG;
     %*LANG<Regex>           := Perl6::Regex;
     %*LANG<Regex-actions>   := Perl6::RegexActions;
+    %*LANG<Diagram>         := Perl6::Diagram;
+    %*LANG<Diagram-actions> := Perl6::DiagramActions;
     %*LANG<MAIN>            := Perl6::Grammar;
     %*LANG<MAIN-actions>    := Perl6::Actions;
-      '{'[ '<...>' |<p6regex=.LANG('Regex','nibbler')>]'}'<?ENDSTMT>
+      '{'[ '<...>' |<p6regex=.LANG('Diagram','expr')>]'}'<?ENDSTMT>
+grammar Perl6::Diagram is HLL::Grammar {
+    rule expr { <thing> ** 'on' }
+
+    token thing {
+        [
+        | <quote>
+        | <attribute>
+        | <call>
+        | 'vline'
+        | :s 'table(' <expr> [',' ':'\d*<identifier> ]* ')'
+        ]
+    }
+
+    token quote {
+        [
+        | <?[']> <quote_EXPR: ':q'>
+        | <?["]> <quote_EXPR: ':qq'>
+        ]
+    }
+
+    token call {
+        '<' <identifier>
+        [
+        | '>' :s [from <attribute>]?
+        | :s [ <identifier> '=' <quote>]* '>'
+        ]
+    }
+
+    token identifier { <.ident> [ <[\-']> <.ident> ]* }
+
+    token attribute { '.'<.identifier> }
+}
```

The above grammar parses my `BookLayout` example above. I guess the cool thing isn't that it does, but that it parses it *inside a regular Raku script*. That's what this was all about, after all. The technology is there in Rakudo; it's just not user-accessible yet.

## Simple as that, eh?

Doing this today is not easy. I stumbled upon maybe ten types of internal error along the way, about half of which I never managed to diagnose, but simply got rid of by doing things again, more slowly.

Summarizing the situation:

- Yes, extending the syntax is *possible*. It's not particularly easy. That's just because the Raku vision isn't fully implemented yet. But there is a roadmap, and we're sticking to it.
- None of the internals hacking will be needed once this works the real way. I'll still have to modify the grammar and the actions, and I'll still have to add a `DiagramHOW` metaclass, but I'll do it from the safety of a perl script or a module, not by prying open the Rakudo source files.
- I'm sure there's a whole heap of errors that could be removed or improved here. Problem is, my usual instinct for submitting bugs gets put on hold when I'm doing naughty things like internals hacking. What would I report it as? "[BUG] Nasty error message after applying this patch to Rakudo"? Somehow that doesn't feel right.
- After getting diagrams to parse, I have *no idea whatsoever* how to give them the right semantics. What grammars do is to emit the regexes as specialized `PAST` nodes. There are no specialized `PAST` nodes for diagrams.

Looking forward to seeing this get much easier over time.
